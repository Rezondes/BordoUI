--[[
    Bordo UI - High-Precision Minimap Pins (MapPins.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Authentic zero-drift pin engine:
    - 1. Real-time Caches (Battleground Chests) on the Minimap with distance and edge clamping
    - 2. Guardian Lairs with dynamic heraldic marks (LairMarks) and respawn / combat status
    - 3. Zone Map Calibration & Indoor / Outdoor Zoom detection
    - 4. World Map pin projection
]]--

local ART = "Interface\\AddOns\\BordoUI\\Art\\";
local PIN_SIZE = 16;
local EDGE_SIZE = 11;

-- The yards across the minimap at each zoom level (1.12 client outdoors & indoors)
local MINIMAP_YARDS = { [0] = 466.67, [1] = 400, [2] = 333.33, [3] = 266.67, [4] = 200, [5] = 133.33 };
local INSIDE_YARDS = { [0] = 300, [1] = 240, [2] = 180, [3] = 120, [4] = 80, [5] = 50 };

local function Enabled()
    return true;
end

local function Playing()
    if not (AZS_GetPhase and AZS_CHESTS) then
        return false;
    end
    local phase = AZS_GetPhase();
    return phase == "playing" or phase == "choosing" or phase == "paused";
end

-- A map coordinate as a share of the map, 0 to 1
local function Share(value)
    value = tonumber(value);
    if not value or value < 0 then
        return nil;
    end
    if value > 1.5 then
        return value / 100;
    end
    return value;
end

------------------------------------------------------------------------------
-- Yard Span & Map Calibration per Zone
------------------------------------------------------------------------------
local spans = {}; -- [zone name] = { across, down }

local function Places()
    local list = {};
    for index = 1, table.getn(AZS_CHESTS or {}) do
        table.insert(list, AZS_CHESTS[index]);
    end
    if AZS_GetLairs then
        local lairs = AZS_GetLairs();
        for index = 1, table.getn(lairs or {}) do
            table.insert(list, lairs[index]);
        end
    end
    return list;
end

local NEAREST = 0.004;

local function Span()
    local zone = (AZS_ZONE and AZS_ZONE.zname) or GetZoneText() or "?";
    local known = spans[zone] or { baseAcross = 0, baseDown = 0 };
    local places = Places();
    for a = 1, table.getn(places) do
        for b = a + 1, table.getn(places) do
            local p, q = places[a], places[b];
            local pmx, qmx, pmy, qmy = Share(p.mx), Share(q.mx), Share(p.my), Share(q.my);
            local px, qx, py, qy = tonumber(p.x), tonumber(q.x), tonumber(p.y), tonumber(q.y);
            if pmx and qmx and pmy and qmy and px and qx and py and qy then
                local dmx, dmy = math.abs(pmx - qmx), math.abs(pmy - qmy);
                if dmx > known.baseAcross and dmx > NEAREST then
                    known.baseAcross = dmx;
                    known.foundAcross = math.abs(py - qy) / dmx;
                end
                if dmy > known.baseDown and dmy > NEAREST then
                    known.baseDown = dmy;
                    known.foundDown = math.abs(px - qx) / dmy;
                end
            end
        end
    end
    known.across = known.foundAcross or (known.foundDown and known.foundDown * 3 / 2);
    known.down = known.foundDown or (known.foundAcross and known.foundAcross * 2 / 3);
    spans[zone] = known;
    if known.across and known.down then
        return known;
    end
end

------------------------------------------------------------------------------
-- Minimap Pin Frames
------------------------------------------------------------------------------
local pins = {};

local function Pin(index)
    local pin = pins[index];
    if pin then
        return pin;
    end
    pin = CreateFrame("Frame", "BordoUI_MinimapPin" .. index, Minimap);
    pin:SetFrameLevel(Minimap:GetFrameLevel() + 4);
    pin.art = pin:CreateTexture(nil, "OVERLAY");
    pin.art:SetAllPoints(pin);

    pin.glow = pin:CreateTexture(nil, "ARTWORK");
    pin.glow:SetTexture(ART .. "PaceGlow");
    pin.glow:SetBlendMode("ADD");
    pin.glow:SetVertexColor(1, 0.82, 0.2);
    pin.glow:SetPoint("CENTER", pin, "CENTER", 0, 0);
    pin.glow:Hide();

    pin:EnableMouse(true);
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        GameTooltip:SetText(this.title or "", 1, 0.82, 0);
        if this.note then
            GameTooltip:AddLine(this.note, 0.8, 0.8, 0.8);
        end
        if this.flagged then
            GameTooltip:AddLine("The game's flag points here.", 1, 0.82, 0.2);
        end
        if this.yards then
            GameTooltip:AddLine(math.floor(this.yards + 0.5) .. " yards away", 0.6, 0.6, 0.6);
        end
        if this.cost and this.cost > 0 then
            GameTooltip:AddLine(string.format("Cost: %d Gold", this.cost), 0.2, 0.8, 1.0);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);

    pins[index] = pin;
    return pin;
