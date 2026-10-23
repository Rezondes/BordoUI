--[[
    Bordo UI - Co-op Team Damage Meter (CoopMeter.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    - Real-time multiplayer DPS & damage leaderboard for Co-op mode
    - Dual tracking: High-precision Addon Sync ("BORDO_COOP") + Multi-language Combat Log Fallback
    - Class-colored status bars, contribution share %, and detailed tooltips
    - Freely movable, clamped to screen, lock-supported, and saved across sessions
    - Auto-shows in Co-op mode; toggle anytime with /coop or /bordo coop
]]--

BordoUI.CoopData = {};
local MAX_COOP_ROWS = 8;
local syncElapsed = 0;
local updateElapsed = 0;
local lastRunPhase = nil;
local testModeActive = false;
local userClosedThisSession = false;

-- Class Colors Table
local CLASS_COLORS = {
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
    ["MAGE"]    = { r = 0.41, g = 0.80, b = 0.94 },
    ["ROGUE"]   = { r = 1.00, g = 0.96, b = 0.41 },
    ["DRUID"]   = { r = 1.00, g = 0.49, b = 0.04 },
    ["HUNTER"]  = { r = 0.67, g = 0.83, b = 0.45 },
    ["SHAMAN"]  = { r = 0.00, g = 0.44, b = 0.87 },
    ["PRIEST"]  = { r = 1.00, g = 1.00, b = 1.00 },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
};

local function GetClassColor(className)
    if ( not className ) then return 0.2, 0.8, 1.0; end
    local upper = string.upper(className);
    if ( RAID_CLASS_COLORS and RAID_CLASS_COLORS[upper] ) then
        return RAID_CLASS_COLORS[upper].r, RAID_CLASS_COLORS[upper].g, RAID_CLASS_COLORS[upper].b;
    end
    if ( CLASS_COLORS[upper] ) then
        return CLASS_COLORS[upper].r, CLASS_COLORS[upper].g, CLASS_COLORS[upper].b;
    end
    return 0.2, 0.8, 1.0;
end

-- =========================================================================
-- 1. CO-OP DAMAGE METER WINDOW
-- =========================================================================
local meterFrame = CreateFrame("Frame", "BordoUI_CoopMeterFrame", UIParent);
meterFrame:SetWidth(250);
meterFrame:SetHeight(150);
meterFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -160); -- Placed neatly below Minimap
meterFrame:SetFrameStrata("LOW");
meterFrame:SetFrameLevel(10);
meterFrame:SetClampedToScreen(true);
meterFrame:SetMovable(true);
tinsert(UISpecialFrames, "BordoUI_CoopMeterFrame"); -- ESC closeable
meterFrame:Hide();

-- Modern dark backdrop with cyan border
meterFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 12,
    edgeSize = 8,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
meterFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.94);
meterFrame:SetBackdropBorderColor(0.0, 0.75, 0.95, 0.90);

-- Header Bar (Draggable)
local header = CreateFrame("Frame", nil, meterFrame);
header:SetPoint("TOPLEFT", meterFrame, "TOPLEFT", 4, -4);
header:SetPoint("BOTTOMRIGHT", meterFrame, "TOPRIGHT", -4, -22);
header:EnableMouse(true);
header:RegisterForDrag("LeftButton");
header:SetScript("OnDragStart", function()
    if ( BordoUIDB and BordoUIDB.locked ) then return; end
    meterFrame:StartMoving();
end);
header:SetScript("OnDragStop", function()
    meterFrame:StopMovingOrSizing();
    local point, _, relPoint, x, y = meterFrame:GetPoint();
    if ( BordoUIDB ) then
        BordoUIDB.coopPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);

local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
titleText:SetPoint("LEFT", header, "LEFT", 4, 0);
titleText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
titleText:SetText("|cff00ccff👥 CO-OP DAMAGE METER|r");

local liveIndicator = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
liveIndicator:SetPoint("LEFT", titleText, "RIGHT", 6, 0);
liveIndicator:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
liveIndicator:SetText("|cff55ff55● LIVE|r");
meterFrame.liveIndicator = liveIndicator;

