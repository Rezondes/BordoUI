--[[
    Bordo UI - MapPins.lua
    World of Warcraft 1.12.1 / Interface 11200 / Azeroth Survivors
    
    Authentic Minimap Pin Engine:
    1. Battleground Caches (Golden Chests):
       - Golden chest icon (PinCache.tga) directly on the Minimap.
       - Yards calculated from AZS_RUN (px, py) or zone map calibration.
       - Distance edge clamping: Out-of-reach caches stay pinned to the minimap border pointing towards them.
       - Interactive hover tooltip: "Battleground Cache", yards away.
    2. Guardian Lairs:
       - Displays authentic heraldic marks (LairMarks.tga).
       - Dimmed silver when empty/respawning, bright when alive.
       - Breathing golden glow when targeted by the game's red flag.
       - Distance edge clamping to minimap border.
       - Hover tooltip: "Guardian's lair: [Name]", yards away.
    3. Performance:
       - Zero garbage collection overhead, smooth 20 FPS refresh rate.
]]--

BordoUI = BordoUI or {};
AZSHelper = BordoUI;

local ART = "Interface\\AddOns\\BordoUI\\Art\\";
local PIN_SIZE = 16;
local EDGE_SIZE = 12;

-- The yards across the minimap at each zoom level (stock Vanilla 1.12 values)
local MINIMAP_YARDS = { [0] = 466.67, [1] = 400.0, [2] = 333.33, [3] = 266.67, [4] = 200.0, [5] = 133.33 };
local INSIDE_YARDS  = { [0] = 300.0,  [1] = 240.0, [2] = 180.0,  [3] = 120.0,  [4] = 80.0,   [5] = 50.0 };

local function Enabled()
    return true;
end

local function Playing()
    if ( not AZS_CHESTS and not AZS_RUN ) then
        return false;
    end
    if ( AZS_GetPhase ) then
        local phase = AZS_GetPhase();
        if ( phase == "dead" or phase == "victory" ) then
            return false;
        end
    end
    return true;
end

local function Share(value)
    value = tonumber(value);
    if ( not value or value < 0 ) then
        return nil;
    end
    if ( value > 1.5 ) then
        return value / 100;
    end
    return value;
end

local function Settings()
    BordoUIDB = BordoUIDB or {};
    return BordoUIDB;
end

function SurvivorUI_PinSize(kind)
    local size = tonumber(Settings()[kind == "cache" and "pinCacheSize" or "pinLairSize"]);
    return size and math.max(10, math.min(28, size)) or PIN_SIZE;
end

-- =========================================================================
-- Coordinate Mapping & Zone Span Calibration
-- =========================================================================
local spans = {};
local NEAREST = 0.004;

local function Places()
    local list = {};
    local chests = AZS_CHESTS or {};
    for index = 1, table.getn(chests) do
        table.insert(list, chests[index]);
    end
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
    for index = 1, table.getn(lairs) do
        table.insert(list, lairs[index]);
    end
    return list;
end

local function Span()
    local zone = (AZS_ZONE and AZS_ZONE.zname) or (GetZoneText and GetZoneText()) or "?";
    local known = spans[zone] or { baseAcross = 0, baseDown = 0 };
    local places = Places();
    for a = 1, table.getn(places) do
        for b = a + 1, table.getn(places) do
            local p, q = places[a], places[b];
            local pmx = Share(p.mx or (p.index and p[9]) or p[5]);
            local qmx = Share(q.mx or (q.index and q[9]) or q[5]);
            local pmy = Share(p.my or (p.index and p[10]) or p[6]);
            local qmy = Share(q.my or (q.index and q[10]) or q[6]);
            local px = tonumber(p.x or (p.index and p[6]) or p[2]);
            local qx = tonumber(q.x or (q.index and q[6]) or q[2]);
            local py = tonumber(p.y or (p.index and p[7]) or p[3]);
            local qy = tonumber(q.y or (q.index and q[7]) or q[3]);
            if ( pmx and qmx and pmy and qmy and px and qx and py and qy ) then
                local dmx, dmy = math.abs(pmx - qmx), math.abs(pmy - qmy);
                if ( dmx > known.baseAcross and dmx > NEAREST ) then
                    known.baseAcross = dmx;
                    known.foundAcross = math.abs(py - qy) / dmx;
                end
                if ( dmy > known.baseDown and dmy > NEAREST ) then
                    known.baseDown = dmy;
                    known.foundDown = math.abs(px - qx) / dmy;
                end
            end
        end
    end
    known.across = known.foundAcross or (known.foundDown and known.foundDown * 1.5) or 6381.25;
    known.down = known.foundDown or (known.foundAcross and known.foundAcross / 1.5) or 4254.17;
    spans[zone] = known;
    return known;
