--[[
    Bordo UI - Modern Boss & Miniboss Tracker (BossTracker.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Faithfully reproduces the modern Tracker:
    - 1. Zone Name & Big Run Clock (4:26 / 20:00)
    - 2. Boss Timeline with Progress Bar & Tick Marks (3:33, 7:33, 11:33, 15:33, 20:00)
    - 3. Scheduled Boss List with color coding:
         - Green: Slain / Defeated (with spawn & death time)
         - Orange: Currently Alive & Fighting (with live HP% / FIGHT)
         - White / Yellow: Next Upcoming Boss with live active countdown ("in 1:10  3:33")
         - Grey: Future scheduled boss
    - 4. Guardians Bar with Lair Heraldic Marks:
         - When Dead: Red bar with countdown timer (0:39, 1:51)
         - When Alive: Green/Gold bar with live Rotational Directional Arrow (GuardianArrow.tga) pointing to boss in 3D world
         - When Fighting: Orange bar with health percentage
    - 5. Elites counter
    Movable, scalable with mouse wheel, saved position.
]]--

BordoUI = BordoUI or {};
local TrackerUI = {};
BordoUI.BossTracker = TrackerUI;

local ART = "Interface\\AddOns\\BordoUI\\Art\\";
local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local CELLS = 8; -- 8x8 arrow sheet = 64 angles
local WIDTH = 220;

local function FormatClock(sec)
    sec = math.max(0, math.floor((sec or 0) + 0.5));
    return string.format("%d:%02d", math.floor(sec / 60), math.mod(sec, 60));
end

-- ============================================================================
-- Zone Boss Data & Fallbacks for Azeroth Survivors (All 9 Zones)
-- ============================================================================
local MAP_BOSS_DATA = {
    ["Elwynn Forest"] = {
        { name = "Hogger", at = 213 },
        { name = "Mother Fang", at = 453 },
        { name = "Rhahk'Zor", at = 693 },
        { name = "Mr. Smite", at = 933 },
        { name = "Edwin VanCleef", at = 1200, final = 1 },
    },
    ["Duskwood"] = {
        { name = "Naraxis", at = 213 },
        { name = "Mor'Ladim", at = 453 },
        { name = "Stitches", at = 693 },
        { name = "Lupos", at = 933 },
        { name = "Morbent Fel", at = 1200, final = 1 },
    },
    ["Warsong Gulch"] = {
        { name = "Doomguard Commander", at = 213 },
        { name = "Mannoroth's Herald", at = 453 },
        { name = "Varimathras", at = 693 },
        { name = "Lord Hel'nurath", at = 933 },
        { name = "Lord Kazzak", at = 1200, final = 1 },
    },
    ["Arathi Basin"] = {
        { name = "Patchwerk", at = 213 },
        { name = "Lord Blackwood", at = 453 },
        { name = "Baron Rivendare", at = 693 },
        { name = "Anub'Rekhan", at = 933 },
        { name = "Kel'Thuzad", at = 1200, final = 1 },
    },
    ["Feralas"] = {
        { name = "Zevrim Thornhoof", at = 213 },
        { name = "Alzzin the Wildshaper", at = 453 },
        { name = "Tendris Warpwood", at = 693 },
        { name = "Immol'thar", at = 933 },
        { name = "King Gordok", at = 1200, final = 1 },
    },
    ["Gurubashi Arena"] = {
        { name = "High Priestess Jeklik", at = 213 },
        { name = "High Priest Venoxis", at = 453 },
        { name = "Bloodlord Mandokir", at = 693 },
        { name = "Jin'do the Hexxer", at = 933 },
        { name = "Hakkar the Soulflayer", at = 1200, final = 1 },
    },
    ["Alterac Valley"] = {
        { name = "Korrak the Bloodrager", at = 213 },
        { name = "Ivus the Forest Lord", at = 453 },
        { name = "Lokholar the Ice Lord", at = 693 },
        { name = "Glacius the Frozen Titan", at = 933 },
        { name = "Azuregos", at = 1200, final = 1 },
    },
    ["Blackrock Mountain"] = {
        { name = "General Angerforge", at = 213 },
        { name = "Warchief Rend Blackhand", at = 453 },
        { name = "Emperor Dagran Thaurissan", at = 693 },
        { name = "Majordomo Executus", at = 933 },
        { name = "Nefarian", at = 1200, final = 1 },
    },
    ["Gates of Ahn'Qiraj"] = {
        { name = "Kurinnaxx", at = 213 },
        { name = "General Rajaxx", at = 453 },
        { name = "Princess Huhuran", at = 693 },
        { name = "Ossirian the Unscarred", at = 933 },
        { name = "C'Thun", at = 1200, final = 1 },
    },
};

local ZONE_ALIASES = {
    ["elwynn"] = "Elwynn Forest",
    ["wald von elwynn"] = "Elwynn Forest",
    ["elwynn forest"] = "Elwynn Forest",
    ["duskwood"] = "Duskwood",
    ["daemmerwald"] = "Duskwood",
    ["wsg"] = "Warsong Gulch",
    ["warsong gulch"] = "Warsong Gulch",
    ["kriegshymnenschlucht"] = "Warsong Gulch",
    ["ab"] = "Arathi Basin",
    ["arathi basin"] = "Arathi Basin",
    ["arathibecken"] = "Arathi Basin",
    ["feralas"] = "Feralas",
    ["arena"] = "Gurubashi Arena",
    ["gurubashi arena"] = "Gurubashi Arena",
    ["gurubashi"] = "Gurubashi Arena",
    ["av"] = "Alterac Valley",
    ["alterac valley"] = "Alterac Valley",
    ["alteractal"] = "Alterac Valley",
    ["brm"] = "Blackrock Mountain",
    ["blackrock mountain"] = "Blackrock Mountain",
    ["der schwarzfels"] = "Blackrock Mountain",
    ["schwarzfels"] = "Blackrock Mountain",
    ["aq"] = "Gates of Ahn'Qiraj",
    ["ahn'qiraj"] = "Gates of Ahn'Qiraj",
    ["tore von ahn'qiraj"] = "Gates of Ahn'Qiraj",
    ["gates of ahn'qiraj"] = "Gates of Ahn'Qiraj",
};

local BOSS_DEFAULT_TIMES = {};
for _, bList in pairs(MAP_BOSS_DATA) do
    for _, bInfo in ipairs(bList) do
        BOSS_DEFAULT_TIMES[bInfo.name] = bInfo.at;
    end
end

local function GetBossField(b, key, index)
    if type(b) ~= "table" then return nil; end
    if b[key] ~= nil then return b[key]; end
    if index and b[index] ~= nil then return b[index]; end
    return nil;
end

local function LiveBoss(name)
    if not AZS_UNITS or not name then return nil; end
    local count = table.getn(AZS_UNITS);
    for idx = 1, count do
        local u = AZS_UNITS[idx];
        if u then
            local kind = u.kind or u[1];
            local uName = u.name or u[3];
            if (kind == "boss" or kind == "final") and uName == name then
                return u;
            end
        end
    end
    return nil;
end

-- ============================================================================
-- Frame Creation
-- ============================================================================
local frame = CreateFrame("Frame", "BordoUI_BossTrackerFrame", UIParent);
TrackerUI.frame = frame;
SurvivorUITracker = frame;
AZSHelper_BossSchedulePanel = frame;
frame:SetWidth(WIDTH);
frame:SetHeight(230);
frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -160);
frame:SetFrameStrata("LOW");
frame:SetFrameLevel(6);
frame:SetClampedToScreen(true);
frame:SetMovable(true);
frame:EnableMouse(true);
frame:RegisterForDrag("LeftButton");
frame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        frame:StartMoving();
    end
