--[[
    Bordo UI - Modern Boss Loot Alert & Run Loot Log (LootAlert.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors

    1. Top-Center Boss Loot Toast ("Mitte oben, über dem Charakter"):
       - Prominent 40x40 Authentic Item Icon with Quality Border & Glow
       - "BOSS LOOT" header in gold
       - Item Name in full Quality Color (Uncommon, Rare, Epic, Legendary)
       - Item Slot / Subtitle / Collection status (e.g. "Legs · Epic", "Finger · New in collection!")
       - ONLY triggers on true enemy boss drops (CHAT_MSG_LOOT / CHAT_MSG_SYSTEM).
       - Never triggers on Augment choices or level-up upgrades!
       - Excludes starting ability Neck amulets.
       - Smooth 7-second display with fade-out.
       - Movable with Alt+Drag or /bordo unlock (saved in BordoUIDB.lootAlertPos).

    2. Left-Hand Run Loot Log ("Links wo höchster Krit ist"):
       - Sleek panel docked under "Höchster Krit" (SurvivorUICrits) or This Run (SurvivorUIRun)
       - Lists all equipment & jewelry dropped in the current run (newest first)
       - Each entry displays the authentic item icon, quality color, drop time, and count
       - Interactive hover tooltip and Shift-Click link insertion
       - Movable with Alt+Drag or /bordo unlock (saved in BordoUIDB.lootListPos)
       - Resets cleanly when a new run begins (AZSZONE or "Move to begin")

    3. Native Right-Side Loot Suppression:
       - Continuously ensures AZS_SetHudShown("loot", false) so no duplicate window appears on the right.
]]--

BordoUI = BordoUI or {};
local LootUI = {};
BordoUI.LootAlert = LootUI;

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local TOAST_WIDTH = 270;
local TOAST_HEIGHT = 54;
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
    "Nou în colecția ta",
    "Нове у вашій колекції",
};

-- Slot keyword fallback icons so real item symbols (Pants, Helm, Ring, etc.) ALWAYS show, never a box!
local SLOT_KEYWORD_FALLBACKS = {
    -- Pants / Legs
    { keywords = { "pants", "leggings", "legguards", "trousers", "breeches", "kilt", "chaps", "hose", "beine", "beinplatten", "gamaschen" },
      icon = "Interface\\Icons\\INV_Pants_02", slot = "Legs" },
    -- Helm / Head
    { keywords = { "helm", "helmet", "crown", "circlet", "cap", "cowl", "hat", "headpiece", "kopf", "krone", "haube", "visier", "diadem", "kapuze" },
      icon = "Interface\\Icons\\INV_Helmet_06", slot = "Head" },
    -- Shoulders
    { keywords = { "shoulder", "pauldrons", "spaulders", "mantle", "epaulets", "shoulderguards", "schultern", "schulterpolster", "schiftung", "amice" },
      icon = "Interface\\Icons\\INV_Shoulder_02", slot = "Shoulders" },
    -- Chest
    { keywords = { "chest", "vest", "robe", "tunic", "breastplate", "hauberk", "jerkin", "armor", "brust", "gewand", "wams", "harnisch", "panzer", "kutte" },
      icon = "Interface\\Icons\\INV_Chest_Cloth_17", slot = "Chest" },
    -- Gloves
    { keywords = { "gloves", "gauntlets", "mitts", "handguards", "grips", "handschuhe", "stulpen", "faustschützer", "griffe", "handschutz" },
      icon = "Interface\\Icons\\INV_Gauntlets_04", slot = "Hands" },
    -- Belt
    { keywords = { "belt", "girdle", "cinch", "cord", "sash", "waistguard", "gürtel", "gurt", "kordel", "schärpe", "taillenschutz" },
      icon = "Interface\\Icons\\INV_Belt_03", slot = "Waist" },
    -- Boots
    { keywords = { "boots", "sabatons", "greaves", "footpads", "shoes", "striders", "stiefel", "treter", "schuhe", "panzerstiefel" },
      icon = "Interface\\Icons\\INV_Boots_01", slot = "Feet" },
    -- Bracers
    { keywords = { "bracers", "cuffs", "wristguards", "bindings", "armschienen", "handgelenke", "manschetten", "armbänder" },
      icon = "Interface\\Icons\\INV_Bracer_07", slot = "Wrist" },
    -- Cloak
    { keywords = { "cloak", "cape", "drape", "shroud", "umhang", "mantel", "schleier" },
      icon = "Interface\\Icons\\INV_Misc_Cape_19", slot = "Back" },
    -- Rings
    { keywords = { "ring", "band", "signet", "circle", "loop", "siegel", "reif" },
      icon = "Interface\\Icons\\INV_Jewelry_Ring_15", slot = "Finger" },
    -- Trinkets
    { keywords = { "trinket", "talisman", "charm", "badge", "token", "schmuck", "abzeichen", "brosche", "amulett", "medaillon" },
      icon = "Interface\\Icons\\INV_Jewelry_Talisman_07", slot = "Trinket" },
    -- Shield
    { keywords = { "shield", "buckler", "bulwark", "aegis", "schild", "bollwerk", "rundschild" },
      icon = "Interface\\Icons\\INV_Shield_05", slot = "Shield" },
    -- Weapons
    { keywords = { "sword", "blade", "saber", "scimitar", "broadsword", "longsword", "schwert", "klinge", "säbel" },
      icon = "Interface\\Icons\\INV_Sword_04", slot = "One-Hand" },
    { keywords = { "axe", "hatchet", "cleaver", "battleaxe", "axt", "beil", "spalter", "kriegsaxt" },
      icon = "Interface\\Icons\\INV_Axe_02", slot = "One-Hand" },
    { keywords = { "mace", "hammer", "club", "mallet", "bludgeon", "streitkolben", "hammer", "keule", "schlägel" },
      icon = "Interface\\Icons\\INV_Mace_01", slot = "One-Hand" },
    { keywords = { "dagger", "knife", "shank", "stiletto", "dirk", "dolch", "messer", "krummdolch" },
      icon = "Interface\\Icons\\INV_Misc_Knife_02", slot = "One-Hand" },
    { keywords = { "staff", "rod", "pole", "greatstaff", "stab", "stecken" },
      icon = "Interface\\Icons\\INV_Staff_08", slot = "Two-Hand" },
    { keywords = { "bow", "longbow", "shortbow", "composite bow", "bogen", "langbogen" },
      icon = "Interface\\Icons\\INV_Weapon_Bow_05", slot = "Ranged" },
    { keywords = { "crossbow", "armbrust" },
      icon = "Interface\\Icons\\INV_Weapon_Crossbow_01", slot = "Ranged" },
    { keywords = { "gun", "rifle", "musket", "blunderbuss", "shotgun", "flinte", "gewehr", "büchse" },
      icon = "Interface\\Icons\\INV_Weapon_Rifle_01", slot = "Ranged" },
    { keywords = { "wand", "zauberstab" },
      icon = "Interface\\Icons\\INV_Wand_01", slot = "Ranged" },
};

