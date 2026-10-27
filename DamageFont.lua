--[[
    Bordo UI - Modern Scrolling Combat Text & Damage Numbers (DamageFont.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Side Stacked Combat Text with Spell Icons and Multi-hit badges (x2, x3, x4)
      (Exactly matching user screenshot / MikScrollingBattleText style)
    - Positioned beside player character (Outgoing Damage on Right, Incoming/Heals on Left)
    - Multiple Styles: Side Stack, WoW Classic Arc, and Scroll Up
    - Smart Filters: All Damage, No DoT-Spam (direct hits & crits only), Only Crits, Disabled
    - In-World 3D Mob Numbers Toggle: Can be completely hidden to eliminate clutter over ads!
    - Full English UI & Tooltips
    - Live Test Simulation Button
]]--

BordoUI = BordoUI or {};
AZSHelper = AZSHelper or {};

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";

-- Available Font Assets
local FONTS = {
    modern  = { name = "Modern Sans",  path = "Interface\\AddOns\\BordoUI\\Media\\modern.ttf" },
    classic = { name = "Classic WoW",  path = "Fonts\\FRIZQT__.TTF" },
    arcade  = { name = "Arcade Narrow",path = "Fonts\\ARIALN.TTF" },
    russo   = { name = "Russo Bold",   path = "Interface\\AddOns\\BordoUI\\Fonts\\RussoOne-Regular.ttf" },
    exo     = { name = "Exo Sci-Fi",   path = "Interface\\AddOns\\BordoUI\\Fonts\\Exo-SemiBold.ttf" },
};

-- Default Settings (All English)
function BordoUI:GetDamageSettings()
    BordoUIDB = BordoUIDB or {};
    if ( not BordoUIDB.damageSettings ) then
        BordoUIDB.damageSettings = {
            style       = "side",     -- "side" (Stacked beside character with icons), "arc" (WoW Arc), "up" (Scroll Up)
            filter      = "nodots",   -- "all", "nodots", "crits", "off"
            inWorld     = false,      -- false = hide numbers over ads; true = show numbers over ads
            font        = "modern",   -- "modern", "classic", "arcade", "russo", "exo"
            scale       = 0.85,       -- 0.50, 0.70, 0.85, 1.00, 1.25
            icons       = true,       -- Show spell icons
            stacking    = true,       -- Merge rapid identical hits with x2, x3, x4
        };
    end
    return BordoUIDB.damageSettings;
end

-- School / Spell Color Palette
local SPELL_COLORS = {
    physical = { 1.00, 1.00, 1.00 }, -- White
    holy     = { 1.00, 0.90, 0.50 }, -- Pale Gold
    fire     = { 1.00, 0.45, 0.10 }, -- Orange
    nature   = { 0.30, 0.90, 0.30 }, -- Vibrant Green
    frost    = { 0.40, 0.80, 1.00 }, -- Sky Blue
    shadow   = { 0.75, 0.45, 1.00 }, -- Deep Violet
    arcane   = { 1.00, 0.50, 1.00 }, -- Pink / Magenta
    heal     = { 0.20, 1.00, 0.30 }, -- Green
    crit     = { 1.00, 0.82, 0.00 }, -- Gold
};

local function DetectSchoolColor(spellName, isCrit)
    if ( isCrit ) then return SPELL_COLORS.crit; end
    if ( not spellName ) then return SPELL_COLORS.physical; end
    local lower = string.lower(spellName);
    if ( string.find(lower, "fire") or string.find(lower, "feuer") or string.find(lower, "flame") or string.find(lower, "pyro") or string.find(lower, "scorch") or string.find(lower, "ignite") or string.find(lower, "blast") ) then
        return SPELL_COLORS.fire;
    elseif ( string.find(lower, "frost") or string.find(lower, "ice") or string.find(lower, "blizzard") or string.find(lower, "eis") or string.find(lower, "chill") ) then
        return SPELL_COLORS.frost;
    elseif ( string.find(lower, "shadow") or string.find(lower, "schatten") or string.find(lower, "drain") or string.find(lower, "curse") or string.find(lower, "corruption") or string.find(lower, "pain") or string.find(lower, "death") ) then
        return SPELL_COLORS.shadow;
    elseif ( string.find(lower, "holy") or string.find(lower, "heilig") or string.find(lower, "smite") or string.find(lower, "wrath") or string.find(lower, "consecrat") or string.find(lower, "justice") ) then
        return SPELL_COLORS.holy;
    elseif ( string.find(lower, "nature") or string.find(lower, "natur") or string.find(lower, "lightning") or string.find(lower, "blitz") or string.find(lower, "poison") or string.find(lower, "gift") or string.find(lower, "earth") or string.find(lower, "chain") ) then
        return SPELL_COLORS.nature;
    elseif ( string.find(lower, "arcane") or string.find(lower, "arkan") or string.find(lower, "missile") or string.find(lower, "star") or string.find(lower, "moon") ) then
        return SPELL_COLORS.arcane;
    end
    return SPELL_COLORS.physical;
end

-------------------------------------------------------------------------------
-- SCROLLING COMBAT TEXT (SCT) DISPLAY ENGINE
-------------------------------------------------------------------------------
local SCT = {
    lines = {},
    maxLines = 14,
    lineHeight = 22,
};
BordoUI.SCT = SCT;

-- Anchor Frames (Positioned left and right of player character)
local outgoingAnchor = CreateFrame("Frame", "BordoUI_SCT_OutgoingAnchor", UIParent);
outgoingAnchor:SetWidth(120);
outgoingAnchor:SetHeight(30);
outgoingAnchor:SetPoint("CENTER", UIParent, "CENTER", 140, 30);
outgoingAnchor:SetMovable(true);
outgoingAnchor:EnableMouse(true);
outgoingAnchor:RegisterForDrag("LeftButton");

local incomingAnchor = CreateFrame("Frame", "BordoUI_SCT_IncomingAnchor", UIParent);
incomingAnchor:SetWidth(120);
incomingAnchor:SetHeight(30);
incomingAnchor:SetPoint("CENTER", UIParent, "CENTER", -140, 30);
incomingAnchor:SetMovable(true);
incomingAnchor:EnableMouse(true);
incomingAnchor:RegisterForDrag("LeftButton");

local function SetupAnchorDrag(anchor, saveKey, labelText)
    anchor:SetScript("OnDragStart", function()
        if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
            anchor:StartMoving();
        end
    end);
    anchor:SetScript("OnDragStop", function()
        anchor:StopMovingOrSizing();
        local pt, _, relPt, x, y = anchor:GetPoint();
        BordoUIDB = BordoUIDB or {};
        BordoUIDB[saveKey] = { point = pt, relativePoint = relPt, x = x, y = y };
    end);
    
    local lbl = anchor:CreateFontString(nil, "OVERLAY");
    lbl:SetFont(FONT_PATH, 9, "OUTLINE");
    lbl:SetPoint("CENTER", anchor, "CENTER", 0, 0);
    lbl:SetText(labelText);
    lbl:SetTextColor(0.5, 0.8, 1.0, 0.6);
    lbl:Hide();
    anchor.label = lbl;
end

SetupAnchorDrag(outgoingAnchor, "sctOutgoingPos", "Outgoing Damage");
SetupAnchorDrag(incomingAnchor, "sctIncomingPos", "Incoming Damage");

function BordoUI:UpdateSCTAnchorVisibility()
    local locked = BordoUIDB and BordoUIDB.locked;
    if ( not locked ) then
        outgoingAnchor.label:Show();
        incomingAnchor.label:Show();
    else
        outgoingAnchor.label:Hide();
        incomingAnchor.label:Hide();
    end
end

-- Line Pool
local function CreateSCTLine(id)
    local line = CreateFrame("Frame", "BordoUI_SCT_Line_" .. id, UIParent);
    line:SetWidth(180);
    line:SetHeight(24);
    line:SetFrameStrata("HIGH");
    line:SetFrameLevel(15 + id);
    line:Hide();
    
    -- Spell Icon with dark border
    local iconFrame = CreateFrame("Frame", nil, line);
    iconFrame:SetWidth(18);
    iconFrame:SetHeight(18);
    iconFrame:SetPoint("LEFT", line, "LEFT", 0, 0);
    iconFrame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 8,
        edgeSize = 8,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    });
    iconFrame:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.95);
    
    local icon = iconFrame:CreateTexture(nil, "ARTWORK");
    icon:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 1, -1);
    icon:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1, 1);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    line.icon = icon;
    line.iconFrame = iconFrame;
    
    -- Main Damage Number Text
    local text = line:CreateFontString(nil, "OVERLAY");
    text:SetFont(FONT_PATH, 16, "OUTLINE");
    text:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0);
    text:SetJustifyH("LEFT");
    line.text = text;
    
    -- Multiplier Badge (e.g. x2, x3, x4)
    local badge = line:CreateFontString(nil, "OVERLAY");
    badge:SetFont(FONT_PATH, 12, "OUTLINE");
    badge:SetPoint("LEFT", text, "RIGHT", 3, -1);
    badge:SetTextColor(1.0, 0.82, 0.20);
    badge:Hide();
    line.badge = badge;
    
    line.age = 0;
    line.active = false;
    line.count = 1;
    return line;
