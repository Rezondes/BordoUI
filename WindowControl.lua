-- Bordo UI: persistent per-window visibility controls.
BordoUI = BordoUI or {};

local windows = {
    { key = "hud", label = "Combat HUD", frame = "SurvivorUIRow" },
    { key = "stats", label = "Stats", frame = "BordoUI_StatsWindowFrame" },
    { key = "crit", label = "Highest Crit", frame = "BordoUI_HighestCritFrame" },
    { key = "table", label = "Attack Stats Table", frame = "AZSHelper_StatsTableFrame" },
    { key = "boss", label = "Boss Tracker", frame = "BordoUI_BossTrackerFrame" },
    { key = "bossbar", label = "Boss Encounter Bar", frame = "AZSHelper_BossEncounterContainer" },
    { key = "build", label = "Build & Jewelry", frame = "SurvivorUIBuild" },
    { key = "party", label = "Party Frames", frame = "SurvivorUIParty" },
    { key = "kills", label = "Kills & Gold", frame = "AZSHelper_TallyFrame" },
    { key = "meter", label = "Damage Meter", frame = "BordoUIMeter" },
    { key = "dock", label = "Minimap Buttons", frame = "BordoUI_MinimapDock" },
    { key = "chat", label = "Chat Box", frame = "BordoUI_ChatBox" },
    { key = "procs", label = "Procs & Buffs", frame = "BordoUI_ProcTrackerFrame" },
    { key = "plates", label = "Nameplate Settings", frame = "BordoUI_NameplatesWindow" },
    { key = "damage", label = "Damage Text Settings", frame = "BordoUI_DamageNumbersFrame" },
    { key = "lowhp", label = "Low-Health Warning", frame = "BordoUI_LowHealthFrame" },
    { key = "character", label = "Character Panel", frame = "SurvivorUICharacter" },
    { key = "death", label = "Death Recap", frame = "AZSHelper_DeathRecapFrame", transient = true },
    { key = "runrecap", label = "Run Summary", frame = "BordoUI_RunRecapFrame", transient = true },
    { key = "loot", label = "Loot Alert", frame = "BordoUI_LootAlertFrame", transient = true }
};

-- The dock panel intentionally exposes only the windows requested by the user.
local panelWindows = {
    { key = "stats", label = "Stats", frame = "BordoUI_StatsWindowFrame" },
    { key = "crit", label = "Highest Crit", frame = "BordoUI_HighestCritFrame" },
    { key = "build", label = "Build & Jewelry", frame = "SurvivorUIBuild" },
    { key = "chat", label = "Chat Box", frame = "BordoUI_ChatBox" },
    { key = "death", label = "Death Recap", frame = "AZSHelper_DeathRecapFrame", transient = true },
    { key = "runrecap", label = "Run Summary", frame = "BordoUI_RunRecapFrame", transient = true },
    { key = "loot", label = "Loot Alert", frame = "BordoUI_LootAlertFrame", transient = true }
};

local byKey = {};
for i = 1, table.getn(windows) do
    byKey[windows[i].key] = windows[i];
end

local function Saved()
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.windowEnabled = BordoUIDB.windowEnabled or {};
    return BordoUIDB.windowEnabled;
end

local function SetWindow(def, enabled, quiet)
    local states = Saved();
    states[def.key] = enabled and true or false;
    if def.key == "stats" then BordoUIDB.showStats = enabled and true or false; end
    if def.key == "crit" then BordoUIDB.showHighestCrit = enabled and true or false; end
    if def.key == "table" then BordoUIDB.statsTable = enabled and true or false; end
    if def.key == "meter" then BordoUIDB.meter = enabled and true or false; end

    local frame = getglobal(def.frame);
    if frame then
        if enabled then
            if not def.transient then frame:Show(); end
        else
            frame:Hide();
        end
    end
    if not quiet and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: " .. def.label .. " " .. (enabled and "|cff55ff55enabled|r." or "|cffff5555disabled|r."));
    end
end

-- Public API used by the minimap Windows panel.
function BordoUI:GetWindowControlList()
    return panelWindows;
end

function BordoUI:IsWindowEnabled(key)
    return Saved()[key] ~= false;
end

function BordoUI:SetWindowEnabled(key, enabled)
    local def = byKey[key];
    if not def then return false; end
    SetWindow(def, enabled and true or false, true);
    if BordoUI.RefreshWindowsPanel then BordoUI:RefreshWindowsPanel(); end
    return true;
end