-- Close Button [X]
local closeBtn = CreateFrame("Button", nil, header);
closeBtn:SetWidth(16);
closeBtn:SetHeight(16);
closeBtn:SetPoint("RIGHT", header, "RIGHT", -2, 0);

local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
closeText:SetText("|cffff5555X|r");

closeBtn:SetScript("OnClick", function()
    userClosedThisSession = true;
    meterFrame:Hide();
    if ( BordoUIDB ) then BordoUIDB.showCoop = false; end
end);

-- Footer Frame
local footer = CreateFrame("Frame", nil, meterFrame);
footer:SetPoint("BOTTOMLEFT", meterFrame, "BOTTOMLEFT", 4, 4);
footer:SetPoint("BOTTOMRIGHT", meterFrame, "BOTTOMRIGHT", -4, 4);
footer:SetHeight(16);

local footerText = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
footerText:SetPoint("CENTER", footer, "CENTER", 0, 0);
footerText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
footerText:SetText("Team: 0 (0 DPS)  •  1 Player");
meterFrame.footerText = footerText;

-- Row Frames Pool
meterFrame.rows = {};
for i = 1, MAX_COOP_ROWS do
    local row = CreateFrame("Frame", nil, meterFrame);
    row:SetHeight(18);
    row:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2 - ((i - 1) * 20));
    row:SetPoint("RIGHT", meterFrame, "RIGHT", -4, 0);
    row:EnableMouse(true);
    
    -- Status bar background
    local barBg = row:CreateTexture(nil, "BACKGROUND");
    barBg:SetAllPoints(row);
    barBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
    barBg:SetVertexColor(0.08, 0.08, 0.12, 0.6);
    row.barBg = barBg;
    
    -- Status bar fill
    local bar = CreateFrame("StatusBar", nil, row);
    bar:SetPoint("TOPLEFT", row, "TOPLEFT", 1, -1);
    bar:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 1);
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    bar:SetMinMaxValues(0, 100);
    bar:SetValue(0);
    row.bar = bar;
    
    -- Left Text: Rank + Name
    local leftText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    leftText:SetPoint("LEFT", bar, "LEFT", 4, 0);
    leftText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    leftText:SetJustifyH("LEFT");
    row.leftText = leftText;
    
    -- Right Text: Damage + DPS + %
    local rightText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    rightText:SetPoint("RIGHT", bar, "RIGHT", -4, 0);
    rightText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
    rightText:SetJustifyH("RIGHT");
    row.rightText = rightText;
    
    row:SetScript("OnEnter", function()
        if ( not this.playerData ) then return; end
        local p = this.playerData;
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
        local cr, cg, cb = GetClassColor(p.class);
        GameTooltip:AddLine(p.name .. (p.isPlayer and " (You)" or ""), cr, cg, cb);
        GameTooltip:AddLine(string.format("Class: |cffffffff%s|r", p.class or "Unknown"), 1, 1, 1);
        GameTooltip:AddLine(string.format("Total Damage: |cffff2222%s|r (|cffffffff%d|r)",
            BordoUI:FormatNumber(p.dmg), p.dmg), 1, 1, 1);
        GameTooltip:AddLine(string.format("Average DPS: |cffffd100%s DPS|r", BordoUI:FormatNumber(p.dps)), 1, 1, 1);
        local share = (p.teamDmg and p.teamDmg > 0) and (p.dmg / p.teamDmg * 100) or 0;
        GameTooltip:AddLine(string.format("Team Contribution: |cff00ccff%.1f%%|r", share), 1, 1, 1);
        if ( p.kills and p.kills > 0 ) then
            GameTooltip:AddLine(string.format("Enemies Killed: |cffffffff%s|r", BordoUI:FormatNumber(p.kills)), 1, 1, 1);
        end
        if ( p.source == "addon" ) then
            GameTooltip:AddLine("Sync: |cff55ff55Bordo UI Addon Sync (100% Exact)|r", 0.7, 0.7, 0.7);
        else
            GameTooltip:AddLine("Sync: |cffaaaaaaCombat Log Fallback|r", 0.7, 0.7, 0.7);
        end
        GameTooltip:Show();
    end);
    
    row:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    
    meterFrame.rows[i] = row;
    row:Hide();
