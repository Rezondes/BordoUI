-- =========================================================================
-- AZSHelper: Nameplates.lua
-- Modern, Rectangular Enemy Nameplates with High-Visibility Boss & Miniboss Highlighting
-- Compatible with WoW 1.12.1 (Interface 11200 / Lua 5.0)
-- =========================================================================

local function GetUnitClassification(mobName)
    if ( not mobName or mobName == "" ) then return "normal"; end
    
    -- 1. Check AZS_UNITS (Server-sent live list of all special units)
    if ( AZS_UNITS ) then
        for i = 1, table.getn(AZS_UNITS) do
            local u = AZS_UNITS[i];
            if ( u and u.name == mobName ) then
                return u.kind or "normal"; -- "final", "boss", "guardian", "elite"
            end
        end
    end
    
    -- 2. Check live bosses from AZS_GetBosses()
    local bosses = (AZS_GetBosses and AZS_GetBosses()) or {};
    for i = 1, table.getn(bosses) do
        local b = bosses[i];
        if ( b and b.name == mobName ) then
            if ( b.final == 1 or b.final == true ) then return "final"; end
            return "boss";
        end
    end
    
    -- 3. Check live guardians / minibosses from AZS_GetGuardians()
    local guardians = (AZS_GetGuardians and AZS_GetGuardians()) or {};
    for i = 1, table.getn(guardians) do
        local g = guardians[i];
        if ( g and g.name == mobName ) then
            return "guardian";
        end
    end
    
    -- 4. Check guardian lairs from AZS_LAIRS
    local lairs = (AZS_GetLairs and AZS_GetLairs()) or AZS_LAIRS or {};
    for i = 1, table.getn(lairs) do
        local l = lairs[i];
        if ( l and l.name == mobName ) then
            return "guardian";
        end
    end
    
    -- 5. Check zone boss schedule from AZS_SCHEDULE
    local sched = AZS_SCHEDULE or {};
    for i = 1, table.getn(sched) do
        local s = sched[i];
        if ( s and s.name == mobName ) then
            if ( s.final == 1 or s.final == true ) then return "final"; end
            return "boss";
        end
    end
    
    return "normal";
end

-- Identify if a nameplate belongs to a party or raid teammate
local function IsTeammate(unitName)
    if ( not unitName or unitName == "" ) then return false, nil, nil; end
    local lowName = string.lower(unitName);
    
    local numParty = GetNumPartyMembers() or 0;
    for i = 1, numParty do
        local pName = UnitName("party" .. i);
        if ( pName and pName ~= UNKNOWN ) then
            local lowP = string.lower(pName);
            if ( lowP == lowName or string.find(lowName, lowP, 1, true) or string.find(lowP, lowName, 1, true) ) then
                return true, "party" .. i, pName;
            end
        end
    end
    
    local numRaid = GetNumRaidMembers() or 0;
    for i = 1, numRaid do
        local rName = UnitName("raid" .. i);
        if ( rName and rName ~= UNKNOWN ) then
            local lowR = string.lower(rName);
            if ( lowR == lowName or string.find(lowName, lowR, 1, true) or string.find(lowR, lowName, 1, true) ) then
                return true, "raid" .. i, rName;
            end
        end
    end
    
    return false, nil, nil;
end

-- Identify if a frame is a WoW 1.12.1 Blizzard Nameplate
local function IsNameplate(frame)
    if ( not frame ) then return false; end
    if ( frame.isAZSNameplate ) then return true; end
    if ( frame:GetName() ) then return false; end -- Nameplates have no global name in 1.12
    if ( frame:GetParent() ~= WorldFrame ) then return false; end
    
    local regions = { frame:GetRegions() };
    for i = 1, table.getn(regions) do
        local r = regions[i];
        if ( r and r.GetObjectType and r:GetObjectType() == "Texture" ) then
            local tex = r:GetTexture();
            if ( tex and string.find(tex, "Nameplate%-Border") ) then
                frame.isAZSNameplate = true;
                return true;
            end
        end
    end
    return false;
end

