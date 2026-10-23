--[[
    AZS Helper - Complete Modern UI Overhaul (ThemeUI.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Faithfully reproduces the modern HUD from the reference screenshot:
    - 1. Centered Player Unit Frame with HP/Mana & Class Proc Bar
    - 2. Compact Square Action Buttons next to Player Frame
    - 3. Bottom Datatext Bar (LVL, XP, KILLS, GOLD, CHEST, LIVES, RR, DMG, FPS)
    - 4. Right Side Run Clock & Full Boss Schedule Panel (with purple final boss)
    - 5. Left Side Multipliers Panel (Damage, Crit, Cooldown, etc. + Highest Crit)
    - 6. Modern Square Minimap with Zone Pill
    - 7. Sleek Dark Chat Frame
]]--

-- Global environment compatibility for WoW 1.12.1
local _G = getfenv(0);

-- UI Widget Registry (Consolidates all widgets into a single table to respect Lua 5.0's 32-upvalue limit)
local UI = {};
AZSHelper.ThemeUI = UI;

-- Class Colors for Player Frame & Text (Comprehensive English & German mapping)
local CLASS_COLORS = {
    -- English standard
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 }, -- Brown / Tan
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 }, -- Pink
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 }, -- Green
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 }, -- Yellow
    ["PRIEST"]      = { r = 0.90, g = 0.90, b = 0.90 }, -- White
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 }, -- Blue
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 }, -- Ice Blue / Cyan
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 }, -- Purple
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 }, -- Orange
    
    -- German localized
    ["KRIEGER"]     = { r = 0.78, g = 0.61, b = 0.43 },
    ["JÄGER"]       = { r = 0.67, g = 0.83, b = 0.45 },
    ["JAEGER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["SCHURKE"]     = { r = 1.00, g = 0.96, b = 0.41 },
    ["PRIESTER"]    = { r = 0.90, g = 0.90, b = 0.90 },
    ["SCHAMANE"]    = { r = 0.00, g = 0.44, b = 0.87 },
    ["MAGIER"]      = { r = 0.41, g = 0.80, b = 0.94 },
    ["HEXENMEISTER"]= { r = 0.58, g = 0.51, b = 0.79 },
    ["DRUIDE"]      = { r = 1.00, g = 0.49, b = 0.04 },
};

local function GetPlayerClassColor()
    local locCls, engCls = UnitClass("player");
    
    if ( engCls ) then
        local upperEng = string.upper(engCls);
        if ( CLASS_COLORS[upperEng] ) then
            return CLASS_COLORS[upperEng];
        end
    end
    if ( locCls ) then
        local upperLoc = string.upper(locCls);
        if ( CLASS_COLORS[upperLoc] ) then
            return CLASS_COLORS[upperLoc];
        end
    end
    if ( RAID_CLASS_COLORS and engCls and RAID_CLASS_COLORS[engCls] ) then
        return RAID_CLASS_COLORS[engCls];
    end
    
    -- Heuristic detection from active Azeroth Survivors spells
    if ( AZS_SPELLS ) then
        for i = 1, table.getn(AZS_SPELLS) do
            local sp = AZS_SPELLS[i];
            if ( sp and sp.key ) then
                local k = string.lower(sp.key);
                if ( string.find(k, "fire") or string.find(k, "frost") or string.find(k, "arcane") or string.find(k, "pyro") or string.find(k, "blizzard") or string.find(k, "scorch") or string.find(k, "combustion") ) then
                    return CLASS_COLORS["MAGE"];
                elseif ( string.find(k, "shadow") or string.find(k, "corruption") or string.find(k, "immolate") or string.find(k, "drain") or string.find(k, "curse") or string.find(k, "chaos") ) then
                    return CLASS_COLORS["WARLOCK"];
                elseif ( string.find(k, "sinister") or string.find(k, "eviscerate") or string.find(k, "backstab") or string.find(k, "stealth") or string.find(k, "fan") ) then
                    return CLASS_COLORS["ROGUE"];
                elseif ( string.find(k, "shot") or string.find(k, "sting") or string.find(k, "trap") or string.find(k, "aimed") or string.find(k, "multi") ) then
                    return CLASS_COLORS["HUNTER"];
                elseif ( string.find(k, "smite") or string.find(k, "heal") or string.find(k, "holy") or string.find(k, "prayer") or string.find(k, "renew") ) then
                    return CLASS_COLORS["PRIEST"];
                elseif ( string.find(k, "lightning") or string.find(k, "earth") or string.find(k, "shock") or string.find(k, "chain") or string.find(k, "windfury") or string.find(k, "totem") ) then
                    return CLASS_COLORS["SHAMAN"];
                elseif ( string.find(k, "wrath") or string.find(k, "moonfire") or string.find(k, "starfire") or string.find(k, "swipe") or string.find(k, "rejuv") ) then
                    return CLASS_COLORS["DRUID"];
                elseif ( string.find(k, "strike") or string.find(k, "shout") or string.find(k, "cleave") or string.find(k, "slam") or string.find(k, "whirlwind") or string.find(k, "sunder") or string.find(k, "rend") ) then
                    return CLASS_COLORS["WARRIOR"];
                elseif ( string.find(k, "judgment") or string.find(k, "seal") or string.find(k, "consecration") or string.find(k, "hammer") ) then
                    return CLASS_COLORS["PALADIN"];
                end
            end
        end
    end
    
    return { r = 0.41, g = 0.80, b = 0.94 }; -- Default to clean Ice Blue (Mage)
end

-- =========================================================================
-- 1. BOTTOM HORIZONTAL DATATEXT BAR
-- =========================================================================
UI.bottomBar = CreateFrame("Frame", "AZSHelper_BottomBar", UIParent);
UI.bottomBar:SetWidth(620);
UI.bottomBar:SetHeight(18);
UI.bottomBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 2);
UI.bottomBar:SetFrameStrata("LOW");
UI.bottomBar:SetFrameLevel(5);

UI.bottomBar:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.bottomBar:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.bottomBar:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.90);

UI.bottomText = UI.bottomBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.bottomText:SetPoint("CENTER", UI.bottomBar, "CENTER", 0, 0);
UI.bottomText:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE");

-- Modern XP Status Bar Frame (bündig directly attached to top of bottomBar with 4px border overlap)
UI.xpContainer = CreateFrame("Frame", "AZSHelper_XPContainer", UI.bottomBar);
UI.xpContainer:SetPoint("BOTTOMLEFT", UI.bottomBar, "TOPLEFT", 0, -4);
UI.xpContainer:SetPoint("BOTTOMRIGHT", UI.bottomBar, "TOPRIGHT", 0, -4);
UI.xpContainer:SetHeight(10);
UI.xpContainer:SetFrameStrata("LOW");
UI.xpContainer:SetFrameLevel(6);
UI.xpContainer:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.xpContainer:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.xpContainer:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.90);

UI.xpBar = CreateFrame("StatusBar", "AZSHelper_XPBar", UI.xpContainer);
UI.xpBar:SetPoint("TOPLEFT", UI.xpContainer, "TOPLEFT", 3, -2);
UI.xpBar:SetPoint("BOTTOMRIGHT", UI.xpContainer, "BOTTOMRIGHT", -3, 2);
UI.xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
UI.xpBar:SetStatusBarColor(0.0, 0.75, 0.95, 1.0); -- Bright Cyan / XP Blue
UI.xpBar:SetMinMaxValues(0, 100);

-- Centered XP Text directly above the blue bar (e.g. "91%  (18.5k / 20.3k XP)")
UI.xpText = UI.xpContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.xpText:SetPoint("BOTTOM", UI.xpContainer, "TOP", 0, 2);
UI.xpText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.xpText:SetTextColor(1, 1, 1, 0.95);

UI.xpContainer:EnableMouse(true);
UI.xpContainer:SetScript("OnEnter", function()
    local lvl = (AZS_RUN and AZS_RUN.lvl) or UnitLevel("player") or 1;
    local xp = (AZS_RUN and AZS_RUN.xp) or UnitXP("player") or 0;
    local xpn = (AZS_RUN and AZS_RUN.xpn) or UnitXPMax("player") or 1;
    if ( xpn <= 0 ) then xpn = 1; end
    local pct = math.floor((xp / xpn) * 100);
    local remaining = math.max(0, xpn - xp);
    
    GameTooltip:SetOwner(this, "ANCHOR_TOP");
    GameTooltip:AddLine(string.format("|cff00ccffExperience (Level %d)|r", lvl));
    GameTooltip:AddLine(string.format("Progress: |cffffffff%s / %s (%d%%)|r", AZSHelper:FormatNumber(xp), AZSHelper:FormatNumber(xpn), pct));
    GameTooltip:AddLine(string.format("Remaining: |cffffd100%s XP|r", AZSHelper:FormatNumber(remaining)));
    GameTooltip:Show();
end);
UI.xpContainer:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

-- =========================================================================
-- 2. CENTERED COMBAT HUD: PLAYER HP (LEFT), SKILLS (CENTER), BOSS HP (RIGHT)
-- =========================================================================

-- Central Skills Container (Centered horizontally under the character)
UI.skillsContainer = CreateFrame("Frame", "AZSHelper_SkillsContainer", UIParent);
UI.skillsContainer:SetWidth(224);
UI.skillsContainer:SetHeight(34);
UI.skillsContainer:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200);
UI.skillsContainer:SetFrameStrata("MEDIUM");
UI.skillsContainer:SetFrameLevel(10);
UI.skillsContainer:SetClampedToScreen(true);
AZSHelper:MakeMovable(UI.skillsContainer, "centerHudPos");

UI.skillsContainer:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 }
});
UI.skillsContainer:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.skillsContainer:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

-- -------------------------------------------------------------------------
-- LEFT: PLAYER UNIT FRAME (Square Portrait on Left, Bar on Right)
-- -------------------------------------------------------------------------
UI.centerPlayer = CreateFrame("Frame", "AZSHelper_CenterPlayerFrame", UI.skillsContainer);
UI.centerPlayer:SetWidth(170);
UI.centerPlayer:SetHeight(34);
UI.centerPlayer:SetPoint("RIGHT", UI.skillsContainer, "LEFT", -8, 0);
UI.centerPlayer:SetFrameStrata("MEDIUM");
UI.centerPlayer:SetFrameLevel(10);
UI.centerPlayer:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile     = true,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 }
});
UI.centerPlayer:SetBackdropColor(0.04, 0.04, 0.05, 1.0);