end

-- =========================================================================
-- 2. ADDON BROADCAST & COMBAT LOG LISTENER
-- =========================================================================
local function BroadcastMyStats()
    local numParty = GetNumPartyMembers() or 0;
    local numRaid = GetNumRaidMembers() or 0;
    if ( numParty <= 0 and numRaid <= 0 ) then return; end
    
    local myDmg = math.floor((AZS_RUN and AZS_RUN.dealt) or 0);
    local _, _, myDps = AZS_GetMeter();
    myDps = math.floor(myDps or 0);
    local myKills = (AZS_RUN and AZS_RUN.kills) or 0;
    local locCls, engCls = UnitClass("player");
    local myClass = engCls or locCls or "WARRIOR";
    local myHp = (AZS_RUN and AZS_RUN.hp) or UnitHealth("player") or 0;
    local myMaxHp = (AZS_RUN and AZS_RUN.hpm) or UnitHealthMax("player") or 100;
    
    local channel = (numRaid > 0) and "RAID" or "PARTY";
    local msg = myDmg .. ";" .. myDps .. ";" .. myClass .. ";" .. myKills .. ";" .. myHp .. ";" .. myMaxHp;
    pcall(SendAddonMessage, "BordoCoop", msg, channel);
    pcall(SendAddonMessage, "BORDO_COOP", msg, channel);
end

-- Universal Multi-Language Combat Log Parser for party members without Bordo UI
local function ProcessCombatLogPartyHit(msg)
    if ( not msg or msg == "" ) then return; end
    
    local numParty = GetNumPartyMembers() or 0;
    if ( numParty <= 0 ) then return; end
    
    local matchedName = nil;
    local matchedClass = "WARRIOR";
    local lowMsg = string.lower(msg);
    
    for i = 1, numParty do
        local pName = UnitName("party" .. i);
        if ( pName and pName ~= UNKNOWN ) then
            local lowPName = string.lower(pName);
            -- Plain substring search without pattern escaping
            if ( string.find(lowMsg, lowPName, 1, true) ) then
                matchedName = pName;
                local _, cl = UnitClass("party" .. i);
                matchedClass = cl or "WARRIOR";
                break;
            end
        end
    end
    
    if ( not matchedName ) then return; end
    
    -- Extract damage amount:
    -- In WoW combat logs, damage is always an integer number.
    -- English: "for 190", "suffers 190"
    -- German: "für 190", "190 Schaden"
    -- Russian: "190 ед. урона", "наносит 190"
    local amount = nil;
    
    local _, _, a1 = string.find(msg, "(%d+)%s*Schaden");
    if ( a1 ) then amount = tonumber(a1); end
    if ( not amount ) then
        local _, _, a2 = string.find(msg, "for (%d+)");
        if ( a2 ) then amount = tonumber(a2); end
    end
    if ( not amount ) then
        local _, _, a3 = string.find(msg, "(%d+)%s*ед%.");
        if ( a3 ) then amount = tonumber(a3); end
    end
    if ( not amount ) then
        local _, _, a4 = string.find(msg, "(%d+)%s*урона");
        if ( a4 ) then amount = tonumber(a4); end
    end
    if ( not amount ) then
        local _, _, a5 = string.find(msg, "suffers (%d+)");
        if ( a5 ) then amount = tonumber(a5); end
    end
    if ( not amount ) then
        local _, _, a6 = string.find(msg, "f%A+r (%d+)");
        if ( a6 ) then amount = tonumber(a6); end
    end
    -- Fallback: extract last number in the string (in almost all WoW combat messages, the damage number is the last number)
    if ( not amount ) then
        local gFunc = string.gfind or string.gmatch;
        if ( gFunc ) then
            for num in gFunc(msg, "(%d+)") do
                amount = tonumber(num);
            end
        end
    end
    
    if ( amount and amount > 0 and amount < 5000000 ) then
        local existing = BordoUI.CoopData[matchedName];
        -- Only attribute combat log hits if player is not sending fresh addon syncs (< 3.0s ago)
        if ( not existing or existing.source ~= "addon" or (GetTime() - (existing.lastUpdate or 0) > 3.0) ) then
            if ( not existing ) then
                existing = {
                    name       = matchedName,
                    dmg        = 0,
                    dps        = 0,
                    class      = matchedClass,
                    kills      = 0,
                    hp         = 0,
                    maxHp      = 100,
                    source     = "combatlog",
                    lastUpdate = GetTime(),
                };
                BordoUI.CoopData[matchedName] = existing;
            end
            existing.dmg = existing.dmg + amount;
            existing.class = matchedClass;
            local runT = (AZS_GetRunTime and AZS_GetRunTime()) or (AZS_RUN and AZS_RUN.t) or 1;
            existing.dps = math.floor(existing.dmg / math.max(1, runT));
            existing.lastUpdate = GetTime();
            existing.source = "combatlog";
        end
    end