end

-- Hero's position on the map
local function HeroPlace()
    if not GetPlayerMapPosition then
        return nil;
    end
    local x, y = GetPlayerMapPosition("player");
    if (not x or (x == 0 and y == 0)) and SetMapToCurrentZone then
        SetMapToCurrentZone();
        x, y = GetPlayerMapPosition("player");
    end
    if not x or (x == 0 and y == 0) then
        return nil;
    end
    return x, y;
end

-- Hero's position in world yards (AZS_RUN)
local function HeroWorld()
    local run = AZS_RUN;
    if not run then
        return nil;
    end
    local px, py = tonumber(run.px), tonumber(run.py);
    if not (px and py) then
        return nil;
    end
    local facing = tonumber(run.pf);
    if facing then
        facing = -facing;
    end
    return px, py, facing;
end

-- World displacement in yards: east and south
local function WorldWay(px, py, x, y)
    return py - y, px - x;
end

-- Exports for other modules
SurvivorUI_HeroPlace = HeroPlace;
SurvivorUI_MapSpan = Span;
SurvivorUI_MapShare = Share;
SurvivorUI_HeroWorld = HeroWorld;
SurvivorUI_WorldWay = WorldWay;

BordoUI_HeroPlace = HeroPlace;
BordoUI_HeroWorld = HeroWorld;
BordoUI_WorldWay = WorldWay;

------------------------------------------------------------------------------
-- Indoor vs Outdoor Zoom Tracking
------------------------------------------------------------------------------
local function Setting(name)
    local ok, value = pcall(GetCVar, name);
    return ok and value or nil;
end

local probed;
local probing = false;

local function Probe()
    local zoom = Minimap:GetZoom();
    local outside, inside = tonumber(Setting("minimapZoom")), tonumber(Setting("minimapInsideZoom"));
    if not (zoom and outside and inside) or outside ~= inside then
        return;
    end
    probing = true;
    local step = zoom > 0 and -1 or 1;
    Minimap:SetZoom(zoom + step);
    local nowOutside, nowInside = tonumber(Setting("minimapZoom")), tonumber(Setting("minimapInsideZoom"));
    Minimap:SetZoom(zoom);
    probing = false;
    if nowInside ~= inside then
        probed = true;
    elseif nowOutside ~= outside then
        probed = false;
    else
        probed = nil;
    end
end

local function Indoors()
    local zoom = Minimap:GetZoom();
    local outside, inside = tonumber(Setting("minimapZoom")), tonumber(Setting("minimapInsideZoom"));
    if zoom and outside and inside and outside ~= inside then
        return zoom == inside;
    end
    if probed ~= nil then
        return probed;
    end
    return not HeroPlace();
end

local prober = CreateFrame("Frame");
prober:RegisterEvent("PLAYER_ENTERING_WORLD");
prober:RegisterEvent("ZONE_CHANGED");
prober:RegisterEvent("ZONE_CHANGED_INDOORS");
prober:RegisterEvent("ZONE_CHANGED_NEW_AREA");
prober:RegisterEvent("MINIMAP_UPDATE_ZOOM");
prober:SetScript("OnEvent", function()
    if not probing then
        Probe();
    end
end);

local function Settings()
    BordoUIDB = BordoUIDB or {};
    return BordoUIDB;
end

function SurvivorUI_PinSize(kind)
    local size = tonumber(Settings()[kind == "cache" and "pinCacheSize" or "pinLairSize"]);
    return size and math.max(10, math.min(28, size)) or PIN_SIZE;
end

function SurvivorUI_SetPinSize(kind, size)
    Settings()[kind == "cache" and "pinCacheSize" or "pinLairSize"] = size ~= PIN_SIZE and size or nil;
end

------------------------------------------------------------------------------
-- Flag Choice & HUD Flag Handling
------------------------------------------------------------------------------
local function FlagChoice()
    return Settings().gameFlag or "ours";
end