-- Small Square Player Portrait Box (Left of Player Bar)
UI.pPortraitFrame = CreateFrame("Frame", nil, UI.centerPlayer);
UI.pPortraitFrame:SetWidth(34);
UI.pPortraitFrame:SetHeight(34);
UI.pPortraitFrame:SetPoint("LEFT", UI.centerPlayer, "LEFT", 0, 0);
UI.pPortraitFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.pPortraitFrame:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.pPortraitFrame:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

UI.playerPortrait = UI.pPortraitFrame:CreateTexture(nil, "ARTWORK");
UI.playerPortrait:SetPoint("TOPLEFT", UI.pPortraitFrame, "TOPLEFT", 3, -3);
UI.playerPortrait:SetPoint("BOTTOMRIGHT", UI.pPortraitFrame, "BOTTOMRIGHT", -3, 3);
SetPortraitTexture(UI.playerPortrait, "player");
UI.playerPortrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);

-- Player Bar (Bündig directly attached to Portrait Box with 4px border overlap)
UI.playerBar = CreateFrame("Frame", nil, UI.centerPlayer);
UI.playerBar:SetWidth(140);
UI.playerBar:SetHeight(34);
UI.playerBar:SetPoint("LEFT", UI.pPortraitFrame, "RIGHT", -4, 0);
UI.playerBar:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.playerBar:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.playerBar:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

-- Top Line: Player Name (Left) & Level (Right)
UI.pNameText = UI.playerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.pNameText:SetPoint("TOPLEFT", UI.playerBar, "TOPLEFT", 6, -3);
UI.pNameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
UI.pNameText:SetTextColor(1, 1, 1, 1);

UI.pLevelBadge = UI.playerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.pLevelBadge:SetPoint("TOPRIGHT", UI.playerBar, "TOPRIGHT", -6, -3);
UI.pLevelBadge:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
UI.pLevelBadge:SetTextColor(0.95, 0.82, 0.15); -- Gold/Yellow

-- Slim Power Bar directly underneath health bar
UI.powerBar = CreateFrame("StatusBar", nil, UI.playerBar);
UI.powerBar:SetPoint("BOTTOMLEFT", UI.playerBar, "BOTTOMLEFT", 4, 2);
UI.powerBar:SetPoint("BOTTOMRIGHT", UI.playerBar, "BOTTOMRIGHT", -4, 2);
UI.powerBar:SetHeight(2);
UI.powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
UI.powerBar:SetStatusBarColor(0.15, 0.40, 0.90, 1.0);
UI.powerBar:SetMinMaxValues(0, 100);

-- Bottom Line: Class-Colored Health Bar
UI.healthBar = CreateFrame("StatusBar", nil, UI.playerBar);
UI.healthBar:SetPoint("BOTTOMLEFT", UI.playerBar, "BOTTOMLEFT", 4, 4);
UI.healthBar:SetPoint("BOTTOMRIGHT", UI.playerBar, "BOTTOMRIGHT", -4, 4);
UI.healthBar:SetHeight(14);
UI.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
local cCol = GetPlayerClassColor();
UI.healthBar:SetStatusBarColor(cCol.r, cCol.g, cCol.b, 1.0);
UI.healthBar:SetMinMaxValues(0, 100);

UI.pHpValueText = UI.healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.pHpValueText:SetPoint("LEFT", UI.healthBar, "LEFT", 4, 0);
UI.pHpValueText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.pHpValueText:SetTextColor(1, 1, 1, 1);

UI.pHpPctText = UI.healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.pHpPctText:SetPoint("RIGHT", UI.healthBar, "RIGHT", -4, 0);
UI.pHpPctText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.pHpPctText:SetTextColor(1, 1, 1, 1);

-- Proc / Buff Bar directly above Player Frame
UI.procBar = CreateFrame("StatusBar", "AZSHelper_ProcBar", UI.centerPlayer);
UI.procBar:SetPoint("BOTTOMLEFT", UI.playerBar, "TOPLEFT", 0, 4);
UI.procBar:SetPoint("BOTTOMRIGHT", UI.playerBar, "TOPRIGHT", 0, 11);
UI.procBar:SetHeight(7);
UI.procBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
UI.procBar:SetStatusBarColor(0.9, 0.15, 0.15, 1.0);
UI.procBar:SetMinMaxValues(0, 100);
UI.procBar:Hide();

UI.procBorder = CreateFrame("Frame", nil, UI.procBar);
UI.procBorder:SetPoint("TOPLEFT", UI.procBar, "TOPLEFT", -1, 1);
UI.procBorder:SetPoint("BOTTOMRIGHT", UI.procBar, "BOTTOMRIGHT", 1, -1);
UI.procBorder:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 6,
});
UI.procBorder:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.9);

UI.procText = UI.procBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.procText:SetPoint("LEFT", UI.procBar, "LEFT", 2, 0);
UI.procText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");

UI.procTimeText = UI.procBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.procTimeText:SetPoint("RIGHT", UI.procBar, "RIGHT", -2, 0);
UI.procTimeText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");

-- -------------------------------------------------------------------------
-- RIGHT: BOSS / TARGET UNIT FRAME (Bar on Left, Square Portrait on Right)
-- -------------------------------------------------------------------------
UI.centerBoss = CreateFrame("Frame", "AZSHelper_CenterBossFrame", UI.skillsContainer);
UI.centerBoss:SetWidth(170);
UI.centerBoss:SetHeight(34);
UI.centerBoss:SetPoint("LEFT", UI.skillsContainer, "RIGHT", 8, 0);
UI.centerBoss:SetFrameStrata("MEDIUM");
UI.centerBoss:SetFrameLevel(10);
UI.centerBoss:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile     = true,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 }
});
UI.centerBoss:SetBackdropColor(0.04, 0.04, 0.05, 1.0);

-- Boss Bar (Left of Portrait Box)
UI.bossBar = CreateFrame("Frame", nil, UI.centerBoss);
UI.bossBar:SetWidth(140);
UI.bossBar:SetHeight(34);
UI.bossBar:SetPoint("LEFT", UI.centerBoss, "LEFT", 0, 0);
UI.bossBar:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.bossBar:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.bossBar:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

-- Top Line: Level/Elite Badge (Left) & Boss Name (Right)
UI.bossBadge = UI.bossBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.bossBadge:SetPoint("TOPLEFT", UI.bossBar, "TOPLEFT", 6, -3);
UI.bossBadge:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
UI.bossBadge:SetTextColor(0.95, 0.82, 0.15); -- Gold/Yellow

UI.bossNameText = UI.bossBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.bossNameText:SetPoint("TOPRIGHT", UI.bossBar, "TOPRIGHT", -6, -3);
UI.bossNameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
UI.bossNameText:SetTextColor(1, 1, 1, 1);

-- Bottom Line: Crimson Red Health Bar (Mirrored: % on Left, Value on Right)
UI.bossHealthBar = CreateFrame("StatusBar", nil, UI.bossBar);
UI.bossHealthBar:SetPoint("BOTTOMLEFT", UI.bossBar, "BOTTOMLEFT", 4, 3);
UI.bossHealthBar:SetPoint("BOTTOMRIGHT", UI.bossBar, "BOTTOMRIGHT", -4, 3);
UI.bossHealthBar:SetHeight(15);
UI.bossHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
UI.bossHealthBar:SetStatusBarColor(0.85, 0.15, 0.15, 1.0);
UI.bossHealthBar:SetMinMaxValues(0, 100);

UI.bossHpPctText = UI.bossHealthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.bossHpPctText:SetPoint("LEFT", UI.bossHealthBar, "LEFT", 4, 0);
UI.bossHpPctText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.bossHpPctText:SetTextColor(1, 1, 1, 1);

UI.bossHpValueText = UI.bossHealthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.bossHpValueText:SetPoint("RIGHT", UI.bossHealthBar, "RIGHT", -4, 0);
UI.bossHpValueText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.bossHpValueText:SetTextColor(1, 1, 1, 1);

-- Small Square Boss/Target Portrait Box (Bündig directly attached to right of Boss Bar with 4px border overlap)
UI.bossPortraitFrame = CreateFrame("Frame", nil, UI.centerBoss);
UI.bossPortraitFrame:SetWidth(34);
UI.bossPortraitFrame:SetHeight(34);
UI.bossPortraitFrame:SetPoint("LEFT", UI.bossBar, "RIGHT", -4, 0);
UI.bossPortraitFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.bossPortraitFrame:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
UI.bossPortraitFrame:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

UI.bossPortrait = UI.bossPortraitFrame:CreateTexture(nil, "ARTWORK");
UI.bossPortrait:SetPoint("TOPLEFT", UI.bossPortraitFrame, "TOPLEFT", 3, -3);
UI.bossPortrait:SetPoint("BOTTOMRIGHT", UI.bossPortraitFrame, "BOTTOMRIGHT", -3, 3);
UI.bossPortrait:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01");

UI.centerBoss:Hide();

-- =========================================================================
-- 2B. TOP BOSS & MINIBOSS ENCOUNTER BARS (Extra HP bars for ALL active bosses & awake guardians)
-- =========================================================================
UI.encounterContainer = CreateFrame("Frame", "AZSHelper_BossEncounterContainer", UIParent);
UI.encounterContainer:SetWidth(320);
UI.encounterContainer:SetHeight(160);
UI.encounterContainer:SetPoint("TOP", UIParent, "TOP", 0, -55);
UI.encounterContainer:SetFrameStrata("MEDIUM");
UI.encounterContainer:SetFrameLevel(25);
UI.encounterContainer:SetClampedToScreen(true);
AZSHelper:MakeMovable(UI.encounterContainer, "encounterBarsPos");
UI.encounterContainer:Hide();

UI.encounterBars = {};
for i = 1, 6 do
    local bar = CreateFrame("Frame", nil, UI.encounterContainer);
    bar:SetWidth(310);
    bar:SetHeight(22);
    bar:SetPoint("TOP", UI.encounterContainer, "TOP", 0, -(i - 1) * 26 - 2);

    bar:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    });
    bar:SetBackdropColor(0.04, 0.04, 0.06, 0.95);
    bar:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85);

    local sb = CreateFrame("StatusBar", nil, bar);
    sb:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2);
    sb:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2);
    sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    sb:SetMinMaxValues(0, 100);
    bar.statusBar = sb;

    local nameText = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    nameText:SetPoint("LEFT", sb, "LEFT", 6, 0);
    nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    nameText:SetJustifyH("LEFT");
    bar.nameText = nameText;

    local hpText = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    hpText:SetPoint("RIGHT", sb, "RIGHT", -6, 0);
    hpText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    hpText:SetJustifyH("RIGHT");
    bar.hpText = hpText;

    bar:Hide();
    UI.encounterBars[i] = bar;
