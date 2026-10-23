--[[
    AZS Helper - Death Recap / Todesursache (DeathRecap.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    - Zeigt genau an, warum der Spieler gestorben ist (Todesstoß + chronologischer Schadensverlauf)
    - Gesamtdurchlauf-Schadensquellen (AZS_TAKEN) komplett entfernt -> 100% Fokus auf Todesursache
    - Jeder Treffer zeigt: HP vorher, eingesteckter Schlag/Zauber, und HP nachher
    - Bleibt nach dem Tod im Vordergrund stehen (TOOLTIP-Strata, Level 500)
    - Vollständig verschiebbar & wieder zu öffnen mit /azs death oder /azs recap
]]--

AZSHelper.RecentHitsTaken = {}; -- Chronologischer Puffer der letzten Schläge
local MAX_LOGGED_HITS = 7;
local trackedHp = nil;
local trackedMaxHp = 100;

-- 1. Helper: Spieler-Lebenspunkte abfragen
local function GetPlayerHealth()
    local hp = (AZS_RUN and AZS_RUN.hp) or UnitHealth("player") or 0;
    local maxHp = (AZS_RUN and AZS_RUN.hpm) or UnitHealthMax("player") or 100;
    if ( not maxHp or maxHp <= 0 ) then maxHp = 100; end
    return hp, maxHp;
end

-- Helper: HP farbig mit Prozent formatieren
local function FormatHpWithColor(hp, maxHp)
    if ( not hp or hp <= 0 ) then
        return "|cffff20200 HP|r";
    end
    local pct = (maxHp and maxHp > 0) and (hp / maxHp) or 1;
    local color = "55ff55"; -- Grün (> 50%)
    if ( pct <= 0.25 ) then
        color = "ff3333"; -- Rot (<= 25%)
    elseif ( pct <= 0.50 ) then
        color = "ffaa00"; -- Orange/Gelb (25-50%)
    end
    return string.format("|cff%s%s HP|r |cff888888(%d%%)|r",
        color, AZSHelper:FormatNumber(hp), math.floor(pct * 100));
end

-- 2. Incoming Damage Logger
local function LogHitTaken(attacker, spell, amount, isCrit)
    if ( not amount or amount <= 0 ) then return; end
    
    local liveHp, liveMax = GetPlayerHealth();
    if ( not trackedHp or trackedHp <= 0 ) then
        trackedHp = (liveHp > 0) and liveHp or liveMax;
    end
    trackedMaxHp = liveMax;
    
    local hpBefore = trackedHp;
    local hpAfter = math.max(0, hpBefore - amount);
    
    -- Falls liveHp positiv und geringer als hpAfter, synchronisieren
    if ( liveHp > 0 and liveHp < hpAfter ) then
        hpAfter = liveHp;
    end
    trackedHp = hpAfter;
    
    local hit = {
        time     = GetTime(),
        attacker = attacker or "Gegner",
        spell    = spell or "Nahkampf",
        amount   = amount,
        isCrit   = isCrit or false,
        hpBefore = hpBefore,
        hpAfter  = hpAfter,
        maxHp    = liveMax,
    };
    
    table.insert(AZSHelper.RecentHitsTaken, hit);
    if ( table.getn(AZSHelper.RecentHitsTaken) > MAX_LOGGED_HITS ) then
        table.remove(AZSHelper.RecentHitsTaken, 1);
    end
end

-- 3. Combat Log Watcher
local hitWatcher = CreateFrame("Frame", "AZSHelper_DamageTakenWatcher");
hitWatcher:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");
hitWatcher:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");
hitWatcher:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS");
hitWatcher:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE");
hitWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
hitWatcher:RegisterEvent("UNIT_HEALTH");
hitWatcher:RegisterEvent("PLAYER_DEAD");

hitWatcher:SetScript("OnEvent", function()
    if ( event == "PLAYER_DEAD" ) then
        if ( AZSHelper.ShowDeathRecap ) then
            AZSHelper:ShowDeathRecap();
        end
        return;
    end
    
    if ( event == "UNIT_HEALTH" ) then
        if ( arg1 == "player" ) then
            local liveHp = UnitHealth("player") or 0;
            if ( liveHp > 0 ) then
                -- Bei Heilung oder Spielstart aktualisieren
                if ( not trackedHp or liveHp > trackedHp ) then
                    trackedHp = liveHp;
                end
            end
        end
        return;
    end
    
    local msg = arg1;
    if ( not msg ) then return; end
    
    local lower = string.lower(msg);
    local isCrit = (string.find(lower, "crit") ~= nil) or (string.find(lower, "krit") ~= nil);
    
    -- 1. Schadensmenge extrahieren
    local numStr = nil;
    local _, _, n1 = string.find(msg, "for (%d+)");
    if ( n1 ) then numStr = n1; end
    if ( not numStr ) then
        local _, _, n2 = string.find(msg, "f%A+r (%d+)");
        if ( n2 ) then numStr = n2; end
    end
    if ( not numStr ) then
        local _, _, n3 = string.find(msg, "erleidet (%d+)");
        if ( n3 ) then numStr = n3; end
    end
    if ( not numStr ) then
        local _, _, n4 = string.find(msg, "suffer (%d+)");
        if ( n4 ) then numStr = n4; end
    end
    if ( not numStr ) then
        local gFunc = string.gfind or string.gmatch;
        if ( gFunc ) then
            for w in gFunc(msg, "(%d+)") do numStr = w; end
        end
    end
    local amount = tonumber(numStr or 0);
    if ( not amount or amount <= 0 ) then return; end
    
    -- 2. Angreifer & Fähigkeit extrahieren
    local attacker = "Gegner";
    local spell = "Nahkampf";
    
    -- Deutsch Zauber: "Edwin VanCleefs Schattenblitz trifft Euch..."
    local _, _, a1, s1 = string.find(msg, "^(.+)s (.+) trifft Euch");
    if ( a1 and s1 ) then
        attacker = a1; spell = s1;
    else
        -- Deutsch DoT: "Ihr erleidet 45 Feuerschaden von Ragnaros' Feuersbrunst."
        local _, _, a2, s2 = string.find(msg, "von (.+)s (.+)%.");
        if ( a2 and s2 ) then
            attacker = a2; spell = s2;
        else
            -- Deutsch Nahkampf: "Edwin VanCleef trifft Euch..."
            local _, _, a3 = string.find(msg, "^(.+) trifft Euch");
            if ( a3 ) then
                attacker = a3; spell = "Nahkampf";
            else
                -- Englisch Zauber: "Edwin VanCleef's Shadow Bolt hits/crits you..."
                local _, _, a4, s4 = string.find(msg, "^(.+)'s (.+) hits you");
                if ( not a4 ) then
                    _, _, a4, s4 = string.find(msg, "^(.+)'s (.+) crits you");
                end
                if ( a4 and s4 ) then
                    attacker = a4; spell = s4;
                else
                    -- Englisch DoT: "You suffer 45 Fire damage from Ragnaros's Immolate."
                    local _, _, a5, s5 = string.find(msg, "from (.+)'s (.+)%.");
                    if ( a5 and s5 ) then
                        attacker = a5; spell = s5;
                    else
                        -- Englisch Melee: "Edwin VanCleef hits/crits you..."
                        local _, _, a6 = string.find(msg, "^(.+) hits you");
                        if ( not a6 ) then
                            _, _, a6 = string.find(msg, "^(.+) crits you");
                        end
                        if ( a6 ) then
                            attacker = a6; spell = "Nahkampf";
                        end
                    end
                end
            end
        end
    end
    
    LogHitTaken(attacker, spell, amount, isCrit);
end);

-- =========================================================================
-- 4. DEATH RECAP WINDOW
-- =========================================================================
local recapFrame = CreateFrame("Frame", "AZSHelper_DeathRecapFrame", UIParent);
recapFrame:SetWidth(420);
recapFrame:SetHeight(460);
recapFrame:SetPoint("RIGHT", UIParent, "CENTER", -260, 20);
recapFrame:SetFrameStrata("TOOLTIP"); -- Höchste Strata: Niemals von Defeat-Fenster überdeckt
recapFrame:SetFrameLevel(500);
recapFrame:SetClampedToScreen(true);
AZSHelper:MakeMovable(recapFrame, "deathRecapPos");
tinsert(UISpecialFrames, "AZSHelper_DeathRecapFrame"); -- Mit ESC schließbar
recapFrame:Hide();

-- Modernes dunkles Design mit roter Umrandung
recapFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 14,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
});
recapFrame:SetBackdropColor(0.05, 0.04, 0.07, 0.96);
recapFrame:SetBackdropBorderColor(0.90, 0.15, 0.15, 0.95); -- Blutrot

