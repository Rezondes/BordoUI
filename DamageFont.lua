--[[
    Bordo UI - Scrolling Combat Text & Damage Numbers (DamageFont.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Inspired by MikScrollingBattleText (MSBT) & xCT+:
    - Mode 1: Scrolling Combat Text (SCT) beside character (keeps mobs uncluttered)
    - Mode 2: Classic In-World 3D Numbers (floating over ads)
    
    Three SCT Variants:
    - 1. MSBT Style: Numbers + Spell Icon + Multi-hit badge (x2, x3, x4)
    - 2. xCT+ Compact: Spell Name + Icon + Total Damage x[Targets Hit] (e.g. Magma Totem x5)
    - 3. Clean Numbers: Pure floating numbers & golden crits
    
    Features:
    - Redesigned modern clickable overlay UI
    - Live In-Window Interactive Preview Box
    - Test simulation button
    - 100% English interface
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
    if ( not BordoUIDB.damageSettings or type(BordoUIDB.damageSettings) ~= "table" ) then
        BordoUIDB.damageSettings = {};
    end
    local s = BordoUIDB.damageSettings;
    
    -- Ensure non-nil and valid values for every setting
    if ( s.mode ~= "scrolling" and s.mode ~= "inworld" ) then
        s.mode = (s.inWorld == true) and "inworld" or "scrolling";
    end
    if ( s.variant ~= "msbt" and s.variant ~= "xct" and s.variant ~= "clean" ) then
        s.variant = "msbt";
    end
    if ( s.filter ~= "all" and s.filter ~= "nodots" and s.filter ~= "crits" and s.filter ~= "off" ) then
        s.filter = "nodots";
    end
    if ( s.font ~= "modern" and s.font ~= "classic" and s.font ~= "arcade" and s.font ~= "russo" and s.font ~= "exo" ) then
        s.font = "modern";
    end
    if ( not s.scale or type(s.scale) ~= "number" or s.scale <= 0 ) then
        s.scale = tonumber(BordoUIDB.dmgScale) or 0.85;
    end
    if ( s.icons == nil ) then s.icons = true; end
    if ( s.stacking == nil ) then s.stacking = true; end
    
    return s;
end

-- School / Spell Color Palette
local SPELL_COLORS = {
    physical = { 1.00, 1.00, 1.00 }, -- White
    holy     = { 1.00, 0.90, 0.50 }, -- Pale Gold
    fire     = { 1.00, 0.45, 0.10 }, -- Orange
    nature   = { 0.30, 0.90, 0.30 }, -- Green
    frost    = { 0.40, 0.80, 1.00 }, -- Sky Blue
    shadow   = { 0.75, 0.45, 1.00 }, -- Deep Violet
    arcane   = { 1.00, 0.50, 1.00 }, -- Magenta
    heal     = { 0.20, 1.00, 0.30 }, -- Healing Green
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
};
BordoUI.SCT = SCT;

-- Anchor Frames (Positioned left and right of player character)
local outgoingAnchor = CreateFrame("Frame", "BordoUI_SCT_OutgoingAnchor", UIParent);
outgoingAnchor:SetWidth(140);
outgoingAnchor:SetHeight(30);
outgoingAnchor:SetPoint("CENTER", UIParent, "CENTER", 145, 20);
outgoingAnchor:SetMovable(true);
outgoingAnchor:EnableMouse(true);
outgoingAnchor:RegisterForDrag("LeftButton");

local incomingAnchor = CreateFrame("Frame", "BordoUI_SCT_IncomingAnchor", UIParent);
incomingAnchor:SetWidth(140);
incomingAnchor:SetHeight(30);
incomingAnchor:SetPoint("CENTER", UIParent, "CENTER", -145, 20);
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
    lbl:SetTextColor(0.4, 0.8, 1.0, 0.6);
    lbl:Hide();
    anchor.label = lbl;
end

SetupAnchorDrag(outgoingAnchor, "sctOutgoingPos", "Outgoing Combat Text");
SetupAnchorDrag(incomingAnchor, "sctIncomingPos", "Incoming Damage & Heals");

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

-- Line Pool Constructor
local function CreateSCTLine(id)
    local line = CreateFrame("Frame", "BordoUI_SCT_Line_" .. id, UIParent);
    line:SetWidth(240);
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
    iconFrame:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);
    
    local icon = iconFrame:CreateTexture(nil, "ARTWORK");
    icon:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 1, -1);
    icon:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1, 1);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    line.icon = icon;
    line.iconFrame = iconFrame;
    
    -- Spell Name Label (used for xCT+ compact style)
    local nameText = line:CreateFontString(nil, "OVERLAY");
    nameText:SetFont(FONT_PATH, 11, "OUTLINE");
    nameText:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0);
    nameText:SetTextColor(0.85, 0.85, 0.85);
    nameText:Hide();
    line.nameText = nameText;
    
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
    if ( s.mode == "inworld" ) then return; end -- SCT disabled when in Classic 3D mode
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
    
    -- Check for Hit Stacking (if same spell hit within 0.45s, increment count: x2, x3, x5!)
    if ( s.stacking ) then
        for i = 1, SCT.maxLines do
            local l = SCT.lines[i];
            if ( l.active and l.spellName == spellName and (now - l.spawnTime) < 0.45 ) then
                l.count = l.count + 1;
                l.amount = l.amount + amount;
                l.age = 0.1; -- Reset fade timer
                
                local numText = string.format("%d", l.amount);
                if ( l.isCrit or isCrit ) then
                    l.isCrit = true;
                    l.text:SetText(string.format("* %s *", numText));
                    l.text:SetTextColor(SPELL_COLORS.crit[1], SPELL_COLORS.crit[2], SPELL_COLORS.crit[3]);
                else
                    l.text:SetText(numText);
                end
                
                -- Update Badge for Variant
                if ( s.variant == "xct" ) then
                    l.badge:SetText(string.format("x%d", l.count));
                    l.badge:Show();
                elseif ( s.variant == "msbt" ) then
                    l.badge:SetText(string.format("x%d", l.count));
                    l.badge:Show();
                end
                return;
            end
        end
    end
    
    -- Find an available line from pool
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
    
    local fontSize = isCrit and math.floor(18 * (scale / 0.75)) or math.floor(14 * (scale / 0.75));
    targetLine.text:SetFont(fontPath, fontSize, "OUTLINE");
    targetLine.nameText:SetFont(fontPath, math.max(10, fontSize - 3), "OUTLINE");
    targetLine.badge:SetFont(fontPath, math.max(10, fontSize - 3), "OUTLINE");
    targetLine.badge:Hide();
    
    local numStr = string.format("%d", amount);
    local col = isCrit and SPELL_COLORS.crit or (isHeal and SPELL_COLORS.heal or DetectSchoolColor(spellName, false));
    
    -- Layout per Variant
    if ( s.variant == "xct" ) then
        -- Variant 2: xCT+ Compact Named (e.g. [Icon] Magma Totem: 1,450 x5)
        targetLine.icon:SetTexture(iconPath);
        targetLine.iconFrame:Show();
        targetLine.nameText:SetText(spellName .. ":");
        targetLine.nameText:Show();
        targetLine.nameText:ClearAllPoints();
        targetLine.nameText:SetPoint("LEFT", targetLine.iconFrame, "RIGHT", 4, 0);
        
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine.nameText, "RIGHT", 4, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
        targetLine.badge:ClearAllPoints();
        targetLine.badge:SetPoint("LEFT", targetLine.text, "RIGHT", 3, -1);
        
    elseif ( s.variant == "clean" ) then
        -- Variant 3: Clean Numbers (Pure minimal numbers & crits)
        targetLine.iconFrame:Hide();
        targetLine.nameText:Hide();
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine, "LEFT", 0, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " CRIT *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
    else
        -- Variant 1: MSBT Icon Style (e.g. [Icon] 7,178 x4)
        targetLine.icon:SetTexture(iconPath);
        targetLine.iconFrame:Show();
        targetLine.nameText:Hide();
        
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine.iconFrame, "RIGHT", 4, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
        targetLine.badge:ClearAllPoints();
        targetLine.badge:SetPoint("LEFT", targetLine.text, "RIGHT", 3, -1);
    end
    
    targetLine:SetScale(scale);
    targetLine:SetAlpha(1.0);
    targetLine:Show();
    
    -- Stack calculation
    local stackIndex = 0;
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( l.active and l.isIncoming == isIncoming ) then
            l.stackIndex = stackIndex;
            stackIndex = stackIndex + 1;
        end
    end