end

-- Safe hiding helper for both Frames and Textures in WoW 1.12.1
local function SafeHide(obj)
    if ( not obj ) then return; end
    if ( type(obj) == "string" ) then
        obj = getglobal(obj);
        if ( not obj ) then return; end
    end
    if ( obj.Hide ) then
        obj:Hide();
    end
    if ( obj.ClearAllPoints and UIParent ) then
        obj:ClearAllPoints();
        obj:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -5000);
    end
    if ( obj.SetTexture ) then
        obj:SetTexture("");
    end
    if ( obj.SetVertexColor ) then
        obj:SetVertexColor(0, 0, 0, 0);
    end
    if ( obj.SetAlpha ) then
        obj:SetAlpha(0);
    end
end

-- Disable Azeroth Survivors built-in HUD elements
local function HideAZSHudElements()
    if ( AZS_SetHudShown ) then
        AZS_SetHudShown("clock", false);
        AZS_SetHudShown("tally", false);
        AZS_SetHudShown("build", false);
        AZS_SetHudShown("bosses", false);
    end
    if ( SetCVar ) then
        pcall(SetCVar, "hudClock", "0");
        pcall(SetCVar, "hudTally", "0");
        pcall(SetCVar, "hudBuild", "0");
        pcall(SetCVar, "hudBosses", "0");
    end
end

-- Hide Blizzard Default MainMenuBar, Player Frame, Endcaps, Micro Buttons & Bags
local function HideDefaultBlizzardFrames()
    HideAZSHudElements();

    if ( MainMenuBar ) then
        MainMenuBar:ClearAllPoints();
        MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -5000);
        MainMenuBar:Hide();
        MainMenuBar.Show = function() end;
    end
    if ( MainMenuBarArtFrame ) then
        MainMenuBarArtFrame:ClearAllPoints();
        MainMenuBarArtFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -5000);
        MainMenuBarArtFrame:Hide();
        MainMenuBarArtFrame.Show = function() end;
    end
    if ( BonusActionBarFrame ) then
        BonusActionBarFrame:ClearAllPoints();
        BonusActionBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -5000);
        BonusActionBarFrame:Hide();
    end

    -- Kill Blizzard Default Player Frame & Target Frame
    if ( PlayerFrame ) then
        PlayerFrame:ClearAllPoints();
        PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -5000, 5000);
        PlayerFrame:Hide();
        PlayerFrame:UnregisterAllEvents();
        PlayerFrame.Show = function() end;
    end
    if ( TargetFrame ) then
        TargetFrame:ClearAllPoints();
        TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -5000, 5000);
        TargetFrame:Hide();
        TargetFrame:UnregisterAllEvents();
        TargetFrame.Show = function() end;
    end

    -- Hide Blizzard standard frames
    local framesToHide = {
        "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap",
        "MainMenuBarMaxLevelBar", "MainMenuExpBar",
        "ReputationWatchBar",
        "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
        "QuestLogMicroButton", "SocialsMicroButton", "WorldMapMicroButton",
        "MainMenuMicroButton", "HelpMicroButton",
        "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
        "CharacterBag2Slot", "CharacterBag3Slot",
        "KeyRingButton",
        "MainMenuBarOverlayFrame",
        "ShapeshiftBarFrame", "PetActionBarFrame"
    };

    for _, name in pairs(framesToHide) do
        SafeHide(name);
    end

    -- Hide Blizzard action bar background textures
    local artTextures = {
        "MainMenuBarTexture0", "MainMenuBarTexture1", "MainMenuBarTexture2", "MainMenuBarTexture3",
        "MainMenuXPBarTexture0", "MainMenuXPBarTexture1", "MainMenuXPBarTexture2", "MainMenuXPBarTexture3"
    };
    for _, texName in pairs(artTextures) do
        SafeHide(texName);
    end
end

-- Setup Action Buttons 1..6 (Skills) + Slot 12/7 (Racial Ability) inside skillsContainer
local function SetupActionButtons()
    local btnSize = 28;
    local btnGap  = 3;
    local startX  = 3;
    local startY  = 3;

    for i = 1, 6 do
        local btn = getglobal("ActionButton" .. i);
        if ( btn ) then
            btn:SetParent(UI.skillsContainer);
            btn:ClearAllPoints();
            btn:SetPoint("TOPLEFT", UI.skillsContainer, "TOPLEFT", startX + (i - 1) * (btnSize + btnGap), -startY);
            btn:SetWidth(btnSize);
            btn:SetHeight(btnSize);
            btn:SetFrameStrata("MEDIUM");
            btn:SetFrameLevel(UI.skillsContainer:GetFrameLevel() + 2);
            btn:Show();

            -- Hide Blizzard border textures
            local border = getglobal("ActionButton" .. i .. "Border");
            if ( border ) then border:Hide(); border.Show = function() end; end

            local norm = getglobal("ActionButton" .. i .. "NormalTexture");
            if ( norm ) then norm:SetAlpha(0); end

            local icon = getglobal("ActionButton" .. i .. "Icon");
            if ( icon ) then
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
            end

            -- Modern dark border
            if ( not btn.darkBorder ) then
                local b = CreateFrame("Frame", nil, btn);
                b:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1);
                b:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1);
                b:SetFrameLevel(btn:GetFrameLevel() + 1);
                b:SetBackdrop({
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true,
                    tileSize = 8,
                    edgeSize = 6,
                    insets = { left = 1, right = 1, top = 1, bottom = 1 }
                });
                b:SetBackdropBorderColor(0.20, 0.20, 0.24, 0.95);
                btn.darkBorder = b;
            end

            local hotkey = getglobal("ActionButton" .. i .. "HotKey");
            if ( hotkey ) then hotkey:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE"); end

            local count = getglobal("ActionButton" .. i .. "Count");
            if ( count ) then count:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE"); end

            -- Cooldown number overlay (clean integer display)
            if ( not btn.cdText ) then
                local cdText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
                cdText:SetPoint("CENTER", btn, "CENTER", 0, 0);
                cdText:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE");
                cdText:SetTextColor(1, 1, 1, 1);
                btn.cdText = cdText;
            end
        end
    end

    -- Setup Racial Ability Slot (Native slot 12 in stock Azeroth Survivors, fallback to slot 7)
    local racialSlot = 12;
    if ( not HasAction(12) and HasAction(7) ) then
        racialSlot = 7;
    end
    UI.racialSlot = racialSlot;

    local racialBtn = getglobal("ActionButton" .. racialSlot);
    UI.racialBtn = racialBtn;

    if ( racialBtn ) then
        racialBtn:SetParent(UI.skillsContainer);
        racialBtn:ClearAllPoints();
        local racialX = startX + 6 * (btnSize + btnGap) + 4; -- 4px separator gap
        racialBtn:SetPoint("TOPLEFT", UI.skillsContainer, "TOPLEFT", racialX, -startY);
        racialBtn:SetWidth(btnSize);
        racialBtn:SetHeight(btnSize);
        racialBtn:SetFrameStrata("MEDIUM");
        racialBtn:SetFrameLevel(UI.skillsContainer:GetFrameLevel() + 2);
        racialBtn:Show();

        local border = getglobal("ActionButton" .. racialSlot .. "Border");
        if ( border ) then border:Hide(); border.Show = function() end; end

        local norm = getglobal("ActionButton" .. racialSlot .. "NormalTexture");
        if ( norm ) then norm:SetAlpha(0); end

        local icon = getglobal("ActionButton" .. racialSlot .. "Icon");
        if ( icon ) then
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
        end

        -- Radiant gold border for Racial ability
        if ( not racialBtn.darkBorder ) then
            local b = CreateFrame("Frame", nil, racialBtn);
            b:SetPoint("TOPLEFT", racialBtn, "TOPLEFT", -1, 1);
            b:SetPoint("BOTTOMRIGHT", racialBtn, "BOTTOMRIGHT", 1, -1);
            b:SetFrameLevel(racialBtn:GetFrameLevel() + 1);
            b:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 8,
                edgeSize = 6,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            });
            b:SetBackdropBorderColor(0.90, 0.70, 0.15, 0.95); -- Gold highlight
            racialBtn.darkBorder = b;
        end

        local hotkey = getglobal("ActionButton" .. racialSlot .. "HotKey");
        if ( hotkey ) then
            hotkey:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
            hotkey:SetTextColor(1.0, 0.85, 0.3);
        end

        local count = getglobal("ActionButton" .. racialSlot .. "Count");
        if ( count ) then count:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE"); end

        if ( not racialBtn.cdText ) then
            local cdText = racialBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
            cdText:SetPoint("CENTER", racialBtn, "CENTER", 0, 0);
            cdText:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE");
            cdText:SetTextColor(1, 1, 1, 1);
            racialBtn.cdText = cdText;
        end
    end

    -- Hide remaining unused action buttons
    for i = 7, 12 do
        if ( i ~= racialSlot ) then
            SafeHide("ActionButton" .. i);
        end
    end
end

-- =========================================================================
-- 3. RIGHT SIDE: EXACT BOSS-TIMER & SPAWN SCHEDULE PANEL
-- =========================================================================
UI.bossPanel = CreateFrame("Frame", "AZSHelper_BossSchedulePanel", UIParent);
UI.bossPanel:SetWidth(215);
UI.bossPanel:SetHeight(215);
UI.bossPanel:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -155);
UI.bossPanel:SetFrameStrata("BACKGROUND");
UI.bossPanel:SetClampedToScreen(true);
AZSHelper:MakeMovable(UI.bossPanel, "bossPanelPos");

UI.bossPanel:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.bossPanel:SetBackdropColor(0.04, 0.04, 0.05, 0.94);
UI.bossPanel:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);

-- Top Line: Clock + Phase
UI.clockText = UI.bossPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
UI.clockText:SetPoint("TOPLEFT", UI.bossPanel, "TOPLEFT", 6, -5);
UI.clockText:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE");
UI.clockText:SetTextColor(1, 1, 1);