-- Known Classic WoW & Azeroth Survivors drops for instant resolution
local KNOWN_ITEMS = {
    -- Pants
    ["wildheart pants"] = { tex = "Interface\\Icons\\INV_Pants_02", slot = "INVTYPE_LEGS", q = 4 },
    ["hose des wildherzens"] = { tex = "Interface\\Icons\\INV_Pants_02", slot = "INVTYPE_LEGS", q = 4 },
    ["bloodfang pants"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 4 },
    ["hose der blutfänge"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 4 },
    ["judgement legplates"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 4 },
    ["beinplatten des gerichts"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 4 },
    ["netherwind pants"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 4 },
    ["hose des netherwinds"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 4 },
    ["dragonstalker's legguards"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 4 },
    ["drachenjägerschützer"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 4 },
    ["dreadmist leggings"] = { tex = "Interface\\Icons\\INV_Pants_07", slot = "INVTYPE_LEGS", q = 3 },
    ["gamaschen des schreckenszwirns"] = { tex = "Interface\\Icons\\INV_Pants_07", slot = "INVTYPE_LEGS", q = 3 },
    ["shadowcraft pants"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 3 },
    ["hose des schattenkunst"] = { tex = "Interface\\Icons\\INV_Pants_06", slot = "INVTYPE_LEGS", q = 3 },
    ["magister's leggings"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["gamaschen des magisters"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["devout skirt"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["rock der frömmigkeit"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["lightforge legplates"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 3 },
    ["beinplatten der essenz"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 3 },
    ["beaststalker's pants"] = { tex = "Interface\\Icons\\INV_Pants_03", slot = "INVTYPE_LEGS", q = 3 },
    ["hose des bestienmeisters"] = { tex = "Interface\\Icons\\INV_Pants_03", slot = "INVTYPE_LEGS", q = 3 },
    ["elements kilt"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["kilt der elemente"] = { tex = "Interface\\Icons\\INV_Pants_08", slot = "INVTYPE_LEGS", q = 3 },
    ["valor legplates"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 3 },
    ["beinplatten des heldentums"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 3 },
    ["cloudkeeper legplates"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 4 },
    ["wolkenwächter-beinplatten"] = { tex = "Interface\\Icons\\INV_Pants_04", slot = "INVTYPE_LEGS", q = 4 },
    -- Helmets
    ["crown of destruction"] = { tex = "Interface\\Icons\\INV_Helmet_08", slot = "INVTYPE_HEAD", q = 4 },
    ["krone der zerstörung"] = { tex = "Interface\\Icons\\INV_Helmet_08", slot = "INVTYPE_HEAD", q = 4 },
    -- Rings
    ["band of accuria"] = { tex = "Interface\\Icons\\INV_Jewelry_Ring_15", slot = "INVTYPE_FINGER", q = 4 },
    ["band der präzision"] = { tex = "Interface\\Icons\\INV_Jewelry_Ring_15", slot = "INVTYPE_FINGER", q = 4 },
    ["ring of the protector"] = { tex = "Interface\\Icons\\INV_Jewelry_Ring_03", slot = "INVTYPE_FINGER", q = 4 },
    ["ring des beschützers"] = { tex = "Interface\\Icons\\INV_Jewelry_Ring_03", slot = "INVTYPE_FINGER", q = 4 },
    -- Trinkets
    ["blackhand's breadth"] = { tex = "Interface\\Icons\\INV_Misc_StoneTablet_11", slot = "INVTYPE_TRINKET", q = 3 },
    ["schwarzfausts breite"] = { tex = "Interface\\Icons\\INV_Misc_StoneTablet_11", slot = "INVTYPE_TRINKET", q = 3 },
};

-- Suppress native right-hand boss loot notice
local function SuppressNativeLootNotice()
    if AZS_SetHudShown and AZS_IsHudShown then
        if AZS_IsHudShown("loot") then
            AZS_SetHudShown("loot", false);
        end
    end
end

-- ============================================================================
-- 1. Center Boss Loot Toast
-- ============================================================================
local toastFrame = CreateFrame("Button", "BordoUI_LootAlertFrame", UIParent);
LootUI.frame = toastFrame;
toastFrame:SetWidth(TOAST_WIDTH);
toastFrame:SetHeight(TOAST_HEIGHT);
toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -175);
toastFrame:SetFrameStrata("HIGH");
toastFrame:SetFrameLevel(25);
toastFrame:SetClampedToScreen(true);
toastFrame:SetMovable(true);
toastFrame:EnableMouse(true);
toastFrame:RegisterForDrag("LeftButton");
toastFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
toastFrame:Hide();

toastFrame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        toastFrame:StartMoving();
    end
end);

toastFrame:SetScript("OnDragStop", function()
    toastFrame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = toastFrame:GetPoint();
        BordoUIDB.lootAlertPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);

toastFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
toastFrame:SetBackdropColor(0.04, 0.04, 0.07, 0.94);
toastFrame:SetBackdropBorderColor(0.64, 0.21, 0.93, 0.95);

local iconFrame = CreateFrame("Frame", nil, toastFrame);
iconFrame:SetWidth(ICON_SIZE);
iconFrame:SetHeight(ICON_SIZE);
iconFrame:SetPoint("LEFT", toastFrame, "LEFT", 7, 0);

local iconGlow = iconFrame:CreateTexture(nil, "BACKGROUND");
iconGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
iconGlow:SetBlendMode("ADD");
iconGlow:SetPoint("CENTER", iconFrame, "CENTER", 0, 0);
iconGlow:SetWidth(ICON_SIZE + 18);
iconGlow:SetHeight(ICON_SIZE + 18);
iconGlow:SetVertexColor(0.64, 0.21, 0.93, 0.85);

local iconTex = iconFrame:CreateTexture(nil, "ARTWORK");
iconTex:SetAllPoints(iconFrame);
iconTex:SetTexture("Interface\\Icons\\INV_Pants_02");
iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92);

local titleText = toastFrame:CreateFontString(nil, "OVERLAY");
titleText:SetFont(FONT_PATH, 9, "OUTLINE");
titleText:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 9, -2);
titleText:SetTextColor(1.0, 0.82, 0.0);
titleText:SetText("BOSS LOOT");

local nameText = toastFrame:CreateFontString(nil, "OVERLAY");
nameText:SetFont(FONT_PATH, 11, "OUTLINE");
nameText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -2);
nameText:SetPoint("RIGHT", toastFrame, "RIGHT", -16, 0);
nameText:SetJustifyH("LEFT");
nameText:SetTextColor(1.0, 1.0, 1.0);
nameText:SetText("Item Name");

