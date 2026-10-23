--[[
    Bordo UI - Modern Party Unit Frames (PartyFrames.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    - Sleek dark glass theme matching Bordo UI
    - Square cropped 3D portraits with Leader crown & Dead/Offline overlays
    - Class-colored health bars with live HP & percentage
    - Power bars (Mana / Rage / Energy)
    - Freely movable container with saved position & global lock support
    - Cleanly suppresses default Blizzard party frames to eliminate overlaps
    - Click-to-target & right-click party member dropdown menu
    - Live Test Mode (/bordo party test or /partyframes test)
]]--

BordoUI = BordoUI or {};
BordoUI.Party = {};

local testModeActive = false;
local updateElapsed = 0;

-- Class Colors Table (English, German, and Russian localized mappings)
local CLASS_COLORS = {
    -- English standard
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 },
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 },
    ["PRIEST"]      = { r = 0.90, g = 0.90, b = 0.90 },
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 },
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 },
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 },
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 },

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

    -- Russian localized
    ["ВОИН"]        = { r = 0.78, g = 0.61, b = 0.43 },
    ["ПАЛАДИН"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["ОХОТНИК"]     = { r = 0.67, g = 0.83, b = 0.45 },
    ["РАЗБОЙНИК"]   = { r = 1.00, g = 0.96, b = 0.41 },
    ["ЖРЕЦ"]        = { r = 0.90, g = 0.90, b = 0.90 },
    ["ШАМАН"]       = { r = 0.00, g = 0.44, b = 0.87 },
    ["МАГ"]         = { r = 0.41, g = 0.80, b = 0.94 },
    ["ЧЕРНОКНИЖНИК"]= { r = 0.58, g = 0.51, b = 0.79 },
    ["ДРУИД"]       = { r = 1.00, g = 0.49, b = 0.04 },
};

-- Power Bar Colors
local POWER_COLORS = {
    [0] = { r = 0.15, g = 0.40, b = 0.90 }, -- Mana (Blue)
    [1] = { r = 0.85, g = 0.20, b = 0.20 }, -- Rage (Red)
    [2] = { r = 0.95, g = 0.55, b = 0.10 }, -- Focus (Orange)
    [3] = { r = 0.90, g = 0.80, b = 0.15 }, -- Energy (Yellow)
};

local function GetUnitClassColor(unit)
    if ( not unit ) then return { r = 0.41, g = 0.80, b = 0.94 }; end
    local locCls, engCls = UnitClass(unit);
    if ( engCls ) then
        local u = string.upper(engCls);
        if ( CLASS_COLORS[u] ) then return CLASS_COLORS[u]; end
    end
    if ( locCls ) then
        local u = string.upper(locCls);
        if ( CLASS_COLORS[u] ) then return CLASS_COLORS[u]; end
    end
    if ( RAID_CLASS_COLORS and engCls and RAID_CLASS_COLORS[engCls] ) then
        return RAID_CLASS_COLORS[engCls];
    end
    return { r = 0.41, g = 0.80, b = 0.94 };
end

-- =========================================================================
-- 1. CLEANLY SUPPRESS BLIZZARD DEFAULT PARTY FRAMES
-- =========================================================================
local function SuppressBlizzardPartyFrames()
    for i = 1, 4 do
        local blizz = getglobal("PartyMemberFrame" .. i);
        if ( blizz ) then
            blizz:UnregisterAllEvents();
            blizz:Hide();
            blizz:ClearAllPoints();
            blizz:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -2000, 2000);
        end
    end
    if ( PartyMemberFrame_UpdateMember ) then
        PartyMemberFrame_UpdateMember = function() end;
    end
    if ( PartyMemberFrame_Update ) then
        PartyMemberFrame_Update = function() end;
    end
end

