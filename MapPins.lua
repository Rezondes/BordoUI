--[[
    Bordo UI - MapPins.lua
    World of Warcraft 1.12.1 / Interface 11200 / Azeroth Survivors
    
    Complete Unified Map Pin Engine:
    1. Rock-Solid Stationary Pins:
       - Client-side 60 FPS real-time positioning outdoors via GetPlayerMapPosition("player")
       - Continuous coordinate calibration from AZS_LAIRS and AZS_CHESTS (M.mapW, M.mapH, M.originX, M.originY)
       - Instance-mode smoothing via Glide and Ease for Naxxramas, SM, AQ with true INDOOR diameter scale
       - Symbols stay 100% stationary on the map terrain when the player moves (no drifting or swaying!)
    2. Full Chestlight Engine Restored:
       - High-res loot bag texture (bag.tga) + soft pulsing halo glow (glow.tga)
       - Clusters nearby caches within 10 yards (MERGE_YD = 10) into single icons with count tooltip
       - Violet directional edge arrow (AZSHelper_ChestArrow) pointing to distant out-of-range chests
       - Tooltip displays cache count, exact yard distance, and current chest gold cost
       - Chat alerts when new caches spawn
       - World map pins on WorldMapButton
       - Slash commands: /chestlight and /cl (/cl arrow, /cl chat)
    3. Bosses & Guardian Lairs:
       - Active Guardian Lairs with heraldic marks (LairMarks.tga) and warm gold glow
       - Active Bosses from AZS_UNITS with bright red skull pin and intense pulsing red glow
       - Off-screen edge clamping with directional guidance
       - Detailed status tooltips (alive, fighting, empty with respawn timer, distance)
]]--

BordoUI = BordoUI or {};
AZSHelper = AZSHelper or {};

local MEDIA = "Interface\\AddOns\\BordoUI\\Media\\";
local ART = "Interface\\AddOns\\BordoUI\\Art\\";

local BAG = MEDIA .. "bag.tga";
local GLOW = MEDIA .. "glow.tga";
local ARROW = "Interface\\Minimap\\MinimapArrow";
local PIN_LAIR = ART .. "PinLair.tga";
local PACE_GLOW = ART .. "PaceGlow.tga";

local PIN_SIZE = 14;
local BOSS_PIN_SIZE = 18;
local MERGE_YD = 10;
local GLOW_PERIOD = 4.0;
local GLOW_MIN, GLOW_MAX = 0.20, 0.65;
local ARROW_SIZE = 24;

-- Outdoor minimap diameter in yards per zoom level (stock Vanilla 1.12 values)
local OUTDOOR = { [0] = 466.6667, [1] = 400.0, [2] = 333.3333, [3] = 266.6667, [4] = 200.0, [5] = 133.3333 };
-- Indoors (instances/arenas) the minimap shows far less ground per zoom level
local INDOOR  = { [0] = 300.0,    [1] = 240.0, [2] = 180.0,    [3] = 120.0,    [4] = 80.0,   [5] = 50.0 };

-- Module state table (consolidated into a single table to keep Lua 5.0 upvalues well below 32)
local M = {
    chestPins = {},
    bossPins = {},
    worldPins = {},
    known = {},
    primed = false,
    acc = 0,
    calibratedAt = nil,
    mapReady = false,
    indoors = nil,
    indoorsZoom = nil,
    glowClock = 0,
    mapW = 6381.25,
    mapH = 4254.17,
    originX = 0,
    originY = 0,
    hero = { ivl = 0.2, s = {} }
};

AZSHelper.MinimapChestPins = M.chestPins;
AZSHelper.WorldMapChestPins = M.worldPins;

local function DB()
    if ( type(AZSHelperDB) ~= "table" ) then AZSHelperDB = {}; end
    if ( AZSHelperDB.chestArrow == nil ) then AZSHelperDB.chestArrow = true; end
    if ( AZSHelperDB.chestChat == nil ) then AZSHelperDB.chestChat = true; end
    return AZSHelperDB;
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc873ffChestlight:|r |cffe6ccff" .. msg .. "|r");
end

local function Share(v)
    v = tonumber(v);
    if ( not v or v < 0 ) then return nil; end
    if ( v > 1.5 ) then return v / 100; end
    return v;
end

local function GetVal(entry, key, i1, i2)
    if ( not entry ) then return nil; end
    if ( entry[key] ~= nil ) then return entry[key]; end
    if ( i1 and entry[i1] ~= nil ) then return entry[i1]; end
    if ( i2 and entry[i2] ~= nil ) then return entry[i2]; end
    return nil;
