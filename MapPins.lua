-- =========================================================================
-- AZSHelper: MapPins.lua
-- Battleground Cache Minimap & World Map Pins (Chestlight Engine)
-- Port of Chestlight 1.18 for Azeroth Survivors (WoW 1.12.1 / Lua 5.0)
-- 
-- Features:
--   - Loot bag texture (bag.tga) + soft pulsing halo glow (glow.tga)
--   - Clusters nearby chests within 10 yards into single icons with count tooltip
--   - Dynamic map calibration from AZS_LAIRS & AZS_CHESTS
--   - 100% Rock-solid Instance coordinate smoothing (Glide & Ease) for Naxxramas, SM, AQ
--     ensuring pins stay stationary on terrain without drifting or moving with player
--   - Accurate indoor/outdoor minimap yard scale detection (300 yd in Naxxramas)
--   - Violet directional edge arrow pointing towards out-of-range chests
--   - Full WorldMap support when WorldMapFrame is open
--   - Chat alerts when new chests spawn
-- =========================================================================

local MEDIA = "Interface\\AddOns\\BordoUI\\Media\\";
local BAG = MEDIA .. "bag.tga";     -- Chestlight's loot bag
local GLOW = MEDIA .. "glow.tga";   -- Soft halo in the bag's shape
local PIN_SIZE = 13;
local MERGE_YD = 10;               -- Chests closer than this share one icon
local GLOW_PERIOD = 4;              -- Seconds for one soft pulse
local GLOW_MIN, GLOW_MAX = 0.2, 0.6;
local ARROW = "Interface\\Minimap\\MinimapArrow";
local ARROW_SIZE = 25;

-- Outdoor minimap diameter in yards per zoom level (stock 1.12 values)
local OUTDOOR = { [0] = 466.6667, 400, 333.3333, 266.6667, 200, 133.3333 };
-- Indoors (instances) the minimap shows far less ground per zoom level
local INDOOR = { [0] = 300, 240, 180, 120, 80, 50 };

-- Module state table (consolidated into a single table to keep Lua 5.0 upvalues well below 32)
local M = {
    pins = {},
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
    hero = { ivl = 0.2, s = {} }
};

AZSHelper.MinimapChestPins = M.pins;
AZSHelper.WorldMapChestPins = M.worldPins;

-- Check if Minimap is square
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

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc873ffChestlight:|r |cffe6ccff" .. msg .. "|r");
end

local function DB()
    if ( type(AZSHelperDB) ~= "table" ) then AZSHelperDB = {}; end
    if ( AZSHelperDB.chestArrow == nil ) then AZSHelperDB.chestArrow = true; end
    if ( AZSHelperDB.chestChat == nil ) then AZSHelperDB.chestChat = true; end
    return AZSHelperDB;
end

-- Yards per map unit, measured from any two points the game gives with both world and
-- map coordinates (lairs and chests). World x runs north/south, world y east/west.
local function Calibrate()
    local pts = {};
    if ( type(AZS_LAIRS) == "table" ) then
        for i = 1, table.getn(AZS_LAIRS) do table.insert(pts, AZS_LAIRS[i]); end
    end
    if ( type(AZS_CHESTS) == "table" ) then
        for i = 1, table.getn(AZS_CHESTS) do table.insert(pts, AZS_CHESTS[i]); end
    end
    local bestX, bestY = 0, 0;
    local n = table.getn(pts);
    for i = 1, n do
        for j = i + 1, n do
            local a, b = pts[i], pts[j];
            if ( tonumber(a.x) and tonumber(b.x) and tonumber(a.mx) and tonumber(b.mx) ) then
                local dmx = math.abs(a.mx - b.mx);
                local dmy = math.abs(a.my - b.my);
                if ( dmx > bestX and dmx > 0.003 ) then
                    bestX = dmx;
                    M.mapW = math.abs(a.y - b.y) / dmx;
                end
                if ( dmy > bestY and dmy > 0.003 ) then
                    bestY = dmy;
                    M.mapH = math.abs(a.x - b.x) / dmy;
                end
            end
        end
    end
end

