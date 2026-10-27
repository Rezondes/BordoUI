-- =========================================================================
-- AZSHelper: Nameplates.lua
-- Modern, Rectangular Enemy Nameplates with High-Visibility Boss & Miniboss Highlighting
-- Threat & Healthbar Filtering: All Enemies / Bosses & Elites Only / Disabled
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

-- Identify if a unit name belongs to a Shaman totem (100% pure ASCII safe)
local function IsTotem(name)
    if ( not name or name == "" ) then return false; end
    local lower = string.lower(name);
    local _, _, trimmed = string.find(lower, "^%s*(.-)%s*$");
    lower = trimmed or lower;
    
    -- Exclude Grimtotem Tauren NPCs
    if ( string.find(lower, "grimtotem", 1, true) ) then
        return false;
    end
    
    -- Match "totem" in any form
    if ( lower == "totem" or string.find(lower, "totem", 1, true) ) then
        return true;
    end
    
    return false;
end

local function ShouldHideTotems()
    -- Always hide totem nameplates, even if an older SavedVariables file
    -- contains hideTotems = false.
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.hideTotems = true;
    return true;
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
    
    -- Hide the stock art without destroying the game's target marker state.
    -- The target glow's shown state identifies the one targeted plate, which
    -- matters when several co-op adds share the same name.
    if ( defaultBorder ) then
        defaultBorder:SetTexture("");
        defaultBorder:Hide();
        defaultBorder.Show = function() end;
    end
    if ( defaultGlow ) then
        frame.azsTargetGlow = defaultGlow;
        defaultGlow:SetAlpha(0);
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

-- Completely hide a filtered-out nameplate in WoW 1.12.1 (alpha 0, size 0.001)
local function HideNameplateFrame(frame)
    frame.isFilteredOut = true;
    local healthBar = frame.azsHealthBar;
    if ( not healthBar ) then return; end
    local borderFrame = healthBar.azsBorder;
    local nameText = frame.azsNameText;
    local levelText = frame.azsLevelText;
    
    healthBar:SetStatusBarTexture("");
    healthBar:SetAlpha(0);
    healthBar:SetWidth(0.001);
    healthBar:SetHeight(0.001);
    healthBar:Hide();
    if ( borderFrame ) then borderFrame:Hide(); end
    if ( healthBar.azsBg ) then healthBar.azsBg:Hide(); end
    if ( healthBar.azsHpText ) then healthBar.azsHpText:Hide(); end
    if ( nameText ) then nameText:Hide(); end
    if ( levelText ) then levelText:Hide(); end
    frame:SetAlpha(0);
end

-- Restore a previously filtered-out nameplate to full visibility
local function RestoreNameplateFrame(frame)
    frame.isFilteredOut = nil;
    frame.isTotemPlate = nil;
    local healthBar = frame.azsHealthBar;
    if ( not healthBar ) then return; end
    local borderFrame = healthBar.azsBorder;
    local nameText = frame.azsNameText;
    local levelText = frame.azsLevelText;
    
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    healthBar:SetAlpha(1);
    healthBar:Show();
    if ( borderFrame ) then borderFrame:Show(); end
    if ( healthBar.azsBg ) then healthBar.azsBg:Show(); end
    if ( nameText ) then nameText:Show(); end
    if ( levelText ) then levelText:Show(); end
    frame:SetAlpha(1);
end

