--[[
    Bordo UI - Modern Stats Window (StatsWindow.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    Faithfully reproduces the modern 4-section Stats window from reference:
    - 1. Offense (Crit, Crit Dmg, Damage, Haste, Echo)
    - 2. Defense (Health, Regen, Lifesteal, Armor, Kill Heal, Thorns, Lives)
    - 3. Reach (Area, Targets, Pickup)
    - 4. Utility (Speed, Experience, Gold, Luck, Buff Power)
    Sits permanently on screen during runs (no need to press 'C'), draggable, saved position.
]]--
BordoUI = BordoUI or {};
local StatsUI = {};
BordoUI.StatsWindow = StatsUI;
local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local SECTIONS = {
    {
        title = "Offense",
        color = { 1.00, 0.45, 0.25 },
        rows = {
            { key = "crit", label = "Crit", desc = "The chance a spell strikes critically. Past 100%, the rest adds to critical damage.",
              fmt = function(s) return string.format("%.1f%%", (tonumber(s.crit) or 0) * 100); end, gearKey = "gcrit" },
            { key = "cm", label = "Crit Dmg", desc = "A critical strike deals this much of a spell's damage.",
              fmt = function(s) return string.format("%.0f%%", (tonumber(s.cm) or 2) * 100); end, gearKey = "gcm" },
            { key = "dmg", label = "Damage", desc = "Every spell you cast deals this much more damage. Grows with level, gear, talents, jewelry and buffs.",
              fmt = function(s) return string.format("%+.0f%%", ((tonumber(s.dmg) or 1) - 1) * 100); end, gearKey = "gdmg" },
            { key = "cd", label = "Haste", desc = "Your spells recover this much faster / cooldowns reduced.",
              fmt = function(s) return string.format("%+.0f%%", (1 - (tonumber(s.cd) or 1)) * 100); end, gearKey = "gcd" },
            { key = "echo", label = "Echo", desc = "The chance a spell strikes twice. Past 100%, every spell strikes twice and the rest is the chance of a third.",
              fmt = function(s) return string.format("%.0f%%", (tonumber(s.echo) or 0) * 100); end, gearKey = "gecho" },
        }
    },
    {
        title = "Defense",
        color = { 0.30, 0.65, 1.00 },
        rows = {
            { key = "hp", label = "Health", desc = "The maximum health you can have.",
              fmt = function(s) return string.format("%.0f", tonumber(s.hp) or UnitHealthMax("player") or 100); end, gearKey = "ghp" },
            { key = "reg", label = "Regen", desc = "Health you regain every second.",
              fmt = function(s) return string.format("%.1f", tonumber(s.reg) or 0); end, gearKey = "greg" },
            { key = "lch", label = "Lifesteal", desc = "Heals you for this much of all damage you deal.",
              fmt = function(s) return string.format("%.1f%%", (tonumber(s.lch) or 0) * 100); end, gearKey = "glch" },
            { key = "arm", label = "Armor", desc = "Damage you take is reduced by this much (60% at most).",
              fmt = function(s) return string.format("%.0f%%", (tonumber(s.arm) or 0) * 100); end, gearKey = "garm" },
            { key = "heal", label = "Kill Heal", desc = "Every kill heals you for this much.",
              fmt = function(s) return string.format("%.0f", tonumber(s.heal) or 0); end, gearKey = "gheal" },
            { key = "thn", label = "Thorns", desc = "This much of the melee damage you take is dealt back to the attacker.",
              fmt = function(s) return string.format("%.0f%%", (tonumber(s.thn) or 0) * 100); end, gearKey = "gthn" },
            { key = "liv", label = "Lives", desc = "Times you rise again instead of dying.",
              fmt = function(s) return string.format("%d", tonumber(s.liv) or (AZS_RUN and AZS_RUN.lives) or 0); end },
        }
    },
    {
        title = "Reach",
        color = { 0.72, 0.45, 1.00 },
        rows = {
            { key = "area", label = "Area", desc = "Your spells' areas, radiuses and ranges are this much larger.",
              fmt = function(s) return string.format("%+.0f%%", ((tonumber(s.area) or 1) - 1) * 100); end, gearKey = "garea" },
            { key = "cnt", label = "Targets", desc = "Every spell that picks its targets picks this many more.",
              fmt = function(s) return string.format("+%d", tonumber(s.cnt) or 0); end, gearKey = "gcnt" },
            { key = "pick", label = "Pickup", desc = "Experience and gold fly to you from this far.",
              fmt = function(s) return string.format("%.0f yd", tonumber(s.pick) or 9); end, gearKey = "gpick" },
        }
    },
    {
        title = "Utility",
        color = { 0.35, 0.90, 0.55 },
        rows = {
            { key = "spd", label = "Speed", desc = "You run this much faster.",
              fmt = function(s) return string.format("%+.0f%%", ((tonumber(s.spd) or 1) - 1) * 100); end, gearKey = "gspd" },
            { key = "xp", label = "Experience", desc = "You gain this much more experience.",
              fmt = function(s) return string.format("%+.0f%%", ((tonumber(s.xp) or 1) - 1) * 100); end, gearKey = "gxp" },
            { key = "gold", label = "Gold", desc = "You find this much more gold.",
              fmt = function(s) return string.format("%+.0f%%", ((tonumber(s.gold) or 1) - 1) * 100); end, gearKey = "ggold" },
            { key = "luck", label = "Luck", desc = "Better odds of rarer upgrades when you level up.",
              fmt = function(s) return string.format("%+.0f%%", (tonumber(s.luck) or 0) * 100); end, gearKey = "gluck" },
            { key = "bp", label = "Buff Power", desc = "Your damage, haste, shield and thorns buffs are this much stronger.",
              fmt = function(s) return string.format("%+.0f%%", (tonumber(s.bp) or 0) * 100); end, gearKey = "gbp" },
        }
    }
};
local function CreateLine(parent, r, g, b, a)
    local line = parent:CreateTexture(nil, "ARTWORK");
    line:SetTexture(FLAT);
    line:SetVertexColor(r, g, b, a or 1);
    return line;
end
-- Initialize the Main Stats Frame
local frame = CreateFrame("Frame", "BordoUI_StatsWindowFrame", UIParent);
StatsUI.frame = frame;
frame:SetWidth(180);
frame:SetHeight(335);
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -14);
frame:SetFrameStrata("LOW");
frame:SetFrameLevel(6);
frame:SetClampedToScreen(true);
frame:SetMovable(true);
frame:EnableMouse(true);
frame:RegisterForDrag("LeftButton");
frame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        frame:StartMoving();
    end