-- Find and cache the internal elements of a 1.12.1 Nameplate
local function SetupNameplateElements(frame)
    if ( frame.azsElementsReady ) then return; end
    
    local regions = { frame:GetRegions() };
    local defaultBorder, defaultGlow, nameText, levelText;
    
    for i = 1, table.getn(regions) do
        local r = regions[i];
        if ( r and r.GetObjectType ) then
            local oType = r:GetObjectType();
            if ( oType == "Texture" ) then
                local tex = r:GetTexture();
                if ( tex ) then
                    if ( string.find(tex, "Nameplate%-Border") ) then
                        defaultBorder = r;
                    elseif ( string.find(tex, "Nameplate%-Glow") ) then
                        defaultGlow = r;
                    end
                end
            elseif ( oType == "FontString" ) then
                local txt = r:GetText();
                if ( txt and (tonumber(txt) or string.find(txt, "%?%?")) ) then
                    levelText = r;
                else
                    nameText = r;
                end
            end
        end
    end
    
    local children = { frame:GetChildren() };
    local healthBar = nil;
    for i = 1, table.getn(children) do
        local c = children[i];
        if ( c and c.GetObjectType and c:GetObjectType() == "StatusBar" ) then
            healthBar = c;
            break;
        end
    end
    
    if ( not healthBar ) then return; end
    
    -- Permanently hide default curved Blizzard border and glow
    if ( defaultBorder ) then
        defaultBorder:SetTexture("");
        defaultBorder:Hide();
        defaultBorder.Show = function() end;
    end
    if ( defaultGlow ) then
        defaultGlow:SetTexture("");
        defaultGlow:Hide();
        defaultGlow.Show = function() end;
    end
    
    -- Flat modern status bar texture
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    
    -- Dark background texture behind the health bar
    if ( not healthBar.azsBg ) then
        local bg = healthBar:CreateTexture(nil, "BACKGROUND");
        bg:SetAllPoints(healthBar);
        bg:SetTexture(0.06, 0.06, 0.08, 0.90);
        healthBar.azsBg = bg;
    end
    
    -- Modern Rectangular Border Frame
    if ( not healthBar.azsBorder ) then
        local b = CreateFrame("Frame", nil, healthBar);
        b:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 2);
        b:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 2, -2);
        b:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile     = true,
            tileSize = 8,
            edgeSize = 8,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 }
        });
        b:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.95);
        healthBar.azsBorder = b;
    end
    
    -- Health % text in center of bar (for Bosses and Minibosses)
    if ( not healthBar.azsHpText ) then
        local hpText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
        hpText:SetPoint("CENTER", healthBar, "CENTER", 0, 0);
        hpText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
        hpText:SetTextColor(1, 1, 1, 1);
        healthBar.azsHpText = hpText;
    end
    
    frame.azsHealthBar = healthBar;
    frame.azsNameText = nameText;
    frame.azsLevelText = levelText;
    frame.azsElementsReady = true;
end