local function ApplyGameFlag()
    if not (AZS_SetHudShown and AZS_IsHudShown and AZS_GetFlaggedLair) then
        return;
    end
    local settings = Settings();
    local away;
    if Enabled() then
        away = FlagChoice() ~= "game";
    else
        away = settings.noGameFlag;
    end
    if away then
        if AZS_IsHudShown("flag") then
            AZS_SetHudShown("flag", false);
            settings.hidGameFlag = true;
        end
    elseif settings.hidGameFlag then
        AZS_SetHudShown("flag", true);
        settings.hidGameFlag = nil;
    end
end

function SurvivorUI_GameFlag()
    return AZS_GetFlaggedLair and FlagChoice() or nil;
end

function SurvivorUI_SetGameFlag(choice)
    Settings().gameFlag = choice ~= "ours" and choice or nil;
    ApplyGameFlag();
end

local flagLoader = CreateFrame("Frame");
flagLoader:RegisterEvent("PLAYER_ENTERING_WORLD");
flagLoader:SetScript("OnEvent", ApplyGameFlag);

SurvivorUI_GameHud = SurvivorUI_GameHud or {};
SurvivorUI_GameHud.flag = ApplyGameFlag;

local flaggedPin;

local function MinimapYards()
    local zoom = Minimap:GetZoom() or 0;
    local yards = Indoors() and INSIDE_YARDS or MINIMAP_YARDS;
    return yards[zoom] or yards[0], zoom;
end

-- Position Pin with edge clamping on the Minimap
local function Place(pin, east, south, yardsAcross, size)
    local half = Minimap:GetWidth() / 2;
    local perYard = (2 * half) / yardsAcross;
    pin.yards = math.sqrt(east * east + south * south);
    local px, py = east * perYard, -south * perYard;
    local edge = math.floor(size * EDGE_SIZE / PIN_SIZE + 0.5);
    local reach = math.max(math.abs(px), math.abs(py));
    local limit = half - edge / 2;
    if reach > limit then
        if Settings().pinEdge == "hide" then
            pin:Hide();
            return;
        end
        px, py = px * limit / reach, py * limit / reach;
        size = edge;
        pin:SetAlpha(0.7);
    else
        pin:SetAlpha(1.0);
    end
    pin:SetWidth(size);
    pin:SetHeight(size);
    pin:ClearAllPoints();
    pin:SetPoint("CENTER", Minimap, "CENTER", px, py);
    pin:Show();
end

local function WayTo(place, px, py, heroX, heroY, span)
    local x, y = tonumber(place.x), tonumber(place.y);
    if px and x and y then
        return WorldWay(px, py, x, y);
    end
    local mx, my = Share(place.mx), Share(place.my);
    if heroX and span and mx and my then
        return (mx - heroX) * span.across, (my - heroY) * span.down;
    end
end

local pinsWere;

------------------------------------------------------------------------------
-- Main Map Pins Update Loop (10 FPS)
------------------------------------------------------------------------------
local function Update()
    local shown = 0;
    flaggedPin = nil;

    if Enabled() ~= pinsWere then
        pinsWere = Enabled();
        ApplyGameFlag();
    end

    if Enabled() and Playing() then
        local px, py = HeroWorld();
        local heroX, heroY, span;
        if not px then
            heroX, heroY = HeroPlace();
            span = heroX and Span();
        end

        if px or span then
            local settings = Settings();
            local yardsAcross = MinimapYards();

            -- 1. Caches / Chests on the Minimap
            local chests = settings.pinCaches ~= false and AZS_CHESTS or {};
            local cacheSize = SurvivorUI_PinSize("cache");
            local cost = (AZS_RUN and AZS_RUN.chest and tonumber(AZS_RUN.chest)) or nil;

            for index = 1, table.getn(chests) do
                local chest = chests[index];
                local east, south = WayTo(chest, px, py, heroX, heroY, span);
                if east then
                    shown = shown + 1;
                    local pin = Pin(shown);
                    pin.art:SetTexture(ART .. "PinCache");
                    pin.art:SetTexCoord(0, 1, 0, 1);
                    pin.art:SetVertexColor(1, 1, 1);
                    pin.glow:Hide();
                    pin.title = "Battleground Cache";
                    pin.note = nil;
                    pin.flagged = nil;
                    pin.cost = cost;
                    Place(pin, east, south, yardsAcross, cacheSize);
                end
            end

            -- 2. Guardian Lairs on the Minimap
            local lairs = settings.pinLairs ~= false and AZS_GetLairs and AZS_GetLairs() or {};
            local marks = SurvivorUI_LairMarks and SurvivorUI_LairMarks(lairs) or {};
            local lairSize = SurvivorUI_PinSize("lair");

            for index = 1, table.getn(lairs) do
                local lair = lairs[index];
                local east, south = WayTo(lair, px, py, heroX, heroY, span);
                local st = lair.state or lair[2];
                local isActive = (st ~= "empty" and (lair.active == nil or lair.active == true or lair.active == 1));

                if east and (isActive or settings.pinEmpty ~= "hide") then
                    shown = shown + 1;
                    local pin = Pin(shown);
                    local mark = marks[tonumber(lair.index or lair[1]) or index];

                    if mark and SurvivorUI_SetLairMark then
                        SurvivorUI_SetLairMark(pin.art, mark, not isActive);
                    else
                        pin.art:SetTexture(ART .. "PinLair");
                        pin.art:SetTexCoord(0, 1, 0, 1);
                        if isActive then
                            pin.art:SetVertexColor(1, 1, 1);
                        else
                            pin.art:SetVertexColor(0.45, 0.45, 0.45);
                        end
                    end

                    local lName = lair.name or lair[3];
                    if isActive then
                        pin.note = "Guardian's Lair: " .. (lName and lName ~= "" and lName or "Guardian Alive");
                    else
                        pin.note = "Empty Lair";
                    end

                    local markName = SurvivorUI_LairMarkName and SurvivorUI_LairMarkName(mark);
                    pin.title = markName and (markName .. " Lair") or "Guardian Lair";
                    pin.cost = nil;
                    pin.flagged = (tonumber(lair.flag or lair[11]) == 1) or nil;

                    if pin.flagged and FlagChoice() == "ours" then
                        flaggedPin = pin;
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