end

-- Event Listener Frame
local coopListener = CreateFrame("Frame", "BordoUI_CoopListener");
coopListener:RegisterEvent("CHAT_MSG_ADDON");
coopListener:RegisterEvent("CHAT_MSG_COMBAT_PARTY_HITS");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS");
coopListener:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS");
coopListener:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS");
coopListener:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS");
coopListener:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE");
coopListener:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PET_DAMAGE");
coopListener:RegisterEvent("PLAYER_ENTERING_WORLD");
coopListener:RegisterEvent("PARTY_MEMBERS_CHANGED");

coopListener:SetScript("OnEvent", function()
    if ( event == "CHAT_MSG_ADDON" ) then
        local prefix = arg1;
        local msg = arg2;
        local sender = arg4;
        local myName = UnitName("player");
        
        if ( (prefix == "BordoCoop" or prefix == "BORDO_COOP") and sender and msg ) then
            if ( string.lower(sender) ~= string.lower(myName or "") ) then
                local parts = {};
                local gFunc = string.gfind or string.gmatch;
                if ( gFunc ) then
                    for w in gFunc(msg, "([^;]+)") do
                        table.insert(parts, w);
                    end
                end
                
                if ( table.getn(parts) >= 2 ) then
                    local pDmg = tonumber(parts[1]) or 0;
                    local pDps = tonumber(parts[2]) or 0;
                    local pClass = parts[3] or "WARRIOR";
                    local pKills = tonumber(parts[4]) or 0;
                    local pHp = tonumber(parts[5]) or 0;
                    local pHpMax = tonumber(parts[6]) or 100;
                    
                    -- Match exact party member case if possible
                    local normName = sender;
                    local numParty = GetNumPartyMembers() or 0;
                    for i = 1, numParty do
                        local pName = UnitName("party" .. i);
                        if ( pName and string.lower(pName) == string.lower(sender) ) then
                            normName = pName;
                            break;
                        end
                    end
                    
                    BordoUI.CoopData[normName] = {
                        name       = normName,
                        dmg        = pDmg,
                        dps        = pDps,
                        class      = pClass,
                        kills      = pKills,
                        hp         = pHp,
                        maxHp      = pHpMax,
                        lastUpdate = GetTime(),
                        source     = "addon",
                    };
                end
            end
        end
        return;
    end
    
    if ( event == "PARTY_MEMBERS_CHANGED" ) then
        userClosedThisSession = false; -- re-enable auto-show on new party formed
        return;
    end
    
    -- Universal Combat Log Damage Fallback
    if ( string.find(event or "", "COMBAT_") or string.find(event or "", "SPELL_") ) then
        ProcessCombatLogPartyHit(arg1);
    end
end);