local subText = toastFrame:CreateFontString(nil, "OVERLAY");
subText:SetFont(FONT_PATH, 9, "OUTLINE");
subText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2);
subText:SetPoint("RIGHT", toastFrame, "RIGHT", -16, 0);
subText:SetJustifyH("LEFT");
subText:SetTextColor(0.75, 0.75, 0.80);
subText:SetText("Boss Drop");

local closeBtn = CreateFrame("Button", nil, toastFrame);
closeBtn:SetWidth(14);
closeBtn:SetHeight(14);
closeBtn:SetPoint("TOPRIGHT", toastFrame, "TOPRIGHT", -4, -4);
local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
closeTxt:SetFont(FONT_PATH, 10, "OUTLINE");
closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
closeTxt:SetTextColor(0.6, 0.6, 0.6);
closeTxt:SetText("x");
closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.3, 0.3); end);
closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.6, 0.6, 0.6); end);
closeBtn:SetScript("OnClick", function() toastFrame:Hide(); end);

toastFrame:SetScript("OnEnter", function()
    if this.itemLink then
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
        GameTooltip:SetHyperlink(this.itemLink);
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

toastFrame:SetScript("OnLeave", function() GameTooltip:Hide(); end);
toastFrame:SetScript("OnClick", function()
    if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsShown() and this.itemLink then
        ChatFrameEditBox:Insert(this.itemLink);
    else
        toastFrame:Hide();
    end
end);

-- ============================================================================
-- 2. Left-Hand Run Loot Log ("Links wo höchster Krit ist")
-- ============================================================================
local LOG_WIDTH = 220;
local ROW_HEIGHT = 20;
local MAX_LOG_ROWS = 8;
local runLoot = {}; -- { name, link, tex, quality, isNew, time, count }

local logFrame = CreateFrame("Button", "BordoUI_LootLogFrame", UIParent);
LootUI.logFrame = logFrame;
logFrame:SetWidth(LOG_WIDTH);
logFrame:SetHeight(48);
logFrame:SetFrameStrata("MEDIUM");
logFrame:SetFrameLevel(15);
logFrame:SetClampedToScreen(true);
logFrame:SetMovable(true);
logFrame:EnableMouse(true);
logFrame:RegisterForDrag("LeftButton");
logFrame:Hide();

logFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
logFrame:SetBackdropColor(0.04, 0.04, 0.07, 0.88);
logFrame:SetBackdropBorderColor(0.28, 0.28, 0.32, 0.95);

logFrame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        logFrame:StartMoving();
    end
end);