end

-- Initialize Line Pool
for i = 1, SCT.maxLines do
    table.insert(SCT.lines, CreateSCTLine(i));
end

-- Spawn or Stack Combat Text Line
function BordoUI:AddCombatNumber(spellName, amount, isCrit, isIncoming, isHeal)
    local s = self:GetDamageSettings();
    if ( s.filter == "off" ) then return; end
    if ( s.filter == "crits" and not isCrit ) then return; end
    
    local fontDef = FONTS[s.font] or FONTS.modern;
    local fontPath = fontDef.path;
    local scale = tonumber(s.scale) or 0.85;
    
    -- Resolve Spell Icon
    local iconPath = "Interface\\Icons\\INV_Sword_04";
    if ( AZSHelper and AZSHelper.GetSpellIcon ) then
        iconPath = AZSHelper:GetSpellIcon(spellName);
    elseif ( SurvivorUI_MeterIcon ) then
        iconPath = SurvivorUI_MeterIcon(spellName) or iconPath;
    end
    
    local parentAnchor = isIncoming and incomingAnchor or outgoingAnchor;
    local now = GetTime();
    
    -- Check for Hit Stacking (if same spell hit within 0.4s, stack counter like x2, x3, x4!)
    if ( s.stacking ) then
        for i = 1, SCT.maxLines do
            local l = SCT.lines[i];
            if ( l.active and l.spellName == spellName and (now - l.spawnTime) < 0.45 ) then
                l.count = l.count + 1;
                l.amount = l.amount + amount;
                l.age = 0.1; -- Refresh duration
                
                -- Format text with stacked number & multiplier badge
                local numText = string.format("%d", l.amount);
                if ( l.isCrit or isCrit ) then
                    l.isCrit = true;
                    l.text:SetText(string.format("♦ %s ♦", numText));
                    l.text:SetTextColor(SPELL_COLORS.crit[1], SPELL_COLORS.crit[2], SPELL_COLORS.crit[3]);
                else
                    l.text:SetText(numText);
                end
                
                l.badge:SetText(string.format("x%d", l.count));
                l.badge:Show();
                return;
            end
        end
    end
    
    -- Find an available line
    local targetLine = nil;
    local oldestAge = -1;
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( not l.active ) then
            targetLine = l;
            break;
        elseif ( l.age > oldestAge ) then
            oldestAge = l.age;
            targetLine = l;
        end
    end
    if ( not targetLine ) then return; end
    
    targetLine.active = true;
    targetLine.age = 0;
    targetLine.spawnTime = now;
    targetLine.spellName = spellName;
    targetLine.amount = amount;
    targetLine.isCrit = isCrit;
    targetLine.isIncoming = isIncoming;
    targetLine.count = 1;
    targetLine.parentAnchor = parentAnchor;
    
    -- Setup Icon
    if ( s.icons and iconPath ) then
        targetLine.icon:SetTexture(iconPath);
        targetLine.iconFrame:Show();
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine.iconFrame, "RIGHT", 4, 0);
    else
        targetLine.iconFrame:Hide();
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine, "LEFT", 0, 0);
    end
    
    -- Setup Font & Size
    local fontSize = isCrit and math.floor(18 * (scale / 0.75)) or math.floor(14 * (scale / 0.75));
    targetLine.text:SetFont(fontPath, fontSize, "OUTLINE");
    targetLine.badge:SetFont(fontPath, math.max(10, fontSize - 3), "OUTLINE");
    targetLine.badge:Hide();
    
    -- Setup Color & Text
    local numStr = string.format("%d", amount);
    if ( isHeal ) then
        targetLine.text:SetText("+" .. numStr);
        targetLine.text:SetTextColor(SPELL_COLORS.heal[1], SPELL_COLORS.heal[2], SPELL_COLORS.heal[3]);
    elseif ( isCrit ) then
        targetLine.text:SetText("♦ " .. numStr .. " ♦");
        targetLine.text:SetTextColor(SPELL_COLORS.crit[1], SPELL_COLORS.crit[2], SPELL_COLORS.crit[3]);
    else
        local col = DetectSchoolColor(spellName, false);
        targetLine.text:SetText(numStr);
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
    end
    
    targetLine:SetScale(scale);
    targetLine:SetAlpha(1.0);
    targetLine:Show();
    
    -- In Side Stack mode, push older active lines up
    if ( s.style == "side" ) then
        local stackIndex = 0;
        for i = 1, SCT.maxLines do
            local l = SCT.lines[i];
            if ( l.active and l.isIncoming == isIncoming ) then
                l.stackIndex = stackIndex;
                stackIndex = stackIndex + 1;
            end
        end
    end