-- Dynamic Styling on each Nameplate according to Unit Classification & Filters
local function StyleNameplate(frame)
    SetupNameplateElements(frame);
    if ( not frame.azsElementsReady or not frame.azsHealthBar ) then return; end
    
    local healthBar = frame.azsHealthBar;
    local nameText = frame.azsNameText;
    local levelText = frame.azsLevelText;
    local borderFrame = healthBar.azsBorder;
    
    local filter = (BordoUI and BordoUI.GetNameplateFilter and BordoUI:GetNameplateFilter()) or "all";
    if ( not nameText ) then
        if ( filter ~= "all" ) then HideNameplateFrame(frame); end
        return;
    end
    
    -- Extract clean mob name (before our custom prefixes)
    local curName = nameText:GetText();
    if ( not curName or curName == "" ) then
        -- In filtered modes, suppress a newly spawned plate before its name
        -- becomes available. The scanner revisits our filtered plates and
        -- restores it later if it resolves to a boss, elite, guardian or ally.
        if ( filter ~= "all" ) then HideNameplateFrame(frame); end
        return;
    end
    
    local cleanName = frame.azsCleanName;
    if ( not string.find(curName, "|c") and not string.find(curName, "%[") and not string.find(curName, "%+") ) then
        cleanName = curName;
        frame.azsCleanName = curName;
    end
    if ( not cleanName or cleanName == "" ) then
        cleanName = curName;
    end
    
    -- ---------------------------------------------------------------------
    -- CLASSIFICATION 0: TEAMMATES & PARTY MEMBERS (Vibrant Green Health Bar!)
    -- ---------------------------------------------------------------------
    local isAlly, allyToken, allyRealName = IsTeammate(cleanName);
    -- Use the per-plate target marker. Name matching is unsafe in co-op:
    -- every mob with the same display name would otherwise pass the filter.
    local isTarget = frame.azsTargetGlow and frame.azsTargetGlow:IsShown() or false;
    if ( frame.azsTargetGlow ) then frame.azsTargetGlow:SetAlpha(0); end
    if ( not isAlly and isTarget and UnitIsFriend("player", "target") ) then
        isAlly = true;
        allyToken = "target";
        allyRealName = UnitName("target");
    end
    
    if ( isAlly ) then
        local showFriendly = true;
        if ( BordoUIDB and BordoUIDB.friendlyNameplates == false ) then
            showFriendly = false;
        end
        if ( not showFriendly ) then
            HideNameplateFrame(frame);
            return;
        end
        
        if ( frame.isFilteredOut ) then
            RestoreNameplateFrame(frame);
        end
        
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
        
        nameText:ClearAllPoints();
        nameText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 1, 2);
        nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
        
        local isLeader = allyToken and UnitIsPartyLeader(allyToken);
        if ( isLeader ) then
            nameText:SetText("|cffffd100[LEADER] |cff55ff55" .. (allyRealName or cleanName) .. "|r");
        else
            nameText:SetText("|cff55ff55[ALLY] " .. (allyRealName or cleanName) .. "|r");
        end
        
        if ( levelText ) then
            levelText:ClearAllPoints();
            levelText:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", -1, 2);
            levelText:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
            levelText:SetTextColor(0.40, 1.0, 0.40);
        end
        
        -- Calculate accurate HP for ally if unit token is available
        local allyPct = 100;
        local curHpVal = healthBar:GetValue() or 0;
        local _, maxHpVal = healthBar:GetMinMaxValues();
        if ( not maxHpVal or maxHpVal <= 0 ) then maxHpVal = 100; end
        allyPct = math.floor((curHpVal / maxHpVal) * 100);
        
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
            if ( allyPct <= 0 ) then
                healthBar.azsHpText:SetText("|cffff2222DEAD|r");
            else
                healthBar.azsHpText:SetText(string.format("%d%%", allyPct));
            end
        end
        healthBar.azsHpText:Show();
        return;
    end
    
    -- Shaman Totem Check: completely hide HP bar and plate to eliminate clutter
    local isTotem = IsTotem(cleanName);
    local hideTotems = ShouldHideTotems();
    if ( isTotem and hideTotems ) then
        HideNameplateFrame(frame);
        return;
    end
    
    -- ---------------------------------------------------------------------
    -- ENEMY NAMEPLATE FILTERING: All Enemies / Bosses & Elites Only / Disabled
    -- ---------------------------------------------------------------------
    local kind = GetUnitClassification(cleanName);
    local isBossOrElite = (kind == "final" or kind == "boss" or kind == "guardian" or kind == "elite");
    
    -- Fallback Elite Detection: check if level has "+" (e.g. 60+) or "??"
    if ( not isBossOrElite and levelText ) then
        local lTxt = levelText:GetText();
        if ( lTxt and (string.find(lTxt, "%+") or string.find(lTxt, "%?%?")) ) then
            isBossOrElite = true;
            if ( kind == "normal" ) then
                kind = "elite";
            end
        end
    end
    
    local allowTarget = (isTarget and (not BordoUIDB or BordoUIDB.nameplateShowTarget ~= false));
    
    if ( filter == "off" ) then
        if ( not allowTarget ) then
            HideNameplateFrame(frame);
            return;
        end
    elseif ( filter == "bosses" ) then
        -- Boss/Elite mode is strict, including in co-op: targeting an ordinary
        -- add must never briefly reveal its healthbar.
        if ( not isBossOrElite ) then
            HideNameplateFrame(frame);
            return;
        end
    end
    
    -- If previously filtered out, restore visual elements
    if ( frame.isFilteredOut ) then
        RestoreNameplateFrame(frame);
    end
    
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
        nameText:SetText("|cffff44ff*** [FINAL BOSS] " .. cleanName .. " ***|r");
        
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
        nameText:SetText("|cffff2020[BOSS] " .. cleanName .. "|r");
        
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
        nameText:SetText("|cffffcc00[GUARDIAN] " .. cleanName .. "|r");
        
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
    local friendlyEnabled = (not BordoUIDB or BordoUIDB.friendlyNameplates ~= false);
    if ( friendlyEnabled and ShowFriendNameplates ) then
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