-- =========================================================================
-- 2. CREATE PARTY FRAMES CONTAINER
-- =========================================================================
local container = CreateFrame("Frame", "BordoUI_PartyContainer", UIParent);
container:SetWidth(185);
container:SetHeight(180);
container:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 142, -120);
container:SetFrameStrata("LOW");
container:SetFrameLevel(10);
container:SetClampedToScreen(true);
container:SetMovable(true);
container:EnableMouse(true);

-- Container Background Backdrop
container:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
container:SetBackdropColor(0.04, 0.04, 0.05, 0.92);
container:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.95);

-- Top Cyan Accent Line
local cyanAccent = container:CreateTexture(nil, "OVERLAY");
cyanAccent:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -2);
cyanAccent:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", -2, -4);
cyanAccent:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
cyanAccent:SetVertexColor(0.0, 0.85, 0.95, 1.0);

-- Header Bar
local header = CreateFrame("Frame", "BordoUI_PartyHeader", container);
header:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -4);
header:SetPoint("TOPRIGHT", container, "TOPRIGHT", -2, -4);
header:SetHeight(18);
header:EnableMouse(true);

local headerTitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
headerTitle:SetPoint("LEFT", header, "LEFT", 4, 0);
headerTitle:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
headerTitle:SetText("|cff00ccffBORDO UI|r |cffffd100PARTY|r");

local memberCountText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
memberCountText:SetPoint("RIGHT", header, "RIGHT", -22, 0);
memberCountText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
memberCountText:SetText("|cff00e5ff[ 0 / 4 ]|r");

-- Interactive Lock Indicator Button in Header
local lockIndicator = CreateFrame("Button", "BordoUI_PartyLockBtn", header);
lockIndicator:SetWidth(16);
lockIndicator:SetHeight(14);
lockIndicator:SetPoint("RIGHT", header, "RIGHT", -2, 0);

local lockText = lockIndicator:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
lockText:SetPoint("CENTER", lockIndicator, "CENTER", 0, 0);
lockText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
lockText:SetText("|cff55ff55[U]|r");

lockIndicator:SetScript("OnClick", function()
    if ( BordoUI.ToggleLock ) then
        BordoUI:ToggleLock();
    end
end);

local function UpdatePartyLockIndicator()
    if ( BordoUIDB and BordoUIDB.locked ) then
        lockText:SetText("|cffff4444[L]|r");
    else
        lockText:SetText("|cff55ff55[U]|r");
    end
end

-- Draggable Handlers for Container & Header
local function OnDragStartHandler()
    if ( BordoUIDB and BordoUIDB.locked ) then return; end
    container:StartMoving();
end

local function OnDragStopHandler()
    container:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = container:GetPoint();
        BordoUIDB.partyPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end

container:RegisterForDrag("LeftButton");
container:SetScript("OnDragStart", OnDragStartHandler);
container:SetScript("OnDragStop", OnDragStopHandler);

header:RegisterForDrag("LeftButton");
header:SetScript("OnDragStart", OnDragStartHandler);
header:SetScript("OnDragStop", OnDragStopHandler);

-- =========================================================================
-- 3. INDIVIDUAL PARTY MEMBER FRAMES (1 to 4)
-- =========================================================================
local memberFrames = {};

