-- BordoUI: Meta Build Advisor & Card Choice Highlighter
-- Provides an in-game meta build guide for all 9 classes and animated card glowing during level-up choices.

BordoUI = BordoUI or {};

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local BORDER = "Interface\\Tooltips\\UI-Tooltip-Border";
local ACTION_BORDER = "Interface\\Buttons\\UI-ActionButton-Border";

local currentClass = "HUNTER";
local currentBuildIdx = 1;
local manualChoiceHUD = false;

-- AUI table holds all UI frame references to prevent Lua 5.0 32-upvalue limit overflow
local AUI = {};
BordoUI_AdvisorUI = AUI;

local SCHOOL_COLORS = {
    Holy     = { 1.00, 0.78, 0.15 },
    Fire     = { 1.00, 0.50, 0.10 },
    Frost    = { 0.30, 0.72, 1.00 },
    Nature   = { 0.30, 0.88, 0.25 },
    Shadow   = { 0.66, 0.38, 1.00 },
    Arcane   = { 1.00, 0.40, 0.85 },
    Physical = { 0.95, 0.27, 0.24 },
};

local QUALITY_COLORS = {
    [0] = { 0.62, 0.62, 0.62 }, -- Poor
    [1] = { 1.00, 1.00, 1.00 }, -- Common
    [2] = { 0.12, 1.00, 0.00 }, -- Uncommon
    [3] = { 0.00, 0.44, 0.87 }, -- Rare
    [4] = { 0.64, 0.21, 0.93 }, -- Epic
    [5] = { 1.00, 0.50, 0.00 }, -- Legendary
};

local QUALITY_HEX = {
    [0] = "9d9d9d",
    [1] = "ffffff",
    [2] = "1eff00",
    [3] = "0070dd",
    [4] = "a335ee",
    [5] = "ff8000",
};

local function NormalizeIconPath(icon)
    if not icon or icon == "" then return "Interface\\Icons\\INV_Misc_QuestionMark"; end
    local s = tostring(icon);
    if string.find(s, "^InterfaceIcons") then
        s = "Interface\\Icons\\" .. string.sub(s, 15);
    elseif string.find(s, "^Interface[\\/]Icons[\\/]") then
        s = "Interface\\Icons\\" .. string.sub(s, 17);
    end
    return s;
end

local function GetCustomBuild(classKey, buildIdx)
    local cUpper = string.upper(classKey or currentClass);
    local idx = tonumber(buildIdx) or currentBuildIdx or 1;
    if idx < 1 or idx > 3 then idx = 1; end
    local builds = BordoUI_GetClassBuilds(cUpper);
    local cb = builds and builds[idx];
    if cb and cb.jewelry then
        for k, v in pairs(cb.jewelry) do
            if v then
                if v.icon then
                    v.icon = NormalizeIconPath(v.icon);
                end
                if k == "neck" then
                    v.slotType = "NECK";
                    if (not v.spell or v.spell == "") and v.name and string.find(v.name, ":") then
                        local _, _, sp = string.find(v.name, ":%s*([^:]+)");
                        if sp then
                            v.spell = string.gsub(sp, "%s+[IVXLCDMivxlcdm%d]+$", "");
                        end
                    end
                    local nName = v.name or "";
                    local nSpell = v.spell or "";
                    if nName == "Amulet of the Inferno: Exorcism" or nSpell == "Exorcism" or string.find(nName, "Exorcism") then
                        v.name = "Eye of the Splitting Sky: Exorcism";
                        v.icon = "Interface\\Icons\\INV_Jewelry_Necklace_16";
                        v.benefit = "+1 Tgt, +24% Dmg, Leap";
                        v.desc = "Legendary amulet - remakes Exorcism\nEquip: Exorcism strikes 1 more target.\nEquip: Increases the damage of Exorcism by 24%.\nEquip: Exorcism's hits leap to 2 more enemies for 36%.";
                        v.spell = "Exorcism";
                        v.quality = 5;
                    end
                elseif k == "ring1" or k == "ring2" then
                    v.slotType = "RING";
                else
                    v.slotType = "TRINKET";
                end
            end
        end
    end
    return cb;
end

local function GetCurrentAdvisorBuild()
    return GetCustomBuild(currentClass, currentBuildIdx);
end

local OpenCatalogDrawer;
local CloseCatalogDrawer;
local UpdateCatalogDrawerList;
local catalogDrawer;
local catalogScrollOffset = 0;

-- Forward declarations
local RefreshChoiceHUD;
local choiceHUD;

-- ----------------------------------------------------------------------------
-- Main Advisor Frame
-- ----------------------------------------------------------------------------
local advisorFrame = CreateFrame("Frame", "BordoUI_BuildAdvisorFrame", UIParent); AUI.advisorFrame = advisorFrame;
advisorFrame:SetWidth(800);
advisorFrame:SetHeight(620);
advisorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
advisorFrame:SetFrameStrata("DIALOG");
advisorFrame:SetFrameLevel(50);
advisorFrame:SetMovable(true);
advisorFrame:EnableMouse(true);
advisorFrame:RegisterForDrag("LeftButton");
advisorFrame:SetClampedToScreen(true);
advisorFrame:Hide();

advisorFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
});
advisorFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.88);
advisorFrame:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);

advisorFrame:SetScript("OnDragStart", function()
    if IsAltKeyDown() then
        this:StartMoving();
    end
end);

advisorFrame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing();
    local pt, rel, relPt, x, y = this:GetPoint();
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.buildAdvisorPos = { pt = pt, relPt = relPt, x = x, y = y };
end);

-- Title Bar
local titleBar = CreateFrame("Frame", nil, advisorFrame);
titleBar:SetHeight(28);
titleBar:SetPoint("TOPLEFT", advisorFrame, "TOPLEFT", 0, 0);
titleBar:SetPoint("TOPRIGHT", advisorFrame, "TOPRIGHT", 0, 0);
titleBar:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 1 },
});
titleBar:SetBackdropColor(0.08, 0.08, 0.11, 0.98);
titleBar:SetBackdropBorderColor(0.20, 0.20, 0.24, 1);

local titleIcon = titleBar:CreateTexture(nil, "ARTWORK");
titleIcon:SetWidth(18);
titleIcon:SetHeight(18);
titleIcon:SetPoint("LEFT", titleBar, "LEFT", 8, 0);
titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09");

local titleText = titleBar:CreateFontString(nil, "OVERLAY");
titleText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
titleText:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0);
titleText:SetText("|cffffd200BordoUI|r  |cffffffffBuilds|r");

local titleSub = titleBar:CreateFontString(nil, "OVERLAY");
titleSub:SetFont("Fonts\\ARIALN.TTF", 10);
titleSub:SetPoint("LEFT", titleText, "RIGHT", 10, -1);
titleSub:SetTextColor(0.55, 0.55, 0.60);
titleSub:SetText("(Hold Alt to drag window)");

-- Close Button
local closeBtn = CreateFrame("Button", nil, titleBar);
closeBtn:SetWidth(20);
closeBtn:SetHeight(20);
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -5, 0);
closeBtn:SetBackdrop({ bgFile = FLAT });
closeBtn:SetBackdropColor(0.18, 0.08, 0.08, 0.8);
local closeText = closeBtn:CreateFontString(nil, "OVERLAY");
closeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
closeText:SetText("|cffff4444X|r");
closeBtn:SetScript("OnClick", function()
    advisorFrame:Hide();
end);
closeBtn:SetScript("OnEnter", function()
    this:SetBackdropColor(0.4, 0.1, 0.1, 1);
end);
closeBtn:SetScript("OnLeave", function()
    this:SetBackdropColor(0.18, 0.08, 0.08, 0.8);
end);

-- ----------------------------------------------------------------------------
-- Left Sidebar: Class Selection
-- ----------------------------------------------------------------------------
local classPanel = CreateFrame("Frame", nil, advisorFrame);
classPanel:SetWidth(125);
classPanel:SetPoint("TOPLEFT", advisorFrame, "TOPLEFT", 8, -34);
classPanel:SetPoint("BOTTOMLEFT", advisorFrame, "BOTTOMLEFT", 8, 8);
classPanel:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
classPanel:SetBackdropColor(0.06, 0.06, 0.08, 0.9);
classPanel:SetBackdropBorderColor(0.18, 0.18, 0.22, 1);

local classHeader = classPanel:CreateFontString(nil, "OVERLAY");
classHeader:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
classHeader:SetPoint("TOP", classPanel, "TOP", 0, -8);
classHeader:SetTextColor(0.9, 0.8, 0.3);
classHeader:SetText("CLASSES");

local classButtons = {}; AUI.classButtons = classButtons;
local function SelectClass(classKey)
    currentClass = classKey;
    currentBuildIdx = 1;
    catalogScrollOffset = 0;
    BordoUI_BuildAdvisor_Refresh();
    if catalogDrawer and catalogDrawer:IsShown() and UpdateCatalogDrawerList then
        UpdateCatalogDrawerList();
    end
end

for idx = 1, table.getn(BordoUI_BuildData.ClassOrder) do
    local classKey = BordoUI_BuildData.ClassOrder[idx];
    local cInfo = BordoUI_BuildData.Classes[classKey];
    local btn = CreateFrame("Button", nil, classPanel);
    btn:SetWidth(113);
    btn:SetHeight(38);
    btn:SetPoint("TOP", classPanel, "TOP", 0, -26 - (idx - 1) * 44);
    btn:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    btn:SetBackdropColor(0.10, 0.10, 0.14, 0.85);
    btn:SetBackdropBorderColor(0.20, 0.20, 0.26, 1);

    local icon = btn:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(24);
    icon:SetHeight(24);
    icon:SetPoint("LEFT", btn, "LEFT", 6, 0);
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09"); -- Default fallback

    if classKey == "HUNTER" then icon:SetTexture("Interface\\Icons\\INV_Weapon_Bow_02");
    elseif classKey == "PALADIN" then icon:SetTexture("Interface\\Icons\\Spell_Holy_SealOfMight");
    elseif classKey == "WARRIOR" then icon:SetTexture("Interface\\Icons\\INV_Sword_27");
    elseif classKey == "MAGE" then icon:SetTexture("Interface\\Icons\\Spell_Frost_IceStorm");
    elseif classKey == "WARLOCK" then icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil");
    elseif classKey == "ROGUE" then icon:SetTexture("Interface\\Icons\\INV_ThrowingKnife_04");
    elseif classKey == "SHAMAN" then icon:SetTexture("Interface\\Icons\\Spell_Nature_ChainLightning");
    elseif classKey == "PRIEST" then icon:SetTexture("Interface\\Icons\\Spell_Holy_PowerWordShield");
    elseif classKey == "DRUID" then icon:SetTexture("Interface\\Icons\\Ability_Druid_CatForm");
    end

    local name = btn:CreateFontString(nil, "OVERLAY");
    name:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
    name:SetPoint("LEFT", icon, "RIGHT", 7, 1);
    name:SetText(cInfo.name);
    name:SetTextColor(cInfo.color[1], cInfo.color[2], cInfo.color[3]);

    btn.classKey = classKey;
    btn:SetScript("OnClick", function()
        SelectClass(this.classKey);
    end);
    btn:SetScript("OnEnter", function()
        if currentClass ~= this.classKey then
            this:SetBackdropColor(0.18, 0.18, 0.24, 1);
        end
    end);
    btn:SetScript("OnLeave", function()
        if currentClass ~= this.classKey then
            this:SetBackdropColor(0.10, 0.10, 0.14, 0.85);
        end
    end);

    classButtons[classKey] = btn;
end

-- ----------------------------------------------------------------------------
-- Main Content Area: Build Details
-- ----------------------------------------------------------------------------
local contentPanel = CreateFrame("Frame", nil, advisorFrame);
contentPanel:SetPoint("TOPLEFT", classPanel, "TOPRIGHT", 8, 0);
contentPanel:SetPoint("BOTTOMRIGHT", advisorFrame, "BOTTOMRIGHT", -8, 8);
contentPanel:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
contentPanel:SetBackdropColor(0.06, 0.06, 0.08, 0.9);
contentPanel:SetBackdropBorderColor(0.18, 0.18, 0.22, 1);

-- Top Controls Bar: Build Tabs & Activate Button
local topBar = CreateFrame("Frame", nil, contentPanel); AUI.topBar = topBar;
topBar:SetHeight(42);
topBar:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 0, 0);
topBar:SetPoint("TOPRIGHT", contentPanel, "TOPRIGHT", 0, 0);

local buildTabs = {}; AUI.buildTabs = buildTabs;
for t = 1, 3 do
    local tab = CreateFrame("Button", nil, topBar);
    tab:SetHeight(28);
    tab:SetWidth(104);
    tab:SetPoint("LEFT", topBar, "LEFT", 10 + (t - 1) * 108, 0);
    tab:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    local tText = tab:CreateFontString(nil, "OVERLAY");
    tText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    tText:SetPoint("CENTER", tab, "CENTER", 0, 0);
    tab.text = tText;
    tab.tabIdx = t;
    tab:SetScript("OnClick", function()
        currentBuildIdx = this.tabIdx;
        BordoUI_BuildAdvisor_Refresh();
    end);
    buildTabs[t] = tab;
end

-- Activate Build Button
local activateBtn = CreateFrame("Button", nil, topBar); AUI.activateBtn = activateBtn;
activateBtn:SetWidth(190);
activateBtn:SetHeight(28);
activateBtn:SetPoint("RIGHT", topBar, "RIGHT", -10, 0);
activateBtn:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
local activateText = activateBtn:CreateFontString(nil, "OVERLAY");
activateText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
activateText:SetPoint("CENTER", activateBtn, "CENTER", 0, 0);
activateBtn.text = activateText;

-- Build Info Header Card
local infoCard = CreateFrame("Frame", nil, contentPanel);
infoCard:SetHeight(64);
infoCard:SetPoint("TOPLEFT", topBar, "BOTTOMLEFT", 10, -4);
infoCard:SetPoint("TOPRIGHT", topBar, "BOTTOMRIGHT", -10, -4);
infoCard:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
infoCard:SetBackdropColor(0.09, 0.09, 0.12, 0.95);
infoCard:SetBackdropBorderColor(0.24, 0.24, 0.30, 1);

local buildTitle = infoCard:CreateFontString(nil, "OVERLAY"); AUI.buildTitle = buildTitle;
buildTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE");
buildTitle:SetPoint("TOPLEFT", infoCard, "TOPLEFT", 10, -8);

local buildRole = infoCard:CreateFontString(nil, "OVERLAY"); AUI.buildRole = buildRole;
buildRole:SetFont("Fonts\\ARIALN.TTF", 11);
buildRole:SetPoint("LEFT", buildTitle, "RIGHT", 8, -1);
buildRole:SetTextColor(0.2, 0.9, 0.4);

local buildSummary = infoCard:CreateFontString(nil, "OVERLAY"); AUI.buildSummary = buildSummary;
buildSummary:SetFont("Fonts\\ARIALN.TTF", 11);
buildSummary:SetPoint("TOPLEFT", buildTitle, "BOTTOMLEFT", 0, -4);
buildSummary:SetPoint("TOPRIGHT", infoCard, "TOPRIGHT", -10, -26);
buildSummary:SetJustifyH("LEFT");
buildSummary:SetTextColor(0.85, 0.85, 0.88);

local buildStats = infoCard:CreateFontString(nil, "OVERLAY"); AUI.buildStats = buildStats;
buildStats:SetFont("Fonts\\ARIALN.TTF", 10);
buildStats:SetPoint("TOPLEFT", buildSummary, "BOTTOMLEFT", 0, -4);
buildStats:SetTextColor(1.0, 0.82, 0.2);

-- Status banner that flashes when you activate
local activationBanner = infoCard:CreateFontString(nil, "OVERLAY"); AUI.activationBanner = activationBanner;
activationBanner:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
activationBanner:SetPoint("BOTTOMRIGHT", infoCard, "BOTTOMRIGHT", -10, 6);
activationBanner:SetTextColor(0.2, 1.0, 0.4);
activationBanner:Hide();

local renameBtn = CreateFrame("Button", nil, infoCard); AUI.renameBtn = renameBtn;
renameBtn:SetWidth(68);
renameBtn:SetHeight(18);
renameBtn:SetPoint("TOPRIGHT", infoCard, "TOPRIGHT", -10, -6);
renameBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
renameBtn:SetBackdropColor(0.12, 0.12, 0.16, 0.9);
renameBtn:SetBackdropBorderColor(0.35, 0.30, 0.15, 1);
local rText = renameBtn:CreateFontString(nil, "OVERLAY");
rText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
rText:SetPoint("CENTER", renameBtn, "CENTER", 0, 0);
rText:SetTextColor(1.0, 0.82, 0.0);
rText:SetText("[Rename]");
renameBtn.text = rText;
renameBtn:Hide();
renameBtn:SetScript("OnClick", function()
    StaticPopup_Show("BordoUI_RENAME_CUSTOM_BUILD");
end);

StaticPopupDialogs["BordoUI_RENAME_CUSTOM_BUILD"] = {
    text = "Enter a name for your custom build:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 30,
    OnAccept = function()
        local eb = getglobal(this:GetParent():GetName() .. "EditBox");
        local txt = eb and eb:GetText();
        if txt and txt ~= "" then
            local cb = GetCustomBuild(currentClass, currentBuildIdx);
            if cb then
                cb.title = txt;
                cb.name = txt;
                BordoUI_BuildAdvisor_Refresh();
            end
        end
    end,
    OnShow = function()
        local eb = getglobal(this:GetName() .. "EditBox");
        local cb = GetCustomBuild(currentClass, currentBuildIdx);
        if eb and cb then
            eb:SetText(cb.title or ("Build " .. currentBuildIdx));
            eb:HighlightText();
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
};