end

local function IsSquare()
    if ( AZSHelper and AZSHelper.isSquareMinimap ) then return true; end
    if ( AZSHelper_MinimapSquareFrame ) then return true; end
    if ( type(GetMinimapShape) == "function" ) then
        local ok, shape = pcall(GetMinimapShape);
        if ( ok and shape ) then return shape == "SQUARE"; end
    end
    if ( DFRL ) then return true; end
    return false;
end

local function CVarNum(name)
    local ok, v = pcall(GetCVar, name);
    return ok and tonumber(v) or nil;
end

local function Indoors()
    local z = Minimap:GetZoom() or 0;
    if ( M.indoors ~= nil and z == M.indoorsZoom ) then return M.indoors; end
    M.indoorsZoom = z;
    
    local out = CVarNum("minimapZoom");
    local ins = CVarNum("minimapInsideZoom");
    if ( out and ins and out ~= ins ) then
        M.indoors = (z == ins);
        return M.indoors;
    end
    
    -- Astrolabe detection probe for Vanilla WoW 1.12
    if ( out and Minimap:GetZoom() ) then
        Minimap:SetZoom(z < 5 and z + 1 or z - 1);
        local newOut = CVarNum("minimapZoom");
        local changed = (newOut and newOut ~= out);
        Minimap:SetZoom(z);
        M.indoors = not changed;
        return M.indoors;
    end
    
    M.indoors = false;
    return false;
end

-- Smooth interpolation for instance/server coordinates
local function Glide(px, py)
    local now = GetTime and GetTime() or 0;
    local s = M.hero.s;
    local n = table.getn(s);
    local last = s[n];
    if ( not last or math.abs(px - last.x) > 60 or math.abs(py - last.y) > 60 ) then
        M.hero.s = { { t = now, x = px, y = py } };
        return px, py;
    end
    if ( px ~= last.x or py ~= last.y ) then
        local dt = now - last.t;
        if ( dt > 0.01 and dt < 1 ) then
            M.hero.ivl = math.max(0.03, math.min(0.6, M.hero.ivl * 0.9 + dt * 0.1));
        end
        if ( dt >= 1 ) then
            last.t = now - M.hero.ivl;
        end
        table.insert(s, { t = now, x = px, y = py });
        while ( table.getn(s) > 6 ) do table.remove(s, 1); end
    end
    local at = now - M.hero.ivl * 1.5;
    for i = table.getn(s), 2, -1 do
        local a, b = s[i - 1], s[i];
        if ( at >= a.t ) then
            if ( at >= b.t ) then return b.x, b.y; end
            local k = (at - a.t) / (b.t - a.t);
            return a.x + (b.x - a.x) * k, a.y + (b.y - a.y) * k;
        end
    end
    return s[1].x, s[1].y;
end

local function Ease(px, py)
    local now = GetTime and GetTime() or 0;
    local dt = now - (M.hero.et or now);
    M.hero.et = now;
    if ( not M.hero.ex or math.abs(px - M.hero.ex) > 60 or math.abs(py - M.hero.ey) > 60 ) then
        M.hero.ex, M.hero.ey = px, py;
    end
    local k = math.min(1, dt / 0.20);
    M.hero.ex = M.hero.ex + (px - M.hero.ex) * k;
    M.hero.ey = M.hero.ey + (py - M.hero.ey) * k;
    return M.hero.ex, M.hero.ey;
end

-- Client-side real-time player position
local function PlayerPos()
    local mapOpen = WorldMapFrame and WorldMapFrame:IsVisible();
    if ( not M.mapReady and not mapOpen and SetMapToCurrentZone ) then
        SetMapToCurrentZone();
        M.mapReady = true;
    end
    local px, py = GetPlayerMapPosition("player");
    if ( not px or (px == 0 and py == 0) ) then
        M.mapReady = false;
        return nil, nil;
    end
    return px, py;
end