end);
frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = frame:GetPoint();
        BordoUIDB.statsPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);
frame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
frame:SetBackdropColor(0.04, 0.04, 0.06, 0.88);
frame:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);
-- Title Bar (Click & drag to move, Mousewheel to scale)
local headerBar = CreateFrame("Frame", nil, frame);
headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
headerBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
headerBar:SetHeight(24);
headerBar:EnableMouse(true);
headerBar:RegisterForDrag("LeftButton");
headerBar:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        frame:StartMoving();
    end
end);
headerBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing();
    if ( BordoUIDB ) then
        local point, _, relPoint, x, y = frame:GetPoint();
        BordoUIDB.statsPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);
local titleText = headerBar:CreateFontString(nil, "OVERLAY");
titleText:SetFont(FONT_PATH, 12, "OUTLINE");
titleText:SetPoint("TOPLEFT", headerBar, "TOPLEFT", 8, -6);
titleText:SetTextColor(1, 0.82, 0);
titleText:SetText("Stats");
headerBar:EnableMouseWheel(true);
headerBar:SetScript("OnMouseWheel", function()
    local cur = (BordoUIDB and BordoUIDB.statsScale) or 1.0;
    if ( arg1 > 0 ) then cur = cur + 0.05; else cur = cur - 0.05; end
    cur = math.min(1.3, math.max(0.65, cur));
    BordoUIDB.statsScale = cur;
    frame:SetScale(cur);
end);
if ( BordoUI and BordoUI.AttachLockButton ) then
    BordoUI:AttachLockButton(frame, "TOPRIGHT", headerBar, "TOPRIGHT", -6, -4);
