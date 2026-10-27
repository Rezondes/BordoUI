--[[
    Bordo UI - Damage Numbers & Combat Text Manager (DamageFont.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Dedicated Settings GUI Window (/bordo dmg or Minimap Dock Button 4)
    - Motion Style: Classic WoW Arc (seitlich im Bogen runtergehen), Scroll Up, Scroll Down
    - Filter Modes: All Numbers, No DoT-Spam (direct hits & crits only), Only Crits, Hidden/Off
    - Font Styles: Modern Sans, Classic WoW (Friz Quadrata), Arcade Narrow, Russo Bold, Exo Sci-Fi
    - Scaling: 50% (Winzig), 70% (Kompakt), 85% (Standard), 100% (Groß), 125% (Riesig)
    - Test-Hit simulation button for instant visual feedback
    - Minimap dock integration with Left-Click (Config), Right-Click (Cycle Filter), Shift-Click (Toggle Arc)
]]--

BordoUI = BordoUI or {};
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

-- Get or Initialize Settings
function BordoUI:GetDamageSettings()
    BordoUIDB = BordoUIDB or {};
    if ( not BordoUIDB.damageSettings ) then
        BordoUIDB.damageSettings = {
            motion = "arc",      -- "arc" (WoW Classic Arc), "up", "down"
            filter = "all",      -- "all", "nodots", "crits", "off"
            font   = "modern",   -- "modern", "classic", "arcade", "russo", "exo"
            scale  = (BordoUIDB and BordoUIDB.dmgScale) or 0.85,
        };
    end
    -- Synchronize legacy dmgScale if needed
    if ( BordoUIDB.dmgScale and BordoUIDB.damageSettings.scale ~= BordoUIDB.dmgScale ) then
        BordoUIDB.damageSettings.scale = BordoUIDB.dmgScale;
    end
    return BordoUIDB.damageSettings;
end

-- Hook Blizzard CombatText_AddMessage to support "Only Crits" and custom filtering
local orig_CombatText_AddMessage = nil;
local function HookCombatText()
    if ( not orig_CombatText_AddMessage and CombatText_AddMessage ) then
        orig_CombatText_AddMessage = CombatText_AddMessage;
        CombatText_AddMessage = function(message, scrollFunction, r, g, b, displayType, isStaggered)
            local s = BordoUI:GetDamageSettings();
            if ( s and s.filter == "crits" ) then
                local str = tostring(message or "");
                local isCrit = (displayType == "crit") or string.find(str, "%*") or (r and r > 0.9 and g and g > 0.8 and b and b < 0.2);
                if ( not isCrit ) then
                    return;
                end
            elseif ( s and s.filter == "off" ) then
                return;
            end
            return orig_CombatText_AddMessage(message, scrollFunction, r, g, b, displayType, isStaggered);
        end;
    end
end

-- Apply all Damage & Combat Text Settings
function BordoUI:ApplyDamageSettings()
    local s = self:GetDamageSettings();
    local fontDef = FONTS[s.font] or FONTS.modern;
    local fontPath = fontDef.path;
    
    -- In WoW 1.12 engine, DAMAGE_TEXT_FONT sets the 3D in-world floating combat text font
    DAMAGE_TEXT_FONT = fontPath;
    
    local scale = tonumber(s.scale) or 0.85;
    BordoUIDB.dmgScale = scale;
    
    -- 1. Animation Motion Style (WoW Arc vs Scroll Up/Down)
    if ( SetCVar ) then
        if ( s.motion == "arc" ) then
            pcall(SetCVar, "COMBAT_TEXT_FLOAT_MODE", "3"); -- Arc (Bogen / seitlich herunterfallen)
        elseif ( s.motion == "down" ) then
            pcall(SetCVar, "COMBAT_TEXT_FLOAT_MODE", "2"); -- Scroll Down
        else
            pcall(SetCVar, "COMBAT_TEXT_FLOAT_MODE", "1"); -- Scroll Up
        end
    end
    
    -- 2. Damage Filter Modes (All / No DoTs / Only Crits / Off)
    if ( SetCVar ) then
        if ( s.filter == "all" ) then
            pcall(SetCVar, "CombatDamage", "1");
            pcall(SetCVar, "CombatLogPeriodicSpells", "1");
            pcall(SetCVar, "PetMeleeDamage", "1");
            pcall(SetCVar, "PetSpellDamage", "1");
            pcall(SetCVar, "SHOW_COMBAT_TEXT", "1");
        elseif ( s.filter == "nodots" ) then
            pcall(SetCVar, "CombatDamage", "1");
            pcall(SetCVar, "CombatLogPeriodicSpells", "0"); -- Suppress periodic DoT spam
            pcall(SetCVar, "PetMeleeDamage", "1");
            pcall(SetCVar, "PetSpellDamage", "1");
            pcall(SetCVar, "SHOW_COMBAT_TEXT", "1");
        elseif ( s.filter == "crits" ) then
            pcall(SetCVar, "CombatDamage", "0"); -- Turn off white/yellow normal hits in world
            pcall(SetCVar, "SHOW_COMBAT_TEXT", "1"); -- Route outgoing crits through CombatText
        elseif ( s.filter == "off" ) then
            pcall(SetCVar, "CombatDamage", "0");
            pcall(SetCVar, "CombatLogPeriodicSpells", "0");
            pcall(SetCVar, "SHOW_COMBAT_TEXT", "0");
        end
    end
    
    -- 3. CombatText Scaling & Font
    if ( CombatText ) then
        CombatText:SetScale(scale);
    end
    if ( CombatTextFont ) then
        local fontSize = math.max(12, math.floor(18 * (scale / 0.75)));
        CombatTextFont:SetFont(fontPath, fontSize, "OUTLINE");
    end
    
    HookCombatText();
end

-- Backward compatibility alias
function AZSHelper:ApplyModernDamageText()
    BordoUI:ApplyDamageSettings();
end
function BordoUI:ApplyModernDamageText()
    BordoUI:ApplyDamageSettings();
end

-- Cycle Filter Mode (for Minimap Right-Click)
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
        all = "|cff55ff55Alle Zahlen|r (Vollständig)",
        nodots = "|cff00ccffOhne DoTs|r (Kein DoT-Spam)",
        crits = "|cffffd100Nur Crits|r (Ausschließlich kritische Treffer)",
        off = "|cffff4444Deaktiviert|r (Keine Zahlen)",
    };
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Schadenszahlen-Filter: " .. (names[nextFilter] or nextFilter));
end