-- Co-op switches its nameplate state when a run begins. Re-apply our choice
-- on world entry and when the game phase transitions into active play.
local nameplateStartup = CreateFrame("Frame", "BordoUI_NameplateStartup");
nameplateStartup:RegisterEvent("VARIABLES_LOADED");
nameplateStartup:RegisterEvent("PLAYER_ENTERING_WORLD");
local lastNameplatePhase = nil;
local phaseElapsed = 0;
nameplateStartup:SetScript("OnEvent", function()
    EnsureNameplatesEnabled();
    lastNameplatePhase = nil;
end);
nameplateStartup:SetScript("OnUpdate", function()
    phaseElapsed = phaseElapsed + (arg1 or 0.1);
    if ( phaseElapsed < 0.25 ) then return; end
    phaseElapsed = 0;
    local phase = AZS_GetPhase and AZS_GetPhase() or nil;
    if ( phase == "playing" and lastNameplatePhase ~= "playing" ) then
        EnsureNameplatesEnabled();
    end
    lastNameplatePhase = phase;
end);

-- =========================================================================
-- BordoUI Nameplate API & Filtering Controls
-- =========================================================================

function BordoUI:GetNameplateFilter()
    if ( not BordoUIDB ) then return "all"; end
    if ( not BordoUIDB.nameplateFilter ) then return "all"; end
    return BordoUIDB.nameplateFilter;
end

function BordoUI:SetNameplateFilter(filter)
    BordoUIDB = BordoUIDB or {};
    if ( filter ~= "all" and filter ~= "bosses" and filter ~= "off" ) then
        filter = "all";
    end
    BordoUIDB.nameplateFilter = filter;
    
    if ( filter == "all" or filter == "bosses" ) then
        if ( ShowNameplates ) then pcall(ShowNameplates); end
    end
    
    self:UpdateNameplatesWindowUI();
    
    local msg = "";
    if ( filter == "all" ) then
        msg = "|cff00ccffBordo UI|r: Enemy Nameplates: |cff55ff55[ALL ENEMIES]|r (Trash adds, elites & bosses shown)";
    elseif ( filter == "bosses" ) then
        msg = "|cff00ccffBordo UI|r: Enemy Nameplates: |cffffd100[BOSSES & ELITES ONLY]|r (Normal trash adds hidden!)";
    elseif ( filter == "off" ) then
        msg = "|cff00ccffBordo UI|r: Enemy Nameplates: |cffff3333[DISABLED]|r (All enemy healthbars hidden)";
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function BordoUI:CycleNameplateFilter()
    local cur = self:GetNameplateFilter();
    local nxt = "all";
    if ( cur == "all" ) then
        nxt = "bosses";
    elseif ( cur == "bosses" ) then
        nxt = "off";
    else
        nxt = "all";
    end
    self:SetNameplateFilter(nxt);