logFrame:SetScript("OnDragStop", function()
    logFrame:StopMovingOrSizing();
    if BordoUIDB then
        local point, _, relPoint, x, y = logFrame:GetPoint();
        BordoUIDB.lootListPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);

local logTitle = logFrame:CreateFontString(nil, "OVERLAY");
logTitle:SetFont(FONT_PATH, 11, "OUTLINE");
logTitle:SetPoint("TOPLEFT", logFrame, "TOPLEFT", 8, -6);
logTitle:SetTextColor(1.0, 0.82, 0.0);
logTitle:SetText("Loot");

local logRows = {};

local function CreateLogRow(i)
    local row = CreateFrame("Button", nil, logFrame);
    row:SetWidth(LOG_WIDTH - 16);
    row:SetHeight(ROW_HEIGHT);
    row:SetPoint("TOPLEFT", logFrame, "TOPLEFT", 8, -22 - (i - 1) * ROW_HEIGHT);
    row:EnableMouse(true);
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    row.icon = row:CreateTexture(nil, "ARTWORK");
    row.icon:SetWidth(16);
    row.icon:SetHeight(16);
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0);
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

    row.iconBorder = row:CreateTexture(nil, "OVERLAY");
    row.iconBorder:SetTexture(FLAT);
    row.iconBorder:SetPoint("TOPLEFT", row.icon, "TOPLEFT", -1, 1);
    row.iconBorder:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 1, -1);
    row.iconBorder:SetVertexColor(0, 0, 0, 1);

    row.name = row:CreateFontString(nil, "OVERLAY");
    row.name:SetFont(FONT_PATH, 10, "OUTLINE");
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0);
    row.name:SetWidth(128);
    row.name:SetHeight(12);
    row.name:SetJustifyH("LEFT");
    row.name:SetTextColor(1, 1, 1);

    row.time = row:CreateFontString(nil, "OVERLAY");
    row.time:SetFont(FONT_PATH, 9, "OUTLINE");
    row.time:SetPoint("RIGHT", row, "RIGHT", -2, 0);
    row.time:SetTextColor(0.75, 0.75, 0.75);

    row:SetScript("OnEnter", function()
        if this.itemLink then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(this.itemLink);
            GameTooltip:Show();
        elseif this.itemName then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
            local r, g, b = 1, 1, 1;
            if this.itemQuality and QUALITY_COLORS[this.itemQuality] then
                r = QUALITY_COLORS[this.itemQuality][1];
                g = QUALITY_COLORS[this.itemQuality][2];
                b = QUALITY_COLORS[this.itemQuality][3];
            end
            GameTooltip:SetText(this.itemName, r, g, b);
            GameTooltip:Show();
        end
    end);
    row:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    row:SetScript("OnClick", function()
        if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsShown() and this.itemLink then
            ChatFrameEditBox:Insert(this.itemLink);
        end
    end);

    logRows[i] = row;
    return row;
