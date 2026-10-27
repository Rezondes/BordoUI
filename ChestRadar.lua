--[[
    Bordo UI 2.0 - Chest Radar & Proximity Arrow (ChestRadar.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - On-screen rotational compass arrow pointing directly towards the nearest unopened battleground chest/cache
    - Real-time yard distance display ("Chest: 38 yd", "Open Chest!")
    - Auto-hides when no chests are in proximity (> 140 yd)
    - Uses high-performance 64-angle GuardianArrow sprite sheet
    - Movable with /unlock (Alt-drag or Move Mode)
    - Toggle with /bordo chestradar, test with /bordo testchest
]]--

BordoUI = BordoUI or {};
AZSHelper = AZSHelper or {};

local ART = "Interface\\AddOns\\BordoUI\\Art\\";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local CELLS = 8;
local ARROW_SIZE = 26;

-- Rotational sprite sheet helper (64 angles)
local function PointRadarArrow(texture, angle)
    local cell = math.floor(math.mod(-angle / (2 * math.pi) * (CELLS * CELLS), CELLS * CELLS) + 0.5);
    if cell < 0 then cell = cell + CELLS * CELLS; end
    local row = math.floor(cell / CELLS);
    local col = math.mod(cell, CELLS);
    local s = 1 / CELLS;
    texture:SetTexCoord(col * s, (col + 1) * s, row * s, (row + 1) * s);
end

-- Create Radar Frame
local radarFrame = CreateFrame("Frame", "BordoUI_ChestRadarFrame", UIParent);
radarFrame:SetWidth(80);
radarFrame:SetHeight(50);
radarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 75);
radarFrame:SetMovable(true);
radarFrame:EnableMouse(true);
radarFrame:RegisterForDrag("LeftButton");

radarFrame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        radarFrame:StartMoving();
    end
end);
radarFrame:SetScript("OnDragStop", function()
    radarFrame:StopMovingOrSizing();
    local pt, _, relPt, x, y = radarFrame:GetPoint();
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.chestRadarPos = { point = pt, relativePoint = relPt, x = x, y = y };
end);

-- Shadow Texture
local arrowShadow = radarFrame:CreateTexture(nil, "BACKGROUND");
arrowShadow:SetTexture(ART .. "GuardianArrow.tga");
arrowShadow:SetWidth(ARROW_SIZE);
arrowShadow:SetHeight(ARROW_SIZE);
arrowShadow:SetPoint("CENTER", radarFrame, "CENTER", 1, -1);
arrowShadow:SetVertexColor(0, 0, 0, 0.7);
radarFrame.shadow = arrowShadow;

-- Golden Arrow Texture
local arrow = radarFrame:CreateTexture(nil, "OVERLAY");
arrow:SetTexture(ART .. "GuardianArrow.tga");
arrow:SetWidth(ARROW_SIZE);
arrow:SetHeight(ARROW_SIZE);
arrow:SetPoint("CENTER", radarFrame, "CENTER", 0, 0);
arrow:SetVertexColor(1.00, 0.85, 0.20, 1.0); -- Bright Gold
radarFrame.arrow = arrow;

-- Distance / Action Text
local distText = radarFrame:CreateFontString(nil, "OVERLAY");
distText:SetFont(FONT_PATH, 10, "OUTLINE");
distText:SetPoint("TOP", arrow, "BOTTOM", 0, -2);
distText:SetTextColor(1.0, 0.85, 0.20);
distText:SetText("");
radarFrame.distText = distText;

radarFrame:Hide();

local testUntil = 0;

-- Live Scanner Ticker (Runs 10 times per second)
local radarTicker = CreateFrame("Frame", "BordoUI_ChestRadarTicker");
local elapsed = 0;