UI.phaseText = UI.bossPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.phaseText:SetPoint("TOPRIGHT", UI.bossPanel, "TOPRIGHT", -6, -6);
UI.phaseText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.phaseText:SetTextColor(0.1, 0.8, 0.9); -- Cyan

-- Subtitle: Zone name + threat + diff
UI.zoneSubtitle = UI.bossPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.zoneSubtitle:SetPoint("TOPLEFT", UI.clockText, "BOTTOMLEFT", 0, -2);
UI.zoneSubtitle:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -6, 0);
UI.zoneSubtitle:SetFont("Fonts\\ARIALN.TTF", 8, "");
UI.zoneSubtitle:SetJustifyH("LEFT");
UI.zoneSubtitle:SetTextColor(0.8, 0.8, 0.8);

-- Next Boss highlight line
UI.nextBossText = UI.bossPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.nextBossText:SetPoint("TOPLEFT", UI.zoneSubtitle, "BOTTOMLEFT", 0, -3);
UI.nextBossText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.nextBossText:SetTextColor(0.3, 0.95, 0.3); -- Bright Green

-- Mini Table Header: SPAWN | BOSS | COOLDOWN
UI.bTableHeader = CreateFrame("Frame", nil, UI.bossPanel);
UI.bTableHeader:SetPoint("TOPLEFT", UI.nextBossText, "BOTTOMLEFT", 0, -2);
UI.bTableHeader:SetPoint("BOTTOMRIGHT", UI.bossPanel, "TOPRIGHT", -4, -58);

local hSpawn = UI.bTableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hSpawn:SetPoint("LEFT", UI.bTableHeader, "LEFT", 4, 0);
hSpawn:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
hSpawn:SetTextColor(0.8, 0.65, 0.2);
hSpawn:SetText("SPAWN");

local hBoss = UI.bTableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hBoss:SetPoint("LEFT", UI.bTableHeader, "LEFT", 46, 0);
hBoss:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
hBoss:SetTextColor(0.8, 0.65, 0.2);
hBoss:SetText("BOSS");

local hCd = UI.bTableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hCd:SetPoint("RIGHT", UI.bTableHeader, "RIGHT", -4, 0);
hCd:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
hCd:SetTextColor(0.8, 0.65, 0.2);
hCd:SetText("COOLDOWN");

-- Boss schedule timeline rows (Up to 7 rows)
UI.bossRows = {};
for i = 1, 7 do
    local row = CreateFrame("Frame", nil, UI.bossPanel);
    row:SetHeight(13);
    row:SetPoint("TOPLEFT", UI.bTableHeader, "BOTTOMLEFT", 0, -(i - 1) * 14 - 1);
    row:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -4, 0);

    local colTime = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    colTime:SetPoint("LEFT", row, "LEFT", 4, 0);
    colTime:SetWidth(38);
    colTime:SetFont("Fonts\\ARIALN.TTF", 8, "");
    colTime:SetJustifyH("LEFT");
    colTime:SetTextColor(0.4, 0.8, 0.9);
    row.colTime = colTime;

    local colName = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    colName:SetPoint("LEFT", row, "LEFT", 46, 0);
    colName:SetWidth(95);
    colName:SetFont("Fonts\\ARIALN.TTF", 8, "");
    colName:SetJustifyH("LEFT");
    row.colName = colName;

    local colCd = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    colCd:SetPoint("RIGHT", row, "RIGHT", -4, 0);
    colCd:SetWidth(60);
    colCd:SetFont("Fonts\\ARIALN.TTF", 8, "");
    colCd:SetJustifyH("RIGHT");
    row.colCd = colCd;

    row:Hide();
    UI.bossRows[i] = row;
end

-- Guardian / Miniboss Section Header
UI.gTableHeader = CreateFrame("Frame", nil, UI.bossPanel);
UI.gTableHeader:SetHeight(14);
UI.gTableHeader:SetPoint("TOPLEFT", UI.bTableHeader, "BOTTOMLEFT", 0, -7 * 14 - 2);
UI.gTableHeader:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -4, 0);

local hGuard = UI.gTableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hGuard:SetPoint("LEFT", UI.gTableHeader, "LEFT", 4, 0);
hGuard:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
hGuard:SetTextColor(0.95, 0.70, 0.15); -- Gold/Amber
hGuard:SetText("GUARDIAN / MINIBOSS");

local hGStatus = UI.gTableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hGStatus:SetPoint("RIGHT", UI.gTableHeader, "RIGHT", -4, 0);
hGStatus:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
hGStatus:SetTextColor(0.95, 0.70, 0.15);
hGStatus:SetText("STATUS / TIMER");

-- Guardian / Miniboss timeline rows (Up to 6 rows)
UI.guardianRows = {};
for i = 1, 6 do
    local row = CreateFrame("Frame", nil, UI.bossPanel);
    row:SetHeight(13);
    row:SetPoint("TOPLEFT", UI.gTableHeader, "BOTTOMLEFT", 0, -(i - 1) * 14 - 1);
    row:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -4, 0);

    local colName = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    colName:SetPoint("LEFT", row, "LEFT", 4, 0);
    colName:SetWidth(125);
    colName:SetFont("Fonts\\ARIALN.TTF", 8, "");
    colName:SetJustifyH("LEFT");
    row.colName = colName;

    local colStatus = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    colStatus:SetPoint("RIGHT", row, "RIGHT", -4, 0);
    colStatus:SetWidth(85);
    colStatus:SetFont("Fonts\\ARIALN.TTF", 8, "");
    colStatus:SetJustifyH("RIGHT");
    row.colStatus = colStatus;

    row:Hide();
    UI.guardianRows[i] = row;
end

-- Mousewheel Scaling on Boss Panel
UI.bossPanel:EnableMouseWheel(true);
UI.bossPanel:SetScript("OnMouseWheel", function()
    local cur = (AZSHelperDB and AZSHelperDB.bossScale) or 1.0;
    if ( arg1 > 0 ) then cur = cur + 0.05; else cur = cur - 0.05; end
    cur = math.min(1.3, math.max(0.6, cur));
    AZSHelperDB.bossScale = cur;
    UI.bossPanel:SetScale(cur);
end);

UI.bossPanel:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:AddLine("|cffff2020Boss Spawn Timers & Cooldowns|r");
    GameTooltip:AddLine("Scroll mouse wheel to resize.", 1, 1, 1);
    GameTooltip:AddLine("Hold & drag to move window.", 0.7, 0.7, 0.7);
    GameTooltip:Show();
end);
UI.bossPanel:SetScript("OnLeave", function() GameTooltip:Hide(); end);

-- =========================================================================
-- 4. LEFT SIDE: MULTIPLIERS & STATS PANEL
-- =========================================================================
UI.multPanel = CreateFrame("Frame", "AZSHelper_MultipliersPanel", UIParent);
UI.multPanel:SetWidth(125);
UI.multPanel:SetHeight(192);
UI.multPanel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -120);
UI.multPanel:SetFrameStrata("LOW");
UI.multPanel:SetMovable(true);
UI.multPanel:SetClampedToScreen(true);

UI.multPanel:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
UI.multPanel:SetBackdropColor(0.04, 0.04, 0.05, 0.94);
UI.multPanel:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);

-- Top Cyan Accent Line
UI.cyanAccent = UI.multPanel:CreateTexture(nil, "OVERLAY");
UI.cyanAccent:SetPoint("TOPLEFT", UI.multPanel, "TOPLEFT", 2, -2);
UI.cyanAccent:SetPoint("BOTTOMRIGHT", UI.multPanel, "TOPRIGHT", -2, -4);
UI.cyanAccent:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
UI.cyanAccent:SetVertexColor(0.0, 0.85, 0.95, 1.0);

-- Header Text: MULTIPLIERS  9
UI.multTitle = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
UI.multTitle:SetPoint("TOPLEFT", UI.multPanel, "TOPLEFT", 4, -6);
UI.multTitle:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.multTitle:SetText("MULTIPLIERS");

UI.multCount = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.multCount:SetPoint("TOPRIGHT", UI.multPanel, "TOPRIGHT", -4, -6);
UI.multCount:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
UI.multCount:SetText("9");
UI.multCount:SetTextColor(0.1, 0.85, 0.95);

-- Multiplier Rows
UI.statKeys = {
    { label = "Damage:",       field = "dmg",  suffix = "%", isMul = true },
    { label = "Cooldown:",     field = "cd",   suffix = "%", isMul = true },
    { label = "Crit Chance:",  field = "crit", suffix = "%", isPercentRatio = true },
    { label = "Crit Damage:",  field = "cm",   suffix = "%", isCritMul = true },
    { label = "Area:",         field = "area", suffix = "%", isMul = true },
    { label = "Speed:",        field = "spd",  suffix = "%", isMul = true },
    { label = "Armor / DR:",   field = "arm",  suffix = "%", isPercentRatio = true },
    { label = "Lifesteal:",    field = "lch",  suffix = "%", isDirect = true },
    { label = "Pickup:",       field = "pick", suffix = " yd", isDirect = true },
};

UI.multRows = {};
for i = 1, table.getn(UI.statKeys) do
    local r = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    r:SetPoint("TOPLEFT", UI.multTitle, "BOTTOMLEFT", 0, -(i - 1) * 12 - 4);
    r:SetPoint("RIGHT", UI.multPanel, "RIGHT", -4, 0);
    r:SetFont("Fonts\\ARIALN.TTF", 8, "");
    r:SetJustifyH("LEFT");
    UI.multRows[i] = r;
end

-- Highest Crit highlight row at the bottom of the Multipliers panel
local sep = UI.multPanel:CreateTexture(nil, "ARTWORK");
sep:SetPoint("TOPLEFT", UI.multPanel, "TOPLEFT", 4, -125);
sep:SetPoint("BOTTOMRIGHT", UI.multPanel, "TOPRIGHT", -4, -126);
sep:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
sep:SetVertexColor(0.2, 0.2, 0.25, 0.8);

UI.maxCritLabel = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
UI.maxCritLabel:SetPoint("TOPLEFT", sep, "BOTTOMLEFT", 0, -2);
UI.maxCritLabel:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
UI.maxCritLabel:SetText("|cffffd100MAX CRIT:|r");