local function CreateWindowsPanel()
    if BordoUI_WindowsPanel then return BordoUI_WindowsPanel; end

    local panel = CreateFrame("Frame", "BordoUI_WindowsPanel", UIParent);
    panel:SetWidth(470);
    panel:SetHeight(220);
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    panel:SetFrameStrata("DIALOG");
    panel:SetToplevel(true);
    panel:EnableMouse(true);
    panel:SetMovable(true);
    panel:RegisterForDrag("LeftButton");
    panel:SetScript("OnDragStart", function() this:StartMoving(); end);
    panel:SetScript("OnDragStop", function() this:StopMovingOrSizing(); end);
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    panel:SetBackdropColor(0.02, 0.02, 0.02, 0.94);

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -13);
    title:SetText("Bordo UI - Windows");
    title:SetTextColor(0, 0.8, 1);

    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton");
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3);
    close:SetScript("OnClick", function() panel:Hide(); end);

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6);
    hint:SetText("Click ON/OFF to show or hide an individual window. Changes are saved.");
    hint:SetTextColor(0.8, 0.8, 0.8);

    panel.windowRows = {};
    for i = 1, table.getn(panelWindows) do
        local def = panelWindows[i];
        local col = i > 4 and 2 or 1;
        local row = i > 4 and (i - 4) or i;
        local x = col == 1 and 16 or 247;
        local y = -62 - ((row - 1) * 30);

        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y);
        label:SetWidth(145);
        label:SetJustifyH("LEFT");
        label:SetText(def.label);

        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate");
        button:SetWidth(52);
        button:SetHeight(22);
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", x + 151, y + 4);
        button.windowKey = def.key;
        button:SetScript("OnClick", function()
            local key = this.windowKey;
            BordoUI:SetWindowEnabled(key, not BordoUI:IsWindowEnabled(key));
        end);
        panel.windowRows[i] = { key = def.key, button = button };
    end

    if not UISpecialFrames then UISpecialFrames = {}; end
    table.insert(UISpecialFrames, "BordoUI_WindowsPanel");
    panel:Hide();
    return panel;
end

function BordoUI:RefreshWindowsPanel()
    local panel = CreateWindowsPanel();
    for i = 1, table.getn(panel.windowRows) do
        local row = panel.windowRows[i];
        if self:IsWindowEnabled(row.key) then
            row.button:SetText("ON");
            row.button:GetFontString():SetTextColor(0.3, 1, 0.3);
        else
            row.button:SetText("OFF");
            row.button:GetFontString():SetTextColor(1, 0.35, 0.35);
        end
    end
end

function BordoUI:ToggleWindowsPanel()
    local panel = CreateWindowsPanel();
    self:RefreshWindowsPanel();
    if panel:IsShown() then panel:Hide(); else panel:Show(); end
end

local function ListWindows()
    local states = Saved();
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI window controls|r (default: on):");
    for i = 1, table.getn(panelWindows) do
        local def = panelWindows[i];
        local status = states[def.key] == false and "|cffff5555off|r" or "|cff55ff55on|r";
        DEFAULT_CHAT_FRAME:AddMessage("  " .. def.key .. " - " .. def.label .. ": " .. status);
    end
    DEFAULT_CHAT_FRAME:AddMessage("Use |cffffd100/bordo window <name> [on|off]|r to change one.");
end

function BordoUI:HandleWindowCommand(value)
    local _, _, name, action = string.find(string.lower(value or ""), "^(%a+)%s*(%a*)$");
    if not name or name == "" or name == "list" then
        ListWindows();
        return;
    end
    if name == "highestcrit" then name = "crit"; end
    if name == "attack" then name = "table"; end
    if name == "lowhealth" then name = "lowhp"; end
    if name == "nameplates" or name == "nameplate" then name = "plates"; end
    if name == "bosshealth" then name = "bossbar"; end
    if name == "combat" then name = "hud"; end
    if name == "gold" or name == "tally" then name = "kills"; end
    if name == "buffs" or name == "proc" then name = "procs"; end
    local def = byKey[name];
    if not def then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Unknown window. Type |cffffd100/bordo window list|r.");
        return;
    end
    local enabled;
    if action == "on" then
        enabled = true;
    elseif action == "off" then
        enabled = false;
    elseif action == "" then
        enabled = Saved()[name] == false;
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /bordo window <name> [on|off]");
        return;
    end
    SetWindow(def, enabled);
end

-- Keep disabled panels hidden if their own update loop tries to show them again.
local watcher = CreateFrame("Frame", "BordoUI_WindowVisibilityWatcher");
watcher:SetScript("OnUpdate", function()
    local states = Saved();
    for i = 1, table.getn(windows) do
        local def = windows[i];
        if states[def.key] == false then
            local frame = getglobal(def.frame);
            if frame and frame:IsShown() then frame:Hide(); end
        end
    end
end);