local function CreatePartyMemberFrame(id)
    local f = CreateFrame("Button", "BordoUI_PartyMember" .. id, container);
    f:SetWidth(177);
    f:SetHeight(38);
    f.partyId = id;
    f.unit = "party" .. id;
    f:EnableMouse(true);
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    f:RegisterForDrag("LeftButton");
    
    -- Member Card Backdrop
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    f:SetBackdropColor(0.04, 0.04, 0.05, 0.95);
    f:SetBackdropBorderColor(0.14, 0.14, 0.18, 0.95);

    -- Anchor within Container
    if ( id == 1 ) then
        f:SetPoint("TOPLEFT", container, "TOPLEFT", 4, -22);
    else
        f:SetPoint("TOPLEFT", memberFrames[id - 1], "BOTTOMLEFT", 0, -4);
    end

    -- Left: Square Cropped Portrait Box (32x32)
    local pBox = CreateFrame("Frame", nil, f);
    pBox:SetWidth(32);
    pBox:SetHeight(32);
    pBox:SetPoint("LEFT", f, "LEFT", 3, 0);
    pBox:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 }
    });
    pBox:SetBackdropColor(0.02, 0.02, 0.02, 1.0);
    pBox:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.90);

    local portrait = pBox:CreateTexture(nil, "ARTWORK");
    portrait:SetPoint("TOPLEFT", pBox, "TOPLEFT", 2, -2);
    portrait:SetPoint("BOTTOMRIGHT", pBox, "BOTTOMRIGHT", -2, 2);
    portrait:SetTexCoord(0.12, 0.88, 0.12, 0.88);
    f.portrait = portrait;

    -- Leader Crown Icon
    local leaderIcon = pBox:CreateTexture(nil, "OVERLAY");
    leaderIcon:SetWidth(14);
    leaderIcon:SetHeight(14);
    leaderIcon:SetPoint("TOPLEFT", pBox, "TOPLEFT", -3, 3);
    leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
    leaderIcon:Hide();
    f.leaderIcon = leaderIcon;

    -- Dead / Offline Overlay Text on Portrait
    local statusOverlay = pBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    statusOverlay:SetPoint("CENTER", pBox, "CENTER", 0, 0);
    statusOverlay:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    statusOverlay:SetText("");
    statusOverlay:Hide();
    f.statusOverlay = statusOverlay;

    -- Right Info Area:
    -- Row 1: Name (Left) & Level (Right)
    local nameText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    nameText:SetPoint("TOPLEFT", pBox, "TOPRIGHT", 5, 0);
    nameText:SetPoint("RIGHT", f, "RIGHT", -32, 0);
    nameText:SetJustifyH("LEFT");
    nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    nameText:SetText(f.unit);
    f.nameText = nameText;

    local levelText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    levelText:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -3);
    levelText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    levelText:SetTextColor(0.95, 0.82, 0.15); -- Gold
    levelText:SetText("");
    f.levelText = levelText;

    -- Row 2: Health Bar (Height 13px)
    local hpBar = CreateFrame("StatusBar", nil, f);
    hpBar:SetPoint("TOPLEFT", pBox, "TOPRIGHT", 5, -14);
    hpBar:SetPoint("RIGHT", f, "RIGHT", -5, 0);
    hpBar:SetHeight(13);
    hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    hpBar:SetMinMaxValues(0, 100);
    hpBar:SetValue(100);
    f.hpBar = hpBar;

    local hpBg = hpBar:CreateTexture(nil, "BACKGROUND");
    hpBg:SetAllPoints(hpBar);
    hpBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
    hpBg:SetVertexColor(0.08, 0.08, 0.10, 0.85);
    f.hpBg = hpBg;

    local hpText = hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    hpText:SetPoint("CENTER", hpBar, "CENTER", 0, 0);
    hpText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    hpText:SetTextColor(1, 1, 1, 1);
    f.hpText = hpText;

    -- Row 3: Slim Power Bar (Height 3px)
    local powerBar = CreateFrame("StatusBar", nil, f);
    powerBar:SetPoint("TOPLEFT", hpBar, "BOTTOMLEFT", 0, -1);
    powerBar:SetPoint("TOPRIGHT", hpBar, "BOTTOMRIGHT", 0, -1);
    powerBar:SetHeight(3);
    powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    powerBar:SetMinMaxValues(0, 100);
    powerBar:SetValue(100);
    f.powerBar = powerBar;

    local powerBg = powerBar:CreateTexture(nil, "BACKGROUND");
    powerBg:SetAllPoints(powerBar);
    powerBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
    powerBg:SetVertexColor(0.05, 0.05, 0.08, 0.9);
    f.powerBg = powerBg;

    -- Interactive Click & Drag Handling
    f:SetScript("OnClick", function()
        if ( arg1 == "LeftButton" ) then
            if ( not testModeActive ) then
                TargetUnit(f.unit);
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Clicked test unit " .. f.nameText:GetText());
            end
        elseif ( arg1 == "RightButton" ) then
            if ( not testModeActive ) then
                local drop = getglobal("PartyMemberFrame" .. id .. "DropDown");
                if ( drop ) then
                    pcall(ToggleDropDownMenu, 1, nil, drop, "cursor");
                end
            end
        end
    end);

    f:SetScript("OnDragStart", OnDragStartHandler);
    f:SetScript("OnDragStop", OnDragStopHandler);

    -- Tooltips & Border Glow on Hover
    f:SetScript("OnEnter", function()
        f:SetBackdropBorderColor(0.0, 0.85, 0.95, 1.0); -- Cyan hover glow
        if ( not testModeActive and UnitExists(f.unit) ) then
            GameTooltip_SetDefaultAnchor(GameTooltip, f);
            GameTooltip:SetUnit(f.unit);
            GameTooltip:Show();
        end
    end);

    f:SetScript("OnLeave", function()
        f:SetBackdropBorderColor(0.14, 0.14, 0.18, 0.95);
        if ( not testModeActive ) then
            GameTooltip:Hide();
        end
    end);

    memberFrames[id] = f;
    return f;
