--[[

    Bordo UI - Core (Core.lua)

    World of Warcraft 1.12.1 / Azeroth Survivors

    Modern UI Suite by Bordo

]]--

BordoUI = {};

AZSHelper = BordoUI; -- Backwards compatibility alias

BordoUI.version = "2.3.0";

-- Unit & Mob Tooltip Relocation: Anchor world/unit/add tooltips to bottom-left next to ChatFrame1

local tipAnchor = CreateFrame("Frame", "BordoUI_TooltipAnchor", UIParent);

tipAnchor:SetWidth(200);

tipAnchor:SetHeight(80);

tipAnchor:SetPoint("BOTTOMLEFT", ChatFrame1 or UIParent, "BOTTOMRIGHT", 12, 0);

tipAnchor:SetMovable(true);

tipAnchor:SetClampedToScreen(true);

tipAnchor:EnableMouse(false);

BordoUI.tipAnchor = tipAnchor;

local function PlaceTooltip(tooltip)

	tooltip:ClearAllPoints();

	if ( BordoUIDB and BordoUIDB.tooltipPos and BordoUIDB.tooltipPos.point ) then

		BordoUI:RestorePosition(tooltip, BordoUIDB.tooltipPos);

	elseif ( ChatFrame1 ) then

		tooltip:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 12, 0);

	else

		tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 406, 26);

	end

end

local orig_GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor;

function GameTooltip_SetDefaultAnchor(tooltip, parent)

	tooltip:SetOwner(parent, "ANCHOR_NONE");

	PlaceTooltip(tooltip);

	tooltip.default = 1;

end

if ( updateContainerFrameAnchors ) then

	local orig_updateContainerFrameAnchors = updateContainerFrameAnchors;

	updateContainerFrameAnchors = function()

		orig_updateContainerFrameAnchors();

		if ( GameTooltip:IsShown() and GameTooltip.default ) then

			PlaceTooltip(GameTooltip);

		end

	end

end

-- Default Settings