end);
frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = frame:GetPoint();
        BordoUIDB.bossTrackerPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
    if ( BordoUI_UpdateBuildPosition ) then
        BordoUI_UpdateBuildPosition();
    end
end);
frame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
frame:SetBackdropColor(0.04, 0.04, 0.06, 0.88);
frame:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);

-- Header Dragging & Scaling
local headerBar = CreateFrame("Frame", nil, frame);
headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
headerBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
headerBar:SetHeight(38);
headerBar:EnableMouse(true);
headerBar:RegisterForDrag("LeftButton");
headerBar:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        frame:StartMoving();
    end
end);
headerBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = frame:GetPoint();
        BordoUIDB.bossTrackerPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
    if ( BordoUI_UpdateBuildPosition ) then
        BordoUI_UpdateBuildPosition();
    end
end);
headerBar:EnableMouseWheel(true);
headerBar:SetScript("OnMouseWheel", function()
    local cur = (BordoUIDB and BordoUIDB.bossScale) or 1.0;
    if ( arg1 > 0 ) then cur = cur + 0.05; else cur = cur - 0.05; end
    cur = math.min(1.3, math.max(0.65, cur));
    BordoUIDB.bossScale = cur;
    frame:SetScale(cur);
end);

if ( BordoUI and BordoUI.AttachLockButton ) then
    BordoUI:AttachLockButton(frame, "TOPRIGHT", headerBar, "TOPRIGHT", -6, -4);