end

-- SCT Animation Ticker (Smooth 60FPS positioning & fading)
local sctTicker = CreateFrame("Frame", "BordoUI_SCT_Ticker");
sctTicker:SetScript("OnUpdate", function()
    local dt = arg1 or 0.03;
    local s = BordoUI:GetDamageSettings();
    local maxDuration = 2.4;
    
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( l.active ) then
            l.age = l.age + dt;
            if ( l.age >= maxDuration ) then
                l.active = false;
                l:Hide();
            else
                local progress = l.age / maxDuration;
                -- Smooth fade out in final 35% of duration
                if ( progress > 0.65 ) then
                    l:SetAlpha((1.0 - progress) / 0.35);
                else
                    l:SetAlpha(1.0);
                end
                
                local anchor = l.parentAnchor or outgoingAnchor;
                local aPt, aRel, aRelPt, aX, aY = anchor:GetPoint();
                
                if ( s.style == "side" ) then
                    -- Side Stack Style: Neat vertical stack beside the player (MSBT style)
                    local yOffset = (l.stackIndex or 0) * (20 * (tonumber(s.scale) or 0.85));
                    l:ClearAllPoints();
                    l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, yOffset);
                elseif ( s.style == "arc" ) then
                    -- Parabolic Arc Style: Numbers leap outward and fall in a curve
                    local dir = l.isIncoming and -1 or 1;
                    local arcX = dir * (progress * 65);
                    local arcY = math.sin(progress * math.pi) * 45 - (progress * 15);
                    l:ClearAllPoints();
                    l:SetPoint("CENTER", anchor, "CENTER", arcX, arcY);
                else
                    -- Scroll Up Style: Numbers float straight up
                    local upY = progress * 75;
                    l:ClearAllPoints();
                    l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, upY);
                end
            end
        end
    end