-- ----------------------------------------------------------------------------
-- View Mode Switcher: [ Spells & BiS Gear ] vs [ Talent Build (51 Pts) ]
-- ----------------------------------------------------------------------------
local currentViewMode = "OVERVIEW"; -- "OVERVIEW" or "TALENTS"

local viewBar = CreateFrame("Frame", nil, contentPanel);
viewBar:SetHeight(24);
viewBar:SetPoint("TOPLEFT", infoCard, "BOTTOMLEFT", 0, -4);
viewBar:SetPoint("TOPRIGHT", infoCard, "BOTTOMRIGHT", 0, -4);

local viewSpellsBtn = CreateFrame("Button", nil, viewBar);
viewSpellsBtn:SetWidth(164);
viewSpellsBtn:SetHeight(22);
viewSpellsBtn:SetPoint("LEFT", viewBar, "LEFT", 0, 0);
viewSpellsBtn:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
local viewSpellsText = viewSpellsBtn:CreateFontString(nil, "OVERLAY");
viewSpellsText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
viewSpellsText:SetPoint("CENTER", viewSpellsBtn, "CENTER", 0, 0);
viewSpellsBtn.text = viewSpellsText;

local viewTalentsBtn = CreateFrame("Button", nil, viewBar);
viewTalentsBtn:SetWidth(184);
viewTalentsBtn:SetHeight(22);
viewTalentsBtn:SetPoint("LEFT", viewSpellsBtn, "RIGHT", 6, 0);
viewTalentsBtn:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
local viewTalentsText = viewTalentsBtn:CreateFontString(nil, "OVERLAY");
viewTalentsText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
viewTalentsText:SetPoint("CENTER", viewTalentsBtn, "CENTER", 0, 0);
viewTalentsBtn.text = viewTalentsText;

local viewDistText = viewBar:CreateFontString(nil, "OVERLAY"); AUI.viewDistText = viewDistText;
viewDistText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
viewDistText:SetPoint("RIGHT", viewBar, "RIGHT", -2, 0);
viewDistText:SetTextColor(1.0, 0.82, 0.2);

local function UpdateViewBarButtons()
    if currentViewMode == "TALENTS" then
        viewTalentsBtn:SetBackdropColor(0.22, 0.18, 0.05, 0.95);
        viewTalentsBtn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
        viewTalentsText:SetText("|cffffd200[ - Talent Build (51 Pts) ]|r");

        viewSpellsBtn:SetBackdropColor(0.10, 0.10, 0.14, 0.85);
        viewSpellsBtn:SetBackdropBorderColor(0.22, 0.22, 0.28, 1);
        viewSpellsText:SetText("|cff888888[ - Spells & BiS Gear ]|r");
    else
        viewSpellsBtn:SetBackdropColor(0.22, 0.18, 0.05, 0.95);
        viewSpellsBtn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
        viewSpellsText:SetText("|cffffd200[ - Spells & BiS Gear ]|r");

        viewTalentsBtn:SetBackdropColor(0.10, 0.10, 0.14, 0.85);
        viewTalentsBtn:SetBackdropBorderColor(0.22, 0.22, 0.28, 1);
        viewTalentsText:SetText("|cff888888[ - Talent Build (51 Pts) ]|r");
    end
end
UpdateViewBarButtons();

-- Section 1: Core Recommended Spells Card
local spellCard = CreateFrame("Frame", nil, contentPanel); AUI.spellCard = spellCard;
spellCard:SetHeight(166);
spellCard:SetPoint("TOPLEFT", viewBar, "BOTTOMLEFT", 0, -6);
spellCard:SetPoint("TOPRIGHT", viewBar, "BOTTOMRIGHT", 0, -6);
spellCard:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
spellCard:SetBackdropColor(0.08, 0.08, 0.10, 0.95);
spellCard:SetBackdropBorderColor(0.20, 0.20, 0.25, 1);

local spellCardTitle = spellCard:CreateFontString(nil, "OVERLAY");
spellCardTitle:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
spellCardTitle:SetPoint("TOPLEFT", spellCard, "TOPLEFT", 10, -6);
spellCardTitle:SetTextColor(1.0, 0.82, 0.2);
spellCardTitle:SetText("RECOMMENDED SPELLS (PICK PRIORITY)");

local spellRows = {}; AUI.spellRows = spellRows;
for sIdx = 1, 6 do
    local row = CreateFrame("Frame", nil, spellCard);
    row:SetHeight(21);
    local col = (sIdx <= 3) and 1 or 2;
    local posInCol = (sIdx <= 3) and sIdx or (sIdx - 3);

    row:SetWidth(240);
    if col == 1 then
        row:SetPoint("TOPLEFT", spellCard, "TOPLEFT", 10, -22 - (posInCol - 1) * 44);
    else
        row:SetPoint("TOPLEFT", spellCard, "TOPLEFT", 262, -22 - (posInCol - 1) * 44);
    end

    local badge = row:CreateFontString(nil, "OVERLAY");
    badge:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    badge:SetPoint("LEFT", row, "LEFT", 0, 0);
    badge:SetTextColor(1.0, 0.82, 0.0);
    badge:SetText("#" .. sIdx);

    local icon = row:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(20);
    icon:SetHeight(20);
    icon:SetPoint("LEFT", badge, "RIGHT", 4, 0);

    -- Pulsing glow around icon in advisor when this build is active
    local glow = row:CreateTexture(nil, "OVERLAY");
    glow:SetTexture(ACTION_BORDER);
    glow:SetBlendMode("ADD");
    glow:SetVertexColor(1.0, 0.85, 0.1, 1);
    glow:SetWidth(34);
    glow:SetHeight(34);
    glow:SetPoint("CENTER", icon, "CENTER", 0, 0);
    glow:Hide();

    local sName = row:CreateFontString(nil, "OVERLAY");
    sName:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    sName:SetPoint("LEFT", icon, "RIGHT", 6, 0);

    local reason = row:CreateFontString(nil, "OVERLAY");
    reason:SetFont("Fonts\\ARIALN.TTF", 9);
    reason:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -2);
    reason:SetPoint("RIGHT", row, "RIGHT", -60, 0);
    reason:SetJustifyH("LEFT");
    reason:SetTextColor(0.70, 0.70, 0.74);

    -- Interactive Custom Build buttons
    local selectBtn = CreateFrame("Button", nil, row);
    selectBtn:SetWidth(38);
    selectBtn:SetHeight(16);
    selectBtn:SetPoint("RIGHT", row, "RIGHT", -56, 0);
    selectBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    selectBtn:SetBackdropColor(0.12, 0.14, 0.18, 0.9);
    selectBtn:SetBackdropBorderColor(0.3, 0.5, 0.8, 1);
    local sbText = selectBtn:CreateFontString(nil, "OVERLAY");
    sbText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    sbText:SetPoint("CENTER", selectBtn, "CENTER", 0, 0);
    sbText:SetTextColor(0.4, 0.8, 1.0);
    sbText:SetText("Pick");
    selectBtn.sIdx = sIdx;
    selectBtn:SetScript("OnClick", function()
        if OpenCatalogDrawer then OpenCatalogDrawer("SPELL", this.sIdx); end
    end);
    selectBtn:Hide();

    local upBtn = CreateFrame("Button", nil, row);
    upBtn:SetWidth(16);
    upBtn:SetHeight(16);
    upBtn:SetPoint("LEFT", selectBtn, "RIGHT", 2, 0);
    upBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    upBtn:SetBackdropColor(0.12, 0.12, 0.16, 0.9);
    upBtn:SetBackdropBorderColor(0.3, 0.3, 0.35, 1);
    local upText = upBtn:CreateFontString(nil, "OVERLAY");
    upText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    upText:SetPoint("CENTER", upBtn, "CENTER", 0, 0);
    upText:SetTextColor(1, 0.82, 0.0);
    upText:SetText("^");
    upBtn.sIdx = sIdx;
    upBtn:SetScript("OnClick", function()
        local idx = this.sIdx;
        if idx > 1 then
            local cb = GetCustomBuild(currentClass, currentBuildIdx);
            if cb and cb.spells then
                local temp = cb.spells[idx];
                cb.spells[idx] = cb.spells[idx - 1];
                cb.spells[idx - 1] = temp;
                BordoUI_BuildAdvisor_Refresh();
            end
        end
    end);
    upBtn:Hide();

    local downBtn = CreateFrame("Button", nil, row);
    downBtn:SetWidth(16);
    downBtn:SetHeight(16);
    downBtn:SetPoint("LEFT", upBtn, "RIGHT", 2, 0);
    downBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    downBtn:SetBackdropColor(0.12, 0.12, 0.16, 0.9);
    downBtn:SetBackdropBorderColor(0.3, 0.3, 0.35, 1);
    local dnText = downBtn:CreateFontString(nil, "OVERLAY");
    dnText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    dnText:SetPoint("CENTER", downBtn, "CENTER", 0, 0);
    dnText:SetTextColor(1, 0.82, 0.0);
    dnText:SetText("v");
    downBtn.sIdx = sIdx;
    downBtn:SetScript("OnClick", function()
        local idx = this.sIdx;
        if idx < 6 then
            local cb = GetCustomBuild(currentClass, currentBuildIdx);
            if cb and cb.spells then
                local temp = cb.spells[idx];
                cb.spells[idx] = cb.spells[idx + 1];
                cb.spells[idx + 1] = temp;
                BordoUI_BuildAdvisor_Refresh();
            end
        end
    end);
    downBtn:Hide();

    local clearBtn = CreateFrame("Button", nil, row);
    clearBtn:SetWidth(16);
    clearBtn:SetHeight(16);
    clearBtn:SetPoint("LEFT", downBtn, "RIGHT", 2, 0);
    clearBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    clearBtn:SetBackdropColor(0.25, 0.08, 0.08, 0.9);
    clearBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1);
    local clrText = clearBtn:CreateFontString(nil, "OVERLAY");
    clrText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    clrText:SetPoint("CENTER", clearBtn, "CENTER", 0, 0);
    clrText:SetTextColor(1, 0.3, 0.3);
    clrText:SetText("X");
    clearBtn.sIdx = sIdx;
    clearBtn:SetScript("OnClick", function()
        local cb = GetCustomBuild(currentClass, currentBuildIdx);
        if cb and cb.spells then
            cb.spells[this.sIdx] = nil;
            BordoUI_BuildAdvisor_Refresh();
        end
    end);
    clearBtn:Hide();

    row.badge = badge;
    row.icon = icon;
    row.glow = glow;
    row.sName = sName;
    row.reason = reason;
    row.sIdx = sIdx;
    row.selectBtn = selectBtn;
    row.upBtn = upBtn;
    row.downBtn = downBtn;
    row.clearBtn = clearBtn;

    row:EnableMouse(true);
    row:SetScript("OnEnter", function()
        local curBuild = GetCurrentAdvisorBuild();
        local sp = curBuild and curBuild.spells and curBuild.spells[this.sIdx];
        if not sp then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("|cffffd200Priority Slot #" .. this.sIdx .. "|r", 1, 1, 1);
            GameTooltip:AddLine("|cff00ff00[Click to assign a spell from the catalog]|r", 0.2, 1.0, 0.3);
            GameTooltip:Show();
            return;
        end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
        GameTooltip:ClearLines();
        local sColor = SCHOOL_COLORS[sp.school] or { 1, 1, 1 };
        local hex = string.format("%02x%02x%02x", sColor[1] * 255, sColor[2] * 255, sColor[3] * 255);
        GameTooltip:AddLine("|cff" .. hex .. sp.name .. "|r", 1, 1, 1);
        GameTooltip:AddLine("|cffffffff" .. sp.school .. " Ability|r  |cff00ff00(Pick Priority #" .. this.sIdx .. ")|r", 1, 1, 1);
        GameTooltip:AddLine(" ");
        if sp.reason then
            GameTooltip:AddLine("|cffffd200Priority Tip:|r\n" .. sp.reason, 1, 1, 1, 1);
        end
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("|cff00ff00[Click row or Pick button to change spell]|r", 0.2, 1.0, 0.3);
        GameTooltip:Show();
    end);
    row:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    row:SetScript("OnMouseUp", function()
        if OpenCatalogDrawer then
            OpenCatalogDrawer("SPELL", this.sIdx);
        end
    end);
    spellRows[sIdx] = row;
end



-- Modern Dedicated Jewelry Tooltip with authentic card icon
local jTooltip = CreateFrame("Frame", "BordoUI_JewelryCardTooltip", UIParent); AUI.jTooltip = jTooltip;
jTooltip:SetWidth(240);
jTooltip:SetFrameStrata("TOOLTIP");
jTooltip:SetFrameLevel(100);
jTooltip:SetClampedToScreen(true);
jTooltip:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
});
jTooltip:SetBackdropColor(0.04, 0.04, 0.06, 0.92);
jTooltip:SetBackdropBorderColor(0.15, 0.15, 0.20, 0.95);
jTooltip:Hide();

local jtIcon = jTooltip:CreateTexture(nil, "ARTWORK");
jtIcon:SetWidth(28);
jtIcon:SetHeight(28);
jtIcon:SetPoint("TOPLEFT", jTooltip, "TOPLEFT", 8, -8);
jtIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93);

local jtIconBorder = jTooltip:CreateTexture(nil, "OVERLAY");
jtIconBorder:SetPoint("TOPLEFT", jtIcon, "TOPLEFT", -1, 1);
jtIconBorder:SetPoint("BOTTOMRIGHT", jtIcon, "BOTTOMRIGHT", 1, -1);
jtIconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
jtIconBorder:SetBlendMode("ADD");
jtIconBorder:SetAlpha(0.65);

local jtTitle = jTooltip:CreateFontString(nil, "OVERLAY");
jtTitle:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
jtTitle:SetPoint("TOPLEFT", jtIcon, "TOPRIGHT", 6, 0);
jtTitle:SetPoint("RIGHT", jTooltip, "RIGHT", -8, 0);
jtTitle:SetJustifyH("LEFT");

local jtSub = jTooltip:CreateFontString(nil, "OVERLAY");
jtSub:SetFont("Fonts\\ARIALN.TTF", 8);
jtSub:SetPoint("BOTTOMLEFT", jtIcon, "BOTTOMRIGHT", 6, 0);
jtSub:SetPoint("RIGHT", jTooltip, "RIGHT", -8, 0);
jtSub:SetJustifyH("LEFT");
jtSub:SetTextColor(0.75, 0.75, 0.80);

local jtDivider = jTooltip:CreateTexture(nil, "ARTWORK");
jtDivider:SetHeight(1);
jtDivider:SetPoint("TOPLEFT", jtIcon, "BOTTOMLEFT", 0, -6);
jtDivider:SetPoint("RIGHT", jTooltip, "RIGHT", -8, 0);
jtDivider:SetTexture(FLAT);
jtDivider:SetVertexColor(0.25, 0.25, 0.30, 0.8);

local jtDesc = jTooltip:CreateFontString(nil, "OVERLAY");
jtDesc:SetFont("Fonts\\ARIALN.TTF", 9);
jtDesc:SetPoint("TOPLEFT", jtDivider, "BOTTOMLEFT", 0, -5);
jtDesc:SetPoint("RIGHT", jTooltip, "RIGHT", -8, 0);
jtDesc:SetJustifyH("LEFT");
jtDesc:SetTextColor(0.95, 0.95, 0.95);

local jtStatus = jTooltip:CreateFontString(nil, "OVERLAY");
jtStatus:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
jtStatus:SetPoint("TOPLEFT", jtDesc, "BOTTOMLEFT", 0, -6);
jtStatus:SetPoint("RIGHT", jTooltip, "RIGHT", -8, 0);
jtStatus:SetJustifyH("LEFT");

-- Dedicated scanner tooltip for 100% reliable inventory item inspection in WoW 1.12
local scanTooltip = CreateFrame("GameTooltip", "BordoUI_ItemScannerTooltip", nil, "GameTooltipTemplate");
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");

local function NormalizeItemString(str)
    if not str then return ""; end
    local s = string.lower(str);
    -- Strip trailing roman numerals or rank numbers (e.g. " ii", " iii", " iv", " 2", etc.)
    s = string.gsub(s, "%s+[ivxlcdm]+$", "");
    s = string.gsub(s, "%s+%d+$", "");
    -- Strip punctuation, spaces, and underscores
    s = string.gsub(s, "[%s%p_]", "");
    return s;
end

