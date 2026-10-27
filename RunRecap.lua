--[[
    Bordo UI 2.0 - End-of-Run Victory / Defeat Screen (RunRecap.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Elegant arcade-style summary screen on run completion (15:00) or defeat
    - Comprehensive breakdown: Survived Time, Kills, Gold, Level, Total Damage, DPS, and MVP Ability
    - Discord-ready aesthetic with clean watermark
    - Auto-triggers at end of run; toggle/review anytime with /bordo recap
    - Test anytime with /bordo testrecap victory or /bordo testrecap defeat
]]--

BordoUI = BordoUI or {};
AZSHelper = AZSHelper or {};

local FONT_PATH = "Fonts\\ARIALN.TTF";
local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";

local recapFrame = nil;
local lastRunData = nil;

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0));
    local m = math.floor(seconds / 60);
    local s = math.mod(seconds, 60);
    return string.format("%d:%02d", m, s);
end

local function FormatBigNum(num)
    num = tonumber(num) or 0;
    if ( num >= 1000000 ) then
        return string.format("%.2fM", num / 1000000);
    elseif ( num >= 1000 ) then
        return string.format("%.1fK", num / 1000);
    else
        return string.format("%d", math.floor(num));
    end
end

local function CreateStatCard(parent, title, valueText, x, y, w, h)
    local card = CreateFrame("Frame", nil, parent);
    card:SetWidth(w);
    card:SetHeight(h);
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    
    card:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true, tileSize = 12, edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    card:SetBackdropColor(0.05, 0.05, 0.08, 0.95);
    card:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.95);
    
    local titleStr = card:CreateFontString(nil, "OVERLAY");
    titleStr:SetFont(FONT_PATH, 8, "OUTLINE");
    titleStr:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -5);
    titleStr:SetTextColor(0.65, 0.65, 0.65);
    titleStr:SetText(title);
    card.titleStr = titleStr;
    
    local valStr = card:CreateFontString(nil, "OVERLAY");
    valStr:SetFont(FONT_PATH, 11, "OUTLINE");
    valStr:SetPoint("LEFT", card, "LEFT", 8, -5);
    valStr:SetTextColor(1.0, 1.0, 1.0);
    valStr:SetText(valueText);
    card.valStr = valStr;
    
    -- Optional Icon
    local icon = card:CreateTexture(nil, "ARTWORK");
    icon:SetWidth(18);
    icon:SetHeight(18);
    icon:SetPoint("RIGHT", card, "RIGHT", -6, 0);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    icon:Hide();
    card.icon = icon;
    
    return card;
end