end
-- Build Section Categories and Rows
local rowFrames = {};
local currentY = -24;
local ROW_HEIGHT = 14;
local HEADER_HEIGHT = 16;
for secIndex = 1, table.getn(SECTIONS) do
    local sec = SECTIONS[secIndex];
    
    -- Category Header with Colored Center Text and Left/Right Horizontal Lines
    local secHeader = CreateFrame("Frame", nil, frame);
    secHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, currentY);
    secHeader:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, currentY);
    secHeader:SetHeight(HEADER_HEIGHT);
    
    local secText = secHeader:CreateFontString(nil, "OVERLAY");
    secText:SetFont(FONT_PATH, 10, "OUTLINE");
    secText:SetPoint("CENTER", secHeader, "CENTER", 0, 0);
    secText:SetTextColor(sec.color[1], sec.color[2], sec.color[3]);
    secText:SetText(sec.title);
    
    local leftLine = CreateLine(secHeader, sec.color[1], sec.color[2], sec.color[3], 0.7);
    leftLine:SetHeight(1);
    leftLine:SetPoint("LEFT", secHeader, "LEFT", 2, 0);
    leftLine:SetPoint("RIGHT", secText, "LEFT", -6, 0);
    
    local rightLine = CreateLine(secHeader, sec.color[1], sec.color[2], sec.color[3], 0.7);
    rightLine:SetHeight(1);
    rightLine:SetPoint("RIGHT", secHeader, "RIGHT", -2, 0);
    rightLine:SetPoint("LEFT", secText, "RIGHT", 6, 0);
    
    currentY = currentY - HEADER_HEIGHT - 1;
    
    -- Data Rows
    for rIndex = 1, table.getn(sec.rows) do
        local rData = sec.rows[rIndex];
        
        local row = CreateFrame("Button", nil, frame);
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, currentY);
        row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, currentY);
        row:SetHeight(ROW_HEIGHT);
        row:EnableMouse(true);
        
        row.label = row:CreateFontString(nil, "OVERLAY");
        row.label:SetFont(FONT_PATH, 10, "OUTLINE");
        row.label:SetPoint("LEFT", row, "LEFT", 2, 0);
        row.label:SetTextColor(0.85, 0.85, 0.85);
        row.label:SetText(rData.label);
        
        row.value = row:CreateFontString(nil, "OVERLAY");
        row.value:SetFont(FONT_PATH, 10, "OUTLINE");
        row.value:SetPoint("RIGHT", row, "RIGHT", -2, 0);
        row.value:SetTextColor(1, 1, 1);
        row.value:SetText("-");
        
        row.rData = rData;
        row.secColor = sec.color;
        
        row:SetScript("OnEnter", function()
            local data = this.rData;
            if ( not data ) then return; end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
            GameTooltip:SetText(data.label, 1, 1, 1);
            GameTooltip:AddLine(data.desc, 1, 0.82, 0, 1);
            if ( data.gearBonus and data.gearBonus ~= "" ) then
                GameTooltip:AddDoubleLine("Worn gear bonus:", data.gearBonus, 0.12, 1, 0, 0.12, 1, 0);
            end
            GameTooltip:Show();
        end);
        row:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
        
        table.insert(rowFrames, row);
        currentY = currentY - ROW_HEIGHT;
    end
    currentY = currentY - 3;
end
-- Adjust frame height to content
frame:SetHeight(math.abs(currentY) + 6);
-- Live Stat Updating Function
function StatsUI:Update()
    if ( not frame:IsShown() ) then return; end
    
    local s = AZS_STATS or {};
    
    for i = 1, table.getn(rowFrames) do
        local row = rowFrames[i];
        local data = row.rData;
        if ( data and data.fmt ) then
            local valText = data.fmt(s);
            row.value:SetText(valText);
            
            -- Read gear bonus if applicable
            if ( data.gearKey and s[data.gearKey] ) then
                local gVal = tonumber(s[data.gearKey]);
                if ( gVal and gVal > 0 ) then
                    if ( data.key == "dmg" or data.key == "area" or data.key == "spd" or data.key == "gold" or data.key == "crit" or data.key == "echo" or data.key == "cm" ) then
                        data.gearBonus = string.format("+%.1f%%", gVal * 100);
                    else
                        data.gearBonus = string.format("+%d", gVal);
                    end
                else
                    data.gearBonus = nil;
                end
            else
                data.gearBonus = nil;
            end
        end
    end