UI.maxCritVal = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.maxCritVal:SetPoint("TOPRIGHT", sep, "BOTTOMRIGHT", 0, -2);
UI.maxCritVal:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
UI.maxCritVal:SetTextColor(1.0, 0.85, 0.2);
UI.maxCritVal:SetText("0");

UI.maxCritIcon = UI.multPanel:CreateTexture(nil, "ARTWORK");
UI.maxCritIcon:SetWidth(12);
UI.maxCritIcon:SetHeight(12);
UI.maxCritIcon:SetPoint("TOPLEFT", UI.maxCritLabel, "BOTTOMLEFT", 0, -1);
UI.maxCritIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
UI.maxCritIcon:Hide();

UI.maxCritSpellText = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.maxCritSpellText:SetPoint("TOPLEFT", UI.maxCritLabel, "BOTTOMLEFT", 0, -1);
UI.maxCritSpellText:SetPoint("RIGHT", UI.multPanel, "RIGHT", -4, 0);
UI.maxCritSpellText:SetFont("Fonts\\ARIALN.TTF", 7, "");
UI.maxCritSpellText:SetJustifyH("LEFT");
UI.maxCritSpellText:SetTextColor(0.8, 0.8, 0.8);
UI.maxCritSpellText:SetText("-");

UI.critQuoteText = UI.multPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UI.critQuoteText:SetPoint("TOPLEFT", UI.maxCritSpellText, "BOTTOMLEFT", 0, -1);
UI.critQuoteText:SetFont("Fonts\\ARIALN.TTF", 7, "");
UI.critQuoteText:SetTextColor(0.4, 0.9, 0.4);
UI.critQuoteText:SetText("Crit Rate: 0% (0/0)");

-- Dedicated clickable button at the bottom of the panel
local btnDetails = CreateFrame("Button", "AZSHelper_ViewStatsButton", UI.multPanel);
btnDetails:SetPoint("BOTTOMLEFT", UI.multPanel, "BOTTOMLEFT", 4, 4);
btnDetails:SetPoint("BOTTOMRIGHT", UI.multPanel, "BOTTOMRIGHT", -4, 4);
btnDetails:SetHeight(17);
btnDetails:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 8,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
btnDetails:SetBackdropColor(0.08, 0.10, 0.15, 0.95);
btnDetails:SetBackdropBorderColor(0.0, 0.70, 0.85, 0.85); -- Cyan accent border

local btnIcon = btnDetails:CreateTexture(nil, "ARTWORK");
btnIcon:SetWidth(11);
btnIcon:SetHeight(11);
btnIcon:SetPoint("LEFT", btnDetails, "LEFT", 3, 0);
btnIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09");
btnIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

local btnText = btnDetails:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
btnText:SetPoint("LEFT", btnIcon, "RIGHT", 3, 0);
btnText:SetPoint("RIGHT", btnDetails, "RIGHT", -2, 0);
btnText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
btnText:SetTextColor(0.2, 0.85, 1.0);
btnText:SetJustifyH("CENTER");
btnText:SetText("Attack Stats >>");
btnDetails.text = btnText;

local function ToggleStatsTable()
    if ( AZSHelper_StatsTableFrame ) then
        if ( AZSHelper_StatsTableFrame:IsShown() ) then
            AZSHelper_StatsTableFrame:Hide();
            btnText:SetText("Attack Stats >>");
        else
            -- Always dock cleanly to the right of Multipliers panel without overlapping
            AZSHelper_StatsTableFrame:ClearAllPoints();
            AZSHelper_StatsTableFrame:SetPoint("TOPLEFT", UI.multPanel, "TOPRIGHT", 6, 0);
            AZSHelper_StatsTableFrame:Show();
            btnText:SetText("Attack Stats <<");
            if ( AZSHelper.UpdateStatsTable ) then
                AZSHelper:UpdateStatsTable();
            end
        end
    end
end

-- Dock Stats Table to the right of Multipliers panel initially
if ( AZSHelper_StatsTableFrame ) then
    AZSHelper_StatsTableFrame:ClearAllPoints();
    AZSHelper_StatsTableFrame:SetPoint("TOPLEFT", UI.multPanel, "TOPRIGHT", 6, 0);
end

btnDetails:SetScript("OnClick", function()
    ToggleStatsTable();
end);

btnDetails:SetScript("OnEnter", function()
    this:SetBackdropBorderColor(1.0, 0.85, 0.20, 1.0); -- Glow gold
    this:SetBackdropColor(0.12, 0.15, 0.22, 1.0);
    btnText:SetTextColor(1.0, 0.90, 0.30);
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:AddLine("|cff00ccffDetailed Attack & Crit Stats|r");
    GameTooltip:AddLine("Click to open the breakdown table showing damage, DPS, hits & crits for every attack.", 1, 1, 1, 1);
    GameTooltip:Show();
end);

btnDetails:SetScript("OnLeave", function()
    this:SetBackdropBorderColor(0.0, 0.70, 0.85, 0.85);
    this:SetBackdropColor(0.08, 0.10, 0.15, 0.95);
    btnText:SetTextColor(0.2, 0.85, 1.0);
    GameTooltip:Hide();
end);

-- Make Multipliers panel draggable & clickable
local isDraggingMult = false;
UI.multPanel:EnableMouse(true);
UI.multPanel:RegisterForDrag("LeftButton");

UI.multPanel:SetScript("OnDragStart", function()
    isDraggingMult = true;
    this:StartMoving();
end);

UI.multPanel:SetScript("OnDragStop", function()
    this:StopMovingOrSizing();
    isDraggingMult = false;
    local point, _, relPoint, x, y = this:GetPoint();
    if ( AZSHelperDB ) then
        AZSHelperDB.multPanelPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
    if ( AZSHelper_StatsTableFrame and AZSHelper_StatsTableFrame:IsShown() ) then
        AZSHelper_StatsTableFrame:ClearAllPoints();
        AZSHelper_StatsTableFrame:SetPoint("TOPLEFT", this, "TOPRIGHT", 6, 0);
    end
end);

UI.multPanel:SetScript("OnMouseUp", function()
    if ( arg1 == "LeftButton" and not isDraggingMult ) then
        ToggleStatsTable();
    end
end);

UI.multPanel:SetScript("OnEnter", function()
    UI.multPanel:SetBackdropBorderColor(0.0, 0.65, 0.90, 0.95); -- Panel border lights up
    btnDetails:SetBackdropBorderColor(1.0, 0.85, 0.20, 1.0);
    btnText:SetTextColor(1.0, 0.90, 0.30);
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:AddLine("|cff00ccffMultipliers & Crit Statistics|r");
    GameTooltip:AddLine("Click anywhere or click [Attack Stats >>] to open the detailed attack breakdown table.", 1, 1, 1, 1);
    GameTooltip:AddLine("Hold & drag to move window.", 0.7, 0.7, 0.7);
    GameTooltip:Show();
end);

UI.multPanel:SetScript("OnLeave", function()
    UI.multPanel:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);
    btnDetails:SetBackdropBorderColor(0.0, 0.70, 0.85, 0.85);
    btnText:SetTextColor(0.2, 0.85, 1.0);
    GameTooltip:Hide();
end);

-- =========================================================================
-- 5. SQUARE MINIMAP WITH ZONE PILL
-- =========================================================================
function AZSHelper:ApplySquareMinimapStyle()
    if ( Minimap.SetMaskTexture ) then
        Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8");
    end
    Minimap:ClearAllPoints();
    Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -12);
    Minimap:SetWidth(125);
    Minimap:SetHeight(125);

    -- Hide circular artifacts
    local toHide = {
        "MinimapBorder", "MinimapBorderTop", "MinimapZoomIn", "MinimapZoomOut",
        "GameTimeFrame", "MiniMapWorldMapButton", "MiniMapTracking"
    };
    for _, name in pairs(toHide) do
        SafeHide(name);
    end

    -- Sleek 1px black border
    if ( not AZSHelper_MinimapSquareFrame ) then
        local b = CreateFrame("Frame", "AZSHelper_MinimapSquareFrame", Minimap);
        b:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2);
        b:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2);
        b:SetFrameLevel(Minimap:GetFrameLevel() + 5);
        b:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            edgeSize = 10,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        });
        b:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);

        -- Zone Pill at Bottom of Minimap
        local pill = CreateFrame("Frame", nil, Minimap);
        pill:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0);
        pill:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0);
        pill:SetHeight(14);
        pill:SetFrameLevel(Minimap:GetFrameLevel() + 6);
        pill:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = true,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        });
        pill:SetBackdropColor(0.04, 0.04, 0.05, 0.95);

        local zText = pill:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
        zText:SetPoint("CENTER", pill, "CENTER", 0, 0);
        zText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
        AZSHelper.MinimapZonePillText = zText;

        if ( MinimapZoneTextButton ) then MinimapZoneTextButton:Hide(); end

        Minimap:EnableMouseWheel(true);
        Minimap:SetScript("OnMouseWheel", function()
            if ( arg1 > 0 ) then Minimap_ZoomIn(); else Minimap_ZoomOut(); end
        end);
    end
end

-- =========================================================================
-- 6. SLEEK DARK CHAT WINDOW
-- =========================================================================
function AZSHelper:SkinChatWindow()
    if ( not ChatFrame1 ) then return; end
    ChatFrame1:ClearAllPoints();
    ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 14, 26);
    ChatFrame1:SetWidth(380);
    ChatFrame1:SetHeight(130);

    local chatButtons = {
        "ChatFrameMenuButton", "ChatFrame1UpButton", "ChatFrame1DownButton", "ChatFrame1BottomButton"
    };
    for _, btnName in pairs(chatButtons) do
        SafeHide(btnName);
    end

    if ( not AZSHelper_ChatDarkBackdrop ) then
        local bg = CreateFrame("Frame", "AZSHelper_ChatDarkBackdrop", UIParent);
        bg:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -6, 6);
        bg:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 6, -6);
        bg:SetFrameStrata("BACKGROUND");
        bg:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile     = true,
            tileSize = 12,
            edgeSize = 8,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 }
        });
        bg:SetBackdropColor(0.03, 0.03, 0.04, 0.88);
        bg:SetBackdropBorderColor(0.10, 0.10, 0.12, 0.95);
    end

    ChatFrame1:EnableMouseWheel(true);
    ChatFrame1:SetScript("OnMouseWheel", function()
        if ( arg1 > 0 ) then
            if ( IsShiftKeyDown() ) then this:ScrollToTop(); else this:ScrollUp(); end
        else
            if ( IsShiftKeyDown() ) then this:ScrollToBottom(); else this:ScrollDown(); end
        end
    end);
    ChatFrame1:SetFont("Fonts\\ARIALN.TTF", 11, "");