end

local function PlaceLootLog()
    if BordoUIDB and BordoUIDB.lootListPos and BordoUIDB.lootListPos.point then
        BordoUI:RestorePosition(logFrame, BordoUIDB.lootListPos);
        return;
    end
    logFrame:ClearAllPoints();
    local crits = getglobal("SurvivorUICrits");
    local run = getglobal("SurvivorUIRun");
    if crits and crits:IsShown() then
        logFrame:SetPoint("TOPLEFT", crits, "BOTTOMLEFT", 0, -8);
    elseif run and run:IsShown() then
        logFrame:SetPoint("TOPLEFT", run, "BOTTOMLEFT", 0, -8);
    else
        logFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -260);
    end
end

local function UpdateLootLog()
    local n = table.getn(runLoot);
    if n == 0 and not BordoUI.isMovingUnlocked then
        logFrame:Hide();
        return;
    end

    if n > 0 then
        logTitle:SetText(string.format("Loot (%d)", n));
    else
        logTitle:SetText("Loot (Drag Me)");
    end

    local displayCount = math.min(n, MAX_LOG_ROWS);
    for i = 1, MAX_LOG_ROWS do
        local row = logRows[i] or CreateLogRow(i);
        if i <= displayCount then
            local entry = runLoot[i];
            row.itemName = entry.name;
            row.itemLink = entry.link;
            row.itemQuality = entry.quality;

            local qc = QUALITY_COLORS[entry.quality] or QUALITY_COLORS[4];
            local r, g, b = qc[1], qc[2], qc[3];

            row.icon:SetTexture(entry.tex or "Interface\\Icons\\INV_Misc_Gift_01");
            row.name:SetText(entry.name);
            row.name:SetTextColor(r, g, b);

            local extra = entry.time or "";
            if entry.count and entry.count > 1 then
                extra = "x" .. entry.count .. " " .. extra;
            end
            if entry.isNew then
                extra = "|cff7dff7dnew|r " .. extra;
            end
            row.time:SetText(extra);
            row:Show();
        else
            row:Hide();
        end
    end

    local finalHeight = 24 + math.max(1, displayCount) * ROW_HEIGHT + 6;
    logFrame:SetHeight(finalHeight);
    PlaceLootLog();
    logFrame:Show();
end

local function AddRunLootEntry(name, itemLink, texture, quality, isNew)
    local runSeconds = (AZS_GetRunTime and AZS_GetRunTime()) or (AZS_RUN and tonumber(AZS_RUN.t)) or 0;
    local timeStr = "";
    if runSeconds and runSeconds > 0 then
        timeStr = string.format("%d:%02d", math.floor(runSeconds / 60), math.mod(math.floor(runSeconds), 60));
    end

    local found = nil;
    for _, entry in ipairs(runLoot) do
        if entry.name == name then
            found = entry;
            break;
        end
    end

    if found then
        found.count = (found.count or 1) + 1;
        found.time = timeStr;
        if texture and texture ~= "" and (not found.tex or string.find(found.tex, "Gift_01", 1, true)) then
            found.tex = texture;
        end
    else
        local entry = {
            name    = name,
            link    = itemLink,
            tex     = texture,
            quality = quality or 4,
            isNew   = isNew,
            time    = timeStr,
            count   = 1,
        };
        table.insert(runLoot, 1, entry);
    end

    UpdateLootLog();
end

-- ============================================================================
-- Item Cache & Bag Scanning (Background Knowledge Only - Never triggers alert)
-- ============================================================================
local function GetItemCache()
    BordoUIDB = BordoUIDB or {};
    if type(BordoUIDB.itemCache) ~= "table" then
        BordoUIDB.itemCache = {};
    end
    return BordoUIDB.itemCache;
end

local function ScanAllPlayerItems()
    local cache = GetItemCache();

    -- Scan 19 inventory slots
    if GetInventoryItemLink then
        for slot = 1, 19 do
            local link = GetInventoryItemLink("player", slot);
            if link then
                local _, _, name = string.find(link, "%[(.-)%]");
                local tex = GetInventoryItemTexture and GetInventoryItemTexture("player", slot);
                if name and name ~= "" then
                    local lower = string.lower(name);
                    cache[lower] = cache[lower] or {};
                    cache[lower].name = name;
                    cache[lower].link = link;
                    if tex then cache[lower].tex = tex; end
                end
            end
        end
    end

    -- Scan bags (0 = backpack, 1..4 = bags)
    if GetContainerNumSlots and GetContainerItemLink and GetContainerItemInfo then
        for bag = 0, 4 do
            local numSlots = GetContainerNumSlots(bag) or 0;
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot);
                if link then
                    local _, _, name = string.find(link, "%[(.-)%]");
                    local tex = GetContainerItemInfo(bag, slot);
                    if name and name ~= "" then
                        local lower = string.lower(name);
                        cache[lower] = cache[lower] or {};
                        cache[lower].name = name;
                        cache[lower].link = link;
                        if tex then cache[lower].tex = tex; end
                    end
                end
            end
        end
    end