function BordoUI:CreateRunRecapWindow()
    if ( recapFrame ) then return recapFrame; end
    
    recapFrame = CreateFrame("Frame", "BordoUI_RunRecapFrame", UIParent);
    recapFrame:SetWidth(420);
    recapFrame:SetHeight(320);
    recapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
    recapFrame:SetFrameStrata("DIALOG");
    recapFrame:SetFrameLevel(40);
    recapFrame:SetClampedToScreen(true);
    recapFrame:SetMovable(true);
    recapFrame:EnableMouse(true);
    recapFrame:RegisterForDrag("LeftButton");
    
    recapFrame:SetScript("OnDragStart", function() recapFrame:StartMoving(); end);
    recapFrame:SetScript("OnDragStop", function() recapFrame:StopMovingOrSizing(); end);
    
    recapFrame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true, tileSize = 12, edgeSize = 12,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 }
    });
    recapFrame:SetBackdropColor(0.03, 0.03, 0.05, 0.98);
    recapFrame:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.95);
    recapFrame:Hide();
    
    -- Main Header
    local title = recapFrame:CreateFontString(nil, "OVERLAY");
    title:SetFont(FONT_PATH, 16, "OUTLINE");
    title:SetPoint("TOP", recapFrame, "TOP", 0, -14);
    title:SetText("|cffffd100VICTORY!|r");
    recapFrame.title = title;
    
    local subtitle = recapFrame:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont(FONT_PATH, 9, "OUTLINE");
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -3);
    subtitle:SetTextColor(0.8, 0.8, 0.8);
    subtitle:SetText("Run Completed - 15:00 Cleared!");
    recapFrame.subtitle = subtitle;
    
    -- 6 Stat Cards (2 columns x 3 rows)
    local cardW = 190;
    local cardH = 46;
    local col1X = 14;
    local col2X = 216;
    local rowY = { -62, -116, -170 };
    
    recapFrame.cards = {};
    recapFrame.cards.time   = CreateStatCard(recapFrame, "SURVIVED TIME", "15:00", col1X, rowY[1], cardW, cardH);
    recapFrame.cards.kills  = CreateStatCard(recapFrame, "ENEMIES SLAIN", "0", col2X, rowY[1], cardW, cardH);
    recapFrame.cards.gold   = CreateStatCard(recapFrame, "GOLD COLLECTED", "0", col1X, rowY[2], cardW, cardH);
    recapFrame.cards.level  = CreateStatCard(recapFrame, "HERO LEVEL", "Level 1", col2X, rowY[2], cardW, cardH);
    recapFrame.cards.damage = CreateStatCard(recapFrame, "TOTAL DAMAGE & DPS", "0 (0 DPS)", col1X, rowY[3], cardW, cardH);
    recapFrame.cards.mvp    = CreateStatCard(recapFrame, "MVP ABILITY", "None", col2X, rowY[3], cardW, cardH);
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, recapFrame);
    closeBtn:SetWidth(180);
    closeBtn:SetHeight(26);
    closeBtn:SetPoint("BOTTOM", recapFrame, "BOTTOM", 0, 24);
    closeBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true, tileSize = 12, edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    closeBtn:SetBackdropColor(0.08, 0.14, 0.22, 0.95);
    closeBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
    
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
    closeTxt:SetFont(FONT_PATH, 10, "OUTLINE");
    closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
    closeTxt:SetText(">> Close Recap <<");
    closeTxt:SetTextColor(0.00, 0.90, 1.00);
    
    closeBtn:SetScript("OnEnter", function()
        closeBtn:SetBackdropBorderColor(1.0, 0.82, 0.20, 1.0);
        closeTxt:SetTextColor(1.0, 0.82, 0.20);
    end);
    closeBtn:SetScript("OnLeave", function()
        closeBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
        closeTxt:SetTextColor(0.00, 0.90, 1.00);
    end);
    closeBtn:SetScript("OnClick", function()
        recapFrame:Hide();
        PlaySound("igMainMenuClose");
    end);
    
    -- Watermark
    local watermark = recapFrame:CreateFontString(nil, "OVERLAY");
    watermark:SetFont(FONT_PATH, 8, "OUTLINE");
    watermark:SetPoint("BOTTOM", recapFrame, "BOTTOM", 0, 8);
    watermark:SetTextColor(0.40, 0.40, 0.45);
    watermark:SetText("Bordo UI 2.0  -  Azeroth Survivors");
    
    return recapFrame;
end

-- Populate and Display the Recap
function BordoUI:ShowRunRecap(isVictory, customData)
    local frame = self:CreateRunRecapWindow();
    
    -- Gather Run Data
    local data = customData;
    if ( not data ) then
        local runTime = (AZS_RUN and AZS_RUN.time) or (AZS_GetTimer and AZS_GetTimer()) or 0;
        local kills = (AZS_RUN and AZS_RUN.kills) or 0;
        local gold = (AZS_RUN and AZS_RUN.gold) or 0;
        local level = UnitLevel("player") or 1;
        
        -- Meter Data
        local totalDmg = 0;
        local dps = 0;
        local topSpellName = "Attack";
        local topSpellDmg = 0;
        local topSpellIcon = "Interface\\Icons\\INV_Sword_04";
        
        if ( AZS_GetMeter ) then
            local lines, tot, liveDps = AZS_GetMeter();
            totalDmg = tonumber(tot) or 0;
            dps = tonumber(liveDps) or 0;
            if ( lines and table.getn(lines) > 0 and lines[1] ) then
                topSpellName = lines[1].name or lines[1][1] or "Attack";
                topSpellDmg = tonumber(lines[1].damage or lines[1][2]) or 0;
                topSpellIcon = lines[1].icon or lines[1][4] or "Interface\\Icons\\INV_Sword_04";
            end
        end
        
        data = {
            isVictory = isVictory,
            time = runTime,
            kills = kills,
            gold = gold,
            level = level,
            damage = totalDmg,
            dps = dps,
            topSpell = topSpellName,
            topSpellDmg = topSpellDmg,
            topSpellIcon = topSpellIcon
        };
    end
    lastRunData = data;
    
    -- Update Header & Colors
    if ( data.isVictory ) then
        frame:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.95); -- Gold border
        frame.title:SetText("|cffffd100VICTORY - SURVIVED!|r");
        frame.subtitle:SetText("|cff55ff55Congratulations! You conquered the horde.|r");
        pcall(PlaySound, "LevelUp");
    else
        frame:SetBackdropBorderColor(0.85, 0.20, 0.20, 0.95); -- Crimson border
        frame.title:SetText("|cffff4444DEFEAT - RUN OVER|r");
        frame.subtitle:SetText("|cffa0a0a0Fallen in battle. Rise and fight again!|r");
        pcall(PlaySound, "Deathbind_Sound");
    end
    
    -- Fill Cards
    frame.cards.time.valStr:SetText("|cff00ccff" .. FormatTime(data.time) .. "|r");
    frame.cards.kills.valStr:SetText("|cffff5555" .. FormatBigNum(data.kills) .. " Kills|r");
    frame.cards.gold.valStr:SetText("|cffffd24d" .. FormatBigNum(data.gold) .. " Gold|r");
    frame.cards.level.valStr:SetText("|cff33ff33Level " .. tostring(data.level) .. "|r");
    frame.cards.damage.valStr:SetText(string.format("|cffffffff%s|r (|cff00ccff%s DPS|r)", FormatBigNum(data.damage), FormatBigNum(data.dps)));
    
    if ( data.topSpell ) then
        frame.cards.mvp.valStr:SetText("|cffffd100" .. tostring(data.topSpell) .. "|r: " .. FormatBigNum(data.topSpellDmg));
        if ( data.topSpellIcon and data.topSpellIcon ~= "" ) then
            frame.cards.mvp.icon:SetTexture(data.topSpellIcon);
            frame.cards.mvp.icon:Show();
        else
            frame.cards.mvp.icon:Hide();
        end
    end
    
    frame:Show();