-- Robust helper to check if target jewelry (or spell-remaking amulet) is equipped on character
local function IsJewelryEquipped(targetItem)
    if not targetItem then return false, nil; end
    local targetName = "";
    local targetIcon = "";
    local targetSpell = "";
    local targetSlotType = "";
    if type(targetItem) == "table" then
        targetName = targetItem.name or "";
        targetIcon = targetItem.icon or "";
        targetSpell = targetItem.spell or "";
        targetSlotType = targetItem.slotType or targetItem.slot or targetItem.slotKey or "";
    else
        targetName = tostring(targetItem);
    end
    if targetName == "" and targetIcon == "" and targetSpell == "" then return false, nil; end

    -- Extract spell from item name if not explicitly set (e.g. "Eye of the Splitting Sky: Exorcism")
    if (not targetSpell or targetSpell == "") and string.find(targetName, ":") then
        local _, _, spPart = string.find(targetName, ":%s*([^:]+)");
        if spPart then
            spPart = string.gsub(spPart, "%s+[IVXLCDMivxlcdm%d]+$", "");
            targetSpell = spPart;
        end
    end

    local cleanTargetName = NormalizeItemString(targetName);
    local cleanTargetSpell = string.lower(string.gsub(targetSpell or "", "[^%a]", ""));
    local cleanTargetIcon = string.lower(string.gsub(targetIcon or "", "[\\/]", ""));

    -- Aliases for legacy saved custom builds (e.g. "Amulet of the Inferno: Exorcism" -> target spell "exorcism")
    if string.find(cleanTargetName, "amuletoftheinfernoexorcism") or string.find(cleanTargetName, "infernoexorcism") then
        cleanTargetSpell = "exorcism";
    end

    -- Inventory slots: 2 = Neck, 11 = Ring 1, 12 = Ring 2, 13 = Trinket 1, 14 = Trinket 2
    local checkSlots = { 2, 11, 12, 13, 14 };
    local isNeckTarget = (cleanTargetSpell ~= "") or (string.upper(targetSlotType) == "NECK") or (targetSlotType == "neck") or (targetSlotType == "Necklace");

    for sIdx = 1, 5 do
        local sId = checkSlots[sIdx];
        local rawName = nil;
        local link = GetInventoryItemLink and GetInventoryItemLink("player", sId);
        if link then
            local _, _, parsedName = string.find(link, "%[(.+)%]");
            rawName = parsedName;
        end

        -- Tooltip scanner fallback if link didn't parse item name
        if not rawName or rawName == "" then
            scanTooltip:ClearLines();
            scanTooltip:SetInventoryItem("player", sId);
            local tLeft1 = BordoUI_ItemScannerTooltipTextLeft1 and BordoUI_ItemScannerTooltipTextLeft1:GetText();
            if tLeft1 and tLeft1 ~= "" then
                rawName = tLeft1;
            end
        end

        if rawName and rawName ~= "" then
            local cleanEquipName = NormalizeItemString(rawName);
            local lowerEquipName = string.lower(rawName);

            -- 1. Exact or substring match of base name (e.g. "Eye of the Splitting Sky: Exorcism II" matches "Eye of the Splitting Sky: Exorcism")
            if cleanTargetName ~= "" and (cleanEquipName == cleanTargetName or string.find(cleanEquipName, cleanTargetName, 1, true) or string.find(cleanTargetName, cleanEquipName, 1, true)) then
                return true, rawName;
            end

            -- 2. Spell-based remake matching for Neck slot (Slot 2) or target amulets
            -- In Azeroth Survivors, legendary amulets remake class abilities.
            -- If the target is an amulet for a spell (e.g. Exorcism), and slot 2 (or any equipped jewelry)
            -- modifies that spell, it satisfies the build advisor!
            if cleanTargetSpell ~= "" and (sId == 2 or isNeckTarget) then
                if string.find(lowerEquipName, cleanTargetSpell, 1, true) then
                    return true, rawName;
                end
            end
        end

        -- 3. Icon / texture fallback matching
        local tex = GetInventoryItemTexture and GetInventoryItemTexture("player", sId);
        if tex and cleanTargetIcon ~= "" and string.len(cleanTargetIcon) > 5 then
            local cleanTex = string.lower(string.gsub(tex, "[\\/]", ""));
            if cleanTex ~= "" and (cleanTex == cleanTargetIcon or string.find(cleanTex, cleanTargetIcon, 1, true) or string.find(cleanTargetIcon, cleanTex, 1, true)) then
                return true, rawName;
            end
        end
    end

    return false, nil;
end

local function ShowJewelryTooltip(owner, itmData, isEq, slotLabel, anchorDir)
    if not (owner and itmData) then return; end
    if GameTooltip then GameTooltip:Hide(); end
    local qColor = ITEM_QUALITY_COLORS[itmData.quality or 4] or { r = 0.64, g = 0.21, b = 0.93 };
    jtIcon:SetTexture(NormalizeIconPath(itmData.icon));
    jtIconBorder:SetVertexColor(qColor.r, qColor.g, qColor.b, 0.8);
    jtTitle:SetText(itmData.name or "Jewelry");
    jtTitle:SetTextColor(qColor.r, qColor.g, qColor.b);

    local sLabel = slotLabel or itmData.slotType or itmData.slot or "Jewelry";
    jtSub:SetText("|cffffd200" .. sLabel .. "|r  |cff888888(Rank I Card)|r");

    local bStr = itmData.benefit;
    local dStr = itmData.desc;
    local eqStr = itmData.equip;
    local descText = "";

    if eqStr and eqStr ~= "" and (not bStr or not string.find(string.lower(eqStr), string.lower(string.gsub(bStr, "[%s%p_]", "")))) then
        if bStr and bStr ~= "" then
            descText = "|cff00ff66" .. bStr .. "|r\n|cffffffff" .. eqStr .. "|r";
        else
            descText = "|cffffffff" .. eqStr .. "|r";
        end
    elseif dStr and dStr ~= "" then
        if string.find(dStr, "\n") or string.find(dStr, "Legendary") or string.find(dStr, "Equip:") then
            if bStr and bStr ~= "" and not string.find(dStr, bStr, 1, true) then
                descText = "|cff00ff66" .. bStr .. "|r\n" .. dStr;
            else
                descText = dStr;
            end
        else
            if bStr and bStr ~= "" then
                descText = "|cff00ff66" .. bStr .. "|r";
            else
                descText = "|cff00ff66" .. dStr .. "|r";
            end
        end
    elseif bStr and bStr ~= "" then
        descText = "|cff00ff66" .. bStr .. "|r";
    end
    jtDesc:SetText(descText);

    local equipped, eqItemName = IsJewelryEquipped(itmData);
    if equipped or isEq then
        if eqItemName and eqItemName ~= "" then
            jtStatus:SetText("|cff00ff00Equipped: " .. eqItemName .. "|r");
        else
            jtStatus:SetText("|cff00ff00[Equipped on Character]|r");
        end
        jtStatus:Show();
    else
        jtStatus:SetText("|cffff5555[Not Equipped]|r");
        jtStatus:Show();
    end

    jTooltip:ClearAllPoints();
    if anchorDir == "BOTTOM" then
        jTooltip:SetPoint("TOP", owner, "BOTTOM", 0, -6);
    elseif anchorDir == "LEFT" then
        jTooltip:SetPoint("TOPRIGHT", owner, "TOPLEFT", -6, 0);
    else
        jTooltip:SetPoint("TOPLEFT", owner, "TOPRIGHT", 6, 0);
    end

    local textH = (jtDesc.GetStringHeight and jtDesc:GetStringHeight()) or (jtDesc.GetHeight and jtDesc:GetHeight()) or 24;
    local statusH = (jtStatus:IsShown() and ((jtStatus.GetStringHeight and jtStatus:GetStringHeight()) or 14)) or 0;
    local totalH = 8 + 28 + 6 + 1 + 6 + textH + (statusH > 0 and (statusH + 6) or 0) + 8;
    jTooltip:SetHeight(math.max(68, totalH));
    jTooltip:Show();
end

local function HideJewelryTooltip()
    if jTooltip then jTooltip:Hide(); end
end

-- Section 2: BiS Jewelry Card
local gearCard = CreateFrame("Frame", nil, contentPanel); AUI.gearCard = gearCard;
gearCard:SetHeight(126);
gearCard:SetPoint("TOPLEFT", spellCard, "BOTTOMLEFT", 0, -8);
gearCard:SetPoint("TOPRIGHT", spellCard, "BOTTOMRIGHT", 0, -8);
gearCard:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
gearCard:SetBackdropColor(0.08, 0.08, 0.10, 0.95);
gearCard:SetBackdropBorderColor(0.20, 0.20, 0.25, 1);

local gearCardTitle = gearCard:CreateFontString(nil, "OVERLAY");
gearCardTitle:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
gearCardTitle:SetPoint("TOPLEFT", gearCard, "TOPLEFT", 10, -6);
gearCardTitle:SetTextColor(1.0, 0.82, 0.2);
gearCardTitle:SetText("BEST IN SLOT (BiS) JEWELRY & TRINKETS");

local gearSlots = {
    { key = "neck",     label = "Neck",      slotName = "Necklace" },
    { key = "ring1",    label = "Ring 1",    slotName = "Finger" },
    { key = "ring2",    label = "Ring 2",    slotName = "Finger" },
    { key = "trinket1", label = "Trinket 1", slotName = "Trinket" },
    { key = "trinket2", label = "Trinket 2", slotName = "Trinket" },
};
AUI.gearSlots = gearSlots;

local gearRows = {}; AUI.gearRows = gearRows;

-- Hovering over the jewelry card/title shows the authentic 5-slot summary
gearCard:EnableMouse(true);
gearCard:SetScript("OnEnter", function()
    local curBuild = GetCurrentAdvisorBuild();
    if not (curBuild and curBuild.jewelry) then return; end
    if MouseIsOver then
        for i = 1, 5 do
            local gr = gearRows[gearSlots[i].key];
            if gr and MouseIsOver(gr) then
                return;
            end
        end
    end
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:ClearLines();
    GameTooltip:AddLine("|cffffd200BiS Jewelry Set Summary|r", 1, 1, 1);
    GameTooltip:AddLine("|cff888888Worn gear stats in Azeroth Survivors:|r", 1, 1, 1);
    GameTooltip:AddLine(" ");

    for idx = 1, 5 do
        local itm = curBuild.jewelry[gearSlots[idx].key];
        if itm then
            local statText = (itm.stats and itm.stats[1]) or itm.benefit or "";
            GameTooltip:AddLine("|cffffffff" .. statText .. "|r", 1, 1, 1);
        end
    end
    GameTooltip:Show();
end);
gearCard:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

for gIdx = 1, (gearSlots and table.getn(gearSlots) or 0) do
    local gInfo = gearSlots[gIdx];
    local f = CreateFrame("Button", nil, gearCard);
    f:SetWidth(96);
    f:SetHeight(92);
    f:SetPoint("TOPLEFT", gearCard, "TOPLEFT", 8 + (gIdx - 1) * 101, -22);
    f:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    f:SetBackdropColor(0.05, 0.05, 0.07, 0.85);
    f:SetBackdropBorderColor(0.20, 0.20, 0.24, 1);
    f:EnableMouse(true);
    f.gInfo = gInfo;

    local slotTag = f:CreateFontString(nil, "OVERLAY");
    slotTag:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    slotTag:SetPoint("TOP", f, "TOP", 0, -4);
    slotTag:SetTextColor(0.65, 0.65, 0.70);
    slotTag:SetText(gInfo.label);

    local icon = f:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(26);
    icon:SetHeight(26);
    icon:SetPoint("TOP", slotTag, "BOTTOM", 0, -3);

    local iName = f:CreateFontString(nil, "OVERLAY");
    iName:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    iName:SetPoint("TOP", icon, "BOTTOM", 0, -2);
    iName:SetPoint("LEFT", f, "LEFT", 3, 0);
    iName:SetPoint("RIGHT", f, "RIGHT", -3, 0);
    iName:SetJustifyH("CENTER");

    local benefit = f:CreateFontString(nil, "OVERLAY");
    benefit:SetFont("Fonts\\ARIALN.TTF", 8);
    benefit:SetPoint("TOP", iName, "BOTTOM", 0, -1);
    benefit:SetPoint("LEFT", f, "LEFT", 2, 0);
    benefit:SetPoint("RIGHT", f, "RIGHT", -2, 0);
    benefit:SetJustifyH("CENTER");
    benefit:SetTextColor(0.12, 1.0, 0.2);

    -- Clear button for custom mode
    local gClearBtn = CreateFrame("Button", nil, f);
    gClearBtn:SetWidth(15);
    gClearBtn:SetHeight(15);
    gClearBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2);
    gClearBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
    gClearBtn:SetBackdropColor(0.25, 0.05, 0.05, 0.9);
    gClearBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1);
    local gClearTxt = gClearBtn:CreateFontString(nil, "OVERLAY");
    gClearTxt:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    gClearTxt:SetPoint("CENTER", gClearBtn, "CENTER", 0, 0);
    gClearTxt:SetTextColor(1, 0.3, 0.3);
    gClearTxt:SetText("x");
    gClearBtn.gKey = gInfo.key;
    gClearBtn:SetScript("OnClick", function()
        local cb = GetCustomBuild(currentClass, currentBuildIdx);
        if cb and cb.jewelry then
            cb.jewelry[this.gKey] = nil;
            BordoUI_BuildAdvisor_Refresh();
        end
    end);
    gClearBtn:Hide();
    f.clearBtn = gClearBtn;

    f:SetScript("OnEnter", function()
        this:SetBackdropColor(0.12, 0.12, 0.16, 0.95);
        this:SetBackdropBorderColor(1.0, 0.82, 0.2, 1);

        local curBuild = GetCurrentAdvisorBuild();
        local itm = curBuild and curBuild.jewelry and curBuild.jewelry[this.gInfo.key];
        if not itm then
            HideJewelryTooltip();
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("|cffffd200Empty " .. (this.gInfo.label or "Jewelry") .. " Slot|r", 1, 1, 1);
            GameTooltip:AddLine(" ");
            GameTooltip:AddLine("|cff00ff00Click to open Jewelry Catalog & select item!|r", 0.2, 1.0, 0.3);
            GameTooltip:Show();
            return;
        end

        local isEq = IsJewelryEquipped and IsJewelryEquipped(itm);
        ShowJewelryTooltip(this, itm, isEq, this.gInfo.slotName or this.gInfo.label, "RIGHT");
    end);

    f:SetScript("OnLeave", function()
        this:SetBackdropColor(0.05, 0.05, 0.07, 0.85);
        this:SetBackdropBorderColor(0.20, 0.20, 0.24, 1);
        HideJewelryTooltip();
        GameTooltip:Hide();
    end);

    f:SetScript("OnClick", function()
        if OpenCatalogDrawer then
            local defFilter = (this.gInfo.key == "neck" and "Necks")
                or ((this.gInfo.key == "ring1" or this.gInfo.key == "ring2") and "Rings")
                or "Trinkets";
            OpenCatalogDrawer("JEWELRY", this.gInfo.key, defFilter);
        end
    end);

    f.slotTag = slotTag;
    f.icon = icon;
    f.iName = iName;
    f.benefit = benefit;
    gearRows[gInfo.key] = f;
end

-- ============================================================================
-- CATALOG DRAWER (Spells & Jewelry Selector for Custom Builds)
-- ============================================================================
catalogDrawer = CreateFrame("Frame", "BordoUI_BuildCatalogDrawer", advisorFrame); AUI.catalogDrawer = catalogDrawer;
catalogDrawer:SetFrameStrata("DIALOG");
catalogDrawer:SetFrameLevel(60);
catalogDrawer:SetWidth(285);
catalogDrawer:SetPoint("TOPLEFT", advisorFrame, "TOPRIGHT", 4, 0);
catalogDrawer:SetPoint("BOTTOMLEFT", advisorFrame, "BOTTOMRIGHT", 4, 0);
catalogDrawer:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
catalogDrawer:SetBackdropColor(0.04, 0.04, 0.06, 0.98);
catalogDrawer:SetBackdropBorderColor(0.26, 0.26, 0.34, 1);
catalogDrawer:EnableMouse(true);
catalogDrawer:Hide();

local cTitleBar = CreateFrame("Frame", nil, catalogDrawer);
cTitleBar:SetHeight(34);
cTitleBar:SetPoint("TOPLEFT", catalogDrawer, "TOPLEFT", 0, 0);
cTitleBar:SetPoint("TOPRIGHT", catalogDrawer, "TOPRIGHT", 0, 0);
cTitleBar:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 1 },
});
cTitleBar:SetBackdropColor(0.08, 0.08, 0.12, 0.98);
cTitleBar:SetBackdropBorderColor(0.22, 0.22, 0.28, 1);

local cTitleText = cTitleBar:CreateFontString(nil, "OVERLAY"); AUI.cTitleText = cTitleText;
cTitleText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
cTitleText:SetPoint("TOPLEFT", cTitleBar, "TOPLEFT", 10, -5);
cTitleText:SetTextColor(1.0, 0.82, 0.2);
cTitleText:SetText("CATALOG SELECTOR");

local cSubText = cTitleBar:CreateFontString(nil, "OVERLAY"); AUI.cSubText = cSubText;
cSubText:SetFont("Fonts\\ARIALN.TTF", 9);
cSubText:SetPoint("TOPLEFT", cTitleText, "BOTTOMLEFT", 0, -2);
cSubText:SetTextColor(0.65, 0.65, 0.70);
cSubText:SetText("Click an entry to slot it");

local cCloseBtn = CreateFrame("Button", nil, cTitleBar);
cCloseBtn:SetWidth(18);
cCloseBtn:SetHeight(18);
cCloseBtn:SetPoint("RIGHT", cTitleBar, "RIGHT", -6, 0);
cCloseBtn:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 });
cCloseBtn:SetBackdropColor(0.18, 0.08, 0.08, 0.8);
cCloseBtn:SetBackdropBorderColor(0.35, 0.15, 0.15, 1);
local cCloseTxt = cCloseBtn:CreateFontString(nil, "OVERLAY");
cCloseTxt:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
cCloseTxt:SetPoint("CENTER", cCloseBtn, "CENTER", 0, 0);
cCloseTxt:SetText("|cffff4444X|r");
cCloseBtn:SetScript("OnClick", function()
    catalogDrawer:Hide();
end);
cCloseBtn:SetScript("OnEnter", function()
    this:SetBackdropColor(0.38, 0.10, 0.10, 1);
end);
cCloseBtn:SetScript("OnLeave", function()
    this:SetBackdropColor(0.18, 0.08, 0.08, 0.8);
end);

local catTabBar = CreateFrame("Frame", nil, catalogDrawer); AUI.catTabBar = catTabBar;
catTabBar:SetHeight(24);
catTabBar:SetPoint("TOPLEFT", cTitleBar, "BOTTOMLEFT", 4, -4);
catTabBar:SetPoint("TOPRIGHT", cTitleBar, "BOTTOMRIGHT", -4, -4);

local catTabs = {}; AUI.catTabs = catTabs;
local catFilterNames = { "All", "Necks", "Rings", "Trinkets" };
local currentCatFilter = "All";
local currentDrawerMode = "SPELL";
local currentTargetSlot = 1;