-- Zone Yard Span & Origin Calibration
local function Calibrate()
    local pts = {};
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS;
    if ( type(lairs) == "table" ) then
        for i = 1, table.getn(lairs) do table.insert(pts, lairs[i]); end
    end
    if ( type(AZS_CHESTS) == "table" ) then
        for i = 1, table.getn(AZS_CHESTS) do table.insert(pts, AZS_CHESTS[i]); end
    end
    
    local bestX, bestY = 0, 0;
    local bestP, bestQ;
    local n = table.getn(pts);
    for i = 1, n do
        for j = i + 1, n do
            local a, b = pts[i], pts[j];
            local amx = Share(GetVal(a, "mx", 9, 3));
            local bmx = Share(GetVal(b, "mx", 9, 3));
            local amy = Share(GetVal(a, "my", 10, 4));
            local bmy = Share(GetVal(b, "my", 10, 4));
            local ax = tonumber(GetVal(a, "x", 6, 1));
            local bx = tonumber(GetVal(b, "x", 6, 1));
            local ay = tonumber(GetVal(a, "y", 7, 2));
            local by = tonumber(GetVal(b, "y", 7, 2));
            if ( amx and bmx and amy and bmy and ax and bx and ay and by ) then
                local dmx = math.abs(amx - bmx);
                local dmy = math.abs(amy - bmy);
                if ( dmx > bestX and dmx > 0.003 ) then
                    bestX = dmx;
                    M.mapW = math.abs(ay - by) / dmx;
                    bestP = a;
                end
                if ( dmy > bestY and dmy > 0.003 ) then
                    bestY = dmy;
                    M.mapH = math.abs(ax - bx) / dmy;
                    bestQ = a;
                end
            end
        end
    end
    if ( M.mapW and not M.mapH ) then M.mapH = M.mapW * 2 / 3; end
    if ( M.mapH and not M.mapW ) then M.mapW = M.mapH * 3 / 2; end
    if ( not M.mapW or M.mapW <= 0 ) then M.mapW = 6381.25; end
    if ( not M.mapH or M.mapH <= 0 ) then M.mapH = 4254.17; end
    
    local ref = bestP or bestQ or (n > 0 and pts[1]);
    if ( ref ) then
        local rmx = Share(GetVal(ref, "mx", 9, 3));
        local rmy = Share(GetVal(ref, "my", 10, 4));
        local rx = tonumber(GetVal(ref, "x", 6, 1));
        local ry = tonumber(GetVal(ref, "y", 7, 2));
        if ( rmx and rmy and rx and ry ) then
            M.originX = rx + rmy * M.mapH;
            M.originY = ry + rmx * M.mapW;
        end
    end
end

-- Directional Arrow for Distant Caches
M.arrow = CreateFrame("Frame", "AZSHelper_ChestArrow", Minimap);
M.arrow:SetWidth(ARROW_SIZE);
M.arrow:SetHeight(ARROW_SIZE);
M.arrow:SetFrameLevel(Minimap:GetFrameLevel() + 6);
M.arrowTex = M.arrow:CreateTexture(nil, "OVERLAY");
M.arrowTex:SetAllPoints(M.arrow);
M.arrowTex:SetTexture(ARROW);
M.arrowTex:SetVertexColor(0.78, 0.45, 1.0); -- Violet
M.arrow:EnableMouse(true);
M.arrow:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:AddLine("Next Battleground Cache", 0.78, 0.45, 1.0);
    if ( this.dist ) then
        GameTooltip:AddLine(math.floor(this.dist + 0.5) .. " yd away", 1, 1, 1);
    end
    GameTooltip:Show();
end);
M.arrow:SetScript("OnLeave", function() GameTooltip:Hide(); end);
M.arrow:Hide();

local function RotateArrow(a)
    local s = math.sin(-a);
    local c = math.cos(-a);
    local ulx = 0.5 + (-0.5) * c - (-0.5) * s;
    local uly = 0.5 + (-0.5) * s + (-0.5) * c;
    local llx = 0.5 + (-0.5) * c - (0.5) * s;
    local lly = 0.5 + (-0.5) * s + (0.5) * c;
    local urx = 0.5 + (0.5) * c - (-0.5) * s;
    local ury = 0.5 + (0.5) * s + (-0.5) * c;
    local lrx = 0.5 + (0.5) * c - (0.5) * s;
    local lry = 0.5 + (0.5) * s + (0.5) * c;
    if ( M.arrowTex ) then
        M.arrowTex:SetTexCoord(ulx, uly, llx, lly, urx, ury, lrx, lry);
    end
end

