--[[
    Bordo UI 2.0 - Important Procs & Buffs HUD (ProcTracker.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Centered HUD directly above player health bar for critical active procs and defensives
    - High-impact tracking: Divine Shield, Bloodlust, Evasion, Sprint, Power Word: Shield, etc.
    - Type-colored glowing borders: Gold (Burst), Cyan (Defensive/Shield), Green (Speed)
    - Clean live countdown timers and smooth fade animations
    - Movable with /unlock (Alt-drag or Move Mode)
    - Toggle with /bordo procs, test with /bordo testprocs
]]--

BordoUI = BordoUI or {};

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";
local ICON_SIZE = 26;
local MAX_PROCS = 6;

-- Hidden scanner tooltip
local scanner = CreateFrame("GameTooltip", "BordoUI_ProcScannerTip", nil, "GameTooltipTemplate");
scanner:SetOwner(WorldFrame, "ANCHOR_NONE");

-- Monitored Priority Procs & Default Durations
local MONITORED_PROCS = {
    -- Major Defensives & Invulnerabilities (Cyan)
    ["divine shield"]          = { kind = "defense", dur = 12, color = { 0.20, 0.85, 1.00 } },
    ["gottesschild"]           = { kind = "defense", dur = 12, color = { 0.20, 0.85, 1.00 } },
    ["ice block"]              = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["eisblock"]               = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["blessing of protection"] = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["segen des schutzes"]     = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["divine protection"]      = { kind = "defense", dur = 8,  color = { 0.20, 0.85, 1.00 } },
    ["goettlicher schutz"]     = { kind = "defense", dur = 8,  color = { 0.20, 0.85, 1.00 } },
    ["shield wall"]            = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["schildwall"]             = { kind = "defense", dur = 10, color = { 0.20, 0.85, 1.00 } },
    ["last stand"]             = { kind = "defense", dur = 20, color = { 0.20, 0.85, 1.00 } },
    ["letztes gefecht"]        = { kind = "defense", dur = 20, color = { 0.20, 0.85, 1.00 } },
    ["evasion"]                = { kind = "defense", dur = 15, color = { 0.20, 0.85, 1.00 } },
    ["entrinnen"]              = { kind = "defense", dur = 15, color = { 0.20, 0.85, 1.00 } },
    ["barkskin"]               = { kind = "defense", dur = 15, color = { 0.20, 0.85, 1.00 } },
    ["baumrinde"]              = { kind = "defense", dur = 15, color = { 0.20, 0.85, 1.00 } },
    
    -- Shields (Cyan / Blue)
    ["power word: shield"]     = { kind = "shield",  dur = 30, color = { 0.40, 0.75, 1.00 } },
    ["machtwort: schild"]      = { kind = "shield",  dur = 30, color = { 0.40, 0.75, 1.00 } },
    ["ice barrier"]            = { kind = "shield",  dur = 30, color = { 0.40, 0.75, 1.00 } },
    ["eisbarriere"]            = { kind = "shield",  dur = 30, color = { 0.40, 0.75, 1.00 } },
    ["mana shield"]            = { kind = "shield",  dur = 60, color = { 0.40, 0.75, 1.00 } },
    ["manaschild"]             = { kind = "shield",  dur = 60, color = { 0.40, 0.75, 1.00 } },
    ["holy shield"]            = { kind = "shield",  dur = 10, color = { 0.40, 0.75, 1.00 } },
    ["heiliger schild"]        = { kind = "shield",  dur = 10, color = { 0.40, 0.75, 1.00 } },

    -- Offensive Bursts & Procs (Gold)
    ["bloodlust"]              = { kind = "burst",   dur = 40, color = { 1.00, 0.82, 0.00 } },
    ["kampfrausch"]            = { kind = "burst",   dur = 40, color = { 1.00, 0.82, 0.00 } },
    ["heroism"]                = { kind = "burst",   dur = 40, color = { 1.00, 0.82, 0.00 } },
    ["heldentum"]              = { kind = "burst",   dur = 40, color = { 1.00, 0.82, 0.00 } },
    ["berserking"]             = { kind = "burst",   dur = 10, color = { 1.00, 0.82, 0.00 } },
    ["berserker"]              = { kind = "burst",   dur = 10, color = { 1.00, 0.82, 0.00 } },
    ["combustion"]             = { kind = "burst",   dur = 15, color = { 1.00, 0.45, 0.10 } },
    ["verbrennung"]            = { kind = "burst",   dur = 15, color = { 1.00, 0.45, 0.10 } },
    ["arcane power"]           = { kind = "burst",   dur = 15, color = { 1.00, 0.40, 0.90 } },
    ["arkane macht"]           = { kind = "burst",   dur = 15, color = { 1.00, 0.40, 0.90 } },
    ["adrenaline rush"]        = { kind = "burst",   dur = 15, color = { 1.00, 0.82, 0.00 } },
    ["adrenalinrausch"]        = { kind = "burst",   dur = 15, color = { 1.00, 0.82, 0.00 } },
    ["blade flurry"]           = { kind = "burst",   dur = 15, color = { 1.00, 0.82, 0.00 } },
    ["klingenwirbel"]          = { kind = "burst",   dur = 15, color = { 1.00, 0.82, 0.00 } },
    ["death wish"]             = { kind = "burst",   dur = 30, color = { 1.00, 0.30, 0.20 } },
    ["todeswunsch"]            = { kind = "burst",   dur = 30, color = { 1.00, 0.30, 0.20 } },
    ["clearcasting"]           = { kind = "burst",   dur = 15, color = { 0.30, 0.90, 1.00 } },
    ["freizaubern"]            = { kind = "burst",   dur = 15, color = { 0.30, 0.90, 1.00 } },
    ["inner focus"]            = { kind = "burst",   dur = 20, color = { 0.90, 0.90, 0.40 } },
    ["innerer fokus"]          = { kind = "burst",   dur = 20, color = { 0.90, 0.90, 0.40 } },
    ["presence of mind"]       = { kind = "burst",   dur = 20, color = { 0.90, 0.90, 0.40 } },
    ["geistesgegenwart"]       = { kind = "burst",   dur = 20, color = { 0.90, 0.90, 0.40 } },

    -- Mobility & Speed (Lime Green)
    ["sprint"]                 = { kind = "speed",   dur = 15, color = { 0.20, 1.00, 0.30 } },
    ["spurt"]                  = { kind = "speed",   dur = 15, color = { 0.20, 1.00, 0.30 } },
    ["dash"]                   = { kind = "speed",   dur = 15, color = { 0.20, 1.00, 0.30 } },
    ["spurten"]                = { kind = "speed",   dur = 15, color = { 0.20, 1.00, 0.30 } },
    ["aspect of the cheetah"]  = { kind = "speed",   dur = 60, color = { 0.20, 1.00, 0.30 } },
    ["aspekt des geparden"]    = { kind = "speed",   dur = 60, color = { 0.20, 1.00, 0.30 } },
};

-- Main Container Frame
local procFrame = CreateFrame("Frame", "BordoUI_ProcTrackerFrame", UIParent);
procFrame:SetWidth((ICON_SIZE + 4) * MAX_PROCS);
procFrame:SetHeight(ICON_SIZE + 16);
procFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -108);
procFrame:SetMovable(true);
procFrame:EnableMouse(true);
procFrame:RegisterForDrag("LeftButton");