-- ---------- Directional Arrow ----------
M.arrow = CreateFrame("Frame", "AZSHelper_ChestArrow", Minimap);
M.arrow:SetWidth(ARROW_SIZE);
M.arrow:SetHeight(ARROW_SIZE);
M.arrow:SetFrameLevel(Minimap:GetFrameLevel() + 6);
M.arrowTex = M.arrow:CreateTexture(nil, "OVERLAY");
M.arrowTex:SetAllPoints(M.arrow);
M.arrowTex:SetTexture(ARROW);
M.arrowTex:SetVertexColor(0.78, 0.45, 1); -- Violet
M.arrow:EnableMouse(true);
M.arrow:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:AddLine("Nächste Schatztruhe / Cache", 0.78, 0.45, 1);
    if ( this.dist ) then
        GameTooltip:AddLine(math.floor(this.dist + 0.5) .. " yd entfernt", 1, 1, 1);
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
    M.arrowTex:SetTexCoord(ulx, uly, llx, lly, urx, ury, lrx, lry);
end

-- ---------- Minimap Pins ----------
local function NewPin(i)
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
            GameTooltip:AddLine(math.floor(this.dist + 0.5) .. " yd entfernt", 1, 1, 1);
        end
        if ( AZS_RUN and AZS_RUN.chest and tonumber(AZS_RUN.chest) > 0 ) then
            GameTooltip:AddLine(string.format("Kosten: %d Gold", tonumber(AZS_RUN.chest)), 0, 0.8, 1);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    M.pins[i] = pin;
    return pin;
end

-- ---------- World Map Pins ----------
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
            GameTooltip:AddLine(string.format("Kosten: %d Gold", tonumber(AZS_RUN.chest)), 0, 0.8, 1);
        end
        GameTooltip:Show();
    end);
    pin:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    M.worldPins[i] = pin;
    return pin;
end

local function HideAll()
    for _, pin in pairs(M.pins) do pin:Hide(); end
    for _, wpin in pairs(M.worldPins) do wpin:Hide(); end
    if ( M.arrow ) then M.arrow:Hide(); end
end

-- ---------- Instance Hero Smoothing ----------
-- Inside the Scarlet Monastery, Naxxramas and Ahn'Qiraj the game has no zone map: there the
-- hero's and the chests' positions come from the game's own addon data in yards (AZS_RUN
-- px, py and the chests' x, y), and the minimap uses its indoor scale. Outdoors nothing of
-- this is used.
-- The game's line comes only a few times a second and at an uneven pace, while the minimap
-- moves every frame: the bags are drawn a moment in the past, always between two positions
-- the game really gave, and eased. While the hero runs they trail smoothly, never jump or drift.
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
    
    -- Astrolabe detection pattern for Vanilla WoW 1.12
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

local function PlayerPos()
    local mapOpen = WorldMapFrame and WorldMapFrame:IsVisible();
    if ( not M.mapReady and not mapOpen and SetMapToCurrentZone ) then
        SetMapToCurrentZone();
        M.mapReady = true;
    end
    local px, py = GetPlayerMapPosition("player");
    if ( not px or (px == 0 and py == 0) ) then
        M.mapReady = false;
        return nil;
    end
    return px, py;
end

local function UpdateWorldMap(list)
    if ( not WorldMapFrame or not WorldMapFrame:IsShown() or not WorldMapButton ) then return; end
    local wmbW = WorldMapButton:GetWidth();
    local wmbH = WorldMapButton:GetHeight();
    local numChests = table.getn(list);
    for i = 1, numChests do
        local c = list[i];
        local wPin = M.worldPins[i] or NewWorldPin(i);
        if ( wPin and c and c.mx and c.my and c.mx >= 0 and c.my >= 0 ) then
            wPin:ClearAllPoints();
            wPin:SetPoint("CENTER", WorldMapButton, "TOPLEFT", c.mx * wmbW, -c.my * wmbH);
            wPin:Show();
        elseif ( wPin ) then
            wPin:Hide();
        end
    end
    for i = numChests + 1, table.getn(M.worldPins) do
        if ( M.worldPins[i] ) then M.worldPins[i]:Hide(); end
    end