end

local function FindItemInBagsOrInventory(targetName)
    if not targetName or targetName == "" then return nil, nil; end
    local lowerTarget = string.lower(targetName);

    -- Check bags first
    if GetContainerNumSlots and GetContainerItemLink and GetContainerItemInfo then
        for bag = 0, 4 do
            local numSlots = GetContainerNumSlots(bag) or 0;
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot);
                if link then
                    local _, _, name = string.find(link, "%[(.-)%]");
                    if name and string.lower(name) == lowerTarget then
                        local tex = GetContainerItemInfo(bag, slot);
                        return link, tex;
                    end
                end
            end
        end
    end

    -- Check equipped gear
    if GetInventoryItemLink then
        for slot = 1, 19 do
            local link = GetInventoryItemLink("player", slot);
            if link then
                local _, _, name = string.find(link, "%[(.-)%]");
                if name and string.lower(name) == lowerTarget then
                    local tex = GetInventoryItemTexture and GetInventoryItemTexture("player", slot);
                    return link, tex;
                end
            end
        end
    end

    return nil, nil;
end

local function GetKeywordFallbackIcon(name)
    local lower = string.lower(name or "");
    for _, entry in ipairs(SLOT_KEYWORD_FALLBACKS) do
        for _, kw in ipairs(entry.keywords) do
            if string.find(lower, kw, 1, true) then
                return entry.icon, entry.slot;
            end
        end
    end
    return "Interface\\Icons\\INV_Misc_Gift_01", "Boss Drop";
end

-- Filter out starting class ability amulets (Neck pieces are NOT boss drops!)
local function IsNeckPiece(name, itemLink, slotLabel)
    if slotLabel == "Neck" or slotLabel == "Hals" or slotLabel == "INVTYPE_NECK" then return true; end
    local lower = string.lower(name or "");
    if string.find(lower, "neck") or string.find(lower, "amulet") or string.find(lower, "halskette") or string.find(lower, "medallion") then
        return true;
    end
    if string.find(name or "", ":") and (string.find(name or "", " I") or string.find(name or "", " II") or string.find(name or "", " III") or string.find(name or "", " IV") or string.find(name or "", " V")) then
        return true;
    end
    if itemLink and GetItemInfo then
        local _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemLink);
        if equipLoc == "INVTYPE_NECK" then return true; end
    end
    return false;
end

-- ============================================================================
-- Animation & Live Texture Resolver
-- ============================================================================
local displayTimer = 0;
local DISPLAY_DURATION = 7.0;
local resolveTimer = 0;
local suppressTimer = 0;

toastFrame:SetScript("OnUpdate", function()
    -- Suppress native right-hand popup periodically
    suppressTimer = suppressTimer + arg1;
    if suppressTimer >= 1.0 then
        suppressTimer = 0;
        SuppressNativeLootNotice();
    end

    -- Toast display countdown & smooth fade out
    if displayTimer > 0 then
        displayTimer = displayTimer - arg1;
        if displayTimer <= 0 then
            toastFrame:Hide();
            toastFrame.pendingQuery = nil;
            toastFrame.pendingName = nil;
        elseif displayTimer < 0.5 then
            local alpha = math.max(0, displayTimer / 0.5);
            toastFrame:SetAlpha(alpha);
        else
            toastFrame:SetAlpha(1.0);
        end
    end

    -- Background texture & metadata resolver
    if (toastFrame.pendingQuery or toastFrame.pendingName) and displayTimer > 0 then
        resolveTimer = resolveTimer + arg1;
        if resolveTimer >= 0.05 then
            resolveTimer = 0;
            local resolvedTex, resolvedLink, resolvedSlot = nil, nil, nil;

            -- 1. Try GetItemInfo
            if toastFrame.pendingQuery and GetItemInfo then
                local iName, iLink, iQual, _, _, _, _, equipLoc, itemTex = GetItemInfo(toastFrame.pendingQuery);
                if itemTex and itemTex ~= "" then
                    resolvedTex = itemTex;
                    resolvedLink = iLink;
                    if equipLoc and equipLoc ~= "" and getglobal(equipLoc) then
                        resolvedSlot = getglobal(equipLoc);
                    end
                    if iQual and QUALITY_COLORS[iQual] then
                        local qc = QUALITY_COLORS[iQual];
                        nameText:SetTextColor(qc[1], qc[2], qc[3]);
                        iconGlow:SetVertexColor(qc[1], qc[2], qc[3], 0.90);
                        toastFrame:SetBackdropBorderColor(qc[1], qc[2], qc[3], 0.95);
                    end
                end
            end

            -- 2. Try Bags or Inventory
            if (not resolvedTex) and toastFrame.pendingName then
                local bLink, bTex = FindItemInBagsOrInventory(toastFrame.pendingName);
                if bTex then
                    resolvedTex = bTex;
                    resolvedLink = bLink;
                end
            end

            -- 3. Apply resolved texture to both toast and run log
            if resolvedTex and resolvedTex ~= "" then
                iconTex:SetTexture(resolvedTex);
                if resolvedLink then toastFrame.itemLink = resolvedLink; end
                if resolvedSlot and subText:GetText() then
                    local currentSub = subText:GetText();
                    if string.find(currentSub, "New in", 1, true) or string.find(currentSub, "Neu", 1, true) then
                        subText:SetText(resolvedSlot .. " \194\183 |cff7dff7dNew in collection!|r");
                    else
                        subText:SetText(resolvedSlot);
                    end
                end

                -- Save to persistent cache
                if toastFrame.pendingName then
                    local cache = GetItemCache();
                    local lower = string.lower(toastFrame.pendingName);
                    cache[lower] = cache[lower] or {};
                    cache[lower].tex = resolvedTex;
                    if resolvedLink then cache[lower].link = resolvedLink; end

                    -- Update run loot entry if pending
                    for _, entry in ipairs(runLoot) do
                        if entry.name == toastFrame.pendingName then
                            entry.tex = resolvedTex;
                            if resolvedLink then entry.link = resolvedLink; end
                            break;
                        end
                    end
                    UpdateLootLog();
                end

                toastFrame.pendingQuery = nil;
                toastFrame.pendingName = nil;
            end
        end
    end
end);