-- Header Bar (Verschiebbar)
local header = CreateFrame("Frame", nil, recapFrame);
header:SetPoint("TOPLEFT", recapFrame, "TOPLEFT", 4, -4);
header:SetPoint("BOTTOMRIGHT", recapFrame, "TOPRIGHT", -4, -28);
header:EnableMouse(true);
header:RegisterForDrag("LeftButton");
header:SetScript("OnDragStart", function() recapFrame:StartMoving(); end);
header:SetScript("OnDragStop", function()
    recapFrame:StopMovingOrSizing();
    local point, _, relPoint, x, y = recapFrame:GetPoint();
    if ( AZSHelperDB ) then
        AZSHelperDB.deathRecapPos = { point = point, relativePoint = relPoint, x = x, y = y };
    end
end);

local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
titleText:SetPoint("LEFT", header, "LEFT", 8, 0);
titleText:SetText("|cffff2525☠ DEATH RECAP & RECENT HITS ☠|r");

local closeBtn = CreateFrame("Button", nil, recapFrame, "UIPanelCloseButton");
closeBtn:SetPoint("TOPRIGHT", recapFrame, "TOPRIGHT", -2, -2);
closeBtn:SetScript("OnClick", function() recapFrame:Hide(); end);

-- Card 1: Highlight Killing Blow
local kbCard = CreateFrame("Frame", nil, recapFrame);
kbCard:SetPoint("TOPLEFT", recapFrame, "TOPLEFT", 10, -32);
kbCard:SetPoint("RIGHT", recapFrame, "RIGHT", -10, 0);
kbCard:SetHeight(74);
kbCard:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
kbCard:SetBackdropColor(0.14, 0.03, 0.03, 0.90);
kbCard:SetBackdropBorderColor(1.0, 0.20, 0.20, 0.90);