procFrame:SetScript("OnDragStart", function()
    if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
        procFrame:StartMoving();
    end
end);
procFrame:SetScript("OnDragStop", function()
    procFrame:StopMovingOrSizing();
    local pt, _, relPt, x, y = procFrame:GetPoint();
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.procTrackerPos = { point = pt, relativePoint = relPt, x = x, y = y };
end);

local procSlots = {};
for i = 1, MAX_PROCS do
    local slot = CreateFrame("Button", "BordoUI_ProcSlot_" .. i, procFrame);
    slot:SetWidth(ICON_SIZE);
    slot:SetHeight(ICON_SIZE);
    slot:SetPoint("LEFT", procFrame, "LEFT", (i - 1) * (ICON_SIZE + 4), 6);
    
    -- Icon Texture
    local icon = slot:CreateTexture(nil, "ARTWORK");
    icon:SetAllPoints(slot);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    slot.icon = icon;
    
    -- Border Frame with Backdrop
    local border = CreateFrame("Frame", nil, slot);
    border:SetPoint("TOPLEFT", slot, "TOPLEFT", -2, 2);
    border:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2);
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    });
    slot.border = border;
    
    -- Timer Text
    local timerText = slot:CreateFontString(nil, "OVERLAY");
    timerText:SetFont(FONT_PATH, 9, "OUTLINE");
    timerText:SetPoint("TOP", slot, "BOTTOM", 0, -1);
    timerText:SetTextColor(1.0, 1.0, 1.0);
    slot.timerText = timerText;
    
    slot:EnableMouse(true);
    slot:SetScript("OnEnter", function()
        if ( slot.buffIndex ) then
            GameTooltip:SetOwner(slot, "ANCHOR_TOP");
            GameTooltip:SetUnitBuff("player", slot.buffIndex);
            GameTooltip:Show();
        end
    end);
    slot:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    slot:Hide();
    table.insert(procSlots, slot);
