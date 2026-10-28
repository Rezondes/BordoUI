--[[
    Bordo UI - Modern Scrolling Combat Text & Damage Numbers (DamageFont.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    
    Features:
    - Independent Profiles: "Standard" (In-World Overhead 3D) and "Scrolling Text" (SCT Beside Character)
    - Standard Mode:
        - Native Blizzard overhead damage numbers over enemies and player
        - Dedicated Damage Filter (All / No DoTs / Crits / Off)
        - Dedicated Font Family (Standard Skurri, Modern, Classic, Arcade, Russo, Exo)
        - Dedicated Size & Scale (50% to 125%)
        - Compact auto-fitting window (~274px) with zero wasted space
    - Scrolling Text Mode (SCT):
        - 3 Variants: MSBT Style (Icons + Multi-Hit), xCT+ Compact (Name + Total), Clean Pure
        - Multi-hit stacking badges (x2, x3, x4)
        - Full Shaman Totem support (Searing Totem, Magma Totem) and pet attacks
        - Dedicated In-Window Live Style Preview Box
        - Dedicated Filter, Font, and Scale profiles
    - 100% English interface, tooltips, and status messages
]]--

BordoUI = BordoUI or {};
AZSHelper = AZSHelper or {};

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground";
local FONT_PATH = "Fonts\\ARIALN.TTF";

-- Available Font Assets
local FONTS = {
    standard= { name = "Standard",    path = "Fonts\\SKURRI.TTF" },
    modern  = { name = "Modern Clean",path = "Interface\\AddOns\\BordoUI\\Media\\modern.ttf" },
    classic = { name = "Classic Friz",path = "Fonts\\FRIZQT__.TTF" },
    arcade  = { name = "Arcade",      path = "Fonts\\ARIALN.TTF" },
    russo   = { name = "Russo Bold",  path = "Interface\\AddOns\\BordoUI\\Fonts\\RussoOne-Regular.ttf" },
    exo     = { name = "Exo Sci-Fi",  path = "Interface\\AddOns\\BordoUI\\Fonts\\Exo-SemiBold.ttf" },
};

-- Default Settings (Separate Independent Profiles for Standard & SCT)
function BordoUI:GetDamageSettings()
    BordoUIDB = BordoUIDB or {};
    if ( not BordoUIDB.damageSettings or type(BordoUIDB.damageSettings) ~= "table" ) then
        BordoUIDB.damageSettings = {};
    end
    local s = BordoUIDB.damageSettings;
    
    -- Active Mode: "standard" or "scrolling"
    if ( s.mode == "inworld" or (s.mode ~= "scrolling" and s.mode ~= "standard") ) then
        s.mode = (s.mode == "scrolling") and "scrolling" or "standard";
    end
    
    -- 1. Standard Profile (Overhead In-World 3D Numbers)
    if ( not s.standard or type(s.standard) ~= "table" ) then
        s.standard = {
            filter = "all",
            font   = "standard",
            scale  = 0.85,
        };
    end
    if ( s.standard.filter ~= "all" and s.standard.filter ~= "crits" and s.standard.filter ~= "off" ) then
        s.standard.filter = "all";
    end
    s.standard.font = "standard";
    s.standard.scale = 0.85;
    
    -- 2. Scrolling SCT Profile (Side Stacked Beside Character)
    if ( not s.sct or type(s.sct) ~= "table" ) then
        s.sct = {
            variant  = s.variant or "msbt",
            filter   = s.filter or "all",
            font     = (s.font and s.font ~= "standard") and s.font or "modern",
            scale    = s.scale or 0.85,
            icons    = (s.icons ~= false),
            stacking = (s.stacking ~= false),
        };
    end
    if ( s.sct.variant ~= "msbt" and s.sct.variant ~= "xct" and s.sct.variant ~= "clean" ) then
        s.sct.variant = "msbt";
    end
    if ( s.sct.filter ~= "all" and s.sct.filter ~= "nodots" and s.sct.filter ~= "crits" and s.sct.filter ~= "off" ) then
        s.sct.filter = "all";
    end
    if ( not FONTS[s.sct.font] ) then
        s.sct.font = "modern";
    end
    if ( not s.sct.scale or type(s.sct.scale) ~= "number" or s.sct.scale <= 0 ) then
        s.sct.scale = 0.85;
    end
    
    return s;
end

-- School / Spell Color Palette
local SPELL_COLORS = {
    physical = { 1.00, 1.00, 1.00 }, -- White
    holy     = { 1.00, 0.90, 0.50 }, -- Pale Gold
    fire     = { 1.00, 0.45, 0.10 }, -- Orange
    nature   = { 0.30, 0.90, 0.30 }, -- Green
    frost    = { 0.40, 0.80, 1.00 }, -- Sky Blue
    shadow   = { 0.75, 0.45, 1.00 }, -- Deep Violet
    arcane   = { 1.00, 0.50, 1.00 }, -- Magenta
    heal     = { 0.20, 1.00, 0.30 }, -- Healing Green
    crit     = { 1.00, 0.82, 0.00 }, -- Gold
};

local function DetectSchoolColor(spellName, isCrit)
    if ( isCrit ) then return SPELL_COLORS.crit; end
    if ( not spellName ) then return SPELL_COLORS.physical; end
    local lower = string.lower(spellName);
    if ( string.find(lower, "fire") or string.find(lower, "feuer") or string.find(lower, "flame") or string.find(lower, "flammen") or string.find(lower, "pyro") or string.find(lower, "scorch") or string.find(lower, "ignite") or string.find(lower, "blast") or string.find(lower, "searing") or string.find(lower, "verbrennung") or string.find(lower, "gluehend") or string.find(lower, "magma") or string.find(lower, "entz") ) then
        return SPELL_COLORS.fire;
    elseif ( string.find(lower, "frost") or string.find(lower, "ice") or string.find(lower, "blizzard") or string.find(lower, "eis") or string.find(lower, "chill") or string.find(lower, "kaelte") ) then
        return SPELL_COLORS.frost;
    elseif ( string.find(lower, "shadow") or string.find(lower, "schatten") or string.find(lower, "drain") or string.find(lower, "curse") or string.find(lower, "fluch") or string.find(lower, "corruption") or string.find(lower, "verderbnis") or string.find(lower, "pain") or string.find(lower, "death") or string.find(lower, "tod") ) then
        return SPELL_COLORS.shadow;
    elseif ( string.find(lower, "holy") or string.find(lower, "heilig") or string.find(lower, "smite") or string.find(lower, "pein") or string.find(lower, "wrath") or string.find(lower, "zorn") or string.find(lower, "consecrat") or string.find(lower, "weihe") or string.find(lower, "justice") or string.find(lower, "urteil") ) then
        return SPELL_COLORS.holy;
    elseif ( string.find(lower, "nature") or string.find(lower, "natur") or string.find(lower, "lightning") or string.find(lower, "blitz") or string.find(lower, "poison") or string.find(lower, "gift") or string.find(lower, "earth") or string.find(lower, "erde") or string.find(lower, "chain") or string.find(lower, "kette") ) then
        return SPELL_COLORS.nature;
    elseif ( string.find(lower, "arcane") or string.find(lower, "arkan") or string.find(lower, "missile") or string.find(lower, "geschoss") or string.find(lower, "star") or string.find(lower, "stern") or string.find(lower, "moon") or string.find(lower, "mond") ) then
        return SPELL_COLORS.arcane;
    end
    return SPELL_COLORS.physical;
end

-------------------------------------------------------------------------------
-- SCROLLING COMBAT TEXT (SCT) DISPLAY ENGINE
-------------------------------------------------------------------------------
local SCT = {
    lines = {},
    maxLines = 14,
    lineHeight = 22,
};
BordoUI.SCT = SCT;

-- Anchor Frames (Positioned left and right of player character)
local outgoingAnchor = CreateFrame("Frame", "BordoUI_SCT_OutgoingAnchor", UIParent);
outgoingAnchor:SetWidth(130);
outgoingAnchor:SetHeight(30);
outgoingAnchor:SetPoint("CENTER", UIParent, "CENTER", 145, 20);
outgoingAnchor:SetMovable(true);
outgoingAnchor:EnableMouse(true);
outgoingAnchor:RegisterForDrag("LeftButton");

local incomingAnchor = CreateFrame("Frame", "BordoUI_SCT_IncomingAnchor", UIParent);
incomingAnchor:SetWidth(130);
incomingAnchor:SetHeight(30);
incomingAnchor:SetPoint("CENTER", UIParent, "CENTER", -145, 20);
incomingAnchor:SetMovable(true);
incomingAnchor:EnableMouse(true);
incomingAnchor:RegisterForDrag("LeftButton");

local function SetupAnchorDrag(anchor, saveKey, labelText)
    anchor:SetScript("OnDragStart", function()
        if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
            anchor:StartMoving();
        end
    end);
    anchor:SetScript("OnDragStop", function()
        anchor:StopMovingOrSizing();
        local pt, _, relPt, x, y = anchor:GetPoint();
        BordoUIDB = BordoUIDB or {};
        BordoUIDB[saveKey] = { point = pt, relativePoint = relPt, x = x, y = y };
    end);
    
    anchor:SetBackdrop({
        bgFile = FLAT, edgeFile = FLAT, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    anchor:SetBackdropColor(0.0, 0.6, 0.9, 0.25);
    anchor:SetBackdropBorderColor(0.0, 0.8, 1.0, 0.8);
    
    local txt = anchor:CreateFontString(nil, "OVERLAY");
    txt:SetFont(FONT_PATH, 9, "OUTLINE");
    txt:SetPoint("CENTER", anchor, "CENTER", 0, 0);
    txt:SetText(labelText);
    txt:SetTextColor(0.8, 0.9, 1.0);
    anchor.txt = txt;
end

SetupAnchorDrag(outgoingAnchor, "sctOutgoingPos", "SCT Outgoing (Drag)");
SetupAnchorDrag(incomingAnchor, "sctIncomingPos", "SCT Incoming (Drag)");

function BordoUI:UpdateSCTAnchorVisibility()
    local show = (BordoUIDB and not BordoUIDB.locked);
    local s = self:GetDamageSettings();
    if ( s.mode == "standard" ) then
        outgoingAnchor:Hide();
        incomingAnchor:Hide();
        return;
    end
    if ( show ) then
        outgoingAnchor:Show();
        incomingAnchor:Show();
    else
        outgoingAnchor:Hide();
        incomingAnchor:Hide();
    end
end

-- Line Template Builder
local function CreateSCTLine(id)
    local line = CreateFrame("Frame", "BordoUI_SCT_Line_" .. id, UIParent);
    line:SetWidth(200);
    line:SetHeight(SCT.lineHeight);
    line:SetFrameStrata("HIGH");
    line:SetFrameLevel(15);
    line:Hide();
    
    -- Spell Icon Frame (Variant 1 & 2)
    local iconFrame = CreateFrame("Frame", nil, line);
    iconFrame:SetWidth(18);
    iconFrame:SetHeight(18);
    iconFrame:SetPoint("LEFT", line, "LEFT", 0, 0);
    
    local icon = iconFrame:CreateTexture(nil, "ARTWORK");
    icon:SetAllPoints(iconFrame);
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    line.iconFrame = iconFrame;
    line.icon = icon;
    

    
    -- Spell Name Text (Variant 2: xCT+ Compact)
    local nameText = line:CreateFontString(nil, "OVERLAY");
    nameText:SetFont(FONT_PATH, 11, "OUTLINE");
    nameText:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0);
    nameText:SetTextColor(0.85, 0.85, 0.85);
    nameText:Hide();
    line.nameText = nameText;
    
    -- Damage Amount Text
    local text = line:CreateFontString(nil, "OVERLAY");
    text:SetFont(FONT_PATH, 14, "OUTLINE");
    text:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0);
    line.text = text;
    
    -- Hit Stacking Badge (e.g. x2, x3, x5)
    local badge = line:CreateFontString(nil, "OVERLAY");
    badge:SetFont(FONT_PATH, 11, "OUTLINE");
    badge:SetPoint("LEFT", text, "RIGHT", 3, -1);
    badge:SetTextColor(0.00, 0.85, 1.00); -- Cyan badge
    badge:Hide();
    line.badge = badge;
    
    line.age = 0;
    line.active = false;
    line.count = 1;
    return line;
end

-- Initialize Line Pool
for i = 1, SCT.maxLines do
    table.insert(SCT.lines, CreateSCTLine(i));
end

-- Static Icon Map for instant guaranteed spell, talent & totem icons
local SCT_ICONS = {
    -- Mage
    ["pyroblast"]        = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["pyroschlag"]       = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["pyroclasm"]        = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["ignite"]           = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["entzuenden"]       = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["fireball"]         = "Interface\\Icons\\Spell_Fire_FlameBolt",
    ["feuerball"]        = "Interface\\Icons\\Spell_Fire_FlameBolt",
    ["frostbolt"]        = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    ["frostblitz"]       = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    ["flamestrike"]      = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["flammenstoss"]     = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["blast wave"]       = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["druckwelle"]       = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["fire blast"]       = "Interface\\Icons\\Spell_Fire_Fireball",
    ["feuerschlag"]      = "Interface\\Icons\\Spell_Fire_Fireball",
    ["cone of cold"]     = "Interface\\Icons\\Spell_Frost_Glacier",
    ["kaeltekegel"]      = "Interface\\Icons\\Spell_Frost_Glacier",
    ["frost nova"]       = "Interface\\Icons\\Spell_Frost_FrostNova",
    ["blizzard"]         = "Interface\\Icons\\Spell_Frost_IceStorm",
    ["arcane missiles"]  = "Interface\\Icons\\Spell_Nature_StarFall",
    ["arkangeschosse"]   = "Interface\\Icons\\Spell_Nature_StarFall",
    ["arcane explosion"] = "Interface\\Icons\\Spell_Nature_WispSplode",
    ["scorch"]           = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["versengen"]        = "Interface\\Icons\\Spell_Fire_SoulBurn",

    -- Shaman
    ["searing totem"]    = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["totem der verbrennung"] = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["gluehendes totem"]  = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["searing"]          = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["magma totem"]      = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["totem der gluehenden magma"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["fire nova totem"]  = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["fire nova"]        = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["feuernova"]        = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["lightning bolt"]   = "Interface\\Icons\\Spell_Nature_Lightning",
    ["blitzschlag"]      = "Interface\\Icons\\Spell_Nature_Lightning",
    ["chain lightning"]  = "Interface\\Icons\\Spell_Nature_ChainLightning",
    ["kettenblitzschlag"]= "Interface\\Icons\\Spell_Nature_ChainLightning",
    ["kettenblitz"]      = "Interface\\Icons\\Spell_Nature_ChainLightning",
    ["earth shock"]      = "Interface\\Icons\\Spell_Nature_EarthShock",
    ["erdschock"]        = "Interface\\Icons\\Spell_Nature_EarthShock",
    ["flame shock"]      = "Interface\\Icons\\Spell_Fire_FlameShock",
    ["flammenschock"]    = "Interface\\Icons\\Spell_Fire_FlameShock",
    ["frost shock"]      = "Interface\\Icons\\Spell_Frost_FrostShock",
    ["frostschock"]      = "Interface\\Icons\\Spell_Frost_FrostShock",
    ["lightning shield"] = "Interface\\Icons\\Spell_Nature_LightningShield",
    ["blitzschlagschild"]= "Interface\\Icons\\Spell_Nature_LightningShield",
    ["firebolt"]         = "Interface\\Icons\\Spell_Fire_FireBolt02",
    ["feuerblitz"]       = "Interface\\Icons\\Spell_Fire_FireBolt02",

    -- Warlock
    ["shadow bolt"]      = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    ["schattenblitz"]    = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    ["corruption"]       = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
    ["verderbnis"]       = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
    ["immolate"]         = "Interface\\Icons\\Spell_Fire_Immolation",
    ["feuerbrand"]       = "Interface\\Icons\\Spell_Fire_Immolation",
    ["curse of agony"]   = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["fluch der pein"]   = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["rain of fire"]     = "Interface\\Icons\\Spell_Shadow_RainOfFire",
    ["feuerregen"]       = "Interface\\Icons\\Spell_Shadow_RainOfFire",
    ["hellfire"]         = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["hoellenfeuer"]     = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["searing pain"]     = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["sengender schmerz"]= "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["drain life"]       = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    ["blutsauger"]       = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    ["death coil"]       = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    ["todesmantel"]      = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    ["soulfire"]         = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["seelenfeuer"]      = "Interface\\Icons\\Spell_Fire_Fireball02",

    -- Druid
    ["moonfire"]         = "Interface\\Icons\\Spell_Nature_StarFall",
    ["mondfeuer"]        = "Interface\\Icons\\Spell_Nature_StarFall",
    ["starfire"]         = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["sternenfeuer"]     = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["wrath"]            = "Interface\\Icons\\Spell_Nature_AbolishMagic",
    ["zorn"]             = "Interface\\Icons\\Spell_Nature_AbolishMagic",
    ["hurricane"]        = "Interface\\Icons\\Spell_Nature_Cyclone",
    ["hurrikan"]         = "Interface\\Icons\\Spell_Nature_Cyclone",
    ["insect swarm"]     = "Interface\\Icons\\Spell_Nature_InsectSwarm",
    ["insektenschwarm"]  = "Interface\\Icons\\Spell_Nature_InsectSwarm",
    ["swipe"]            = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    ["prankenhieb"]      = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    ["shred"]            = "Interface\\Icons\\Spell_Shadow_VampiricAura",

    -- Priest
    ["smite"]            = "Interface\\Icons\\Spell_Holy_HolySmite",
    ["goettliche pein"]  = "Interface\\Icons\\Spell_Holy_HolySmite",
    ["holy fire"]        = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["heiliges feuer"]   = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["mind blast"]       = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    ["gedankenschlag"]   = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    ["mind flay"]        = "Interface\\Icons\\Spell_Shadow_SiphonMana",
    ["gedankenschinden"] = "Interface\\Icons\\Spell_Shadow_SiphonMana",
    ["shadow word: pain"]= "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    ["schattenwort: schmerz"] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    ["holy nova"]        = "Interface\\Icons\\Spell_Holy_HolyNova",
    ["heilige nova"]     = "Interface\\Icons\\Spell_Holy_HolyNova",

    -- Paladin
    ["consecration"]     = "Interface\\Icons\\Spell_Holy_InnerFire",
    ["weihe"]            = "Interface\\Icons\\Spell_Holy_InnerFire",
    ["hammer of wrath"]  = "Interface\\Icons\\Ability_ThunderClap",
    ["hammer des zorns"] = "Interface\\Icons\\Ability_ThunderClap",
    ["judgement"]        = "Interface\\Icons\\Spell_Holy_RighteousFury",
    ["richturteil"]      = "Interface\\Icons\\Spell_Holy_RighteousFury",
    ["exorcism"]         = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["exorzismus"]       = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["holy shock"]       = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["heiliger schock"]  = "Interface\\Icons\\Spell_Holy_SearingLight",

    -- Hunter
    ["aimed shot"]       = "Interface\\Icons\\INV_Spear_07",
    ["gezielter schuss"] = "Interface\\Icons\\INV_Spear_07",
    ["arcane shot"]      = "Interface\\Icons\\Ability_ImpalingBolt",
    ["arkaner schuss"]   = "Interface\\Icons\\Ability_ImpalingBolt",
    ["multi-shot"]       = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
    ["mehrfachschuss"]   = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
    ["volley"]           = "Interface\\Icons\\Ability_Marksmanship",
    ["salve"]            = "Interface\\Icons\\Ability_Marksmanship",
    ["serpent sting"]    = "Interface\\Icons\\Ability_Hunter_Quickshot",
    ["schlangenbiss"]    = "Interface\\Icons\\Ability_Hunter_Quickshot",

    -- Rogue & Warrior Melee / Physical
    ["eviscerate"]       = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ["ausweiden"]        = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ["sinister strike"]  = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    ["finsterer stoss"]  = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    ["backstab"]         = "Interface\\Icons\\Ability_BackStab",
    ["meucheln"]         = "Interface\\Icons\\Ability_BackStab",
    ["mortal strike"]    = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["toedlicher stoss"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["whirlwind"]        = "Interface\\Icons\\Ability_Whirlwind",
    ["wirbelwind"]       = "Interface\\Icons\\Ability_Whirlwind",
    ["cleave"]           = "Interface\\Icons\\Ability_Warrior_Cleave",
    ["spalten"]          = "Interface\\Icons\\Ability_Warrior_Cleave",
    ["execute"]          = "Interface\\Icons\\INV_Sword_48",
    ["hinrichten"]       = "Interface\\Icons\\INV_Sword_48",
    ["shield slam"]      = "Interface\\Icons\\INV_Shield_05",
    ["schildschlag"]     = "Interface\\Icons\\INV_Shield_05",
    ["thunder clap"]     = "Interface\\Icons\\Spell_Nature_ThunderClap",
    ["donnerknall"]      = "Interface\\Icons\\Spell_Nature_ThunderClap",
    ["attack"]           = "Interface\\Icons\\INV_Sword_04",
    ["melee"]            = "Interface\\Icons\\INV_Sword_04",
    ["auto attack"]      = "Interface\\Icons\\INV_Sword_04",
};

-- Robust Spell Icon Resolver (Checks static map, keyword substrings, and live meters)
local function ResolveSpellIcon(spellName)
    if ( not spellName or spellName == "" ) then
        return "Interface\\Icons\\INV_Sword_04";
    end
    local lower = string.lower(spellName);
    
    -- 1. Exact static match
    if ( SCT_ICONS[lower] ) then
        return SCT_ICONS[lower];
    end
    
    -- 2. Keyword Substrings (Matches procs, German spell names, and talents)
    if ( string.find(lower, "pyro") ) then
        return "Interface\\Icons\\Spell_Fire_Fireball02";
    elseif ( string.find(lower, "searing") or string.find(lower, "verbrennung") or string.find(lower, "gluehend") or string.find(lower, "firebolt") or string.find(lower, "feuerblitz") ) then
        return "Interface\\Icons\\Spell_Fire_SearingTotem";
    elseif ( string.find(lower, "magma") ) then
        return "Interface\\Icons\\Spell_Fire_SelfDestruct";
    elseif ( string.find(lower, "ignite") or string.find(lower, "entz") ) then
        return "Interface\\Icons\\Spell_Fire_Incinerate";
    elseif ( string.find(lower, "fireball") or string.find(lower, "feuerball") ) then
        return "Interface\\Icons\\Spell_Fire_FlameBolt";
    elseif ( string.find(lower, "frostbolt") or string.find(lower, "frostblitz") ) then
        return "Interface\\Icons\\Spell_Frost_FrostBolt02";
    elseif ( string.find(lower, "flamestrike") or string.find(lower, "flammensto") ) then
        return "Interface\\Icons\\Spell_Fire_SelfDestruct";
    elseif ( string.find(lower, "blast wave") or string.find(lower, "druckwelle") ) then
        return "Interface\\Icons\\Spell_Holy_Excorcism_02";
    elseif ( string.find(lower, "fire blast") or string.find(lower, "feuerschlag") ) then
        return "Interface\\Icons\\Spell_Fire_Fireball";
    elseif ( string.find(lower, "chain") or string.find(lower, "ketten") ) then
        return "Interface\\Icons\\Spell_Nature_ChainLightning";
    elseif ( string.find(lower, "lightning") or string.find(lower, "blitz") ) then
        return "Interface\\Icons\\Spell_Nature_Lightning";
    elseif ( string.find(lower, "shadow") or string.find(lower, "schatten") ) then
        return "Interface\\Icons\\Spell_Shadow_ShadowBolt";
    end
    
    -- 3. Dynamic lookup from helper or meter
    local dynIcon = nil;
    if ( AZSHelper and AZSHelper.GetSpellIcon ) then
        dynIcon = AZSHelper:GetSpellIcon(spellName);
    elseif ( SurvivorUI_MeterIcon ) then
        dynIcon = SurvivorUI_MeterIcon(spellName);
    end
    if ( dynIcon and dynIcon ~= "" ) then
        return dynIcon;
    end
    
    -- 4. Fallback Default
    return "Interface\\Icons\\INV_Sword_04";
end

-- Spawn or Stack Combat Text Line
function BordoUI:AddCombatNumber(spellName, amount, isCrit, isIncoming, isHeal)
    local s = self:GetDamageSettings();
    if ( s.mode == "standard" ) then
        if ( s.standard.filter ~= "crits" or not isCrit ) then
            return;
        end
    else
        local cfg = s.sct;
        if ( cfg.filter == "off" ) then return; end
        if ( cfg.filter == "crits" and not isCrit ) then return; end
    end
    
    local cfg = (s.mode == "standard") and s.standard or s.sct;
    local fontDef = FONTS[cfg.font] or (s.mode == "standard" and FONTS.standard or FONTS.modern);
    local fontPath = fontDef.path;
    local scale = tonumber(cfg.scale) or 0.85;
    
    -- Resolve Spell Icon
    local iconPath = ResolveSpellIcon(spellName);
    
    local parentAnchor = isIncoming and incomingAnchor or outgoingAnchor;
    local now = GetTime();
    
    -- Check for Hit Stacking (if same spell hit within 0.45s, increment count: x2, x3, x5!)
    if ( cfg.stacking ) then
        for i = 1, SCT.maxLines do
            local l = SCT.lines[i];
            if ( l.active and l.spellName == spellName and (now - l.spawnTime) < 0.45 ) then
                l.count = l.count + 1;
                l.amount = l.amount + amount;
                l.age = 0.1; -- Reset fade timer
                
                local numText = string.format("%d", tonumber(l.amount) or 0);
                if ( l.isCrit or isCrit ) then
                    l.isCrit = true;
                    l.text:SetText(string.format("* %s *", numText));
                    l.text:SetTextColor(SPELL_COLORS.crit[1], SPELL_COLORS.crit[2], SPELL_COLORS.crit[3]);
                else
                    l.text:SetText(numText);
                end
                
                -- Update Badge for Variant
                if ( cfg.variant == "xct" or cfg.variant == "msbt" ) then
                    l.badge:SetText(string.format("x%d", tonumber(l.count) or 1));
                    l.badge:Show();
                end
                return;
            end
        end
    end
    
    -- Find an available line from pool
    local targetLine = nil;
    local oldestAge = -1;
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( not l.active ) then
            targetLine = l;
            break;
        elseif ( l.age > oldestAge ) then
            oldestAge = l.age;
            targetLine = l;
        end
    end
    if ( not targetLine ) then return; end
    
    targetLine.active = true;
    targetLine.age = 0;
    targetLine.spawnTime = now;
    targetLine.spellName = spellName;
    targetLine.amount = amount;
    targetLine.isCrit = isCrit;
    targetLine.isIncoming = isIncoming;
    targetLine.count = 1;
    targetLine.parentAnchor = parentAnchor;
    
    local fontSize = isCrit and math.floor(18 * (scale / 0.75)) or math.floor(14 * (scale / 0.75));
    targetLine.text:SetFont(fontPath, fontSize, "OUTLINE");
    targetLine.nameText:SetFont(fontPath, math.max(10, fontSize - 3), "OUTLINE");
    targetLine.badge:SetFont(fontPath, math.max(10, fontSize - 3), "OUTLINE");
    targetLine.badge:Hide();
    
    local numStr = string.format("%d", tonumber(amount) or 0);
    local col = isCrit and SPELL_COLORS.crit or (isHeal and SPELL_COLORS.heal or DetectSchoolColor(spellName, false));
    
    -- Layout per Variant
    if ( cfg.variant == "xct" ) then
        -- Variant 2: xCT+ Compact Named (e.g. [Icon] Magma Totem: 1,450 x5)
        targetLine.icon:SetTexture(iconPath);
        targetLine.iconFrame:Show();
        targetLine.nameText:SetText(tostring(spellName or "Hit") .. ":");
        targetLine.nameText:Show();
        targetLine.nameText:ClearAllPoints();
        targetLine.nameText:SetPoint("LEFT", targetLine.iconFrame, "RIGHT", 4, 0);
        
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine.nameText, "RIGHT", 4, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
        targetLine.badge:ClearAllPoints();
        targetLine.badge:SetPoint("LEFT", targetLine.text, "RIGHT", 3, -1);
        
    elseif ( cfg.variant == "clean" ) then
        -- Variant 3: Clean Numbers (Pure minimal numbers & crits)
        targetLine.iconFrame:Hide();
        targetLine.nameText:Hide();
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine, "LEFT", 0, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " CRIT *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
    else
        -- Variant 1: MSBT Icon Style (e.g. [Icon] 7,178 x4)
        targetLine.icon:SetTexture(iconPath);
        targetLine.iconFrame:Show();
        targetLine.nameText:Hide();
        
        targetLine.text:ClearAllPoints();
        targetLine.text:SetPoint("LEFT", targetLine.iconFrame, "RIGHT", 4, 0);
        if ( isCrit ) then
            targetLine.text:SetText("* " .. numStr .. " *");
        else
            targetLine.text:SetText(numStr);
        end
        targetLine.text:SetTextColor(col[1], col[2], col[3]);
        
        targetLine.badge:ClearAllPoints();
        targetLine.badge:SetPoint("LEFT", targetLine.text, "RIGHT", 3, -1);
    end
    
    targetLine:SetScale(scale);
    targetLine:SetAlpha(1.0);
    targetLine:Show();
    
    -- Stack calculation
    local stackIndex = 0;
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( l.active and l.isIncoming == isIncoming ) then
            l.stackIndex = stackIndex;
            stackIndex = stackIndex + 1;
        end
    end
end

-- SCT Animation Ticker (Smooth 60FPS positioning & fading)
local sctTicker = CreateFrame("Frame", "BordoUI_SCT_Ticker");
sctTicker:SetScript("OnUpdate", function()
    local dt = arg1 or 0.03;
    local s = BordoUI:GetDamageSettings();
    if ( s.mode == "standard" and s.standard.filter ~= "crits" ) then return; end
    
    local duration = 2.4;
    for i = 1, SCT.maxLines do
        local l = SCT.lines[i];
        if ( l.active ) then
            l.age = l.age + dt;
            if ( l.age >= duration ) then
                l.active = false;
                l:Hide();
            else
                local progress = l.age / duration;
                
                -- Fade out during the last 30% of lifetime
                if ( progress > 0.70 ) then
                    local alpha = 1.0 - ((progress - 0.70) / 0.30);
                    l:SetAlpha(math.max(0, math.min(1.0, alpha)));
                else
                    l:SetAlpha(1.0);
                end
                
                -- Position stacked lines smoothly upward
                local anchor = l.parentAnchor or outgoingAnchor;
                local yOffset = (l.stackIndex or 0) * SCT.lineHeight + (progress * 14);
                l:ClearAllPoints();
                l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, yOffset);
            end
        end
    end
end);

-------------------------------------------------------------------------------
-- COMBAT LOG EVENT WATCHER (Parses real gameplay hits)
-------------------------------------------------------------------------------
local logWatcher = CreateFrame("Frame", "BordoUI_SCT_CombatLogWatcher");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF");
logWatcher:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");
logWatcher:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");

logWatcher:SetScript("OnEvent", function()
    local msg = arg1;
    if ( not msg ) then return; end
    local s = BordoUI:GetDamageSettings();
    if ( s.mode == "standard" ) then
        if ( s.standard.filter ~= "crits" ) then return; end
    elseif ( s.sct.filter == "off" ) then
        return;
    end
    
    local lower = string.lower(msg);
    local isCrit = (string.find(lower, "crit") ~= nil) or (string.find(lower, "krit") ~= nil);
    if ( s.mode == "standard" and not isCrit ) then
        return; -- In Standard mode with "crits" filter, strictly suppress non-crit spam
    end
    if ( s.mode ~= "standard" and s.sct.filter == "crits" and not isCrit ) then
        return; -- Suppress non-crits in SCT mode
    end
    
    local isPeriodic = (event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" or
                        event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or
                        event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
    if ( s.mode ~= "standard" and isPeriodic and s.sct.filter == "nodots" ) then
        return; -- Suppress DoT-spam in SCT mode
    end
    
    -- Extract Amount (Checks DoT "suffers/erleidet" then direct "for/fuer")
    local numStr = nil;
    local _, _, sAmt = string.find(msg, "suffers (%d+)");
    if ( not sAmt ) then
        _, _, sAmt = string.find(msg, "erleidet (%d+)");
    end
    if ( sAmt ) then
        numStr = sAmt;
    else
        local _, _, fAmt = string.find(msg, "for (%d+)");
        if ( not fAmt ) then
            _, _, fAmt = string.find(msg, "f%A+r (%d+)");
        end
        if ( fAmt ) then
            numStr = fAmt;
        else
            local gFunc = string.gfind or string.gmatch;
            if ( gFunc ) then
                for w in gFunc(msg, "(%d+)") do numStr = w; end
            end
        end
    end
    local amount = tonumber(numStr or 0);
    if ( not amount or amount <= 0 ) then return; end
    
    -- Extract Spell Name & Source
    local spell = nil;
    
    -- 1. Periodic / DoT Hits ("<Target> suffers <Amount> <School> damage from your <Spell>.")
    if ( isPeriodic ) then
        local _, _, pSpell = string.find(msg, "from your ([^%.]+)");
        if ( not pSpell ) then
            _, _, pSpell = string.find(msg, "durch Euer ([^%.]+)");
        end
        if ( not pSpell ) then
            local _, _, pPet, pSp = string.find(msg, "from ([^']+)'s ([^%.]+)");
            if ( pPet ) then
                pSpell = (string.find(pPet, "Totem") or string.find(pPet, "totem")) and pPet or pSp;
            end
        end
        if ( pSpell ) then
            spell = pSpell;
        end
    end
    
    -- 2. Pet & Totem Hits (e.g. Searing Totem, Magma Totem)
    if ( not spell and (event == "CHAT_MSG_SPELL_PET_DAMAGE" or event == "CHAT_MSG_COMBAT_PET_HITS" or event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or event == "CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS") ) then
        local _, _, pet1, sp1 = string.find(msg, "^([^']+)'s (.+) [hcw][ir][ita][ts]");
        if ( pet1 ) then
            if ( string.find(pet1, "Totem") or string.find(pet1, "totem") ) then
                spell = pet1;
            else
                spell = sp1 or pet1;
            end
        end
        if ( not spell ) then
            local _, _, pet2 = string.find(msg, "^(.+ Totem) [hcw][ir][ita][ts]");
            if ( pet2 ) then spell = pet2; end
        end
        if ( not spell ) then
            local _, _, spG, petG = string.find(msg, "^(.+) von (.+) trifft");
            if ( petG ) then
                if ( string.find(petG, "Totem") or string.find(petG, "totem") ) then
                    spell = petG;
                else
                    spell = spG;
                end
            end
        end
        if ( not spell and (string.find(lower, "searing") or string.find(lower, "verbrennung") or string.find(lower, "firebolt") or string.find(lower, "feuerblitz")) ) then
            spell = "Searing Totem";
        end
        if ( not spell and string.find(lower, "magma") ) then
            spell = "Magma Totem";
        end
    end
    
    -- 3. Direct Player Hits ("Your <Spell> hits/crits...")
    if ( not spell ) then
        local _, _, s1 = string.find(msg, "^Euer (.+) trifft");
        if ( s1 ) then spell = s1; end
    end
    if ( not spell ) then
        local _, _, s2 = string.find(msg, "^Your (.+) crits");
        if ( s2 ) then spell = s2; end
    end
    if ( not spell ) then
        local _, _, s3 = string.find(msg, "^Your (.+) hits");
        if ( s3 ) then spell = s3; end
    end
    if ( not spell ) then
        local _, _, s4 = string.find(msg, "^Your (.+) ticks");
        if ( s4 ) then spell = s4; end
    end
    
    -- 4. Fallback Keyword Scanner (Guarantees procs, talents & totems never fall through)
    if ( not spell or spell == "Attack" or spell == "Melee" ) then
        if ( string.find(lower, "pyroblast") or string.find(lower, "pyroschlag") ) then
            spell = "Pyroblast";
        elseif ( string.find(lower, "pyroclasm") ) then
            spell = "Pyroclasm";
        elseif ( string.find(lower, "ignite") or string.find(lower, "entz") ) then
            spell = "Ignite";
        elseif ( string.find(lower, "searing totem") or string.find(lower, "verbrennung") or string.find(lower, "gluehendes totem") or string.find(lower, "gluehend") or string.find(lower, "firebolt") or string.find(lower, "feuerblitz") ) then
            spell = "Searing Totem";
        elseif ( string.find(lower, "magma totem") or string.find(lower, "magma") ) then
            spell = "Magma Totem";
        elseif ( string.find(lower, "fire nova") or string.find(lower, "feuernova") ) then
            spell = "Fire Nova";
        elseif ( string.find(lower, "fireball") or string.find(lower, "feuerball") ) then
            spell = "Fireball";
        elseif ( string.find(lower, "frostbolt") or string.find(lower, "frostblitz") ) then
            spell = "Frostbolt";
        elseif ( string.find(lower, "flamestrike") or string.find(lower, "flammensto") ) then
            spell = "Flamestrike";
        elseif ( string.find(lower, "blast wave") or string.find(lower, "druckwelle") ) then
            spell = "Blast Wave";
        elseif ( string.find(lower, "chain lightning") or string.find(lower, "kettenblitz") ) then
            spell = "Chain Lightning";
        elseif ( string.find(lower, "lightning bolt") or string.find(lower, "blitzschlag") ) then
            spell = "Lightning Bolt";
        elseif ( string.find(lower, "earth shock") or string.find(lower, "erdschock") ) then
            spell = "Earth Shock";
        elseif ( string.find(lower, "flame shock") or string.find(lower, "flammenschock") ) then
            spell = "Flame Shock";
        elseif ( string.find(lower, "frost shock") or string.find(lower, "frostschock") ) then
            spell = "Frost Shock";
        elseif ( string.find(lower, "lightning shield") or string.find(lower, "blitzschlagschild") ) then
            spell = "Lightning Shield";
        elseif ( string.find(lower, "shadow bolt") or string.find(lower, "schattenblitz") ) then
            spell = "Shadow Bolt";
        elseif ( string.find(lower, "corruption") or string.find(lower, "verderbnis") ) then
            spell = "Corruption";
        elseif ( string.find(lower, "immolate") or string.find(lower, "feuerbrand") ) then
            spell = "Immolate";
        elseif ( string.find(lower, "curse of agony") or string.find(lower, "fluch der pein") ) then
            spell = "Curse of Agony";
        elseif ( string.find(lower, "rain of fire") or string.find(lower, "feuerregen") ) then
            spell = "Rain of Fire";
        elseif ( string.find(lower, "hellfire") or string.find(lower, "hoellenfeuer") ) then
            spell = "Hellfire";
        elseif ( string.find(lower, "drain life") or string.find(lower, "blutsauger") ) then
            spell = "Drain Life";
        elseif ( string.find(lower, "death coil") or string.find(lower, "todesmantel") ) then
            spell = "Death Coil";
        elseif ( string.find(lower, "moonfire") or string.find(lower, "mondfeuer") ) then
            spell = "Moonfire";
        elseif ( string.find(lower, "starfire") or string.find(lower, "sternenfeuer") ) then
            spell = "Starfire";
        elseif ( string.find(lower, "wrath") or string.find(lower, "zorn") ) then
            spell = "Wrath";
        elseif ( string.find(lower, "hurricane") or string.find(lower, "hurrikan") ) then
            spell = "Hurricane";
        elseif ( string.find(lower, "insect swarm") or string.find(lower, "insektenschwarm") ) then
            spell = "Insect Swarm";
        elseif ( string.find(lower, "mind blast") or string.find(lower, "gedankenschlag") ) then
            spell = "Mind Blast";
        elseif ( string.find(lower, "mind flay") or string.find(lower, "gedankenschinden") ) then
            spell = "Mind Flay";
        elseif ( string.find(lower, "shadow word") or string.find(lower, "schattenwort") ) then
            spell = "Shadow Word: Pain";
        elseif ( string.find(lower, "holy nova") or string.find(lower, "heilige nova") ) then
            spell = "Holy Nova";
        elseif ( string.find(lower, "consecrat") or string.find(lower, "weihe") ) then
            spell = "Consecration";
        elseif ( string.find(lower, "hammer of wrath") or string.find(lower, "hammer des zorns") ) then
            spell = "Hammer of Wrath";
        elseif ( string.find(lower, "judgement") or string.find(lower, "richturteil") ) then
            spell = "Judgement";
        elseif ( string.find(lower, "aimed shot") or string.find(lower, "gezielter schuss") ) then
            spell = "Aimed Shot";
        elseif ( string.find(lower, "multi-shot") or string.find(lower, "mehrfachschuss") ) then
            spell = "Multi-Shot";
        elseif ( string.find(lower, "arcane shot") or string.find(lower, "arkaner schuss") ) then
            spell = "Arcane Shot";
        elseif ( string.find(lower, "volley") or string.find(lower, "salve") ) then
            spell = "Volley";
        elseif ( string.find(lower, "serpent sting") or string.find(lower, "schlangenbiss") ) then
            spell = "Serpent Sting";
        elseif ( string.find(lower, "eviscerate") or string.find(lower, "ausweiden") ) then
            spell = "Eviscerate";
        elseif ( string.find(lower, "sinister strike") or string.find(lower, "finsterer stoss") ) then
            spell = "Sinister Strike";
        elseif ( string.find(lower, "backstab") or string.find(lower, "meucheln") ) then
            spell = "Backstab";
        elseif ( string.find(lower, "mortal strike") or string.find(lower, "toedlicher stoss") ) then
            spell = "Mortal Strike";
        elseif ( string.find(lower, "whirlwind") or string.find(lower, "wirbelwind") ) then
            spell = "Whirlwind";
        elseif ( string.find(lower, "cleave") or string.find(lower, "spalten") ) then
            spell = "Cleave";
        elseif ( string.find(lower, "execute") or string.find(lower, "hinrichten") ) then
            spell = "Execute";
        elseif ( string.find(lower, "shield slam") or string.find(lower, "schildschlag") ) then
            spell = "Shield Slam";
        elseif ( string.find(lower, "thunder clap") or string.find(lower, "donnerknall") ) then
            spell = "Thunder Clap";
        elseif ( string.find(lower, "you hit") or string.find(lower, "you crit") or string.find(lower, "ihr trefft") or event == "CHAT_MSG_COMBAT_SELF_HITS" ) then
            spell = "Melee";
        elseif ( not spell ) then
            spell = "Attack";
        end
    end
    
    local isIncoming = (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");
    local isHeal = (event == "CHAT_MSG_SPELL_SELF_BUFF" and (string.find(lower, "heal") or string.find(lower, "heilt")));
    
    BordoUI:AddCombatNumber(spell, amount, isCrit, isIncoming, isHeal);
end);

-------------------------------------------------------------------------------
-- APPLY DAMAGE & FONT SETTINGS
-------------------------------------------------------------------------------
function BordoUI:ApplyDamageSettings()
    local s = self:GetDamageSettings();
    
    if ( s.mode == "standard" ) then
        local cfg = s.standard;
        if ( cfg.filter ~= "all" and cfg.filter ~= "crits" and cfg.filter ~= "off" ) then
            cfg.filter = "all";
        end
        
        if ( cfg.filter == "all" ) then
            -- Enable native game engine CVars for Standard in-world overhead damage
            if ( SetCVar ) then
                pcall(SetCVar, "CombatDamage", "1");
                pcall(SetCVar, "PetMeleeDamage", "1");
                pcall(SetCVar, "PetSpellDamage", "1");
                pcall(SetCVar, "CombatLogPeriodicSpells", "1");
                pcall(SetCVar, "SHOW_COMBAT_TEXT", "1");
                pcall(SetCVar, "COMBAT_TEXT_FLOAT_MODE", "1");
            end
            DAMAGE_TEXT_FONT = "Fonts\\SKURRI.TTF";
            -- Hide all SCT lines to avoid duplicate numbers
            for i = 1, SCT.maxLines do
                if ( SCT.lines[i] ) then
                    SCT.lines[i].active = false;
                    SCT.lines[i]:Hide();
                end
            end
        elseif ( cfg.filter == "crits" ) then
            -- Suppress native non-crit white hit & DoT spam
            if ( SetCVar ) then
                pcall(SetCVar, "CombatDamage", "0");
                pcall(SetCVar, "CombatLogPeriodicSpells", "0");
                pcall(SetCVar, "PetMeleeDamage", "0");
                pcall(SetCVar, "PetSpellDamage", "0");
            end
            DAMAGE_TEXT_FONT = "Fonts\\SKURRI.TTF";
        else -- "off"
            -- Completely disable all damage numbers
            if ( SetCVar ) then
                pcall(SetCVar, "CombatDamage", "0");
                pcall(SetCVar, "CombatLogPeriodicSpells", "0");
                pcall(SetCVar, "PetMeleeDamage", "0");
                pcall(SetCVar, "PetSpellDamage", "0");
            end
            for i = 1, SCT.maxLines do
                if ( SCT.lines[i] ) then
                    SCT.lines[i].active = false;
                    SCT.lines[i]:Hide();
                end
            end
        end
    else
        -- SCT Mode: Disable 3D numbers over ads and route through SCT beside character
        local cfg = s.sct;
        local fontDef = FONTS[cfg.font] or FONTS.modern;
        local fontPath = fontDef.path;
        local scale = tonumber(cfg.scale) or 0.85;
        
        if ( SetCVar ) then
            pcall(SetCVar, "CombatDamage", "0");
        end
        DAMAGE_TEXT_FONT = "Interface\\AddOns\\BordoUI\\Media\\blank.ttf";
        
        if ( CombatText ) then CombatText:SetScale(scale); end
        if ( CombatTextFont ) then
            local fontSize = math.max(12, math.floor(18 * (scale / 0.75)));
            CombatTextFont:SetFont(fontPath, fontSize, "OUTLINE");
        end
    end
    
    -- Restore Anchors Position
    if ( BordoUIDB and BordoUIDB.sctOutgoingPos ) then
        local pos = BordoUIDB.sctOutgoingPos;
        outgoingAnchor:ClearAllPoints();
        outgoingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 145, pos.y or 20);
    end
    if ( BordoUIDB and BordoUIDB.sctIncomingPos ) then
        local pos = BordoUIDB.sctIncomingPos;
        incomingAnchor:ClearAllPoints();
        incomingAnchor:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or -145, pos.y or 20);
    end
    
    self:UpdateSCTAnchorVisibility();
    if ( self.UpdateDamageWindowUI ) then
        self:UpdateDamageWindowUI();
    end
end

-- Backward compatibility aliases
function AZSHelper:ApplyModernDamageText() BordoUI:ApplyDamageSettings(); end
function BordoUI:ApplyModernDamageText() BordoUI:ApplyDamageSettings(); end

-- Live Test Simulation
function BordoUI:TestDamageNumbers()
    self:ApplyDamageSettings();
    local s = self:GetDamageSettings();
    
    if ( s.mode == "standard" ) then
        local cfg = s.standard;
        pcall(PlaySound, "igSpellCastStarted");
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ccffBordo UI|r: |cffffd100Standard Mode Active|r - Filter: %s",
            tostring(cfg.filter or "all")
        ));
        if ( cfg.filter == "off" ) then
            if ( UIErrorsFrame ) then
                UIErrorsFrame:AddMessage("Damage Numbers Disabled", 1.0, 0.3, 0.3, 1.0, 2);
            end
        elseif ( cfg.filter == "crits" ) then
            if ( UIErrorsFrame ) then
                UIErrorsFrame:AddMessage("* 14,636 CRIT * (Only Crits Mode)", 1.0, 0.82, 0.0, 1.0, 2);
            end
            self:AddCombatNumber("Holy Shield", 14636, true, false, false);
            self:AddCombatNumber("Shadow Bolt", 7349, true, false, false);
        else
            if ( UIErrorsFrame ) then
                UIErrorsFrame:AddMessage("Standard Numbers: 777 hit, * 14,636 CRIT *", 1.0, 0.82, 0.0, 1.0, 2);
            end
            if ( CombatText_AddMessage and CombatText_StandardScroll ) then
                CombatText_AddMessage("777", CombatText_StandardScroll, 1.0, 1.0, 1.0);
                CombatText_AddMessage("* 14,636 CRIT *", CombatText_StandardScroll, 1.0, 0.82, 0.0, "crit");
            end
        end
        return;
    end
    
    -- SCT Live Simulation Burst
    self:AddCombatNumber("Searing Totem", 307, false, false, false);
    self:AddCombatNumber("Frostbolt", 777, false, false, false);
    self:AddCombatNumber("Frostbolt", 694, false, false, false);
    if ( s.sct and s.sct.variant == "xct" ) then
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
        self:AddCombatNumber("Magma Totem", 1450, false, false, false);
    end
    self:AddCombatNumber("Holy Shield", 14636, true, false, false);
    self:AddCombatNumber("Shadow Bolt", 7349, true, false, false);
    
    pcall(PlaySound, "igSpellCastStarted");