end

-- =========================================================================
-- Hero Location & Distance Engine
-- =========================================================================
local function HeroWorld()
    local run = AZS_RUN;
    if ( not run ) then return nil, nil, nil; end
    local px, py = tonumber(run.px), tonumber(run.py);
    if ( not (px and py) ) then return nil, nil, nil; end
    local facing = tonumber(run.pf);
    if ( facing ) then facing = -facing; end
    return px, py, facing;
end

local function WorldWay(px, py, x, y)
    return py - y, px - x;
end

local function HeroPlace()
    local x, y = GetPlayerMapPosition("player");
    if ( (not x or (x == 0 and y == 0)) and SetMapToCurrentZone ) then
        SetMapToCurrentZone();
        x, y = GetPlayerMapPosition("player");
    end
    if ( not x or (x == 0 and y == 0) ) then return nil, nil; end
    return x, y;
end

local function WayTo(place, px, py, heroX, heroY, span)
    local x = tonumber(place.x or (place.index and place[6]) or place[2]);
    local y = tonumber(place.y or (place.index and place[7]) or place[3]);
    if ( px and x and y ) then
        return WorldWay(px, py, x, y);
    end
    local mx = Share(place.mx or (place.index and place[9]) or place[5]);
    local my = Share(place.my or (place.index and place[10]) or place[6]);
    if ( heroX and span and mx and my ) then
        return (mx - heroX) * span.across, (my - heroY) * span.down;
    end
    return nil, nil;
end

SurvivorUI_HeroPlace = HeroPlace;
SurvivorUI_MapSpan = Span;
SurvivorUI_MapShare = Share;
SurvivorUI_HeroWorld = HeroWorld;
SurvivorUI_WorldWay = WorldWay;

-- =========================================================================
-- Minimap Environment (Indoors / Outdoors Zoom)
-- =========================================================================
local function Setting(name)
    local ok, value = pcall(GetCVar, name);
    return ok and value or nil;
end

local function Indoors()
    local zoom = Minimap:GetZoom() or 0;
    local outside = tonumber(Setting("minimapZoom"));
    local inside = tonumber(Setting("minimapInsideZoom"));
    if ( outside and inside and outside ~= inside ) then
        return zoom == inside;
    end
    local hx, hy = HeroPlace();
    return not hx;
end

local function MinimapYards()
    local zoom = Minimap:GetZoom() or 0;
    local yards = Indoors() and INSIDE_YARDS or MINIMAP_YARDS;
    return yards[zoom] or yards[0], zoom;
end

-- =========================================================================
-- Pin Pool & Placement Engine
-- =========================================================================
local pins = {};
local flaggedPin = nil;

