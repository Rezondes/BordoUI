--[[
    Bordo UI 2.0 - Low-Health Warning & Heartbeat (LowHealthWarning.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Cinematic pulsing crimson vignette on screen edges when player HP <= 25%
    - Rhythmic heartbeat audio pulse (1.1s interval)
    - Auto-hides when healed above 25% or dead
    - Toggle with /bordo lowhp, test with /bordo testlowhp
]]--

BordoUI = BordoUI or {};

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local lowHealthFrame = nil;
local testActiveUntil = 0;
local lastHeartbeat = 0;

local function InitLowHealthFrame()
    if ( lowHealthFrame ) then return lowHealthFrame; end
    
    lowHealthFrame = CreateFrame("Frame", "BordoUI_LowHealthFrame", UIParent);
    lowHealthFrame:SetAllPoints(UIParent);
    lowHealthFrame:SetFrameStrata("BACKGROUND");
    lowHealthFrame:SetFrameLevel(1);
    lowHealthFrame:Hide();
    
    -- 4 Edge Vignette Gradients (Dark Crimson)
    local EDGE_DEPTH = 110;
    
    -- Top Edge
    local top = lowHealthFrame:CreateTexture(nil, "BACKGROUND");
    top:SetTexture(FLAT);
    top:SetPoint("TOPLEFT", lowHealthFrame, "TOPLEFT", 0, 0);
    top:SetPoint("TOPRIGHT", lowHealthFrame, "TOPRIGHT", 0, 0);
    top:SetHeight(EDGE_DEPTH);
    top:SetGradientAlpha("VERTICAL", 0.85, 0.05, 0.05, 0.0, 0.85, 0.05, 0.05, 0.75);
    lowHealthFrame.top = top;
    
    -- Bottom Edge
    local bottom = lowHealthFrame:CreateTexture(nil, "BACKGROUND");
    bottom:SetTexture(FLAT);
    bottom:SetPoint("BOTTOMLEFT", lowHealthFrame, "BOTTOMLEFT", 0, 0);
    bottom:SetPoint("BOTTOMRIGHT", lowHealthFrame, "BOTTOMRIGHT", 0, 0);
    bottom:SetHeight(EDGE_DEPTH);
    bottom:SetGradientAlpha("VERTICAL", 0.85, 0.05, 0.05, 0.75, 0.85, 0.05, 0.05, 0.0);
    lowHealthFrame.bottom = bottom;
    
    -- Left Edge
    local left = lowHealthFrame:CreateTexture(nil, "BACKGROUND");
    left:SetTexture(FLAT);
    left:SetPoint("TOPLEFT", lowHealthFrame, "TOPLEFT", 0, 0);
    left:SetPoint("BOTTOMLEFT", lowHealthFrame, "BOTTOMLEFT", 0, 0);
    left:SetWidth(EDGE_DEPTH);
    left:SetGradientAlpha("HORIZONTAL", 0.85, 0.05, 0.05, 0.75, 0.85, 0.05, 0.05, 0.0);
    lowHealthFrame.left = left;
    
    -- Right Edge
    local right = lowHealthFrame:CreateTexture(nil, "BACKGROUND");
    right:SetTexture(FLAT);
    right:SetPoint("TOPRIGHT", lowHealthFrame, "TOPRIGHT", 0, 0);
    right:SetPoint("BOTTOMRIGHT", lowHealthFrame, "BOTTOMRIGHT", 0, 0);
    right:SetWidth(EDGE_DEPTH);
    right:SetGradientAlpha("HORIZONTAL", 0.85, 0.05, 0.05, 0.0, 0.85, 0.05, 0.05, 0.75);
    lowHealthFrame.right = right;
    
    -- Subtle soft full-screen tint
    local tint = lowHealthFrame:CreateTexture(nil, "BACKGROUND");
    tint:SetTexture(FLAT);
    tint:SetAllPoints(lowHealthFrame);
    tint:SetVertexColor(0.85, 0.02, 0.02, 0.08);
    lowHealthFrame.tint = tint;
    
    return lowHealthFrame;
end

-- Play deep heartbeat thump
local function PlayHeartbeatSound()
    -- Attempt sound file, fallback to reliable Spell_Shadow_DeathCoil / aggro sound
    local played = pcall(PlaySoundFile, "Sound\\Spells\\ShadowWordPain_Impact.wav");
    if ( not played ) then
        pcall(PlaySound, "Spell_Shadow_DeathCoil");
    end
end

-- Pulse Ticker
local ticker = CreateFrame("Frame", "BordoUI_LowHealthTicker");
ticker:SetScript("OnUpdate", function()
    local now = GetTime();
    local isTesting = (now < testActiveUntil);
    
    BordoUIDB = BordoUIDB or {};
    if ( BordoUIDB.lowHealthWarning == false and not isTesting ) then
        if ( lowHealthFrame and lowHealthFrame:IsShown() ) then lowHealthFrame:Hide(); end
        return;
    end
    
    local hp = UnitHealth("player") or 100;
    local hpMax = UnitHealthMax("player") or 100;
    local dead = UnitIsDeadOrGhost("player");
    local pct = (hpMax > 0) and (hp / hpMax) or 1.0;
    
    local isLow = (not dead) and (pct <= 0.25 and pct > 0);
    
    if ( isLow or isTesting ) then
        local f = lowHealthFrame or InitLowHealthFrame();
        if ( not f:IsShown() ) then
            f:Show();
        end
        
        -- Pulsing sine wave between 0.35 and 0.95 alpha
        local freq = isTesting and 4.0 or (pct <= 0.12 and 5.5 or 4.0);
        local pulse = 0.35 + 0.60 * (0.5 + 0.5 * math.sin(now * freq));
        f:SetAlpha(pulse);
        
        -- Heartbeat audio timing (every 1.05s)
        local soundInterval = (pct <= 0.12) and 0.75 or 1.10;
        if ( (now - lastHeartbeat) >= soundInterval ) then
            lastHeartbeat = now;
            PlayHeartbeatSound();
        end
    else
        if ( lowHealthFrame and lowHealthFrame:IsShown() ) then
            lowHealthFrame:Hide();
        end
    end
end);

-- Toggle Setting
function BordoUI:ToggleLowHealthWarning()
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.lowHealthWarning = (BordoUIDB.lowHealthWarning == false);
    local state = BordoUIDB.lowHealthWarning and "|cff55ff55Enabled|r" or "|cffff4444Disabled|r";
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Low-Health Warning (Vignette & Heartbeat) is now " .. state);
end

-- Live Test Preview (5 Seconds)
function BordoUI:TestLowHealthWarning()
    testActiveUntil = GetTime() + 5.0;
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Testing Low-Health Warning for 5 seconds...");
    local f = lowHealthFrame or InitLowHealthFrame();
    f:Show();
end