end

function BordoUI:ToggleFriendlyNameplates()
    BordoUIDB = BordoUIDB or {};
    if ( BordoUIDB.friendlyNameplates == nil ) then
        BordoUIDB.friendlyNameplates = true;
    end
    BordoUIDB.friendlyNameplates = not BordoUIDB.friendlyNameplates;
    
    if ( BordoUIDB.friendlyNameplates ) then
        if ( ShowFriendNameplates ) then pcall(ShowFriendNameplates); end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Teammate Nameplates: |cff55ff55[ENABLED]|r (Vibrant green ally bars)");
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Teammate Nameplates: |cffff3333[DISABLED]|r");
    end
    self:UpdateNameplatesWindowUI();
end

function BordoUI:ToggleTargetNameplate()
    BordoUIDB = BordoUIDB or {};
    if ( BordoUIDB.nameplateShowTarget == nil ) then
        BordoUIDB.nameplateShowTarget = true;
    end
    BordoUIDB.nameplateShowTarget = not BordoUIDB.nameplateShowTarget;
    local st = BordoUIDB.nameplateShowTarget and "|cff55ff55[SHOWN]|r" or "|cffff3333[FILTERED]|r";
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Target Nameplate Override is now " .. st .. ".");
    self:UpdateNameplatesWindowUI();
end

-- =========================================================================
-- Modern Settings Window for Nameplates & Threat Filtering
-- =========================================================================

local npWin = nil;

local function CreateStyledFilterButton(parent, label, x, y, width, height, onClick)
    local btn = CreateFrame("Button", nil, parent);
    btn:SetWidth(width);
    btn:SetHeight(height);
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    
    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 8,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
    btn:SetBackdropBorderColor(0.20, 0.20, 0.26, 0.95);
    
    local txt = btn:CreateFontString(nil, "OVERLAY");
    txt:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    txt:SetPoint("CENTER", btn, "CENTER", 0, 0);
    txt:SetText(label);
    txt:SetTextColor(0.70, 0.70, 0.70);
    btn.text = txt;
    
    local hl = btn:CreateTexture(nil, "HIGHLIGHT");
    hl:SetAllPoints(btn);
    hl:SetTexture("Interface\\Buttons\\CheckButtonHilight");
    hl:SetBlendMode("ADD");
    hl:SetAlpha(0.25);
    
    btn:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn");
        if ( onClick ) then onClick(btn); end
    end);
    
    btn:SetScript("OnEnter", function()
        btn:SetBackdropBorderColor(0.0, 0.8, 1.0, 1.0);
    end);
    
    btn:SetScript("OnLeave", function()
        if ( BordoUI and BordoUI.UpdateNameplatesWindowUI ) then
            BordoUI:UpdateNameplatesWindowUI();
        end
    end);
    
    return btn;
end