for i = 1, 4 do
    local cTab = CreateFrame("Button", nil, catTabBar);
    cTab:SetWidth(66);
    cTab:SetHeight(20);
    cTab:SetPoint("LEFT", catTabBar, "LEFT", (i - 1) * 68, 0);
    cTab:SetBackdrop({
        bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    cTab:SetBackdropColor(0.08, 0.08, 0.10, 0.90);
    cTab:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.85);

    local ctText = cTab:CreateFontString(nil, "OVERLAY");
    ctText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    ctText:SetPoint("CENTER", cTab, "CENTER", 0, 0);
    ctText:SetTextColor(0.65, 0.65, 0.70);
    cTab.text = ctText;
    cTab.filterName = catFilterNames[i];
    cTab.text:SetText(catFilterNames[i]);
    cTab:SetScript("OnClick", function()
        currentCatFilter = this.filterName;
        UpdateCatalogDrawerList();
    end);
    catTabs[i] = cTab;
end

local catalogRows = {}; AUI.catalogRows = catalogRows;
catalogScrollOffset = 0;
local currentFilteredItems = {};

for r = 1, 12 do
    local rBtn = CreateFrame("Button", nil, catalogDrawer);
    rBtn:SetHeight(38);
    rBtn:SetPoint("TOPLEFT", catTabBar, "BOTTOMLEFT", 2, -4 - (r - 1) * 40);
    rBtn:SetPoint("TOPRIGHT", catTabBar, "BOTTOMRIGHT", -2, -4 - (r - 1) * 40);
    rBtn:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    rBtn:SetBackdropColor(0.08, 0.08, 0.10, 0.9);
    rBtn:SetBackdropBorderColor(0.20, 0.20, 0.24, 1);
    rBtn:EnableMouse(true);

    local rIcon = rBtn:CreateTexture(nil, "ARTWORK");
    rIcon:SetWidth(26);
    rIcon:SetHeight(26);
    rIcon:SetPoint("LEFT", rBtn, "LEFT", 4, 0);
    rIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93);

    local rName = rBtn:CreateFontString(nil, "OVERLAY");
    rName:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    rName:SetPoint("TOPLEFT", rIcon, "TOPRIGHT", 5, -2);
    rName:SetPoint("RIGHT", rBtn, "RIGHT", -4, 0);
    rName:SetJustifyH("LEFT");

    local rSub = rBtn:CreateFontString(nil, "OVERLAY");
    rSub:SetFont("Fonts\\ARIALN.TTF", 8);
    rSub:SetPoint("BOTTOMLEFT", rIcon, "BOTTOMRIGHT", 5, 2);
    rSub:SetPoint("RIGHT", rBtn, "RIGHT", -4, 0);
    rSub:SetJustifyH("LEFT");
    rSub:SetTextColor(0.7, 0.7, 0.75);

    rBtn.icon = rIcon;
    rBtn.name = rName;
    rBtn.sub = rSub;
    rBtn.rIdx = r;

    rBtn:SetScript("OnEnter", function()
        this:SetBackdropColor(0.14, 0.14, 0.20, 0.98);
        this:SetBackdropBorderColor(0.85, 0.70, 0.20, 0.95);
        if this.itemData then
            local d = this.itemData;
            if currentDrawerMode == "SPELL" then
                HideJewelryTooltip();
                GameTooltip:SetOwner(this, "ANCHOR_LEFT");
                GameTooltip:ClearLines();
                local sColor = SCHOOL_COLORS[d.school] or { 1, 1, 1 };
                GameTooltip:AddLine(d.name, sColor[1], sColor[2], sColor[3]);
                GameTooltip:AddLine(d.school .. " Ability", 1, 1, 1);
                GameTooltip:AddLine(" ");
                GameTooltip:AddLine(d.desc or "", 1, 1, 1, 1);
                GameTooltip:AddLine(" ");
                GameTooltip:AddLine("|cff00ff00Click to slot into Priority #" .. currentTargetSlot .. "|r", 0.2, 1.0, 0.3);
                GameTooltip:Show();
            else
                ShowJewelryTooltip(this, d, nil, d.slotType or "Jewelry", "LEFT");
            end
        end
    end);

    rBtn:SetScript("OnLeave", function()
        this:SetBackdropColor(0.06, 0.06, 0.08, 0.92);
        this:SetBackdropBorderColor(0.18, 0.18, 0.22, 0.85);
        HideJewelryTooltip();
        GameTooltip:Hide();
    end);

    rBtn:SetScript("OnClick", function()
        if not this.itemData then return; end
        local d = this.itemData;
        local cb = GetCustomBuild(currentClass, currentBuildIdx);
        if not cb then return; end

        if currentDrawerMode == "SPELL" then
            local cleanKey = d.key or string.lower(string.gsub(d.name, "[%s%p]+", "_"));
            cb.spells[currentTargetSlot] = {
                key = cleanKey,
                name = d.name,
                school = d.school or "Physical",
                icon = d.icon,
                rankMax = 8,
                reason = "Custom Priority #" .. currentTargetSlot,
            };
            PlaySound("igSpellBookOpen");
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Set Spell #" .. currentTargetSlot .. " to |cff00ff00" .. d.name .. "|r");
        else
            cb.jewelry[currentTargetSlot] = {
                name = d.name,
                icon = d.icon,
                quality = d.quality or 4,
                benefit = d.benefit,
                slot = d.slotType,
                slotType = d.slotType,
                spell = d.spell,
                equip = d.desc,
                desc = d.desc,
            };
            PlaySound("LOOTWINDOWCOINSOUND");
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Slotted |cffa335ee" .. d.name .. "|r into " .. currentTargetSlot);
        end

        catalogDrawer:Hide();
        BordoUI_BuildAdvisor_Refresh();

        local activeBuild, actClass, actIdx = BordoUI_GetActiveBuild();
        if actClass == currentClass and actIdx == currentBuildIdx then
            RefreshChoiceHUD();
        end
    end);

    catalogRows[r] = rBtn;
end

catalogDrawer:EnableMouseWheel(true);
catalogDrawer:SetScript("OnMouseWheel", function()
    local delta = arg1;
    local maxOffset = table.getn(currentFilteredItems) - 12;
    if maxOffset < 0 then maxOffset = 0; end
    if delta > 0 then
        catalogScrollOffset = math.max(0, catalogScrollOffset - 1);
    else
        catalogScrollOffset = math.min(maxOffset, catalogScrollOffset + 1);
    end
    UpdateCatalogDrawerList();
end);

UpdateCatalogDrawerList = function()
    local ui = BordoUI_AdvisorUI or AUI;
    local cTitleText = ui.cTitleText;
    local cSubText = ui.cSubText;
    local catTabBar = ui.catTabBar;
    local catTabs = ui.catTabs;
    local catalogRows = ui.catalogRows;
    currentFilteredItems = {};
    if currentDrawerMode == "SPELL" then
        catTabBar:Hide();
        local spells = (BordoUI_Catalog and BordoUI_Catalog.Spells and BordoUI_Catalog.Spells[currentClass]) or {};
        for _, s in ipairs(spells) do
            table.insert(currentFilteredItems, s);
        end
        cTitleText:SetText("SELECT SPELL #" .. currentTargetSlot);
        cSubText:SetText(currentClass .. " Spells (" .. table.getn(currentFilteredItems) .. " available)");
    else
        catTabBar:Show();
        for i = 1, 4 do
            if catTabs[i].filterName == currentCatFilter then
                catTabs[i]:SetBackdropColor(0.24, 0.24, 0.32, 1);
                catTabs[i]:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
            else
                catTabs[i]:SetBackdropColor(0.10, 0.10, 0.14, 0.9);
                catTabs[i]:SetBackdropBorderColor(0.22, 0.22, 0.26, 1);
            end
        end

        local allJewelry = (BordoUI_Catalog and BordoUI_Catalog.Jewelry) or {};
        for _, j in ipairs(allJewelry) do
            -- Class-specific legendary items (e.g. legendary amulets) only show for that class
            local isClassItem = (not j.class) or (string.upper(j.class) == string.upper(currentClass));
            if isClassItem then
                local match = false;
                if currentCatFilter == "All" then
                    match = true;
                elseif currentCatFilter == "Necks" and j.slotType == "NECK" then
                    match = true;
                elseif currentCatFilter == "Rings" and j.slotType == "RING" then
                    match = true;
                elseif currentCatFilter == "Trinkets" and j.slotType == "TRINKET" then
                    match = true;
                end
                if match then
                    table.insert(currentFilteredItems, j);
                end
            end
        end
        cTitleText:SetText("SELECT " .. string.upper(currentTargetSlot));
        cSubText:SetText("Filter: " .. currentCatFilter .. " (" .. table.getn(currentFilteredItems) .. " items)");
    end

    local maxOffset = table.getn(currentFilteredItems) - 12;
    if maxOffset < 0 then maxOffset = 0; end
    if catalogScrollOffset > maxOffset then catalogScrollOffset = maxOffset; end

    for r = 1, 12 do
        local rBtn = catalogRows[r];
        local itmIdx = catalogScrollOffset + r;
        local itmData = currentFilteredItems[itmIdx];
        if itmData then
            rBtn.itemData = itmData;
            rBtn.icon:SetTexture(NormalizeIconPath(itmData.icon));
            if currentDrawerMode == "SPELL" then
                local sColor = SCHOOL_COLORS[itmData.school] or { 1, 1, 1 };
                rBtn.name:SetText(itmData.name);
                rBtn.name:SetTextColor(sColor[1], sColor[2], sColor[3]);
                rBtn.sub:SetText(itmData.school .. " Spell");
            else
                local qHex = QUALITY_HEX[itmData.quality or 4] or "a335ee";
                rBtn.name:SetText("|cff" .. qHex .. itmData.name .. "|r");
                rBtn.sub:SetText("|cff00ff66" .. (itmData.benefit or itmData.slotType) .. "|r");
            end
            rBtn:Show();
        else
            rBtn.itemData = nil;
            rBtn:Hide();
        end
    end
end;

OpenCatalogDrawer = function(mode, targetSlot, defaultFilter)
    currentDrawerMode = mode;
    currentTargetSlot = targetSlot;
    catalogScrollOffset = 0;
    if defaultFilter then
        currentCatFilter = defaultFilter;
    else
        currentCatFilter = "All";
    end
    UpdateCatalogDrawerList();
    catalogDrawer:Show();
end;

CloseCatalogDrawer = function()
    catalogDrawer:Hide();
end;

-- Section 3: Bottom Strategy & Preview Bar
local bottomBar = CreateFrame("Frame", nil, contentPanel);
bottomBar:SetHeight(36);
bottomBar:SetPoint("BOTTOMLEFT", contentPanel, "BOTTOMLEFT", 10, 8);
bottomBar:SetPoint("BOTTOMRIGHT", contentPanel, "BOTTOMRIGHT", -10, 8);
bottomBar:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
bottomBar:SetBackdropColor(0.08, 0.08, 0.10, 0.95);
bottomBar:SetBackdropBorderColor(0.20, 0.20, 0.25, 1);

local tacticsText = bottomBar:CreateFontString(nil, "OVERLAY"); AUI.tacticsText = tacticsText;
tacticsText:SetFont("Fonts\\ARIALN.TTF", 10);
tacticsText:SetPoint("LEFT", bottomBar, "LEFT", 10, 0);
tacticsText:SetPoint("RIGHT", bottomBar, "RIGHT", -170, 0);
tacticsText:SetJustifyH("LEFT");
tacticsText:SetTextColor(0.9, 0.85, 0.7);

local previewGlowBtn = CreateFrame("Button", nil, bottomBar); AUI.previewGlowBtn = previewGlowBtn;
previewGlowBtn:SetWidth(150);
previewGlowBtn:SetHeight(24);
previewGlowBtn:SetPoint("RIGHT", bottomBar, "RIGHT", -8, 0);
previewGlowBtn:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
previewGlowBtn:SetBackdropColor(0.15, 0.12, 0.04, 0.9);
previewGlowBtn:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.8);
local prevText = previewGlowBtn:CreateFontString(nil, "OVERLAY"); AUI.prevText = prevText;
prevText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
prevText:SetPoint("CENTER", previewGlowBtn, "CENTER", 0, 0);
prevText:SetText("|cffffd200Preview Choice HUD|r");

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Section 4: Authentic In-Game Talent Tree Grid (Matching Azeroth Survivors Armory UI)
-- ----------------------------------------------------------------------------
local talentsPanel = CreateFrame("Frame", nil, contentPanel); AUI.talentsPanel = talentsPanel;
talentsPanel:SetPoint("TOPLEFT", viewBar, "BOTTOMLEFT", 0, -6);
talentsPanel:SetPoint("BOTTOMRIGHT", bottomBar, "TOPRIGHT", 0, 6);
talentsPanel:Hide();

local treeColumns = {}; AUI.treeColumns = treeColumns;
for treeIdx = 1, 3 do
    local col = CreateFrame("Frame", nil, talentsPanel);
    col:SetWidth(144);
    col:SetPoint("TOPLEFT", talentsPanel, "TOPLEFT", (treeIdx - 1) * 148, 0);
    col:SetPoint("BOTTOMLEFT", talentsPanel, "BOTTOMLEFT", (treeIdx - 1) * 148, 0);
    col:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    col:SetBackdropColor(0.06, 0.06, 0.08, 0.95);
    col:SetBackdropBorderColor(0.20, 0.20, 0.26, 1);

    -- Header (Spec icon, name, points spent)
    local colHeader = CreateFrame("Frame", nil, col);
    colHeader:SetHeight(28);
    colHeader:SetPoint("TOPLEFT", col, "TOPLEFT", 0, 0);
    colHeader:SetPoint("TOPRIGHT", col, "TOPRIGHT", 0, 0);
    colHeader:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 1 },
    });
    colHeader:SetBackdropColor(0.10, 0.10, 0.14, 0.98);
    colHeader:SetBackdropBorderColor(0.24, 0.24, 0.30, 1);

    local colIcon = colHeader:CreateTexture(nil, "ARTWORK");
    colIcon:SetWidth(20);
    colIcon:SetHeight(20);
    colIcon:SetPoint("LEFT", colHeader, "LEFT", 5, 0);

    local colName = colHeader:CreateFontString(nil, "OVERLAY");
    colName:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    colName:SetPoint("LEFT", colIcon, "RIGHT", 5, 1);
    colName:SetTextColor(1.0, 0.85, 0.2);

    local colPts = colHeader:CreateFontString(nil, "OVERLAY");
    colPts:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    colPts:SetPoint("RIGHT", colHeader, "RIGHT", -5, 1);
    colPts:SetTextColor(0.2, 1.0, 0.3);

    -- Talent Grid Area (7 Tiers x 3 Columns)
    local gridArea = CreateFrame("Frame", nil, col);
    gridArea:SetPoint("TOPLEFT", colHeader, "BOTTOMLEFT", 2, -2);
    gridArea:SetPoint("TOPRIGHT", colHeader, "BOTTOMRIGHT", -2, -2);
    gridArea:SetHeight(226);
    gridArea:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    gridArea:SetBackdropColor(0.04, 0.04, 0.06, 0.95);
    gridArea:SetBackdropBorderColor(0.16, 0.16, 0.20, 1);

    -- Vertical Gold Milestone Connector Line (Behind buttons)
    local lineT3toT5 = gridArea:CreateTexture(nil, "BACKGROUND");
    lineT3toT5:SetTexture(FLAT);
    lineT3toT5:SetWidth(2);
    lineT3toT5:SetPoint("TOP", gridArea, "TOPLEFT", 72, -72);
    lineT3toT5:SetPoint("BOTTOM", gridArea, "TOPLEFT", 72, -155);
    lineT3toT5:SetVertexColor(0.25, 0.25, 0.28, 1);

    local lineT5toT7 = gridArea:CreateTexture(nil, "BACKGROUND");
    lineT5toT7:SetTexture(FLAT);
    lineT5toT7:SetWidth(2);
    lineT5toT7:SetPoint("TOP", gridArea, "TOPLEFT", 72, -135);
    lineT5toT7:SetPoint("BOTTOM", gridArea, "TOPLEFT", 72, -218);
    lineT5toT7:SetVertexColor(0.25, 0.25, 0.28, 1);

    -- 7 Tiers of Talent Buttons (Col 1 = 11, Col 2 = 59, Col 3 = 107)
    local colX = { 11, 59, 107 };
    local gridButtons = {};

    for t = 1, 7 do
        gridButtons[t] = {};
        local tierY = -5 - (t - 1) * 31;
        for c = 1, 3 do
            local btn = CreateFrame("Button", nil, gridArea);
            btn:SetWidth(26);
            btn:SetHeight(26);
            btn:SetPoint("TOPLEFT", gridArea, "TOPLEFT", colX[c], tierY);
            btn:SetBackdrop({
                bgFile = FLAT,
                edgeFile = FLAT,
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            });
            btn:SetBackdropColor(0.08, 0.08, 0.10, 0.9);
            btn:SetBackdropBorderColor(0.22, 0.22, 0.26, 1);
            btn:EnableMouse(true);

            local bIcon = btn:CreateTexture(nil, "ARTWORK");
            bIcon:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1);
            bIcon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1);
            bIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93);

            local badgeFrame = CreateFrame("Frame", nil, btn);
            badgeFrame:SetWidth(18);
            badgeFrame:SetHeight(10);
            badgeFrame:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2);
            badgeFrame:SetBackdrop({
                bgFile = FLAT,
                edgeFile = FLAT,
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
            });
            badgeFrame:SetBackdropColor(0, 0, 0, 0.9);
            badgeFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1);

            local badgeText = badgeFrame:CreateFontString(nil, "OVERLAY");
            badgeText:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE");
            badgeText:SetPoint("CENTER", badgeFrame, "CENTER", 0, 0);

            btn.icon = bIcon;
            btn.badgeFrame = badgeFrame;
            btn.badgeText = badgeText;
            btn.tier = t;
            btn.col = c;

            btn:SetScript("OnEnter", function()
                if this.talentData then
                    local td = this.talentData;
                    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
                    GameTooltip:ClearLines();
                    GameTooltip:AddLine("|cffffd200" .. td.name .. "|r", 1, 1, 1);
                    if td.isMilestone then
                        GameTooltip:AddLine("|cff00ffff" .. td.pts .. " Point Milestone|r", 1, 1, 1);
                    else
                        GameTooltip:AddLine("Rank " .. (td.points or 0) .. " / " .. (td.max or 5), 1, 1, 1);
                    end
                    if td.points and td.points > 0 then
                        GameTooltip:AddLine("|cff00ff00[Skilled in this build]|r", 0.2, 1.0, 0.3);
                    else
                        GameTooltip:AddLine("|cff888888[Not skilled for this build]|r", 0.6, 0.6, 0.6);
                    end
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddLine("|cffffffff" .. (td.desc or "") .. "|r", 1, 1, 1, 1);
                    GameTooltip:Show();
                end
            end);
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide();
            end);

            gridButtons[t][c] = btn;
            btn:Hide();
        end
    end

    -- Milestones Footer Area (10 / 20 / 30 pts)
    local msArea = CreateFrame("Frame", nil, col);
    msArea:SetPoint("TOPLEFT", gridArea, "BOTTOMLEFT", 0, -4);
    msArea:SetPoint("BOTTOMRIGHT", col, "BOTTOMRIGHT", -2, 4);
    msArea:SetBackdrop({
        bgFile = FLAT,
        edgeFile = FLAT,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    msArea:SetBackdropColor(0.04, 0.04, 0.06, 0.95);
    msArea:SetBackdropBorderColor(0.18, 0.18, 0.22, 1);

    local msRows = {};
    local msPts = { 10, 20, 30 };
    for m = 1, 3 do
        local mRow = CreateFrame("Frame", nil, msArea);
        mRow:SetHeight(20);
        mRow:SetPoint("TOPLEFT", msArea, "TOPLEFT", 4, -4 - (m - 1) * 23);
        mRow:SetPoint("TOPRIGHT", msArea, "TOPRIGHT", -4, -4 - (m - 1) * 23);
        mRow:EnableMouse(true);

        local mIcon = mRow:CreateTexture(nil, "ARTWORK");
        mIcon:SetWidth(16);
        mIcon:SetHeight(16);
        mIcon:SetPoint("LEFT", mRow, "LEFT", 2, 0);
        mIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93);

        local mText = mRow:CreateFontString(nil, "OVERLAY");
        mText:SetFont("Fonts\\ARIALN.TTF", 9);
        mText:SetPoint("LEFT", mIcon, "RIGHT", 4, 0);
        mText:SetPoint("RIGHT", mRow, "RIGHT", -2, 0);
        mText:SetJustifyH("LEFT");

        mRow.icon = mIcon;
        mRow.text = mText;
        mRow.pts = msPts[m];

        mRow:SetScript("OnEnter", function()
            if this.msData then
                local md = this.msData;
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
                GameTooltip:ClearLines();
                GameTooltip:AddLine("|cffffd200" .. md.name .. "|r  |cff00ffff(" .. md.pts .. " Points)|r", 1, 1, 1);
                if md.active then
                    GameTooltip:AddLine("|cff00ff00[Unlocked in this build]|r", 0.2, 1.0, 0.3);
                else
                    GameTooltip:AddLine("|cff888888[Locked - Requires " .. md.pts .. " points]|r", 0.6, 0.6, 0.6);
                end
                GameTooltip:AddLine(" ");
                GameTooltip:AddLine("|cffffffff" .. (md.desc or "") .. "|r", 1, 1, 1, 1);
                GameTooltip:Show();
            end
        end);
        mRow:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);

        msRows[m] = mRow;
    end

    col.colHeader = colHeader;
    col.colIcon = colIcon;
    col.colName = colName;
    col.colPts = colPts;
    col.gridArea = gridArea;
    col.lineT3toT5 = lineT3toT5;
    col.lineT5toT7 = lineT5toT7;
    col.gridButtons = gridButtons;
    col.msRows = msRows;

    treeColumns[treeIdx] = col;