end

-- Quick Cycle Filter (Minimap Right-Click)
function BordoUI:CycleDamageFilter()
    local s = self:GetDamageSettings();
    local nextFilter;
    if ( s.mode == "standard" ) then
        nextFilter = (s.standard.filter == "all") and "crits" or ((s.standard.filter == "crits") and "off" or "all");
        s.standard.filter = nextFilter;
    else
        nextFilter = (s.sct.filter == "all") and "nodots" or ((s.sct.filter == "nodots") and "crits" or ((s.sct.filter == "crits") and "off" or "all"));
        s.sct.filter = nextFilter;
    end
    self:ApplyDamageSettings();
    
    local names = {
        all    = "|cff55ff55All Damage|r",
        nodots = "|cff00ccffNo DoT-Spam|r",
        crits  = "|cffffd100Only Crits|r",
        off    = "|cffff4444Disabled|r",
    };
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r [" .. ((s.mode == "standard") and "Standard" or "SCT") .. "] Filter: " .. (names[nextFilter] or nextFilter));
end

-- Quick Toggle Mode (Minimap Shift-Click)
function BordoUI:ToggleDamageMotion()
    local s = self:GetDamageSettings();
    if ( s.mode == "standard" ) then
        s.mode = "scrolling";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Mode: |cff00ccffScrolling Text (SCT beside character)|r");
    else
        s.mode = "standard";
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r Mode: |cffffd100Standard (Original numbers over targets)|r");
    end
    self:ApplyDamageSettings();