function BordoUI:CreateNameplatesSettingsWindow()
    if ( npWin ) then return npWin; end
    
    npWin = CreateFrame("Frame", "BordoUI_NameplatesWindow", UIParent);
    npWin:SetWidth(380);
    npWin:SetHeight(185);
    npWin:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    npWin:SetFrameStrata("HIGH");
    npWin:SetFrameLevel(25);
    npWin:SetClampedToScreen(true);
    npWin:SetMovable(true);
    npWin:EnableMouse(true);
    npWin:RegisterForDrag("LeftButton");
    
    npWin:SetScript("OnDragStart", function()
        if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
            npWin:StartMoving();
        end
    end);
    npWin:SetScript("OnDragStop", function()
        npWin:StopMovingOrSizing();
        local pt, _, relPt, x, y = npWin:GetPoint();
        BordoUIDB = BordoUIDB or {};
        BordoUIDB.nameplatesFramePos = { point = pt, relativePoint = relPt, x = x, y = y };
    end);
    
    npWin:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    npWin:SetBackdropColor(0.04, 0.04, 0.07, 0.96);
    npWin:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.95);
    npWin:Hide();
    
    -- Window Title & Subtitle
    local title = npWin:CreateFontString(nil, "OVERLAY");
    title:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE");
    title:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -8);
    title:SetText("|cff00ccffBordo UI|r |cffffd100Nameplates & Threat Filter|r");
    
    local subtitle = npWin:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
    subtitle:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -23);
    subtitle:SetTextColor(0.65, 0.65, 0.65);
    subtitle:SetText("Filter enemy healthbars: keep Bosses & Elites visible while hiding add clutter.");
    npWin.subtitle = subtitle;
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, npWin);
    closeBtn:SetWidth(18);
    closeBtn:SetHeight(18);
    closeBtn:SetPoint("TOPRIGHT", npWin, "TOPRIGHT", -6, -6);
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
    closeTxt:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE");
    closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
    closeTxt:SetText("X");
    closeTxt:SetTextColor(0.7, 0.7, 0.7);
    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.2, 0.2); end);
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.7, 0.7, 0.7); end);
    closeBtn:SetScript("OnClick", function() npWin:Hide(); PlaySound("igMainMenuClose"); end);
    
    -- Section 1 Header: Enemy Healthbar Filter
    local sec1 = npWin:CreateFontString(nil, "OVERLAY");
    sec1:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    sec1:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -42);
    sec1:SetText("|cffffd100ENEMY HEALTHBAR FILTER|r");
    
    -- Row 1: 3 Filter Buttons
    npWin.btnAll = CreateStyledFilterButton(npWin, "All Enemies", 12, -58, 114, 26, function()
        BordoUI:SetNameplateFilter("all");
    end);
    
    npWin.btnBosses = CreateStyledFilterButton(npWin, "Bosses & Elites", 133, -58, 114, 26, function()
        BordoUI:SetNameplateFilter("bosses");
    end);
    
    npWin.btnOff = CreateStyledFilterButton(npWin, "Disabled", 254, -58, 114, 26, function()
        BordoUI:SetNameplateFilter("off");
    end);
    
    -- Section 2 Header: Display Options
    local sec2 = npWin:CreateFontString(nil, "OVERLAY");
    sec2:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    sec2:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -95);
    sec2:SetText("|cffffd100DISPLAY OPTIONS|r");
    
    -- Row 2: 3 Display Option Buttons
    npWin.btnTeammates = CreateStyledFilterButton(npWin, "Teammates: ON", 12, -112, 172, 24, function()
        BordoUI:ToggleFriendlyNameplates();
    end);
    
    npWin.btnTarget = CreateStyledFilterButton(npWin, "Target Bar: ON", 196, -112, 172, 24, function()
        BordoUI:ToggleTargetNameplate();
    end);
    
    -- Status Line
    local status = npWin:CreateFontString(nil, "OVERLAY");
    status:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
    status:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -145);
    status:SetText("Filter: |cff55ff55All Enemies|r");
    npWin.statusText = status;
    
    -- Hint Line
    local hint = npWin:CreateFontString(nil, "OVERLAY");
    hint:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
    hint:SetPoint("TOPLEFT", npWin, "TOPLEFT", 12, -164);
    hint:SetTextColor(0.50, 0.50, 0.50);
    hint:SetText("Minimap Dock: Right-Click icon to quick-cycle   -   Shift-Click for teammates");
    
    return npWin;
end