end

-- 4th Column: Authentic Armory Summary Panel (Matching Azeroth Survivors Image 2!)
local summaryPanel = CreateFrame("Frame", nil, talentsPanel);
summaryPanel:SetPoint("TOPLEFT", talentsPanel, "TOPLEFT", 448, 0);
summaryPanel:SetPoint("BOTTOMRIGHT", talentsPanel, "BOTTOMRIGHT", 0, 0);
summaryPanel:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
summaryPanel:SetBackdropColor(0.06, 0.06, 0.08, 0.98);
summaryPanel:SetBackdropBorderColor(0.38, 0.32, 0.12, 1);

local sHeader = summaryPanel:CreateFontString(nil, "OVERLAY");
sHeader:SetFont("Fonts\\CinzelDecorative-Bold.ttf", 11, "OUTLINE");
if not sHeader:GetFont() then sHeader:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE"); end
sHeader:SetPoint("TOP", summaryPanel, "TOP", 0, -8);
sHeader:SetTextColor(1.0, 0.82, 0.2);
sHeader:SetText("TALENT POINTS");

local sSpent = summaryPanel:CreateFontString(nil, "OVERLAY");
sSpent:SetFont("Fonts\\CinzelDecorative-Bold.ttf", 16, "OUTLINE");
if not sSpent:GetFont() then sSpent:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE"); end
sSpent:SetPoint("TOP", sHeader, "BOTTOM", 0, -2);
sSpent:SetTextColor(1.0, 0.95, 0.8);
sSpent:SetText("51 SPENT");

local sDist = summaryPanel:CreateFontString(nil, "OVERLAY"); AUI.sDist = sDist;
sDist:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
sDist:SetPoint("TOP", sSpent, "BOTTOM", 0, -2);
sDist:SetPoint("LEFT", summaryPanel, "LEFT", 6, 0);
sDist:SetPoint("RIGHT", summaryPanel, "RIGHT", -6, 0);
sDist:SetJustifyH("CENTER");
sDist:SetTextColor(0.2, 1.0, 0.4);
sDist:SetText("11 / 8 / 32");

local sMax = summaryPanel:CreateFontString(nil, "OVERLAY");
sMax:SetFont("Fonts\\ARIALN.TTF", 9);
sMax:SetPoint("TOP", sDist, "BOTTOM", 0, -2);
sMax:SetPoint("LEFT", summaryPanel, "LEFT", 6, 0);
sMax:SetPoint("RIGHT", summaryPanel, "RIGHT", -6, 0);
sMax:SetJustifyH("CENTER");
sMax:SetTextColor(0.65, 0.65, 0.70);
sMax:SetText("Every talent point earned.");

local sRule1 = summaryPanel:CreateTexture(nil, "ARTWORK");
sRule1:SetTexture(FLAT);
sRule1:SetHeight(1);
sRule1:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 10, -78);
sRule1:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -10, -78);
sRule1:SetVertexColor(0.35, 0.30, 0.15, 0.8);

local sDesc = summaryPanel:CreateFontString(nil, "OVERLAY");
sDesc:SetFont("Fonts\\ARIALN.TTF", 9);
sDesc:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 10, -84);
sDesc:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -10, -84);
sDesc:SetJustifyH("LEFT");
sDesc:SetTextColor(0.80, 0.80, 0.85);
sDesc:SetText("Talents are spent in the armory's Talents tab, between runs. Respecs are free.\n\nPoint at a talent to read it. The milestones at 10, 20 and 30 points change how your spells play.");

local sRule2 = summaryPanel:CreateTexture(nil, "ARTWORK");
sRule2:SetTexture(FLAT);
sRule2:SetHeight(1);
sRule2:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 10, -165);
sRule2:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -10, -165);
sRule2:SetVertexColor(0.35, 0.30, 0.15, 0.8);

local sBuildLabel = summaryPanel:CreateFontString(nil, "OVERLAY");
sBuildLabel:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
sBuildLabel:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 10, -172);
sBuildLabel:SetTextColor(1.0, 0.82, 0.2);
sBuildLabel:SetText("RECOMMENDED BUILD");

local sBuildName = summaryPanel:CreateFontString(nil, "OVERLAY"); AUI.sBuildName = sBuildName;
sBuildName:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
sBuildName:SetPoint("TOPLEFT", sBuildLabel, "BOTTOMLEFT", 0, -3);
sBuildName:SetPoint("RIGHT", summaryPanel, "RIGHT", -10, 0);
sBuildName:SetJustifyH("LEFT");
sBuildName:SetTextColor(1.0, 1.0, 1.0);

local sMsHeader = summaryPanel:CreateFontString(nil, "OVERLAY");
sMsHeader:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
sMsHeader:SetPoint("TOPLEFT", sBuildName, "BOTTOMLEFT", 0, -8);
sMsHeader:SetTextColor(0.0, 0.9, 1.0);
sMsHeader:SetText("ACTIVE MILESTONES:");

local sMsList = summaryPanel:CreateFontString(nil, "OVERLAY"); AUI.sMsList = sMsList;
sMsList:SetFont("Fonts\\ARIALN.TTF", 9);
sMsList:SetPoint("TOPLEFT", sMsHeader, "BOTTOMLEFT", 0, -3);
sMsList:SetPoint("RIGHT", summaryPanel, "RIGHT", -10, 0);
sMsList:SetJustifyH("LEFT");
sMsList:SetTextColor(0.9, 0.9, 0.9);

local tipBox = CreateFrame("Frame", nil, summaryPanel);
tipBox:SetHeight(40);
tipBox:SetPoint("BOTTOMLEFT", summaryPanel, "BOTTOMLEFT", 8, 8);
tipBox:SetPoint("BOTTOMRIGHT", summaryPanel, "BOTTOMRIGHT", -8, 8);
tipBox:SetBackdrop({
    bgFile = FLAT,
    edgeFile = FLAT,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
tipBox:SetBackdropColor(0.04, 0.04, 0.06, 0.9);
tipBox:SetBackdropBorderColor(0.20, 0.20, 0.25, 1);

local tipText = tipBox:CreateFontString(nil, "OVERLAY");
tipText:SetFont("Fonts\\ARIALN.TTF", 8);
tipText:SetPoint("TOPLEFT", tipBox, "TOPLEFT", 6, -4);
tipText:SetPoint("BOTTOMRIGHT", tipBox, "BOTTOMRIGHT", -6, 4);
tipText:SetJustifyH("LEFT");
tipText:SetTextColor(0.7, 0.7, 0.75);
tipText:SetText("|cff00ff00[Tip]|r Hover over any talent button or milestone in the trees to view its full rank effects.");
viewSpellsBtn:SetScript("OnClick", function()
    currentViewMode = "OVERVIEW";
    UpdateViewBarButtons();
    talentsPanel:Hide();
    spellCard:Show();
    gearCard:Show();
    if previewGlowBtn then previewGlowBtn:Show(); end
    BordoUI_BuildAdvisor_Refresh();
end);

viewTalentsBtn:SetScript("OnClick", function()
    currentViewMode = "TALENTS";
    UpdateViewBarButtons();
    spellCard:Hide();
    gearCard:Hide();
    talentsPanel:Show();
    if previewGlowBtn then previewGlowBtn:Hide(); end
    BordoUI_BuildAdvisor_Refresh();
end);

-- ----------------------------------------------------------------------------
-- KILLER FEATURE: Card Choice Glowing & Recommendation HUD
-- Appears directly OVER the Level Up card screen (via AZS_SetOnTopOfScreens)
-- and clearly shows which abilities to pick for your active build!
-- ----------------------------------------------------------------------------

local function RegisterOnTopOfScreens()
    if AZS_SetOnTopOfScreens then
        pcall(AZS_SetOnTopOfScreens, "BordoUI_ChoiceAdvisorHUD", true);
        pcall(AZS_SetOnTopOfScreens, "BordoUI_BuildAdvisorFrame", true);
    end
    if AZS_ON_TOP then
        AZS_ON_TOP["BordoUI_ChoiceAdvisorHUD"] = 1;
        AZS_ON_TOP["BordoUI_BuildAdvisorFrame"] = 1;
        local names = {};
        for n in pairs(AZS_ON_TOP) do
            table.insert(names, n);
        end
        table.sort(names);
        AZS_ON_TOP_FRAMES = table.concat(names, ",");
    end
end

choiceHUD = CreateFrame("Frame", "BordoUI_ChoiceAdvisorHUD", UIParent); AUI.choiceHUD = choiceHUD;
choiceHUD:SetWidth(540);
choiceHUD:SetHeight(124);
choiceHUD:SetPoint("TOP", UIParent, "TOP", 0, -4);
choiceHUD:SetFrameStrata("FULLSCREEN_DIALOG");
choiceHUD:SetFrameLevel(100);
choiceHUD:SetMovable(true);
choiceHUD:EnableMouse(true);
choiceHUD:RegisterForDrag("LeftButton");
choiceHUD:SetClampedToScreen(true);
choiceHUD:Hide();

choiceHUD:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
});
choiceHUD:SetBackdropColor(0.025, 0.025, 0.035, 0.80);
choiceHUD:SetBackdropBorderColor(0.24, 0.22, 0.18, 0.85);

local function SetChoiceHUDScale(scale)
    scale = tonumber(scale) or 1.0;
    if scale < 0.5 then scale = 0.5; end
    if scale > 1.6 then scale = 1.6; end
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.choiceHudScale = scale;
    choiceHUD:SetScale(scale);
    if AUI and AUI.hudScaleText then
        AUI.hudScaleText:SetText(string.format("%d%%", math.floor(scale * 100 + 0.5)));
    end
end

choiceHUD:EnableMouseWheel(true);
choiceHUD:SetScript("OnEnter", function()
    if GameTooltip then GameTooltip:Hide(); end
end);
choiceHUD:SetScript("OnMouseWheel", function()
    BordoUIDB = BordoUIDB or {};
    local cur = BordoUIDB.choiceHudScale or 1.0;
    if arg1 > 0 then
        SetChoiceHUDScale(cur + 0.05);
    else
        SetChoiceHUDScale(cur - 0.05);
    end
end);

choiceHUD:SetScript("OnDragStart", function()
    if IsAltKeyDown() then
        this:StartMoving();
    end
end);
choiceHUD:SetScript("OnDragStop", function()
    this:StopMovingOrSizing();
    local pt, rel, relPt, x, y = this:GetPoint();
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.choiceAdvisorPos = { pt = pt, relPt = relPt, x = x, y = y };
end);

RegisterOnTopOfScreens();

-- Modern Sleek Header Bar
local hudHeaderBar = CreateFrame("Frame", nil, choiceHUD);
hudHeaderBar:SetHeight(18);
hudHeaderBar:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 8, -3);
hudHeaderBar:SetPoint("TOPRIGHT", choiceHUD, "TOPRIGHT", -8, -3);
hudHeaderBar:EnableMouse(true);
hudHeaderBar:SetScript("OnEnter", function()
    if GameTooltip then GameTooltip:Hide(); end
end);

local hudTag = hudHeaderBar:CreateFontString(nil, "OVERLAY"); AUI.hudTag = hudTag;
hudTag:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
hudTag:SetShadowColor(0, 0, 0, 1);
hudTag:SetShadowOffset(1, -1);
hudTag:SetPoint("LEFT", hudHeaderBar, "LEFT", 0, 0);

local hudHeader = hudHeaderBar:CreateFontString(nil, "OVERLAY"); AUI.hudHeader = hudHeader;
hudHeader:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
hudHeader:SetShadowColor(0, 0, 0, 1);
hudHeader:SetShadowOffset(1, -1);
hudHeader:SetPoint("LEFT", hudTag, "RIGHT", 6, 0);

local hudSub = hudHeaderBar:CreateFontString(nil, "OVERLAY"); AUI.hudSub = hudSub;
hudSub:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
hudSub:SetShadowColor(0, 0, 0, 1);
hudSub:SetShadowOffset(1, -1);
hudSub:SetPoint("RIGHT", hudHeaderBar, "RIGHT", -164, 0);
hudSub:SetTextColor(0.90, 0.90, 0.95);
hudSub:SetText("Pick & BiS Advisor");

-- HUD Scaling [-] [100%] [+] Buttons
local function ShowScaleTooltip(btn)
    local target = btn or this;
    if not target then return; end
    GameTooltip:SetOwner(target, "ANCHOR_BOTTOM");
    GameTooltip:ClearLines();
    GameTooltip:AddLine("HUD Scaling", 1, 0.82, 0);
    local curScale = (BordoUIDB and BordoUIDB.choiceHudScale) or 1.0;
    GameTooltip:AddDoubleLine("Current Scale:", string.format("%d%%", math.floor(curScale * 100 + 0.5)), 1, 1, 1, 0.2, 1, 0.2);
    GameTooltip:AddLine(" ");
    GameTooltip:AddLine("Left-Click: Scale +/- 10%", 0.75, 0.75, 0.75);
    GameTooltip:AddLine("Mouse Wheel over HUD: Smooth Scale", 0.75, 0.75, 0.75);
    GameTooltip:AddLine("Right-Click: Reset to 100%", 0.85, 0.85, 0.3);
    GameTooltip:Show();
end