end

-- 1. Zone Name (Yellow)
local zoneText = headerBar:CreateFontString(nil, "OVERLAY");
zoneText:SetFont(FONT_PATH, 11, "OUTLINE");
zoneText:SetPoint("TOPLEFT", headerBar, "TOPLEFT", 8, -5);
zoneText:SetTextColor(1, 0.82, 0);
zoneText:SetText("Azeroth");
TrackerUI.zoneText = zoneText;

-- 2. Big Run Clock (4:26 / 20:00)
local clockText = headerBar:CreateFontString(nil, "OVERLAY");
clockText:SetFont(FONT_PATH, 18, "OUTLINE");
clockText:SetPoint("TOP", headerBar, "TOP", 0, -16);
clockText:SetTextColor(1, 1, 1);
clockText:SetText("0:00 / 20:00");
TrackerUI.clockText = clockText;

-- 3. Timeline Bar
local timelineContainer = CreateFrame("Frame", nil, frame);
timelineContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -48);
timelineContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -48);
timelineContainer:SetHeight(18);
timelineContainer:SetWidth(204);

local timelineBar = CreateFrame("StatusBar", nil, timelineContainer);
timelineBar:SetPoint("BOTTOMLEFT", timelineContainer, "BOTTOMLEFT", 0, 2);
timelineBar:SetPoint("BOTTOMRIGHT", timelineContainer, "BOTTOMRIGHT", 0, 2);
timelineBar:SetHeight(6);
timelineBar:SetWidth(204);
timelineBar:SetStatusBarTexture(FLAT);
timelineBar:SetStatusBarColor(0.30, 0.85, 0.35, 1.0);
timelineBar:SetMinMaxValues(0, 1200);
timelineBar:SetValue(0);
TrackerUI.timelineBar = timelineBar;

local timelineBg = timelineBar:CreateTexture(nil, "BACKGROUND");
timelineBg:SetTexture(FLAT);
timelineBg:SetVertexColor(0.18, 0.18, 0.22, 0.95);
timelineBg:SetAllPoints(timelineBar);

-- Up to 5 Boss Ticks on Timeline
local timelineTicks = {};
for i = 1, 5 do
    local tick = CreateFrame("Frame", nil, timelineContainer);
    tick:SetWidth(2);
    tick:SetHeight(10);
    tick:SetPoint("BOTTOM", timelineBar, "BOTTOM", 0, 0);

    local line = tick:CreateTexture(nil, "OVERLAY");
    line:SetTexture(FLAT);
    line:SetVertexColor(1, 1, 1, 0.95);
    line:SetAllPoints(tick);

    local label = tick:CreateFontString(nil, "OVERLAY");
    label:SetFont(FONT_PATH, 8, "OUTLINE");
    label:SetPoint("BOTTOM", tick, "TOP", 0, 1);
    label:SetTextColor(1, 0.82, 0);
    label:SetText("");

    tick.line = line;
    tick.label = label;
    tick:Hide();
    timelineTicks[i] = tick;
end

-- 4. Scheduled Boss Rows (Up to 6 bosses)
local bossRows = {};
local startBossY = -70;
for i = 1, 6 do
    local row = CreateFrame("Button", nil, frame);
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, startBossY - (i - 1) * 14);
    row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, startBossY - (i - 1) * 14);
    row:SetHeight(13);
    row:EnableMouse(true);
    row:RegisterForClicks("LeftButtonUp");
    row:SetScript("OnClick", function()
        if this.bossTarget and TargetByName then
            TargetByName(this.bossTarget, true);
        end
    end);

    local name = row:CreateFontString(nil, "OVERLAY");
    name:SetFont(FONT_PATH, 9, "OUTLINE");
    name:SetPoint("LEFT", row, "LEFT", 2, 0);
    name:SetJustifyH("LEFT");
    name:SetWidth(125);

    local timeText = row:CreateFontString(nil, "OVERLAY");
    timeText:SetFont(FONT_PATH, 9, "OUTLINE");
    timeText:SetPoint("RIGHT", row, "RIGHT", -2, 0);
    timeText:SetJustifyH("RIGHT");

    row.name = name;
    row.timeText = timeText;
    row:Hide();
    bossRows[i] = row;
end

-- 5. Guardians Section
local guardiansHeader = CreateFrame("Frame", nil, frame);
guardiansHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -158);
guardiansHeader:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -158);
guardiansHeader:SetHeight(14);