local defaults = {

    dmgScale   = 0.75,

    tableScale = 0.80,

    collapsed  = false,

    locked     = false, -- Global UI window lock

    statsPos   = nil, -- Defaults to docked cleanly to the right of Multipliers panel

    multPanelPos = { point = "TOPLEFT", relativePoint = "TOPLEFT", x = 12, y = -120 },

    centerHudPos = { point = "BOTTOM", relativePoint = "BOTTOM", x = 0, y = 200 },

    deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 },

    encounterBarsPos = { point = "TOP", relativePoint = "TOP", x = 0, y = -55 },

    tallyPos = nil, -- Defaults to centered under combat HUD

    microDockPos = nil, -- Defaults to bottom-right corner

    chatPos = { point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT", x = 14, y = 26 },

    partyPos = { point = "TOPLEFT", relativePoint = "TOPLEFT", x = 142, y = -120 },

    showParty = true,

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

-- Frame Movement & Lock Utility

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

function BordoUI:SetLocked(locked)

    if ( not BordoUIDB ) then return; end

    BordoUIDB.locked = locked and true or false;

    if ( BordoUI.UpdateLockState ) then

        BordoUI:UpdateLockState();

    end

    if ( BordoUI.UpdatePartyFrames ) then

        BordoUI:UpdatePartyFrames();

    end

    if ( BordoUI.UpdateAllLockButtons ) then

        BordoUI:UpdateAllLockButtons();

    end

    if ( BordoUIDB.locked ) then

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: All UI windows are now |cffff3333[LOCKED]|r. Dragging is disabled.");

    else

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: All UI windows are now |cff55ff55[UNLOCKED]|r. You can freely drag and reposition Chat, Stats, Boss Bars, Damage Meter, Build & Minimap buttons.");

    end

end

function BordoUI:ToggleLock()

    local newState = not (BordoUIDB and BordoUIDB.locked);

    BordoUI:SetLocked(newState);

    return newState;

end

-- =========================================================================

-- Universal Window Lock Button Engine

-- =========================================================================

BordoUI.LockButtons = {};

function BordoUI:UpdateAllLockButtons()

    local isLocked = (BordoUIDB and BordoUIDB.locked);

    for i = 1, table.getn(BordoUI.LockButtons) do

        local btn = BordoUI.LockButtons[i];

        if btn and btn.tex then

            if isLocked then

                btn.tex:SetTexture("Interface\\AddOns\\BordoUI\\Art\\Lock.tga");

                btn.tex:SetVertexColor(0.85, 0.85, 0.85, 0.85);

            else

                btn.tex:SetTexture("Interface\\AddOns\\BordoUI\\Art\\Unlock.tga");

                btn.tex:SetVertexColor(0.30, 1.00, 0.40, 1.00);

            end

        end

    end

end

function BordoUI:AttachLockButton(parent, anchorPoint, relFrame, relPoint, x, y)

    if not parent then return nil; end

    local btn = CreateFrame("Button", nil, parent);

    btn:SetWidth(15);

    btn:SetHeight(15);

    btn:SetPoint(anchorPoint or "TOPRIGHT", relFrame or parent, relPoint or "TOPRIGHT", x or -4, y or -4);

    btn:SetFrameLevel((parent:GetFrameLevel() or 5) + 12);

    

    local tex = btn:CreateTexture(nil, "OVERLAY");

    tex:SetAllPoints(btn);

    btn.tex = tex;

    

    btn:SetScript("OnClick", function()

        BordoUI:ToggleLock();

    end);

    

    

    table.insert(BordoUI.LockButtons, btn);

    BordoUI:UpdateAllLockButtons();

    return btn;

end

-- Event Listener Frame

local eventFrame = CreateFrame("Frame", "BordoUI_CoreEventFrame");

eventFrame:RegisterEvent("VARIABLES_LOADED");

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

eventFrame:SetScript("OnEvent", function()

    if ( event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" ) then

        InitDB();

        if ( BordoUI.UpdateAllLockButtons ) then

            BordoUI:UpdateAllLockButtons();

        end

        if ( event == "PLAYER_ENTERING_WORLD" ) then

            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r loaded (Modern UI Suite, Miniboss Timer, Chest Radar & Boss Highlight). Type |cffffd100/bordo|r or |cffffd100/azs|r.");

            BordoUI:ApplyMaxCameraDistance();

            if ( BordoUI.ApplyModernDamageText ) then

                BordoUI:ApplyModernDamageText();

            end

            if ( BordoUI.ApplySquareMinimapStyle ) then

                BordoUI:ApplySquareMinimapStyle();

            end

            if ( BordoUI.UpdateLockState ) then

                BordoUI:UpdateLockState();

            end

            if ( ChatFrame1 and BordoUIDB and BordoUIDB.chatPos ) then

                BordoUI:RestorePosition(ChatFrame1, BordoUIDB.chatPos);

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

            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Floating combat text scale set to %.0f%%.", num * 100));

        else

            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Usage: /bordo dmg 0.75 (value between 0.4 and 1.5)");

        end

    elseif ( cmd == "size" or cmd == "table" ) then

        local num = tonumber(val);

        if ( num and num >= 0.4 and num <= 1.5 ) then

            if ( BordoUI.SetTableScale ) then

                BordoUI:SetTableScale(num);

            end

            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Stats table scale set to %.0f%%.", num * 100));

        else

            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Usage: /bordo size 0.75 (value between 0.4 and 1.5)");

        end

    elseif ( cmd == "death" or cmd == "recap" or cmd == "tod" ) then

        if ( BordoUI.ShowDeathRecap ) then

            BordoUI:ShowDeathRecap();

        end

    elseif ( cmd == "boss" or cmd == "timer" ) then

        if ( AZSHelper_BossSchedulePanel ) then

            if ( AZSHelper_BossSchedulePanel:IsShown() ) then

                AZSHelper_BossSchedulePanel:Hide();

                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss timer list hidden.");

            else

                AZSHelper_BossSchedulePanel:Show();

                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss timer list shown.");

            end

        end

    elseif ( cmd == "test" or cmd == "preview" ) then

        BordoUI.TestBossPreview = not BordoUI.TestBossPreview;

        local st = BordoUI.TestBossPreview and "enabled (Hogger test boss)" or "disabled";

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Boss HP preview " .. st .. ".");

    elseif ( cmd == "zoom" or cmd == "cam" or cmd == "camera" ) then

        BordoUI:ApplyMaxCameraDistance();

        local yards = tonumber(val) or 35;

        pcall(CameraZoomOut, yards);

        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: Max camera zoom unlocked (factor 4 / 50 yards). Zoomed out by %d yards. You can now zoom out further using your mouse wheel!", yards));

    elseif ( cmd == "party" or cmd == "group" ) then

        if ( BordoUI.TogglePartyFrames ) then

            BordoUI:TogglePartyFrames(val);

        end

    elseif ( cmd == "plates" or cmd == "nameplates" or cmd == "teammates" ) then

        if ( BordoUI.EnsureNameplates ) then

            BordoUI:EnsureNameplates();

        else

            if ( ShowFriendNameplates ) then pcall(ShowFriendNameplates); end

            if ( ShowNameplates ) then pcall(ShowNameplates); end

        end

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Teammate & enemy nameplates enabled (Friendly vibrant green / Enemy red)!");

    elseif ( cmd == "lock" ) then

        BordoUI:ToggleMoveMode(false);

        BordoUI:SetLocked(true);

    elseif ( cmd == "unlock" ) then

        BordoUI:SetLocked(false);

        BordoUI:ToggleMoveMode(true);

    elseif ( cmd == "move" or cmd == "togglelock" ) then

        BordoUI:ToggleMoveMode();

    elseif ( cmd == "help" ) then

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI Commands:|r");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo|r - Toggle Attack Stats Table");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo party|r - Toggle Modern Party Frames (/bordo party test)");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo plates|r - Force-enable Teammate (green) & Enemy nameplates");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo lock|r - Lock all UI windows (disables dragging)");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo unlock|r - Unlock all UI windows (freely drag & reposition)");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo move|r - Toggle lock / unlock state");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo reset|r - Reset all window positions to defaults");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo recap|r - View Death Recap & Recent Damage");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo dmg <0.4-1.5>|r - Set floating damage font scale");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo size <0.4-1.5>|r - Set stats table scale");

        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100/bordo zoom [yards]|r - Unlock & set max camera distance");

    elseif ( cmd == "reset" ) then

        BordoUI:ResetToDefaultLayout();

    elseif ( cmd == "chest" or cmd == "chests" or cmd == "cl" or cmd == "kiste" or cmd == "kisten" ) then

        if ( SlashCmdList["AZSCHESTLIGHT"] ) then

            SlashCmdList["AZSCHESTLIGHT"](val);

        end

    else

        -- Toggle Stats Table

        if ( AZSHelper_StatsTableFrame ) then

            if ( AZSHelper_StatsTableFrame:IsShown() ) then

                AZSHelper_StatsTableFrame:Hide();

                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Stats table hidden.");

            else

                if ( AZSHelper.AnchorStatsTableToMultipliers ) then

                    AZSHelper:AnchorStatsTableToMultipliers();

                end

                AZSHelper_StatsTableFrame:Show();

                DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Stats table shown.");

            end

        end

    end