end);

-------------------------------------------------------------------------------
-- COMBAT LOG EVENT WATCHER (Parses real gameplay hits)
-------------------------------------------------------------------------------
local logWatcher = CreateFrame("Frame", "BordoUI_SCT_CombatLogWatcher");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");

logWatcher:SetScript("OnEvent", function()
    local msg = arg1;
    if ( not msg ) then return; end
    local s = BordoUI:GetDamageSettings();
    if ( s.filter == "off" ) then return; end
    
    local isPeriodic = (event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
    if ( isPeriodic and s.filter == "nodots" ) then
        return; -- Suppress DoT-spam
    end
    
    local lower = string.lower(msg);
    local isCrit = (string.find(lower, "crit") ~= nil) or (string.find(lower, "krit") ~= nil);
    if ( s.filter == "crits" and not isCrit ) then
        return; -- Suppress non-crits
    end
    
    -- Extract Amount
    local numStr = nil;
    local _, _, n1 = string.find(msg, "for (%d+)");
    if ( n1 ) then numStr = n1; end
    if ( not numStr ) then
        local _, _, n2 = string.find(msg, "f%A+r (%d+)");
        if ( n2 ) then numStr = n2; end
    end
    if ( not numStr ) then
        local gFunc = string.gfind or string.gmatch;
        if ( gFunc ) then
            for w in gFunc(msg, "(%d+)") do numStr = w; end
        end
    end
    local amount = tonumber(numStr or 0);
    if ( not amount or amount <= 0 ) then return; end
    
    -- Extract Spell Name
    local spell = nil;
    local _, _, s1 = string.find(msg, "^Euer (.+) trifft");
    if ( s1 ) then spell = s1; end
    if ( not spell ) then
        local _, _, s2 = string.find(msg, "^Your (.+) crits");
        if ( s2 ) then spell = s2; end
    end
    if ( not spell ) then
        local _, _, s3 = string.find(msg, "^Your (.+) hits");
        if ( s3 ) then spell = s3; end
    end
    if ( not spell ) then
        local _, _, s4 = string.find(msg, "^Your (.+) ticks");
        if ( s4 ) then spell = s4; end
    end
    if ( not spell ) then
        spell = (event == "CHAT_MSG_COMBAT_SELF_HITS") and "Melee" or "Attack";
    end
    
    local isIncoming = (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");
    local isHeal = (event == "CHAT_MSG_SPELL_SELF_BUFF" and (string.find(lower, "heal") or string.find(lower, "heilt")));
    
    BordoUI:AddCombatNumber(spell, amount, isCrit, isIncoming, isHeal);
end);

-------------------------------------------------------------------------------
-- APPLY DAMAGE & FONT SETTINGS
-------------------------------------------------------------------------------
function BordoUI:ApplyDamageSettings()
    local s = self:GetDamageSettings();
    local fontDef = FONTS[s.font] or FONTS.modern;
    local fontPath = fontDef.path;
    local scale = tonumber(s.scale) or 0.85;
    
    -- 1. In-World 3D Numbers Toggle:
    -- If inWorld is false: point DAMAGE_TEXT_FONT to blank.ttf (transparent font) to hide numbers over ads!
    -- If inWorld is true: point DAMAGE_TEXT_FONT to the chosen font.
    if ( s.inWorld == false ) then
        DAMAGE_TEXT_FONT = "Interface\\AddOns\\BordoUI\\Media\\blank.ttf";
    else
        DAMAGE_TEXT_FONT = fontPath;
    end
    
    -- 2. Blizzard CombatText Scaling & Font
    if ( CombatTextFont ) then
        local fontSize = math.max(12, math.floor(18 * (scale / 0.75)));
        CombatTextFont:SetFont(fontPath, fontSize, "OUTLINE");
    end
    if ( CombatText ) then
        CombatText:SetScale(scale);
    end
    
    -- 3. Restore Anchors Position
    if ( BordoUIDB and BordoUIDB.sctOutgoingPos ) then
        local pos = BordoUIDB.sctOutgoingPos;
        outgoingAnchor:ClearAllPoints();
        outgoingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 140, pos.y or 30);
    end
    if ( BordoUIDB and BordoUIDB.sctIncomingPos ) then
        local pos = BordoUIDB.sctIncomingPos;
        incomingAnchor:ClearAllPoints();
        incomingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or -140, pos.y or 30);
    end
    
    self:UpdateSCTAnchorVisibility();
