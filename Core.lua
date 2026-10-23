--[[
    Bordo UI - Core (Core.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Modern UI Suite by Bordo
]]--

BordoUI = {};
AZSHelper = BordoUI; -- Vollständiger Rückwärtskompatibilitäts-Alias
BordoUI.version = "2.0.0";

-- Default Settings
local defaults = {
    dmgScale   = 0.75,
    tableScale = 0.80,
    collapsed  = false,
    statsPos   = { point = "LEFT", relativePoint = "LEFT", x = 20, y = 0 },
    centerHudPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 200 },
    deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 },
    encounterBarsPos = { point = "TOP", relativePoint = "TOP", x = 0, y = -55 },
    chestArrow = true,
    chestChat  = true,
};

local function InitDB()
    if ( not BordoUIDB ) then
        BordoUIDB = AZSHelperDB or {};
    end
    AZSHelperDB = BordoUIDB;
    for k, v in pairs(defaults) do
        if ( BordoUIDB[k] == nil ) then
            BordoUIDB[k] = v;
        end
    end
    -- Migrate old positions to under-character HUD & non-overlapping Death Recap
    if ( not BordoUIDB.centerHudPos or (BordoUIDB.centerHudPos.y and BordoUIDB.centerHudPos.y < 100) ) then
        BordoUIDB.centerHudPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 200 };
    end
    if ( not BordoUIDB.deathRecapPos or (BordoUIDB.deathRecapPos.x and BordoUIDB.deathRecapPos.x > -250) ) then
        BordoUIDB.deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 };
    end
end

-- Formatting Utilities
function BordoUI:FormatNumber(n)
    if ( not n ) then return "0"; end
    n = math.floor(n);
    if ( n >= 1000000 ) then
        return string.format("%.1fM", n / 1000000);
    elseif ( n >= 10000 ) then
        return string.format("%.1fk", n / 1000);
    elseif ( n >= 1000 ) then
        local thousands = math.floor(n / 1000);
        local remainder = math.mod(n, 1000);
        return string.format("%d,%03d", thousands, remainder);
    else
        return tostring(n);
    end
end

function BordoUI:FormatTime(sec)
    if ( not sec or sec < 0 ) then return "0:00"; end
    local m = math.floor(sec / 60);
    local s = math.floor(math.mod(sec, 60));
    return string.format("%d:%02d", m, s);
end

function BordoUI:ApplyMaxCameraDistance()
    pcall(SetCVar, "cameraDistanceMax", "50");
    pcall(SetCVar, "cameraDistanceMaxFactor", "3.4");
    pcall(SetCVar, "cameraDistanceMaxFactor", "4");
end

-- Frame Movement Utility
function BordoUI:MakeMovable(frame, saveKey)
    frame:SetMovable(true);
    frame:EnableMouse(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", function()
        this:StartMoving();
    end);
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing();
        if ( saveKey and BordoUIDB ) then
            local point, _, relPoint, x, y = this:GetPoint();
            BordoUIDB[saveKey] = { point = point, relativePoint = relPoint, x = x, y = y };
        end
    end);
end

function BordoUI:RestorePosition(frame, posData)
    if ( frame and posData and posData.point ) then
        frame:ClearAllPoints();
        frame:SetPoint(posData.point, UIParent, posData.relativePoint or posData.point, posData.x or 0, posData.y or 0);
    end
end