end

-- Active Buff Tracking State
local activeProcs = {};
local testUntil = 0;

-- Live Scanner & Countdown Ticker
local watcher = CreateFrame("Frame", "BordoUI_ProcWatcher");
watcher:SetScript("OnUpdate", function()
    local now = GetTime();
    
    BordoUIDB = BordoUIDB or {};
    if ( BordoUIDB.procTracker == false and now >= testUntil ) then
        for i = 1, MAX_PROCS do procSlots[i]:Hide(); end
        return;
    end
    
    -- Test Simulation Mode
    if ( now < testUntil ) then
        local simulated = {
            { name = "Divine Shield", icon = "Interface\\Icons\\Spell_Holy_DivineIntervention", dur = 12, col = { 0.2, 0.85, 1.0 } },
            { name = "Bloodlust",     icon = "Interface\\Icons\\Spell_Nature_BloodLust",           dur = 40, col = { 1.0, 0.82, 0.0 } },
            { name = "Sprint",        icon = "Interface\\Icons\\Ability_Rogue_Sprint",             dur = 15, col = { 0.2, 1.00, 0.3 } },
        };
        for i = 1, MAX_PROCS do
            local s = procSlots[i];
            local sim = simulated[i];
            if ( sim ) then
                s.icon:SetTexture(sim.icon);
                s.border:SetBackdropBorderColor(sim.col[1], sim.col[2], sim.col[3], 0.95);
                local rem = math.max(0, testUntil - now);
                s.timerText:SetText(string.format("%.1fs", rem));
                s:Show();
            else
                s:Hide();
            end
        end
        return;
    end
    
    -- Real Buff Scan
    local found = {};
    for i = 1, 32 do
        local tex = UnitBuff("player", i);
        if ( not tex ) then break; end
        
        scanner:ClearLines();
        scanner:SetUnitBuff("player", i);
        local line1 = BordoUI_ProcScannerTipTextLeft1 and BordoUI_ProcScannerTipTextLeft1:GetText();
        if ( line1 and line1 ~= "" ) then
            local lower = string.lower(line1);
            local entry = MONITORED_PROCS[lower];
            if ( entry ) then
                if ( not activeProcs[lower] ) then
                    activeProcs[lower] = { startTime = now, totalDur = entry.dur };
                end
                table.insert(found, {
                    key = lower,
                    name = line1,
                    tex = tex,
                    buffIndex = i,
                    cfg = entry,
                    meta = activeProcs[lower]
                });
            end
        end
    end
    
    -- Clean up expired tracking
    for k, _ in pairs(activeProcs) do
        local isStillActive = false;
        for j = 1, table.getn(found) do
            if ( found[j].key == k ) then isStillActive = true; break; end
        end
        if ( not isStillActive ) then activeProcs[k] = nil; end
    end
    
    -- Render Slots
    local numFound = table.getn(found);
    for i = 1, MAX_PROCS do
        local slot = procSlots[i];
        if ( i <= numFound ) then
            local item = found[i];
            slot.buffIndex = item.buffIndex;
            slot.icon:SetTexture(item.tex);
            local col = item.cfg.color or { 1, 1, 1 };
            slot.border:SetBackdropBorderColor(col[1], col[2], col[3], 0.95);
            
            local elapsed = now - (item.meta.startTime or now);
            local total = item.meta.totalDur or 15;
            local rem = math.max(0, total - elapsed);
            if ( rem > 0 ) then
                slot.timerText:SetText(rem > 5 and string.format("%ds", math.ceil(rem)) or string.format("%.1fs", rem));
            else
                slot.timerText:SetText("");
            end
            slot:Show();
        else
            slot:Hide();
        end
    end
end);

-- Toggle Command
function BordoUI:ToggleProcTracker()
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.procTracker = (BordoUIDB.procTracker == false);
    local state = BordoUIDB.procTracker and "|cff55ff55Enabled|r" or "|cffff4444Disabled|r";
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Important Procs Tracker is now " .. state);
end

-- Live Test Command (8 Seconds)
function BordoUI:TestProcTracker()
    testUntil = GetTime() + 8.0;
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Simulating 3 active procs (Divine Shield, Bloodlust, Sprint) for 8 seconds...");
end