local hudScaleMinus = CreateFrame("Button", nil, hudHeaderBar);
hudScaleMinus:SetWidth(15);
hudScaleMinus:SetHeight(15);
hudScaleMinus:SetPoint("RIGHT", hudHeaderBar, "RIGHT", -144, 0);
hudScaleMinus:SetBackdrop({
    bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
hudScaleMinus:SetBackdropColor(0.04, 0.04, 0.06, 0.70);
hudScaleMinus:SetBackdropBorderColor(0.28, 0.26, 0.22, 0.85);
local smText = hudScaleMinus:CreateFontString(nil, "OVERLAY");
smText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
smText:SetShadowColor(0, 0, 0, 1);
smText:SetShadowOffset(1, -1);
smText:SetPoint("CENTER", hudScaleMinus, "CENTER", 0, 0);
smText:SetTextColor(1, 1, 1);
smText:SetText("-");
hudScaleMinus:RegisterForClicks("LeftButtonUp", "RightButtonUp");
hudScaleMinus:SetScript("OnClick", function()
    BordoUIDB = BordoUIDB or {};
    if arg1 == "RightButton" then
        SetChoiceHUDScale(1.0);
    else
        local cur = BordoUIDB.choiceHudScale or 1.0;
        SetChoiceHUDScale(cur - 0.10);
    end
    PlaySound("igMainMenuOptionCheckBoxOn");
end);
hudScaleMinus:SetScript("OnEnter", function() ShowScaleTooltip(this); end);
hudScaleMinus:SetScript("OnLeave", function() GameTooltip:Hide(); end);

local hudScalePlus = CreateFrame("Button", nil, hudHeaderBar);
hudScalePlus:SetWidth(15);
hudScalePlus:SetHeight(15);
hudScalePlus:SetPoint("RIGHT", hudHeaderBar, "RIGHT", -96, 0);
hudScalePlus:SetBackdrop({
    bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
hudScalePlus:SetBackdropColor(0.04, 0.04, 0.06, 0.70);
hudScalePlus:SetBackdropBorderColor(0.28, 0.26, 0.22, 0.85);
local spText = hudScalePlus:CreateFontString(nil, "OVERLAY");
spText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
spText:SetShadowColor(0, 0, 0, 1);
spText:SetShadowOffset(1, -1);
spText:SetPoint("CENTER", hudScalePlus, "CENTER", 0, 0);
spText:SetTextColor(1, 1, 1);
spText:SetText("+");
hudScalePlus:RegisterForClicks("LeftButtonUp", "RightButtonUp");
hudScalePlus:SetScript("OnClick", function()
    BordoUIDB = BordoUIDB or {};
    if arg1 == "RightButton" then
        SetChoiceHUDScale(1.0);
    else
        local cur = BordoUIDB.choiceHudScale or 1.0;
        SetChoiceHUDScale(cur + 0.10);
    end
    PlaySound("igMainMenuOptionCheckBoxOn");
end);
hudScalePlus:SetScript("OnEnter", function() ShowScaleTooltip(this); end);
hudScalePlus:SetScript("OnLeave", function() GameTooltip:Hide(); end);

local hudScaleText = hudHeaderBar:CreateFontString(nil, "OVERLAY"); AUI.hudScaleText = hudScaleText;
hudScaleText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
hudScaleText:SetShadowColor(0, 0, 0, 1);
hudScaleText:SetShadowOffset(1, -1);
hudScaleText:SetPoint("LEFT", hudScaleMinus, "RIGHT", 2, 0);
hudScaleText:SetPoint("RIGHT", hudScalePlus, "LEFT", -2, 0);
hudScaleText:SetJustifyH("CENTER");
hudScaleText:SetTextColor(1, 0.85, 0.20);
hudScaleText:SetText("100%");

-- View Mode Toggle Button: ALL / SPELLS / JEWELRY
local hudModeBtn = CreateFrame("Button", nil, hudHeaderBar);
hudModeBtn:SetWidth(74);
hudModeBtn:SetHeight(15);
hudModeBtn:SetPoint("RIGHT", hudHeaderBar, "RIGHT", -18, 0);
hudModeBtn:SetBackdrop({
    bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
});
hudModeBtn:SetBackdropColor(0.04, 0.04, 0.06, 0.70);
hudModeBtn:SetBackdropBorderColor(0.28, 0.26, 0.22, 0.85);

local hudModeText = hudModeBtn:CreateFontString(nil, "OVERLAY"); AUI.hudModeText = hudModeText;
hudModeText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
hudModeText:SetShadowColor(0, 0, 0, 1);
hudModeText:SetShadowOffset(1, -1);
hudModeText:SetPoint("CENTER", hudModeBtn, "CENTER", 0, 0);
hudModeText:SetTextColor(0.95, 0.95, 0.95);
hudModeText:SetText("VIEW: ALL");

hudModeBtn:SetScript("OnClick", function()
    BordoUIDB = BordoUIDB or {};
    local cur = BordoUIDB.choiceHudMode or "ALL";
    if cur == "ALL" then
        BordoUIDB.choiceHudMode = "SPELLS";
    elseif cur == "SPELLS" then
        BordoUIDB.choiceHudMode = "JEWELRY";
    else
        BordoUIDB.choiceHudMode = "ALL";
    end
    PlaySound("igMainMenuOptionCheckBoxOn");
    RefreshChoiceHUD();
end);

local hudClose = CreateFrame("Button", nil, hudHeaderBar);
hudClose:SetWidth(15);
hudClose:SetHeight(15);
hudClose:SetPoint("RIGHT", hudHeaderBar, "RIGHT", 0, 0);
local hudCloseText = hudClose:CreateFontString(nil, "OVERLAY");
hudCloseText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
hudCloseText:SetShadowColor(0, 0, 0, 1);
hudCloseText:SetShadowOffset(1, -1);
hudCloseText:SetPoint("CENTER", hudClose, "CENTER", 0, 0);
hudCloseText:SetTextColor(1.0, 0.40, 0.40);
hudCloseText:SetText("x");
hudClose:SetScript("OnClick", function()
    manualChoiceHUD = false;
    choiceHUD:Hide();
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.showChoiceHUD = false;
    if prevText then prevText:SetText("|cffffd200Preview Choice HUD|r"); end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Choice HUD hidden. Type |cff00ccff/guide hud on|r to show it again.");
end);

-- 6 Modern Sleek Horizontal Spell Slot Cards (Row 1)
local hudSlots = {}; AUI.hudSlots = hudSlots;
for i = 1, 6 do
    local slot = CreateFrame("Button", nil, choiceHUD);
    slot:SetWidth(84);
    slot:SetHeight(44);
    slot:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 8 + (i - 1) * 88, -24);
    slot:SetBackdrop({
        bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    slot:SetBackdropColor(0.02, 0.02, 0.04, 0.25);
    slot:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.35);

    local glow = slot:CreateTexture(nil, "BACKGROUND");
    glow:SetPoint("TOPLEFT", slot, "TOPLEFT", -2, 2);
    glow:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2);
    glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
    glow:SetBlendMode("ADD");
    glow:SetAlpha(0.85);
    glow:Hide();
    slot.glow = glow;

    local icon = slot:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(24);
    icon:SetHeight(24);
    icon:SetPoint("LEFT", slot, "LEFT", 4, 0);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

    local badge = slot:CreateFontString(nil, "OVERLAY");
    badge:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    badge:SetShadowColor(0, 0, 0, 1);
    badge:SetShadowOffset(1, -1);
    badge:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1);
    badge:SetTextColor(1, 0.85, 0.2);

    local sTitle = slot:CreateFontString(nil, "OVERLAY");
    sTitle:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    sTitle:SetShadowColor(0, 0, 0, 1);
    sTitle:SetShadowOffset(1, -1);
    sTitle:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 2);
    sTitle:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -2, 2);
    sTitle:SetJustifyH("LEFT");
    sTitle:SetTextColor(1, 1, 1);

    local status = slot:CreateFontString(nil, "OVERLAY");
    status:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    status:SetShadowColor(0, 0, 0, 1);
    status:SetShadowOffset(1, -1);
    status:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 4, -2);
    status:SetTextColor(0.0, 1.0, 0.4);

    slot.icon = icon;
    slot.badge = badge;
    slot.status = status;
    slot.sTitle = sTitle;

    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    slot:SetScript("OnClick", function()
        if arg1 == "RightButton" and this.spellData then
            local spKey = this.spellData.key or string.lower(string.gsub(this.spellData.name, "[%s%p_]", ""));
            BordoUI_BanishedSpells = BordoUI_BanishedSpells or {};
            if BordoUI_BanishedSpells[spKey] then
                BordoUI_BanishedSpells[spKey] = nil;
                DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Unbanished |cff00ff00" .. this.spellData.name .. "|r from Choice HUD.");
            else
                BordoUI_BanishedSpells[spKey] = true;
                DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r |cffff4444BANISHED|r |cffffd200" .. this.spellData.name .. "|r from Choice HUD (Right-click again to unbanish).");
            end
            PlaySound("igMainMenuOptionCheckBoxOn");
            RefreshChoiceHUD();
        end
    end);

    slot:SetScript("OnEnter", function()
        HideJewelryTooltip();
        if this.spellData then
            GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("|cffffd200" .. this.spellData.name .. "|r  |cff00ff00(Pick Priority #" .. (this.spellData.prio or 1) .. ")|r", 1, 1, 1);
            GameTooltip:AddLine("|cff888888" .. (this.spellData.school or "Ability") .. " Ability|r", 1, 1, 1);
            GameTooltip:AddLine(" ");
            GameTooltip:AddLine("|cffffffff" .. (this.spellData.reason or "") .. "|r", 1, 1, 1, 1);
            GameTooltip:AddLine(" ");
            GameTooltip:AddLine("|cff888888Right-Click: Banish / Unbanish spell|r", 0.6, 0.6, 0.6);
            GameTooltip:Show();
        end
    end);
    slot:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    hudSlots[i] = slot;
end

-- 5 Modern Sleek Horizontal BiS Jewelry & Trinket Cards (Row 2)
local JEWELRY_HUD_DEFS = {
    { key = "neck",     label = "NECK",   slotName = "Necklace" },
    { key = "ring1",    label = "RING 1", slotName = "Finger 1" },
    { key = "ring2",    label = "RING 2", slotName = "Finger 2" },
    { key = "trinket1", label = "TRK 1",  slotName = "Trinket 1" },
    { key = "trinket2", label = "TRK 2",  slotName = "Trinket 2" },
};

local hudJewelrySlots = {}; AUI.hudJewelrySlots = hudJewelrySlots;
for j = 1, 5 do
    local jDef = JEWELRY_HUD_DEFS[j];
    local jSlot = CreateFrame("Button", nil, choiceHUD);
    jSlot:SetWidth(102);
    jSlot:SetHeight(44);
    jSlot:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 7 + (j - 1) * 106, -72);
    jSlot:SetBackdrop({
        bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    });
    jSlot:SetBackdropColor(0.02, 0.02, 0.04, 0.25);
    jSlot:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.35);

    local glow = jSlot:CreateTexture(nil, "BACKGROUND");
    glow:SetPoint("TOPLEFT", jSlot, "TOPLEFT", -2, 2);
    glow:SetPoint("BOTTOMRIGHT", jSlot, "BOTTOMRIGHT", 2, -2);
    glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
    glow:SetBlendMode("ADD");
    glow:SetAlpha(0.85);
    glow:Hide();
    jSlot.glow = glow;

    local icon = jSlot:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(24);
    icon:SetHeight(24);
    icon:SetPoint("LEFT", jSlot, "LEFT", 5, 0);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

    local slotLabel = jSlot:CreateFontString(nil, "OVERLAY");
    slotLabel:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    slotLabel:SetShadowColor(0, 0, 0, 1);
    slotLabel:SetShadowOffset(1, -1);
    slotLabel:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 2);
    slotLabel:SetTextColor(1, 0.82, 0.30);
    slotLabel:SetText(jDef.label);

    local jTitle = jSlot:CreateFontString(nil, "OVERLAY");
    jTitle:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE");
    jTitle:SetShadowColor(0, 0, 0, 1);
    jTitle:SetShadowOffset(1, -1);
    jTitle:SetPoint("LEFT", icon, "RIGHT", 5, 1);
    jTitle:SetPoint("RIGHT", jSlot, "RIGHT", -3, 1);
    jTitle:SetJustifyH("LEFT");
    jTitle:SetTextColor(1, 1, 1);

    local status = jSlot:CreateFontString(nil, "OVERLAY");
    status:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    status:SetShadowColor(0, 0, 0, 1);
    status:SetShadowOffset(1, -1);
    status:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 5, -2);
    status:SetTextColor(0.0, 1.0, 0.4);

    jSlot.icon = icon;
    jSlot.slotLabel = slotLabel;
    jSlot.jTitle = jTitle;
    jSlot.status = status;
    jSlot.jDef = jDef;

    jSlot:SetScript("OnEnter", function()
        if GameTooltip then GameTooltip:Hide(); end
        if this.jewelryData then
            ShowJewelryTooltip(this, this.jewelryData, this.isEquipped, this.jDef.slotName, "BOTTOM");
        end
    end);
    jSlot:SetScript("OnLeave", function()
        HideJewelryTooltip();
        GameTooltip:Hide();
    end);

    jSlot:SetScript("OnClick", function()
        BordoUI_ToggleBuildAdvisor();
    end);

    hudJewelrySlots[j] = jSlot;
end

-- (IsJewelryEquipped is defined above line 783 for universal access across Tooltips and HUD)

-- Robust Function to check current rank of a spell across AZS_SPELLS, keys, names and ActionBars
local function GetLearnedRank(sp)
    if not sp then return 0; end
    local spKey = sp.key or "";
    local spName = sp.name or "";

    local cleanKey = string.lower(string.gsub(spKey, "[^%a]", ""));
    local cleanName = string.lower(string.gsub(spName, "[^%a]", ""));
    if cleanKey == "" and cleanName == "" then return 0; end

    -- Authoritative check: AZS_SPELLS table managed by Azeroth Survivors engine
    if AZS_SPELLS and table.getn(AZS_SPELLS) > 0 then
        for idx = 1, table.getn(AZS_SPELLS) do
            local e = AZS_SPELLS[idx];
            if e then
                local eRank = tonumber(e.rank or e[3]) or 1;
                
                -- Check e.key or e[1]
                local rawKey = e.key or e[1];
                if rawKey and rawKey ~= "" then
                    local eCleanKey = string.lower(string.gsub(tostring(rawKey), "[^%a]", ""));
                    if eCleanKey ~= "" and (eCleanKey == cleanKey or eCleanKey == cleanName) then
                        return eRank;
                    end
                end

                -- Check e.spell or e[2] (string spell name)
                local rawSpell = e.spell or e[2];
                if rawSpell and type(rawSpell) == "string" and rawSpell ~= "" then
                    local eCleanSpell = string.lower(string.gsub(rawSpell, "[^%a]", ""));
                    if eCleanSpell ~= "" and (eCleanSpell == cleanKey or eCleanSpell == cleanName) then
                        return eRank;
                    end
                end
            end
        end
    end

    return 0;
end