-- Event Listener Frame
local eventFrame = CreateFrame("Frame", "BordoUI_CoreEventFrame");
eventFrame:RegisterEvent("VARIABLES_LOADED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

eventFrame:SetScript("OnEvent", function()
    if ( event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" ) then
        InitDB();
        if ( event == "PLAYER_ENTERING_WORLD" ) then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r geladen (Moderne UI Suite, Miniboss-Timer, Kisten-Radar & Boss-Highlight). Tippe |cffffd100/bordo|r oder |cffffd100/azs|r.");
            BordoUI:ApplyMaxCameraDistance();
            if ( BordoUI.ApplyModernDamageText ) then
                BordoUI:ApplyModernDamageText();
            end
            if ( BordoUI.ApplySquareMinimapStyle ) then
                BordoUI:ApplySquareMinimapStyle();
            end
        end
    end
end);

-- Slash Commands
SLASH_BORDOU1 = "/bordo";
SLASH_BORDOU2 = "/bordoui";
SLASH_BORDOU3 = "/bu";
SLASH_BORDOU4 = "/azs";
SLASH_BORDOU5 = "/survivor";
SlashCmdList["BORDOU"] = function(msg)
    msg = string.lower(msg or "");
    local _, _, cmd, val = string.find(msg, "^(%a+)%s*(.*)$");
    
    if ( cmd == "scale" or cmd == "dmg" ) then
        local num = tonumber(val);
        if ( num and num >= 0.4 and num <= 1.5 ) then
            BordoUIDB.dmgScale = num;
            if ( BordoUI.ApplyModernDamageText ) then
                BordoUI:ApplyModernDamageText();
            end
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Schadenszahlen-Skalierung auf %.0f%% gesetzt.", num * 100));
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Nutzung: /bordo dmg 0.75 (Wert zwischen 0.4 und 1.5)");
        end
    elseif ( cmd == "size" or cmd == "table" ) then
        local num = tonumber(val);
        if ( num and num >= 0.4 and num <= 1.5 ) then
            if ( BordoUI.SetTableScale ) then
                BordoUI:SetTableScale(num);
            end
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Statistik-Tabellengröße auf %.0f%% gesetzt.", num * 100));
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Nutzung: /bordo size 0.75 (Wert zwischen 0.4 und 1.5)");
        end
    elseif ( cmd == "death" or cmd == "recap" or cmd == "tod" ) then
        if ( BordoUI.ShowDeathRecap ) then
            BordoUI:ShowDeathRecap();
        end
    elseif ( cmd == "boss" or cmd == "timer" ) then
        if ( AZSHelper_BossSchedulePanel ) then
            if ( AZSHelper_BossSchedulePanel:IsShown() ) then
                AZSHelper_BossSchedulePanel:Hide();
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss-Timer Liste ausgeblendet.");
            else
                AZSHelper_BossSchedulePanel:Show();
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss-Timer Liste eingeblendet.");
            end
        end
    elseif ( cmd == "test" or cmd == "preview" ) then
        BordoUI.TestBossPreview = not BordoUI.TestBossPreview;
        local st = BordoUI.TestBossPreview and "aktiviert (Hogger Test-Boss)" or "deaktiviert";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss-HP Vorschau " .. st .. ".");
    elseif ( cmd == "zoom" or cmd == "cam" or cmd == "camera" ) then
        BordoUI:ApplyMaxCameraDistance();
        local yards = tonumber(val) or 35;
        pcall(CameraZoomOut, yards);
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Maximaler Kamera-Zoom freigeschaltet (Faktor 4 / 50 Yards). Rausgezoomt um %d Yards. Du kannst mit dem Mausrad jetzt viel weiter rauszoomen!", yards));
    elseif ( cmd == "reset" ) then
        BordoUIDB.statsPos = { point = "LEFT", relativePoint = "LEFT", x = 20, y = 0 };
        BordoUIDB.centerHudPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 200 };
        BordoUIDB.deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 };
        BordoUIDB.encounterBarsPos = { point = "TOP", relativePoint = "TOP", x = 0, y = -55 };
        if ( AZSHelper_StatsTableFrame ) then
            BordoUI:RestorePosition(AZSHelper_StatsTableFrame, BordoUIDB.statsPos);
        end
        if ( AZSHelper_SkillsContainer ) then
            BordoUI:RestorePosition(AZSHelper_SkillsContainer, BordoUIDB.centerHudPos);
        end
        if ( AZSHelper_DeathRecapFrame ) then
            BordoUI:RestorePosition(AZSHelper_DeathRecapFrame, BordoUIDB.deathRecapPos);
        end
        if ( AZSHelper_BossEncounterContainer ) then
            BordoUI:RestorePosition(AZSHelper_BossEncounterContainer, BordoUIDB.encounterBarsPos);
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: UI-Positionen auf Standard zurückgesetzt.");
    elseif ( cmd == "chest" or cmd == "chests" or cmd == "cl" or cmd == "kiste" or cmd == "kisten" ) then
        if ( SlashCmdList["AZSCHESTLIGHT"] ) then
            SlashCmdList["AZSCHESTLIGHT"](val);
        end
    else
        -- Toggle Stats Table
        if ( AZSHelper_StatsTableFrame ) then
            if ( AZSHelper_StatsTableFrame:IsShown() ) then
                AZSHelper_StatsTableFrame:Hide();
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Statistik-Tabelle ausgeblendet.");
            else
                AZSHelper_StatsTableFrame:Show();
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Statistik-Tabelle eingeblendet.");
            end
        end
    end
end;