end
-- Update Ticker Frame (5 times per second)
local ticker = CreateFrame("Frame", "BordoUI_StatsWindowTicker");
local elapsed = 0;
ticker:SetScript("OnUpdate", function()
    elapsed = elapsed + arg1;
    if ( elapsed < 0.2 ) then return; end
    elapsed = 0;
    StatsUI:Update();
end);

-- =========================================================================
-- HIGHEST CRIT WINDOW (Docked right under Stats Window)
-- =========================================================================
BordoUI.Crits = BordoUI.Crits or {};
local crits = BordoUI.Crits;

local function FormatNumber(num)
    num = tonumber(num) or 0;
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000);
    elseif num >= 10000 then
        return string.format("%.1fk", num / 1000);
    elseif num >= 1000 then
        local thousands = math.floor(num / 1000);
        local remainder = math.mod(num, 1000);
        return string.format("%d,%03d", thousands, remainder);
    else
        return tostring(math.floor(num + 0.5));
    end
end

local function GetAttackIcon(spellName)
    if AZSHelper and AZSHelper.GetSpellIcon then
        local icon = AZSHelper:GetSpellIcon(spellName);
        if icon and icon ~= "" and icon ~= "Interface\Icons\INV_Misc_QuestionMark" then
            return icon;
        end
    end
    if AZS_SPELLS then
        local lower = string.lower(spellName or "");
        for i = 1, table.getn(AZS_SPELLS) do
            local e = AZS_SPELLS[i];
            local k = string.lower(e.key or e[1] or "");
            local icon = e.icon or e[2];
            if (k == lower or string.find(k, lower) or string.find(lower, k)) and icon then
                return icon;
            end
        end
    end
    local numTabs = GetNumSpellTabs and GetNumSpellTabs() or 0;
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab);
        for s = (offset or 0) + 1, (offset or 0) + (numSpells or 0) do
            local sName = GetSpellName(s, "spell");
            if sName and string.lower(sName) == string.lower(spellName or "") then
                local tex = GetSpellTexture(s, "spell");
                if tex then return tex; end
            end
        end
    end
    local lower = string.lower(spellName or "");
    if lower == "melee" or lower == "nahkampf" or lower == "attack" or lower == "angriff" then
        return "Interface\Icons\INV_Sword_04";
    end
    return "Interface\Icons\INV_Misc_QuestionMark";
end

-- Create the Highest Crit Frame
local critFrame = CreateFrame("Frame", "BordoUI_HighestCritFrame", UIParent);
StatsUI.critFrame = critFrame;
BordoUI.HighestCritFrame = critFrame;
critFrame:SetWidth(180);
critFrame:SetHeight(48);
critFrame:SetFrameStrata("LOW");
critFrame:SetFrameLevel(6);
critFrame:SetClampedToScreen(true);
critFrame:SetMovable(true);
critFrame:EnableMouse(true);
critFrame:RegisterForDrag("LeftButton");

critFrame:SetBackdrop({
    bgFile   = "Interface\Tooltips\UI-Tooltip-Background",
    edgeFile = "Interface\Tooltips\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
critFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.88);
critFrame:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);

local function SaveCritPosition()
    if BordoUIDB then
        local point, _, relPoint, x, y = critFrame:GetPoint();
        BordoUIDB.highestCritPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end

critFrame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        critFrame:StartMoving();
    end
end);
critFrame:SetScript("OnDragStop", function()
    critFrame:StopMovingOrSizing();
    SaveCritPosition();
end);

-- Header Bar
local critHeader = CreateFrame("Frame", nil, critFrame);
critHeader:SetPoint("TOPLEFT", critFrame, "TOPLEFT", 0, 0);
critHeader:SetPoint("TOPRIGHT", critFrame, "TOPRIGHT", 0, 0);
critHeader:SetHeight(22);
critHeader:EnableMouse(true);
critHeader:RegisterForDrag("LeftButton");
critHeader:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        critFrame:StartMoving();
    end
end);
critHeader:SetScript("OnDragStop", function()
    critFrame:StopMovingOrSizing();
    SaveCritPosition();
end);

local critTitle = critHeader:CreateFontString(nil, "OVERLAY");
critTitle:SetFont(FONT_PATH, 11, "OUTLINE");
critTitle:SetPoint("LEFT", critHeader, "LEFT", 8, 0);
critTitle:SetTextColor(1, 0.82, 0);
critTitle:SetText("Highest Crit");