end

for i = 1, 4 do
    CreatePartyMemberFrame(i);
end

-- =========================================================================
-- 4. UPDATE FUNCTIONS (Live Data & Test Mode)
-- =========================================================================
local TEST_PARTY_MEMBERS = {
    [1] = { name = "Byoo",       class = "SHAMAN",  level = 10, hp = 1450, maxHp = 1450, power = 2100, maxPower = 2100, powerType = 0, leader = true },
    [2] = { name = "Wunderling", class = "MAGE",    level = 10, hp = 980,  maxHp = 1120, power = 1800, maxPower = 2400, powerType = 0, leader = false },
    [3] = { name = "Doprecious", class = "WARRIOR", level = 9,  hp = 1850, maxHp = 2200, power = 45,   maxPower = 100,  powerType = 1, leader = false },
    [4] = { name = "Wildsomon",  class = "PRIEST",  level = 10, hp = 1200, maxHp = 1300, power = 1950, maxPower = 2500, powerType = 0, leader = false },
};

function BordoUI:UpdatePartyMember(id)
    local f = memberFrames[id];
    if ( not f ) then return; end

    -- TEST MODE DISPLAY
    if ( testModeActive ) then
        local data = TEST_PARTY_MEMBERS[id];
        if ( not data ) then f:Hide(); return; end
        f:Show();
        
        -- Name & Class
        local cCol = CLASS_COLORS[data.class] or { r = 0.41, g = 0.80, b = 0.94 };
        f.nameText:SetText(data.name);
        f.nameText:SetTextColor(cCol.r, cCol.g, cCol.b, 1.0);
        f.levelText:SetText(tostring(data.level));
        
        -- Health Bar
        f.hpBar:SetMinMaxValues(0, data.maxHp);
        f.hpBar:SetValue(data.hp);
        f.hpBar:SetStatusBarColor(cCol.r, cCol.g, cCol.b, 1.0);
        local pct = math.floor((data.hp / data.maxHp) * 100);
        f.hpText:SetText(string.format("%d (%d%%)", data.hp, pct));
        f.hpBg:SetVertexColor(cCol.r * 0.25, cCol.g * 0.25, cCol.b * 0.25, 0.85);

        -- Power Bar
        local pCol = POWER_COLORS[data.powerType] or POWER_COLORS[0];
        f.powerBar:SetMinMaxValues(0, data.maxPower);
        f.powerBar:SetValue(data.power);
        f.powerBar:SetStatusBarColor(pCol.r, pCol.g, pCol.b, 1.0);
        f.powerBar:Show();

        -- Portrait & Leader
        SetPortraitTexture(f.portrait, "player");
        if ( data.leader ) then
            f.leaderIcon:Show();
        else
            f.leaderIcon:Hide();
        end
        f.statusOverlay:Hide();
        f:SetAlpha(1.0);
        return;
    end

    -- LIVE PARTY MEMBER DATA
    local unit = f.unit;
    if ( not UnitExists(unit) ) then
        f:Hide();
        return;
    end
    f:Show();

    local name = UnitName(unit) or "Unknown";
    local level = UnitLevel(unit);
    local isDead = UnitIsDead(unit) or UnitIsGhost(unit);
    local isConnected = UnitIsConnected(unit);
    local isLeader = UnitIsPartyLeader(unit);

    -- Class Color
    local cCol = GetUnitClassColor(unit);
    f.nameText:SetText(name);
    f.nameText:SetTextColor(cCol.r, cCol.g, cCol.b, 1.0);

    -- Level
    if ( level and level > 0 ) then
        f.levelText:SetText(tostring(level));
    else
        f.levelText:SetText("");
    end

    -- Health
    local hp = UnitHealth(unit) or 0;
    local maxHp = UnitHealthMax(unit) or 1;
    if ( maxHp <= 0 ) then maxHp = 1; end
    f.hpBar:SetMinMaxValues(0, maxHp);
    f.hpBar:SetValue(hp);
    f.hpBar:SetStatusBarColor(cCol.r, cCol.g, cCol.b, 1.0);
    f.hpBg:SetVertexColor(cCol.r * 0.25, cCol.g * 0.25, cCol.b * 0.25, 0.85);

    -- Status & Health Text
    if ( not isConnected ) then
        f.hpText:SetText("|cff888888OFFLINE|r");
        f.statusOverlay:SetText("|cff888888OFF|r");
        f.statusOverlay:Show();
        f:SetAlpha(0.60);
    elseif ( isDead ) then
        f.hpText:SetText("|cffff2222DEAD|r");
        f.statusOverlay:SetText("|cffff2222DEAD|r");
        f.statusOverlay:Show();
        f:SetAlpha(0.75);
    else
        local pct = math.floor((hp / maxHp) * 100);
        f.hpText:SetText(string.format("%d (%d%%)", hp, pct));
        f.statusOverlay:Hide();

        -- Range check fade (dim slightly if party member is far away)
        if ( CheckInteractDistance and not CheckInteractDistance(unit, 4) ) then
            f:SetAlpha(0.80);
        else
            f:SetAlpha(1.0);
        end
    end

    -- Power / Mana
    local pType = UnitPowerType(unit) or 0;
    local pVal = UnitMana(unit) or 0;
    local pMax = UnitManaMax(unit) or 1;
    if ( pMax <= 0 ) then pMax = 1; end

    local pCol = POWER_COLORS[pType] or POWER_COLORS[0];
    f.powerBar:SetMinMaxValues(0, pMax);
    f.powerBar:SetValue(pVal);
    f.powerBar:SetStatusBarColor(pCol.r, pCol.g, pCol.b, 1.0);
    f.powerBar:Show();

    -- Portrait & Leader Icon
    SetPortraitTexture(f.portrait, unit);
    if ( isLeader ) then
        f.leaderIcon:Show();
    else
        f.leaderIcon:Hide();
    end