end;

-- Standalone Slash Commands for Locking / Unlocking

SLASH_BORDOLOCK1 = "/lock";

SlashCmdList["BORDOLOCK"] = function()

    BordoUI:SetLocked(true);

end;

SLASH_BORDOUNLOCK1 = "/unlock";

SlashCmdList["BORDOUNLOCK"] = function()

    BordoUI:SetLocked(false);

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

-- Lair Marks Helpers (used by BossTracker, MapPins, Guardians)

local MARK_KINDS = 8;

local MARK_NAMES = { "Crossed swords", "Shield", "Crown", "Chalice", "Fleur-de-lis", "War hammer", "Tower", "Helm" };

function SurvivorUI_LairMarks(lairs)

    local marks = {};

    lairs = lairs or (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};

    local places = {};

    for index = 1, table.getn(lairs) do

        local l = lairs[index];

        local idx = (l and (l.index or l[1])) or index;

        table.insert(places, tonumber(idx) or index);

    end

    table.sort(places);

    for rank = 1, table.getn(places) do

        marks[places[rank]] = math.mod(rank - 1, MARK_KINDS) + 1;

    end

    return marks;

end

function SurvivorUI_SetLairMark(texture, mark, dim)

    if ( not mark or not texture ) then

        if ( texture ) then texture:Hide(); end

        return;

    end

    local column = math.mod(mark - 1, 4);

    local line = math.floor((mark - 1) / 4);

    texture:SetTexture("Interface\\AddOns\\BordoUI\\Art\\LairMarks");

    texture:SetTexCoord(column / 4, (column + 1) / 4, line / 2, (line + 1) / 2);

    if ( dim ) then

        texture:SetVertexColor(0.5, 0.5, 0.5, 0.8);

    else

        texture:SetVertexColor(1, 1, 1, 1);

    end

    texture:Show();

end

function SurvivorUI_LairMarkName(mark)

    return mark and MARK_NAMES[mark] or nil;

end

-- =========================================================================

-- Visual Move Mode & Universal Layout System

