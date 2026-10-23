--[[
    AZS Helper - Attack & Crit Statistics Table (StatsTable.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    - Sleek modern table anchored to the left of the screen
    - Shows all active/skilled attacks and their highest crits
    - Shows overall highest crit and character crit rate
    - Scalable (Mousewheel over header, [-]/[+] buttons, /azs size)
    - Draggable and collapsible
]]--

AZSHelper.SpellStats = {};
AZSHelper.OverallMaxCrit = 0;
AZSHelper.OverallMaxCritSpell = "-";
AZSHelper.TotalHits = 0;
AZSHelper.TotalCrits = 0;

-- Reset Stats Function
function AZSHelper:ResetSpellStats()
    AZSHelper.SpellStats = {};
    AZSHelper.OverallMaxCrit = 0;
    AZSHelper.OverallMaxCritSpell = "-";
    AZSHelper.TotalHits = 0;
    AZSHelper.TotalCrits = 0;
    if ( AZSHelper.UpdateStatsTable ) then
        AZSHelper:UpdateStatsTable();
    end
end

-- Combat Log Parser for per-attack crits
local function ProcessCombatHit(spell, amount, isCrit)
    if ( not spell or not amount or amount <= 0 ) then return; end
    
    spell = string.gsub(spell, "%.$", ""); -- remove trailing period
    
    AZSHelper.TotalHits = AZSHelper.TotalHits + 1;
    if ( not AZSHelper.SpellStats[spell] ) then
        AZSHelper.SpellStats[spell] = {
            hits = 0,
            crits = 0,
            maxCrit = 0,
            maxHit = 0,
        };
    end
    
    local data = AZSHelper.SpellStats[spell];
    data.hits = data.hits + 1;
    
    if ( isCrit ) then
        AZSHelper.TotalCrits = AZSHelper.TotalCrits + 1;
        data.crits = data.crits + 1;
        if ( amount > data.maxCrit ) then
            data.maxCrit = amount;
        end
        if ( amount > AZSHelper.OverallMaxCrit ) then
            AZSHelper.OverallMaxCrit = amount;
            AZSHelper.OverallMaxCritSpell = spell;
        end
    else
        if ( amount > data.maxHit ) then
            data.maxHit = amount;
        end
    end
end

local combatFrame = CreateFrame("Frame", "AZSHelper_CombatWatcher");
combatFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
combatFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
combatFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");

combatFrame:SetScript("OnEvent", function()
    local msg = arg1;
    if ( not msg ) then return; end
    
    local lower = string.lower(msg);
    local isCrit = (string.find(lower, "crit") ~= nil) or (string.find(lower, "krit") ~= nil);
    
    -- Extract Amount
    local numStr = nil;
    local _, _, n1 = string.find(msg, "for (%d+)");
    if ( n1 ) then numStr = n1; end
    if ( not numStr ) then
        local _, _, n2 = string.find(msg, "f%A+r (%d+)");
        if ( n2 ) then numStr = n2; end
    end
    if ( not numStr ) then
        local gFunc = string.gfind or string.gmatch;
        if ( gFunc ) then
            for w in gFunc(msg, "(%d+)") do numStr = w; end
        end
    end
    
    local amount = tonumber(numStr or 0);
    if ( not amount or amount <= 0 ) then return; end
    
    -- Extract Spell Name
    local spell = nil;
    local _, _, s1 = string.find(msg, "^Euer (.+) trifft");
    if ( s1 ) then spell = s1; end
    if ( not spell ) then
        local _, _, s2 = string.find(msg, "^Your (.+) crits");
        if ( s2 ) then spell = s2; end
    end
    if ( not spell ) then
        local _, _, s3 = string.find(msg, "^Your (.+) hits");
        if ( s3 ) then spell = s3; end
    end
    if ( not spell ) then
        spell = "Melee";
    end
    
    ProcessCombatHit(spell, amount, isCrit);
end);

-- =========================================================================
-- SPELL ICON CACHE & RESOLVER (All Classes & Spells)
-- =========================================================================
local spellIconCache = {};

local SPELL_ICONS = {
    -- Generic / Melee
    ["melee"] = "Interface\\Icons\\INV_Sword_04",
    ["nahkampf"] = "Interface\\Icons\\INV_Sword_04",
    ["nahkampf / melee"] = "Interface\\Icons\\INV_Sword_04",
    ["angriff"] = "Interface\\Icons\\INV_Sword_04",
    ["attack"] = "Interface\\Icons\\INV_Sword_04",
    ["auto attack"] = "Interface\\Icons\\INV_Sword_04",
    ["automatisch angreifen"] = "Interface\\Icons\\INV_Sword_04",
    ["schlag"] = "Interface\\Icons\\INV_Gauntlets_04",

    -- Warrior
    ["whirlwind"] = "Interface\\Icons\\Ability_Whirlwind",
    ["wirbelwind"] = "Interface\\Icons\\Ability_Whirlwind",
    ["execute"] = "Interface\\Icons\\INV_Sword_48",
    ["hinrichten"] = "Interface\\Icons\\INV_Sword_48",
    ["mortal strike"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["tödlicher stoß"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["bloodthirst"] = "Interface\\Icons\\Spell_Nature_BloodLust",
    ["blutdurst"] = "Interface\\Icons\\Spell_Nature_BloodLust",
    ["cleave"] = "Interface\\Icons\\Ability_Warrior_Cleave",
    ["spalten"] = "Interface\\Icons\\Ability_Warrior_Cleave",
    ["heroic strike"] = "Interface\\Icons\\Ability_Rogue_Ambush",
    ["heldenhafter stoß"] = "Interface\\Icons\\Ability_Rogue_Ambush",
    ["overpower"] = "Interface\\Icons\\Ability_MeleeDamage",
    ["überwältigen"] = "Interface\\Icons\\Ability_MeleeDamage",
    ["rend"] = "Interface\\Icons\\Ability_Gouge",
    ["verwunden"] = "Interface\\Icons\\Ability_Gouge",
    ["deep wounds"] = "Interface\\Icons\\Ability_BackStab",
    ["tiefe wunden"] = "Interface\\Icons\\Ability_BackStab",
    ["flurry"] = "Interface\\Icons\\Ability_GhoulFrenzy",
    ["schlaghagel"] = "Interface\\Icons\\Ability_GhoulFrenzy",
    ["rampage"] = "Interface\\Icons\\Ability_Warrior_Rampage",
    ["tobend"] = "Interface\\Icons\\Ability_Warrior_Rampage",
    ["thunder clap"] = "Interface\\Icons\\Spell_Nature_ThunderClap",
    ["donnerknall"] = "Interface\\Icons\\Spell_Nature_ThunderClap",
    ["demoralizing shout"] = "Interface\\Icons\\Ability_Warrior_WarCry",
    ["demoralisierender ruf"] = "Interface\\Icons\\Ability_Warrior_WarCry",
    ["battle shout"] = "Interface\\Icons\\Ability_Warrior_BattleShout",
    ["schlachtruf"] = "Interface\\Icons\\Ability_Warrior_BattleShout",
    ["shield slam"] = "Interface\\Icons\\INV_Shield_05",
    ["schildschlag"] = "Interface\\Icons\\INV_Shield_05",
    ["revenge"] = "Interface\\Icons\\Ability_Warrior_Revenge",
    ["rache"] = "Interface\\Icons\\Ability_Warrior_Revenge",
    ["slam"] = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
    ["zerschmettern"] = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
    ["sweeping strikes"] = "Interface\\Icons\\Ability_Rogue_SliceDice",
    ["weitreichende stöße"] = "Interface\\Icons\\Ability_Rogue_SliceDice",
    ["hamstring"] = "Interface\\Icons\\Ability_ShockWave",
    ["kniesehne"] = "Interface\\Icons\\Ability_ShockWave",
    ["pummel"] = "Interface\\Icons\\INV_Gauntlets_04",
    ["zuschlagen"] = "Interface\\Icons\\INV_Gauntlets_04",
    ["shield bash"] = "Interface\\Icons\\Ability_Warrior_ShieldBash",
    ["schildhieb"] = "Interface\\Icons\\Ability_Warrior_ShieldBash",

    -- Azeroth Survivors & Special Items/Procs
    ["the eye of hakkar"] = "Interface\\Icons\\INV_Misc_Eye_01",
    ["eye of hakkar"] = "Interface\\Icons\\INV_Misc_Eye_01",
    ["das auge von hakkar"] = "Interface\\Icons\\INV_Misc_Eye_01",
    ["windfury"] = "Interface\\Icons\\Spell_Nature_Windfury",
    ["windzorn"] = "Interface\\Icons\\Spell_Nature_Windfury",
    ["thunderfury"] = "Interface\\Icons\\Spell_Nature_Cyclone",
    ["shadowbolt volley"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    ["schattenblitzsalve"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",

    -- Mage
    ["fireball"] = "Interface\\Icons\\Spell_Fire_FlameBolt",
    ["feuerball"] = "Interface\\Icons\\Spell_Fire_FlameBolt",
    ["frostbolt"] = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    ["frostblitz"] = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    ["arcane missiles"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["arkane geschosse"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["arcane explosion"] = "Interface\\Icons\\Spell_Nature_WispSplode",
    ["arkane explosion"] = "Interface\\Icons\\Spell_Nature_WispSplode",
    ["pyroblast"] = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["pyroschlag"] = "Interface\\Icons\\Spell_Fire_Fireball02",
    ["scorch"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["versengen"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["flamestrike"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["flammenstoß"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["blizzard"] = "Interface\\Icons\\Spell_Frost_IceStorm",
    ["cone of cold"] = "Interface\\Icons\\Spell_Frost_Glacier",
    ["kältekegel"] = "Interface\\Icons\\Spell_Frost_Glacier",
    ["frost nova"] = "Interface\\Icons\\Spell_Frost_FrostNova",
    ["frostnova"] = "Interface\\Icons\\Spell_Frost_FrostNova",
    ["ice shards"] = "Interface\\Icons\\Spell_Frost_IceShard",
    ["fire blast"] = "Interface\\Icons\\Spell_Fire_Fireball",
    ["feuerschlag"] = "Interface\\Icons\\Spell_Fire_Fireball",
    ["blast wave"] = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["druckwelle"] = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["combustion"] = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["verbrennung"] = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["ignite"] = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["entzünden"] = "Interface\\Icons\\Spell_Fire_Incinerate",

    -- Rogue
    ["sinister strike"] = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    ["finsterer stoß"] = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    ["eviscerate"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ["ausweiden"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ["backstab"] = "Interface\\Icons\\Ability_BackStab",
    ["meucheln"] = "Interface\\Icons\\Ability_BackStab",
    ["ambush"] = "Interface\\Icons\\Ability_Rogue_Ambush",
    ["hinterhalt"] = "Interface\\Icons\\Ability_Rogue_Ambush",
    ["slice and dice"] = "Interface\\Icons\\Ability_Rogue_SliceDice",
    ["zerhäckseln"] = "Interface\\Icons\\Ability_Rogue_SliceDice",
    ["rupture"] = "Interface\\Icons\\Ability_Rogue_Rupture",
    ["blutung"] = "Interface\\Icons\\Ability_Rogue_Rupture",
    ["garrote"] = "Interface\\Icons\\Ability_Rogue_Garrote",
    ["erdrosseln"] = "Interface\\Icons\\Ability_Rogue_Garrote",
    ["gouge"] = "Interface\\Icons\\Ability_Gouge",
    ["solarschlag"] = "Interface\\Icons\\Ability_Gouge",
    ["kick"] = "Interface\\Icons\\Ability_Kick",
    ["tritt"] = "Interface\\Icons\\Ability_Kick",
    ["fan of knives"] = "Interface\\Icons\\Ability_Rogue_FanOfKnives",
    ["dolchfächer"] = "Interface\\Icons\\Ability_Rogue_FanOfKnives",
    ["hemorrhage"] = "Interface\\Icons\\Spell_Shadow_LifeDrain",
    ["blutsturz"] = "Interface\\Icons\\Spell_Shadow_LifeDrain",
    ["ghostly strike"] = "Interface\\Icons\\Spell_Shadow_Curse",
    ["geisterhafter stoß"] = "Interface\\Icons\\Spell_Shadow_Curse",
    ["riposte"] = "Interface\\Icons\\Ability_Warrior_Challange",
    ["instant poison"] = "Interface\\Icons\\Ability_Poisons",
    ["sofort wirkendes gift"] = "Interface\\Icons\\Ability_Poisons",
    ["deadly poison"] = "Interface\\Icons\\Ability_Rogue_DualWeild",
    ["tödliches gift"] = "Interface\\Icons\\Ability_Rogue_DualWeild",

    -- Hunter
    ["auto shot"] = "Interface\\Icons\\Ability_Whirlwind",
    ["automatischer schuss"] = "Interface\\Icons\\Ability_Whirlwind",
    ["aimed shot"] = "Interface\\Icons\\INV_Spear_07",
    ["gezielter schuss"] = "Interface\\Icons\\INV_Spear_07",
    ["multi-shot"] = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
    ["mehrfachschuss"] = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
    ["arcane shot"] = "Interface\\Icons\\Ability_ImpalingBolt",
    ["arcaner schuss"] = "Interface\\Icons\\Ability_ImpalingBolt",
    ["serpent sting"] = "Interface\\Icons\\Ability_Hunter_Quickshot",
    ["schlangenbiss"] = "Interface\\Icons\\Ability_Hunter_Quickshot",
    ["concussive shot"] = "Interface\\Icons\\Spell_Frost_Stun",
    ["erschütternder schuss"] = "Interface\\Icons\\Spell_Frost_Stun",
    ["raptor strike"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["raptorschlag"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["mongoose bite"] = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    ["mungobiss"] = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    ["volley"] = "Interface\\Icons\\Ability_Marksmanship",
    ["salve"] = "Interface\\Icons\\Ability_Marksmanship",
    ["explosive trap"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["sprengfalle"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["immolation trap"] = "Interface\\Icons\\Spell_Fire_FlameShock",
    ["feuerbrandfalle"] = "Interface\\Icons\\Spell_Fire_FlameShock",

    -- Warlock
    ["shadow bolt"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    ["schattenblitz"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    ["corruption"] = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
    ["verderbnis"] = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
    ["immolate"] = "Interface\\Icons\\Spell_Fire_Immolation",
    ["feuerbrand"] = "Interface\\Icons\\Spell_Fire_Immolation",
    ["agony"] = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["curse of agony"] = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["fluch der pein"] = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["drain life"] = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    ["blutsauger"] = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
    ["life tap"] = "Interface\\Icons\\Spell_Shadow_BurningSpirit",
    ["aderlass"] = "Interface\\Icons\\Spell_Shadow_BurningSpirit",
    ["searing pain"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["sengender schmerz"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
    ["hellfire"] = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["höllenfeuer"] = "Interface\\Icons\\Spell_Fire_Incinerate",
    ["rain of fire"] = "Interface\\Icons\\Spell_Fire_MeteorStorm",
    ["feuerregen"] = "Interface\\Icons\\Spell_Fire_MeteorStorm",
    ["conflagrate"] = "Interface\\Icons\\Spell_Fire_Fireball",
    ["feuersbrunst"] = "Interface\\Icons\\Spell_Fire_Fireball",
    ["shadowburn"] = "Interface\\Icons\\Spell_Shadow_ScourgeBuild",
    ["schattenbrand"] = "Interface\\Icons\\Spell_Shadow_ScourgeBuild",
    ["death coil"] = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    ["todesmantel"] = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    ["drain soul"] = "Interface\\Icons\\Spell_Shadow_Haunting",
    ["seelendieb"] = "Interface\\Icons\\Spell_Shadow_Haunting",

    -- Priest
    ["smite"] = "Interface\\Icons\\Spell_Holy_HolyBolt",
    ["peinigen"] = "Interface\\Icons\\Spell_Holy_HolyBolt",
    ["holy fire"] = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["heiliges feuer"] = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["shadow word: pain"] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    ["schattenwort: schmerz"] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    ["mind blast"] = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    ["gedankenschlag"] = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    ["mind flay"] = "Interface\\Icons\\Spell_Shadow_SiphonMana",
    ["gedankenschinden"] = "Interface\\Icons\\Spell_Shadow_SiphonMana",
    ["holy nova"] = "Interface\\Icons\\Spell_Holy_HolyNova",
    ["heilige nova"] = "Interface\\Icons\\Spell_Holy_HolyNova",
    ["starshards"] = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["sternensplitter"] = "Interface\\Icons\\Spell_Arcane_StarFire",

    -- Paladin
    ["judgement"] = "Interface\\Icons\\Spell_Holy_RighteousFury",
    ["richturteil"] = "Interface\\Icons\\Spell_Holy_RighteousFury",
    ["consecration"] = "Interface\\Icons\\Spell_Holy_InnerFire",
    ["weihe"] = "Interface\\Icons\\Spell_Holy_InnerFire",
    ["holy wrath"] = "Interface\\Icons\\Spell_Holy_Excorcism",
    ["heiliger zorn"] = "Interface\\Icons\\Spell_Holy_Excorcism",
    ["exorcism"] = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["exorzismus"] = "Interface\\Icons\\Spell_Holy_Excorcism_02",
    ["hammer of wrath"] = "Interface\\Icons\\Ability_ThunderClap",
    ["hammer des zorns"] = "Interface\\Icons\\Ability_ThunderClap",
    ["holy shock"] = "Interface\\Icons\\Spell_Holy_SearingLight",
    ["heiliger schock"] = "Interface\\Icons\\Spell_Holy_SearingLight",

    -- Druid
    ["moonfire"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["mondfeuer"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["starfire"] = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["sternfeuer"] = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["wrath"] = "Interface\\Icons\\Spell_Nature_AbolishMagic",
    ["zorn"] = "Interface\\Icons\\Spell_Nature_AbolishMagic",
    ["insect swarm"] = "Interface\\Icons\\Spell_Nature_InsectSwarm",
    ["insektenschwarm"] = "Interface\\Icons\\Spell_Nature_InsectSwarm",
    ["rake"] = "Interface\\Icons\\Ability_Druid_Disembowel",
    ["krallenhieb"] = "Interface\\Icons\\Ability_Druid_Disembowel",
    ["claw"] = "Interface\\Icons\\Ability_Druid_Rake",
    ["klaue"] = "Interface\\Icons\\Ability_Druid_Rake",
    ["shred"] = "Interface\\Icons\\Spell_Shadow_VampiricAura",
    ["schreddern"] = "Interface\\Icons\\Spell_Shadow_VampiricAura",
    ["rip"] = "Interface\\Icons\\Ability_GhoulFrenzy",
    ["zerfetzen"] = "Interface\\Icons\\Ability_GhoulFrenzy",
    ["ferocious bite"] = "Interface\\Icons\\Ability_Druid_FerociousBite",
    ["wilder biss"] = "Interface\\Icons\\Ability_Druid_FerociousBite",
    ["swipe"] = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    ["prankenhieb"] = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    ["maul"] = "Interface\\Icons\\Ability_Druid_Maul",
    ["zermalmen"] = "Interface\\Icons\\Ability_Druid_Maul",
    ["hurricane"] = "Interface\\Icons\\Spell_Nature_Cyclone",
    ["hurrikan"] = "Interface\\Icons\\Spell_Nature_Cyclone",

    -- Shaman
    ["earth shock"] = "Interface\\Icons\\Spell_Nature_EarthShock",
    ["erdschock"] = "Interface\\Icons\\Spell_Nature_EarthShock",
    ["flame shock"] = "Interface\\Icons\\Spell_Fire_FlameShock",
    ["flammenschock"] = "Interface\\Icons\\Spell_Fire_FlameShock",
    ["frost shock"] = "Interface\\Icons\\Spell_Frost_FrostShock",
    ["frostschock"] = "Interface\\Icons\\Spell_Frost_FrostShock",
    ["fire nova"] = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["feuernova"] = "Interface\\Icons\\Spell_Fire_SealOfFire",
    ["magma totem"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["magmatotem"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
    ["searing totem"] = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["glühendes totem"] = "Interface\\Icons\\Spell_Fire_SearingTotem",
    ["lightning bolt"] = "Interface\\Icons\\Spell_Nature_Lightning",
    ["blitzschlag"] = "Interface\\Icons\\Spell_Nature_Lightning",
    ["chain lightning"] = "Interface\\Icons\\Spell_Nature_ChainLightning",
    ["kettenblitzschlag"] = "Interface\\Icons\\Spell_Nature_ChainLightning",
};

local function ScanSpellbookIcons()
    local numTabs = GetNumSpellTabs and GetNumSpellTabs() or 0;
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab);
        for s = (offset or 0) + 1, (offset or 0) + (numSpells or 0) do
            local sName = GetSpellName(s, "spell");
            local tex = GetSpellTexture(s, "spell");
            if ( sName and tex ) then
                spellIconCache[sName] = tex;
                spellIconCache[string.lower(sName)] = tex;
            end
        end
    end
end

function AZSHelper:GetSpellIcon(spellName)
    if ( not spellName or spellName == "" or spellName == "-" ) then
        return "Interface\\Icons\\INV_Misc_QuestionMark";
    end
    
    if ( spellIconCache[spellName] ) then
        return spellIconCache[spellName];
    end
    local lower = string.lower(spellName);
    if ( spellIconCache[lower] ) then
        return spellIconCache[lower];
    end
    
    if ( SPELL_ICONS[lower] ) then
        spellIconCache[spellName] = SPELL_ICONS[lower];
        return SPELL_ICONS[lower];
    end
    
    -- Dynamic spellbook search
    local numTabs = GetNumSpellTabs and GetNumSpellTabs() or 0;
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab);
        for s = (offset or 0) + 1, (offset or 0) + (numSpells or 0) do
            local sName = GetSpellName(s, "spell");
            if ( sName and string.lower(sName) == lower ) then
                local tex = GetSpellTexture(s, "spell");
                if ( tex ) then
                    spellIconCache[spellName] = tex;
                    spellIconCache[lower] = tex;
                    return tex;
                end
            end
        end
    end
    
    -- Fuzzy / partial match
    for k, tex in pairs(SPELL_ICONS) do
        if ( string.find(lower, k) ) then
            spellIconCache[spellName] = tex;
            return tex;
        end
    end
    
    return "Interface\\Icons\\INV_Misc_QuestionMark";
end

-- =========================================================================
-- CREATE MAIN STATS TABLE FRAME (ANCHORED TO LEFT)
-- =========================================================================
local mainFrame = CreateFrame("Frame", "AZSHelper_StatsTableFrame", UIParent);
mainFrame:SetWidth(320);
mainFrame:SetHeight(360);
mainFrame:SetClampedToScreen(true);
mainFrame:SetFrameStrata("MEDIUM"); -- Above background panels so nothing bleeds through
tinsert(UISpecialFrames, "AZSHelper_StatsTableFrame"); -- Close with ESC

-- Positioned directly to the right of Multipliers panel
mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 143, -120);
mainFrame:Hide(); -- Hidden by default so it doesn't clutter screen

-- Solid Dark Backdrop (Opaque so background frames don't bleed through)
mainFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
mainFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.98);
mainFrame:SetBackdropBorderColor(0.20, 0.65, 0.95, 0.90); -- Sleek cyan/blue border

-- Function to dock directly to the right of the Multipliers panel
function AZSHelper:AnchorStatsTableToMultipliers()
    local anchor = AZSHelper_MultipliersPanel;
    if ( mainFrame and anchor ) then
        mainFrame:ClearAllPoints();
        mainFrame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 6, 0);
    elseif ( mainFrame ) then
        mainFrame:ClearAllPoints();
        mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 143, -120);
    end
end

-- 1. Header Drag Bar
local header = CreateFrame("Frame", nil, mainFrame);
header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 4, -4);
header:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", -4, -26);
header:EnableMouse(true);
header:RegisterForDrag("LeftButton");
header:SetScript("OnDragStart", function()
    if ( BordoUIDB and BordoUIDB.locked ) then return; end
    mainFrame:StartMoving();
end);
header:SetScript("OnDragStop", function()
    mainFrame:StopMovingOrSizing();
    local p, _, rp, x, y = mainFrame:GetPoint();
    if ( AZSHelperDB ) then
        AZSHelperDB.statsPos = { point = p, relativePoint = rp, x = x, y = y, custom = true };
    end
end);

local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
titleText:SetPoint("LEFT", header, "LEFT", 4, 0);
titleText:SetText("|cff00ccffBordo UI|r |cffffd100Damage Stats|r");

-- Party Frames Quick Toggle Button
local btnParty = CreateFrame("Button", nil, header);
btnParty:SetWidth(50);
btnParty:SetHeight(16);
btnParty:SetPoint("LEFT", titleText, "RIGHT", 8, 0);
btnParty:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 8,
    edgeSize = 6,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 }
});
btnParty:SetBackdropColor(0.04, 0.12, 0.20, 0.90);
btnParty:SetBackdropBorderColor(0.0, 0.70, 0.95, 0.85);

local btnPartyText = btnParty:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
btnPartyText:SetPoint("CENTER", btnParty, "CENTER", 0, 0);
btnPartyText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE");
btnPartyText:SetText("👥 Party");

btnParty:SetScript("OnClick", function()
    if ( BordoUI.TogglePartyFrames ) then
        BordoUI:TogglePartyFrames();
    end
end);

btnParty:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_TOP");
    GameTooltip:AddLine("|cff00ccffBordo UI Party Frames|r");
    GameTooltip:AddLine("Click to toggle modern group unit frames.", 1, 1, 1);
    GameTooltip:AddLine("Slash commands: |cffffd100/bparty|r or |cffffd100/bordo party|r", 0.7, 0.7, 0.7);
    GameTooltip:Show();
end);

btnParty:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

-- Close Button [X]
local btnClose = CreateFrame("Button", nil, header);
btnClose:SetWidth(18);
btnClose:SetHeight(18);
btnClose:SetPoint("RIGHT", header, "RIGHT", -2, 0);

local btnCloseText = btnClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
btnCloseText:SetPoint("CENTER", btnClose, "CENTER", 0, 0);
btnCloseText:SetText("|cffff5555X|r");

btnClose:SetScript("OnClick", function()
    mainFrame:Hide();
end);

-- Collapse / Expand Button [-] / [+]
local btnCollapse = CreateFrame("Button", nil, header);
btnCollapse:SetWidth(18);
btnCollapse:SetHeight(18);
btnCollapse:SetPoint("RIGHT", btnClose, "LEFT", -2, 0);

local btnCollapseText = btnCollapse:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
btnCollapseText:SetPoint("CENTER", btnCollapse, "CENTER", 0, 0);
btnCollapseText:SetText("[-]");

-- Scale [+] Button
local btnPlus = CreateFrame("Button", nil, header);
btnPlus:SetWidth(16);
btnPlus:SetHeight(16);
btnPlus:SetPoint("RIGHT", btnCollapse, "LEFT", -2, 0);

local plusText = btnPlus:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
plusText:SetPoint("CENTER", btnPlus, "CENTER", 0, 0);
plusText:SetText("+");

-- Scale Percentage Label
local scaleLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
scaleLabel:SetPoint("RIGHT", btnPlus, "LEFT", -2, 0);
scaleLabel:SetText("80%");
mainFrame.scaleLabel = scaleLabel;

-- Scale [-] Button
local btnMinus = CreateFrame("Button", nil, header);
btnMinus:SetWidth(16);
btnMinus:SetHeight(16);
btnMinus:SetPoint("RIGHT", scaleLabel, "LEFT", -2, 0);

local minusText = btnMinus:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
minusText:SetPoint("CENTER", btnMinus, "CENTER", 0, 0);
minusText:SetText("-");

-- Scale Handler Function
function AZSHelper:SetTableScale(scale)
    if ( not scale ) then scale = 0.80; end
    scale = math.min(1.4, math.max(0.45, scale));
    scale = math.floor(scale * 100 + 0.5) / 100;
    AZSHelperDB.tableScale = scale;
    mainFrame:SetScale(scale);
    if ( mainFrame.scaleLabel ) then
        mainFrame.scaleLabel:SetText(string.format("%.0f%%", scale * 100));
    end
end

btnMinus:SetScript("OnClick", function()
    local cur = (AZSHelperDB and AZSHelperDB.tableScale) or 0.80;
    AZSHelper:SetTableScale(cur - 0.05);
end);

btnPlus:SetScript("OnClick", function()
    local cur = (AZSHelperDB and AZSHelperDB.tableScale) or 0.80;
    AZSHelper:SetTableScale(cur + 0.05);
end);

-- Mousewheel Scaling on Header
header:EnableMouseWheel(true);
header:SetScript("OnMouseWheel", function()
    local cur = (AZSHelperDB and AZSHelperDB.tableScale) or 0.80;
    if ( arg1 > 0 ) then
        AZSHelper:SetTableScale(cur + 0.05);
    else
        AZSHelper:SetTableScale(cur - 0.05);
    end
end);

header:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    GameTooltip:AddLine("|cff00ccffBordo UI Damage Stats|r");
    GameTooltip:AddLine("Scroll mouse wheel or click [-] / [+] to change size.", 1, 1, 1);
    GameTooltip:AddLine("Hold & drag to move window.", 0.7, 0.7, 0.7);
    GameTooltip:Show();
end);
header:SetScript("OnLeave", function() GameTooltip:Hide(); end);

-- 2. Overview Card: Top Records & Crit Chance
local overviewCard = CreateFrame("Frame", nil, mainFrame);
overviewCard:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, -26);
overviewCard:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", -6, -96);
overviewCard:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
});
overviewCard:SetBackdropColor(0.07, 0.08, 0.12, 0.85);
overviewCard:SetBackdropBorderColor(0.9, 0.7, 0.15, 0.7);

-- Highest Crit Display
local hcLabel = overviewCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
hcLabel:SetPoint("TOPLEFT", overviewCard, "TOPLEFT", 6, -6);
hcLabel:SetText("HIGHEST CRIT:");

local hcValue = overviewCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
hcValue:SetPoint("LEFT", hcLabel, "RIGHT", 6, 0);
hcValue:SetTextColor(1.0, 0.85, 0.2);
hcValue:SetText("0");
mainFrame.hcValue = hcValue;

local hcIcon = overviewCard:CreateTexture(nil, "ARTWORK");
hcIcon:SetWidth(14);
hcIcon:SetHeight(14);
hcIcon:SetPoint("TOPLEFT", hcLabel, "BOTTOMLEFT", 0, -3);
hcIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
hcIcon:Hide();
mainFrame.hcIcon = hcIcon;

local hcSpell = overviewCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
hcSpell:SetPoint("TOPLEFT", hcLabel, "BOTTOMLEFT", 0, -3);
hcSpell:SetText("Ability: -");
mainFrame.hcSpell = hcSpell;

-- Character Sheet Crit & Real Crit Rate
local charCritText = overviewCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
charCritText:SetPoint("TOPLEFT", hcLabel, "BOTTOMLEFT", 0, -19);
charCritText:SetText("Char Crit: 0.0%  |  Actual: 0.0%");
mainFrame.charCritText = charCritText;

local runSummaryText = overviewCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
runSummaryText:SetPoint("TOPLEFT", charCritText, "BOTTOMLEFT", 0, -2);
runSummaryText:SetText("DPS: 0  |  Damage: 0");
mainFrame.runSummaryText = runSummaryText;

-- 3. Table Column Headers
local tableHeader = CreateFrame("Frame", nil, mainFrame);
tableHeader:SetPoint("TOPLEFT", overviewCard, "BOTTOMLEFT", 0, -4);
tableHeader:SetPoint("BOTTOMRIGHT", overviewCard, "BOTTOMRIGHT", 0, -22);

local col1 = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
col1:SetPoint("LEFT", tableHeader, "LEFT", 4, 0);
col1:SetText("Ability");

local col2 = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
col2:SetPoint("LEFT", tableHeader, "LEFT", 130, 0);
col2:SetText("Max Crit");

local col3 = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
col3:SetPoint("LEFT", tableHeader, "LEFT", 202, 0);
col3:SetText("Crit Rate");

local col4 = tableHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
col4:SetPoint("RIGHT", tableHeader, "RIGHT", -4, 0);
col4:SetText("DPS");

-- 4. Attack Rows (Up to 10 rows)
mainFrame.rows = {};
for i = 1, 10 do
    local r = CreateFrame("Frame", nil, mainFrame);
    r:SetHeight(20);
    r:SetPoint("TOPLEFT", tableHeader, "BOTTOMLEFT", 0, -(i - 1) * 21);
    r:SetPoint("RIGHT", mainFrame, "RIGHT", -6, 0);
    
    if ( math.mod(i, 2) == 0 ) then
        local rBg = r:CreateTexture(nil, "BACKGROUND");
        rBg:SetAllPoints(r);
        rBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
        rBg:SetVertexColor(0.2, 0.2, 0.3, 0.25);
    end
    
    -- Spell Icon (16x16 with 1px dark border)
    local iconFrame = CreateFrame("Frame", nil, r);
    iconFrame:SetWidth(16);
    iconFrame:SetHeight(16);
    iconFrame:SetPoint("LEFT", r, "LEFT", 4, 0);
    
    local iconTex = iconFrame:CreateTexture(nil, "ARTWORK");
    iconTex:SetAllPoints(iconFrame);
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92);
    r.iconTex = iconTex;
    r.iconFrame = iconFrame;
    
    local iconBorder = CreateFrame("Frame", nil, iconFrame);
    iconBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -1, 1);
    iconBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 1, -1);
    iconBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 4,
        edgeSize = 4,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    iconBorder:SetBackdropBorderColor(0.12, 0.12, 0.15, 0.90);
    
    local rName = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    rName:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0);
    rName:SetWidth(102);
    rName:SetJustifyH("LEFT");
    r.name = rName;
    
    local rMaxCrit = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
    rMaxCrit:SetPoint("LEFT", r, "LEFT", 130, 0);
    rMaxCrit:SetWidth(68);
    rMaxCrit:SetJustifyH("LEFT");
    rMaxCrit:SetTextColor(1.0, 0.85, 0.2);
    r.maxCrit = rMaxCrit;
    
    local rRate = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    rRate:SetPoint("LEFT", r, "LEFT", 202, 0);
    rRate:SetWidth(56);
    rRate:SetJustifyH("LEFT");
    r.rate = rRate;
    
    local rDPS = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    rDPS:SetPoint("RIGHT", r, "RIGHT", -4, 0);
    rDPS:SetWidth(44);
    rDPS:SetJustifyH("RIGHT");
    r.dps = rDPS;
    
    r:Hide();
    mainFrame.rows[i] = r;
end

-- 5. Bottom Controls
local btnReset = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate");
btnReset:SetWidth(80);
btnReset:SetHeight(18);
btnReset:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 6, 6);
btnReset:SetText("Reset");
btnReset:SetScript("OnClick", function()
    AZSHelper:ResetSpellStats();
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Statistics reset.");
end);

local helpText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
helpText:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -6, 8);
helpText:SetText("/bordo size 0.7");

-- Collapse Logic
local isCollapsed = false;
local function SetCollapsed(collapsed)
    isCollapsed = collapsed;
    AZSHelperDB.collapsed = collapsed;
    if ( collapsed ) then
        overviewCard:Hide();
        tableHeader:Hide();
        for i = 1, 10 do mainFrame.rows[i]:Hide(); end
        btnReset:Hide();
        helpText:Hide();
        mainFrame:SetHeight(30);
        btnCollapseText:SetText("[+]");
    else
        overviewCard:Show();
        tableHeader:Show();
        btnReset:Show();
        helpText:Show();
        mainFrame:SetHeight(360);
        btnCollapseText:SetText("[-]");
        AZSHelper:UpdateStatsTable();
    end
end

btnCollapse:SetScript("OnClick", function()
    SetCollapsed(not isCollapsed);
end);

-- 6. Update Stats Table Function
function AZSHelper:UpdateStatsTable()
    if ( not mainFrame:IsShown() or isCollapsed ) then return; end
    
    -- Update Overview
    local maxC = AZSHelper.OverallMaxCrit or 0;
    mainFrame.hcValue:SetText(AZSHelper:FormatNumber(maxC));
    local maxCSpell = AZSHelper.OverallMaxCritSpell or "-";
    if ( maxCSpell and maxCSpell ~= "-" ) then
        local icon = AZSHelper:GetSpellIcon(maxCSpell);
        mainFrame.hcIcon:SetTexture(icon);
        mainFrame.hcIcon:Show();
        mainFrame.hcSpell:ClearAllPoints();
        mainFrame.hcSpell:SetPoint("LEFT", mainFrame.hcIcon, "RIGHT", 4, 0);
        mainFrame.hcSpell:SetText("Ability: |cffffffff" .. maxCSpell .. "|r");
    else
        mainFrame.hcIcon:Hide();
        mainFrame.hcSpell:ClearAllPoints();
        mainFrame.hcSpell:SetPoint("TOPLEFT", overviewCard, "TOPLEFT", 6, -22);
        mainFrame.hcSpell:SetText("Ability: -");
    end
    
    local sheetCrit = (AZS_STATS and AZS_STATS.crit) or 0;
    if ( sheetCrit <= 1.0 and sheetCrit > 0 ) then
        sheetCrit = sheetCrit * 100;
    end
    local sheetCM = (AZS_STATS and AZS_STATS.cm) or 1.5;
    local totalH = AZSHelper.TotalHits or 0;
    local totalC = AZSHelper.TotalCrits or 0;
    local measuredRate = (totalH > 0) and ((totalC / totalH) * 100) or 0;
    
    mainFrame.charCritText:SetText(string.format("Char Crit: |cff00ff00%.1f%%|r (x%.1f)  |  Actual: |cffffd100%.1f%%|r (%d/%d)",
        sheetCrit, sheetCM, measuredRate, totalC, totalH));
        
    local totalDmg = (AZS_RUN and AZS_RUN.dealt) or 0;
    local currentDPS = 0;
    if ( AZS_GetMeter ) then
        local _, _, d = AZS_GetMeter();
        currentDPS = d or 0;
    end
    mainFrame.runSummaryText:SetText(string.format("DPS: |cffffffff%s|r  |  Total Damage: |cffffffff%s|r",
        AZSHelper:FormatNumber(currentDPS), AZSHelper:FormatNumber(totalDmg)));
        
    -- Aggregate Attacks from Meter & Combat Log
    local attackList = {};
    local seen = {};
    
    if ( AZS_GetMeter ) then
        local lines = AZS_GetMeter();
        lines = lines or {};
        for i = 1, table.getn(lines) do
            local l = lines[i];
            if ( l and l.name ) then
                seen[l.name] = true;
                local sData = AZSHelper.SpellStats[l.name];
                table.insert(attackList, {
                    name    = l.name,
                    dmg     = l.dmg or 0,
                    dps     = l.dps or 0,
                    maxCrit = sData and sData.maxCrit or 0,
                    hits    = sData and sData.hits or 0,
                    crits   = sData and sData.crits or 0,
                });
            end
        end
    end
    
    for spName, sData in pairs(AZSHelper.SpellStats) do
        if ( not seen[spName] ) then
            table.insert(attackList, {
                name    = spName,
                dmg     = 0,
                dps     = 0,
                maxCrit = sData.maxCrit or 0,
                hits    = sData.hits or 0,
                crits   = sData.crits or 0,
            });
        end
    end
    
    -- Populate Rows
    local num = table.getn(attackList);
    for i = 1, 10 do
        local row = mainFrame.rows[i];
        if ( i <= num ) then
            local at = attackList[i];
            row.name:SetText(at.name);
            
            local icon = AZSHelper:GetSpellIcon(at.name);
            if ( row.iconTex ) then
                row.iconTex:SetTexture(icon);
            end
            
            if ( at.maxCrit > 0 ) then
                row.maxCrit:SetText(AZSHelper:FormatNumber(at.maxCrit));
            else
                row.maxCrit:SetText("-");
            end
            
            if ( at.hits > 0 ) then
                local pct = (at.crits / at.hits) * 100;
                row.rate:SetText(string.format("%.0f%% (%d)", pct, at.crits));
            else
                row.rate:SetText("-");
            end
            
            row.dps:SetText(AZSHelper:FormatNumber(at.dps));
            row:Show();
        else
            row:Hide();
        end
    end
end

-- Refresh loop (throttled every 0.3s)
local refreshElapsed = 0;
local lastPhase = nil;
mainFrame:SetScript("OnUpdate", function()
    refreshElapsed = refreshElapsed + arg1;
    if ( refreshElapsed < 0.3 ) then return; end
    refreshElapsed = 0;
    
    -- Auto reset on new run
    local ph = (AZS_GetPhase and AZS_GetPhase()) or (AZS_RUN and AZS_RUN.ph);
    if ( ph == "ready" and lastPhase and lastPhase ~= "ready" ) then
        AZSHelper:ResetSpellStats();
    end
    lastPhase = ph;
    
    AZSHelper:UpdateStatsTable();
end);

mainFrame:SetScript("OnShow", function()
    if ( AZSHelper_ViewStatsButton and AZSHelper_ViewStatsButton.text ) then
        AZSHelper_ViewStatsButton.text:SetText("Attack Stats <<");
    end
end);

mainFrame:SetScript("OnHide", function()
    if ( AZSHelper_ViewStatsButton and AZSHelper_ViewStatsButton.text ) then
        AZSHelper_ViewStatsButton.text:SetText("Attack Stats >>");
    end
end);

-- Restore saved position and scale on load
local initFrame = CreateFrame("Frame");
initFrame:RegisterEvent("VARIABLES_LOADED");
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
initFrame:RegisterEvent("SPELLS_CHANGED");
initFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
initFrame:SetScript("OnEvent", function()
    if ( event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" or event == "PLAYER_ENTERING_WORLD" ) then
        ScanSpellbookIcons();
    end
    local sc = (AZSHelperDB and AZSHelperDB.tableScale) or 0.80;
    AZSHelper:SetTableScale(sc);
    if ( AZSHelperDB ) then
        if ( AZSHelperDB.statsPos and AZSHelperDB.statsPos.custom ) then
            AZSHelper:RestorePosition(mainFrame, AZSHelperDB.statsPos);
        else
            AZSHelper:AnchorStatsTableToMultipliers();
        end
        if ( AZSHelperDB.collapsed ) then
            SetCollapsed(true);
        end
    end
end);