-- =========================================================================
-- 3. LEADERBOARD SORTING & UPDATE DISPLAY
-- =========================================================================
function BordoUI:UpdateCoopMeter()
    local players = {};
    local myName = UnitName("player") or "You";
    local _, myClass = UnitClass("player");
    local myDmg = (AZS_RUN and AZS_RUN.dealt) or 0;
    local _, _, myDps = AZS_GetMeter();
    myDps = myDps or 0;
    local myKills = (AZS_RUN and AZS_RUN.kills) or 0;
    
    if ( testModeActive ) then
        -- Mock preview data for testing
        players = {
            { name = myName, dmg = 1420000, dps = 5240, class = myClass or "WARRIOR", kills = 1850, isPlayer = true, source = "addon" },
            { name = "Gofover", dmg = 940000, dps = 3450, class = "PALADIN", kills = 1120, isPlayer = false, source = "addon" },
            { name = "Dimasik", dmg = 610000, dps = 2210, class = "PRIEST", kills = 740, isPlayer = false, source = "combatlog" },
        };
    else
        -- Add local player
        table.insert(players, {
            name     = myName,
            dmg      = myDmg,
            dps      = myDps,
            class    = myClass or "WARRIOR",
            kills    = myKills,
            isPlayer = true,
            source   = "addon",
        });
        
        -- Add party members
        local numParty = GetNumPartyMembers() or 0;
        for i = 1, numParty do
            local pName = UnitName("party" .. i);
            if ( pName and pName ~= UNKNOWN and pName ~= myName ) then
                local _, pClass = UnitClass("party" .. i);
                local pData = BordoUI.CoopData[pName];
                if ( not pData ) then
                    local lowP = string.lower(pName);
                    for k, v in pairs(BordoUI.CoopData) do
                        if ( string.lower(k) == lowP ) then
                            pData = v;
                            break;
                        end
                    end
                end
                
                if ( pData ) then
                    pData.class = pClass or pData.class;
                    table.insert(players, pData);
                else
                    table.insert(players, {
                        name       = pName,
                        dmg        = 0,
                        dps        = 0,
                        class      = pClass or "WARRIOR",
                        kills      = 0,
                        isPlayer   = false,
                        source     = "addon",
                    });
                end
            end
        end
        
        -- Add any additional players found in CoopData not currently in party token list (e.g. raid)
        for name, data in pairs(BordoUI.CoopData) do
            local alreadyAdded = false;
            for _, p in ipairs(players) do
                if ( p.name == name ) then alreadyAdded = true; break; end
            end
            if ( not alreadyAdded and (GetTime() - (data.lastUpdate or 0) < 60) ) then
                table.insert(players, data);
            end
        end
    end
    
    -- Sort descending by damage
    table.sort(players, function(a, b)
        return (a.dmg or 0) > (b.dmg or 0);
    end);
    
    -- Calculate team totals
    local teamDmg = 0;
    local teamDps = 0;
    for _, p in ipairs(players) do
        teamDmg = teamDmg + (p.dmg or 0);
        teamDps = teamDps + (p.dps or 0);
    end
    local maxDmg = math.max(1, players[1] and players[1].dmg or 1);
    
    -- Update Rows
    local numDisplay = math.min(MAX_COOP_ROWS, table.getn(players));
    for i = 1, MAX_COOP_ROWS do
        local row = meterFrame.rows[i];
        if ( i <= numDisplay ) then
            local p = players[i];
            p.teamDmg = teamDmg;
            row.playerData = p;
            
            local cr, cg, cb = GetClassColor(p.class);
            row.bar:SetMinMaxValues(0, maxDmg);
            row.bar:SetValue(p.dmg or 0);
            row.bar:SetStatusBarColor(cr, cg, cb, 0.85);
            
            local sharePct = (teamDmg > 0) and math.floor(((p.dmg or 0) / teamDmg) * 100) or 0;
            local tag = p.isPlayer and " |cff888888(You)|r" or "";
            row.leftText:SetText(string.format("%d. %s%s", i, p.name, tag));
            row.rightText:SetText(string.format("%s (|cffffd100%s|r, %d%%)",
                BordoUI:FormatNumber(p.dmg), BordoUI:FormatNumber(p.dps), sharePct));
            
            row:Show();
        else
            row.playerData = nil;
            row:Hide();
        end
    end
    
    -- Resize frame dynamically to fit visible rows
    local rowCount = math.max(1, numDisplay);
    meterFrame:SetHeight(26 + (rowCount * 20) + 22);
    
    -- Update Footer summary
    meterFrame.footerText:SetText(string.format("Team: |cffff2222%s|r (|cffffd100%s DPS|r)  •  %d Player%s",
        BordoUI:FormatNumber(teamDmg), BordoUI:FormatNumber(teamDps), numDisplay, (numDisplay == 1 and "" or "s")));