-- ============================================================================
-- Main Show Routine
-- ============================================================================
function LootUI:ShowAlert(name, itemLink, texture, quality, slotLabel, isNew)
    if not name or name == "" then return; end
    if IsNeckPiece(name, itemLink, slotLabel) then return; end

    SuppressNativeLootNotice();

    local lowerName = string.lower(name);
    local cache = GetItemCache();

    -- Step 1: Pre-fill from Known Items dictionary
    if KNOWN_ITEMS[lowerName] then
        local entry = KNOWN_ITEMS[lowerName];
        if not texture or texture == "" then texture = entry.tex; end
        if not quality then quality = entry.q; end
        if (not slotLabel or slotLabel == "Boss Drop") and entry.slot and getglobal(entry.slot) then
            slotLabel = getglobal(entry.slot);
        end
    end

    -- Step 2: Pre-fill from Persistent Item Cache
    if cache[lowerName] then
        if (not texture or texture == "") and cache[lowerName].tex then
            texture = cache[lowerName].tex;
        end
        if (not itemLink or itemLink == "") and cache[lowerName].link then
            itemLink = cache[lowerName].link;
        end
    end

    -- Step 3: Check bags or equipped gear right now
    if not texture or texture == "" then
        local bLink, bTex = FindItemInBagsOrInventory(name);
        if bTex then
            texture = bTex;
            if bLink and not itemLink then itemLink = bLink; end
        end
    end

    -- Step 4: Try GetItemInfo
    local itemQuery = itemLink or name;
    if (not texture or texture == "") and itemQuery and GetItemInfo then
        local iName, iLink, iQual, _, _, _, _, equipLoc, itemTex = GetItemInfo(itemQuery);
        if itemTex and itemTex ~= "" then texture = itemTex; end
        if iLink and not itemLink then itemLink = iLink; end
        if iQual and not quality then quality = iQual; end
        if equipLoc and equipLoc ~= "" and getglobal(equipLoc) then
            slotLabel = getglobal(equipLoc);
        end
    end

    -- Step 5: Fallback to keyword icon (e.g. Pants -> INV_Pants_02, Helm -> INV_Helmet_06)
    local isFallback = false;
    if not texture or texture == "" then
        local fallbackIcon, fallbackSlot = GetKeywordFallbackIcon(name);
        texture = fallbackIcon;
        if not slotLabel or slotLabel == "Boss Drop" then slotLabel = fallbackSlot; end
        isFallback = true;
    end

    -- Quality Color
    quality = quality or 4; -- default Epic
    local qc = QUALITY_COLORS[quality] or QUALITY_COLORS[4];
    local r, g, b = qc[1], qc[2], qc[3];

    iconTex:SetTexture(texture);
    iconGlow:SetVertexColor(r, g, b, 0.90);
    toastFrame:SetBackdropBorderColor(r, g, b, 0.95);

    nameText:SetText(name);
    nameText:SetTextColor(r, g, b);

    local sub = slotLabel or "Boss Drop";
    if isNew then
        sub = sub .. " \194\183 |cff7dff7dNew in collection!|r";
    end
    subText:SetText(sub);

    toastFrame.itemName = name;
    toastFrame.itemLink = itemLink;
    toastFrame.itemQuality = quality;
    toastFrame.subDetail = sub;

    if isFallback or (not itemLink) then
        toastFrame.pendingQuery = itemLink or name;
        toastFrame.pendingName = name;
        resolveTimer = 0;
    else
        toastFrame.pendingQuery = nil;
        toastFrame.pendingName = nil;
    end

    displayTimer = DISPLAY_DURATION;
    toastFrame:SetAlpha(1.0);
    toastFrame:Show();

    -- Add to Left-Hand Run Loot Log
    AddRunLootEntry(name, itemLink, texture, quality, isNew);

    PlaySound("QUESTCOMPLETED");