end

-- Backward compatibility alias
function AZSHelper:ApplyModernDamageText()
    BordoUI:ApplyDamageSettings();
end
function BordoUI:ApplyModernDamageText()
    BordoUI:ApplyDamageSettings();
end

-- Simulated Test Damage Numbers (Matching user screenshot)
function BordoUI:TestDamageNumbers()
    self:ApplyDamageSettings();
    
    -- Feed 4 sample lines matching the user's screenshot
    self:AddCombatNumber("Frostbolt", 777, false, false, false);
    self:AddCombatNumber("Frostbolt", 694, false, false, false);
    self:AddCombatNumber("Mace Attack", 698, false, false, false);
    self:AddCombatNumber("Holy Shield", 14636, true, false, false); -- Crit!
    self:AddCombatNumber("Shadow Bolt", 7349, true, false, false); -- Crit!
    
    pcall(PlaySound, "igSpellCastStarted");
end

-- Quick Cycle Filter (Minimap Right-Click)
function BordoUI:CycleDamageFilter()
    local s = self:GetDamageSettings();
    local nextFilter = "all";
    if ( s.filter == "all" ) then
        nextFilter = "nodots";
    elseif ( s.filter == "nodots" ) then
        nextFilter = "crits";
    elseif ( s.filter == "crits" ) then
        nextFilter = "off";
    else
        nextFilter = "all";
    end
    s.filter = nextFilter;
    self:ApplyDamageSettings();
    if ( self.UpdateDamageWindowUI ) then self:UpdateDamageWindowUI(); end
    
    local names = {
        all = "|cff55ff55All Numbers|r (Full combat log)",
        nodots = "|cff00ccffNo DoT-Spam|r (Direct hits & crits only)",
        crits = "|cffffd100Only Crits|r (Critical strikes only)",
        off = "|cffff4444Disabled|r (Hidden)",
    };
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Combat Numbers Filter: " .. (names[nextFilter] or nextFilter));
end

-- Quick Toggle Motion (Minimap Shift-Click)
function BordoUI:ToggleDamageMotion()
    local s = self:GetDamageSettings();
    if ( s.style == "side" ) then
        s.style = "arc";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Combat Numbers Style: |cffffd100WoW Classic Arc|r");
    elseif ( s.style == "arc" ) then
        s.style = "up";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Combat Numbers Style: |cff00ccffScroll Up|r");
    else
        s.style = "side";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Combat Numbers Style: |cff55ff55Side Stacked (MSBT)|r");
    end
    self:ApplyDamageSettings();
    if ( self.UpdateDamageWindowUI ) then self:UpdateDamageWindowUI(); end
end

-- Set Scale directly
function BordoUI:SetDamageScale(scale)
    local s = self:GetDamageSettings();
    s.scale = math.min(1.5, math.max(0.4, tonumber(scale) or 0.85));
    self:ApplyDamageSettings();
    if ( self.UpdateDamageWindowUI ) then self:UpdateDamageWindowUI(); end
