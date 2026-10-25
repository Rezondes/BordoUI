--[[
    Bordo UI - Modern Boss Loot Alert (LootAlert.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors

    Displays a prominent, modern Loot Toast above the player character
    ("Mitte oben, über dem Charakter") when a boss drops an item or jewelry:
    - 42x42 Loot Icon with Quality Border & Glow
    - "BOSS LOOT" header in gold
    - Item Name in full Quality Color (Uncommon, Rare, Epic, Legendary)
    - Item Slot / Subtitle / Collection status
    - Mouseover Tooltip with full stats & effects
    - Smooth 7-second display with fade-in and fade-out
    - Movable with Alt+Drag or /bordo unlock (saved in BordoUIDB.lootAlertPos)
    - Testable with /bordo loot or /bordo testloot
]]--

BordoUI = BordoUI or {};
local LootUI = {};
BordoUI.LootAlert = LootUI;

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local WIDTH = 270;
local HEIGHT = 54;
local ICON_SIZE = 40;

-- Quality Colors (Standard WoW 1.12.1)
local QUALITY_COLORS = {
    [0] = { 0.62, 0.62, 0.62, "|cff9d9d9d" }, -- Poor (Grey)
    [1] = { 1.00, 1.00, 1.00, "|cffffffff" }, -- Common (White)
    [2] = { 0.12, 1.00, 0.00, "|cff1eff00" }, -- Uncommon (Green)
    [3] = { 0.00, 0.44, 0.87, "|cff0070dd" }, -- Rare (Blue)
    [4] = { 0.64, 0.21, 0.93, "|cffa335ee" }, -- Epic (Purple)
    [5] = { 1.00, 0.50, 0.00, "|cffff8000" }, -- Legendary (Orange)
};

local HEX_TO_QUALITY = {
    ["9d9d9d"] = 0,
    ["ffffff"] = 1,
    ["1eff00"] = 2,
    ["0070dd"] = 3,
    ["a335ee"] = 4,
    ["ff8000"] = 5,
};

-- Multilingual prefixes for loot messages
local LOOT_PREFIXES = {
    "You receive loot:",
    "Du erhältst Beute:",
    "Otrzymujesz łup:",
    "Você recebe saque:",
    "Recibes botín:",
    "Vous recevez du butin :",
    "Ganimet aldın:",
    "Вы получаете добычу:",
    "你获得了战利品：",
    "전리품을 받았습니다:",
    "Primești pradă:",
    "Ви отримуєте здобич:",
    "戦利品を入手：",
};

local NEW_TAGS = {
    "New in your collection",
    "Neu in deiner Sammlung",
    "Nowość w kolekcji",
    "Novo na sua coleção",
    "Nuevo en tu colección",
    "Nouveau dans votre collection",
    "Koleksiyonunda yeni",
    "Новое в вашей коллекции",
    "收藏新增",
    "수집품에 새로 추가",
};

-- ============================================================================
-- Frame Creation (Top-Center, above Character)
-- ============================================================================
local frame = CreateFrame("Button", "BordoUI_LootAlertFrame", UIParent);
LootUI.frame = frame;
frame:SetWidth(WIDTH);
frame:SetHeight(HEIGHT);
-- Default: Top-Center above character
frame:SetPoint("TOP", UIParent, "TOP", 0, -175);
frame:SetFrameStrata("HIGH");
frame:SetFrameLevel(25);
frame:SetClampedToScreen(true);
frame:SetMovable(true);
frame:EnableMouse(true);
frame:RegisterForDrag("LeftButton");
frame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
frame:Hide();

frame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        frame:StartMoving();
    end
end);

frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = frame:GetPoint();
        BordoUIDB.lootAlertPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);

-- Background
frame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
frame:SetBackdropColor(0.04, 0.04, 0.07, 0.94);
frame:SetBackdropBorderColor(0.64, 0.21, 0.93, 0.95); -- default epic purple accent

-- Icon Container & Glow
local iconFrame = CreateFrame("Frame", nil, frame);
iconFrame:SetWidth(ICON_SIZE);
iconFrame:SetHeight(ICON_SIZE);
iconFrame:SetPoint("LEFT", frame, "LEFT", 7, 0);

local iconGlow = iconFrame:CreateTexture(nil, "BACKGROUND");
iconGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
iconGlow:SetBlendMode("ADD");
iconGlow:SetPoint("CENTER", iconFrame, "CENTER", 0, 0);
iconGlow:SetWidth(ICON_SIZE + 18);
iconGlow:SetHeight(ICON_SIZE + 18);
iconGlow:SetVertexColor(0.64, 0.21, 0.93, 0.85);

local iconTex = iconFrame:CreateTexture(nil, "ARTWORK");
iconTex:SetAllPoints(iconFrame);
iconTex:SetTexture("Interface\\Icons\\INV_Box_01");
iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92);

