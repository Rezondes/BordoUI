--[[
    Bordo UI - Core (Core.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Modern UI Suite by Bordo (Survivor UI + Death Recap + Green Teammate Nameplates)
]]--

BordoUI = BordoUI or {};
AZSHelper = BordoUI; -- Backwards compatibility alias
BordoUI.version = "3.1.0";

-- Default Settings
local defaults = {
    locked        = false,
    deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 },
    goldPos       = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 185 },
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
    if ( not BordoUIDB.goldPos ) then
        BordoUIDB.goldPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 185 };
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

------------------------------------------------------------------------------
-- Gold & Chest Tracker Frame (Bottom-Center, Movable, Dynamic Pricing)
------------------------------------------------------------------------------
local goldTracker = CreateFrame("Button", "BordoUI_GoldTrackerFrame", UIParent);
goldTracker:SetWidth(110);
goldTracker:SetHeight(28);
goldTracker:SetFrameStrata("MEDIUM");
goldTracker:SetFrameLevel(15);
goldTracker:SetClampedToScreen(true);

goldTracker:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});
goldTracker:SetBackdropColor(0, 0, 0, 0.70);
goldTracker:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8);

-- Coin Icon
local coinIcon = goldTracker:CreateTexture("BordoUI_GoldTrackerCoin", "ARTWORK");
coinIcon:SetTexture("Interface\\AddOns\\BordoUI\\Art\\Coin");
coinIcon:SetWidth(18);
coinIcon:SetHeight(18);
coinIcon:SetPoint("LEFT", goldTracker, "LEFT", 6, 0);

-- Breathing Glow behind Coin when affordable
local coinGlow = goldTracker:CreateTexture("BordoUI_GoldTrackerGlow", "BACKGROUND");
coinGlow:SetTexture("Interface\\AddOns\\BordoUI\\Art\\PaceGlow");
coinGlow:SetBlendMode("ADD");
coinGlow:SetVertexColor(1, 0.85, 0.2, 0.7);
coinGlow:SetPoint("CENTER", coinIcon, "CENTER", 0, 0);
coinGlow:SetWidth(30);
coinGlow:SetHeight(30);
coinGlow:Hide();

-- Text (e.g. 400 / 20)
local goldText = goldTracker:CreateFontString("BordoUI_GoldTrackerText", "OVERLAY");
goldText:SetFont(SurvivorUI_FONT or "Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
goldText:SetPoint("LEFT", coinIcon, "RIGHT", 6, 0);
goldText:SetJustifyH("LEFT");
goldText:SetText("|cffffd7000|r |cff888888/|r |cff33ff3320|r");

-- Draggable
BordoUI:MakeMovable(goldTracker, "goldPos");

-- Tooltip
goldTracker:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_TOP");
    GameTooltip:SetText("|cffffd200Bordo UI - Gold & Chest Tracker|r", 1, 1, 1);
    local curGold = (AZS_RUN and tonumber(AZS_RUN.gold)) or 0;
    local nextCost = (AZS_RUN and tonumber(AZS_RUN.chest)) or 20;
    GameTooltip:AddLine("Current Gold: |cffffffff" .. BordoUI:FormatNumber(curGold) .. "|r", 0.9, 0.9, 0.9);
    GameTooltip:AddLine("Next Chest Cost: |cffffffff" .. BordoUI:FormatNumber(nextCost) .. "|r", 0.9, 0.9, 0.9);
    if ( nextCost > 0 and curGold >= nextCost ) then
        GameTooltip:AddLine("|cff33ff33★ Affordable! Go open a chest! ★|r");
    elseif ( nextCost > 0 ) then
        GameTooltip:AddLine(string.format("|cffff6666✖ Need %s more gold|r", BordoUI:FormatNumber(nextCost - curGold)));
    end
    GameTooltip:AddLine("|cff888888(Left-Click and drag to move)|r", 0.7, 0.7, 0.7);
    GameTooltip:Show();
end);
goldTracker:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