end

local function Update()
    local list = AZS_CHESTS;
    local phase = AZS_GetPhase and AZS_GetPhase() or nil;
    if ( not phase or type(list) ~= "table" ) then
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
    
    local present = {};
    local fresh = 0;
    for i = 1, table.getn(list) do
        local id = list[i].id;
        if ( id ) then
            present[id] = list[i];
            if ( not M.known[id] ) then
                M.known[id] = true;
                if ( M.primed ) then fresh = fresh + 1; end
            end
        end
    end
    for id in pairs(M.known) do
        if ( not present[id] ) then M.known[id] = nil; end
    end
    if ( phase ~= "ready" ) then M.primed = true; end
    
    local db = DB();
    if ( fresh > 0 and db.chestChat ) then
        Print(fresh == 1 and "Eine neue Schatztruhe ist gespawnt." or (fresh .. " neue Schatztruhen sind gespawnt."));
    end
    
    -- Determine whether we are in instance / world coordinates mode (Naxxramas, SM, AQ or missing map coordinates)
    local isInstance = false;
    if ( AZS_ZONE and (AZS_ZONE.zone == "naxx" or AZS_ZONE.zone == "sm" or AZS_ZONE.zone == "aq") ) then
        isInstance = true;
    end
    if ( not isInstance ) then
        for _, c in pairs(present) do
            if ( c.mx and tonumber(c.mx) and tonumber(c.mx) < 0 ) then
                isInstance = true;
                break;
            end
        end
    end
    
    -- Where the hero stands on the zone map.
    local mpx, mpy = PlayerPos();
    local world = false;
    local wpx, wpy;
    if ( (isInstance or not mpx) and type(AZS_RUN) == "table" and tonumber(AZS_RUN.px) and tonumber(AZS_RUN.py) ) then
        world = true;
        wpx, wpy = Glide(tonumber(AZS_RUN.px), tonumber(AZS_RUN.py));
        wpx, wpy = Ease(wpx, wpy);
    end
    
    -- Group chests lying close together: one icon at their centre
    local groups = {};
    for _, c in pairs(present) do
        local cx, cy;
        if ( world or isInstance ) then
            if ( tonumber(c.x) and tonumber(c.y) ) then
                cx = -tonumber(c.y);
                cy = -tonumber(c.x);
            end
        elseif ( tonumber(c.mx) and tonumber(c.my) and tonumber(c.mx) >= 0 and tonumber(c.my) >= 0 ) then
            cx = c.mx * M.mapW;
            cy = c.my * M.mapH;
        end
        if ( cx and cy ) then
            local joined = false;
            for g = 1, table.getn(groups) do
                local gr = groups[g];
                local dx = cx - gr.x;
                local dy = cy - gr.y;
                if ( dx * dx + dy * dy <= MERGE_YD * MERGE_YD ) then
                    gr.n = gr.n + 1;
                    gr.x = gr.x + dx / gr.n;
                    gr.y = gr.y + dy / gr.n;
                    joined = true;
                    break;
                end
            end
            if ( not joined ) then
                table.insert(groups, { x = cx, y = cy, n = 1 });
            end
        end
    end
    
    for i = table.getn(groups) + 1, table.getn(M.pins) do
        if ( M.pins[i] ) then M.pins[i]:Hide(); end
    end
    
    local hx, hy;
    if ( world or isInstance ) then
        if ( not wpx or not wpy ) then
            HideAll();
            return;
        end
        hx = -wpy;
        hy = -wpx;
    elseif ( mpx and mpy ) then
        hx = mpx * M.mapW;
        hy = mpy * M.mapH;
    else
        HideAll();
        return;
    end
    
    local z = Minimap:GetZoom() or 0;
    local diameter;
    if ( world or isInstance ) then
        -- In instances (Naxxramas, SM, AQ) the minimap is ALWAYS in its indoor scale!
        diameter = INDOOR[z] or 180;
    elseif ( Indoors() ) then
        diameter = INDOOR[z] or 180;
    else
        diameter = OUTDOOR[z] or 333.3333;
    end
    
    local scale = Minimap:GetWidth() / diameter;
    local limit = Minimap:GetWidth() / 2 - PIN_SIZE / 2;
    local square = IsSquare();
    
    local inRange = false;
    local pulse = GLOW_MIN + (GLOW_MAX - GLOW_MIN) * (0.5 + 0.5 * math.sin(M.glowClock * 2 * math.pi / GLOW_PERIOD));
    local nearDist, nearX, nearY;
    
    for i = 1, table.getn(groups) do
        local gr = groups[i];
        local east = gr.x - hx;
        local north = hy - gr.y;
        local pin = M.pins[i] or NewPin(i);
        pin.count = gr.n;
        pin.dist = math.sqrt(east * east + north * north);
        local ox = east * scale;
        local oy = north * scale;
        local m;
        if ( square ) then
            m = math.max(math.abs(ox), math.abs(oy));
        else
            m = math.sqrt(ox * ox + oy * oy);
        end
        
        if ( m > limit ) then
            pin:Hide();
            if ( not nearDist or pin.dist < nearDist ) then
                nearDist = pin.dist;
                nearX = ox;
                nearY = oy;
            end
        else
            inRange = true;
            if ( pin.glow ) then pin.glow:SetAlpha(pulse); end
            pin:ClearAllPoints();
            pin:SetPoint("CENTER", Minimap, "CENTER", ox, oy);
            pin:Show();
        end
    end
    
    if ( db.chestArrow and not inRange and nearDist and M.arrow ) then
        local a = math.atan2(nearX, nearY);
        local dx = math.sin(a);
        local dy = math.cos(a);
        local edge = Minimap:GetWidth() / 2 - ARROW_SIZE / 2;
        local m = square and math.max(math.abs(dx), math.abs(dy)) or 1;
        RotateArrow(a);
        M.arrow.dist = nearDist;
        M.arrow:ClearAllPoints();
        M.arrow:SetPoint("CENTER", Minimap, "CENTER", dx / m * edge, dy / m * edge);
        M.arrow:Show();
    else
        if ( M.arrow ) then M.arrow:Hide(); end
    end
    
    UpdateWorldMap(list);