local gTitle = guardiansHeader:CreateFontString(nil, "OVERLAY");
gTitle:SetFont(FONT_PATH, 9, "OUTLINE");
gTitle:SetPoint("LEFT", guardiansHeader, "LEFT", 2, 0);
gTitle:SetTextColor(0.85, 0.85, 0.85);
gTitle:SetText("Guardians");

local gGoal = guardiansHeader:CreateFontString(nil, "OVERLAY");
gGoal:SetFont(FONT_PATH, 9, "OUTLINE");
gGoal:SetPoint("RIGHT", guardiansHeader, "RIGHT", -2, 0);
gGoal:SetTextColor(0.35, 0.90, 0.40);
gGoal:SetText("4/4 by 8:00 - done");
TrackerUI.gGoal = gGoal;

-- Guardians Segment Boxes (One per lair, up to 6 lairs)
local guardianSegments = {};
local segmentBar = CreateFrame("Frame", nil, frame);
segmentBar:SetPoint("TOPLEFT", guardiansHeader, "BOTTOMLEFT", 0, -2);
segmentBar:SetPoint("TOPRIGHT", guardiansHeader, "BOTTOMRIGHT", 0, -2);
segmentBar:SetHeight(18);

local function PointArrow(texture, angle)
    local cells = CELLS * CELLS;
    local k = math.mod(math.floor(angle / (2 * math.pi) * cells + 0.5), cells);
    if ( k < 0 ) then k = k + cells; end
    local col = math.mod(k, CELLS);
    local row = math.floor(k / CELLS);
    texture:SetTexCoord(col / CELLS, (col + 1) / CELLS, row / CELLS, (row + 1) / CELLS);
end

local function WrapAngle(angle)
    while angle > math.pi do
        angle = angle - 2 * math.pi;
    end
    while angle < -math.pi do
        angle = angle + 2 * math.pi;
    end
    return angle;
end

for i = 1, 6 do
    local seg = CreateFrame("Frame", nil, segmentBar);
    seg:SetHeight(18);
    seg:EnableMouse(true);
    seg:SetScript("OnMouseUp", function()
        if this.targetBoss and TargetByName then
            TargetByName(this.targetBoss, true);
        end
    end);

    local bg = seg:CreateTexture(nil, "BACKGROUND");
    bg:SetTexture(FLAT);
    bg:SetAllPoints(seg);
    seg.bg = bg;

    local mark = seg:CreateTexture(nil, "ARTWORK");
    mark:SetWidth(14);
    mark:SetHeight(14);
    mark:SetPoint("LEFT", seg, "LEFT", 2, 0);
    seg.mark = mark;

    local shadow = seg:CreateTexture(nil, "ARTWORK");
    shadow:SetTexture(ART .. "GuardianArrow.tga");
    shadow:SetVertexColor(0, 0, 0, 0.85);
    shadow:SetWidth(15);
    shadow:SetHeight(15);
    shadow:SetPoint("CENTER", seg, "CENTER", 7, 0);
    seg.shadow = shadow;

    local arrow = seg:CreateTexture(nil, "OVERLAY");
    arrow:SetTexture(ART .. "GuardianArrow.tga");
    arrow:SetWidth(13);
    arrow:SetHeight(13);
    arrow:SetPoint("CENTER", seg, "CENTER", 7, 0);
    seg.arrow = arrow;

    local timer = seg:CreateFontString(nil, "OVERLAY");
    timer:SetFont(FONT_PATH, 10, "OUTLINE");
    timer:SetPoint("RIGHT", seg, "RIGHT", -3, 0);
    timer:SetTextColor(1, 1, 1);
    seg.timer = timer;

    seg:Hide();
    guardianSegments[i] = seg;
end

-- 6. Elites Line
local elitesRow = CreateFrame("Frame", nil, frame);
elitesRow:SetPoint("TOPLEFT", segmentBar, "BOTTOMLEFT", 0, -4);
elitesRow:SetPoint("TOPRIGHT", segmentBar, "BOTTOMRIGHT", 0, -4);
elitesRow:SetHeight(14);

local eLabel = elitesRow:CreateFontString(nil, "OVERLAY");
eLabel:SetFont(FONT_PATH, 9, "OUTLINE");
eLabel:SetPoint("LEFT", elitesRow, "LEFT", 2, 0);
eLabel:SetTextColor(0.85, 0.85, 0.85);
eLabel:SetText("Elites");