-- Toggle Motion Mode (for Minimap Shift-Click)
function BordoUI:ToggleDamageMotion()
    local s = self:GetDamageSettings();
    if ( s.motion == "arc" ) then
        s.motion = "up";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Schadens-Flugbahn: |cff00ccffNach Oben (Scroll Up)|r");
    else
        s.motion = "arc";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Schadens-Flugbahn: |cffffd100WoW Bogen (Arc)|r (seitlich runterfallen)");
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

-- Simulated Test Damage Numbers
function BordoUI:TestDamageNumbers()
    self:ApplyDamageSettings();
    if ( not CombatText_AddMessage ) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: CombatText ist nicht geladen.");
        return;
    end
    
    local scroll = CombatText_StandardScroll;
    -- Spawn sample normal hit, sample heal, and a huge crit
    CombatText_AddMessage("1,240", scroll, 1.0, 1.0, 1.0);
    CombatText_AddMessage("+860", scroll, 0.25, 1.0, 0.25);
    CombatText_AddMessage("* 5,820 CRIT! *", scroll, 1.0, 0.82, 0.0, "crit");
    pcall(PlaySound, "igSpellCastStarted");
end

-------------------------------------------------------------------------------
-- CONFIGURATION GUI WINDOW (BordoUI_DamageNumbersFrame)
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
    dmgFrame:SetWidth(330);
    dmgFrame:SetHeight(380);
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
    dmgFrame:SetBackdropColor(0.04, 0.04, 0.07, 0.95);
    dmgFrame:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.95);
    dmgFrame:Hide();
    
    -- Title & Subtitle
    local title = dmgFrame:CreateFontString(nil, "OVERLAY");
    title:SetFont(FONT_PATH, 11, "OUTLINE");
    title:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, -8);
    title:SetText("|cff00ccffBordo UI|r |cffffd100Schadenszahlen & Styles|r");
    
    local subtitle = dmgFrame:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont(FONT_PATH, 8, "OUTLINE");
    subtitle:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 10, -22);
    subtitle:SetTextColor(0.65, 0.65, 0.65);
    subtitle:SetText("Passe Flugbahn, Filter, Schriftart und Skalierung der Zahlen an.");
    
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
    
    -- 1. Animation Motion Style
    AddHeader("1. Flugbahn & Animation (WoW-Style):");
    local motions = {
        { id = "arc",  label = "WoW Bogen (Arc)", desc = "Springt hoch und fällt seitlich im Bogen herunter (WoW-Klassiker)." },
        { id = "up",   label = "Nach Oben",       desc = "Klassisches Hochsteigen über dem Ziel (Scroll Up)." },
        { id = "down", label = "Nach Unten",      desc = "Sanft nach unten gleiten (Scroll Down)." },
    };
    local btnW = 98;
    for i = 1, table.getn(motions) do
        local m = motions[i];
        CreateOptionButton(dmgFrame, "motion", m.id, m.label, m.label, m.desc, btnW, 20, 10 + (i - 1) * (btnW + 6), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.motion = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 28;
    
    -- 2. Damage Filter
    AddHeader("2. Zahlen-Filter (Spam reduzieren):");
    local filters = {
        { id = "all",    label = "Alle Zahlen", desc = "Zeigt alle direkten Treffer, DoT-Ticks & Crits vollständig an." },
        { id = "nodots", label = "Ohne DoTs",   desc = "Schaltet tausende DoT-Zahlen aus! Zeigt nur echte Treffer & Crits." },
        { id = "crits",  label = "Nur Crits",   desc = "Zeigt ausschließlich fette kritische Treffer an (maximale Übersicht)." },
        { id = "off",    label = "Aus",         desc = "Fliegende Schadenszahlen komplett verstecken." },
    };
    local fW = 73;
    for i = 1, table.getn(filters) do
        local f = filters[i];
        CreateOptionButton(dmgFrame, "filter", f.id, f.label, f.label, f.desc, fW, 20, 10 + (i - 1) * (fW + 6), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.filter = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 28;
    
    -- 3. Font Styles
    AddHeader("3. Schriftart (Font Style):");
    local fontList = {
        { id = "modern",  label = "Modern",  desc = "Crisp, saubere sans-serif Schriftart." },
        { id = "classic", label = "Classic", desc = "Nostalgische WoW Friz Quadrata Schriftart." },
        { id = "arcade",  label = "Arcade",  desc = "Schmale, kompakte Arial Narrow Schriftart." },
        { id = "russo",   label = "Russo",   desc = "Fette, wuchtige Blockschrift (Russo One)." },
        { id = "exo",     label = "Exo",     desc = "Futuristischer Sci-Fi-Stil (Exo)." },
    };
    local ftW = 58;
    for i = 1, table.getn(fontList) do
        local ft = fontList[i];
        CreateOptionButton(dmgFrame, "font", ft.id, ft.label, ft.label, ft.desc, ftW, 20, 10 + (i - 1) * (ftW + 5), curY, function(val)
            local s = BordoUI:GetDamageSettings();
            s.font = val;
            BordoUI:ApplyDamageSettings();
            BordoUI:UpdateDamageWindowUI();
        end);
    end
    curY = curY - 28;
    
    -- 4. Scale Sizes
    AddHeader("4. Größe & Skalierung:");
    local scales = {
        { val = 0.50, label = "50% Klein",   desc = "Sehr kleine, unaufdringliche Zahlen." },
        { val = 0.70, label = "70% Kompakt", desc = "Kompakte Zahlen, ideal für dichte Monsterhorden." },
        { val = 0.85, label = "85% Normal",  desc = "Ausgewogene Standardgröße (BordoUI Default)." },
        { val = 1.00, label = "100% Groß",   desc = "Original Blizzard 100% Schriftgröße." },
        { val = 1.25, label = "125% Riesig", desc = "Extra große, massive Schadenszahlen." },
    };
    for i = 1, table.getn(scales) do
        local sc = scales[i];
        CreateOptionButton(dmgFrame, "scale", sc.val, sc.label, sc.label, sc.desc, ftW, 20, 10 + (i - 1) * (ftW + 5), curY, function(val)
            BordoUI:SetDamageScale(val);
        end);
    end
    curY = curY - 34;
    
    -- 5. Test Button
    local testBtn = CreateFrame("Button", nil, dmgFrame);
    testBtn:SetWidth(310);
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
    testTxt:SetText("▶  Test-Schadenszahlen simulieren (Hits & Crit)");
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
        local motionNames = { arc = "WoW Bogen", up = "Nach Oben", down = "Nach Unten" };
        local filterNames = { all = "Alle Zahlen", nodots = "Ohne DoTs", crits = "Nur Crits", off = "Aus" };
        local fontNames   = { modern = "Modern", classic = "Classic", arcade = "Arcade", russo = "Russo", exo = "Exo" };
        local scPct = math.floor((s.scale or 0.85) * 100 + 0.5);
        
        dmgFrame.statusText:SetText(string.format("Aktiv: |cffffd100%s|r | |cff00ccff%s|r | |cff55ff55%s|r | |cffffffff%d%%|r",
            motionNames[s.motion] or s.motion,
            filterNames[s.filter] or s.filter,
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