-- =========================================================================

BordoUI.MoveOverlays = {};

local function CreateMoveOverlay(targetFrame, labelText, saveFunc)

    if ( not targetFrame ) then return nil; end

    local overlay = CreateFrame("Button", nil, UIParent);

    overlay:SetFrameStrata("TOOLTIP");

    overlay:SetFrameLevel(100);

    overlay:SetAllPoints(targetFrame);

    

    overlay:SetBackdrop({

        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",

        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",

        tile     = true,

        tileSize = 8,

        edgeSize = 8,

        insets   = { left = 1, right = 1, top = 1, bottom = 1 }

    });

    overlay:SetBackdropColor(0.10, 0.45, 0.90, 0.40);

    overlay:SetBackdropBorderColor(0.20, 0.85, 1.00, 1.00);

    local txt = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight");

    txt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");

    txt:SetPoint("CENTER", overlay, "CENTER", 0, 0);

    txt:SetTextColor(1, 1, 1, 1);

    txt:SetText(labelText);

    overlay.text = txt;

    overlay:EnableMouse(true);

    overlay:RegisterForDrag("LeftButton");

    overlay:SetScript("OnDragStart", function()

        targetFrame:StartMoving();

    end);

    overlay:SetScript("OnDragStop", function()

        targetFrame:StopMovingOrSizing();

        if ( saveFunc ) then saveFunc(targetFrame); end

    end);

    overlay:Hide();

    return overlay;

end

function BordoUI:ToggleMoveMode(enable)

    if ( enable == nil ) then

        enable = not BordoUI.moveModeActive;

    end

    BordoUI.moveModeActive = enable;

    if ( not BordoUI.controlBar ) then

        local bar = CreateFrame("Frame", "BordoUI_MoveControlBar", UIParent);

        bar:SetWidth(340);

        bar:SetHeight(34);

        bar:SetPoint("TOP", UIParent, "TOP", 0, -25);

        bar:SetFrameStrata("TOOLTIP");

        bar:SetFrameLevel(105);

        bar:SetBackdrop({

            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",

            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",

            tile     = true,

            tileSize = 8,

            edgeSize = 8,

            insets   = { left = 2, right = 2, top = 2, bottom = 2 }

        });

        bar:SetBackdropColor(0.04, 0.04, 0.06, 0.95);

        bar:SetBackdropBorderColor(1.00, 0.82, 0.00, 1.00);

        local lockBtn = CreateFrame("Button", nil, bar);

        lockBtn:SetWidth(150);

        lockBtn:SetHeight(22);

        lockBtn:SetPoint("LEFT", bar, "LEFT", 8, 0);

        lockBtn:SetBackdrop({

            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",

            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",

            edgeSize = 6,

        });

        lockBtn:SetBackdropColor(0.12, 0.35, 0.15, 0.90);

        lockBtn:SetBackdropBorderColor(0.30, 0.95, 0.30, 0.90);

        local lTxt = lockBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");

        lTxt:SetPoint("CENTER", lockBtn, "CENTER", 0, 0);

        lTxt:SetText("Lock All Windows");

        lockBtn:SetScript("OnClick", function()

            BordoUI:ToggleMoveMode(false);

            BordoUI:SetLocked(true);

        end);

        local resetBtn = CreateFrame("Button", nil, bar);

        resetBtn:SetWidth(150);

        resetBtn:SetHeight(22);

        resetBtn:SetPoint("RIGHT", bar, "RIGHT", -8, 0);

        resetBtn:SetBackdrop({

            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",

            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",

            edgeSize = 6,

        });

        resetBtn:SetBackdropColor(0.35, 0.15, 0.15, 0.90);

        resetBtn:SetBackdropBorderColor(0.95, 0.30, 0.30, 0.90);

        local rTxt = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");

        rTxt:SetPoint("CENTER", resetBtn, "CENTER", 0, 0);

        rTxt:SetText("Reset Default Layout");

        resetBtn:SetScript("OnClick", function()

            BordoUI:ResetToDefaultLayout();

        end);

        BordoUI.controlBar = bar;

    end

    local targets = {

        { frame = SurvivorUIRow, name = "Combat HUD (Drag Me)", key = "hudPos" },

        { frame = BordoUI_StatsWindowFrame, name = "Stats Window (Drag Me)", key = "statsPos" },

        { frame = BordoUI_BossTrackerFrame or AZSHelper_BossSchedulePanel, name = "Boss Tracker (Drag Me)", key = "bossTrackerPos" },

        { frame = SurvivorUIBuild, name = "Build & Jewelry (Drag Me)", key = "buildPos" },

        { frame = SurvivorUIParty, name = "Party Frames (Drag Me)", key = "partyPos" },

        { frame = AZSHelper_TallyFrame, name = "Kills & Gold (Drag Me)", key = "tallyPos" },

        { frame = BordoUI_MinimapDock, name = "Minimap Action Buttons (Drag Me)", key = "minimapDockPos" },

        { frame = BordoUI_ChatBox, name = "Chat Box (Drag Me)", key = "chatPos" },

        { frame = AZSHelper_StatsTableFrame, name = "Damage Meter (Drag Me)", key = "statsPos" },

		{ frame = BordoUI_TooltipAnchor, name = "Mob Tooltip (Drag Me)", key = "tooltipPos" },

    };

    for i = 1, table.getn(targets) do

        local t = targets[i];

        if ( t.frame ) then

            if ( not BordoUI.MoveOverlays[i] ) then

                BordoUI.MoveOverlays[i] = CreateMoveOverlay(t.frame, t.name, function(f)

                    local pt, _, relPt, x, y = f:GetPoint();

                    BordoUIDB = BordoUIDB or {};

                    BordoUIDB[t.key] = { point = pt, relativePoint = relPt, x = x, y = y };

                end);

            end

            if ( enable ) then

                BordoUI.MoveOverlays[i]:ClearAllPoints();

                BordoUI.MoveOverlays[i]:SetAllPoints(t.frame);

                BordoUI.MoveOverlays[i]:Show();

            else

                BordoUI.MoveOverlays[i]:Hide();

            end

        end

    end

    if ( enable ) then

        BordoUI.controlBar:Show();

        BordoUIDB.locked = false;

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Move Mode |cff55ff55[ACTIVE]|r. Drag any colored box to reposition. Click |cffffd100[Lock All Windows]|r or type |cffffd100/lock|r when done.");

    else

        BordoUI.controlBar:Hide();

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Move Mode |cffff3333[OFF]|r. All window positions saved.");

    end