end

function BordoUI:UpdatePartyFrames()
    UpdatePartyLockIndicator();

    if ( testModeActive ) then
        container:Show();
        memberCountText:SetText("|cff00e5ff[ 4 / 4 ]|r");
        container:SetHeight(22 + 4 * 42 + 2);
        for i = 1, 4 do
            BordoUI:UpdatePartyMember(i);
        end
        return;
    end

    local numParty = GetNumPartyMembers() or 0;
    if ( numParty <= 0 ) then
        container:Hide();
        return;
    end

    container:Show();
    memberCountText:SetText(string.format("|cff00e5ff[ %d / 4 ]|r", numParty));
    container:SetHeight(22 + numParty * 42 + 2);

    for i = 1, 4 do
        if ( i <= numParty ) then
            BordoUI:UpdatePartyMember(i);
        else
            if ( memberFrames[i] ) then memberFrames[i]:Hide(); end
        end
    end
end

-- =========================================================================
-- 5. EVENT LISTENER & TICKER
-- =========================================================================
local partyListener = CreateFrame("Frame", "BordoUI_PartyListenerFrame");
partyListener:RegisterEvent("VARIABLES_LOADED");
partyListener:RegisterEvent("PLAYER_ENTERING_WORLD");
partyListener:RegisterEvent("PARTY_MEMBERS_CHANGED");
partyListener:RegisterEvent("PARTY_LEADER_CHANGED");
partyListener:RegisterEvent("PARTY_MEMBER_ENABLE");
partyListener:RegisterEvent("PARTY_MEMBER_DISABLE");
partyListener:RegisterEvent("UNIT_HEALTH");
partyListener:RegisterEvent("UNIT_MANA");
partyListener:RegisterEvent("UNIT_RAGE");
partyListener:RegisterEvent("UNIT_ENERGY");
partyListener:RegisterEvent("UNIT_MAXHEALTH");
partyListener:RegisterEvent("UNIT_MAXMANA");
partyListener:RegisterEvent("UNIT_PORTRAIT_UPDATE");