end

-- =========================================================================
-- 7. REFRESH & TICK SUB-FUNCTIONS
--    Separated to strictly respect Lua 5.0's 32-upvalue limit per function.
-- =========================================================================

-- A. Update Bottom Datatext Bar & XP Bar
local function UpdateBottomBar()
    local lvl = (AZS_RUN and AZS_RUN.lvl) or UnitLevel("player") or 1;
    local xp = (AZS_RUN and AZS_RUN.xp) or 0;
    local xpn = (AZS_RUN and AZS_RUN.xpn) or 1;
    local xpPct = (xpn > 0) and math.floor((xp / xpn) * 100) or 0;
    local kills = (AZS_RUN and AZS_RUN.kills) or 0;
    local gold = (AZS_RUN and AZS_RUN.gold) or 0;
    local chest = (AZS_RUN and AZS_RUN.chest) or 20;
    local lives = (AZS_RUN and AZS_RUN.lives) or 0;
    local rr = (AZS_RUN and AZS_RUN.rr) or 0;
    local dealt = (AZS_RUN and AZS_RUN.dealt) or 0;
    local fps = math.floor(GetFramerate() or 60);

    UI.bottomText:SetText(string.format("LVL |cffffffff%d|r   XP |cff00ccff%d%%|r   KILLS |cffffffff%d|r   GOLD |cff00ccff%s|r   CHEST |cff00ccff%dg|r   LIVES |cffffffff%d|r   RR |cffffffff%d|r   DMG |cffffffff%s|r   FPS |cff00ccff%d|r",
        lvl, xpPct, kills, AZSHelper:FormatNumber(gold), chest, lives, rr, AZSHelper:FormatNumber(dealt), fps));

    UI.xpBar:SetMinMaxValues(0, xpn);
    UI.xpBar:SetValue(xp);
    UI.xpText:SetText(string.format("%d%%  (%s / %s XP)", xpPct, AZSHelper:FormatNumber(xp), AZSHelper:FormatNumber(xpn)));
end

-- B. Update Centered Player Unit Frame & Action Button Overlays
local function UpdatePlayerFrame()
    local lvl = (AZS_RUN and AZS_RUN.lvl) or UnitLevel("player") or 1;
    local hp = (AZS_RUN and AZS_RUN.hp) or UnitHealth("player") or 100;
    local hpm = (AZS_RUN and AZS_RUN.hpm) or UnitHealthMax("player") or 100;
    if ( hpm <= 0 ) then hpm = 1; end
    UI.healthBar:SetMinMaxValues(0, hpm);
    UI.healthBar:SetValue(hp);

    -- Live Class Color Update for Health Bar
    local cCol = GetPlayerClassColor();
    UI.healthBar:SetStatusBarColor(cCol.r, cCol.g, cCol.b, 1.0);

    local hpPct = math.floor((hp / hpm) * 100);
    UI.pNameText:SetText(UnitName("player") or "Player");
    UI.pLevelBadge:SetText(tostring(lvl));
    UI.pHpValueText:SetText(AZSHelper:FormatNumber(hp));
    UI.pHpPctText:SetText(string.format("%d%%", hpPct));

    if ( UI.playerPortrait ) then
        SetPortraitTexture(UI.playerPortrait, "player");
        UI.playerPortrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);
    end

    local mana = UnitMana("player") or 0;
    local manaMax = UnitManaMax("player") or 100;
    if ( manaMax <= 0 ) then manaMax = 100; end
    UI.powerBar:SetMinMaxValues(0, manaMax);
    UI.powerBar:SetValue(mana);

    -- Dynamic Power Color (Mana = Blue, Rage = Red, Energy = Yellow)
    local pType = UnitPowerType("player") or 0;
    if ( pType == 1 ) then
        UI.powerBar:SetStatusBarColor(0.85, 0.15, 0.15, 1.0); -- Rage
    elseif ( pType == 3 ) then
        UI.powerBar:SetStatusBarColor(0.95, 0.85, 0.10, 1.0); -- Energy
    else
        UI.powerBar:SetStatusBarColor(0.15, 0.40, 0.90, 1.0); -- Mana
    end

    -- Proc Bar (e.g. Blood Fury / Class Proc)
    if ( AZS_RUN and AZS_RUN.proc and AZS_RUN.proc ~= "" and AZS_RUN.pv and AZS_RUN.pm and AZS_RUN.pm > 0 ) then
        UI.procBar:SetMinMaxValues(0, AZS_RUN.pm);
        UI.procBar:SetValue(AZS_RUN.pv);
        UI.procText:SetText(string.upper(string.gsub(AZS_RUN.proc, "_", " ")));
        UI.procTimeText:SetText(string.format("%.1fs", AZS_RUN.pv));
        UI.procBar:Show();
    else
        UI.procBar:Hide();
    end

    -- Action Button Cooldown Overlays from AZS_SPELLS
    if ( AZS_SPELLS ) then
        local totalSpells = table.getn(AZS_SPELLS);
        local normalCount = math.min(6, math.max(0, totalSpells - 1));

        for i = 1, 6 do
            local btn = getglobal("ActionButton" .. i);
            if ( btn and btn.cdText ) then
                local sp = (i <= normalCount) and AZS_SPELLS[i] or nil;
                if ( sp and sp.cd and sp.cd >= 1.5 ) then
                    if ( sp.cd >= 60 ) then
                        btn.cdText:SetText(string.format("%dm", math.ceil(sp.cd / 60)));
                    else
                        btn.cdText:SetText(string.format("%d", math.ceil(sp.cd)));
                    end
                    btn.cdText:Show();
                else
                    btn.cdText:SetText("");
                    btn.cdText:Hide();
                end
            end
        end

        -- Racial Ability Cooldown & Icon (Last entry in AZS_SPELLS)
        local racialSlot = UI.racialSlot or 12;
        local rBtn = UI.racialBtn or getglobal("ActionButton" .. racialSlot);
        if ( rBtn and totalSpells > 0 ) then
            local rSp = AZS_SPELLS[totalSpells];
            if ( rSp ) then
                local rIcon = getglobal("ActionButton" .. racialSlot .. "Icon");
                if ( rIcon and rSp.icon and (not rIcon:GetTexture() or rIcon:GetTexture() == "") ) then
                    rIcon:SetTexture(rSp.icon);
                    rIcon:Show();
                end

                if ( rBtn.cdText ) then
                    if ( rSp.cd and rSp.cd >= 1.5 ) then
                        if ( rSp.cd >= 60 ) then
                            rBtn.cdText:SetText(string.format("%dm", math.ceil(rSp.cd / 60)));
                        else
                            rBtn.cdText:SetText(string.format("%d", math.ceil(rSp.cd)));
                        end
                        rBtn.cdText:Show();
                    else
                        rBtn.cdText:SetText("");
                        rBtn.cdText:Hide();
                    end
                end
            end
        end
    end
end

-- C. Update Right-Side Live Boss Unit Frame
local function UpdateBossFrame()
    local lvl = (AZS_RUN and AZS_RUN.lvl) or UnitLevel("player") or 1;

    if ( AZSHelper.TestBossPreview ) then
        UI.bossHealthBar:SetMinMaxValues(0, 100);
        UI.bossHealthBar:SetValue(72);
        UI.bossHealthBar:SetStatusBarColor(0.85, 0.15, 0.15, 1.0);
        UI.bossBadge:SetText("5+");
        UI.bossNameText:SetText("Schmerbauch");
        UI.bossHpPctText:SetText("72%");
        UI.bossHpValueText:SetText("4808");
        if ( UI.bossPortrait ) then
            UI.bossPortrait:SetTexture("Interface\\Icons\\Ability_Hunter_Pet_Boar");
            UI.bossPortrait:SetTexCoord(0.08, 0.92, 0.08, 0.92);
        end
        UI.centerBoss:Show();
        return;
    end

    local activeBoss = nil;
    local bosses = (AZS_GetBosses and AZS_GetBosses()) or {};
    if ( table.getn(bosses) > 0 ) then
        activeBoss = bosses[1];
    end

    local activeGuardian = nil;
    if ( not activeBoss ) then
        local guardians = (AZS_GetGuardians and AZS_GetGuardians()) or {};
        for i = 1, table.getn(guardians) do
            local g = guardians[i];
            if ( g and g.awake and g.hp and g.hp > 0 ) then
                activeGuardian = g;
                break;
            end
        end
    end

    if ( activeBoss ) then
        local bhp = activeBoss.hp or 1;
        local bhpm = activeBoss.hpm or 1;
        if ( bhpm <= 0 ) then bhpm = 1; end
        local bPct = math.floor((bhp / bhpm) * 100);

        UI.bossHealthBar:SetMinMaxValues(0, bhpm);
        UI.bossHealthBar:SetValue(bhp);

        if ( activeBoss.final == 1 or activeBoss.final == true ) then
            UI.bossHealthBar:SetStatusBarColor(0.85, 0.20, 0.85, 1.0); -- Magenta for final boss
            UI.bossBadge:SetText("Boss+");
        else
            UI.bossHealthBar:SetStatusBarColor(0.85, 0.15, 0.15, 1.0); -- Crimson red
            UI.bossBadge:SetText(tostring(lvl) .. "+");
        end

        UI.bossNameText:SetText(activeBoss.name or "Boss");
        UI.bossHpPctText:SetText(string.format("%d%%", bPct));
        UI.bossHpValueText:SetText(AZSHelper:FormatNumber(bhp));
        if ( UI.bossPortrait ) then
            if ( UnitExists("target") ) then
                SetPortraitTexture(UI.bossPortrait, "target");
                UI.bossPortrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);
            else
                UI.bossPortrait:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01");
                UI.bossPortrait:SetTexCoord(0.08, 0.92, 0.08, 0.92);
            end
        end
        UI.centerBoss:Show();
    elseif ( activeGuardian ) then
        local ghp = activeGuardian.hp or 1;
        local ghpm = activeGuardian.hpm or 1;
        if ( ghpm <= 0 ) then ghpm = 1; end
        local gPct = math.floor((ghp / ghpm) * 100);

        UI.bossHealthBar:SetMinMaxValues(0, ghpm);
        UI.bossHealthBar:SetValue(ghp);
        UI.bossHealthBar:SetStatusBarColor(0.90, 0.55, 0.10, 1.0);
        UI.bossBadge:SetText("Guardian+");
        UI.bossNameText:SetText(activeGuardian.name or "Guardian");
        UI.bossHpPctText:SetText(string.format("%d%%", gPct));
        UI.bossHpValueText:SetText(AZSHelper:FormatNumber(ghp));
        if ( UI.bossPortrait ) then
            if ( UnitExists("target") ) then
                SetPortraitTexture(UI.bossPortrait, "target");
                UI.bossPortrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);
            else
                UI.bossPortrait:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01");
                UI.bossPortrait:SetTexCoord(0.08, 0.92, 0.08, 0.92);
            end
        end
        UI.centerBoss:Show();
    elseif ( UnitExists("target") and not UnitIsFriend("player", "target") and not UnitIsDead("target") ) then
        local thp = UnitHealth("target") or 0;
        local thpm = UnitHealthMax("target") or 100;
        if ( thpm <= 0 ) then thpm = 100; end
        local tPct = math.floor((thp / thpm) * 100);
        local tLvl = UnitLevel("target") or lvl;
        if ( tLvl < 0 ) then tLvl = "??"; end

        UI.bossHealthBar:SetMinMaxValues(0, thpm);
        UI.bossHealthBar:SetValue(thp);
        UI.bossHealthBar:SetStatusBarColor(0.85, 0.15, 0.15, 1.0);
        UI.bossBadge:SetText(tostring(tLvl) .. "+");
        UI.bossNameText:SetText(UnitName("target") or "Target");
        UI.bossHpPctText:SetText(string.format("%d%%", tPct));
        UI.bossHpValueText:SetText(AZSHelper:FormatNumber(thp));
        if ( UI.bossPortrait ) then
            SetPortraitTexture(UI.bossPortrait, "target");
            UI.bossPortrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);
        end
        UI.centerBoss:Show();
    else
        UI.centerBoss:Hide();
    end