end

-- SCT Animation Ticker (Smooth 60FPS positioning & fading)
local sctTicker = CreateFrame("Frame", "BordoUI_SCT_Ticker");
sctTicker:SetScript("OnUpdate", function()
    local dt = arg1 or 0.03;
    local s = BordoUI:GetDamageSettings();
    if ( s.mode == "inworld" ) then return; end
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
                if ( progress > 0.65 ) then
                    l:SetAlpha((1.0 - progress) / 0.35);
                else
                    l:SetAlpha(1.0);
                end
                
                local anchor = l.parentAnchor or outgoingAnchor;
                local yOffset = (l.stackIndex or 0) * (20 * (tonumber(s.scale) or 0.85));
                l:ClearAllPoints();
                l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, yOffset);
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
    if ( s.mode == "inworld" ) then return; end
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
    
    -- In-World 3D Mode vs SCT Mode:
    -- If mode == "scrolling": Hide 3D numbers over ads using transparent blank.ttf
    -- If mode == "inworld": Render 3D numbers over ads in chosen font!
    if ( s.mode == "scrolling" ) then
        DAMAGE_TEXT_FONT = "Interface\\AddOns\\BordoUI\\Media\\blank.ttf";
    else
        DAMAGE_TEXT_FONT = fontPath;
        -- Hide any active SCT lines
        for i = 1, SCT.maxLines do
            if ( SCT.lines[i] ) then SCT.lines[i]:Hide(); end
        end
    end
    
    -- Blizzard CombatText Font & Scale
    if ( CombatTextFont ) then
        local fontSize = math.max(12, math.floor(18 * (scale / 0.75)));
        CombatTextFont:SetFont(fontPath, fontSize, "OUTLINE");
    end
    if ( CombatText ) then
        CombatText:SetScale(scale);
    end
    
    -- Restore Anchors Position
    if ( BordoUIDB and BordoUIDB.sctOutgoingPos ) then
        local pos = BordoUIDB.sctOutgoingPos;
        outgoingAnchor:ClearAllPoints();
        outgoingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 145, pos.y or 20);
    end
    if ( BordoUIDB and BordoUIDB.sctIncomingPos ) then
        local pos = BordoUIDB.sctIncomingPos;
        incomingAnchor:ClearAllPoints();
        incomingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or -145, pos.y or 20);
    end
    
    self:UpdateSCTAnchorVisibility();
    if ( self.UpdateDamageWindowUI ) then
        self:UpdateDamageWindowUI();
    end
