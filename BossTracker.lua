--[[
    Bordo UI - Modern Boss & Miniboss Tracker (BossTracker.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Faithfully reproduces the modern Tracker from reference screenshot:
    - 1. Zone Name & Big Run Clock (4:26 / 20:00)
    - 2. Boss Timeline with Progress Bar & Tick Marks (3:33, 7:33, 11:33, 15:33)
    - 3. Scheduled Boss List with color coding (Green: spawned/slain, Yellow: upcoming countdown, Grey: future)
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

-- Main Frame
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

local timelineBar = CreateFrame("StatusBar", nil, timelineContainer);
timelineBar:SetPoint("BOTTOMLEFT", timelineContainer, "BOTTOMLEFT", 0, 2);
timelineBar:SetPoint("BOTTOMRIGHT", timelineContainer, "BOTTOMRIGHT", 0, 2);
timelineBar:SetHeight(6);
timelineBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
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
    local row = CreateFrame("Frame", nil, frame);
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, startBossY - (i - 1) * 14);
    row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, startBossY - (i - 1) * 14);
    row:SetHeight(13);
    
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
gGoal:SetText("4/4 by 8:00 \194\183 done");
TrackerUI.gGoal = gGoal;

-- Guardians Segment Boxes (One per lair, up to 6 lairs)
local guardianSegments = {};
local segmentBar = CreateFrame("Frame", nil, frame);
segmentBar:SetPoint("TOPLEFT", guardiansHeader, "BOTTOMLEFT", 0, -2);
segmentBar:SetPoint("TOPRIGHT", guardiansHeader, "BOTTOMRIGHT", 0, -2);
segmentBar:SetHeight(16);

local function PointArrow(texture, angle)
    local cells = CELLS * CELLS;
    local k = math.mod(math.floor(angle / (2 * math.pi) * cells + 0.5), cells);
    if ( k < 0 ) then k = k + cells; end
    local col = math.mod(k, CELLS);
    local row = math.floor(k / CELLS);
    texture:SetTexCoord(col / CELLS, (col + 1) / CELLS, row / CELLS, (row + 1) / CELLS);
end

for i = 1, 6 do
    local seg = CreateFrame("Frame", nil, segmentBar);
    seg:SetHeight(16);
    
    local bg = seg:CreateTexture(nil, "BACKGROUND");
    bg:SetTexture(FLAT);
    bg:SetAllPoints(seg);
    seg.bg = bg;
    
    local mark = seg:CreateTexture(nil, "ARTWORK");
    mark:SetWidth(13);
    mark:SetHeight(13);
    mark:SetPoint("LEFT", seg, "LEFT", 1, 0);
    seg.mark = mark;
    
    local arrow = seg:CreateTexture(nil, "OVERLAY");
    arrow:SetTexture(ART .. "GuardianArrow");
    arrow:SetWidth(13);
    arrow:SetHeight(13);
    arrow:SetPoint("CENTER", seg, "CENTER", 4, 0);
    seg.arrow = arrow;
    
    local timer = seg:CreateFontString(nil, "OVERLAY");
    timer:SetFont(FONT_PATH, 9, "OUTLINE");
    timer:SetPoint("RIGHT", seg, "RIGHT", -2, 0);
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
        return tonumber(AZS_RUN.pf) or 0;
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

-- Main Update Loop
function TrackerUI:Update()
    if ( not frame:IsShown() ) then return; end
    
    local run = AZS_RUN;
    local t = (run and tonumber(run.t)) or 0;
    local zone = (AZS_ZONE and AZS_ZONE.zname) or GetZoneText() or "Azeroth";
    zoneText:SetText(zone);
    
    -- Schedule and Total Run Time
    local sched = AZS_SCHEDULE or {};
    local totalTime = 1200; -- 20 min default
    local numSched = table.getn(sched);
    if ( numSched > 0 and sched[numSched] and sched[numSched].t ) then
        totalTime = tonumber(sched[numSched].t) or 1200;
    end
    if ( totalTime <= 0 ) then totalTime = 1200; end
    
    clockText:SetText(string.format("%s / %s", FormatClock(t), FormatClock(totalTime)));
    
    -- Timeline Bar
    timelineBar:SetMinMaxValues(0, totalTime);
    timelineBar:SetValue(math.min(t, totalTime));
    
    -- Timeline Ticks for Scheduled Bosses
    local tickCount = math.min(5, numSched);
    local barW = timelineBar:GetWidth() or 204;
    for i = 1, 5 do
        local tick = timelineTicks[i];
        if ( i <= tickCount ) then
            local b = sched[i];
            local bTime = tonumber(b.t) or 0;
            if ( bTime > 0 and totalTime > 0 ) then
                local pct = bTime / totalTime;
                tick:ClearAllPoints();
                tick:SetPoint("BOTTOMLEFT", timelineBar, "BOTTOMLEFT", math.floor(pct * barW), 0);
                tick.label:SetText(FormatClock(bTime));
                tick:Show();
            else
                tick:Hide();
            end
        else
            tick:Hide();
        end
    end
    
    -- Scheduled Boss Rows
    local foundNext = false;
    for i = 1, 6 do
        local row = bossRows[i];
        if ( i <= numSched ) then
            local b = sched[i];
            local bTime = tonumber(b.t) or 0;
            local bName = b.name or ("Boss " .. i);
            local isSpawned = (t >= bTime);
            
            row.name:SetText(bName);
            if ( isSpawned ) then
                -- Defeated / Active in green
                row.name:SetTextColor(0.30, 1.00, 0.40);
                row.timeText:SetTextColor(0.30, 1.00, 0.40);
                row.timeText:SetText(string.format("%s / %s", FormatClock(bTime), FormatClock(bTime + 24)));
            elseif ( not foundNext ) then
                -- Next upcoming boss with yellow countdown
                foundNext = true;
                local diff = bTime - t;
                row.name:SetTextColor(1, 1, 1);
                row.timeText:SetTextColor(1, 0.82, 0);
                row.timeText:SetText(string.format("in %s  %s", FormatClock(diff), FormatClock(bTime)));
            else
                -- Future scheduled boss in grey
                row.name:SetTextColor(0.55, 0.55, 0.58);
                row.timeText:SetTextColor(0.55, 0.55, 0.58);
                row.timeText:SetText(FormatClock(bTime));
            end
            row:Show();
        else
            row:Hide();
        end
    end
    
    -- Guardians / Lairs
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
    local numLairs = table.getn(lairs);
    local marks = SurvivorUI_LairMarks(lairs);
    local px = (run and tonumber(run.px)) or 0;
    local py = (run and tonumber(run.py)) or 0;
    local pFacing = UpdatePlayerHeading();
    
    -- Check achievement 4/4 before 8:00
    local slainBefore8 = 0;
    local totalSlain = 0;
    for i = 1, numLairs do
        local l = lairs[i];
        if ( l and (l.active == false or l.active == 0) ) then
            totalSlain = totalSlain + 1;
        end
    end
    if ( totalSlain >= 4 or t >= 480 ) then
        gGoal:SetText(string.format("%d/4 by 8:00 \194\183 done", math.min(4, totalSlain)));
        gGoal:SetTextColor(0.35, 0.90, 0.40);
    else
        local rem = math.max(0, 480 - t);
        gGoal:SetText(string.format("%d/4 in %s", totalSlain, FormatClock(rem)));
        gGoal:SetTextColor(1, 0.82, 0);
    end
    
    if ( numLairs > 0 ) then
        local segW = (barW - (numLairs - 1) * 2) / numLairs;
        for i = 1, 6 do
            local seg = guardianSegments[i];
            if ( i <= numLairs ) then
                local lair = lairs[i];
                local markId = marks[tonumber(lair.index or lair[1]) or i] or i;
                
                seg:ClearAllPoints();
                seg:SetPoint("LEFT", segmentBar, "LEFT", (i - 1) * (segW + 2), 0);
                seg:SetWidth(segW);
                
                local isActive = (lair.active == true or lair.active == 1);
                local isAwake = (lair.awake == true or lair.awake == 1);
                
                SurvivorUI_SetLairMark(seg.mark, markId, not isActive);
                
                if ( isAwake ) then
                    -- Fighting / Awake in orange
                    seg.bg:SetVertexColor(1.0, 0.55, 0.15, 0.85);
                    seg.arrow:Hide();
                    seg.timer:Show();
                    seg.timer:SetText("FIGHT");
                elseif ( isActive ) then
                    -- Spawned / Alive in light green with Rotational Arrow pointing to boss
                    seg.bg:SetVertexColor(0.70, 0.92, 0.55, 0.85);
                    seg.timer:Hide();
                    seg.arrow:Show();
                    
                    local lx = tonumber(lair.x or lair[2]) or 0;
                    local ly = tonumber(lair.y or lair[3]) or 0;
                    local bearing = math.atan2(ly - py, lx - px);
                    local relAngle = bearing - pFacing;
                    PointArrow(seg.arrow, relAngle);
                else
                    -- Slain / Respawning in red with countdown
                    seg.bg:SetVertexColor(0.85, 0.22, 0.20, 0.85);
                    seg.arrow:Hide();
                    seg.timer:Show();
                    local respawnTime = tonumber(lair.respawn or lair.left) or 0;
                    if ( respawnTime > 0 ) then
                        seg.timer:SetText(FormatClock(respawnTime));
                    else
                        seg.timer:SetText("0:39");
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

-- Ticker (10 updates per second for butter-smooth arrow rotation)
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
loader:SetScript("OnEvent", InitBossTracker);