end

-- Event Listener for Run Completion & Death
local eventFrame = CreateFrame("Frame", "BordoUI_RunRecapListener");
eventFrame:RegisterEvent("PLAYER_DEAD");
eventFrame:SetScript("OnEvent", function()
    if ( event == "PLAYER_DEAD" ) then
        -- Trigger defeat recap if player was in an active run
        local t = (AZS_RUN and AZS_RUN.time) or (AZS_GetTimer and AZS_GetTimer()) or 0;
        if ( t > 10 ) then
            BordoUI:ShowRunRecap(false);
        end
    end
end);

-- 15:00 Timer Victory Watcher
local timerWatcher = CreateFrame("Frame", "BordoUI_RunRecapTimerWatcher");
local victoryTriggered = false;
local timerElapsed = 0;

timerWatcher:SetScript("OnUpdate", function()
    timerElapsed = timerElapsed + (arg1 or 0.2);
    if ( timerElapsed < 0.5 ) then return; end
    timerElapsed = 0;
    
    local t = (AZS_RUN and AZS_RUN.time) or (AZS_GetTimer and AZS_GetTimer()) or 0;
    if ( t >= 900 and not victoryTriggered ) then
        victoryTriggered = true;
        BordoUI:ShowRunRecap(true);
    elseif ( t < 10 ) then
        victoryTriggered = false;
    end
end);

-- Slash Command Handler
function BordoUI:ToggleRunRecap(subCmd)
    subCmd = string.lower(subCmd or "");
    if ( subCmd == "testvictory" or subCmd == "victory" ) then
        self:ShowRunRecap(true, {
            isVictory = true, time = 900, kills = 14850, gold = 3420, level = 42,
            damage = 4280000, dps = 4755, topSpell = "Pyroblast", topSpellDmg = 1890000,
            topSpellIcon = "Interface\\Icons\\Spell_Fire_Fireball02"
        });
    elseif ( subCmd == "testdefeat" or subCmd == "defeat" ) then
        self:ShowRunRecap(false, {
            isVictory = false, time = 742, kills = 8240, gold = 1690, level = 28,
            damage = 1950000, dps = 2628, topSpell = "Chain Lightning", topSpellDmg = 840000,
            topSpellIcon = "Interface\\Icons\\Spell_Nature_ChainLightning"
        });
    else
        if ( recapFrame and recapFrame:IsShown() ) then
            recapFrame:Hide();
        else
            if ( lastRunData ) then
                self:ShowRunRecap(lastRunData.isVictory, lastRunData);
            else
                self:ShowRunRecap(true, {
                    isVictory = true, time = 900, kills = 12500, gold = 2800, level = 38,
                    damage = 3500000, dps = 3888, topSpell = "Frostbolt", topSpellDmg = 1450000,
                    topSpellIcon = "Interface\\Icons\\Spell_Frost_FrostBolt02"
                });
            end
        end
    end
end