local iconBorder = iconFrame:CreateTexture(nil, "OVERLAY");
iconBorder:SetTexture(FLAT);
iconBorder:SetAllPoints(iconFrame);
iconBorder:SetVertexColor(0.64, 0.21, 0.93, 1.0);
iconBorder:Hide();

-- Text Elements
local titleText = frame:CreateFontString(nil, "OVERLAY");
titleText:SetFont(FONT_PATH, 9, "OUTLINE");
titleText:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 9, -2);
titleText:SetTextColor(1.0, 0.82, 0.0);
titleText:SetText("BOSS LOOT");

local nameText = frame:CreateFontString(nil, "OVERLAY");
nameText:SetFont(FONT_PATH, 11, "OUTLINE");
nameText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -2);
nameText:SetPoint("RIGHT", frame, "RIGHT", -10, 0);
nameText:SetJustifyH("LEFT");
nameText:SetTextColor(1.0, 1.0, 1.0);
nameText:SetText("Item Name");

local subText = frame:CreateFontString(nil, "OVERLAY");
subText:SetFont(FONT_PATH, 9, "OUTLINE");
subText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2);
subText:SetPoint("RIGHT", frame, "RIGHT", -10, 0);
subText:SetJustifyH("LEFT");
subText:SetTextColor(0.75, 0.75, 0.80);
subText:SetText("Jewelry Drop");

-- Close button
local closeBtn = CreateFrame("Button", nil, frame);
closeBtn:SetWidth(14);
closeBtn:SetHeight(14);
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4);
local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
closeTxt:SetFont(FONT_PATH, 10, "OUTLINE");
closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
closeTxt:SetTextColor(0.6, 0.6, 0.6);
closeTxt:SetText("x");
closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.3, 0.3); end);
closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.6, 0.6, 0.6); end);
closeBtn:SetScript("OnClick", function()
    frame:Hide();
end);

-- Tooltip on Hover
frame:SetScript("OnEnter", function()
    if this.itemLink then
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
        GameTooltip:SetHyperlink(this.itemLink);
        GameTooltip:Show();
    elseif this.itemSlot then
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
        GameTooltip:SetInventoryItem("player", this.itemSlot);
        GameTooltip:Show();
    elseif this.itemName then
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
        local r, g, b = 1, 1, 1;
        if this.itemQuality and QUALITY_COLORS[this.itemQuality] then
            r = QUALITY_COLORS[this.itemQuality][1];
            g = QUALITY_COLORS[this.itemQuality][2];
            b = QUALITY_COLORS[this.itemQuality][3];
        end
        GameTooltip:SetText(this.itemName, r, g, b);
        if this.subDetail then
            GameTooltip:AddLine(this.subDetail, 0.85, 0.85, 0.85);
        end
        GameTooltip:Show();
    end
end);

frame:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

frame:SetScript("OnClick", function()
    if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsShown() and this.itemLink then
        ChatFrameEditBox:Insert(this.itemLink);
    else
        frame:Hide();
    end
end);

-- ============================================================================
-- Animation & Show Routine
-- ============================================================================
local displayTimer = 0;
local DISPLAY_DURATION = 7.0; -- seconds to stay visible

frame:SetScript("OnUpdate", function()
    if displayTimer > 0 then
        displayTimer = displayTimer - arg1;
        if displayTimer <= 0 then
            frame:Hide();
        elseif displayTimer < 0.5 then
            -- Fade out over last 0.5s
            local alpha = math.max(0, displayTimer / 0.5);
            frame:SetAlpha(alpha);
        else
            frame:SetAlpha(1.0);
        end
    end
end);

function LootUI:ShowAlert(name, itemLink, texture, quality, slotLabel, isNew, itemSlot)
    if not name or name == "" then return; end

    -- Quality Color
    quality = quality or 4; -- default Epic
    local qc = QUALITY_COLORS[quality] or QUALITY_COLORS[4];
    local r, g, b = qc[1], qc[2], qc[3];

    -- Texture
    if (not texture or texture == "") and itemLink and GetItemInfo then
        local _, _, _, _, _, _, _, _, itemTex = GetItemInfo(itemLink);
        texture = itemTex;
    end
    if not texture or texture == "" then
        texture = "Interface\\Icons\\INV_Box_01";
    end

    iconTex:SetTexture(texture);
    iconGlow:SetVertexColor(r, g, b, 0.90);
    frame:SetBackdropBorderColor(r, g, b, 0.95);

    nameText:SetText(name);
    nameText:SetTextColor(r, g, b);

    local sub = slotLabel or "Jewelry Drop";
    if isNew then
        sub = sub .. " \194\183 |cff7dff7dNew in collection!|r";
    end
    subText:SetText(sub);

    frame.itemName = name;
    frame.itemLink = itemLink;
    frame.itemQuality = quality;
    frame.subDetail = sub;
    frame.itemSlot = itemSlot;

    displayTimer = DISPLAY_DURATION;
    frame:SetAlpha(1.0);
    frame:Show();

    PlaySound("QUESTCOMPLETED");