radarTicker:SetScript("OnUpdate", function()
    local dt = arg1 or 0.1;
    elapsed = elapsed + dt;
    if ( elapsed < 0.08 ) then return; end
    elapsed = 0;
    
    local now = GetTime();
    BordoUIDB = BordoUIDB or {};
    if ( BordoUIDB.chestRadar == false and now >= testUntil ) then
        if ( radarFrame:IsShown() ) then radarFrame:Hide(); end
        return;
    end
    
    -- Test Simulation Mode
    if ( now < testUntil ) then
        local simulatedAngle = math.mod(now * 1.5, 2 * math.pi);
        PointRadarArrow(arrow, simulatedAngle);
        PointRadarArrow(arrowShadow, simulatedAngle);
        distText:SetText("Chest: 42 yd");
        distText:SetTextColor(1.0, 0.85, 0.20);
        arrow:SetVertexColor(1.0, 0.85, 0.20);
        radarFrame:Show();
        return;
    end
    
    -- Real Chest Distance & Angle Scan
    local chests = AZS_CHESTS or {};
    local numChests = table.getn(chests);
    if ( numChests <= 0 ) then
        if ( radarFrame:IsShown() ) then radarFrame:Hide(); end
        return;
    end
    
    -- Player coordinates
    local px, py = GetPlayerMapPosition("player");
    if ( not px or (px == 0 and py == 0) ) then
        if ( radarFrame:IsShown() ) then radarFrame:Hide(); end
        return;
    end
    
    local facing = (GetPlayerFacing and GetPlayerFacing()) or 0;
    
    -- Find nearest chest
    local nearestDist = 999999;
    local bestRelAngle = 0;
    
    for i = 1, numChests do
        local c = chests[i];
        if ( c ) then
            local cx = tonumber(c.x or (c[1] and c[1]) or 0);
            local cy = tonumber(c.y or (c[2] and c[2]) or 0);
            local cmx = tonumber(c.mx or 0);
            local cmy = tonumber(c.my or 0);
            
            -- If map coords available, compute delta in map units
            local dx = 0;
            local dy = 0;
            if ( cmx > 0 and cmy > 0 ) then
                dx = (cmx - px);
                dy = (cmy - py);
            else
                dx = (cx - px);
                dy = (cy - py);
            end
            
            -- Approximate yard distance based on game zone scale (~1000 yd per map span)
            local distYards = math.sqrt(dx * dx + dy * dy) * 1200;
            
            if ( distYards < nearestDist ) then
                nearestDist = distYards;
                -- World angle: WoW 0 is North, clockwise or counter-clockwise
                local worldAngle = math.atan2(dx, dy);
                bestRelAngle = worldAngle - facing;
            end
        end
    end
    
    -- Display if within 140 yards
    if ( nearestDist <= 140 ) then
        PointRadarArrow(arrow, bestRelAngle);
        PointRadarArrow(arrowShadow, bestRelAngle);
        
        if ( nearestDist <= 6 ) then
            distText:SetText("Open Chest!");
            distText:SetTextColor(0.20, 1.00, 0.30);
            arrow:SetVertexColor(0.20, 1.00, 0.30);
        else
            distText:SetText(string.format("Chest: %d yd", math.floor(nearestDist + 0.5)));
            distText:SetTextColor(1.00, 0.85, 0.20);
            arrow:SetVertexColor(1.00, 0.85, 0.20);
        end
        radarFrame:Show();
    else
        if ( radarFrame:IsShown() ) then radarFrame:Hide(); end
    end
end);

-- Toggle Setting
function BordoUI:ToggleChestRadar()
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.chestRadar = (BordoUIDB.chestRadar == false);
    local state = BordoUIDB.chestRadar and "|cff55ff55Enabled|r" or "|cffff4444Disabled|r";
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Chest Proximity Radar Arrow is now " .. state);
end

-- Live Test Simulation
function BordoUI:TestChestRadar()
    testUntil = GetTime() + 8.0;
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Simulating nearest chest arrow (42 yd) for 8 seconds...");
end