local eCount = elitesRow:CreateFontString(nil, "OVERLAY");
eCount:SetFont(FONT_PATH, 9, "OUTLINE");
eCount:SetPoint("RIGHT", elitesRow, "RIGHT", -2, 0);
eCount:SetTextColor(0.65, 0.65, 0.65);
eCount:SetText("none");
TrackerUI.eCount = eCount;

-- Dynamic Heading / Facing tracking from map movement
local lastWalkX, lastWalkY;
local walkedHeading = 0;
local function UpdatePlayerHeading()
    if ( AZS_RUN and AZS_RUN.pf ) then
        return -tonumber(AZS_RUN.pf);
    end
    local hx, hy = GetPlayerMapPosition("player");
    if ( hx and hy and (hx > 0 or hy > 0) ) then
        if ( lastWalkX and lastWalkY ) then
            local dx = hx - lastWalkX;
            local dy = hy - lastWalkY;
            if ( dx * dx + dy * dy > 0.000004 ) then
                walkedHeading = math.atan2(dx, -dy);
                lastWalkX, lastWalkY = hx, hy;
            end
        else
            lastWalkX, lastWalkY = hx, hy;
        end
    end
    return walkedHeading;
end

-- ============================================================================
-- Main Update Loop
-- ============================================================================
local bossSeenUp = {};
local bossKilled = {};
local lastRunSeconds = nil;