end

-- Update frame
local f = CreateFrame("Frame", "AZSHelper_ChestlightUpdateFrame", UIParent);
f:SetScript("OnUpdate", function()
    M.glowClock = M.glowClock + arg1;
    M.acc = M.acc + arg1;
    if ( M.acc < 0.03 ) then return; end
    M.acc = 0;
    Update();
end);

f:RegisterEvent("VARIABLES_LOADED");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("ZONE_CHANGED_NEW_AREA");
f:RegisterEvent("ZONE_CHANGED_INDOORS");
f:SetScript("OnEvent", function()
    if ( event == "VARIABLES_LOADED" ) then
        DB();
    elseif ( event == "ZONE_CHANGED_INDOORS" ) then
        M.indoors = nil;
    else
        M.mapReady = false;
        M.indoors = nil;
    end
end);

-- Slash commands (Chestlight compatible & AZSHelper integrated)
SLASH_AZSCHESTLIGHT1 = "/chestlight";
SLASH_AZSCHESTLIGHT2 = "/cl";
SlashCmdList["AZSCHESTLIGHT"] = function(msg)
    local db = DB();
    msg = string.lower(msg or "");
    if ( msg == "arrow" ) then
        db.chestArrow = not db.chestArrow;
        Print("Pfeil zu entfernten Kisten: " .. (db.chestArrow and "|cff55ff55an|r" or "|cffff5555aus|r"));
    elseif ( msg == "chat" ) then
        db.chestChat = not db.chestChat;
        Print("Chat-Nachricht bei Kisten-Spawn: " .. (db.chestChat and "|cff55ff55an|r" or "|cffff5555aus|r"));
    else
        Print("/cl chat - Chat-Nachricht bei neuem Kisten-Spawn (" .. (db.chestChat and "an" or "aus") .. ")");
        Print("/cl arrow - Violette Richtungspfeil-Anzeige (" .. (db.chestArrow and "an" or "aus") .. ")");
    end
end;