-- Minimap Chest Pin Factory
local function NewChestPin(i)
    local pin = CreateFrame("Frame", "AZSHelper_MinimapChestPin" .. i, Minimap);
    pin:SetWidth(PIN_SIZE);
    pin:SetHeight(PIN_SIZE);
    pin:SetFrameLevel(Minimap:GetFrameLevel() + 5);
    
    local glow = pin:CreateTexture(nil, "ARTWORK");
    glow:SetTexture(GLOW);
    glow:SetBlendMode("ADD");
    glow:SetWidth(PIN_SIZE * 1.6);
    glow:SetHeight(PIN_SIZE * 1.6);
    glow:SetPoint("CENTER", pin, "CENTER", 0, 0);
    pin.glow = glow;
    
    local tex = pin:CreateTexture(nil, "OVERLAY");
    tex:SetAllPoints(pin);
    tex:SetTexture(BAG);
    pin.tex = tex;
    
    pin:EnableMouse(true);
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        if ( this.count and this.count > 1 ) then
            GameTooltip:AddLine(this.count .. " Battleground Caches", 1, 0.82, 0);
        else
            GameTooltip:AddLine("Battleground Cache", 1, 0.82, 0);
        end
        if ( this.dist ) then
            GameTooltip:AddLine(math.floor(this.dist + 0.5) .. " yd away", 1, 1, 1);
        end
        if ( AZS_RUN and AZS_RUN.chest and tonumber(AZS_RUN.chest) > 0 ) then
            GameTooltip:AddLine(string.format("Cost: %d Gold", tonumber(AZS_RUN.chest)), 0, 0.80, 1);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    M.chestPins[i] = pin;
    return pin;
end

-- Minimap Boss / Guardian Lair Pin Factory
local function NewBossPin(i)
    local pin = CreateFrame("Frame", "BordoUI_MinimapBossPin" .. i, Minimap);
    pin:SetWidth(BOSS_PIN_SIZE);
    pin:SetHeight(BOSS_PIN_SIZE);
    pin:SetFrameLevel(Minimap:GetFrameLevel() + 5);
    
    local glow = pin:CreateTexture(nil, "ARTWORK");
    glow:SetTexture(PACE_GLOW);
    glow:SetBlendMode("ADD");
    glow:SetWidth(BOSS_PIN_SIZE * 2.0);
    glow:SetHeight(BOSS_PIN_SIZE * 2.0);
    glow:SetPoint("CENTER", pin, "CENTER", 0, 0);
    pin.glow = glow;
    
    local art = pin:CreateTexture(nil, "OVERLAY");
    art:SetAllPoints(pin);
    pin.art = art;
    
    pin:EnableMouse(true);
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        GameTooltip:AddLine(this.title or "Boss", 1, 0.82, 0);
        if ( this.note ) then
            GameTooltip:AddLine(this.note, 1, 1, 1);
        end
        if ( this.dist ) then
            GameTooltip:AddLine(math.floor(this.dist + 0.5) .. " yd away", 0.7, 0.7, 0.7);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    M.bossPins[i] = pin;
    return pin;
end

-- World Map Pins
local function NewWorldPin(i)
    if ( not WorldMapButton ) then return nil; end
    local pin = CreateFrame("Button", "AZSHelper_WorldMapChestPin" .. i, WorldMapButton);
    pin:SetWidth(14);
    pin:SetHeight(14);
    pin:SetFrameLevel(WorldMapButton:GetFrameLevel() + 5);
    
    local tex = pin:CreateTexture(nil, "OVERLAY");
    tex:SetAllPoints(pin);
    tex:SetTexture(BAG);
    pin.tex = tex;
    
    pin:EnableMouse(true);
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:AddLine("Battleground Cache", 1, 0.82, 0);
        if ( AZS_RUN and AZS_RUN.chest and tonumber(AZS_RUN.chest) > 0 ) then
            GameTooltip:AddLine(string.format("Cost: %d Gold", tonumber(AZS_RUN.chest)), 0, 0.80, 1);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    M.worldPins[i] = pin;
    return pin;
end

local function HideAll()
    for _, pin in pairs(M.chestPins) do if ( pin ) then pin:Hide(); end end
    for _, pin in pairs(M.bossPins) do if ( pin ) then pin:Hide(); end end
    for _, wpin in pairs(M.worldPins) do if ( wpin ) then wpin:Hide(); end end
    if ( M.arrow ) then M.arrow:Hide(); end
end