end

function BordoUI:ResetToDefaultLayout()

    BordoUIDB = BordoUIDB or {};

    BordoUIDB.hudPos = nil;

    BordoUIDB.statsPos = nil;

    BordoUIDB.bossTrackerPos = nil;

    BordoUIDB.buildLeft = nil;

    BordoUIDB.buildTop = nil;

    BordoUIDB.buildPos = nil;

    BordoUIDB.partyLeft = nil;

    BordoUIDB.partyBottom = nil;

    BordoUIDB.partyPos = nil;

    BordoUIDB.bottomBarPos = nil;

    BordoUIDB.tallyPos = nil;

    BordoUIDB.microDockPos = nil;

	BordoUIDB.tooltipPos = nil;

    BordoUIDB.centerHudPos = nil;

    BordoUIDB.multPanelPos = nil;

    if ( AZSHelperDB ) then

        AZSHelperDB.rowPos = nil;

        AZSHelperDB.bottomBarPos = nil;

        AZSHelperDB.tallyPos = nil;

        AZSHelperDB.microDockPos = nil;

		AZSHelperDB.tooltipPos = nil;

        AZSHelperDB.centerHudPos = nil;

    end

	if ( BordoUI_TooltipAnchor ) then

		BordoUI_TooltipAnchor:ClearAllPoints();

		if ( ChatFrame1 ) then

			BordoUI_TooltipAnchor:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 12, 0);

		else

			BordoUI_TooltipAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 406, 26);

		end

	end

    if ( BordoUI_ResetThemeUI ) then BordoUI_ResetThemeUI(); end

    if ( StatsUI and StatsUI.ResetPosition ) then StatsUI:ResetPosition(); end

    if ( TrackerUI and TrackerUI.ResetPosition ) then TrackerUI:ResetPosition(); end

    if ( BordoUI_ResetBuildPosition ) then BordoUI_ResetBuildPosition(); end

    if ( BordoUI_ResetPartyPosition ) then BordoUI_ResetPartyPosition(); end

    if ( ChatFrame1 ) then

        ChatFrame1:ClearAllPoints();

        ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 12, 16);

    end

    if ( Minimap ) then

        Minimap:ClearAllPoints();

        Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -12);

    end

    if ( BordoUI.moveModeActive ) then

        BordoUI:ToggleMoveMode(true);

    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: All UI windows reset to standard layout matching reference screenshot!");

end