end

-- Backward compatibility aliases
function AZSHelper:ApplyModernDamageText() BordoUI:ApplyDamageSettings(); end
function BordoUI:ApplyModernDamageText() BordoUI:ApplyDamageSettings(); end

-- Live Test Simulation
function BordoUI:TestDamageNumbers()
    self:ApplyDamageSettings();
    local s = self:GetDamageSettings();
    
    if ( s.mode == "inworld" ) then
        if ( CombatText_AddMessage and CombatText_StandardScroll ) then
            CombatText_AddMessage("777", CombatText_StandardScroll, 0.4, 0.8, 1.0);
            CombatText_AddMessage("+850", CombatText_StandardScroll, 0.2, 1.0, 0.2);
            CombatText_AddMessage("* 14,636 CRIT! *", CombatText_StandardScroll, 1.0, 0.82, 0.0, "crit");
        end
        pcall(PlaySound, "igSpellCastStarted");
        return;
    end
    
    -- Feed sample lines matching the user's reference
    self:AddCombatNumber("Frostbolt", 777, false, false, false);
    self:AddCombatNumber("Frostbolt", 694, false, false, false);
    if ( s.variant == "xct" ) then
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false); -- Will show Magma Totem: 7,250 x5!
    end
    self:AddCombatNumber("Holy Shield", 14636, true, false, false); -- Big Crit!
    self:AddCombatNumber("Shadow Bolt", 7349, true, false, false);  -- Big Crit!
    
    pcall(PlaySound, "igSpellCastStarted");