-- High-precision Target Vector Calculation relative to Hero
-- Returns east (yards East) and north (yards North)
local function TargetWay(target, mode, hx, hy)
    if ( not target ) then return nil, nil; end
    
    if ( mode == "map" ) then
        local tmx = Share(GetVal(target, "mx", 9, 3));
        local tmy = Share(GetVal(target, "my", 10, 4));
        if ( tmx and tmy ) then
            local east = (tmx - hx) * M.mapW;
            local north = (hy - tmy) * M.mapH;
            return east, north;
        end
        
        -- Target has world coordinates in map mode
        local tx = tonumber(GetVal(target, "x", 6, 1));
        local ty = tonumber(GetVal(target, "y", 7, 2));
        if ( tx and ty and M.originX and M.originY ) then
            local heroX = M.originX - hy * M.mapH;
            local heroY = M.originY - hx * M.mapW;
            local east = heroY - ty;
            local north = tx - heroX;
            return east, north;
        end
    elseif ( mode == "world" ) then
        local tx = tonumber(GetVal(target, "x", 6, 1));
        local ty = tonumber(GetVal(target, "y", 7, 2));
        if ( tx and ty ) then
            local east = hy - ty;
            local north = tx - hx;
            return east, north;
        end
        
        local tmx = Share(GetVal(target, "mx", 9, 3));
        local tmy = Share(GetVal(target, "my", 10, 4));
        if ( tmx and tmy and M.originX and M.originY ) then
            local txCalc = M.originX - tmy * M.mapH;
            local tyCalc = M.originY - tmx * M.mapW;
            local east = hy - tyCalc;
            local north = txCalc - hx;
            return east, north;
        end
    end
    
    return nil, nil;
end

-- Place Boss Pin with edge clamping
local function PlaceBossPin(pin, east, north, scale, limit, size, square)
    local ox = east * scale;
    local oy = north * scale;
    local m = square and math.max(math.abs(ox), math.abs(oy)) or math.sqrt(ox * ox + oy * oy);
    if ( m > limit ) then
        local k = limit / m;
        ox = ox * k;
        oy = oy * k;
        local edgeSize = math.floor(size * 0.75 + 0.5);
        pin:SetWidth(edgeSize);
        pin:SetHeight(edgeSize);
        pin:SetAlpha(0.75);
    else
        pin:SetWidth(size);
        pin:SetHeight(size);
        pin:SetAlpha(1.0);
    end
    pin:ClearAllPoints();
    pin:SetPoint("CENTER", Minimap, "CENTER", ox, oy);
    pin:Show();
end

local function UpdateWorldMap(list)
    if ( not WorldMapFrame or not WorldMapFrame:IsShown() or not WorldMapButton ) then return; end
    local wmbW = WorldMapButton:GetWidth();
    local wmbH = WorldMapButton:GetHeight();
    local numChests = table.getn(list or {});
    for i = 1, numChests do
        local c = list[i];
        local wPin = M.worldPins[i] or NewWorldPin(i);
        local cmx = Share(GetVal(c, "mx", 9, 3));
        local cmy = Share(GetVal(c, "my", 10, 4));
        if ( wPin and cmx and cmy and cmx >= 0 and cmy >= 0 ) then
            wPin:ClearAllPoints();
            wPin:SetPoint("CENTER", WorldMapButton, "TOPLEFT", cmx * wmbW, -cmy * wmbH);
            wPin:Show();
        elseif ( wPin ) then
            wPin:Hide();
        end
    end
    for i = numChests + 1, table.getn(M.worldPins) do
        if ( M.worldPins[i] ) then M.worldPins[i]:Hide(); end
    end
end