end

-- =========================================================================
-- 4. ALWAYS-ACTIVE BACKGROUND WORKER FRAME
--    Ensures sync & auto-show run even when meterFrame is initially hidden!
-- =========================================================================
local coopWorker = CreateFrame("Frame", "BordoUI_CoopWorkerFrame");

coopWorker:SetScript("OnUpdate", function()
    local dt = arg1 or 0.1;
    syncElapsed = syncElapsed + dt;
    updateElapsed = updateElapsed + dt;
    
    -- 1. Broadcast stats every 0.5 seconds during active run or card picking
    if ( syncElapsed >= 0.5 ) then
        syncElapsed = 0;
        local ph = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph);
        if ( ph == "playing" or ph == "choosing" or ph == "paused" ) then
            BroadcastMyStats();
        end
    end
    
    -- 2. State & Auto-show check every 0.25 seconds
    if ( updateElapsed >= 0.25 ) then
        updateElapsed = 0;
        
        -- Auto reset Coop data on new run start
        local ph = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph);
        if ( ph == "ready" and lastRunPhase and lastRunPhase ~= "ready" ) then
            BordoUI.CoopData = {};
            userClosedThisSession = false;
        end
        lastRunPhase = ph;
        
        local numParty = GetNumPartyMembers() or 0;
        local numRaid = GetNumRaidMembers() or 0;
        
        -- Auto-show if in group and playing
        if ( (numParty > 0 or numRaid > 0) and ph == "playing" ) then
            if ( not userClosedThisSession and not meterFrame:IsShown() ) then
                meterFrame:Show();
            end
        end
        
        if ( meterFrame:IsShown() ) then
            BordoUI:UpdateCoopMeter();
        end
    end
end);

-- =========================================================================
-- 5. PUBLIC TOGGLE & SLASH COMMANDS
-- =========================================================================
function BordoUI:ToggleCoopMeter(param)
    param = string.lower(param or "");
    if ( param == "test" or param == "preview" ) then
        testModeActive = not testModeActive;
        userClosedThisSession = false;
        meterFrame:Show();
        BordoUI:UpdateCoopMeter();
        local st = testModeActive and "|cff55ff55ENABLED|r" or "|cffff4444DISABLED|r";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Co-op Meter test preview " .. st .. ".");
        return;
    end
    if ( param == "reset" ) then
        BordoUI.CoopData = {};
        testModeActive = false;
        userClosedThisSession = false;
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Co-op damage meter reset.");
        BordoUI:UpdateCoopMeter();
        return;
    end
    
    if ( meterFrame:IsShown() ) then
        userClosedThisSession = true;
        meterFrame:Hide();
        if ( BordoUIDB ) then BordoUIDB.showCoop = false; end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Co-op Damage Meter hidden. Type |cffffd100/coop|r to show.");
    else
        userClosedThisSession = false;
        meterFrame:Show();
        if ( BordoUIDB ) then BordoUIDB.showCoop = true; end
        BordoUI:UpdateCoopMeter();
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Co-op Damage Meter shown.");
    end
end

SLASH_BORDOCOOP1 = "/coop";
SlashCmdList["BORDOCOOP"] = function(msg)
    BordoUI:ToggleCoopMeter(msg);
end;