end

-- Quick Cycle Filter (Minimap Right-Click)
function BordoUI:CycleDamageFilter()
    local s = self:GetDamageSettings();
    local nextFilter = (s.filter == "all") and "nodots" or ((s.filter == "nodots") and "crits" or ((s.filter == "crits") and "off" or "all"));
    s.filter = nextFilter;
    self:ApplyDamageSettings();
    
    local names = {
        all    = "|cff55ff55All Numbers|r",
        nodots = "|cff00ccffNo DoT-Spam|r",
        crits  = "|cffffd100Only Crits|r",
        off    = "|cffff4444Disabled|r",
    };
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Combat Text Filter: " .. (names[nextFilter] or nextFilter));
end

-- Quick Toggle Mode (Minimap Shift-Click)
function BordoUI:ToggleDamageMotion()
    local s = self:GetDamageSettings();
    if ( s.mode == "scrolling" ) then
        s.mode = "inworld";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Mode: |cffffd100Classic In-World 3D (Over Ads)|r");
    else
        s.mode = "scrolling";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Mode: |cff00ccffScrolling Combat Text (Beside Character)|r");
    end
    self:ApplyDamageSettings();
end

-- Set Scale directly
function BordoUI:SetDamageScale(scale)
    local s = self:GetDamageSettings();
    local num = tonumber(scale) or 0.85;
    s.scale = math.min(1.5, math.max(0.4, num));
    if ( BordoUIDB ) then
        BordoUIDB.dmgScale = s.scale;
    end
    self:ApplyDamageSettings();
    self:UpdateDamageWindowUI();
end

-------------------------------------------------------------------------------
-- REDESIGNED MODERN OVERLAY SETTINGS WINDOW (All English)
-------------------------------------------------------------------------------
local dmgFrame = nil;
local optionButtons = {};
local previewWidgets = {};