local kbTitle = kbCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
kbTitle:SetPoint("TOPLEFT", kbCard, "TOPLEFT", 8, -6);
kbTitle:SetText("|cffff4444☠ KILLING BLOW ☠|r");

local kbAttacker = kbCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
kbAttacker:SetPoint("TOPLEFT", kbTitle, "BOTTOMLEFT", 0, -2);
kbAttacker:SetTextColor(1.0, 0.85, 0.2);
recapFrame.kbAttacker = kbAttacker;

local kbDetails = kbCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
kbDetails:SetPoint("TOPLEFT", kbAttacker, "BOTTOMLEFT", 0, -2);
recapFrame.kbDetails = kbDetails;

local kbHpStep = kbCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
kbHpStep:SetPoint("TOPLEFT", kbDetails, "BOTTOMLEFT", 0, -2);
recapFrame.kbHpStep = kbHpStep;

-- Section 2: Chronological HP Loss Before Death
local hitsSectionTitle = recapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hitsSectionTitle:SetPoint("TOPLEFT", kbCard, "BOTTOMLEFT", 4, -8);
hitsSectionTitle:SetText("|cffddbb66RECENT DAMAGE TAKEN (HP HISTORY):|r");

recapFrame.hitRowFrames = {};
local MAX_DISPLAY_ROWS = 6;

for i = 1, MAX_DISPLAY_ROWS do
    local rowFrame = CreateFrame("Frame", nil, recapFrame);
    rowFrame:SetHeight(36);
    rowFrame:SetPoint("TOPLEFT", kbCard, "BOTTOMLEFT", 0, -26 - ((i - 1) * 40));
    rowFrame:SetPoint("RIGHT", recapFrame, "RIGHT", -10, 0);
    
    rowFrame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    rowFrame:SetBackdropColor(0.06, 0.07, 0.10, 0.85);
    rowFrame:SetBackdropBorderColor(0.25, 0.28, 0.35, 0.60);
    
    -- Zeile 1: Zeit, Angreifer, Fähigkeit, Krit-Info
    local titleLine = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    titleLine:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 8, -4);
    titleLine:SetPoint("RIGHT", rowFrame, "RIGHT", -8, 0);
    titleLine:SetJustifyH("LEFT");
    
    -- Zeile 2: HP Vorher ──[ -Schaden ]──> HP Nachher
    local hpLine = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    hpLine:SetPoint("TOPLEFT", titleLine, "BOTTOMLEFT", 0, -2);
    hpLine:SetPoint("RIGHT", rowFrame, "RIGHT", -8, 0);
    hpLine:SetJustifyH("LEFT");
    
    rowFrame.titleLine = titleLine;
    rowFrame.hpLine = hpLine;
    recapFrame.hitRowFrames[i] = rowFrame;
end