end

-- C2. Update Multi-Boss & Miniboss Encounter Bars (Shows HP bar for every active boss/awake guardian)
local function UpdateEncounterBars()
    local activeEnemies = {};

    -- 1. All bosses alive right now
    local bosses = (AZS_GetBosses and AZS_GetBosses()) or {};
    for i = 1, table.getn(bosses) do
        local b = bosses[i];
        if ( b and b.hp and b.hp > 0 ) then
            table.insert(activeEnemies, {
                id      = b.id,
                name    = b.name or "Boss",
                hp      = b.hp,
                hpm     = (b.hpm and b.hpm > 0) and b.hpm or 100,
                kind    = (b.final == 1 or b.final == true) and "final" or "boss",
                enraged = b.enraged or false,
            });
        end
    end

    -- 2. All guardians currently awake / in fight
    local guardians = (AZS_GetGuardians and AZS_GetGuardians()) or {};
    for i = 1, table.getn(guardians) do
        local g = guardians[i];
        if ( g and g.awake and g.hp and g.hp > 0 ) then
            local found = false;
            for k = 1, table.getn(activeEnemies) do
                if ( activeEnemies[k].name == g.name ) then found = true; break; end
            end
            if ( not found ) then
                table.insert(activeEnemies, {
                    id   = g.id,
                    name = g.name or "Guardian",
                    hp   = g.hp,
                    hpm  = (g.hpm and g.hpm > 0) and g.hpm or 100,
                    kind = "guardian",
                });
            end
        end
    end

    -- 3. Fallback from AZS_UNITS if GetBosses/GetGuardians were empty
    if ( table.getn(activeEnemies) == 0 and AZS_UNITS ) then
        for i = 1, table.getn(AZS_UNITS) do
            local u = AZS_UNITS[i];
            if ( u and u.hp and u.hp > 0 ) then
                if ( u.kind == "final" or u.kind == "boss" or (u.kind == "guardian" and u.state == 1) ) then
                    table.insert(activeEnemies, {
                        id      = u.id,
                        name    = u.name or "Enemy",
                        hp      = u.hp,
                        hpm     = (u.hpm and u.hpm > 0) and u.hpm or 100,
                        kind    = u.kind,
                        enraged = (u.kind ~= "guardian" and u.state == 1),
                    });
                end
            end
        end
    end

    local numActive = table.getn(activeEnemies);
    local maxBars = table.getn(UI.encounterBars);
    if ( numActive > 0 ) then
        UI.encounterContainer:Show();
        UI.encounterContainer:SetHeight(math.min(maxBars, numActive) * 26 + 6);
        for i = 1, maxBars do
            local bar = UI.encounterBars[i];
            if ( i <= numActive ) then
                local e = activeEnemies[i];
                local pct = math.floor((e.hp / e.hpm) * 100);
                bar.statusBar:SetMinMaxValues(0, e.hpm);
                bar.statusBar:SetValue(e.hp);

                local tag = "";
                if ( e.kind == "final" ) then
                    bar.statusBar:SetStatusBarColor(0.85, 0.20, 0.85, 1.0); -- Magenta
                    bar:SetBackdropBorderColor(0.95, 0.30, 0.95, 1.0);
                    tag = "|cffff44ff👑 [FINAL BOSS] |r";
                elseif ( e.kind == "boss" ) then
                    bar.statusBar:SetStatusBarColor(0.88, 0.15, 0.15, 1.0); -- Crimson
                    bar:SetBackdropBorderColor(1.00, 0.25, 0.25, 1.0);
                    tag = e.enraged and "|cffff2020☠ [BOSS - ENRAGED] |r" or "|cffff2020☠ [BOSS] |r";
                else
                    -- Guardian / Miniboss
                    bar.statusBar:SetStatusBarColor(0.95, 0.60, 0.10, 1.0); -- Amber
                    bar:SetBackdropBorderColor(1.00, 0.75, 0.15, 1.0);
                    tag = "|cffffcc00★ [GUARDIAN] |r";
                end

                bar.nameText:SetText(tag .. "|cffffffff" .. e.name .. "|r");
                bar.hpText:SetText(string.format("%s (%d%%)", AZSHelper:FormatNumber(e.hp), pct));
                bar:Show();
            else
                bar:Hide();
            end
        end
    else
        UI.encounterContainer:Hide();
        for i = 1, maxBars do
            if ( UI.encounterBars[i] ) then
                UI.encounterBars[i]:Hide();
            end
        end
    end
end