local function CreatePillButton(parent, group, val, text, tooltipTitle, tooltipDesc, width, height, x, y, onClick)
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
    dmgFrame:SetWidth(380);
    dmgFrame:SetHeight(470);
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
    
    -- Window Title & Subtitle (English)
    local title = dmgFrame:CreateFontString(nil, "OVERLAY");
    title:SetFont(FONT_PATH, 12, "OUTLINE");
    title:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -8);
    title:SetText("|cff00ccffBordo UI|r |cffffd100Combat Text Settings|r");
    
    local subtitle = dmgFrame:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont(FONT_PATH, 8, "OUTLINE");
    subtitle:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -23);
    subtitle:SetTextColor(0.65, 0.65, 0.65);
    subtitle:SetText("Choose between Scrolling Combat Text (MSBT/xCT+) and Classic 3D numbers.");
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, dmgFrame);
    closeBtn:SetWidth(18);
    closeBtn:SetHeight(18);
    closeBtn:SetPoint("TOPRIGHT", dmgFrame, "TOPRIGHT", -6, -6);
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
    closeTxt:SetFont(FONT_PATH, 11, "OUTLINE");
    closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
    closeTxt:SetText("X");
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
        h:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, curY);
        h:SetTextColor(1, 0.82, 0.20);
        h:SetText(text);
        curY = curY - 15;
    end
    
    -- 1. PRIMARY COMBAT TEXT MODE (Large Prominent Toggle Cards)
    AddHeader("1. COMBAT TEXT SYSTEM:");
    local modeOptions = {
        { id = "scrolling", label = "SCT (Beside Character)", desc = "Numbers scroll beside your character (MSBT/xCT+ style). Hides cluttered numbers over enemy ads!" },
        { id = "inworld",   label = "Classic 3D (Over Ads)",          desc = "Standard classic WoW floating combat numbers over enemy heads in 3D world." },
    };
    local mW = 174;
    for i = 1, table.getn(modeOptions) do
        local m = modeOptions[i];
        CreatePillButton(dmgFrame, "mode", m.id, m.label, m.label, m.desc, mW, 24, 12 + (i - 1) * (mW + 8), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.mode = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 32;
    
    -- 2. SCT DISPLAY VARIANTS (Only used in Scrolling mode)
    AddHeader("2. SCROLLING TEXT VARIANT (SCT STYLES):");
    local variants = {
        { id = "msbt",  label = "MSBT (Icon + Hits)", desc = "Number + Spell Icon + Multi-hit badge (e.g. 7,178 [Icon] x4). Exact match for reference image!" },
        { id = "xct",   label = "xCT+ (Name + Total)", desc = "Spell Name + Icon + Total Damage x[Targets Hit] (e.g. Magma Totem x5). Ultra-compact for mass AoE!" },
        { id = "clean", label = "Clean (Pure Numbers)", desc = "Pure floating numbers & golden crits with no icons. Highest contrast." },
    };
    local vW = 114;
    for i = 1, table.getn(variants) do
        local v = variants[i];
        CreatePillButton(dmgFrame, "variant", v.id, v.label, v.label, v.desc, vW, 22, 12 + (i - 1) * (vW + 7), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.variant = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 30;
    
    -- 3. INTERACTIVE IN-WINDOW LIVE PREVIEW BOX
    local previewBox = CreateFrame("Frame", "BordoUI_DamagePreviewBox", dmgFrame);
    previewBox:SetWidth(356);
    previewBox:SetHeight(44);
    previewBox:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, curY);
    previewBox:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    previewBox:SetBackdropColor(0.02, 0.02, 0.03, 0.95);
    previewBox:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);
    
    local prevTag = previewBox:CreateFontString(nil, "OVERLAY");
    prevTag:SetFont(FONT_PATH, 8, "OUTLINE");
    prevTag:SetPoint("TOPLEFT", previewBox, "TOPLEFT", 6, -4);
    prevTag:SetText("|cff777777LIVE STYLE PREVIEW:|r");
    
    -- Preview Line 1
    local pIcon1 = previewBox:CreateTexture(nil, "ARTWORK");
    pIcon1:SetWidth(16); pIcon1:SetHeight(16);
    pIcon1:SetPoint("LEFT", previewBox, "LEFT", 12, -4);
    pIcon1:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    pIcon1:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
    
    local pText1 = previewBox:CreateFontString(nil, "OVERLAY");
    pText1:SetFont(FONT_PATH, 12, "OUTLINE");
    pText1:SetPoint("LEFT", pIcon1, "RIGHT", 4, 0);
    pText1:SetText("Frostbolt: 777");
    pText1:SetTextColor(0.4, 0.8, 1.0);
    
    -- Preview Line 2 (Crit)
    local pIcon2 = previewBox:CreateTexture(nil, "ARTWORK");
    pIcon2:SetWidth(16); pIcon2:SetHeight(16);
    pIcon2:SetPoint("LEFT", previewBox, "CENTER", 10, -4);
    pIcon2:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    pIcon2:SetTexture("Interface\\Icons\\Spell_Holy_SealOfProtection");
    
    local pText2 = previewBox:CreateFontString(nil, "OVERLAY");
    pText2:SetFont(FONT_PATH, 13, "OUTLINE");
    pText2:SetPoint("LEFT", pIcon2, "RIGHT", 4, 0);
    pText2:SetText("* 14,636 * x3");
    pText2:SetTextColor(1.0, 0.82, 0.0);
    
    previewWidgets.box = previewBox;
    previewWidgets.icon1 = pIcon1;
    previewWidgets.text1 = pText1;
    previewWidgets.icon2 = pIcon2;
    previewWidgets.text2 = pText2;
    
    curY = curY - 52;
    
    -- 4. DAMAGE FILTER MODES
    AddHeader("3. DAMAGE FILTER (SPAM REDUCTION):");
    local filters = {
        { id = "all",    label = "All Damage",  desc = "Show all direct hits, periodic DoT ticks, and crits." },
        { id = "nodots", label = "No DoT-Spam", desc = "Hide thousands of periodic DoT ticks; show only direct hits & crits!" },
        { id = "crits",  label = "Only Crits",  desc = "Exclusively display big critical strikes (cleanest screen)." },
        { id = "off",    label = "Disabled",    desc = "Completely disable scrolling damage numbers." },
    };
    local fW = 84;
    for i = 1, table.getn(filters) do
        local f = filters[i];
        CreatePillButton(dmgFrame, "filter", f.id, f.label, f.label, f.desc, fW, 20, 12 + (i - 1) * (fW + 6), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.filter = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 28;
    
    -- 5. FONT SELECTION
    AddHeader("4. FONT FAMILY:");
    local fontList = {
        { id = "modern",  label = "Modern",  desc = "Crisp, clean sans-serif typeface." },
        { id = "classic", label = "Classic", desc = "Nostalgic World of Warcraft Friz Quadrata." },
        { id = "arcade",  label = "Arcade",  desc = "Compact, legible Arial Narrow." },
        { id = "russo",   label = "Russo",   desc = "Heavy, punchy action comic block font." },
        { id = "exo",     label = "Exo",     desc = "Futuristic, elegant sci-fi font." },
    };
    local ftW = 67;
    for i = 1, table.getn(fontList) do
        local ft = fontList[i];
        CreatePillButton(dmgFrame, "font", ft.id, ft.label, ft.label, ft.desc, ftW, 20, 12 + (i - 1) * (ftW + 5), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.font = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 28;
    
    -- 6. SIZE SCALING
    AddHeader("5. SIZE & SCALE:");
    local scales = {
        { val = 0.50, label = "50% Tiny",    desc = "Small, minimal numbers." },
        { val = 0.70, label = "70% Compact", desc = "Compact size, ideal for large monster packs." },
        { val = 0.85, label = "85% Normal",  desc = "Balanced BordoUI standard size." },
        { val = 1.00, label = "100% Large",  desc = "Standard Blizzard 100% scale." },
        { val = 1.25, label = "125% Huge",   desc = "Extra large high-visibility numbers." },
    };
    for i = 1, table.getn(scales) do
        local sc = scales[i];
        CreatePillButton(dmgFrame, "scale", sc.val, sc.label, sc.label, sc.desc, ftW, 20, 12 + (i - 1) * (ftW + 5), curY, function(val)
            BordoUI:SetDamageScale(val);
        end);
    end
    curY = curY - 34;
    
    -- 7. ACTION BUTTONS: TEST LIVE COMBAT TEXT
    local testBtn = CreateFrame("Button", nil, dmgFrame);
    testBtn:SetWidth(356);
    testBtn:SetHeight(26);
    testBtn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, curY);
    testBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    testBtn:SetBackdropColor(0.08, 0.14, 0.22, 0.95);
    testBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
    
    local testTxt = testBtn:CreateFontString(nil, "OVERLAY");
    testTxt:SetFont(FONT_PATH, 10, "OUTLINE");
    testTxt:SetPoint("CENTER", testBtn, "CENTER", 0, 0);
    testTxt:SetText(">> Test Live Combat Text on Screen <<");
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
    curY = curY - 30;
    local statusText = dmgFrame:CreateFontString(nil, "OVERLAY");
    statusText:SetFont(FONT_PATH, 8, "OUTLINE");
    statusText:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, curY);
    statusText:SetTextColor(0.60, 0.85, 0.60);
    dmgFrame.statusText = statusText;
    
    BordoUI:UpdateDamageWindowUI();
    return dmgFrame;