end

-- ============================================================================
-- Chat Message Interception
-- ============================================================================
local function ParseLootMessage(message)
    if type(message) ~= "string" then return; end

    local body = nil;
    for _, prefix in ipairs(LOOT_PREFIXES) do
        local _, last = string.find(message, prefix, 1, true);
        if last then
            body = string.sub(message, last + 1);
            break;
        end
    end

    if not body then
        local _, _, rest = string.find(message, "You receive [%a ]+: (.+)");
        body = rest;
    end

    if not body or body == "" then return; end

    -- Extract name, link, color
    local _, _, itemLink, linkedName = string.find(body, "|H(item:[^|]+)|h%[(.-)%]|h");
    local _, _, hexColor = string.find(body, "|c%x%x(%x%x%x%x%x%x)");
    local name = linkedName;
    if not name then
        local _, _, bracketName = string.find(body, "%[(.-)%]");
        name = bracketName;
    end

    if not name or name == "" then return; end

    -- Check if new in collection
    local isNew = false;
    for _, tag in ipairs(NEW_TAGS) do
        if string.find(body, tag, 1, true) then
            isNew = true;
            break;
        end
    end

    -- Determine quality & info
    local quality = 4; -- default Epic
    local itemQuery = itemLink or name;
    if hexColor then
        quality = HEX_TO_QUALITY[string.lower(hexColor)] or 4;
    elseif itemQuery and GetItemInfo then
        local _, _, itemQuality = GetItemInfo(itemQuery);
        if itemQuality then quality = itemQuality; end
    end

    -- Texture & Slot info
    local texture = nil;
    local slotLabel = "Boss Drop";
    if itemQuery and GetItemInfo then
        local iName, iLink, iQual, _, _, _, _, equipLoc, itemTex = GetItemInfo(itemQuery);
        if itemTex then texture = itemTex; end
        if iLink and not itemLink then itemLink = iLink; end
        if iQual and not hexColor then quality = iQual; end
        if equipLoc and equipLoc ~= "" and getglobal(equipLoc) then
            slotLabel = getglobal(equipLoc);
        end
    end

    LootUI:ShowAlert(name, itemLink, texture, quality, slotLabel, isNew);
end

-- ============================================================================
-- Inventory Watcher (Detect newly equipped boss drops / jewelry in run)
-- ============================================================================
local JEWELRY_SLOTS = { 2, 11, 12, 13, 14 };
local SLOT_NAMES = {
    [2] = "Neck",
    [11] = "Ring",
    [12] = "Ring",
    [13] = "Trinket",
    [14] = "Trinket",
};

local knownGear = {};
local initializedGear = false;

local function CheckEquippedGear()
    if not GetInventoryItemLink then return; end

    for _, slot in ipairs(JEWELRY_SLOTS) do
        local link = GetInventoryItemLink("player", slot);
        local oldLink = knownGear[slot];

        if link and link ~= oldLink then
            knownGear[slot] = link;
            if initializedGear then
                -- A new piece was equipped!
                local _, _, name = string.find(link, "%[(.-)%]");
                local texture = GetInventoryItemTexture("player", slot);
                local _, _, hexColor = string.find(link, "|c%x%x(%x%x%x%x%x%x)");
                local quality = (hexColor and HEX_TO_QUALITY[string.lower(hexColor)]) or 4;
                local slotName = SLOT_NAMES[slot] or "Jewelry";

                LootUI:ShowAlert(name or "Jewelry", link, texture, quality, slotName, false, slot);
            end
        elseif not link then
            knownGear[slot] = nil;
        end
    end
    initializedGear = true;
end

-- ============================================================================
-- Events & Initialization
-- ============================================================================
local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("CHAT_MSG_LOOT");
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM");
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("VARIABLES_LOADED");
eventFrame:RegisterEvent("CHAT_MSG_ADDON");

eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_SYSTEM" then
        ParseLootMessage(arg1);
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            CheckEquippedGear();
        end
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == "AZSZONE" then
            -- Reset gear baseline for new run
            knownGear = {};
            initializedGear = false;
            CheckEquippedGear();
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
        -- Restore saved position
        if BordoUIDB and BordoUIDB.lootAlertPos and BordoUIDB.lootAlertPos.point then
            BordoUI:RestorePosition(frame, BordoUIDB.lootAlertPos);
        else
            frame:ClearAllPoints();
            frame:SetPoint("TOP", UIParent, "TOP", 0, -175);
        end
        CheckEquippedGear();
    end
end);

-- ============================================================================
-- Test Helper
-- ============================================================================
function BordoUI:TestLootAlert()
    LootUI:ShowAlert(
        "Band of Accuria",
        "item:17063:0:0:0",
        "Interface\\Icons\\INV_Jewelry_Ring_15",
        4, -- Epic
        "Finger (Ring · Rank IV)",
        true
    );
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Triggered Boss Loot Alert preview above character.");
end