-- Refresh Choice HUD with active build spells & intelligent BiS Jewelry tracking
RefreshChoiceHUD = function()
    local ui = BordoUI_AdvisorUI or AUI;
    local choiceHUD = ui.choiceHUD;
    local hudTag = ui.hudTag;
    local hudHeader = ui.hudHeader;
    local hudSub = ui.hudSub;
    local hudModeText = ui.hudModeText;
    local hudSlots = ui.hudSlots;
    local hudJewelrySlots = ui.hudJewelrySlots;
    local activateBtn = ui.activateBtn;
    local activationBanner = ui.activationBanner;
    local prevText = ui.prevText;
    local previewGlowBtn = ui.previewGlowBtn;
    RegisterOnTopOfScreens();
    local activeBuild, actClass, actIdx = BordoUI_GetActiveBuild();
    if not (activeBuild and activeBuild.spells) then
        choiceHUD:Hide();
        return;
    end

    local cInfo = BordoUI_BuildData.Classes[actClass] or { name = actClass, color = { 1, 1, 1 } };
    local cHex = string.format("%02x%02x%02x", cInfo.color[1] * 255, cInfo.color[2] * 255, cInfo.color[3] * 255);

    local bTitle = string.upper(activeBuild.title or "BUILD");
    if string.len(bTitle) > 13 then
        bTitle = string.sub(bTitle, 1, 12) .. ".";
    end
    hudTag:SetText("|cff" .. cHex .. "[" .. string.upper(cInfo.name) .. "]|r");
    hudHeader:SetText("|cffffd200" .. bTitle .. "|r");

    -- Determine view mode: ALL (both rows), SPELLS, JEWELRY
    BordoUIDB = BordoUIDB or {};
    local hudMode = BordoUIDB.choiceHudMode or "ALL";
    hudModeText:SetText("VIEW: " .. hudMode);

    if hudMode == "ALL" then
        choiceHUD:SetHeight(124);
        for i = 1, 6 do
            hudSlots[i]:ClearAllPoints();
            hudSlots[i]:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 8 + (i - 1) * 88, -24);
            hudSlots[i]:Show();
        end
        for j = 1, 5 do
            hudJewelrySlots[j]:ClearAllPoints();
            hudJewelrySlots[j]:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 7 + (j - 1) * 106, -72);
            hudJewelrySlots[j]:Show();
        end
    elseif hudMode == "SPELLS" then
        choiceHUD:SetHeight(72);
        for i = 1, 6 do
            hudSlots[i]:ClearAllPoints();
            hudSlots[i]:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 8 + (i - 1) * 88, -24);
            hudSlots[i]:Show();
        end
        for j = 1, 5 do
            hudJewelrySlots[j]:Hide();
        end
    elseif hudMode == "JEWELRY" then
        choiceHUD:SetHeight(72);
        for i = 1, 6 do
            hudSlots[i]:Hide();
        end
        for j = 1, 5 do
            hudJewelrySlots[j]:ClearAllPoints();
            hudJewelrySlots[j]:SetPoint("TOPLEFT", choiceHUD, "TOPLEFT", 7 + (j - 1) * 106, -24);
            hudJewelrySlots[j]:Show();
        end
    end

    -- Detect total learned regular spells in current run from Azeroth Survivors engine
    -- The last entry in AZS_SPELLS is the racial ability on button 12.
    -- Regular card picks occupy buttons 1 to 6.
    local totalSpells = (AZS_SPELLS and table.getn(AZS_SPELLS)) or 0;
    local numLearned = math.max(0, totalSpells - 1);
    local isSlotsFull = (numLearned >= 6);

    BordoUI_BanishedSpells = BordoUI_BanishedSpells or {};

    -- Update Row 1: 6 Spells
    -- Slot #1: Priority slot: if unlearned -> "[PICK #1]", once learned -> steady "PRIO" (antique gold, no blink).
    -- Slots #2 to #6: If unlearned and free slots exist -> "[PICK]" in green! Once learned -> ONLY spell name centered vertically.
    -- No MAX anywhere; no slots dimmed or greyed out.
    for i = 1, 6 do
        local slot = hudSlots[i];
        local sp = activeBuild.spells[i];
        if sp and sp.name then
            slot.spellData = sp;
            slot.icon:SetTexture(sp.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
            slot.icon:SetVertexColor(1, 1, 1);
            slot.badge:SetText("#" .. (sp.prio or i));
            slot.glow:Hide();

            local displayName = sp.name;
            if string.len(displayName) > 11 then
                displayName = string.sub(displayName, 1, 10) .. ".";
            end
            slot.sTitle:SetText(displayName);

            local spKey = sp.key or string.lower(string.gsub(sp.name, "[%s%p_]", ""));
            local isBanished = BordoUI_BanishedSpells[spKey];
            local curRank = GetLearnedRank(sp);

            if isBanished then
                slot.sTitle:ClearAllPoints();
                slot.sTitle:SetPoint("TOPLEFT", slot.icon, "TOPRIGHT", 4, 2);
                slot.sTitle:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -2, 2);
                slot.status:SetText("|cffff4444[BANISHED]|r");
                slot.status:Show();
                slot:SetAlpha(0.35);
                slot.icon:SetVertexColor(0.4, 0.4, 0.4);
                slot:SetBackdropColor(0.15, 0.05, 0.05, 0.25);
                slot:SetBackdropBorderColor(0.40, 0.15, 0.15, 0.50);
            elseif i == 1 then
                -- Slot 1: ALWAYS Priority Slot
                slot.sTitle:ClearAllPoints();
                slot.sTitle:SetPoint("TOPLEFT", slot.icon, "TOPRIGHT", 4, 2);
                slot.sTitle:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -2, 2);
                slot:SetAlpha(1.0);
                if not isSlotsFull and curRank == 0 then
                    slot.status:SetText("|cff4ade80[PICK #1]|r");
                    slot.status:Show();
                    slot:SetBackdropColor(0.03, 0.08, 0.04, 0.35);
                    slot:SetBackdropBorderColor(0.25, 0.70, 0.38, 0.85);
                else
                    slot.status:SetText("|cffdfba66PRIO|r");
                    slot.status:Show();
                    slot:SetBackdropColor(0.05, 0.04, 0.02, 0.40);
                    slot:SetBackdropBorderColor(0.70, 0.58, 0.28, 0.90);
                end
            elseif not isSlotsFull and curRank == 0 then
                -- Slots 2 to 6: NOT YET LEARNED and free slot exists -> SHOW [PICK] in soft green!
                slot.sTitle:ClearAllPoints();
                slot.sTitle:SetPoint("TOPLEFT", slot.icon, "TOPRIGHT", 4, 2);
                slot.sTitle:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -2, 2);
                slot.status:SetText("|cff34d399[PICK]|r");
                slot.status:Show();
                slot:SetAlpha(1.0);
                slot:SetBackdropColor(0.02, 0.05, 0.03, 0.28);
                slot:SetBackdropBorderColor(0.18, 0.48, 0.26, 0.65);
            else
                -- Slots 2 to 6: LEARNED (or slots full): ONLY spell name, centered vertically, no Rank/MAX
                slot.sTitle:ClearAllPoints();
                slot.sTitle:SetPoint("LEFT", slot.icon, "RIGHT", 4, 0);
                slot.sTitle:SetPoint("RIGHT", slot, "RIGHT", -2, 0);
                slot.status:SetText("");
                slot.status:Hide();
                slot:SetAlpha(1.0);
                slot:SetBackdropColor(0.02, 0.02, 0.04, 0.30);
                slot:SetBackdropBorderColor(0.24, 0.22, 0.18, 0.70);
            end
        else
            slot.spellData = nil;
            if hudMode ~= "JEWELRY" then slot:Hide(); end
        end
    end

    -- Update Row 2: 5 BiS Jewelry Slots
    local numEquippedJewelry = 0;
    local numTotalJewelry = 0;

    for j = 1, 5 do
        local jSlot = hudJewelrySlots[j];
        local jDef = JEWELRY_HUD_DEFS[j];
        local itm = activeBuild.jewelry and activeBuild.jewelry[jDef.key];

        if itm then
            numTotalJewelry = numTotalJewelry + 1;
            local itmObj = itm;
            if type(itm) ~= "table" then
                itmObj = { name = tostring(itm), quality = 4, icon = "Interface\\Icons\\INV_Jewelry_Necklace_01" };
            end
            itmObj.slotKey = jDef.key;
            if jDef.key == "neck" then
                itmObj.slotType = "NECK";
                if (not itmObj.spell or itmObj.spell == "") and itmObj.name and string.find(itmObj.name, ":") then
                    local _, _, sp = string.find(itmObj.name, ":%s*([^:]+)");
                    if sp then
                        itmObj.spell = string.gsub(sp, "%s+[IVXLCDMivxlcdm%d]+$", "");
                    end
                end
                if itmObj.name == "Amulet of the Inferno: Exorcism" or itmObj.spell == "Exorcism" or string.find(itmObj.name or "", "Exorcism") then
                    itmObj.name = "Eye of the Splitting Sky: Exorcism";
                    itmObj.icon = "Interface\\Icons\\INV_Jewelry_Necklace_16";
                    itmObj.benefit = "+1 Tgt, +24% Dmg, Leap";
                    itmObj.desc = "Legendary amulet - remakes Exorcism\nEquip: Exorcism strikes 1 more target.\nEquip: Increases the damage of Exorcism by 24%.\nEquip: Exorcism's hits leap to 2 more enemies for 36%.";
                    itmObj.spell = "Exorcism";
                    itmObj.quality = 5;
                end
            elseif jDef.key == "ring1" or jDef.key == "ring2" then
                itmObj.slotType = "RING";
            else
                itmObj.slotType = "TRINKET";
            end
            jSlot.jewelryData = itmObj;
            jSlot.icon:SetTexture(NormalizeIconPath(itmObj.icon));

            local qColor = ITEM_QUALITY_COLORS[itmObj.quality or 4] or { r = 1, g = 1, b = 1 };
            local displayName = itmObj.name or "Jewelry";
            if string.len(displayName) > 12 then
                displayName = string.sub(displayName, 1, 11) .. ".";
            end
            jSlot.jTitle:SetText(displayName);
            jSlot.jTitle:SetTextColor(qColor.r, qColor.g, qColor.b);

            local isEq = IsJewelryEquipped(itmObj);
            jSlot.isEquipped = isEq;

            local itmBenefit = itmObj.benefit or "";
            if string.len(itmBenefit) > 14 then
                itmBenefit = string.sub(itmBenefit, 1, 13) .. ".";
            end

            if isEq then
                numEquippedJewelry = numEquippedJewelry + 1;
                jSlot.status:SetText("|cff888888[Equipped]|r");
                jSlot.glow:Hide();
                jSlot:SetAlpha(0.55);
                jSlot:SetBackdropColor(0.02, 0.02, 0.03, 0.20);
                jSlot:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.30);
            else
                jSlot.status:SetText("|cff7cb57c" .. itmBenefit .. "|r");
                jSlot.glow:Hide();
                jSlot:SetAlpha(0.95);
                jSlot:SetBackdropColor(0.025, 0.035, 0.025, 0.30);
                jSlot:SetBackdropBorderColor(0.26, 0.28, 0.22, 0.75);
            end
        else
            jSlot.jewelryData = nil;
            jSlot.isEquipped = false;
            jSlot.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
            jSlot.jTitle:SetText("Not set");
            jSlot.jTitle:SetTextColor(0.5, 0.5, 0.5);
            jSlot.status:SetText("|cff555555Empty|r");
            jSlot.glow:Hide();
            jSlot:SetAlpha(0.35);
            jSlot:SetBackdropBorderColor(0.14, 0.14, 0.18, 0.5);
        end
    end

    if isSlotsFull then
        hudSub:SetText("|cffffd2006/6 Spells|r - |cffffffff" .. numEquippedJewelry .. "/5 BiS Gear|r");
    else
        hudSub:SetText("|cffffd200Pick Advisor|r |cffffffff(" .. numLearned .. "/6 Spells - " .. numEquippedJewelry .. "/5 BiS)|r");
    end
end

-- ----------------------------------------------------------------------------
activateBtn:SetScript("OnClick", function()
    local activeBuild, actClass, actIdx = BordoUI_GetActiveBuild();
    local isAlreadyActive = (activeBuild ~= nil and actClass == currentClass and actIdx == currentBuildIdx);

    if not isAlreadyActive then
        -- Activate the newly selected build
        local b = BordoUI_SetActiveBuild(currentClass, currentBuildIdx);
        if b then
            PlaySound("QUESTCOMPLETED");
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Active Build set to |cff00ff00" .. b.title .. "|r (" .. currentClass .. "). Recommended spells will glow during card choices!");
            activationBanner:SetText("|cff00ff00[- BUILD ACTIVATED]|r");
            activationBanner:Show();
        end
        -- Immediately show the Glowing Choice HUD so the user sees it in action!
        manualChoiceHUD = true;
        RefreshChoiceHUD();
        choiceHUD:Show();
        if prevText then prevText:SetText("|cff00ff00Hide Choice HUD|r"); end
    else
        -- Already active: Clicking it again DEACTIVATES the build for this run!
        BordoUI_ClearActiveBuild();
        PlaySound("igMainMenuOptionCheckBoxOff");
        manualChoiceHUD = false;
        choiceHUD:Hide();
        if prevText then prevText:SetText("|cffffd200Preview Choice HUD|r"); end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Active Build deactivated for this run.");
    end

    BordoUI_BuildAdvisor_Refresh();
end);

previewGlowBtn:SetScript("OnClick", function()
    manualChoiceHUD = not manualChoiceHUD;
    if manualChoiceHUD then
        PlaySound("igMainMenuOptionCheckBoxOn");
        prevText:SetText("|cff00ff00Hide Choice HUD|r");
        RefreshChoiceHUD();
        choiceHUD:Show();
    else
        PlaySound("igMainMenuOptionCheckBoxOff");
        prevText:SetText("|cffffd200Preview Choice HUD|r");
        choiceHUD:Hide();
    end
end);