function BordoUI:UpdateNameplatesWindowUI()
    if ( not npWin ) then return; end
    
    local filter = self:GetNameplateFilter();
    
    -- Update Filter Buttons
    local btns = {
        { btn = npWin.btnAll, key = "all", label = "All Enemies", activeColor = { 0.0, 0.8, 1.0, 1.0 } },
        { btn = npWin.btnBosses, key = "bosses", label = "Bosses & Elites", activeColor = { 1.0, 0.82, 0.0, 1.0 } },
        { btn = npWin.btnOff, key = "off", label = "Disabled", activeColor = { 1.0, 0.3, 0.3, 1.0 } }
    };
    
    for i = 1, table.getn(btns) do
        local item = btns[i];
        local b = item.btn;
        if ( b ) then
            if ( filter == item.key ) then
                b:SetBackdropColor(0.12, 0.22, 0.32, 0.95);
                b:SetBackdropBorderColor(item.activeColor[1], item.activeColor[2], item.activeColor[3], item.activeColor[4]);
                b.text:SetTextColor(item.activeColor[1], item.activeColor[2], item.activeColor[3]);
            else
                b:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
                b:SetBackdropBorderColor(0.20, 0.20, 0.26, 0.95);
                b.text:SetTextColor(0.65, 0.65, 0.65);
            end
        end
    end
    
    -- Update Display Options
    local friendly = (not BordoUIDB or BordoUIDB.friendlyNameplates ~= false);
    if ( npWin.btnTeammates ) then
        if ( friendly ) then
            npWin.btnTeammates.text:SetText("|cff55ff55Teammates: ON|r");
            npWin.btnTeammates:SetBackdropBorderColor(0.15, 0.85, 0.30, 0.95);
        else
            npWin.btnTeammates.text:SetText("|cffff3333Teammates: OFF|r");
            npWin.btnTeammates:SetBackdropBorderColor(0.25, 0.25, 0.30, 0.90);
        end
    end
    
    local showTarget = (not BordoUIDB or BordoUIDB.nameplateShowTarget ~= false);
    if ( npWin.btnTarget ) then
        if ( showTarget ) then
            npWin.btnTarget.text:SetText("|cff55ff55Target Bar: ON|r");
            npWin.btnTarget:SetBackdropBorderColor(0.15, 0.85, 0.30, 0.95);
        else
            npWin.btnTarget.text:SetText("|cffff3333Target Bar: OFF|r");
            npWin.btnTarget:SetBackdropBorderColor(0.25, 0.25, 0.30, 0.90);
        end
    end
    
    -- Update Status Line
    if ( npWin.statusText ) then
        local filterLabel = (filter == "bosses" and "|cffffd100Bosses & Elites Only|r") or (filter == "off" and "|cffff3333Disabled|r") or "|cff55ff55All Enemies|r";
        local addsLabel = (filter == "bosses" and "|cffff3333Hidden|r") or (filter == "off" and "|cffff3333Hidden|r") or "|cff55ff55Shown|r";
        local allyLabel = (friendly and "|cff55ff55Visible|r") or "|cffff3333Hidden|r";
        npWin.statusText:SetText("Filter: " .. filterLabel .. "   |cff555555-|r   Trash Adds: " .. addsLabel .. "   |cff555555-|r   Teammates: " .. allyLabel);
    end
end

function BordoUI:ToggleNameplatesWindow()
    local win = npWin or self:CreateNameplatesSettingsWindow();
    if ( win:IsShown() ) then
        win:Hide();
        PlaySound("igMainMenuClose");
    else
        if ( BordoUIDB and BordoUIDB.nameplatesFramePos ) then
            local pos = BordoUIDB.nameplatesFramePos;
            win:ClearAllPoints();
            win:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 0);
        end
        self:UpdateNameplatesWindowUI();
        win:Show();
        PlaySound("igMainMenuOpen");
    end
end

-- =========================================================================
-- Continuous Scanner for Active Nameplates
-- =========================================================================

local scanFrame = CreateFrame("Frame", "AZSHelper_NameplateScanner");
local scanElapsed = 0;

scanFrame:SetScript("OnUpdate", function()
    local elapsed = arg1 or 0.05;
    scanElapsed = scanElapsed + elapsed;
    if ( scanElapsed < 0.02 ) then return; end
    scanElapsed = 0;
    
    local frames = { WorldFrame:GetChildren() };
    for i = 1, table.getn(frames) do
        local f = frames[i];
        if ( IsNameplate(f) and f:IsShown() ) then
            StyleNameplate(f);
        end
    end
end);