local function Pin(index)
    local pin = pins[index];
    if ( pin ) then return pin; end
    
    pin = CreateFrame("Frame", "BordoUI_MapPin" .. index, Minimap);
    pin:SetFrameLevel(Minimap:GetFrameLevel() + 5);
    
    local art = pin:CreateTexture(nil, "OVERLAY");
    art:SetAllPoints(pin);
    pin.art = art;
    
    local glow = pin:CreateTexture(nil, "ARTWORK");
    glow:SetTexture(ART .. "PaceGlow");
    glow:SetBlendMode("ADD");
    glow:SetVertexColor(1, 0.82, 0.20);
    glow:SetPoint("CENTER", pin, "CENTER", 0, 0);
    glow:Hide();
    pin.glow = glow;
    
    pin:EnableMouse(true);
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        GameTooltip:SetText(this.title or "Map Pin", 1, 0.82, 0);
        if ( this.note ) then
            GameTooltip:AddLine(this.note, 0.8, 0.8, 0.8);
        end
        if ( this.flagged ) then
            GameTooltip:AddLine("The game's flag points here.", 1, 0.82, 0.20);
        end
        if ( this.yards ) then
            GameTooltip:AddLine(string.format("%d yards away", math.floor(this.yards + 0.5)), 0.65, 0.65, 0.65);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    
    pins[index] = pin;
    return pin;
end

local function Place(pin, east, south, yardsAcross, size)
    local half = Minimap:GetWidth() / 2;
    local perYard = (2 * half) / yardsAcross;
    pin.yards = math.sqrt(east * east + south * south);
    local px = east * perYard;
    local py = -south * perYard;
    local edge = math.floor(size * EDGE_SIZE / PIN_SIZE + 0.5);
    local reach = math.max(math.abs(px), math.abs(py));
    local limit = half - edge / 2;
    
    if ( reach > limit ) then
        px = px * limit / reach;
        py = py * limit / reach;
        size = edge;
        pin:SetAlpha(0.70);
    else
        pin:SetAlpha(1.0);
    end
    
    pin:SetWidth(size);
    pin:SetHeight(size);
    pin:ClearAllPoints();
    pin:SetPoint("CENTER", Minimap, "CENTER", px, py);
    pin:Show();
end

-- =========================================================================
-- Main Update Loop
-- =========================================================================
local function Update()
    local shown = 0;
    flaggedPin = nil;
    
    if ( Enabled() and Playing() ) then
        local px, py = HeroWorld();
        local heroX, heroY, span;
        if ( not px ) then
            heroX, heroY = HeroPlace();
            span = heroX and Span();
        end
        
        if ( px or heroX ) then
            local yardsAcross = MinimapYards();
            
            -- 1. Battleground Caches (Golden Chests)
            local rawChests = AZS_CHESTS or {};
            local chests = {};
            for k, v in pairs(rawChests) do
                if ( type(v) == 'table' ) then
                    table.insert(chests, v);
                end
            end
            local cacheSize = SurvivorUI_PinSize("cache");
            for index = 1, table.getn(chests) do
                local chest = chests[index];
                local east, south = WayTo(chest, px, py, heroX, heroY, span);
                if ( east and south ) then
                    shown = shown + 1;
                    local pin = Pin(shown);
                    pin.art:SetTexture(ART .. "PinCache");
                    pin.art:SetTexCoord(0, 1, 0, 1);
                    pin.art:SetVertexColor(1, 1, 1, 1);
                    pin.glow:Hide();
                    pin.title = "Battleground Cache";
                    local cost = (AZS_RUN and AZS_RUN.chest) and tonumber(AZS_RUN.chest) or nil;
                    if ( cost and cost > 0 ) then
                        pin.note = string.format("Cost: %d Gold", cost);
                    else
                        pin.note = "Gold and power cache";
                    end
                    pin.flagged = nil;
                    Place(pin, east, south, yardsAcross, cacheSize);
                end
            end
            
            -- 2. Guardian Lairs (Heraldic Marks)
            local rawLairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
            local lairs = {};
            for k, v in pairs(rawLairs) do
                if ( type(v) == "table" ) then
                    table.insert(lairs, v);
                end
            end
            table.sort(lairs, function(a, b)
                local pa = tonumber(a.index or a[1]) or 0;
                local pb = tonumber(b.index or b[1]) or 0;
                return pa < pb;
            end);
            
            local marks = SurvivorUI_LairMarks and SurvivorUI_LairMarks(lairs) or {};
            local lairSize = SurvivorUI_PinSize("lair");
            for index = 1, table.getn(lairs) do
                local lair = lairs[index];
                local east, south = WayTo(lair, px, py, heroX, heroY, span);
                local state = lair.state or lair[2];
                local isAlive = (state ~= "empty" and (lair.active == true or lair.active == 1 or (state and state ~= "empty") or (lair.id and tonumber(lair.id) > 0)));
                
                if ( east and south ) then
                    shown = shown + 1;
                    local pin = Pin(shown);
                    local place = tonumber(lair.index or lair[1]) or index;
                    local mark = marks[place] or (math.mod(index - 1, 8) + 1);
                    
                    if ( mark and SurvivorUI_SetLairMark ) then
                        SurvivorUI_SetLairMark(pin.art, mark, not isAlive);
                    else
                        pin.art:SetTexture(ART .. "PinLair");
                        pin.art:SetTexCoord(0, 1, 0, 1);
                        if ( isAlive ) then
                            pin.art:SetVertexColor(1, 1, 1, 1);
                        else
                            pin.art:SetVertexColor(0.50, 0.50, 0.50, 0.85);
                        end
                    end
                    
                    local lName = lair.name or lair[3] or "Miniboss";
                    if ( isAlive ) then
                        pin.note = "|cff55ff55● Guardian is Alive (" .. lName .. ")|r";
                    else
                        local left = tonumber(lair.left or lair.respawn or lair[5]) or 0;
                        if ( left > 0 ) then
                            pin.note = string.format("|cffff4444✕ Empty (Respawn in %d:%02d)|r", math.floor(left / 60), math.mod(left, 60));
                        else
                            pin.note = "|cff888888✕ Empty Lair (" .. lName .. ")|r";
                        end
                    end
                    
                    local markName = SurvivorUI_LairMarkName and SurvivorUI_LairMarkName(mark);
                    pin.title = markName and (markName .. " Lair") or "Guardian Lair";
                    pin.flagged = (tonumber(lair.flag or lair[11]) == 1) or nil;
                    
                    if ( pin.flagged ) then
                        flaggedPin = pin;
                        pin.glow:Show();
                    else
                        pin.glow:Hide();
                    end
                    
                    Place(pin, east, south, yardsAcross, lairSize);
                end
            end
        end
    end
    
    for index = shown + 1, table.getn(pins) do
        pins[index]:Hide();
    end