partyListener:SetScript("OnEvent", function()
    if ( event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" ) then
        SuppressBlizzardPartyFrames();
        if ( BordoUIDB and BordoUIDB.partyPos ) then
            BordoUI:RestorePosition(container, BordoUIDB.partyPos);
        end
        BordoUI:UpdatePartyFrames();
    elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
        SuppressBlizzardPartyFrames();
        BordoUI:UpdatePartyFrames();
    elseif ( arg1 and string.sub(arg1, 1, 5) == "party" ) then
        local id = tonumber(string.sub(arg1, 6));
        if ( id and id >= 1 and id <= 4 ) then
            BordoUI:UpdatePartyMember(id);
        end
    end
end);

-- Smooth OnUpdate Ticker (0.15s update interval for live combat responsiveness)
partyListener:SetScript("OnUpdate", function()
    local dt = arg1 or 0.15;
    updateElapsed = updateElapsed + dt;
    if ( updateElapsed >= 0.15 ) then
        updateElapsed = 0;
        if ( testModeActive or (GetNumPartyMembers() and GetNumPartyMembers() > 0) ) then
            BordoUI:UpdatePartyFrames();
        end
    end
end);

-- =========================================================================
-- 6. SLASH COMMAND TOGGLE & TEST MODE
-- =========================================================================
function BordoUI:TogglePartyFrames(param)
    param = string.lower(param or "");
    if ( param == "test" or param == "preview" ) then
        testModeActive = not testModeActive;
        BordoUI:UpdatePartyFrames();
        local st = testModeActive and "|cff55ff55ENABLED|r" or "|cffff4444DISABLED|r";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party frames test preview " .. st .. ".");
        return;
    end

    if ( param == "reset" ) then
        testModeActive = false;
        BordoUIDB.partyPos = { point = "TOPLEFT", relativePoint = "TOPLEFT", x = 142, y = -120 };
        BordoUI:RestorePosition(container, BordoUIDB.partyPos);
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party frames position reset.");
        BordoUI:UpdatePartyFrames();
        return;
    end

    if ( container:IsShown() ) then
        container:Hide();
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party frames hidden. Type |cffffd100/bparty|r or |cffffd100/bordo party|r to show.");
    else
        container:Show();
        BordoUI:UpdatePartyFrames();
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party frames shown.");
    end
end

-- Slash Commands: /bparty and /partyframes
SLASH_BORDOPARTY1 = "/bparty";
SLASH_BORDOPARTY2 = "/partyframes";
SlashCmdList["BORDOPARTY"] = function(msg)
    BordoUI:TogglePartyFrames(msg);
end;