-- Reset Button
local btnReset = CreateFrame("Button", nil, critHeader);
btnReset:SetWidth(32);
btnReset:SetHeight(14);
btnReset:SetPoint("RIGHT", critHeader, "RIGHT", -24, 0);
local btnResetText = btnReset:CreateFontString(nil, "OVERLAY");
btnResetText:SetFont(FONT_PATH, 9, "OUTLINE");
btnResetText:SetPoint("CENTER", btnReset, "CENTER", 0, 0);
btnResetText:SetTextColor(0.55, 0.55, 0.60);
btnResetText:SetText("Reset");
btnReset:SetScript("OnEnter", function()
    btnResetText:SetTextColor(1, 0.82, 0);
end);
btnReset:SetScript("OnLeave", function()
    btnResetText:SetTextColor(0.55, 0.55, 0.60);
end);
btnReset:SetScript("OnClick", function()
    BordoUI:ResetCrits();
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Highest Crits reset.");
    end
end);

-- Mousewheel zoom to scale Highest Crit along with Stats
critHeader:EnableMouseWheel(true);
critHeader:SetScript("OnMouseWheel", function()
    local cur = (BordoUIDB and BordoUIDB.statsScale) or 1.0;
    if ( arg1 > 0 ) then cur = cur + 0.05; else cur = cur - 0.05; end
    cur = math.min(1.3, math.max(0.65, cur));
    BordoUIDB.statsScale = cur;
    if frame then frame:SetScale(cur); end
    critFrame:SetScale(cur);
end);

-- Attach universal lock button to top right
if BordoUI and BordoUI.AttachLockButton then
    BordoUI:AttachLockButton(critFrame, "TOPRIGHT", critHeader, "TOPRIGHT", -6, -4);
end

-- Gold divider line under header
local critSep = CreateLine(critHeader, 1, 0.82, 0, 0.4);
critSep:SetHeight(1);
critSep:SetPoint("BOTTOMLEFT", critHeader, "BOTTOMLEFT", 6, 0);
critSep:SetPoint("BOTTOMRIGHT", critHeader, "BOTTOMRIGHT", -6, 0);

-- Empty label when no crits yet
local emptyText = critFrame:CreateFontString(nil, "OVERLAY");
emptyText:SetFont(FONT_PATH, 9, "OUTLINE");
emptyText:SetPoint("CENTER", critFrame, "CENTER", 0, -8);
emptyText:SetTextColor(0.50, 0.50, 0.55);
emptyText:SetText("No crits recorded yet");

-- Rows (up to 7 rows)
local MAX_CRIT_ROWS = 7;
local critRows = {};

for i = 1, MAX_CRIT_ROWS do
    local r = CreateFrame("Button", nil, critFrame);
    r:SetHeight(18);
    r:SetPoint("TOPLEFT", critFrame, "TOPLEFT", 6, -24 - (i - 1) * 19);
    r:SetPoint("TOPRIGHT", critFrame, "TOPRIGHT", -6, -24 - (i - 1) * 19);
    r:EnableMouse(true);

    if math.mod(i, 2) == 0 then
        local rBg = r:CreateTexture(nil, "BACKGROUND");
        rBg:SetAllPoints(r);
        rBg:SetTexture(FLAT);
        rBg:SetVertexColor(0.08, 0.08, 0.12, 0.35);
    end

    -- Icon frame (14x14)
    local iconFrame = CreateFrame("Frame", nil, r);
    iconFrame:SetWidth(14);
    iconFrame:SetHeight(14);
    iconFrame:SetPoint("LEFT", r, "LEFT", 2, 0);

    local iconTex = iconFrame:CreateTexture(nil, "ARTWORK");
    iconTex:SetAllPoints(iconFrame);
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    r.iconTex = iconTex;

    local iconBorder = iconFrame:CreateTexture(nil, "BORDER");
    iconBorder:SetTexture(FLAT);
    iconBorder:SetVertexColor(0, 0, 0, 1);
    iconBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -1, 1);
    iconBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 1, -1);

    local nameText = r:CreateFontString(nil, "OVERLAY");
    nameText:SetFont(FONT_PATH, 10, "OUTLINE");
    nameText:SetPoint("LEFT", iconFrame, "RIGHT", 5, 0);
    nameText:SetWidth(88);
    nameText:SetJustifyH("LEFT");
    nameText:SetTextColor(0.90, 0.90, 0.94);
    r.nameText = nameText;

    local valText = r:CreateFontString(nil, "OVERLAY");
    valText:SetFont(FONT_PATH, 10, "OUTLINE");
    valText:SetPoint("RIGHT", r, "RIGHT", -2, 0);
    valText:SetTextColor(1.0, 0.85, 0.20); -- Crit gold
    valText:SetJustifyH("RIGHT");
    r.valText = valText;

    r:SetScript("OnEnter", function()
        if not this.abilityName then return end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
        GameTooltip:SetText(this.abilityName, 1, 0.82, 0);
        GameTooltip:AddDoubleLine("Highest Crit:", FormatNumber(this.maxCrit or 0), 1, 1, 1, 1, 0.85, 0.20);
        if this.crits and this.hits then
            local rate = (this.hits > 0) and (this.crits / this.hits * 100) or 0;
            GameTooltip:AddDoubleLine("Crit Rate:", string.format("%.1f%% (%d/%d)", rate, this.crits, this.hits), 0.7, 0.7, 0.7, 0.4, 1, 0.6);
        end
        GameTooltip:Show();
    end);
    r:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    r:Hide();
    critRows[i] = r;