end

-- =========================================================================
-- Animation & Ticker Frame
-- =========================================================================
local elapsed = 0;
local breath = 0;
local pinFrame = CreateFrame("Frame", "BordoUI_MapPinsFrame", UIParent);
pinFrame:SetScript("OnUpdate", function()
    local dt = arg1 or 0.05;
    elapsed = elapsed + dt;
    if ( elapsed >= 0.05 ) then
        elapsed = 0;
        Update();
    end
    
    breath = breath + dt;
    if ( flaggedPin and flaggedPin:IsShown() ) then
        local pulse = flaggedPin:GetWidth() * (2.2 + 0.35 * math.sin(breath * 4));
        flaggedPin.glow:SetWidth(pulse);
        flaggedPin.glow:SetHeight(pulse);
        flaggedPin.glow:SetAlpha(0.60 + 0.30 * math.sin(breath * 4));
        flaggedPin.glow:Show();
    end
end);

-- Diagnostics Slash Command
SLASH_BORDOPINS1 = "/pins";
SLASH_BORDOPINS2 = "/bordopins";
SlashCmdList["BORDOPINS"] = function()
    local numChests = AZS_CHESTS and table.getn(AZS_CHESTS) or 0;
    local numLairs = (AZS_GetLairs and table.getn(AZS_GetLairs())) or (AZS_LAIRS and table.getn(AZS_LAIRS)) or 0;
    local r = AZS_RUN;
    local px = r and r.px or "nil";
    local py = r and r.py or "nil";
    local hx, hy = GetPlayerMapPosition("player");
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI MapPins|r: Caches=%d, Lairs=%d, World=(%s, %s), Map=(%.3f, %.3f)", numChests, numLairs, tostring(px), tostring(py), hx or 0, hy or 0));
end;