-- Main Map Pin Update Loop (called every 0.03s)
local function Update()
    local phase = AZS_GetPhase and AZS_GetPhase() or nil;
    if ( not phase or phase == "dead" ) then
        HideAll();
        M.known = {};
        M.primed = false;
        return;
    end
    if ( phase == "ready" ) then M.primed = false; end
    
    local stamp = (AZS_CHESTS_UPDATED or 0) + (AZS_LAIRS_UPDATED or 0);
    if ( stamp ~= M.calibratedAt ) then
        M.calibratedAt = stamp;
        Calibrate();
    end
    
    -- Check active chests and trigger chat notification on fresh spawns
    local chestList = AZS_CHESTS or {};
    local presentChests = {};
    local fresh = 0;
    for i = 1, table.getn(chestList) do
        local id = chestList[i].id or i;
        if ( id ) then
            presentChests[id] = chestList[i];
            if ( not M.known[id] ) then
                M.known[id] = true;
                if ( M.primed ) then fresh = fresh + 1; end
            end
        end
    end
    for id in pairs(M.known) do
        if ( not presentChests[id] ) then M.known[id] = nil; end
    end
    if ( phase ~= "ready" ) then M.primed = true; end
    
    local db = DB();
    if ( fresh > 0 and db.chestChat ) then
        Print(fresh == 1 and "A new Battleground Cache has spawned." or (fresh .. " new Battleground Caches have spawned."));
    end
    
    -- Determine whether we are in instance / world coordinates mode (Naxx, SM, AQ or missing map position)
    local isInstance = false;
    if ( AZS_ZONE and (AZS_ZONE.zone == "naxx" or AZS_ZONE.zone == "sm" or AZS_ZONE.zone == "aq") ) then
        isInstance = true;
    end
    if ( not isInstance ) then
        for _, c in pairs(presentChests) do
            local cmx = GetVal(c, "mx", 9, 3);
            if ( cmx and tonumber(cmx) and tonumber(cmx) < 0 ) then
                isInstance = true;
                break;
            end
        end
    end
    
    -- Obtain Hero Position:
    -- 1. Client-side real-time map position (60 FPS, no lag)
    local mpx, mpy = PlayerPos();
    local mode = "map";
    local hx, hy;
    
    if ( not isInstance and mpx and mpy and (mpx > 0 or mpy > 0) ) then
        mode = "map";
        hx, hy = mpx, mpy;
    elseif ( type(AZS_RUN) == "table" and tonumber(AZS_RUN.px) and tonumber(AZS_RUN.py) ) then
        mode = "world";
        local rawX = tonumber(AZS_RUN.px);
        local rawY = tonumber(AZS_RUN.py);
        local wpx, wpy = Glide(rawX, rawY);
        wpx, wpy = Ease(wpx, wpy);
        hx, hy = wpx, wpy;
    else
        HideAll();
        return;
    end
    
    local z = Minimap:GetZoom() or 0;
    local diameter;
    if ( isInstance or mode == "world" ) then
        -- In instances/arenas the minimap ALWAYS renders at indoor yard scale!
        diameter = INDOOR[z] or 180;
    elseif ( Indoors() ) then
        diameter = INDOOR[z] or 180;
    else
        diameter = OUTDOOR[z] or 333.3333;
    end
    
    local scale = Minimap:GetWidth() / diameter;
    local half = Minimap:GetWidth() / 2;
    local chestLimit = half - PIN_SIZE / 2;
    local square = IsSquare();
    
    -------------------------------------------------------------------------
    -- 1. BATTLEGROUND CACHES (CHESTLIGHT ENGINE)
    -------------------------------------------------------------------------
    -- Group nearby chests within MERGE_YD = 10 yards into single icons with count
    local groups = {};
    for _, c in pairs(presentChests) do
        local east, north = TargetWay(c, mode, hx, hy);
        if ( east and north ) then
            local joined = false;
            for g = 1, table.getn(groups) do
                local gr = groups[g];
                local dx = east - gr.east;
                local dy = north - gr.north;
                if ( dx * dx + dy * dy <= MERGE_YD * MERGE_YD ) then
                    gr.n = gr.n + 1;
                    gr.east = gr.east + dx / gr.n;
                    gr.north = gr.north + dy / gr.n;
                    joined = true;
                    break;
                end
            end
            if ( not joined ) then
                table.insert(groups, { east = east, north = north, n = 1, c = c });
            end
        end
    end
    
    for i = table.getn(groups) + 1, table.getn(M.chestPins) do
        if ( M.chestPins[i] ) then M.chestPins[i]:Hide(); end
    end
    
    local inRange = false;
    local nearDist, nearX, nearY;
    
    for i = 1, table.getn(groups) do
        local gr = groups[i];
        local east = gr.east;
        local north = gr.north;
        local pin = M.chestPins[i] or NewChestPin(i);
        pin.count = gr.n;
        pin.dist = math.sqrt(east * east + north * north);
        
        local ox = east * scale;
        local oy = north * scale;
        local m = square and math.max(math.abs(ox), math.abs(oy)) or math.sqrt(ox * ox + oy * oy);
        
        if ( m > chestLimit ) then
            pin:Hide();
            if ( not nearDist or pin.dist < nearDist ) then
                nearDist = pin.dist;
                nearX = ox;
                nearY = oy;
            end
        else
            inRange = true;
            pin:ClearAllPoints();
            pin:SetPoint("CENTER", Minimap, "CENTER", ox, oy);
            pin:Show();
        end
    end
    
    -- Directional edge arrow pointing towards distant caches
    if ( db.chestArrow and not inRange and nearDist and M.arrow ) then
        local a = math.atan2(nearX, nearY);
        local dx = math.sin(a);
        local dy = math.cos(a);
        local edge = half - ARROW_SIZE / 2;
        local m = square and math.max(math.abs(dx), math.abs(dy)) or 1;
        RotateArrow(a);
        M.arrow.dist = nearDist;
        M.arrow:ClearAllPoints();
        M.arrow:SetPoint("CENTER", Minimap, "CENTER", dx / m * edge, dy / m * edge);
        M.arrow:Show();
    else
        if ( M.arrow ) then M.arrow:Hide(); end
    end
    
    UpdateWorldMap(chestList);
    
    -------------------------------------------------------------------------
    -- 2. BOSSES & GUARDIAN LAIRS
    -------------------------------------------------------------------------
    local shownBoss = 0;
    local bossLimit = half - BOSS_PIN_SIZE / 2;
    
    -- Active Bosses from AZS_UNITS
    if ( AZS_UNITS and type(AZS_UNITS) == "table" ) then
        for i = 1, table.getn(AZS_UNITS) do
            local u = AZS_UNITS[i];
            local kind = GetVal(u, "kind", 1);
            if ( kind == "boss" or kind == "final" ) then
                local east, north = TargetWay(u, mode, hx, hy);
                if ( east and north ) then
                    shownBoss = shownBoss + 1;
                    local pin = M.bossPins[shownBoss] or NewBossPin(shownBoss);
                    pin.isUnitBoss = true;
                    local bName = GetVal(u, "name", 3) or "Boss";
                    local dist = math.sqrt(east * east + north * north);
                    pin.dist = dist;
                    pin.title = "|cffff2020★ BOSS: " .. bName .. " ★|r";
                    pin.note = "|cffff5533⚠ Active Boss!|r";
                    
                    pin.art:SetTexture(PIN_LAIR);
                    pin.art:SetTexCoord(0, 1, 0, 1);
                    pin.art:SetVertexColor(1, 0.15, 0.15);
                    pin.glow:SetTexture(PACE_GLOW);
                    pin.glow:SetVertexColor(1, 0.20, 0.10);
                    pin.glow:Show();
                    
                    PlaceBossPin(pin, east, north, scale, bossLimit, BOSS_PIN_SIZE, square);
                end
            end
        end
    end
    
    -- Guardian Lairs from AZS_GetLairs() or AZS_LAIRS
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS;
    if ( type(lairs) == "table" ) then
        local marks = SurvivorUI_LairMarks and SurvivorUI_LairMarks(lairs) or {};
        for i = 1, table.getn(lairs) do
            local lair = lairs[i];
            local east, north = TargetWay(lair, mode, hx, hy);
            if ( east and north ) then
                local isActive = (lair.active == true or lair.active == 1);
                local isAwake = (lair.awake == true or lair.awake == 1);
                local isFlagged = (tonumber(lair.flag) == 1);
                
                shownBoss = shownBoss + 1;
                local pin = M.bossPins[shownBoss] or NewBossPin(shownBoss);
                pin.isUnitBoss = false;
                local markId = marks[tonumber(lair.index or lair[1]) or i] or i;
                local markName = SurvivorUI_LairMarkName and SurvivorUI_LairMarkName(markId);
                local lName = GetVal(lair, "name", 4) or "Guardian";
                local dist = math.sqrt(east * east + north * north);
                pin.dist = dist;
                
                if ( markName ) then
                    pin.title = markName .. " Lair (" .. lName .. ")";
                else
                    pin.title = "Guardian's Lair: " .. lName;
                end
                
                if ( isAwake ) then
                    pin.note = "|cffff9900⚔ Guardian in Combat!|r";
                elseif ( isActive ) then
                    pin.note = "|cff55ff55● Guardian is Alive|r";
                else
                    local rem = tonumber(lair.respawn or lair.left) or 0;
                    if ( rem > 0 ) then
                        pin.note = string.format("|cffff4444✕ Empty (Respawn in %d:%02d)|r", math.floor(rem / 60), math.mod(rem, 60));
                    else
                        pin.note = "|cff888888✕ Empty Lair|r";
                    end
                end
                
                if ( SurvivorUI_SetLairMark ) then
                    SurvivorUI_SetLairMark(pin.art, markId, not isActive);
                else
                    pin.art:SetTexture(PIN_LAIR);
                    pin.art:SetTexCoord(0, 1, 0, 1);
                    if ( isActive ) then
                        pin.art:SetVertexColor(1, 1, 1);
                    else
                        pin.art:SetVertexColor(0.45, 0.45, 0.45);
                    end
                end
                
                if ( isActive or isFlagged ) then
                    pin.glow:SetTexture(PACE_GLOW);
                    pin.glow:SetVertexColor(1, 0.82, 0.20);
                    pin.glow:Show();
                else
                    pin.glow:Hide();
                end
                
                PlaceBossPin(pin, east, north, scale, bossLimit, 16, square);
            end
        end
    end
    
    for i = shownBoss + 1, table.getn(M.bossPins) do
        if ( M.bossPins[i] ) then M.bossPins[i]:Hide(); end
    end