end

-- Refresh / Draw Highest Crits
function BordoUI:UpdateHighestCrit()
    if not critFrame:IsShown() then return end

    local sorted = {};
    for spell, data in pairs(crits) do
        if data and data.maxCrit and data.maxCrit > 0 then
            table.insert(sorted, {
                spell = spell,
                maxCrit = data.maxCrit,
                crits = data.crits or 1,
                hits = data.hits or 1,
            });
        end
    end

    table.sort(sorted, function(a, b)
        return a.maxCrit > b.maxCrit;
    end);

    local total = table.getn(sorted);
    if total == 0 then
        emptyText:Show();
        for i = 1, MAX_CRIT_ROWS do
            critRows[i]:Hide();
        end
        critFrame:SetHeight(48);
        return;
    end

    emptyText:Hide();
    local count = math.min(MAX_CRIT_ROWS, total);
    for i = 1, MAX_CRIT_ROWS do
        local r = critRows[i];
        if i <= count then
            local entry = sorted[i];
            r.abilityName = entry.spell;
            r.maxCrit = entry.maxCrit;
            r.crits = entry.crits;
            r.hits = entry.hits;

            r.nameText:SetText(entry.spell);
            r.valText:SetText(FormatNumber(entry.maxCrit));
            r.iconTex:SetTexture(GetAttackIcon(entry.spell));
            r:Show();
        else
            r.abilityName = nil;
            r:Hide();
        end
    end

    critFrame:SetHeight(26 + count * 19 + 4);
end

function BordoUI:ResetCrits()
    BordoUI.Crits = {};
    crits = BordoUI.Crits;
    BordoUI:UpdateHighestCrit();
end

-- Combat Log Parser for Crits
local function RecordCrit(spell, amount, isCrit)
    if not spell or not amount or amount <= 0 then return end
    spell = string.gsub(spell, "%.$", "");
    spell = string.gsub(spell, "^%s*(.-)%s*$", "%1");

    if not crits[spell] then
        crits[spell] = { hits = 0, crits = 0, maxCrit = 0 };
    end

    local d = crits[spell];
    d.hits = d.hits + 1;

    if isCrit then
        d.crits = d.crits + 1;
        if amount > d.maxCrit then
            d.maxCrit = amount;
            BordoUI:UpdateHighestCrit();
        end
    end
end

