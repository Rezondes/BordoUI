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
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 14, -135);
frame:SetFrameStrata("LOW");
frame:SetFrameLevel(6);
frame:SetClampedToScreen(true);
frame:SetMovable(true);
frame:EnableMouse(true);

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
    if ( BordoUIDB and BordoUIDB.locked ) then return; end
    frame:StartMoving();
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

-- Initialize Position & Scale
local function InitStatsWindow()
    if ( BordoUIDB and BordoUIDB.statsPos ) then
        BordoUI:RestorePosition(frame, BordoUIDB.statsPos);
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
end

local loader = CreateFrame("Frame");
loader:RegisterEvent("PLAYER_ENTERING_WORLD");
loader:RegisterEvent("VARIABLES_LOADED");
loader:SetScript("OnEvent", InitStatsWindow);