-- Card 3: Run Summary at Death
local sumCard = CreateFrame("Frame", nil, recapFrame);
sumCard:SetPoint("BOTTOMLEFT", recapFrame, "BOTTOMLEFT", 10, 36);
sumCard:SetPoint("BOTTOMRIGHT", recapFrame, "BOTTOMRIGHT", -10, 36);
sumCard:SetHeight(28);
sumCard:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
sumCard:SetBackdropColor(0.07, 0.07, 0.10, 0.85);
sumCard:SetBackdropBorderColor(0.3, 0.6, 0.9, 0.6);

local sumText = sumCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
sumText:SetPoint("CENTER", sumCard, "CENTER", 0, 0);
recapFrame.sumText = sumText;

-- Bottom Close Button
local btnClose = CreateFrame("Button", nil, recapFrame, "UIPanelButtonTemplate");
btnClose:SetWidth(140);
btnClose:SetHeight(22);
btnClose:SetPoint("BOTTOM", recapFrame, "BOTTOM", 0, 8);
btnClose:SetText("Close (ESC)");
btnClose:SetScript("OnClick", function() recapFrame:Hide(); end);

-- =========================================================================
-- 5. POPULATE & SHOW RECAP
-- =========================================================================
function AZSHelper:ShowDeathRecap()
    local numHits = table.getn(AZSHelper.RecentHitsTaken);
    local deathTime = GetTime();
    local maxHp = trackedMaxHp or 100;
    
    -- Mark last hit as lethal (hpAfter = 0)
    if ( numHits > 0 ) then
        local lastHit = AZSHelper.RecentHitsTaken[numHits];
        lastHit.hpAfter = 0;
        
        local critTag = lastHit.isCrit and " |cffff0000(Critical)|r" or "";
        local overkill = math.max(0, lastHit.amount - lastHit.hpBefore);
        local overStr = (overkill > 0) and string.format(" |cff888888(%s Overkill)|r", AZSHelper:FormatNumber(overkill)) or "";
        
        recapFrame.kbAttacker:SetText(lastHit.attacker);
        recapFrame.kbDetails:SetText(string.format("Ability: |cffffffff%s%s|r   •   Damage: |cffff2222%s|r",
            lastHit.spell, critTag, AZSHelper:FormatNumber(lastHit.amount)));
        recapFrame.kbHpStep:SetText(string.format("HP Loss: %s  |cffff2222──>|r  |cffff2020 0 HP [KILLING BLOW]%s|r",
            FormatHpWithColor(lastHit.hpBefore, lastHit.maxHp or maxHp), overStr));
    else
        recapFrame.kbAttacker:SetText("Unknown Damage");
        recapFrame.kbDetails:SetText("Ability: Lethal Hit");
        recapFrame.kbHpStep:SetText("No combat log details available before death.");
    end
    
    -- Display up to 6 hits prior to death
    local startIdx = math.max(1, numHits - MAX_DISPLAY_ROWS + 1);
    local displayCount = (numHits >= startIdx) and (numHits - startIdx + 1) or 0;
    
    for i = 1, MAX_DISPLAY_ROWS do
        local rowFrame = recapFrame.hitRowFrames[i];
        if ( i <= displayCount ) then
            local hitIdx = startIdx + (i - 1);
            local h = AZSHelper.RecentHitsTaken[hitIdx];
            local dt = math.max(0, deathTime - h.time);
            local cTag = h.isCrit and " |cffff3333[CRIT]|r" or "";
            local isFatal = (hitIdx == numHits);
            local fatalTag = isFatal and " |cffff2020☠ KILLING BLOW ☠|r" or "";
            
            -- Row 1: [-0.4s] Attacker • Spell [CRIT]
            rowFrame.titleLine:SetText(string.format("|cff888888[-%.1fs]|r  |cffffd100%s|r  •  |cffffffff%s|r%s%s",
                dt, h.attacker, h.spell, cTag, fatalTag));
            
            -- Row 2: HP Before ──[ -Damage ]──> HP After
            local hMax = h.maxHp or maxHp;
            local hpBeforeStr = FormatHpWithColor(h.hpBefore, hMax);
            
            if ( isFatal or h.hpAfter <= 0 ) then
                local ok = math.max(0, h.amount - h.hpBefore);
                local okStr = (ok > 0) and string.format(" |cff888888(%s Overkill)|r", AZSHelper:FormatNumber(ok)) or "";
                rowFrame.hpLine:SetText(string.format("%s   |cffff2222──[ -%s Damage ]──>|r   |cffff2020 0 HP [DEFEATED]%s|r",
                    hpBeforeStr, AZSHelper:FormatNumber(h.amount), okStr));
                -- Red tinted border for the final fatal hit
                rowFrame:SetBackdropColor(0.14, 0.04, 0.04, 0.90);
                rowFrame:SetBackdropBorderColor(0.90, 0.20, 0.20, 0.85);
            else
                local hpAfterStr = FormatHpWithColor(h.hpAfter, hMax);
                rowFrame.hpLine:SetText(string.format("%s   |cffff4444──[ -%s Damage ]──>|r   %s",
                    hpBeforeStr, AZSHelper:FormatNumber(h.amount), hpAfterStr));
                -- Dark border
                rowFrame:SetBackdropColor(0.06, 0.07, 0.10, 0.85);
                rowFrame:SetBackdropBorderColor(0.25, 0.28, 0.35, 0.60);
            end
            
            rowFrame:Show();
        else
            rowFrame:Hide();
        end
    end
    
    -- Run Summary at Death
    local t = (AZS_RUN and AZS_RUN.t) or (AZS_END and AZS_END.t) or 0;
    local lvl = (AZS_RUN and AZS_RUN.lvl) or (AZS_END and AZS_END.lvl) or 1;
    local kills = (AZS_RUN and AZS_RUN.kills) or 0;
    local gold = (AZS_RUN and AZS_RUN.gold) or 0;
    local bosses = (AZS_RUN and AZS_RUN.bk) or 0;
    
    recapFrame.sumText:SetText(string.format("Survived: |cffffffff%s|r   |   Level: |cffffffff%d|r   |   Kills: |cffffffff%s|r   |   Bosses: |cffffffff%d|r   |   Gold: |cffffd100%s|r",
        AZSHelper:FormatTime(t), lvl, AZSHelper:FormatNumber(kills), bosses, AZSHelper:FormatNumber(gold)));
        
    -- Restore position or anchor cleanly to center
    if ( AZSHelperDB and AZSHelperDB.deathRecapPos and AZSHelperDB.deathRecapPos.point ) then
        AZSHelper:RestorePosition(recapFrame, AZSHelperDB.deathRecapPos);
    else
        recapFrame:ClearAllPoints();
        recapFrame:SetPoint("RIGHT", UIParent, "CENTER", -260, 20);
    end
    
    -- Ensure Death Recap is on top
    recapFrame:SetFrameStrata("TOOLTIP");
    recapFrame:SetFrameLevel(500);
    recapFrame:Show();
    if ( recapFrame.Raise ) then
        recapFrame:Raise();
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Bordo UI]|r You have fallen! Death Recap opened. Type |cffffd100/bordo recap|r to view again.");
end