local elapsed = 0;
local breath = 0;
local watcher = CreateFrame("Frame");
watcher:SetScript("OnUpdate", function()
    elapsed = elapsed + arg1;
    if elapsed >= 0.1 then
        elapsed = 0;
        Update();
    end
    breath = breath + arg1;
    if flaggedPin and flaggedPin:IsShown() then
        local size = flaggedPin:GetWidth() * (2.4 + 0.35 * math.sin(breath * 4));
        flaggedPin.glow:SetWidth(size);
        flaggedPin.glow:SetHeight(size);
        flaggedPin.glow:SetAlpha(0.6 + 0.3 * math.sin(breath * 4));
        flaggedPin.glow:Show();
    end
end);

-- Compass / Distance report helper
local function Nearest(list, px, py)
    local best, bestEast, bestSouth;
    for index = 1, table.getn(list) do
        local x, y = tonumber(list[index].x), tonumber(list[index].y);
        if x and y then
            local east, south = WorldWay(px, py, x, y);
            local yards = math.sqrt(east * east + south * south);
            if not best or yards < best then
                best, bestEast, bestSouth = yards, east, south;
            end
        end
    end
    return best, bestEast, bestSouth;
end

local COMPASS = { "north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west" };

local function Compass(east, south)
    local bearing = math.atan2(east, -south) * 180 / math.pi;
    return COMPASS[math.mod(math.floor((bearing + 22.5) / 45) + 8, 8) + 1];
end

function SurvivorUI_PinsReport()
    local say = function(text) DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r " .. text); end
    say("zone: " .. tostring(AZS_ZONE and AZS_ZONE.zone) .. " (map " .. tostring(AZS_ZONE and AZS_ZONE.map)
        .. "); real: " .. tostring(GetRealZoneText and GetRealZoneText()));
    local chests = AZS_CHESTS or {};
    local lairs = AZS_GetLairs and AZS_GetLairs() or {};
    say("caches: " .. table.getn(chests) .. ", lairs: " .. table.getn(lairs));
    local px, py, facing = HeroWorld();
    if px then
        local degrees = facing and math.mod(math.floor(facing * 180 / math.pi + 0.5) + 720, 360);
        say(string.format("hero world: x %.1f, y %.1f; facing %s", px, py,
            degrees and (degrees .. " deg") or "not sent"));
        local yards, east, south = Nearest(chests, px, py);
        if yards then
            say(string.format("nearest cache: %d yards %s", math.floor(yards + 0.5), Compass(east, south)));
        end
        yards, east, south = Nearest(lairs, px, py);
        if yards then
            say(string.format("nearest lair: %d yards %s", math.floor(yards + 0.5), Compass(east, south)));
        end
    else
        say("hero world position: not sent");
    end
end
BordoUI_PinsReport = SurvivorUI_PinsReport;