-- Dynamic Styling on each Nameplate according to Unit Classification
local function StyleNameplate(frame)
    SetupNameplateElements(frame);
    if ( not frame.azsElementsReady or not frame.azsHealthBar ) then return; end
    
    local healthBar = frame.azsHealthBar;
    local nameText = frame.azsNameText;
    local levelText = frame.azsLevelText;
    local borderFrame = healthBar.azsBorder;
    
    if ( not nameText ) then return; end
    
    -- Extract clean mob name (before our custom prefixes)
    local curName = nameText:GetText();
    if ( not curName or curName == "" ) then return; end
    
    local cleanName = frame.azsCleanName;
    if ( not string.find(curName, "|c") and not string.find(curName, "%[") and not string.find(curName, "%+") and not string.find(curName, "🛡") and not string.find(curName, "👑") ) then
        cleanName = curName;
        frame.azsCleanName = curName;
    end
    if ( not cleanName or cleanName == "" ) then
        cleanName = curName;
    end
    
    local kind = GetUnitClassification(cleanName);
    local isTarget = (UnitExists("target") and UnitName("target") == cleanName);
    
    -- Calculate HP percentage
    local val = healthBar:GetValue() or 0;
    local _, maxVal = healthBar:GetMinMaxValues();
    if ( not maxVal or maxVal <= 0 ) then maxVal = 100; end
    local pct = math.floor((val / maxVal) * 100);
    
    -- Position Text cleanly above the bar
    nameText:ClearAllPoints();
    nameText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 1, 2);
    
    if ( levelText ) then
        levelText:ClearAllPoints();
        levelText:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", -1, 2);
    end
    
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 0: TEAMMATES & PARTY MEMBERS (Vibrant Green Health Bar!)
    -- ---------------------------------------------------------------------
    local isAlly, allyToken, allyRealName = IsTeammate(cleanName);
    if ( not isAlly and isTarget and UnitIsFriend("player", "target") ) then
        isAlly = true;
        allyToken = "target";
        allyRealName = UnitName("target");
    end
    
    if ( isAlly ) then
        healthBar:SetWidth(130);
        healthBar:SetHeight(15);
        frame:SetFrameLevel(75);
        
        -- Vibrant Bright Lime-Green Health Bar for Teammates!
        healthBar:SetStatusBarColor(0.12, 0.95, 0.22, 1.0);
        if ( healthBar.azsBg ) then
            healthBar.azsBg:SetTexture(0.02, 0.15, 0.04, 0.92);
        end
        
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(0.50, 1.0, 0.65, 1.0);
            else
                borderFrame:SetBackdropBorderColor(0.15, 0.85, 0.30, 0.95);
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
        local isLeader = allyToken and UnitIsPartyLeader(allyToken);
        if ( isLeader ) then
            nameText:SetText("|cffffd100👑 |cff55ff55" .. (allyRealName or cleanName) .. "|r");
        else
            nameText:SetText("|cff55ff55🛡️ " .. (allyRealName or cleanName) .. "|r");
        end
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
            levelText:SetTextColor(0.40, 1.0, 0.40);
        end
        
        -- Calculate accurate HP for ally if unit token is available
        local allyPct = pct;
        if ( allyToken and UnitExists(allyToken) ) then
            local curHp = UnitHealth(allyToken) or 0;
            local maxHp = UnitHealthMax(allyToken) or 100;
            if ( maxHp > 0 ) then
                allyPct = math.floor((curHp / maxHp) * 100);
            end
            if ( UnitIsDead(allyToken) or UnitIsGhost(allyToken) or curHp <= 0 ) then
                healthBar.azsHpText:SetText("|cffff2222DEAD|r");
            else
                healthBar.azsHpText:SetText(string.format("%d%%", allyPct));
            end
        else
            if ( pct <= 0 ) then
                healthBar.azsHpText:SetText("|cffff2222DEAD|r");
            else
                healthBar.azsHpText:SetText(string.format("%d%%", pct));
            end
        end
        healthBar.azsHpText:Show();
        return;
    end

    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 1: FINAL BOSS (Huge, Glowing Magenta, Top Strata)
    -- ---------------------------------------------------------------------
    if ( kind == "final" ) then
        healthBar:SetWidth(175);
        healthBar:SetHeight(20);
        frame:SetFrameLevel(100);
        
        healthBar:SetStatusBarColor(0.85, 0.15, 0.85, 1.0); -- Royal Magenta
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(1.0, 0.6, 1.0, 1.0); -- Bright target highlight
            else
                borderFrame:SetBackdropBorderColor(0.95, 0.25, 0.95, 1.0);
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE");
        nameText:SetText("|cffff44ff👑 [FINAL BOSS] " .. cleanName .. " 👑|r");
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
            levelText:SetTextColor(1, 0.2, 0.2);
        end
        
        healthBar.azsHpText:SetText(string.format("%d%%", pct));
        healthBar.azsHpText:Show();
        
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 2: ZONE BOSS (Large, Fiery Crimson, Top Layer)
    -- ---------------------------------------------------------------------
    elseif ( kind == "boss" ) then
        healthBar:SetWidth(160);
        healthBar:SetHeight(18);
        frame:SetFrameLevel(90);
        
        healthBar:SetStatusBarColor(0.95, 0.15, 0.15, 1.0); -- Fiery Crimson
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(1.0, 0.8, 0.3, 1.0); -- Bright target gold
            else
                borderFrame:SetBackdropBorderColor(1.0, 0.25, 0.25, 1.0);
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE");
        nameText:SetText("|cffff2020☠ [BOSS] " .. cleanName .. " ☠|r");
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
            levelText:SetTextColor(1, 0.82, 0.15);
        end
        
        healthBar.azsHpText:SetText(string.format("%d%%", pct));
        healthBar.azsHpText:Show();
        
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 3: MINIBOSS / GUARDIAN (Prominent, Radiant Gold / Amber)
    -- ---------------------------------------------------------------------
    elseif ( kind == "guardian" ) then
        healthBar:SetWidth(145);
        healthBar:SetHeight(16);
        frame:SetFrameLevel(80);
        
        healthBar:SetStatusBarColor(0.95, 0.60, 0.10, 1.0); -- Radiant Amber
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(1.0, 1.0, 0.4, 1.0); -- Bright white/gold target
            else
                borderFrame:SetBackdropBorderColor(1.0, 0.75, 0.15, 1.0); -- Gold border
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
        nameText:SetText("|cffffcc00★ [GUARDIAN] " .. cleanName .. " ★|r");
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
            levelText:SetTextColor(1, 0.82, 0.15);
        end
        
        healthBar.azsHpText:SetText(string.format("%d%%", pct));
        healthBar.azsHpText:Show();
        
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 4: ELITE MOB (Slightly enhanced)
    -- ---------------------------------------------------------------------
    elseif ( kind == "elite" ) then
        healthBar:SetWidth(115);
        healthBar:SetHeight(11);
        frame:SetFrameLevel(30);
        
        healthBar:SetStatusBarColor(0.85, 0.25, 0.25, 1.0);
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(0.9, 0.8, 0.3, 1.0);
            else
                borderFrame:SetBackdropBorderColor(0.65, 0.55, 0.20, 0.95);
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
        nameText:SetText("|cffffd100+|r " .. cleanName);
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
            levelText:SetTextColor(1, 0.82, 0.15);
        end
        healthBar.azsHpText:Hide();
        
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 5: NORMAL TRASH ADDS (Compact, Clean, Modern Rectangular)
    -- ---------------------------------------------------------------------
    else
        healthBar:SetWidth(100);
        healthBar:SetHeight(10);
        frame:SetFrameLevel(10);
        
        healthBar:SetStatusBarColor(0.75, 0.20, 0.20, 1.0); -- Clean dark-red
        if ( borderFrame ) then
            if ( isTarget ) then
                borderFrame:SetBackdropBorderColor(0.2, 0.8, 1.0, 1.0); -- Target highlight
            else
                borderFrame:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.95);
            end
        end
        
        nameText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
        nameText:SetText(cleanName);
        
        if ( levelText ) then
            levelText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
            levelText:SetTextColor(0.85, 0.85, 0.85);
        end
        healthBar.azsHpText:Hide();
    end