end

-- Set Scale directly
function BordoUI:SetDamageScale(scale)
    local s = self:GetDamageSettings();
    local num = math.min(1.5, math.max(0.4, tonumber(scale) or 0.85));
    if ( s.mode == "standard" ) then
        s.standard.scale = num;
    else
        s.sct.scale = num;
    end
    if ( BordoUIDB ) then
        BordoUIDB.dmgScale = num;
    end
    self:ApplyDamageSettings();
    self:UpdateDamageWindowUI();
end

-------------------------------------------------------------------------------
-- REDESIGNED MODERN OVERLAY SETTINGS WINDOW (All English)
-------------------------------------------------------------------------------
local dmgFrame = nil;
local optionButtons = {};
local previewWidgets = {};
local uiSections = {};

local function CreatePillButton(parent, group, val, text, tooltipTitle, tooltipDesc, width, height, x, y, onClick)
    local btn = CreateFrame("Button", nil, parent);
    btn:SetWidth(width);
    btn:SetHeight(height);
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    
    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
    btn:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95);
    
    local label = btn:CreateFontString(nil, "OVERLAY");
    label:SetFont(FONT_PATH, 9, "OUTLINE");
    label:SetPoint("CENTER", btn, "CENTER", 0, 0);
    label:SetTextColor(0.75, 0.75, 0.75);
    label:SetText(text);
    btn.label = label;
    
    btn.group = group;
    btn.val = val;
    
    btn:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn");
        onClick(group, val);
    end);
    
    btn:SetScript("OnEnter", function()
        btn:SetBackdropBorderColor(0.00, 0.80, 1.00, 1.0);
        if ( tooltipTitle and tooltipDesc ) then
            GameTooltip:SetOwner(btn, "ANCHOR_TOP");
            GameTooltip:ClearLines();
            GameTooltip:AddLine(tooltipTitle, 1, 0.82, 0);
            GameTooltip:AddLine(tooltipDesc, 0.85, 0.85, 0.85, 1);
            GameTooltip:Show();
        end
    end);
    
    btn:SetScript("OnLeave", function()
        if ( GameTooltip ) then GameTooltip:Hide(); end
        BordoUI:UpdateDamageWindowUI();
    end);
    
    table.insert(optionButtons, btn);
    return btn;
