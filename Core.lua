--[[
    Bordo UI - Core (Core.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Modern UI Suite by Bordo (Survivor UI + Death Recap + Green Teammate Nameplates)
]]--

BordoUI = BordoUI or {};
AZSHelper = BordoUI; -- Backwards compatibility alias
BordoUI.version = "3.0.0";

-- Default Settings
local defaults = {
    locked        = false,
    deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 },
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
function BordoUI:MakeMovable(frame, saveKey, callback)
    if ( not frame ) then return; end
    frame:SetMovable(true);
    frame:EnableMouse(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", function()
        if ( BordoUIDB and BordoUIDB.locked ) then return; end
        this:StartMoving();
    end);
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing();
        if ( saveKey and BordoUIDB ) then
            local point, _, relPoint, x, y = this:GetPoint();
            BordoUIDB[saveKey] = { point = point, relativePoint = relPoint, x = x, y = y };
        end
        if ( callback ) then
            callback(this);
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
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r v3.0 loaded (Survivor UI + Death Recap + Green Teammate Nameplates). Type |cffffd100/bordo|r or |cffffd100/sui|r.");
            BordoUI:ApplyMaxCameraDistance();
        end
    end
end);

-- Slash Commands
SLASH_BORDOU1 = "/bordo";
SLASH_BORDOU2 = "/bordoui";
SLASH_BORDOU3 = "/bu";
SLASH_BORDOU4 = "/azs";
SlashCmdList["BORDOU"] = function(msg)
    msg = string.lower(msg or "");
    local _, _, cmd, val = string.find(msg, "^(%a+)%s*(.*)$");
    
    if ( cmd == "death" or cmd == "recap" or cmd == "tod" or cmd == "" ) then
        if ( BordoUI.ShowDeathRecap ) then
            BordoUI:ShowDeathRecap();
        end
    elseif ( cmd == "zoom" or cmd == "cam" or cmd == "camera" ) then
        BordoUI:ApplyMaxCameraDistance();
        local yards = tonumber(val) or 35;
        pcall(CameraZoomOut, yards);
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Max camera zoom unlocked (factor 4 / 50 yards). Zoomed out by %d yards. You can now zoom out further using your mouse wheel!", yards));
    elseif ( cmd == "plates" or cmd == "nameplates" or cmd == "teammates" ) then
        if ( BordoUI.EnsureNameplates ) then
            BordoUI:EnsureNameplates();
        else
            if ( ShowFriendNameplates ) then pcall(ShowFriendNameplates); end
            if ( ShowNameplates ) then pcall(ShowNameplates); end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Teammate & enemy nameplates enabled (Friendly vibrant green / Enemy red)!");
    elseif ( cmd == "opt" or cmd == "options" or cmd == "config" ) then
        if ( SlashCmdList["SURVIVORUI"] ) then
            SlashCmdList["SURVIVORUI"]("opt");
        end
    elseif ( cmd == "reset" ) then
        BordoUIDB.deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 };
        if ( AZSHelper_DeathRecapFrame ) then
            BordoUI:RestorePosition(AZSHelper_DeathRecapFrame, BordoUIDB.deathRecapPos);
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Death Recap position reset to default.");
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI Commands:|r");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo|r or |cffffd100/recap|r - Toggle Death Recap & Lethal Hits Window");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo plates|r or |cffffd100/plates|r - Toggle Teammate (vibrant green) & Enemy nameplates");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo zoom [yards]|r - Unlock & set max camera distance (50 yards)");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo opt|r or |cffffd100/sui opt|r - Open Survivor UI Settings Panel");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo reset|r - Reset Death Recap position");
    end
end;

SLASH_BORDORECAP1 = "/recap";
SLASH_BORDORECAP2 = "/death";
SlashCmdList["BORDORECAP"] = function()
    if ( BordoUI.ShowDeathRecap ) then
        BordoUI:ShowDeathRecap();
    end
end;

SLASH_BORDOPLATES1 = "/plates";
SlashCmdList["BORDOPLATES"] = function()
    if ( BordoUI.EnsureNameplates ) then
        BordoUI:EnsureNameplates();
    else
        if ( ShowFriendNameplates ) then pcall(ShowFriendNameplates); end
        if ( ShowNameplates ) then pcall(ShowNameplates); end
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Teammate & enemy nameplates enabled (Friendly vibrant green / Enemy red)!");
end;