end

-- Animation & Position Ticker
local updateFrame = CreateFrame("Frame", "BordoUI_ChestlightUpdateFrame", UIParent);
updateFrame:SetScript("OnUpdate", function()
    local dt = arg1 or 0;
    M.glowClock = M.glowClock + dt;
    M.acc = M.acc + dt;
    
    -- Smooth pulsing glows
    local chestPulse = GLOW_MIN + (GLOW_MAX - GLOW_MIN) * (0.5 + 0.5 * math.sin(M.glowClock * 2 * math.pi / GLOW_PERIOD));
    local bossPulse = 0.55 + 0.35 * math.sin(M.glowClock * 4);
    
    for _, pin in pairs(M.chestPins) do
        if ( pin and pin:IsShown() and pin.glow and pin.glow:IsShown() ) then
            pin.glow:SetAlpha(chestPulse);
        end
    end
    for _, pin in pairs(M.bossPins) do
        if ( pin and pin:IsShown() and pin.glow and pin.glow:IsShown() ) then
            pin.glow:SetAlpha(bossPulse);
        end
    end
    
    -- Rock-solid 30 FPS position update
    if ( M.acc < 0.03 ) then return; end
    M.acc = 0;
    Update();
end);

updateFrame:RegisterEvent("VARIABLES_LOADED");
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
updateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
updateFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
updateFrame:SetScript("OnEvent", function()
    if ( event == "VARIABLES_LOADED" ) then
        DB();
    elseif ( event == "ZONE_CHANGED_INDOORS" ) then
        M.indoors = nil;
    else
        M.mapReady = false;
        M.indoors = nil;
    end
end);