end

function BordoUI:CreateDamageNumbersWindow()
    if ( dmgFrame ) then return dmgFrame; end
    
    dmgFrame = CreateFrame("Frame", "BordoUI_DamageNumbersFrame", UIParent);
    dmgFrame:SetWidth(380);
    dmgFrame:SetHeight(370);
    dmgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
    dmgFrame:SetFrameStrata("HIGH");
    dmgFrame:SetFrameLevel(22);
    dmgFrame:SetClampedToScreen(true);
    dmgFrame:SetMovable(true);
    dmgFrame:EnableMouse(true);
    dmgFrame:RegisterForDrag("LeftButton");
    
    dmgFrame:SetScript("OnDragStart", function()
        if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
            dmgFrame:StartMoving();
        end
    end);
    dmgFrame:SetScript("OnDragStop", function()
        dmgFrame:StopMovingOrSizing();
        local pt, _, relPt, x, y = dmgFrame:GetPoint();
        BordoUIDB = BordoUIDB or {};
        BordoUIDB.damageFramePos = { point = pt, relativePoint = relPt, x = x, y = y };
    end);
    
    dmgFrame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    dmgFrame:SetBackdropColor(0.04, 0.04, 0.07, 0.96);
    dmgFrame:SetBackdropBorderColor(0.18, 0.18, 0.24, 0.95);
    dmgFrame:Hide();
    
    -- Window Title & Subtitle (English)
    local title = dmgFrame:CreateFontString(nil, "OVERLAY");
    title:SetFont(FONT_PATH, 12, "OUTLINE");
    title:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -8);
    title:SetText("|cff00ccffBordo UI|r |cffffd100Combat Text Settings|r");
    
    local subtitle = dmgFrame:CreateFontString(nil, "OVERLAY");
    subtitle:SetFont(FONT_PATH, 8, "OUTLINE");
    subtitle:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -23);
    subtitle:SetTextColor(0.65, 0.65, 0.65);
    subtitle:SetText("Configure independent settings for Standard and Scrolling Text.");
    dmgFrame.subtitle = subtitle;
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, dmgFrame);
    closeBtn:SetWidth(18);
    closeBtn:SetHeight(18);
    closeBtn:SetPoint("TOPRIGHT", dmgFrame, "TOPRIGHT", -6, -6);
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY");
    closeTxt:SetFont(FONT_PATH, 11, "OUTLINE");
    closeTxt:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
    closeTxt:SetText("X");
    closeTxt:SetTextColor(0.7, 0.7, 0.7);
    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.2, 0.2); end);
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.7, 0.7, 0.7); end);
    closeBtn:SetScript("OnClick", function() dmgFrame:Hide(); PlaySound("igMainMenuClose"); end);
    
    if ( BordoUI and BordoUI.AttachLockButton ) then
        BordoUI:AttachLockButton(dmgFrame, "TOPRIGHT", dmgFrame, "TOPRIGHT", -26, -5);
    end
    
    -- Generic Click Handler routing to Standard or SCT table
    local function OnOptionClick(group, val)
        local s = BordoUI:GetDamageSettings();
        if ( group == "mode" ) then
            s.mode = val;
        elseif ( s.mode == "standard" ) then
            if ( group == "scale" ) then
                s.standard.scale = tonumber(val) or 0.85;
            else
                s.standard[group] = val;
            end
        else
            if ( group == "scale" ) then
                s.sct.scale = tonumber(val) or 0.85;
            else
                s.sct[group] = val;
            end
        end
        BordoUI:ApplyDamageSettings();
        BordoUI:UpdateDamageWindowUI();
    end
    
    -- 1. PRIMARY COMBAT TEXT MODE CARDS
    local hMode = dmgFrame:CreateFontString(nil, "OVERLAY");
    hMode:SetFont(FONT_PATH, 9, "OUTLINE");
    hMode:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -42);
    hMode:SetTextColor(1, 0.82, 0.20);
    hMode:SetText("1. COMBAT TEXT SYSTEM:");
    uiSections.hMode = hMode;
    
    local modeOptions = {
        { id = "standard",  label = "Standard",             desc = "Original standard damage numbers floating over enemies and player." },
        { id = "scrolling", label = "Scrolling Text (SCT)", desc = "Numbers scroll beside your character (MSBT / xCT+ style)." },
    };
    local mW = 174;
    uiSections.modeButtons = {};
    for i = 1, table.getn(modeOptions) do
        local m = modeOptions[i];
        local btn = CreatePillButton(dmgFrame, "mode", m.id, m.label, m.label, m.desc, mW, 24, 12 + (i - 1) * (mW + 8), -57, OnOptionClick);
        table.insert(uiSections.modeButtons, btn);
    end
    
    -- 2. SCT DISPLAY VARIANTS (Only shown in Scrolling mode)
    local hVariant = dmgFrame:CreateFontString(nil, "OVERLAY");
    hVariant:SetFont(FONT_PATH, 9, "OUTLINE");
    hVariant:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -89);
    hVariant:SetTextColor(1, 0.82, 0.20);
    hVariant:SetText("2. SCROLLING TEXT VARIANT (SCT STYLES):");
    uiSections.hVariant = hVariant;
    
    local variants = {
        { id = "msbt",  label = "MSBT (Icon + Hits)", desc = "Number + Spell Icon + Multi-hit badge (e.g. 7,178 [Icon] x4). Exact match for reference image!" },
        { id = "xct",   label = "xCT+ (Name + Total)", desc = "Spell Name + Icon + Total Damage x[Targets Hit] (e.g. Magma Totem x5). Ultra-compact for mass AoE!" },
        { id = "clean", label = "Clean (Pure Numbers)", desc = "Pure floating numbers & golden crits with no icons. Highest contrast." },
    };
    local vW = 114;
    uiSections.variantButtons = {};
    for i = 1, table.getn(variants) do
        local v = variants[i];
        local btn = CreatePillButton(dmgFrame, "variant", v.id, v.label, v.label, v.desc, vW, 22, 12 + (i - 1) * (vW + 7), -104, OnOptionClick);
        table.insert(uiSections.variantButtons, btn);
    end
    
    -- 3. INTERACTIVE IN-WINDOW LIVE PREVIEW BOX (Only shown in Scrolling mode)
    local previewBox = CreateFrame("Frame", "BordoUI_DamagePreviewBox", dmgFrame);
    previewBox:SetWidth(356);
    previewBox:SetHeight(44);
    previewBox:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -134);
    previewBox:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    previewBox:SetBackdropColor(0.02, 0.02, 0.03, 0.95);
    previewBox:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95);
    
    local prevTag = previewBox:CreateFontString(nil, "OVERLAY");
    prevTag:SetFont(FONT_PATH, 8, "OUTLINE");
    prevTag:SetPoint("TOPLEFT", previewBox, "TOPLEFT", 6, -4);
    prevTag:SetText("|cff777777LIVE STYLE PREVIEW:|r");
    
    local pIcon1 = previewBox:CreateTexture(nil, "ARTWORK");
    pIcon1:SetWidth(16); pIcon1:SetHeight(16);
    pIcon1:SetPoint("LEFT", previewBox, "LEFT", 12, -4);
    pIcon1:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    pIcon1:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
    
    local pText1 = previewBox:CreateFontString(nil, "OVERLAY");
    pText1:SetFont(FONT_PATH, 12, "OUTLINE");
    pText1:SetPoint("LEFT", pIcon1, "RIGHT", 4, 0);
    pText1:SetText("Frostbolt: 777");
    pText1:SetTextColor(0.4, 0.8, 1.0);
    
    local pIcon2 = previewBox:CreateTexture(nil, "ARTWORK");
    pIcon2:SetWidth(16); pIcon2:SetHeight(16);
    pIcon2:SetPoint("LEFT", previewBox, "CENTER", 10, -4);
    pIcon2:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    pIcon2:SetTexture("Interface\\Icons\\Spell_Holy_SealOfProtection");
    
    local pText2 = previewBox:CreateFontString(nil, "OVERLAY");
    pText2:SetFont(FONT_PATH, 13, "OUTLINE");
    pText2:SetPoint("LEFT", pIcon2, "RIGHT", 4, 0);
    pText2:SetText("* 14,636 * x3");
    pText2:SetTextColor(1.0, 0.82, 0.0);
    
    previewWidgets.box = previewBox;
    previewWidgets.icon1 = pIcon1;
    previewWidgets.text1 = pText1;
    previewWidgets.icon2 = pIcon2;
    previewWidgets.text2 = pText2;
    
    -- 4. DAMAGE FILTER MODES
    local hFilter = dmgFrame:CreateFontString(nil, "OVERLAY");
    hFilter:SetFont(FONT_PATH, 9, "OUTLINE");
    hFilter:SetTextColor(1, 0.82, 0.20);
    uiSections.hFilter = hFilter;
    
    local filters = {
        { id = "all",    label = "All Damage",  desc = "Show all damage numbers (direct hits, periodic DoT ticks, and crits)." },
        { id = "nodots", label = "No DoT-Spam", desc = "Hide periodic DoT ticks; show only direct hits & crits!" },
        { id = "crits",  label = "Only Crits",  desc = "Exclusively display critical strikes! All non-crit white hits and spam are suppressed." },
        { id = "off",    label = "Disabled",    desc = "Completely disable all damage numbers (zero floating text)." },
    };
    local fW = 84;
    uiSections.filterButtons = {};
    for i = 1, table.getn(filters) do
        local f = filters[i];
        local btn = CreatePillButton(dmgFrame, "filter", f.id, f.label, f.label, f.desc, fW, 20, 12 + (i - 1) * (fW + 6), 0, OnOptionClick);
        table.insert(uiSections.filterButtons, btn);
    end
    
    -- 5. FONT SELECTION
    local hFont = dmgFrame:CreateFontString(nil, "OVERLAY");
    hFont:SetFont(FONT_PATH, 9, "OUTLINE");
    hFont:SetTextColor(1, 0.82, 0.20);
    uiSections.hFont = hFont;
    
    local fontList = {
        { id = "standard",label = "Standard",desc = "Original default Blizzard damage font (Skurri)." },
        { id = "modern",  label = "Modern",  desc = "Crisp, clean sans-serif typeface." },
        { id = "classic", label = "Classic", desc = "Nostalgic World of Warcraft Friz Quadrata." },
        { id = "arcade",  label = "Arcade",  desc = "Compact, legible Arial Narrow." },
        { id = "russo",   label = "Russo",   desc = "Heavy, punchy action comic block font." },
        { id = "exo",     label = "Exo",     desc = "Futuristic, elegant sci-fi font." },
    };
    local ftW = 55;
    uiSections.fontButtons = {};
    for i = 1, table.getn(fontList) do
        local ft = fontList[i];
        local btn = CreatePillButton(dmgFrame, "font", ft.id, ft.label, ft.label, ft.desc, ftW, 20, 12 + (i - 1) * (ftW + 5), 0, OnOptionClick);
        table.insert(uiSections.fontButtons, btn);
    end
    
    -- 6. SIZE SCALING
    local hScale = dmgFrame:CreateFontString(nil, "OVERLAY");
    hScale:SetFont(FONT_PATH, 9, "OUTLINE");
    hScale:SetTextColor(1, 0.82, 0.20);
    uiSections.hScale = hScale;
    
    local scales = {
        { val = 0.50, label = "50% Tiny",    desc = "Small, minimal numbers." },
        { val = 0.70, label = "70% Compact", desc = "Compact size, ideal for large monster packs." },
        { val = 0.85, label = "85% Normal",  desc = "Balanced BordoUI standard size." },
        { val = 1.00, label = "100% Large",  desc = "Standard Blizzard 100% scale." },
        { val = 1.25, label = "125% Huge",   desc = "Extra large high-visibility numbers." },
    };
    uiSections.scaleButtons = {};
    for i = 1, table.getn(scales) do
        local sc = scales[i];
        local btn = CreatePillButton(dmgFrame, "scale", sc.val, sc.label, sc.label, sc.desc, ftW, 20, 12 + (i - 1) * (ftW + 5), 0, OnOptionClick);
        table.insert(uiSections.scaleButtons, btn);
    end
    
    -- 7. ACTION BUTTONS: TEST LIVE COMBAT TEXT
    local testBtn = CreateFrame("Button", nil, dmgFrame);
    testBtn:SetWidth(356);
    testBtn:SetHeight(26);
    testBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 12,
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    testBtn:SetBackdropColor(0.08, 0.14, 0.22, 0.95);
    testBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
    
    local testTxt = testBtn:CreateFontString(nil, "OVERLAY");
    testTxt:SetFont(FONT_PATH, 10, "OUTLINE");
    testTxt:SetPoint("CENTER", testBtn, "CENTER", 0, 0);
    testTxt:SetText(">> Test Live Combat Text on Screen <<");
    testTxt:SetTextColor(0.00, 0.90, 1.00);
    
    testBtn:SetScript("OnEnter", function()
        testBtn:SetBackdropBorderColor(1.0, 0.82, 0.20, 1.0);
        testTxt:SetTextColor(1.0, 0.82, 0.20);
    end);
    testBtn:SetScript("OnLeave", function()
        testBtn:SetBackdropBorderColor(0.00, 0.80, 1.00, 0.8);
        testTxt:SetTextColor(0.00, 0.90, 1.00);
    end);
    testBtn:SetScript("OnClick", function()
        BordoUI:TestDamageNumbers();
    end);
    uiSections.testBtn = testBtn;
    
    -- Bottom Status line
    local statusText = dmgFrame:CreateFontString(nil, "OVERLAY");
    statusText:SetFont(FONT_PATH, 8, "OUTLINE");
    statusText:SetTextColor(0.60, 0.85, 0.60);
    dmgFrame.statusText = statusText;
    
    BordoUI:UpdateDamageWindowUI();
    return dmgFrame;