end

-------------------------------------------------------------------------------
-- SETTINGS GUI WINDOW (All English UI)
-------------------------------------------------------------------------------
local dmgFrame = nil;
local optionButtons = {};

local function CreateOptionButton(parent, group, val, text, tooltipTitle, tooltipDesc, width, height, x, y, onClick)
    local btn = CreateFrame("Button", nil, parent);
    btn:SetWidth(width);
    btn:SetHeight(height);
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    
    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
    btn:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95);
    
    local label = btn:CreateFontString(nil, "OVERLAY");
    label:SetFont(FONT_PATH, 9, "OUTLINE");
    label:SetPoint("CENTER", btn, "CENTER", 0, 0);
    label:SetTextColor(0.75, 0.75, 0.75);
    label:SetText(text);
    btn.label = label;
    
    btn.group = group;
    btn.val = val;
    
    btn:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn");
        onClick(val);
    end);
    
    btn:SetScript("OnEnter", function()
        btn:SetBackdropBorderColor(0.00, 0.80, 1.00, 1.0);
        if ( tooltipTitle and tooltipDesc ) then
            GameTooltip:SetOwner(btn, "ANCHOR_TOP");
            GameTooltip:ClearLines();
            GameTooltip:AddLine(tooltipTitle, 1, 0.82, 0);
            GameTooltip:AddLine(tooltipDesc, 0.85, 0.85, 0.85, 1);
            GameTooltip:Show();
        end
    end);
    
    btn:SetScript("OnLeave", function()
        if ( GameTooltip ) then GameTooltip:Hide(); end
        BordoUI:UpdateDamageWindowUI();
    end);
    
    table.insert(optionButtons, btn);
    return btn;
end