end

-- Ensure native WoW 1.12.1 friendly and enemy nameplates are turned on
local function EnsureNameplatesEnabled()
    -- Native WoW 1.12.1 engine functions to toggle/show friendly & enemy nameplates
    if ( ShowFriendNameplates ) then
        pcall(ShowFriendNameplates);
    end
    if ( ShowNameplates ) then
        pcall(ShowNameplates);
    end
    pcall(SetCVar, "UnitNamePlayer", "1");
    pcall(SetCVar, "UnitNameFriendlyPlayerName", "1");
    pcall(SetCVar, "UnitNameEnemyPlayerName", "1");
end
if ( BordoUI ) then
    BordoUI.EnsureNameplates = EnsureNameplatesEnabled;
end

-- Continuous Scanner for Active Nameplates
local scanFrame = CreateFrame("Frame", "AZSHelper_NameplateScanner");
local scanElapsed = 0;
local checkTimer = 0;
local hasInitialRun = false;

scanFrame:SetScript("OnUpdate", function()
    local elapsed = arg1 or 0.05;
    scanElapsed = scanElapsed + elapsed;
    checkTimer = checkTimer + elapsed;
    
    -- Ensure friendly nameplates are active on load and periodically checked in group
    if ( not hasInitialRun or checkTimer >= 4.0 ) then
        checkTimer = 0;
        hasInitialRun = true;
        if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
            EnsureNameplatesEnabled();
        end
    end
    
    if ( scanElapsed < 0.05 ) then return; end
    scanElapsed = 0;
    
    local frames = { WorldFrame:GetChildren() };
    for i = 1, table.getn(frames) do
        local f = frames[i];
        if ( IsNameplate(f) and f:IsShown() ) then
            StyleNameplate(f);
        end
    end
end);

-- Auto-enable friendly player nameplates so teammates are immediately visible
local npAutoFrame = CreateFrame("Frame", "BordoUI_NameplateAutoFrame");
npAutoFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
npAutoFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
npAutoFrame:RegisterEvent("RAID_ROSTER_UPDATE");
npAutoFrame:RegisterEvent("PLAYER_ALIVE");

npAutoFrame:SetScript("OnEvent", function()
    EnsureNameplatesEnabled();
end);