end

-- Refresh Active Highlight & Live Layout in Settings Window
function BordoUI:UpdateDamageWindowUI()
    if ( not dmgFrame ) then return; end
    local s = self:GetDamageSettings();
    local isStandard = (s.mode == "standard");
    local activeCfg = isStandard and s.standard or s.sct;
    
    local fontDef = FONTS[activeCfg.font] or (isStandard and FONTS.standard or FONTS.modern);
    local fontPath = fontDef.path;
    local scale = tonumber(activeCfg.scale) or 0.85;
    
    -- Subtitle
    if ( dmgFrame.subtitle ) then
        if ( isStandard ) then
            dmgFrame.subtitle:SetText("Configuring Standard In-World Damage Numbers (Overhead 3D).");
        else
            dmgFrame.subtitle:SetText("Configuring Scrolling Combat Text (Beside Character).");
        end
    end
    
    -- Dynamic Layout based on Active Mode:
    local fW = 84;
    local ftW = 55;
    
    if ( isStandard ) then
        -- Standard Mode: Hide Variant Header, Variant Buttons, and Preview Box
        if ( uiSections.hVariant ) then uiSections.hVariant:Hide(); end
        if ( uiSections.variantButtons ) then
            for i = 1, table.getn(uiSections.variantButtons) do uiSections.variantButtons[i]:Hide(); end
        end
        if ( previewWidgets.box ) then previewWidgets.box:Hide(); end
        
        -- Section 2: Damage Filter (Spam Reduction)
        uiSections.hFilter:SetText("2. DAMAGE FILTER (SPAM REDUCTION):");
        uiSections.hFilter:ClearAllPoints();
        uiSections.hFilter:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -89);
        uiSections.hFilter:Show();
        
        -- 3 Filter Buttons: [ All Damage ] [ Only Crits ] [ Disabled ]
        local stdW = 114;
        for i = 1, table.getn(uiSections.filterButtons) do
            local btn = uiSections.filterButtons[i];
            if ( btn.val == "all" ) then
                btn:SetWidth(stdW);
                btn:ClearAllPoints();
                btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -104);
                btn:Show();
            elseif ( btn.val == "crits" ) then
                btn:SetWidth(stdW);
                btn:ClearAllPoints();
                btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 133, -104);
                btn:Show();
            elseif ( btn.val == "off" ) then
                btn:SetWidth(stdW);
                btn:ClearAllPoints();
                btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 254, -104);
                btn:Show();
            else
                btn:Hide();
            end
        end
        
        -- Hide Font Family, Size Scale, Test Button, and Status Text in Standard Mode
        if ( uiSections.hFont ) then uiSections.hFont:Hide(); end
        if ( uiSections.fontButtons ) then
            for i = 1, table.getn(uiSections.fontButtons) do uiSections.fontButtons[i]:Hide(); end
        end
        if ( uiSections.hScale ) then uiSections.hScale:Hide(); end
        if ( uiSections.scaleButtons ) then
            for i = 1, table.getn(uiSections.scaleButtons) do uiSections.scaleButtons[i]:Hide(); end
        end
        if ( uiSections.testBtn ) then uiSections.testBtn:Hide(); end
        if ( dmgFrame.statusText ) then dmgFrame.statusText:Hide(); end
        
        -- Snug compact height: exactly 140px!
        dmgFrame:SetHeight(140);
        
    else
        -- SCT Mode: Show Variant Header, Variant Buttons, and Preview Box
        if ( uiSections.hVariant ) then
            uiSections.hVariant:ClearAllPoints();
            uiSections.hVariant:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -89);
            uiSections.hVariant:Show();
        end
        if ( uiSections.variantButtons ) then
            local vW = 114;
            for i = 1, table.getn(uiSections.variantButtons) do
                local btn = uiSections.variantButtons[i];
                btn:ClearAllPoints();
                btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12 + (i - 1) * (vW + 7), -104);
                btn:Show();
            end
        end
        if ( previewWidgets.box ) then
            previewWidgets.box:ClearAllPoints();
            previewWidgets.box:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -134);
            previewWidgets.box:Show();
        end
        
        -- Section 3: Damage Filter
        uiSections.hFilter:SetText("3. DAMAGE FILTER (SPAM REDUCTION):");
        uiSections.hFilter:ClearAllPoints();
        uiSections.hFilter:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -186);
        uiSections.hFilter:Show();
        
        local fW = 84;
        for i = 1, table.getn(uiSections.filterButtons) do
            local btn = uiSections.filterButtons[i];
            btn:SetWidth(fW);
            btn:ClearAllPoints();
            btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12 + (i - 1) * (fW + 6), -201);
            btn:Show();
        end
        
        -- Section 4: Font Family
        uiSections.hFont:SetText("4. FONT FAMILY:");
        uiSections.hFont:ClearAllPoints();
        uiSections.hFont:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -229);
        uiSections.hFont:Show();
        local ftW = 55;
        for i = 1, table.getn(uiSections.fontButtons) do
            local btn = uiSections.fontButtons[i];
            btn:ClearAllPoints();
            btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12 + (i - 1) * (ftW + 5), -244);
            btn:Show();
        end
        
        -- Section 5: Size & Scale
        uiSections.hScale:SetText("5. SIZE & SCALE:");
        uiSections.hScale:ClearAllPoints();
        uiSections.hScale:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -272);
        uiSections.hScale:Show();
        for i = 1, table.getn(uiSections.scaleButtons) do
            local btn = uiSections.scaleButtons[i];
            btn:ClearAllPoints();
            btn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12 + (i - 1) * (ftW + 5), -287);
            btn:Show();
        end
        
        -- Action: Test Button
        uiSections.testBtn:ClearAllPoints();
        uiSections.testBtn:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -319);
        uiSections.testBtn:Show();
        
        -- Status Text
        dmgFrame.statusText:ClearAllPoints();
        dmgFrame.statusText:SetPoint("TOPLEFT", dmgFrame, "TOPLEFT", 12, -349);
        dmgFrame.statusText:Show();
        
        -- Fit height snugly: 370px!
        dmgFrame:SetHeight(370);
    end
    
    -- Update Button Highlighting matching the ACTIVE mode's own profile
    for i = 1, table.getn(optionButtons) do
        local btn = optionButtons[i];
        local isSelected = false;
        if ( btn.group == "mode" ) then
            isSelected = (s.mode == btn.val);
        elseif ( btn.group == "scale" ) then
            isSelected = (math.abs((tonumber(activeCfg.scale) or 0.85) - tonumber(btn.val)) < 0.04);
        else
            isSelected = (activeCfg[btn.group] == btn.val);
        end
        
        if ( isSelected ) then
            btn:SetBackdropBorderColor(0.00, 0.85, 1.00, 1.0);
            btn:SetBackdropColor(0.05, 0.16, 0.25, 0.95);
            btn.label:SetTextColor(0.00, 0.95, 1.00);
        else
            btn:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95);
            btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90);
            btn.label:SetTextColor(0.65, 0.65, 0.65);
        end
    end
    
    -- Update SCT In-Window Live Preview Box (when shown)
    if ( not isStandard and previewWidgets.box ) then
        local pFontSize = math.max(10, math.floor(13 * (scale / 0.75)));
        previewWidgets.text1:SetFont(fontPath, pFontSize, "OUTLINE");
        previewWidgets.text2:SetFont(fontPath, math.floor(pFontSize * 1.15), "OUTLINE");
        
        if ( activeCfg.variant == "xct" ) then
            previewWidgets.icon1:Show();
            previewWidgets.icon2:Show();
            previewWidgets.icon1:SetTexture("Interface\\Icons\\Spell_Fire_SelfDestruct");
            previewWidgets.icon2:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.icon1, "RIGHT", 4, 0);
            previewWidgets.text1:SetText("Magma Totem: 1,450 x5");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.icon2, "RIGHT", 4, 0);
            previewWidgets.text2:SetText("Frostbolt: * 820 *");
        elseif ( activeCfg.variant == "clean" ) then
            previewWidgets.icon1:Hide();
            previewWidgets.icon2:Hide();
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.box, "LEFT", 14, -4);
            previewWidgets.text1:SetText("777 (Frost)");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.box, "CENTER", 10, -4);
            previewWidgets.text2:SetText("* 14,636 CRIT *");
        else
            -- MSBT
            previewWidgets.icon1:Show();
            previewWidgets.icon2:Show();
            previewWidgets.icon1:SetTexture("Interface\\Icons\\Spell_Frost_FrostBolt02");
            previewWidgets.icon2:SetTexture("Interface\\Icons\\Spell_Holy_SealOfProtection");
            previewWidgets.text1:ClearAllPoints();
            previewWidgets.text1:SetPoint("LEFT", previewWidgets.icon1, "RIGHT", 4, 0);
            previewWidgets.text1:SetText("777");
            previewWidgets.text2:ClearAllPoints();
            previewWidgets.text2:SetPoint("LEFT", previewWidgets.icon2, "RIGHT", 4, 0);
            previewWidgets.text2:SetText("* 14,636 * x3");
        end
    end
    
    -- Bottom Status Text
    if ( dmgFrame.statusText ) then
        local filterNames = { all = "All Hits", nodots = "No DoT-Spam", crits = "Only Crits", off = "Disabled" };
        local fontNames   = { standard = "Standard", modern = "Modern", classic = "Classic", arcade = "Arcade", russo = "Russo", exo = "Exo" };
        local scPct       = math.floor(((tonumber(activeCfg.scale) or 0.85)) * 100 + 0.5);
        local fName       = filterNames[activeCfg.filter] or tostring(activeCfg.filter or "All Hits");
        local ftName      = fontNames[activeCfg.font] or tostring(activeCfg.font or (isStandard and "Standard" or "Modern"));
        
        if ( isStandard ) then
            dmgFrame.statusText:SetText(string.format("Active: |cffffd100Standard|r | |cff00ccff%s|r | |cff55ff55%s|r | |cffffffff%d%%|r",
                tostring(fName or "All Hits"),
                tostring(ftName or "Standard"),
                tonumber(scPct) or 85
            ));
        else
            local variantNames = { msbt = "MSBT Style", xct = "xCT+ Named", clean = "Clean Pure" };
            local vName = variantNames[activeCfg.variant] or "MSBT Style";
            dmgFrame.statusText:SetText(string.format("Active: |cffffd100Scrolling SCT|r | |cff00ccff%s|r | |cff55ff55%s|r | |cffaaaaaa%s|r | |cffffffff%d%%|r",
                tostring(vName),
                tostring(fName or "All Hits"),
                tostring(ftName or "Modern"),
                tonumber(scPct) or 85
            ));
        end
    end
end

-- Toggle Window Visibility
function BordoUI:ToggleDamageNumbersWindow()
    local win = dmgFrame or self:CreateDamageNumbersWindow();
    if ( win:IsShown() ) then
        win:Hide();
        PlaySound("igMainMenuClose");
    else
        -- Restore position if available
        if ( BordoUIDB and BordoUIDB.damageFramePos ) then
            local pos = BordoUIDB.damageFramePos;
            win:ClearAllPoints();
            win:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 20);
        end
        self:UpdateDamageWindowUI();
        win:Show();
        PlaySound("igMainMenuOpen");
    end
end

-- Immediate Initialization on load
BordoUI:ApplyDamageSettings();

-- World entry listener
local fontListener = CreateFrame("Frame", "BordoUI_DamageFontListener");
fontListener:RegisterEvent("PLAYER_ENTERING_WORLD");
fontListener:RegisterEvent("VARIABLES_LOADED");
fontListener:SetScript("OnEvent", function()
    BordoUI:ApplyDamageSettings();
end);