-- ----------------------------------------------------------------------------
-- Refresh Advisor View
-- ----------------------------------------------------------------------------
function BordoUI_BuildAdvisor_Refresh()
    local ui = BordoUI_AdvisorUI or AUI;
    local classButtons = ui.classButtons;
    local buildTabs = ui.buildTabs;
    local topBar = ui.topBar;
    local renameBtn = ui.renameBtn;
    local catalogDrawer = ui.catalogDrawer;
    local activateBtn = ui.activateBtn;
    local activationBanner = ui.activationBanner;
    local buildTitle = ui.buildTitle;
    local buildRole = ui.buildRole;
    local buildSummary = ui.buildSummary;
    local viewDistText = ui.viewDistText;
    local buildStats = ui.buildStats;
    local spellRows = ui.spellRows;
    local gearSlots = ui.gearSlots or gearSlots;
    local gearRows = ui.gearRows;
    local sBuildName = ui.sBuildName;
    local sDist = ui.sDist;
    local treeColumns = ui.treeColumns;
    local sMsList = ui.sMsList;
    local spellCard = ui.spellCard;
    local gearCard = ui.gearCard;
    local talentsPanel = ui.talentsPanel;
    local previewGlowBtn = ui.previewGlowBtn;
    local tacticsText = ui.tacticsText;

    -- Update class list buttons
    for cKey, btn in pairs(classButtons) do
        local cInfo = BordoUI_BuildData.Classes[cKey];
        if cKey == currentClass then
            btn:SetBackdropColor(cInfo.color[1] * 0.35, cInfo.color[2] * 0.35, cInfo.color[3] * 0.35, 1);
            btn:SetBackdropBorderColor(cInfo.color[1], cInfo.color[2], cInfo.color[3], 1);
        else
            btn:SetBackdropColor(0.10, 0.10, 0.14, 0.85);
            btn:SetBackdropBorderColor(0.20, 0.20, 0.26, 1);
        end
    end

    -- Update 3 Custom Build Tabs (Build 1, Build 2, Build 3)
    for t = 1, 3 do
        local b = GetCustomBuild(currentClass, t);
        local tab = buildTabs[t];
        if tab and b then
            tab:SetWidth(104);
            tab:ClearAllPoints();
            tab:SetPoint("LEFT", topBar, "LEFT", 10 + (t - 1) * 108, 0);
            local tTitle = b.title or ("Build " .. t);
            if string.len(tTitle) > 13 then
                tTitle = string.sub(tTitle, 1, 11) .. "..";
            end
            tab.text:SetText(tTitle);
            tab:Show();
            if currentBuildIdx == t then
                tab:SetBackdropColor(0.24, 0.24, 0.32, 1);
                tab:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
            else
                tab:SetBackdropColor(0.12, 0.12, 0.16, 0.9);
                tab:SetBackdropBorderColor(0.24, 0.24, 0.28, 1);
            end
        end
    end

    local curBuild = GetCurrentAdvisorBuild();
    if not curBuild then return; end

    -- Rename button is always available for custom builds
    if renameBtn then
        renameBtn:Show();
    end

    -- Check if this build is currently the ACTIVE tracked build
    local activeBuild, actClass, actIdx = BordoUI_GetActiveBuild();
    local isActive = (activeBuild ~= nil and actClass == currentClass and actIdx == currentBuildIdx);

    if isActive then
        activateBtn:SetBackdropColor(0.10, 0.28, 0.10, 0.95);
        activateBtn:SetBackdropBorderColor(0.20, 1.00, 0.20, 1);
        activateBtn.text:SetText("|cff00ff00[ACTIVE IN RUN]|r");
        activationBanner:SetText("|cff00ff00[ACTIVE - SPELLS GLOW]|r");
        activationBanner:Show();
    else
        activateBtn:SetBackdropColor(0.22, 0.18, 0.05, 0.95);
        activateBtn:SetBackdropBorderColor(1.00, 0.82, 0.00, 1);
        activateBtn.text:SetText("|cffffd200[ACTIVATE FOR RUN]|r");
        activationBanner:Hide();
    end

    -- Update Info Card
    local cInfo = BordoUI_BuildData.Classes[currentClass];
    buildTitle:SetText(curBuild.title or "Custom Build");
    buildTitle:SetTextColor(cInfo.color[1], cInfo.color[2], cInfo.color[3]);
    buildRole:SetText("[" .. (curBuild.role or "Custom Build") .. "]");
    buildSummary:SetText(curBuild.summary or curBuild.desc or "Craft your own custom build by selecting spells and jewelry.");

    if curBuild.talents then
        viewDistText:SetText("|cffffd200Talents:|r |cff00ff00" .. curBuild.talents.summary .. " (51 Pts)|r");
    else
        viewDistText:SetText("|cff888888Custom (Freestyle Talents)|r");
    end

    if currentViewMode == "TALENTS" then
        if curBuild.talents then
            buildStats:SetText("|cffffd200Talent Distribution:|r |cff00ff00" .. curBuild.talents.summary .. "|r  |cffffd200Stat Priority:|r " .. (curBuild.statPriority or "Any"));
        else
            buildStats:SetText("|cffffd200Custom Build:|r |cff00ff00Freestyle Talents|r  |cffffd200Stat Priority:|r " .. (curBuild.statPriority or "Choose in game"));
        end
    else
        buildStats:SetText("|cffffd200Stat Priority:|r " .. (curBuild.statPriority or "Custom") .. "  |cff888888(Talents: " .. (curBuild.talents and curBuild.talents.summary or "Freestyle") .. ")|r");
    end

    -- Update Spell Rows (All 3 builds are custom and fully configurable!)
    for sIdx = 1, 6 do
        local r = spellRows[sIdx];
        local sp = curBuild.spells and curBuild.spells[sIdx];

        if sp then
            if r.selectBtn then r.selectBtn:Show(); end
            if r.upBtn then r.upBtn:Show(); end
            if r.downBtn then r.downBtn:Show(); end
            if r.clearBtn then r.clearBtn:Show(); end

            r.icon:SetTexture(sp.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
            local sColor = SCHOOL_COLORS[sp.school] or { 1, 1, 1 };
            r.sName:SetText(sp.name .. " |cff888888(" .. (sp.school or "Physical") .. ")|r");
            r.sName:SetTextColor(sColor[1], sColor[2], sColor[3]);
            r.reason:SetText(sp.reason or ("Custom Priority #" .. sIdx));

            if isActive then
                r.badge:SetText("|cff00ff00#" .. sIdx .. "|r");
                if r.glow then r.glow:Show(); end
            else
                r.badge:SetText("#" .. sIdx);
                if r.glow then r.glow:Hide(); end
            end

            r:Show();
        else
            -- Empty slot: show placeholder + pick button
            if r.selectBtn then r.selectBtn:Show(); end
            if r.upBtn then r.upBtn:Hide(); end
            if r.downBtn then r.downBtn:Hide(); end
            if r.clearBtn then r.clearBtn:Hide(); end

            r.icon:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-Relic");
            r.sName:SetText("|cff777777[Empty Priority #" .. sIdx .. "]|r");
            r.sName:SetTextColor(0.5, 0.5, 0.5);
            r.reason:SetText("|cff00ff00Click row or [+ Pick] to choose a spell|r");
            r.badge:SetText("#" .. sIdx);
            if r.glow then r.glow:Hide(); end
            r:Show();
        end
    end

    -- Update Gear Rows (All 5 slots interactive for all 3 custom builds)
    for gIdx = 1, (gearSlots and table.getn(gearSlots) or 0) do
        local gInfo = gearSlots[gIdx];
        local gr = gearRows[gInfo.key];
        local itm = curBuild.jewelry and curBuild.jewelry[gInfo.key];

        if gr.clearBtn then
            if itm then gr.clearBtn:Show(); else gr.clearBtn:Hide(); end
        end

        if itm then
            gr.icon:SetTexture(NormalizeIconPath(itm.icon));
            local qColor = QUALITY_COLORS[itm.quality or 4] or { 0.64, 0.21, 0.93 };
            gr.iName:SetText(itm.name);
            gr.iName:SetTextColor(qColor[1], qColor[2], qColor[3]);
            gr.benefit:SetText(itm.benefit or (itm.slot or gInfo.label));
            gr:Show();
        else
            local slotIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. ((gInfo.key == "neck") and "Neck" or ((gInfo.key == "ring1" or gInfo.key == "ring2") and "Finger" or "Trinket"));
            gr.icon:SetTexture(slotIcon);
            gr.iName:SetText("|cff777777[Empty " .. gInfo.label .. "]|r");
            gr.iName:SetTextColor(0.5, 0.5, 0.5);
            gr.benefit:SetText("|cff00ff00Click to slot jewelry|r");
            gr:Show();
        end
    end

    -- Update Authentic Talents Grid & Summary Panel (Matching Azeroth Survivors Image 2)
    if curBuild.talents and curBuild.talents.trees then
        local tTrees = curBuild.talents.trees;
        sBuildName:SetText("|cffffd200" .. (curBuild.name or "Build") .. "|r");
        sDist:SetText(curBuild.talents.summary or "11 / 8 / 32");

        local activeMsText = "";
        local msPositions = { { 3, 2 }, { 5, 2 }, { 7, 2 } };
        local defaultSlots = {
            { 1, 1 }, { 1, 3 },
            { 2, 1 }, { 2, 3 },
            { 4, 1 }, { 4, 3 },
            { 5, 1 }, { 5, 3 },
            { 6, 1 }, { 6, 3 },
            { 3, 1 }, { 3, 3 },
            { 7, 1 }, { 7, 3 },
        };

        for tIdx = 1, 3 do
            local col = treeColumns[tIdx];
            local tree = tTrees[tIdx];
            if col and tree then
                col.colIcon:SetTexture(tree.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
                col.colName:SetText(tree.name);
                local treePts = tree.points or 0;
                if treePts > 0 then
                    col.colPts:SetText("|cff00ff00" .. treePts .. " points|r");
                else
                    col.colPts:SetText("|cff7777770 points|r");
                end

                -- Milestone Connector Lines
                if treePts >= 20 then
                    col.lineT3toT5:SetVertexColor(1.0, 0.82, 0.0, 1);
                else
                    col.lineT3toT5:SetVertexColor(0.25, 0.25, 0.28, 1);
                end
                if treePts >= 30 then
                    col.lineT5toT7:SetVertexColor(1.0, 0.82, 0.0, 1);
                else
                    col.lineT5toT7:SetVertexColor(0.25, 0.25, 0.28, 1);
                end

                -- Reset buttons
                for t = 1, 7 do
                    for c = 1, 3 do
                        col.gridButtons[t][c]:Hide();
                        col.gridButtons[t][c].talentData = nil;
                    end
                end

                -- Populate 3 Milestones (Tier 3 Col 2, Tier 5 Col 2, Tier 7 Col 2)
                if tree.milestones then
                    for m = 1, 3 do
                        local mData = tree.milestones[m];
                        local pos = msPositions[m];
                        if mData and pos and col.gridButtons[pos[1]] and col.gridButtons[pos[1]][pos[2]] then
                            local btn = col.gridButtons[pos[1]][pos[2]];
                            btn.talentData = {
                                name = mData.name,
                                desc = mData.desc,
                                icon = mData.icon or tree.icon,
                                isMilestone = true,
                                pts = mData.pts,
                                points = (treePts >= mData.pts) and 1 or 0,
                                max = 1,
                            };
                            btn.icon:SetTexture(mData.icon or tree.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
                            if treePts >= mData.pts then
                                btn.icon:SetVertexColor(1, 1, 1);
                                btn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
                                btn.badgeText:SetText("|cffffd2001/1|r");
                                btn.badgeFrame:SetBackdropBorderColor(0.6, 0.5, 0.1, 1);
                            else
                                btn.icon:SetVertexColor(0.26, 0.26, 0.26);
                                btn:SetBackdropBorderColor(0.18, 0.18, 0.22, 0.8);
                                btn.badgeText:SetText("|cff6666660/1|r");
                                btn.badgeFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1);
                            end
                            btn:Show();
                        end
                    end
                end

                -- Populate Regular Talents
                if tree.talents then
                    local sSlot = 1;
                    local numTalents = table.getn(tree.talents);
                    for tRank = 1, numTalents do
                        local tData = tree.talents[tRank];
                        if tData then
                            local r = tData.row;
                            local c = tData.col;
                            if not (r and c) then
                                local dSlot = defaultSlots[sSlot];
                                if dSlot then
                                    r = dSlot[1];
                                    c = dSlot[2];
                                    sSlot = sSlot + 1;
                                end
                            end
                            if r and c and col.gridButtons[r] and col.gridButtons[r][c] then
                                local btn = col.gridButtons[r][c];
                                btn.talentData = tData;
                                btn.icon:SetTexture(tData.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
                                local pts = tData.points or 0;
                                local maxPts = tData.max or 5;
                                if pts > 0 then
                                    btn.icon:SetVertexColor(1, 1, 1);
                                    if pts >= maxPts then
                                        btn:SetBackdropBorderColor(0.2, 1.0, 0.3, 1);
                                        btn.badgeText:SetText("|cff00ff00" .. pts .. "/" .. maxPts .. "|r");
                                    else
                                        btn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1);
                                        btn.badgeText:SetText("|cffffd200" .. pts .. "/" .. maxPts .. "|r");
                                    end
                                    btn.badgeFrame:SetBackdropBorderColor(0.3, 0.5, 0.2, 1);
                                else
                                    btn.icon:SetVertexColor(0.26, 0.26, 0.26);
                                    btn:SetBackdropBorderColor(0.18, 0.18, 0.22, 0.8);
                                    btn.badgeText:SetText("|cff6666660/" .. maxPts .. "|r");
                                    btn.badgeFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1);
                                end
                                btn:Show();
                            end
                        end
                    end
                end

                -- Milestones Footer Rows
                if tree.milestones then
                    for m = 1, 3 do
                        local mData = tree.milestones[m];
                        local mRow = col.msRows[m];
                        if mData and mRow then
                            mRow.msData = mData;
                            mRow.icon:SetTexture(mData.icon or tree.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
                            if treePts >= mData.pts then
                                mRow.icon:SetVertexColor(1, 1, 1);
                                mRow.text:SetText("|cff00ffff" .. mData.pts .. " points|r  |cffffffff" .. mData.name .. "|r");
                                activeMsText = activeMsText .. "|cff00ff00*|r " .. mData.name .. "\n   |cff00ffff(" .. tree.name .. " " .. mData.pts .. "p)|r\n";
                            else
                                mRow.icon:SetVertexColor(0.28, 0.28, 0.28);
                                mRow.text:SetText("|cff555555" .. mData.pts .. " points  " .. mData.name .. "|r");
                            end
                            mRow:Show();
                        elseif mRow then
                            mRow:Hide();
                        end
                    end
                end
            end
        end

        if activeMsText == "" then
            sMsList:SetText("|cff777777None unlocked yet|r");
        else
            sMsList:SetText(activeMsText);
        end
    end
    -- Update View Mode Visibilities & Tactics Text
    UpdateViewBarButtons();
    if currentViewMode == "TALENTS" then
        spellCard:Hide();
        gearCard:Hide();
        talentsPanel:Show();
        if previewGlowBtn then previewGlowBtn:Hide(); end
        tacticsText:SetText("|cffffd200Armory Guide:|r Spend 51 talent points across the 3 trees as shown above. Respecs are free in Armory.");
    else
        talentsPanel:Hide();
        spellCard:Show();
        gearCard:Show();
        if previewGlowBtn then previewGlowBtn:Show(); end
        if curBuild.tactics and curBuild.tactics[1] then
            tacticsText:SetText("|cffffd200Meta Tip:|r " .. curBuild.tactics[1]);
        else
            tacticsText:SetText("");
        end
    end

    -- If catalog drawer is open while switching classes/builds, update it immediately
    if catalogDrawer and catalogDrawer:IsShown() and UpdateCatalogDrawerList then
        UpdateCatalogDrawerList();
    end
end

function BordoUI_ToggleBuildAdvisor()
    if advisorFrame:IsShown() then
        advisorFrame:Hide();
    else
        -- Default to player class on first open
        local _, pClass = UnitClass("player");
        if pClass and BordoUI_BuildData.Classes[pClass] then
            currentClass = pClass;
        end
        local activeBuild, actClass, actIdx = BordoUI_GetActiveBuild();
        if activeBuild and actClass and actClass == currentClass and actIdx then
            currentBuildIdx = actIdx;
        end
        BordoUI_BuildAdvisor_Refresh();
        advisorFrame:Show();
    end
end

function BordoUI_ToggleChoiceHUD()
    if choiceHUD:IsShown() then
        manualChoiceHUD = false;
        choiceHUD:Hide();
        if AUI and AUI.prevText then AUI.prevText:SetText("|cffffd200Preview Choice HUD|r"); end
    else
        manualChoiceHUD = true;
        RefreshChoiceHUD();
        choiceHUD:Show();
        if AUI and AUI.prevText then AUI.prevText:SetText("|cff00ff00Hide Choice HUD|r"); end
    end
end

-- ----------------------------------------------------------------------------
-- Dedicated Always-On Watcher Frame
-- NEVER HIDDEN: Guarantees OnUpdate fires continuously regardless of UI state!
-- ----------------------------------------------------------------------------
local watcher = CreateFrame("Frame", "BordoUI_ChoiceWatcherFrame", UIParent);
watcher:SetWidth(1);
watcher:SetHeight(1);
watcher:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -100, -100);
watcher:Show();

local elapsedTotal = 0;
local checkTimer = 0;
local lastRunTime = 0;

watcher:SetScript("OnUpdate", function()
    local dt = arg1 or 0.05;
    elapsedTotal = elapsedTotal + dt;

    -- Pulsing glow sine animation: smooth oscillation between 0.35 and 1.0
    local pulseAlpha = 0.40 + 0.45 * math.sin(elapsedTotal * 5.5);

    -- Animate glow on Choice HUD if shown
    if choiceHUD and choiceHUD:IsShown() then
        for i = 1, 6 do
            local slot = hudSlots[i];
            if slot and slot.glow and slot.glow:IsShown() then
                slot.glow:SetAlpha(pulseAlpha);
            end
        end
        for j = 1, 5 do
            local jSlot = hudJewelrySlots and hudJewelrySlots[j];
            if jSlot and jSlot.glow and jSlot.glow:IsShown() then
                jSlot.glow:SetAlpha(pulseAlpha);
            end
        end
    end

    -- Animate glow on Advisor spell rows if advisor is shown
    if advisorFrame and advisorFrame:IsShown() then
        for sIdx = 1, 6 do
            local r = spellRows[sIdx];
            if r and r.glow and r.glow:IsShown() then
                r.glow:SetAlpha(pulseAlpha);
            end
        end
    end

    checkTimer = checkTimer + dt;
    checkTimerRefresh = (checkTimerRefresh or 0) + dt;

    if checkTimer >= 0.15 then
        checkTimer = 0;

        -- Check in-game Azeroth Survivors phase and run time
        local phase = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph);
        local runT = (AZS_GetRunTime and AZS_GetRunTime()) or (AZS_RUN and tonumber(AZS_RUN.t)) or 0;

        -- Reset Active in Run when round ends or new round is ready/started
        local isNewRound = (phase == "ready" or phase == "dead" or phase == "victory");
        if not isNewRound and lastRunTime and lastRunTime > 5 and runT < 2 then
            isNewRound = true;
        end
        lastRunTime = runT;

        if isNewRound then
            if BordoUI_BanishedSpells and next(BordoUI_BanishedSpells) then
                BordoUI_BanishedSpells = {};
            end
            if BordoUIDB and BordoUIDB.activeBuild then
                BordoUI_ClearActiveBuild();
                manualChoiceHUD = false;
                if choiceHUD and choiceHUD:IsShown() then choiceHUD:Hide(); end
                if advisorFrame and advisorFrame:IsShown() then
                    BordoUI_BuildAdvisor_Refresh();
                end
            end
        end

        local stored = (AZS_GetStoredLevels and AZS_GetStoredLevels()) or (SurvivorUI_StoredLevels and SurvivorUI_StoredLevels()) or 0;
        local isChoosing = (phase == "choosing" or phase == "level_up" or (stored > 0 and (phase == "paused" or phase == "playing")));

        local activeBuild = BordoUI_GetActiveBuild();

        if manualChoiceHUD and activeBuild then
            if not choiceHUD:IsShown() then
                choiceHUD:Show();
            end
        else
            if isChoosing and activeBuild then
                if (BordoUIDB and BordoUIDB.showChoiceHUD == false) then
                    if choiceHUD:IsShown() then choiceHUD:Hide(); end
                else
                    RegisterOnTopOfScreens();
                    if not choiceHUD:IsShown() then
                        choiceHUD:Show();
                    end
                end
            else
                if choiceHUD:IsShown() then
                    choiceHUD:Hide();
                end
            end
        end

        -- Keep Choice HUD updated live as cards are picked during run!
        if choiceHUD:IsShown() then
            local curUpdated = AZS_SPELLS_UPDATED or 0;
            if curUpdated ~= (lastSpellsUpdated or -1) or checkTimerRefresh >= 0.35 then
                lastSpellsUpdated = curUpdated;
                checkTimerRefresh = 0;
                RefreshChoiceHUD();
            end
        end
    end
end);

watcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
watcher:RegisterEvent("PLAYER_AURAS_CHANGED");
watcher:RegisterEvent("UNIT_INVENTORY_CHANGED");
watcher:RegisterEvent("BAG_UPDATE");
watcher:RegisterEvent("PLAYER_ENTERING_WORLD");
watcher:SetScript("OnEvent", function()
    if choiceHUD and choiceHUD:IsShown() then
        RefreshChoiceHUD();
    end
end);

-- ----------------------------------------------------------------------------
-- Slash Commands & Init
-- ----------------------------------------------------------------------------
SLASH_BORDOBUILDGUIDE1 = "/buildguide";
SLASH_BORDOBUILDGUIDE2 = "/builds";
SLASH_BORDOBUILDGUIDE3 = "/metabuild";
SLASH_BORDOBUILDGUIDE4 = "/guide";

SlashCmdList["BORDOBUILDGUIDE"] = function(msg)
    local cmd = msg and string.lower(string.gsub(msg, "^%s*(.-)%s*$", "%1")) or "";
    if cmd == "test" then
        manualChoiceHUD = not manualChoiceHUD;
        if manualChoiceHUD then
            RefreshChoiceHUD();
            choiceHUD:Show();
            if prevText then prevText:SetText("|cff00ff00Hide Choice HUD|r"); end
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Choice HUD Test active (Alt+Drag to move). Type |cff00ccff/guide test|r to close.");
        else
            choiceHUD:Hide();
            if prevText then prevText:SetText("|cffffd200Preview Choice HUD|r"); end
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Choice HUD Test closed.");
        end
        return;
    elseif cmd == "hud off" or cmd == "off" then
        BordoUIDB = BordoUIDB or {};
        BordoUIDB.showChoiceHUD = false;
        manualChoiceHUD = false;
        choiceHUD:Hide();
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Level Up Pick HUD disabled. Type |cff00ccff/guide hud on|r to enable.");
        return;
    elseif cmd == "hud on" or cmd == "on" then
        BordoUIDB = BordoUIDB or {};
        BordoUIDB.showChoiceHUD = true;
        manualChoiceHUD = true;
        RefreshChoiceHUD();
        choiceHUD:Show();
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Level Up Pick HUD enabled and previewing.");
        return;
    elseif string.sub(cmd, 1, 5) == "scale" then
        local val = tonumber(string.sub(cmd, 6));
        if val then
            if val > 10 then val = val / 100; end
            SetChoiceHUDScale(val);
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Choice HUD Scale set to |cff00ff00" .. math.floor(val * 100 + 0.5) .. "%|r.");
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100BordoUI:|r Usage: |cff00ccff/guide scale 0.8|r (50% to 160%)");
        end
        return;
    end
    BordoUI_ToggleBuildAdvisor();
end;

local initFrame = CreateFrame("Frame");
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
initFrame:SetScript("OnEvent", function()
    RegisterOnTopOfScreens();
    BordoUI_BanishedSpells = {};
    -- Deactivate Active in Run by default on startup
    BordoUI_ClearActiveBuild();
    manualChoiceHUD = false;
    if choiceHUD then choiceHUD:Hide(); end
    if advisorFrame then advisorFrame:Hide(); end

    -- Restore position if saved
    if BordoUIDB and BordoUIDB.buildAdvisorPos then
        local pos = BordoUIDB.buildAdvisorPos;
        advisorFrame:ClearAllPoints();
        advisorFrame:SetPoint(pos.pt or "CENTER", UIParent, pos.relPt or "CENTER", pos.x or 0, pos.y or 20);
    end
    if BordoUIDB and BordoUIDB.choiceAdvisorPos then
        local pos = BordoUIDB.choiceAdvisorPos;
        choiceHUD:ClearAllPoints();
        choiceHUD:SetPoint(pos.pt or "TOP", UIParent, pos.relPt or "TOP", pos.x or 0, pos.y or -4);
    end
    if BordoUIDB and BordoUIDB.choiceHudScale then
        SetChoiceHUDScale(BordoUIDB.choiceHudScale);
    end
end);