-- Slash Commands
SLASH_AZSDEATH1 = "/azs death";
SLASH_AZSDEATH2 = "/azs recap";
SLASH_AZSDEATH3 = "/azs tod";
SlashCmdList["AZSDEATH"] = function(msg)
    msg = string.lower(msg or "");
    if ( msg == "reset" ) then
        if ( AZSHelperDB ) then
            AZSHelperDB.deathRecapPos = { point = "RIGHT", relativePoint = "CENTER", x = -260, y = 20 };
        end
        recapFrame:ClearAllPoints();
        recapFrame:SetPoint("RIGHT", UIParent, "CENTER", -260, 20);
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Death Recap position reset.");
    end
    AZSHelper:ShowDeathRecap();
end;

-- 6. Monitor Phase Changes to Trigger or Hide
local deathMonitor = CreateFrame("Frame", "AZSHelper_DeathMonitor");
local deathElapsed = 0;
local lastDeathPhase = nil;

deathMonitor:SetScript("OnUpdate", function()
    deathElapsed = deathElapsed + arg1;
    if ( deathElapsed < 0.20 ) then return; end
    deathElapsed = 0;
    
    local phase = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph);
    
    -- Bei Phasenwechsel zu Tod automatisch öffnen
    if ( (phase == "dead" or phase == "defeat") and lastDeathPhase ~= "dead" and lastDeathPhase ~= "defeat" ) then
        AZSHelper:ShowDeathRecap();
    end
    
    -- Automatisch ausblenden, sobald ein neuer Run beginnt
    if ( phase == "ready" or phase == "playing" ) then
        if ( lastDeathPhase == "dead" or lastDeathPhase == "defeat" ) then
            recapFrame:Hide();
            AZSHelper.RecentHitsTaken = {};
            trackedHp = nil;
        end
    end
    
    lastDeathPhase = phase;
end);