function BordoUI:CreateDamageNumbersWindow()
    if ( dmgFrame ) then return dmgFrame; end
    
    dmgFrame = CreateFrame("Frame", "BordoUI_DamageNumbersFrame", UIParent);
    dmgFrame:SetWidth(340);
    dmgFrame:SetHeight(410);
    dmgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
    dmgFrame:SetFrameStrata("HIGH");
    dmgFrame:SetFrameLevel(22);
    dmgFrame:SetClampedToScreen(true);
    dmgFrame:SetMovable(true);
    dmgFrame:EnableMouse(true);
    dmgFrame:RegisterForDrag("LeftButton");
    
    dmgFrame:SetScript("OnDragStart", function()
        if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
            dmgFrame:StartMoving();
        end
    end);
    dmgFrame:SetScript("OnDragStop", function()
        dmgFrame:StopMovingOrSizing();
        local pt, _, relPt, x, y = dmgFrame:GetPoint();
        BordoUIDB = BordoUIDB or {};
        BordoUIDB.damageFramePos = { point = pt, relativePoint = relPt, x = x, y = y };
    end);
    
    dmgFrame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    dmgFrame:SetBackdropColor(0.04, 0.04, 0.07, 0.96);
    dmgFrame:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.95);
    dmgFrame:Hide();
    
    -- Title & Subtitle (English)
    local title = dmgFrame:CreateFontString(nil, "OVERLAY");
    title:SetFont(FONT_PATH, 11, "OUTLINE");
    title:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, -8);
    title:SetText("|cff00ccffBordo UI|r |cffffd100Damage Numbers & Combat Text|r");
    
    local subtitle = dmgFrame:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont(FONT_PATH, 8, "OUTLINE");
    subtitle:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, -22);
    subtitle:SetTextColor(0.65, 0.65, 0.65);
    subtitle:SetText("Configure animation style, filters, font, size, and in-world visibility.");
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, dmgFrame);
    closeBtn:SetWidth(18);
    closeBtn:SetHeight(18);
    closeBtn:SetPoint("TOPRIGHT", dmgFrame, "TOPRIGHT", -5, -5);
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
    closeTxt:SetFont(FONT_PATH, 11, "OUTLINE");
    closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
    closeTxt:SetText("✕");
    closeTxt:SetTextColor(0.7, 0.7, 0.7);
    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.2, 0.2); end);
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.7, 0.7, 0.7); end);
    closeBtn:SetScript("OnClick", function() dmgFrame:Hide(); PlaySound("igMainMenuClose"); end);
    
    if ( BordoUI and BordoUI.AttachLockButton ) then
        BordoUI:AttachLockButton(dmgFrame, "TOPRIGHT", dmgFrame, "TOPRIGHT", -26, -5);
    end
    
    local curY = -42;
    local function AddHeader(text)
        local h = dmgFrame:CreateFontString(nil, "OVERLAY");
        h:SetFont(FONT_PATH, 9, "OUTLINE");
        h:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, curY);
        h:SetTextColor(1, 0.82, 0.20);
        h:SetText(text);
        curY = curY - 16;
    end
    
    -- 1. Animation & Display Style
    AddHeader("1. Display Style & Animation:");
    local styles = {
        { id = "side", label = "Side Stack", desc = "Stacked beside character with spell icons and x2/x3 counters (MSBT Style)." },
        { id = "arc",  label = "WoW Arc",    desc = "Classic WoW outward parabolic bouncing arc." },
        { id = "up",   label = "Scroll Up",  desc = "Smooth vertical scrolling float upwards." },
    };
    local sW = 101;
    for i = 1, table.getn(styles) do
        local st = styles[i];
        CreateOptionButton(dmgFrame, "style", st.id, st.label, st.label, st.desc, sW, 20, 10 + (i - 1) * (sW + 6), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.style = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 27;
    
    -- 2. Damage Filter
    AddHeader("2. Damage Filter (Spam Reduction):");
    local filters = {
        { id = "all",    label = "All Damage",  desc = "Show all direct hits, periodic DoT ticks, and crits." },
        { id = "nodots", label = "No DoT-Spam", desc = "Hide thousands of periodic DoT ticks; show only direct hits & crits!" },
        { id = "crits",  label = "Only Crits",  desc = "Exclusively display big critical strikes (cleanest screen)." },
        { id = "off",    label = "Disabled",    desc = "Completely disable scrolling damage numbers." },
    };
    local fW = 75;
    for i = 1, table.getn(filters) do
        local f = filters[i];
        CreateOptionButton(dmgFrame, "filter", f.id, f.label, f.label, f.desc, fW, 20, 10 + (i - 1) * (fW + 6), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.filter = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 27;
    
    -- 3. In-World 3D Numbers Toggle
    AddHeader("3. In-World Numbers (Floating Over Ads):");
    local inWorldOptions = {
        { val = false, label = "Hide Over Ads (Clean)", desc = "Hides 3D damage floating over enemy mobs so your screen stays uncluttered!" },
        { val = true,  label = "Show Over Ads",         desc = "Renders standard 3D numbers floating over enemy mobs in the 3D world." },
    };
    local iwW = 156;
    for i = 1, table.getn(inWorldOptions) do
        local opt = inWorldOptions[i];
        CreateOptionButton(dmgFrame, "inWorld", opt.val, opt.label, opt.label, opt.desc, iwW, 20, 10 + (i - 1) * (iwW + 8), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.inWorld = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 27;
    
    -- 4. Font Selection
    AddHeader("4. Font Style:");
    local fontList = {
        { id = "modern",  label = "Modern",  desc = "Crisp, clean sans-serif typeface." },
        { id = "classic", label = "Classic", desc = "Nostalgic World of Warcraft Friz Quadrata." },
        { id = "arcade",  label = "Arcade",  desc = "Compact, legible Arial Narrow." },
        { id = "russo",   label = "Russo",   desc = "Heavy, punchy action comic block font." },
        { id = "exo",     label = "Exo",     desc = "Futuristic, elegant sci-fi font." },
    };
    local ftW = 60;
    for i = 1, table.getn(fontList) do
        local ft = fontList[i];
        CreateOptionButton(dmgFrame, "font", ft.id, ft.label, ft.label, ft.desc, ftW, 20, 10 + (i - 1) * (ftW + 5), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.font = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 27;
    
    -- 5. Size Scaling
    AddHeader("5. Size & Scale:");
    local scales = {
        { val = 0.50, label = "50% Tiny",    desc = "Small, minimal numbers." },
        { val = 0.70, label = "70% Compact", desc = "Compact size, ideal for large monster packs." },
        { val = 0.85, label = "85% Normal",  desc = "Balanced BordoUI standard size." },
        { val = 1.00, label = "100% Large",  desc = "Standard Blizzard 100% scale." },
        { val = 1.25, label = "125% Huge",   desc = "Extra large high-visibility numbers." },
    };
    for i = 1, table.getn(scales) do
        local sc = scales[i];
        CreateOptionButton(dmgFrame, "scale", sc.val, sc.label, sc.label, sc.desc, ftW, 20, 10 + (i - 1) * (ftW + 5), curY, function(val)
            BordoUI:SetDamageScale(val);
        end);
    end
    curY = curY - 33;
    
    -- 6. Simulate Test Button
    local testBtn = CreateFrame("Button", nil, dmgFrame);
    testBtn:SetWidth(320);
    testBtn:SetHeight(24);
    testBtn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, curY);
    testBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    testBtn:SetBackdropColor(0.10, 0.12, 0.18, 0.95);
    testBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
    
    local testTxt = testBtn:CreateFontString(nil, "OVERLAY");
    testTxt:SetFont(FONT_PATH, 10, "OUTLINE");
    testTxt:SetPoint("CENTER", testBtn, "CENTER", 0, 0);
    testTxt:SetText("▶  Simulate Test Combat Text (Hits, Heal & Crits)");
    testTxt:SetTextColor(0.00, 0.90, 1.00);
    
    testBtn:SetScript("OnEnter", function()
        testBtn:SetBackdropBorderColor(1.0, 0.82, 0.20, 1.0);
        testTxt:SetTextColor(1.0, 0.82, 0.20);
    end);
    testBtn:SetScript("OnLeave", function()
        testBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
        testTxt:SetTextColor(0.00, 0.90, 1.00);
    end);
    testBtn:SetScript("OnClick", function()
        BordoUI:TestDamageNumbers();
    end);
    
    -- Bottom Status line
    curY = curY - 28;
    local statusText = dmgFrame:CreateFontString(nil, "OVERLAY");
    statusText:SetFont(FONT_PATH, 8, "OUTLINE");
    statusText:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, curY);
    statusText:SetTextColor(0.60, 0.85, 0.60);
    dmgFrame.statusText = statusText;
    
    BordoUI:UpdateDamageWindowUI();
    return dmgFrame;
end

-- Refresh Active Highlight on Buttons
function BordoUI:UpdateDamageWindowUI()
    if ( not dmgFrame ) then return; end
    local s = self:GetDamageSettings();
    
    for i = 1, table.getn(optionButtons) do
        local btn = optionButtons[i];
        local isSelected = false;
        if ( btn.group == "scale" ) then
            isSelected = (math.abs((tonumber(s.scale) or 0.85) - tonumber(btn.val)) < 0.04);
        elseif ( btn.group == "inWorld" ) then
            isSelected = (s.inWorld == btn.val);
        else
            isSelected = (s[btn.group] == btn.val);
        end
        
        if ( isSelected ) then
            btn:SetBackdropBorderColor(1.00, 0.82, 0.20, 1.0);
            btn:SetBackdropColor(0.18, 0.15, 0.05, 0.95);
            btn.label:SetTextColor(1.00, 0.85, 0.25);
        else
            btn:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95);
            btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
            btn.label:SetTextColor(0.65, 0.65, 0.65);
        end
    end
    
    if ( dmgFrame.statusText ) then
        local styleNames  = { side = "Side Stack", arc = "WoW Arc", up = "Scroll Up" };
        local filterNames = { all = "All Damage", nodots = "No DoT-Spam", crits = "Only Crits", off = "Disabled" };
        local inWorldName = s.inWorld and "Over Ads: On" or "Over Ads: Hidden";
        local fontNames   = { modern = "Modern", classic = "Classic", arcade = "Arcade", russo = "Russo", exo = "Exo" };
        local scPct = math.floor((s.scale or 0.85) * 100 + 0.5);
        
        dmgFrame.statusText:SetText(string.format("Active: |cffffd100%s|r | |cff00ccff%s|r | |cff55ff55%s|r | |cffaaaaaa%s|r | |cffffffff%d%%|r",
            styleNames[s.style] or s.style,
            filterNames[s.filter] or s.filter,
            inWorldName,
            fontNames[s.font] or s.font,
            scPct
        ));
    end
end

-- Toggle Window Visibility
function BordoUI:ToggleDamageNumbersWindow()
    local win = dmgFrame or self:CreateDamageNumbersWindow();
    if ( win:IsShown() ) then
        win:Hide();
        PlaySound("igMainMenuClose");
    else
        -- Restore position if available
        if ( BordoUIDB and BordoUIDB.damageFramePos ) then
            local pos = BordoUIDB.damageFramePos;
            win:ClearAllPoints();
            win:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 20);
        end
        self:UpdateDamageWindowUI();
        win:Show();
        PlaySound("igMainMenuOpen");
    end
end

-- Immediate Initialization on load
BordoUI:ApplyDamageSettings();

-- World entry listener
local fontListener = CreateFrame("Frame", "BordoUI_DamageFontListener");
fontListener:RegisterEvent("PLAYER_ENTERING_WORLD");
fontListener:RegisterEvent("VARIABLES_LOADED");
fontListener:SetScript("OnEvent", function()
    BordoUI:ApplyDamageSettings();
end);