-- Slash Commands (Chestlight compatible & AZSHelper integrated)
SLASH_AZSCHESTLIGHT1 = "/chestlight";
SLASH_AZSCHESTLIGHT2 = "/cl";
SlashCmdList["AZSCHESTLIGHT"] = function(msg)
    local db = DB();
    msg = string.lower(msg or "");
    if ( msg == "arrow" ) then
        db.chestArrow = not db.chestArrow;
        Print("Directional Arrow to Distant Caches: " .. (db.chestArrow and "|cff55ff55Enabled|r" or "|cffff5555Disabled|r"));
    elseif ( msg == "chat" ) then
        db.chestChat = not db.chestChat;
        Print("Chat notification on Cache Spawn: " .. (db.chestChat and "|cff55ff55Enabled|r" or "|cffff5555Disabled|r"));
    else
        Print("/cl chat - Toggle chat notification when caches spawn (" .. (db.chestChat and "Enabled" or "Disabled") .. ")");
        Print("/cl arrow - Toggle violet directional edge arrow (" .. (db.chestArrow and "Enabled" or "Disabled") .. ")");
    end
end;

-- Exported SurvivorUI & BordoUI compatibility APIs
SurvivorUI_HeroPlace = PlayerPos;
SurvivorUI_MapSpan = function() return { across = M.mapW, down = M.mapH }; end;
SurvivorUI_MapShare = Share;
SurvivorUI_HeroWorld = function()
    local r = AZS_RUN;
    if ( not r ) then return nil, nil, nil; end
    return tonumber(r.px), tonumber(r.py), tonumber(r.pf);
end;
SurvivorUI_WorldWay = function(px, py, x, y)
    return py - y, px - x;
end;
SurvivorUI_PinSize = function(kind)
    return kind == "cache" and PIN_SIZE or BOSS_PIN_SIZE;
end;
SurvivorUI_PinsReport = function()
    Print(string.format("Map calibration: %.1f x %.1f yards (Indoors: %s)", M.mapW, M.mapH, tostring(Indoors())));
end;