end

-- Refresh Active Highlight & Live Preview in Settings Window
function BordoUI:UpdateDamageWindowUI()
    if ( not dmgFrame ) then return; end
    local s = self:GetDamageSettings();
    local fontDef = FONTS[s.font] or FONTS.modern;
    local fontPath = fontDef.path;
    local scale = tonumber(s.scale) or 0.85;
    
    -- Update Button Highlighting
    for i = 1, table.getn(optionButtons) do
        local btn = optionButtons[i];
        local isSelected = false;
        if ( btn.group == "scale" ) then
            isSelected = (math.abs((tonumber(s.scale) or 0.85) - tonumber(btn.val)) < 0.04);
        else
            isSelected = (s[btn.group] == btn.val);
        end
        
        if ( isSelected ) then
            btn:SetBackdropBorderColor(0.00, 0.85, 1.00, 1.0);
            btn:SetBackdropColor(0.05, 0.16, 0.25, 0.95);
            btn.label:SetTextColor(0.00, 0.95, 1.00);
        else
            btn:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95);
            btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
            btn.label:SetTextColor(0.65, 0.65, 0.65);
        end
    end
    
    -- Update In-Window Live Preview Box
    if ( previewWidgets.box ) then
        local pFontSize = math.max(10, math.floor(13 * (scale / 0.75)));
        previewWidgets.text1:SetFont(fontPath, pFontSize, "OUTLINE");
        previewWidgets.text2:SetFont(fontPath, math.floor(pFontSize * 1.15), "OUTLINE");
        
        if ( s.mode == "inworld" ) then
            previewWidgets.icon1:Hide();
            previewWidgets.icon2:Hide();
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.box, "LEFT", 14, -4);
            previewWidgets.text1:SetText("In-World 3D: 777");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.box, "CENTER", 10, -4);
            previewWidgets.text2:SetText("* 14,636 CRIT *");
        elseif ( s.variant == "xct" ) then
            previewWidgets.icon1:Show();
            previewWidgets.icon2:Show();
            previewWidgets.icon1:SetTexture("Interface\\Icons\\Spell_Fire_SelfDestruct");
            previewWidgets.icon2:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.icon1, "RIGHT", 4, 0);
            previewWidgets.text1:SetText("Magma Totem: 1,450 x5");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.icon2, "RIGHT", 4, 0);
            previewWidgets.text2:SetText("Frostbolt: * 820 *");
        elseif ( s.variant == "clean" ) then
            previewWidgets.icon1:Hide();
            previewWidgets.icon2:Hide();
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.box, "LEFT", 14, -4);
            previewWidgets.text1:SetText("777 (Frost)");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.box, "CENTER", 10, -4);
            previewWidgets.text2:SetText("* 14,636 CRIT *");
        else
            -- MSBT
            previewWidgets.icon1:Show();
            previewWidgets.icon2:Show();
            previewWidgets.icon1:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
            previewWidgets.icon2:SetTexture("Interface\\Icons\\Spell_Holy_SealOfProtection");
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.icon1, "RIGHT", 4, 0);
            previewWidgets.text1:SetText("777");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.icon2, "RIGHT", 4, 0);
            previewWidgets.text2:SetText("* 14,636 * x3");
        end
    end
    
    -- Bottom Status Text
    if ( dmgFrame.statusText ) then
        local modeName    = (s.mode == "inworld") and "Classic 3D" or "Scrolling SCT";
        local variantName = (s.variant == "xct") and "xCT+ Named" or ((s.variant == "clean") and "Clean Pure" or "MSBT Style");
        local filterNames = { all = "All Hits", nodots = "No DoT-Spam", crits = "Only Crits", off = "Disabled" };
        local fontNames   = { modern = "Modern", classic = "Classic", arcade = "Arcade", russo = "Russo", exo = "Exo" };
        local scPct       = math.floor((s.scale or 0.85) * 100 + 0.5);
        
        local filterNames = { all = "All Hits", nodots = "No DoT-Spam", crits = "Only Crits", off = "Disabled" };
        local fontNames   = { modern = "Modern", classic = "Classic", arcade = "Arcade", russo = "Russo", exo = "Exo" };
        local scPct       = math.floor(((tonumber(s.scale) or 0.85)) * 100 + 0.5);
        local fName       = filterNames[s.filter] or tostring(s.filter or "All Hits");
        local ftName      = fontNames[s.font] or tostring(s.font or "Modern");
        local subName     = (s.mode == "inworld") and "Over Ads" or variantName;

        dmgFrame.statusText:SetText(string.format("Active: |cffffd100%s|r | |cff00ccff%s|r | |cff55ff55%s|r | |cffaaaaaa%s|r | |cffffffff%d%%|r",
            tostring(modeName or "Scrolling SCT"),
            tostring(subName or "MSBT Style"),
            tostring(fName or "All Hits"),
            tostring(ftName or "Modern"),
            tonumber(scPct) or 85
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