-- OnUpdate loop
local goldTimer = 0;
local glowBreath = 0;
goldTracker:SetScript("OnUpdate", function()
    glowBreath = glowBreath + arg1;
    goldTimer = goldTimer + arg1;
    if ( goldTimer < 0.12 ) then return; end
    goldTimer = 0;

    local isPlaying = false;
    if ( AZS_GetPhase ) then
        local ph = AZS_GetPhase();
        isPlaying = (ph == "playing" or ph == "choosing" or ph == "paused");
    elseif ( AZS_RUN and AZS_RUN.t ) then
        local ph = AZS_RUN.ph;
        isPlaying = (ph == "playing" or ph == "choosing" or ph == "paused" or not ph);
    end

    if ( not isPlaying and not (BordoUIDB and BordoUIDB.goldPreview) ) then
        if ( this:IsShown() ) then this:Hide(); end
        return;
    end

    if ( not this:IsShown() ) then this:Show(); end

    local g = (AZS_RUN and tonumber(AZS_RUN.gold)) or 0;
    local c = (AZS_RUN and tonumber(AZS_RUN.chest)) or 20;

    local gStr = BordoUI:FormatNumber(g);
    local cStr = BordoUI:FormatNumber(c);

    if ( c > 0 and g >= c ) then
        goldText:SetText("|cffffd700" .. gStr .. "|r |cff888888/|r |cff33ff33" .. cStr .. "|r");
        this:SetBackdropBorderColor(1, 0.85, 0.2, 0.9);
        coinGlow:Show();
        local pulse = 0.55 + 0.35 * math.sin(glowBreath * 5);
        coinGlow:SetAlpha(pulse);
    else
        goldText:SetText("|cffffd700" .. gStr .. "|r |cff888888/|r |cffcca050" .. cStr .. "|r");
        this:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.8);
        coinGlow:Hide();
    end

    local textWidth = goldText:GetStringWidth() or 40;
    local wantedWidth = math.max(105, textWidth + 34);
    if ( math.abs(this:GetWidth() - wantedWidth) > 2 ) then
        this:SetWidth(wantedWidth);
    end
end);
BordoUI.GoldTrackerFrame = goldTracker;

eventFrame:SetScript("OnEvent", function()
    if ( event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" ) then
        InitDB();
        if ( BordoUIDB and BordoUIDB.goldPos ) then
            BordoUI:RestorePosition(goldTracker, BordoUIDB.goldPos);
        else
            goldTracker:ClearAllPoints();
            goldTracker:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 185);
        end
        if ( event == "PLAYER_ENTERING_WORLD" ) then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r v3.0 loaded (Survivor UI + Death Recap + Green Teammate Nameplates + Gold Tracker). Type |cffffd100/bordo|r or |cffffd100/sui|r.");
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
    elseif ( cmd == "gold" ) then
        if ( val == "reset" ) then
            BordoUIDB.goldPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 185 };
            BordoUI:RestorePosition(goldTracker, BordoUIDB.goldPos);
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Gold & Chest Tracker position reset to bottom-center.");
        else
            BordoUIDB.goldPreview = not BordoUIDB.goldPreview;
            if ( BordoUIDB.goldPreview ) then goldTracker:Show(); end
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Gold Tracker test preview " .. (BordoUIDB.goldPreview and "|cff33ff33ON|r (drag to move)" or "|cffff3333OFF|r"));
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
        BordoUIDB.goldPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 185 };
        if ( goldTracker ) then
            BordoUI:RestorePosition(goldTracker, BordoUIDB.goldPos);
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Positions reset to default.");
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI Commands:|r");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo|r or |cffffd100/recap|r - Toggle Death Recap & Lethal Hits Window");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo gold|r or |cffffd100/gold|r - Toggle Gold & Chest Tracker test preview or reset position");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo plates|r or |cffffd100/plates|r - Toggle Teammate (vibrant green) & Enemy nameplates");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo zoom [yards]|r - Unlock & set max camera distance (50 yards)");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo opt|r or |cffffd100/sui opt|r - Open Survivor UI Settings Panel");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo reset|r - Reset Death Recap & Gold frame positions");
    end
end;

SLASH_BORDOGOLD1 = "/gold";
SlashCmdList["BORDOGOLD"] = function(msg)
    msg = string.lower(msg or "");
    if ( msg == "reset" ) then
        BordoUIDB.goldPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 185 };
        BordoUI:RestorePosition(goldTracker, BordoUIDB.goldPos);
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Gold & Chest Tracker position reset to bottom-center.");
    elseif ( msg == "show" or msg == "test" ) then
        BordoUIDB.goldPreview = not BordoUIDB.goldPreview;
        if ( BordoUIDB.goldPreview ) then goldTracker:Show(); end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Gold Tracker test preview " .. (BordoUIDB.goldPreview and "|cff33ff33ON|r (drag to move)" or "|cffff3333OFF|r"));
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI Gold Tracker:|r (Left-Click & Drag to move)");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/gold reset|r - Reset position to bottom center");
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/gold test|r - Toggle test preview outside of a run");
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