function TrackerUI:Update()
    if ( not frame:IsShown() ) then return; end

    local run = AZS_RUN;
    local t = (AZS_GetRunTime and AZS_GetRunTime()) or (run and tonumber(run.t)) or 0;
    local zone = (AZS_ZONE and AZS_ZONE.zname) or GetZoneText() or "Azeroth";
    zoneText:SetText(zone);

    -- Reset state if a new run has started
    if lastRunSeconds and (t + 3 < lastRunSeconds) then
        bossSeenUp = {};
        bossKilled = {};
    end
    lastRunSeconds = t;

    -- Resolve Boss Schedule
    local rawSched = AZS_SCHEDULE;
    local sched = {};
    if type(rawSched) == "table" and table.getn(rawSched) > 0 then
        for i = 1, table.getn(rawSched) do
            sched[i] = rawSched[i];
        end
    else
        -- Fallback to map-specific schedule
        local zKey = string.lower(zone or "");
        local canonicalZone = ZONE_ALIASES[zKey] or zone;
        local fallbackList = MAP_BOSS_DATA[canonicalZone];
        if not fallbackList then
            for k, v in pairs(ZONE_ALIASES) do
                if string.find(zKey, k) then
                    fallbackList = MAP_BOSS_DATA[v];
                    break;
                end
            end
        end
        if fallbackList then
            for i = 1, table.getn(fallbackList) do
                sched[i] = fallbackList[i];
            end
        end
    end
    local numSched = table.getn(sched);

    -- Total Run Time
    local totalTime = 1200; -- 20 min default
    if AZS_GetRunLength then
        totalTime = tonumber(AZS_GetRunLength()) or 0;
    end
    if totalTime <= 0 and AZS_ZONE and AZS_ZONE.len then
        totalTime = tonumber(AZS_ZONE.len) or 0;
    end
    if totalTime <= 0 and run and run.fin then
        totalTime = tonumber(run.fin) or 0;
    end
    if totalTime <= 0 and numSched > 0 then
        local lastB = sched[numSched];
        local lastAt = tonumber(GetBossField(lastB, "at", 2) or GetBossField(lastB, "t"));
        if lastAt and lastAt > 0 then totalTime = lastAt; end
    end
    if totalTime <= 0 then totalTime = 1200; end

    clockText:SetText(string.format("%s / %s", FormatClock(t), FormatClock(totalTime)));

    -- Timeline Bar
    timelineBar:SetMinMaxValues(0, totalTime);
    timelineBar:SetValue(math.min(t, totalTime));

    -- Boss Rows & Timeline Ticks
    local barW = timelineBar:GetWidth();
    if not barW or barW <= 10 then
        barW = 204;
    end
    local foundNext = false;

    for i = 1, 6 do
        local row = bossRows[i];
        if ( i <= numSched ) then
            local b = sched[i];
            local bName = GetBossField(b, "name", 3) or ("Boss " .. i);
            local bAt = tonumber(GetBossField(b, "at", 2) or GetBossField(b, "t"))
                or BOSS_DEFAULT_TIMES[bName]
                or (i == 5 and 1200 or (213 + (i - 1) * 240));
            local bState = GetBossField(b, "state", 5);
            local bFinal = (GetBossField(b, "final", 4) == 1 or i == numSched);

            -- Determine state
            local liveUnit = LiveBoss(bName);
            if bState == "dead" then
                if not bossKilled[bName] and bossSeenUp[bName] then
                    bossKilled[bName] = t;
                end
            elseif bState == "up" or liveUnit then
                bState = "up";
                bossSeenUp[bName] = true;
            elseif bState == "due" then
                -- Due
            else
                if bossSeenUp[bName] and not liveUnit and t > bAt then
                    bState = "dead";
                    if not bossKilled[bName] then bossKilled[bName] = t; end
                elseif t >= bAt or liveUnit then
                    bState = "up";
                    bossSeenUp[bName] = true;
                else
                    bState = "due";
                end
            end

            -- Up to 5 Boss Ticks on Timeline
            if i <= 5 then
                local tick = timelineTicks[i];
                if bAt > 0 and totalTime > 0 and bAt <= totalTime then
                    local pct = bAt / totalTime;
                    local x = math.floor(pct * barW);
                    x = math.min(barW - 2, math.max(1, x));
                    tick:ClearAllPoints();
                    tick:SetPoint("BOTTOMLEFT", timelineBar, "BOTTOMLEFT", x, 0);

                    if bFinal then
                        tick:SetWidth(3);
                    else
                        tick:SetWidth(2);
                    end

                    tick.label:ClearAllPoints();
                    if x > barW - 24 then
                        tick.label:SetPoint("BOTTOMRIGHT", tick, "TOPRIGHT", 0, 1);
                    elseif x < 24 then
                        tick.label:SetPoint("BOTTOMLEFT", tick, "TOPLEFT", 0, 1);
                    else
                        tick.label:SetPoint("BOTTOM", tick, "TOP", 0, 1);
                    end

                    if bState == "dead" then
                        tick.line:SetVertexColor(0.30, 0.90, 0.40, 0.95);
                        tick.label:SetText(FormatClock(bAt));
                        tick.label:SetTextColor(0.30, 0.90, 0.40);
                    elseif bState == "up" then
                        tick.line:SetVertexColor(1.00, 0.55, 0.15, 0.95);
                        tick.label:SetText("FIGHT");
                        tick.label:SetTextColor(1.00, 0.55, 0.15);
                    elseif not foundNext and bAt >= t then
                        foundNext = true;
                        tick.line:SetVertexColor(1.00, 0.82, 0.20, 0.95);
                        tick.label:SetText(FormatClock(bAt));
                        tick.label:SetTextColor(1.00, 0.82, 0.20);
                    else
                        tick.line:SetVertexColor(0.85, 0.85, 0.85, 0.80);
                        tick.label:SetText(FormatClock(bAt));
                        tick.label:SetTextColor(0.70, 0.70, 0.70);
                    end
                    tick:Show();
                else
                    timelineTicks[i]:Hide();
                end
            end

            -- Scheduled Boss Row Display
            row.name:SetText(bName);
            if bState == "dead" then
                -- Slain: Green
                row.name:SetTextColor(0.30, 0.90, 0.40);
                row.timeText:SetTextColor(0.30, 0.90, 0.40);
                if bossKilled[bName] then
                    row.timeText:SetText(string.format("%s / %s", FormatClock(bAt), FormatClock(bossKilled[bName])));
                else
                    row.timeText:SetText(string.format("%s - done", FormatClock(bAt)));
                end
                row.bossTarget = nil;
            elseif bState == "up" then
                -- Alive / Active: Orange
                row.name:SetTextColor(1.00, 0.55, 0.25);
                row.timeText:SetTextColor(1.00, 0.65, 0.30);
                if liveUnit then
                    local hp = tonumber(liveUnit.hp or liveUnit[4]) or 0;
                    local hpm = tonumber(liveUnit.hpm or liveUnit[5]) or 0;
                    if hpm > 0 then
                        local pct = math.floor(hp / hpm * 100 + 0.5);
                        row.timeText:SetText(string.format("%d%%  %s", pct, FormatClock(bAt)));
                    else
                        row.timeText:SetText(string.format("FIGHT  %s", FormatClock(bAt)));
                    end
                else
                    row.timeText:SetText(string.format("ALIVE  %s", FormatClock(bAt)));
                end
                row.bossTarget = bName;
            else
                -- Due / Upcoming
                row.bossTarget = nil;
                if not foundNext and bAt >= t then
                    foundNext = true;
                    local diff = math.max(0, bAt - t);
                    row.name:SetTextColor(1.00, 1.00, 1.00);
                    row.timeText:SetTextColor(1.00, 0.82, 0.20);
                    row.timeText:SetText(string.format("in %s  %s", FormatClock(diff), FormatClock(bAt)));
                else
                    row.name:SetTextColor(0.55, 0.55, 0.58);
                    row.timeText:SetTextColor(0.55, 0.55, 0.58);
                    row.timeText:SetText(FormatClock(bAt));
                end
            end
            row:Show();
        else
            -- Endless Mode: Display returning boss in row 6 if schedule is done
            if i == 6 and run and tonumber(run.endl) == 1 and tonumber(run.nb or -1) >= 0 then
                local nextIn = tonumber(run.nb);
                local nextName = run.nbn;
                if not nextName or nextName == "" then nextName = "Next boss"; end
                row.name:SetText(nextName);
                row.name:SetTextColor(1, 1, 1);
                row.timeText:SetTextColor(1, 0.82, 0);
                row.timeText:SetText(string.format("in %s", FormatClock(nextIn)));
                row.bossTarget = nil;
                row:Show();
            else
                row:Hide();
            end
            if i <= 5 then
                timelineTicks[i]:Hide();
            end
        end
    end

    -- Guardians / Lairs
    local rawLairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
    local marks = SurvivorUI_LairMarks and SurvivorUI_LairMarks(rawLairs) or {};
    local lairList = {};
    for k, v in pairs(rawLairs) do
        if type(v) == "table" then
            table.insert(lairList, v);
        end
    end
    table.sort(lairList, function(a, b)
        local pa = tonumber(a.index or a[1]) or 0;
        local pb = tonumber(b.index or b[1]) or 0;
        return pa < pb;
    end);
    local numLairs = table.getn(lairList);
    local px = (run and tonumber(run.px)) or 0;
    local py = (run and tonumber(run.py)) or 0;
    local pFacing = UpdatePlayerHeading();

    -- Check achievement 4/4 before 8:00
    local totalSlain = 0;
    if ( t >= 30 ) then
        for i = 1, numLairs do
            local l = lairList[i];
            local st = l.state or l[2];
            local since = AZS_LAIRS_UPDATED and (GetTime() - AZS_LAIRS_UPDATED) or 0;
            local respawnTime = (tonumber(l.left or l.respawn or l[5]) or 0) - since;
            if ( l.active == false or l.active == 0 or (st == "empty" and respawnTime > 0) ) then
                totalSlain = totalSlain + 1;
            end
        end
    end
    if ( totalSlain >= 4 or t >= 480 ) then
        gGoal:SetText(string.format("%d/4 by 8:00 - done", math.min(4, totalSlain)));
        gGoal:SetTextColor(0.35, 0.90, 0.40);
    else
        local rem = math.max(0, 480 - t);
        gGoal:SetText(string.format("%d/4 in %s", totalSlain, FormatClock(rem)));
        gGoal:SetTextColor(1, 0.82, 0);
    end

    if ( numLairs > 0 ) then
        local segW = (barW - (numLairs - 1) * 3) / numLairs;
        for i = 1, 6 do
            local seg = guardianSegments[i];
            if ( i <= numLairs ) then
                local lair = lairList[i];
                local place = tonumber(lair.index or lair[1]) or i;
                local markId = marks[place] or (math.mod(i - 1, 8) + 1);

                seg:ClearAllPoints();
                seg:SetPoint("LEFT", segmentBar, "LEFT", (i - 1) * (segW + 3), 0);
                seg:SetWidth(segW);

                local state = lair.state or lair[2];
                local isAwake = (state == "awake" or lair.awake == true or lair.awake == 1);
                local isActive = (state ~= "empty" and (lair.active == nil or lair.active == true or lair.active == 1));

                if ( SurvivorUI_SetLairMark ) then
                    SurvivorUI_SetLairMark(seg.mark, markId, not isActive);
                end

                seg.targetBoss = lair.name or lair[3];

                if ( isAwake ) then
                    -- Fighting / Awake in orange
                    seg.bg:SetVertexColor(1.0, 0.55, 0.15, 0.85);
                    seg.arrow:Hide();
                    if ( seg.shadow ) then seg.shadow:Hide(); end
                    seg.timer:Show();
                    seg.timer:SetText("FIGHT");
                elseif ( isActive ) then
                    -- Spawned / Alive in light green with live 3D Directional Arrow
                    seg.bg:SetVertexColor(0.70, 0.92, 0.55, 0.85);
                    seg.timer:Hide();

                    local lx = tonumber(lair.x or lair[6]) or 0;
                    local ly = tonumber(lair.y or lair[7]) or 0;
                    local east = py - ly;
                    local south = px - lx;
                    local bearing = math.atan2(east, -south);
                    local relAngle = bearing - pFacing;

                    PointArrow(seg.arrow, relAngle);
                    if ( seg.shadow ) then
                        PointArrow(seg.shadow, relAngle);
                        seg.shadow:Show();
                    end
                    seg.arrow:Show();

                    -- Tint gold when walking/facing towards the boss (within ~15 degrees)
                    local ahead = math.abs(WrapAngle(relAngle)) < 0.26;
                    if ( ahead ) then
                        seg.arrow:SetVertexColor(1.00, 0.85, 0.25, 1.0);
                    else
                        seg.arrow:SetVertexColor(1.00, 1.00, 1.00, 1.0);
                    end
                else
                    -- Slain / Respawning or pending initial spawn
                    local since = AZS_LAIRS_UPDATED and (GetTime() - AZS_LAIRS_UPDATED) or 0;
                    local respawnTime = (tonumber(lair.left or lair.respawn or lair[5]) or 0) - since;
                    if ( t < 45 and totalSlain == 0 ) then
                        -- Early run waiting for first lair activation: dark slate gray
                        seg.bg:SetVertexColor(0.20, 0.22, 0.25, 0.85);
                        seg.arrow:Hide();
                        if ( seg.shadow ) then seg.shadow:Hide(); end
                        seg.timer:Show();
                        seg.timer:SetText("...");
                    elseif ( respawnTime > 0 ) then
                        seg.bg:SetVertexColor(0.85, 0.22, 0.20, 0.85);
                        seg.arrow:Hide();
                        if ( seg.shadow ) then seg.shadow:Hide(); end
                        seg.timer:Show();
                        seg.timer:SetText(FormatClock(math.floor(respawnTime + 0.5)));
                    else
                        seg.bg:SetVertexColor(0.85, 0.45, 0.20, 0.85);
                        seg.arrow:Hide();
                        if ( seg.shadow ) then seg.shadow:Hide(); end
                        seg.timer:Show();
                        seg.timer:SetText("DUE");
                    end
                end
                seg:Show();
            else
                seg:Hide();
            end
        end
    else
        for i = 1, 6 do guardianSegments[i]:Hide(); end
    end

    -- Elites count
    local elites = 0;
    if ( AZS_UNITS ) then
        for i = 1, table.getn(AZS_UNITS) do
            local u = AZS_UNITS[i];
            if ( u and (u.kind == "elite" or u[1] == "elite") ) then
                elites = elites + 1;
            end
        end
    end
    if ( elites > 0 ) then
        eCount:SetText(string.format("%d active", elites));
        eCount:SetTextColor(1, 0.82, 0);
    else
        eCount:SetText("none");
        eCount:SetTextColor(0.65, 0.65, 0.65);
    end