-- D. Update Boss Schedule Panel & Guardian Timers
local function UpdateBossSchedule()
    local t = (AZS_GetRunTime and AZS_GetRunTime()) or (AZS_RUN and AZS_RUN.t) or 0;
    local zLen = (AZS_GetRunLength and AZS_GetRunLength()) or (AZS_ZONE and AZS_ZONE.len) or 960;
    local ph = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph) or "PLAYING";
    UI.clockText:SetText(string.format("%s / %s", AZSHelper:FormatTime(t), AZSHelper:FormatTime(zLen)));
    UI.phaseText:SetText(string.upper(ph));

    local zName = (AZS_ZONE and AZS_ZONE.zname) or "Azeroth";
    local zSub = (AZS_ZONE and AZS_ZONE.zsub) or "The Threat";
    local zDiff = (AZS_ZONE and AZS_ZONE.diff) or 1.0;
    UI.zoneSubtitle:SetText(string.format("%s - %s (Diff %.2f)", zName, zSub, zDiff));

    -- Next Boss line & Audio/Visual alert
    local upcoming = (AZS_GetUpcomingBosses and AZS_GetUpcomingBosses()) or {};
    local nextB = upcoming[1];
    local bossesAlive = (AZS_GetBosses and AZS_GetBosses()) or {};
    local numAlive = table.getn(bossesAlive);

    if ( numAlive > 0 ) then
        local bName = bossesAlive[1].name or "Boss";
        UI.nextBossText:SetText(string.format("|cffff2020BOSS ACTIVE: %s!|r", bName));
    elseif ( nextB ) then
        local left = math.max(0, nextB.left or 0);
        local color = (left <= 15) and "|cffff4444" or "|cff55ff55";
        UI.nextBossText:SetText(string.format("Next: %s %sin %s|r", nextB.name, color, AZSHelper:FormatTime(left)));
    elseif ( AZS_RUN and AZS_RUN.endl == 1 and AZS_RUN.nb and AZS_RUN.nb >= 0 ) then
        UI.nextBossText:SetText(string.format("Endless Boss: |cff55ff55in %s|r", AZSHelper:FormatTime(AZS_RUN.nb)));
    else
        UI.nextBossText:SetText("Next: -");
    end

    -- Populate Boss List using AZS_SCHEDULE (or fallback to upcoming)
    local schedule = AZS_SCHEDULE or {};
    local numSched = table.getn(schedule);

    if ( numSched > 0 ) then
        for i = 1, 7 do
            local row = UI.bossRows[i];
            if ( i <= numSched ) then
                local b = schedule[i];
                local atStr = AZSHelper:FormatTime(b.at or 0);
                row.colTime:SetText(atStr);

                -- Boss Name (Final boss in purple #ff44ff)
                if ( b.final == 1 or b.final == true ) then
                    row.colName:SetText("|cffff44ff" .. (b.name or "Boss") .. "|r");
                else
                    if ( b.state == "dead" ) then
                        row.colName:SetText("|cff777777" .. (b.name or "Boss") .. "|r");
                    else
                        row.colName:SetText("|cffffffff" .. (b.name or "Boss") .. "|r");
                    end
                end

                -- Cooldown / Status
                if ( b.state == "dead" ) then
                    row.colCd:SetText("|cff666666[DEAD ✓]|r");
                elseif ( b.state == "up" ) then
                    row.colCd:SetText("|cffff2020[ACTIVE!]|r");
                else
                    local left = math.max(0, (b.at or 0) - t);
                    local inStr = AZSHelper:FormatTime(left);
                    if ( left <= 30 ) then
                        row.colCd:SetText("|cffffcc00in " .. inStr .. "|r");
                    else
                        row.colCd:SetText("|cffaaaaaain " .. inStr .. "|r");
                    end
                end
                row:Show();
            else
                row:Hide();
            end
        end
    else
        for i = 1, 7 do
            local row = UI.bossRows[i];
            if ( i <= table.getn(upcoming) ) then
                local b = upcoming[i];
                local atStr = AZSHelper:FormatTime(b.at or 0);
                local left = math.max(0, b.left or 0);
                row.colTime:SetText(atStr);
                if ( b.final ) then
                    row.colName:SetText("|cffff44ff" .. (b.name or "Boss") .. "|r");
                else
                    row.colName:SetText("|cffffffff" .. (b.name or "Boss") .. "|r");
                end
                row.colCd:SetText(string.format("|cffaaaaaain %s|r", AZSHelper:FormatTime(left)));
                row:Show();
            else
                row:Hide();
            end
        end
    end

    -- Count visible bosses for dynamic layout
    local visibleBosses = 0;
    for i = 1, 7 do
        if ( UI.bossRows[i] and UI.bossRows[i]:IsShown() ) then
            visibleBosses = visibleBosses + 1;
        end
    end

    -- Update Guardian / Miniboss Schedule & Respawn Timers (Supports up to 6 guardians)
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
    local guardians = (AZS_GetGuardians and AZS_GetGuardians()) or {};
    local numLairs = table.getn(lairs);
    local maxGRows = table.getn(UI.guardianRows);
    local visibleGuards = 0;

    if ( numLairs > 0 ) then
        UI.gTableHeader:Show();
        UI.gTableHeader:ClearAllPoints();
        UI.gTableHeader:SetPoint("TOPLEFT", UI.bTableHeader, "BOTTOMLEFT", 0, -(math.max(1, visibleBosses) * 14 + 4));
        UI.gTableHeader:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -4, 0);

        for i = 1, maxGRows do
            local row = UI.guardianRows[i];
            if ( i <= numLairs ) then
                local l = lairs[i];
                local gName = l.name or ("Guardian #" .. i);
                if ( l.state == "awake" ) then
                    local hpStr = "";
                    for g = 1, table.getn(guardians) do
                        if ( guardians[g] and guardians[g].name == gName and guardians[g].hp and guardians[g].hpm ) then
                            local pct = math.floor((guardians[g].hp / guardians[g].hpm) * 100);
                            hpStr = string.format(" (%d%%)", pct);
                            break;
                        end
                    end
                    row.colName:SetText("|cffff9900" .. gName .. "|r" .. hpStr);
                    row.colStatus:SetText("|cffff2020[COMBAT!]|r");
                elseif ( l.state == "asleep" ) then
                    row.colName:SetText("|cffffffff" .. gName .. "|r");
                    row.colStatus:SetText("|cff55ff55[READY]|r");
                else
                    local left = l.left or 0;
                    row.colName:SetText("|cff888888" .. gName .. " (empty)|r");
                    if ( left > 0 ) then
                        row.colStatus:SetText(string.format("|cffffaa00Spawns in %s|r", AZSHelper:FormatTime(left)));
                    else
                        row.colStatus:SetText("|cffffff00[SPAWNING...]|r");
                    end
                end
                row:Show();
                visibleGuards = visibleGuards + 1;
            else
                row:Hide();
            end
        end
    else
        local numGuards = table.getn(guardians);
        if ( numGuards > 0 ) then
            UI.gTableHeader:Show();
            UI.gTableHeader:ClearAllPoints();
            UI.gTableHeader:SetPoint("TOPLEFT", UI.bTableHeader, "BOTTOMLEFT", 0, -(math.max(1, visibleBosses) * 14 + 4));
            UI.gTableHeader:SetPoint("RIGHT", UI.bossPanel, "RIGHT", -4, 0);

            for i = 1, maxGRows do
                local row = UI.guardianRows[i];
                if ( i <= numGuards ) then
                    local g = guardians[i];
                    local pct = (g.hp and g.hpm and g.hpm > 0) and math.floor((g.hp / g.hpm) * 100) or 100;
                    row.colName:SetText("|cffff9900" .. (g.name or "Guardian") .. "|r (" .. pct .. "%)");
                    row.colStatus:SetText(g.awake and "|cffff2020[COMBAT!]|r" or "|cff55ff55[READY]|r");
                    row:Show();
                    visibleGuards = visibleGuards + 1;
                else
                    row:Hide();
                end
            end
        else
            UI.gTableHeader:Hide();
            for i = 1, maxGRows do
                if ( UI.guardianRows[i] ) then UI.guardianRows[i]:Hide(); end
            end
        end
    end

    -- Dynamically fit bossPanel height so all rows fit perfectly without clipping
    local desiredH = 58 + 14 + (visibleBosses * 14) + (visibleGuards > 0 and (16 + visibleGuards * 14) or 6);
    if ( desiredH < 120 ) then desiredH = 120; end
    UI.bossPanel:SetHeight(desiredH);
end

-- E. Update Multipliers & Highest Crit
local function UpdateMultipliers()
    if ( AZS_STATS ) then
        for i = 1, table.getn(UI.statKeys) do
            local cfg = UI.statKeys[i];
            local raw = AZS_STATS[cfg.field];
            local row = UI.multRows[i];
            if ( raw ~= nil ) then
                local str = "";
                if ( cfg.isMul ) then
                    local val = (raw - 1.0) * 100;
                    str = (val >= 0) and string.format("+%.0f%%", val) or string.format("%.0f%%", val);
                elseif ( cfg.isCritMul ) then
                    str = string.format("%.0f%%", raw * 100);
                elseif ( cfg.field == "crit" or cfg.field == "arm" or cfg.isPercentRatio ) then
                    str = string.format("%.1f%%", raw * 100);
                elseif ( cfg.field == "lch" ) then
                    str = string.format("%.1f%%", raw);
                else
                    str = tostring(raw) .. cfg.suffix;
                end
                row:SetText(string.format("%-14s |cffffffff%s|r", cfg.label, str));
            end
        end
    end

    UI.maxCritVal:SetText(AZSHelper:FormatNumber(AZSHelper.OverallMaxCrit or 0));
    local spName = AZSHelper.OverallMaxCritSpell or "-";
    UI.maxCritSpellText:SetText(spName);
    if ( spName and spName ~= "-" and AZSHelper.GetSpellIcon and UI.maxCritIcon ) then
        UI.maxCritIcon:SetTexture(AZSHelper:GetSpellIcon(spName));
        UI.maxCritIcon:Show();
        UI.maxCritSpellText:ClearAllPoints();
        UI.maxCritSpellText:SetPoint("LEFT", UI.maxCritIcon, "RIGHT", 3, 0);
        UI.maxCritSpellText:SetPoint("RIGHT", UI.multPanel, "RIGHT", -4, 0);
    elseif ( UI.maxCritIcon ) then
        UI.maxCritIcon:Hide();
        UI.maxCritSpellText:ClearAllPoints();
        UI.maxCritSpellText:SetPoint("TOPLEFT", UI.maxCritLabel, "BOTTOMLEFT", 0, -1);
        UI.maxCritSpellText:SetPoint("RIGHT", UI.multPanel, "RIGHT", -4, 0);
    end

    local totalH = AZSHelper.TotalHits or 0;
    local totalC = AZSHelper.TotalCrits or 0;
    local q = (totalH > 0) and math.floor((totalC / totalH) * 100) or 0;
    UI.critQuoteText:SetText(string.format("Crit Rate: %d%% (%d/%d)", q, totalC, totalH));
end

-- =========================================================================
-- 8. REFRESH & TICK LOOP (Updates all panels from AZS state)
-- =========================================================================
local updateFrame = CreateFrame("Frame", "AZSHelper_ThemeUpdateFrame");
local updateElapsed = 0;

updateFrame:SetScript("OnUpdate", function()
    updateElapsed = updateElapsed + arg1;
    if ( updateElapsed < 0.1 ) then return; end
    updateElapsed = 0;

    HideDefaultBlizzardFrames();
    UpdateBottomBar();
    UpdatePlayerFrame();
    UpdateBossFrame();
    UpdateEncounterBars();
    UpdateBossSchedule();
    UpdateMultipliers();

    if ( AZSHelper.MinimapZonePillText ) then
        local zName = (AZS_ZONE and AZS_ZONE.zname) or "Azeroth";
        AZSHelper.MinimapZonePillText:SetText(GetMinimapZoneText() or zName);
    end
end);

-- Setup on Player Entering World & immediate load
local function InitTheme()
    HideDefaultBlizzardFrames();
    SetupActionButtons();
    if ( AZSHelper.ApplyMaxCameraDistance ) then
        AZSHelper:ApplyMaxCameraDistance();
    end
    local cCol = GetPlayerClassColor();
    if ( UI.healthBar ) then
        UI.healthBar:SetStatusBarColor(cCol.r, cCol.g, cCol.b, 1.0);
    end
    AZSHelper:ApplySquareMinimapStyle();
    AZSHelper:SkinChatWindow();
    if ( AZSHelperDB and AZSHelperDB.centerHudPos ) then
        AZSHelper:RestorePosition(UI.skillsContainer, AZSHelperDB.centerHudPos);
    end
    if ( AZSHelperDB and AZSHelperDB.multPanelPos ) then
        AZSHelper:RestorePosition(UI.multPanel, AZSHelperDB.multPanelPos);
    end
    if ( AZSHelperDB and AZSHelperDB.bossPanelPos ) then
        AZSHelper:RestorePosition(UI.bossPanel, AZSHelperDB.bossPanelPos);
    end
    if ( AZSHelperDB and AZSHelperDB.encounterBarsPos ) then
        AZSHelper:RestorePosition(UI.encounterContainer, AZSHelperDB.encounterBarsPos);
    end
    if ( AZSHelperDB and AZSHelperDB.bossScale ) then
        UI.bossPanel:SetScale(AZSHelperDB.bossScale);
    end
end

InitTheme();

local themeInit = CreateFrame("Frame", "AZSHelper_ThemeInit");
themeInit:RegisterEvent("PLAYER_ENTERING_WORLD");
themeInit:RegisterEvent("VARIABLES_LOADED");
themeInit:RegisterEvent("PLAYER_TARGET_CHANGED");
themeInit:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
themeInit:SetScript("OnEvent", function()
    if ( event == "PLAYER_TARGET_CHANGED" ) then
        HideDefaultBlizzardFrames();
    elseif ( event == "ACTIONBAR_SLOT_CHANGED" ) then
        SetupActionButtons();
    else
        InitTheme();
    end
end);