local critWatcher = CreateFrame("Frame", "BordoUI_CritWatcher");
critWatcher:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
critWatcher:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
critWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
critWatcher:SetScript("OnEvent", function()
    local msg = arg1;
    if not msg then return end

    local lower = string.lower(msg);
    local isCrit = (string.find(lower, "crit") ~= nil) or (string.find(lower, "krit") ~= nil);

    -- Extract Damage Amount
    local _, _, amount = string.find(msg, " for (%d+)");
    if not amount then
        _, _, amount = string.find(msg, " f%A+r (%d+)");
    end
    if not amount then
        _, _, amount = string.find(msg, " suffers (%d+) .+ from your ");
    end
    if not amount then
        local gFunc = string.gfind or string.gmatch;
        if gFunc then
            for w in gFunc(msg, "(%d+)") do amount = w; end
        end
    end
    amount = tonumber(amount or 0);
    if not amount or amount <= 0 then return end

    -- Extract Spell / Attack Name
    local spell = nil;

    -- English Patterns
    local _, _, s = string.find(msg, "^Your (.+) crits (.+) for (%d+)");
    if s then spell = s; end

    if not spell then
        local _, _, s2 = string.find(msg, "^Your (.+) crits for (%d+)");
        if s2 then spell = s2; end
    end

    if not spell then
        local _, _, _, a = string.find(msg, "^You crit (.+) for (%d+)");
        if a then spell = "Melee"; end
    end

    if not spell then
        local _, _, owner, sPet = string.find(msg, "^(.+)'s (.+) crits (.+) for (%d+)");
        if sPet then spell = (owner and owner ~= "") and (owner.."'s "..sPet) or sPet; end
    end

    if not spell then
        local _, _, s3 = string.find(msg, "^Your (.+) hits (.+) for (%d+)");
        if s3 then spell = s3; end
    end

    -- German Patterns
    if not spell then
        local _, _, gs1 = string.find(msg, "^Euer (.+) trifft (.+) kritisch f%A+r (%d+)");
        if gs1 then spell = gs1; end
    end

    if not spell then
        local _, _, gs2 = string.find(msg, "^Eure (.+) trifft (.+) kritisch f%A+r (%d+)");
        if gs2 then spell = gs2; end
    end

    if not spell then
        local _, _, gs3 = string.find(msg, "^Ihr trefft (.+) kritisch f%A+r (%d+)");
        if gs3 then spell = "Nahkampf"; end
    end

    if not spell then
        local _, _, gs4 = string.find(msg, "^Euer (.+) trifft");
        if gs4 then spell = gs4; end
    end

    if not spell then
        local _, _, gs5 = string.find(msg, "^Eure (.+) trifft");
        if gs5 then spell = gs5; end
    end

    if not spell then
        if string.find(msg, "You hit ") or string.find(msg, "You crit ") then
            spell = "Melee";
        elseif string.find(msg, "Ihr trefft ") then
            spell = "Nahkampf";
        end
    end

    if spell then
        RecordCrit(spell, amount, isCrit);
    end
end);

-- Reset Position Function
function StatsUI:ResetPosition()
    frame:ClearAllPoints();
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -14);
    if critFrame then
        critFrame:ClearAllPoints();
        critFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -8);
    end
    if ( BordoUIDB ) then
        BordoUIDB.statsPos = nil;
        BordoUIDB.highestCritPos = nil;
    end
end
-- Initialize Position & Scale
local function InitStatsWindow()
    if ( BordoUIDB and BordoUIDB.statsPos and BordoUIDB.statsPos.point ) then
        BordoUI:RestorePosition(frame, BordoUIDB.statsPos);
    else
        frame:ClearAllPoints();
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -14);
    end
    if ( BordoUIDB and BordoUIDB.statsScale ) then
        frame:SetScale(BordoUIDB.statsScale);
    end
    if ( BordoUIDB and BordoUIDB.showStats == false ) then
        frame:Hide();
    else
        frame:Show();
    end
    StatsUI:Update();

    -- Initialize Highest Crit Window
    if ( BordoUIDB and BordoUIDB.highestCritPos and BordoUIDB.highestCritPos.point ) then
        BordoUI:RestorePosition(critFrame, BordoUIDB.highestCritPos);
    else
        critFrame:ClearAllPoints();
        critFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -8);
    end
    if ( BordoUIDB and BordoUIDB.statsScale ) then
        critFrame:SetScale(BordoUIDB.statsScale);
    end
    if ( BordoUIDB and BordoUIDB.showHighestCrit == false ) then
        critFrame:Hide();
    else
        critFrame:Show();
    end
    BordoUI:UpdateHighestCrit();
end
local loader = CreateFrame("Frame");
loader:RegisterEvent("PLAYER_ENTERING_WORLD");
loader:RegisterEvent("VARIABLES_LOADED");
loader:SetScript("OnEvent", InitStatsWindow);