end

-- Ticker (10 updates per second for smooth arrow rotation & countdowns)
local ticker = CreateFrame("Frame", "BordoUI_BossTrackerTicker");
local elapsed = 0;
ticker:SetScript("OnUpdate", function()
    elapsed = elapsed + arg1;
    if ( elapsed < 0.1 ) then return; end
    elapsed = 0;
    TrackerUI:Update();
end);

function TrackerUI:ResetPosition()
    frame:ClearAllPoints();
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -160);
    if ( BordoUIDB ) then
        BordoUIDB.bossTrackerPos = nil;
    end
    if ( BordoUI_UpdateBuildPosition ) then
        BordoUI_UpdateBuildPosition();
    end
end

local function InitBossTracker()
    if ( BordoUIDB and BordoUIDB.bossTrackerPos and BordoUIDB.bossTrackerPos.point ) then
        BordoUI:RestorePosition(frame, BordoUIDB.bossTrackerPos);
    else
        frame:ClearAllPoints();
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -160);
    end
    if ( BordoUIDB and BordoUIDB.bossScale ) then
        frame:SetScale(BordoUIDB.bossScale);
    end
    frame:Show();
    TrackerUI:Update();
    if ( BordoUI_UpdateBuildPosition ) then
        BordoUI_UpdateBuildPosition();
    end
end

local loader = CreateFrame("Frame");
loader:RegisterEvent("PLAYER_ENTERING_WORLD");
loader:RegisterEvent("VARIABLES_LOADED");
loader:RegisterEvent("CHAT_MSG_ADDON");
loader:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" then
        if arg1 == "AZSZONE" then
            bossSeenUp = {};
            bossKilled = {};
            lastRunSeconds = nil;
        end
        return;
    end
    InitBossTracker();
end);