end

-- ============================================================================
-- Chat Message Interception (ONLY True Enemy Boss Drops)
-- ============================================================================
local function ParseLootMessage(message)
    if type(message) ~= "string" then return; end

    -- STRICT GUARD: If player is currently picking an Augment or leveling up, IGNORE!
    if AZS_GetPhase then
        local phase = AZS_GetPhase();
        if phase == "choosing" or phase == "level_up" then
            return;
        end
    end

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
        if itemTex and itemTex ~= "" then texture = itemTex; end
        if iLink and not itemLink then itemLink = iLink; end
        if iQual and not hexColor then quality = iQual; end
        if equipLoc and equipLoc ~= "" and getglobal(equipLoc) then
            slotLabel = getglobal(equipLoc);
        end
    end

    if IsNeckPiece(name, itemLink, slotLabel) then return; end

    LootUI:ShowAlert(name, itemLink, texture, quality, slotLabel, isNew);
end

-- ============================================================================
-- Events & Initialization
-- ============================================================================
local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("CHAT_MSG_LOOT");
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM");
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
eventFrame:RegisterEvent("BAG_UPDATE");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("VARIABLES_LOADED");
eventFrame:RegisterEvent("CHAT_MSG_ADDON");

eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_SYSTEM" then
        -- Check for new run reset message
        if arg1 and (string.find(arg1, "Move to begin", 1, true) or string.find(arg1, "Betretet das Gebiet", 1, true)) then
            runLoot = {};
            UpdateLootLog();
        end
        ParseLootMessage(arg1);
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            -- ONLY quietly scan items into cache for tooltips/textures. NEVER trigger alerts on equip!
            ScanAllPlayerItems();
        end
    elseif event == "BAG_UPDATE" then
        ScanAllPlayerItems();
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == "AZSZONE" then
            -- Reset run loot log for new zone/run & suppress native loot
            runLoot = {};
            UpdateLootLog();
            SuppressNativeLootNotice();
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
        -- Restore saved positions
        if BordoUIDB and BordoUIDB.lootAlertPos and BordoUIDB.lootAlertPos.point then
            BordoUI:RestorePosition(toastFrame, BordoUIDB.lootAlertPos);
        else
            toastFrame:ClearAllPoints();
            toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -175);
        end
        PlaceLootLog();
        ScanAllPlayerItems();
        SuppressNativeLootNotice();
    end
end);

-- ============================================================================
-- Commands & Testing
-- ============================================================================
function BordoUI:ClearRunLoot()
    runLoot = {};
    UpdateLootLog();
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Cleared current run loot list.");
end

function BordoUI:TestLootAlert(kind)
    kind = string.lower(kind or "");
    if kind == "pants" or kind == "hosen" or kind == "legs" or kind == "beine" then
        LootUI:ShowAlert(
            "Wildheart Pants",
            "item:16678:0:0:0",
            "Interface\\Icons\\INV_Pants_02",
            4, -- Epic
            "Legs (Pants · Tier 0.5)",
            true
        );
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Previewed Boss Drop: |cffa335ee[Wildheart Pants]|r (Legs).");
    elseif kind == "helm" or kind == "kopf" or kind == "head" then
        LootUI:ShowAlert(
            "Crown of Destruction",
            "item:18817:0:0:0",
            "Interface\\Icons\\INV_Helmet_08",
            4, -- Epic
            "Head (Crown)",
            false
        );
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Previewed Boss Drop: |cffa335ee[Crown of Destruction]|r (Head).");
    else
        LootUI:ShowAlert(
            "Band of Accuria",
            "item:17063:0:0:0",
            "Interface\\Icons\\INV_Jewelry_Ring_15",
            4, -- Epic
            "Finger (Ring · Rank IV)",
            true
        );
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Previewed Boss Drop: |cffa335ee[Band of Accuria]|r (Ring). Try '/bordo testloot pants' for pants.");
    end
end
