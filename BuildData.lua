-- BordoUI: Meta Build Database & Advisor Data
-- Azeroth Survivors meta builds for all 9 classes with authentic WoW 1.12 spell/item assets.
BordoUI = BordoUI or {};
BordoUI_BuildData = {};

local CLASSES = {
    HUNTER  = { name = "Hunter",  color = { 0.67, 0.83, 0.45 }, hex = "aad372" },
    PALADIN = { name = "Paladin", color = { 0.96, 0.55, 0.73 }, hex = "f58cba" },
    WARRIOR = { name = "Warrior", color = { 0.78, 0.61, 0.43 }, hex = "c79c6e" },
    MAGE    = { name = "Mage",    color = { 0.41, 0.80, 0.94 }, hex = "69ccf0" },
    WARLOCK = { name = "Warlock", color = { 0.58, 0.51, 0.79 }, hex = "9482c9" },
    ROGUE   = { name = "Rogue",   color = { 1.00, 0.96, 0.41 }, hex = "fff569" },
    SHAMAN  = { name = "Shaman",  color = { 0.00, 0.44, 0.87 }, hex = "0070de" },
    PRIEST  = { name = "Priest",  color = { 1.00, 1.00, 1.00 }, hex = "ffffff" },
    DRUID   = { name = "Druid",   color = { 1.00, 0.49, 0.04 }, hex = "ff7d0a" },
};

BordoUI_BuildData.Classes = CLASSES;
BordoUI_BuildData.ClassOrder = {
    "HUNTER", "PALADIN", "WARRIOR", "MAGE", "WARLOCK", "ROGUE", "SHAMAN", "PRIEST", "DRUID"
};

-- 18 Comprehensive Builds (2 per class)
BordoUI_BuildData.Builds = {
    -- ------------------------------------------------------------------------
    -- HUNTER
    -- ------------------------------------------------------------------------
    HUNTER = {
        {
            id = "hunter_volley_trapper",
            title = "Volley Trapper",
            spec = "Survival / Beastmaster",
            role = "AoE Waveclear & Speed Farming Meta",
            summary = "The top-tier mob grinding build. Combines screen-wide Volley with high-frequency fire traps to obliterate waves before they get close.",
            statPriority = "Cooldown Reduction > Spell / Fire Damage > Area Radius > Crit Chance",
            stats = {
                { name = "Cooldown Reduction", note = "Enables continuous trap deployment and 100% Volley uptime" },
                { name = "Fire / Spell Damage", note = "Directly scales Explosive Trap, Immolation Trap, and Volley" },
                { name = "Area / Radius", note = "Widens Volley radius to blanket entire screen chokepoints" },
                { name = "Critical Strike", note = "Triggers massive double-damage bursts on trapped clusters" },
            },
            spells = {
                {
                    key = "volley",
                    name = "Volley",
                    icon = "Interface\\Icons\\Ability_Marksmanship",
                    school = "Arcane",
                    prio = 1,
                    rankMax = 8,
                    reason = "Primary waveclearing spell. Continuously rains arrows in a large radius, decimating dense enemy packs.",
                },
                {
                    key = "explosive_trap",
                    name = "Explosive Trap",
                    icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
                    school = "Fire",
                    prio = 2,
                    rankMax = 8,
                    reason = "Huge burst fire damage upon triggering. Melts approaching hordes instantly when stacked with CDR.",
                },
                {
                    key = "multi_shot",
                    name = "Multi-Shot",
                    icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Frontal cone physical burst. Covers gaps between trap cooldowns and cleaves fast rushers.",
                },
                {
                    key = "immolation_trap",
                    name = "Immolation Trap",
                    icon = "Interface\\Icons\\Spell_Fire_Immolation",
                    school = "Fire",
                    prio = 4,
                    rankMax = 8,
                    reason = "Persistent fire ground burn. Ensures that even high-HP elites take continuous burning damage.",
                },
                {
                    key = "serpent_sting",
                    name = "Serpent Sting",
                    icon = "Interface\\Icons\\Ability_Hunter_Quickshot",
                    school = "Nature",
                    prio = 5,
                    rankMax = 8,
                    reason = "Reliable single-target nature DoT. Automatically softens tough champions and bosses.",
                },
                {
                    key = "arcane_shot",
                    name = "Arcane Shot",
                    icon = "Interface\\Icons\\Ability_ImpalingBolt",
                    school = "Arcane",
                    prio = 6,
                    rankMax = 8,
                    reason = "Fast cooldown instant shot. Fills single-target cooldown gaps against surviving enemies.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Provides highest base critical strike and attack power to scale all arrow and physical damage.",
                },
                                ring1 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Essential for lowering trap and Volley cooldowns, allowing near permanent AoE coverage.",
                },
                                ring2 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+65% Dmg",
                    stats = { "+65% Dmg" },
                    equip = "Increases all damage dealt by your spells and physical attacks.",
                    why = "Direct multiplicative damage scaling across both physical shots and elemental traps.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Enormous spell power boost that doubles the burst damage of Explosive Trap and Volley waves.",
                },
                                trinket2 = {
                    name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+236% Crit Dmg",
                    stats = { "+236% Crit Dmg" },
                    equip = "Increases the critical damage multiplier of all attacks and spells.",
                    why = "Consistent flat critical chance bonus ensuring reliable crits on multi-target strikes.",
                },
            },
            tactics = {
                "Prioritize ranking up Volley to Rank 3 as fast as possible (before 05:00) to secure early wave control.",
                "With Quick Strike Ring equipped, keep moving in wide arcs to lure enemies into overlapping trap fields.",
                "Against stage bosses, keep Serpent Sting active while maintaining maximum distance.",
            },
        },
        {
            id = "hunter_aimed_sniper",
            title = "Aimed Shot Sniper",
            spec = "Marksmanship",
            role = "Boss & Elite Melter Single-Target Meta",
            summary = "Designed to deliver catastrophic single-target crits. Melts guardians and final bosses in seconds with heavy physical shots.",
            statPriority = "Critical Strike Chance > Attack Power > Cooldown Reduction > Attack Speed",
            stats = {
                { name = "Critical Strike Chance", note = "Aimed Shot scales with giant critical damage multipliers" },
                { name = "Attack Power", note = "Directly increases the base weapon damage of all physical attacks" },
                { name = "Cooldown Reduction", note = "Enables faster Aimed Shot and Rapid Fire cycling" },
                { name = "Attack Speed", note = "Reduces windup time and triggers frequent auto-shots" },
            },
            spells = {
                {
                    key = "aimed_shot",
                    name = "Aimed Shot",
                    icon = "Interface\\Icons\\INV_Spear_07",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "The premier boss killing nuke. High damage multiplier that deals colossal single-target chunks.",
                },
                {
                    key = "multi_shot",
                    name = "Multi-Shot",
                    icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Cleaves secondary adds while sustaining primary pressure on the elite target.",
                },
                {
                    key = "rapid_fire",
                    name = "Rapid Fire",
                    icon = "Interface\\Icons\\Ability_Hunter_RunningShot",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Massive haste and attack speed steroid, turning your hunter into a machine gun during boss phases.",
                },
                {
                    key = "serpent_sting",
                    name = "Serpent Sting",
                    icon = "Interface\\Icons\\Ability_Hunter_Quickshot",
                    school = "Nature",
                    prio = 4,
                    rankMax = 8,
                    reason = "Constant ticking nature DoT keeping boss health depleting during movement phases.",
                },
                {
                    key = "concussive_shot",
                    name = "Concussive Shot",
                    icon = "Interface\\Icons\\Spell_Frost_Stun",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Kiting control. Slows rushing bosses and dangerous elite mobs, keeping you safe at maximum range.",
                },
                {
                    key = "arcane_shot",
                    name = "Arcane Shot",
                    icon = "Interface\\Icons\\Ability_ImpalingBolt",
                    school = "Arcane",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant-cast shot to weave between Aimed Shot recovery periods.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "BiS necklace for physical hunters, maximizing Aimed Shot critical output.",
                },
                                ring1 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Turns every Aimed Shot crit into a devastating chunk that drops boss HP bars rapidly.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Reduces the lengthy Aimed Shot cooldown for rapid-fire execution.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Chance to trigger a free instant physical attack, dramatically boosting sustained DPS.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+210% Dmg",
                    stats = { "+210% Dmg" },
                    equip = "Increases physical and weapon attack power by a massive percentage.",
                    why = "Provides a temporary colossal Attack Power boost that aligns with Rapid Fire burst windows.",
                },
            },
            tactics = {
                "Maintain maximum range from enemies to give Aimed Shot clean line of sight.",
                "Pop Rapid Fire as soon as a Guardian or Boss spawns to burst them down immediately.",
                "Pick Multi-Shot to handle trash adds so your Aimed Shot lands squarely on the priority target.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- PALADIN
    -- ------------------------------------------------------------------------
    PALADIN = {
        {
            id = "paladin_retribution",
            title = "Retribution Crusader",
            spec = "Retribution",
            role = "Holy Burst & Undead Cleanser Meta",
            summary = "The classic holy power house. Bathes the battlefield in Consecration while blasting demons and undead with Holy Wrath and Exorcism.",
            statPriority = "Holy Spell Damage > Cooldown Reduction > Critical Strike > Area Radius",
            stats = {
                { name = "Holy Spell Damage", note = "Increases all holy ability damage (Consecration, Wrath, Judgement)" },
                { name = "Cooldown Reduction", note = "Enables rapid rotation of Judgement, Exorcism, and Hammer of Wrath" },
                { name = "Critical Strike", note = "Triggers huge yellow crit numbers and holy vengeance procs" },
                { name = "Area Radius", note = "Expands Consecration and Holy Wrath coverage to hit more enemies" },
            },
            spells = {
                {
                    key = "consecration",
                    name = "Consecration",
                    icon = "Interface\\Icons\\Spell_Holy_InnerFire",
                    school = "Holy",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core persistent holy field. Damages all enemies walking through it; mandatory foundation.",
                },
                {
                    key = "holy_wrath",
                    name = "Holy Wrath",
                    icon = "Interface\\Icons\\Spell_Holy_Excorcism",
                    school = "Holy",
                    prio = 2,
                    rankMax = 8,
                    reason = "Radial holy blast. Delivers massive damage and brief stuns to all surrounding enemies.",
                },
                {
                    key = "judgement",
                    name = "Judgement",
                    icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
                    school = "Holy",
                    prio = 3,
                    rankMax = 8,
                    reason = "Frequent targeted holy burst with short cooldown. Excellent for targeting priority threats.",
                },
                {
                    key = "exorcism",
                    name = "Exorcism",
                    icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
                    school = "Holy",
                    prio = 4,
                    rankMax = 8,
                    reason = "Heavy direct holy nuke that deals bonus damage against undead and demonic opponents.",
                },
                {
                    key = "hammer_of_wrath",
                    name = "Hammer of Wrath",
                    icon = "Interface\\Icons\\Ability_ThunderClap",
                    school = "Holy",
                    prio = 5,
                    rankMax = 8,
                    reason = "The holy execute hammer. Deals gigantic damage to enemies below 20% health.",
                },
                {
                    key = "hammer_of_justice",
                    name = "Hammer of Justice",
                    icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
                    school = "Holy",
                    prio = 6,
                    rankMax = 8,
                    reason = "Essential 5-second stun to lock down charging elites and interrupt dangerous casts.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Massively boosts holy spell damage across all 6 core spells.",
                },
                                ring1 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows near 100% Consecration uptime and rapid Holy Wrath spam.",
                },
                                ring2 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+65% Dmg",
                    stats = { "+65% Dmg" },
                    equip = "Increases all damage dealt by your spells and physical attacks.",
                    why = "Multiplies all holy spell damage output and prevents misses against high-level guardians.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Turns Holy Wrath into a screen-clearing explosion during peak density.",
                },
                                trinket2 = {
                    name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+236% Crit Dmg",
                    stats = { "+236% Crit Dmg" },
                    equip = "Increases the critical damage multiplier of all attacks and spells.",
                    why = "Ensures frequent Holy Wrath and Exorcism critical strikes.",
                },
            },
            tactics = {
                "Keep moving through enemy waves so they follow you through the Consecration fire.",
                "Save Hammer of Wrath for bosses and elite guardians as soon as their health drops low.",
                "Stun charging champions with Hammer of Justice to prevent heavy incoming hits.",
            },
        },
        {
            id = "paladin_holy_bulwark",
            title = "Holy Bulwark Tank",
            spec = "Protection / Holy",
            role = "Immortal Spikes & Reflect Tank Meta",
            summary = "Unkillable juggernaut. Stacks holy shields, reflective thorns, and burst healing to outlast any encounter while enemies destroy themselves.",
            statPriority = "Max Health > Damage Reduction > Holy Spell Damage > Block Value",
            stats = {
                { name = "Max Health", note = "Expands your health pool to absorb high-tier guardian slams" },
                { name = "Damage Reduction", note = "Reduces all incoming physical and magic hits" },
                { name = "Holy Spell Damage", note = "Scales Holy Shield reflective damage and Consecration" },
                { name = "Block Value", note = "Absorbs flat damage from every incoming melee attack" },
            },
            spells = {
                {
                    key = "holy_shield",
                    name = "Holy Shield",
                    icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection",
                    school = "Holy",
                    prio = 1,
                    rankMax = 8,
                    reason = "Increases block chance and retaliates with holy damage whenever an attack is blocked.",
                },
                {
                    key = "consecration",
                    name = "Consecration",
                    icon = "Interface\\Icons\\Spell_Holy_InnerFire",
                    school = "Holy",
                    prio = 2,
                    rankMax = 8,
                    reason = "Primary damaging aura that softens attacking enemies while you hold ground.",
                },
                {
                    key = "holy_light",
                    name = "Holy Light",
                    icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
                    school = "Holy",
                    prio = 3,
                    rankMax = 8,
                    reason = "Emergency high-potency self-heal that restores large portions of your health bar.",
                },
                {
                    key = "holy_shock",
                    name = "Holy Shock",
                    icon = "Interface\\Icons\\Spell_Holy_SearingLight",
                    school = "Holy",
                    prio = 4,
                    rankMax = 8,
                    reason = "Instant-cast holy spell. Can burst enemies down or provide instant emergency healing.",
                },
                {
                    key = "judgement",
                    name = "Judgement",
                    icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
                    school = "Holy",
                    prio = 5,
                    rankMax = 8,
                    reason = "Consistent single-target offensive holy strike maintaining steady boss DPS.",
                },
                {
                    key = "divine_shield",
                    name = "Divine Shield",
                    icon = "Interface\\Icons\\Spell_Holy_DivineIntervention",
                    school = "Holy",
                    prio = 6,
                    rankMax = 8,
                    reason = "The legendary immunity bubble. Protects you from 100% of damage in lethal situations.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Medallion of Steadfast Might",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_03",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+40% HP, +25% Armor",
                    stats = { "+40% HP", "+25% Armor" },
                    equip = "Increases maximum health and armor mitigation against incoming physical damage.",
                    why = "Provides massive defensive stats to withstand swarming horde attacks.",
                },
                                ring1 = {
                    name = "Heavy Dark Iron Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_14",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+40% HP",
                    stats = { "+40% HP" },
                    equip = "Increases your maximum health pool and damage resistance.",
                    why = "Top tier defensive ring adding flat durability and physical damage absorption.",
                },
                                ring2 = {
                    name = "Archimtiros' Ring of Reckoning",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_40",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+30% Armor, +25% HP",
                    stats = { "+30% Armor, +25% HP" },
                    equip = "Decreases damage taken by 30% and grants bonus maximum health.",
                    why = "Percentage damage reduction that scales effectively against late-game bosses.",
                },
                                trinket1 = {
                    name = "Lifegiving Gem",
                    icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+60% HP & Heal",
                    stats = { "+60% HP & Heal" },
                    equip = "Increases maximum health and provides an emergency heal when low.",
                    why = "The premier survival trinket. Boosts max health and acts as a second life.",
                },
                                trinket2 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Boosts Holy Shield reflect damage and Holy Light heal potency.",
                },
            },
            tactics = {
                "Keep Holy Shield active continuously; let swarmers hit your shield to damage themselves.",
                "Use Divine Shield when surrounded by multiple elites or during boss enrage phases.",
                "Stack health and defensive jewelry so your heals have time to recover your health pool.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- WARRIOR
    -- ------------------------------------------------------------------------
    WARRIOR = {
        {
            id = "warrior_whirlwind_cleaver",
            title = "Whirlwind Cleaver",
            spec = "Fury",
            role = "360-Degree Melee Blender Meta",
            summary = "Spin-to-win playstyle. Whirlwind and Cleave cut down surrounding swarms while Bloodthirst sustains your HP bar through constant combat.",
            statPriority = "Attack Power > Critical Strike > Cooldown Reduction > Attack Speed",
            stats = {
                { name = "Attack Power", note = "Increases all physical weapon damage hits" },
                { name = "Critical Strike", note = "Triggers Flurry attack speed buffs and Deep Wounds" },
                { name = "Cooldown Reduction", note = "Reduces Whirlwind and Thunder Clap cycling time" },
                { name = "Attack Speed", note = "Accelerates auto-swings and extra attack procs" },
            },
            spells = {
                {
                    key = "whirlwind",
                    name = "Whirlwind",
                    icon = "Interface\\Icons\\Ability_Whirlwind",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core spinning attack hitting all surrounding targets in a 360-degree radius.",
                },
                {
                    key = "cleave",
                    name = "Cleave",
                    icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Frontal multi-target weapon sweep that multiplies your melee strike efficiency.",
                },
                {
                    key = "thunder_clap",
                    name = "Thunder Clap",
                    icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Radial shockwave that damages all nearby enemies and slows their attack and move speed.",
                },
                {
                    key = "bloodthirst",
                    name = "Bloodthirst",
                    icon = "Interface\\Icons\\Spell_Nature_BloodLust",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Instant heavy physical strike that heals you for a percentage of damage dealt.",
                },
                {
                    key = "mortal_strike",
                    name = "Mortal Strike",
                    icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Heavy physical nuke reducing target healing by 50%; excellent for bosses.",
                },
                {
                    key = "slam",
                    name = "Slam",
                    icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Direct overhead slam providing steady single-target physical damage.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Top physical DPS neck for scaling Whirlwind and Cleave crits.",
                },
                                ring1 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Multiplies critical strike damage on multi-target physical hits.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows near-continuous Whirlwind spinning without delay.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Triggers free extra attacks that can recursively proc more weapon strikes.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+210% Dmg",
                    stats = { "+210% Dmg" },
                    equip = "Increases physical and weapon attack power by a massive percentage.",
                    why = "Colossal attack power steroid for deleting elite packs and bosses.",
                },
            },
            tactics = {
                "Charge into dense monster clusters to maximize Whirlwind and Cleave hit counts.",
                "Use Bloodthirst continuously on cooldown to keep your health bar topped off.",
                "Keep Thunder Clap applied to prevent swarming mobs from overwhelming your position.",
            },
        },
        {
            id = "warrior_bleed_berserker",
            title = "Rend & Bleed Berserker",
            spec = "Arms",
            role = "Deep Wounds & Execute Boss Shredder Meta",
            summary = "Arms bleed specialist. Stacks Rend and Deep Wounds on targets, finishing them off with overwhelming Overpower and Execute strikes.",
            statPriority = "Critical Strike > Physical Damage > Armor Penetration > Lifesteal",
            stats = {
                { name = "Critical Strike", note = "Crit hits trigger Deep Wounds bleeds that stack infinitely" },
                { name = "Physical Damage", note = "Increases all weapon and bleed ticks" },
                { name = "Armor Penetration", note = "Bypasses high armor on armored guardians and bosses" },
                { name = "Lifesteal", note = "Recovers health from ongoing bleed ticks" },
            },
            spells = {
                {
                    key = "mortal_strike",
                    name = "Mortal Strike",
                    icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Primary weapon nuke delivering high base physical damage and triggering deep wound crits.",
                },
                {
                    key = "rend",
                    name = "Rend",
                    icon = "Interface\\Icons\\Ability_Gouge",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Core physical bleed that steadily drains enemy health pools over time.",
                },
                {
                    key = "whirlwind",
                    name = "Whirlwind",
                    icon = "Interface\\Icons\\Ability_Whirlwind",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "AoE applicator to spread Deep Wounds across multiple approaching enemies.",
                },
                {
                    key = "overpower",
                    name = "Overpower",
                    icon = "Interface\\Icons\\Ability_MeleeDamage",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Unavoidable physical strike with +50% critical strike bonus.",
                },
                {
                    key = "sweeping_strikes",
                    name = "Sweeping Strikes",
                    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Causes your next attacks to cleave to additional adjacent enemies.",
                },
                {
                    key = "execute",
                    name = "Execute",
                    icon = "Interface\\Icons\\INV_Sword_48",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Devastating execute blow that finishes off targets below 20% health instantly.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Increases physical base damage and Deep Wounds bleed tick size.",
                },
                                ring1 = {
                    name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+12% Lifesteal",
                    stats = { "+12% Lifesteal" },
                    equip = "Heals you for 12% of all damage dealt to enemy units.",
                    why = "Lifesteal keeps you sustained as your bleeds tick on surrounding targets.",
                },
                                ring2 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+65% Dmg",
                    stats = { "+65% Dmg" },
                    equip = "Increases all damage dealt by your spells and physical attacks.",
                    why = "Multiplicative damage bonus scaling both base weapon strikes and bleed ticks.",
                },
                                trinket1 = {
                    name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+236% Crit Dmg",
                    stats = { "+236% Crit Dmg" },
                    equip = "Increases the critical damage multiplier of all attacks and spells.",
                    why = "High critical chance ensures reliable Deep Wounds procs.",
                },
                                trinket2 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Extra attacks yield additional chances to trigger Overpower and Execute.",
                },
            },
            tactics = {
                "Apply Rend to priority targets and let Deep Wounds stack from critical hits.",
                "Use Overpower whenever it lights up for near-guaranteed critical strikes.",
                "When a boss hits 20% health, Execute deletes their remaining health instantly.",
            },
        },
        {
            id = "warrior_shield_slam_prot",
            title = "Shield Slam Juggernaut",
            spec = "Protection",
            role = "Tanky Frontline & High Shield Slam Burst",
            summary = "Unstoppable heavily armored bulwark. Crushes enemies with devastating Shield Slams scaled by Block Value and Armor, sweeps waves with Cleave and Thunder Clap, and shrugs off incoming blows with Shield Block and Revenge.",
            statPriority = "Shield Block Value > Armor > Cooldown Reduction > Attack Speed > Critical Strike",
            stats = {
                { name = "Shield Block Value", note = "Directly fuels Shield Slam damage, scaling each shield bash into an avalanche of physical burst" },
                { name = "Armor & Defense", note = "Reduces all incoming physical damage and powers up Revenge counter-attacks" },
                { name = "Cooldown Reduction", note = "Maximizes uptime on Shield Slam, Shield Block, and radial Thunder Clap slows" },
                { name = "Attack Speed / Haste", note = "Accelerates rage generation and rapid-fire Cleave sweeps across clustered mobs" },
            },
            spells = {
                {
                    key = "shield_slam",
                    name = "Shield Slam",
                    icon = "Interface\\Icons\\INV_Shield_05",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core nuke ability. Bashes target for massive physical damage scaled by your shield block value. Obliterates elites and bosses.",
                },
                {
                    key = "cleave",
                    name = "Cleave",
                    icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Frontal multi-target weapon sweep. Multiplies damage into 2+ enemies at once to shred regular waves.",
                },
                {
                    key = "revenge",
                    name = "Revenge",
                    icon = "Interface\\Icons\\Ability_Warrior_Revenge",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Devastating counter-attack triggered by blocking or parrying attacks. Deals heavy damage with low cooldown.",
                },
                {
                    key = "thunder_clap",
                    name = "Thunder Clap",
                    icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Radial physical shockwave that damages all nearby enemies and slows their attack and movement speed.",
                },
                {
                    key = "shield_block",
                    name = "Shield Block",
                    icon = "Interface\\Icons\\Ability_Defensivestate",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Dramatically raises block chance and block value, ensuring nonstop Revenge triggers and surviving monster swarms.",
                },
                {
                    key = "battle_shout",
                    name = "Battle Shout",
                    icon = "Interface\\Icons\\Ability_Warrior_WarCry",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Party and self attack power aura, boosting damage of all weapon attacks and Shield Slam strikes.",
                },
            },
            jewelry = {
                neck = {
                    name = "Medallion of Steadfast Might",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_03",
                    quality = 3,
                    slot = "Necklace",
                    benefit = "+10% Red, +15% HP, Thorns",
                    stats = { "+150 Armor, +12% Block Value", "+15 Stamina" },
                    equip = "Increases the damage absorbed by your shield by 30 and adds 150 Armor.",
                    why = "Maximum shield block value scaling directly inflates Shield Slam burst damage while fortifying defenses.",
                },
                ring1 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+2% Hit, +16 Agility, +50 Armor",
                    stats = { "+2% Hit, +16 Agility", "+50 Armor" },
                    equip = "Improves your chance to hit with all physical attacks by 2%.",
                    why = "Hit cap is essential so your highest damage Shield Slam nukes land reliably on target every time.",
                },
                ring2 = {
                    name = "Heavy Dark Iron Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_14",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+110 Armor, +20 Stamina",
                    stats = { "+110 Armor, +20 Stamina", "+5 Defense" },
                    equip = "Adds 110 Armor and boosts survivability against swarming mob clusters.",
                    why = "Massive armor and stamina bonus allows you to tank continuous physical attacks while proccing Revenge.",
                },
                trinket1 = {
                    name = "Star of Mystaria",
                    icon = "Interface\\Icons\\INV_Enchant_EssenceMagicLarge",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+25% Max HP, +4% Dmg Red",
                    stats = { "+5% Block Chance, +24 Block Value", "+130 Armor" },
                    equip = "Increases chance to block attacks with a shield by 5% and increases block value by 24.",
                    why = "The ultimate Protection Warrior trinket in classic WoW. Huge block chance and block value boosts Shield Slam.",
                },
                trinket2 = {
                    name = "Lifegiving Gem",
                    icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Max HP",
                    stats = { "+1% Defense, +10 Stamina", "Equip: 1% chance on being hit to reduce physical damage by 25 for 10 sec." },
                    equip = "Grants damage absorption shield on being struck, making you virtually invincible in giant pack pulls.",
                    why = "Damage reduction on hit synergizes with Shield Block to completely nullify monster swarms.",
                },
            },
            tactics = {
                "Gather dense mob packs around you, activate Shield Block to trigger Revenge, and blast priority elites with Shield Slam!",
                "Keep Battle Shout active at all times to maximize physical base damage and Cleave sweeps.",
                "Use Thunder Clap whenever packs surround you to slow down enemy attack intervals.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- MAGE
    -- ------------------------------------------------------------------------
    MAGE = {
        {
            id = "mage_frost_shatter",
            title = "Frost Shatter",
            spec = "Frost",
            role = "Perma-Freeze & Blizzard Screen Wipe Meta",
            summary = "Total crowd control domination. Freezes whole screens with Frost Nova and Blizzard, triggering the legendary +50% Shatter crit combo.",
            statPriority = "Frost Spell Damage > Cooldown Reduction > Area Radius > Spell Crit",
            stats = {
                { name = "Frost Spell Damage", note = "Increases base damage of Blizzard, Cone of Cold, and Frostbolt" },
                { name = "Cooldown Reduction", note = "Permits continuous Frost Nova freeze cycles" },
                { name = "Area Radius", note = "Expands Blizzard and Frost Nova across the full screen" },
                { name = "Spell Crit", note = "Combines with Shatter for 100% critical strike rates on frozen mobs" },
            },
            spells = {
                {
                    key = "blizzard",
                    name = "Blizzard",
                    icon = "Interface\\Icons\\Spell_Frost_IceStorm",
                    school = "Frost",
                    prio = 1,
                    rankMax = 8,
                    reason = "Screen-wide ice storm. Heavily slows all approaching mobs while dealing continuous damage.",
                },
                {
                    key = "frost_nova",
                    name = "Frost Nova",
                    icon = "Interface\\Icons\\Spell_Frost_FrostNova",
                    school = "Frost",
                    prio = 2,
                    rankMax = 8,
                    reason = "Instant 360-degree root freezing all nearby enemies in place, triggering Shatter bonuses.",
                },
                {
                    key = "cone_of_cold",
                    name = "Cone of Cold",
                    icon = "Interface\\Icons\\Spell_Frost_Glacier",
                    school = "Frost",
                    prio = 3,
                    rankMax = 8,
                    reason = "Frontal frost wave dealing huge burst damage and slowing targets.",
                },
                {
                    key = "frostbolt",
                    name = "Frostbolt",
                    icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
                    school = "Frost",
                    prio = 4,
                    rankMax = 8,
                    reason = "Chilling single-target projectile to burst down frozen elites.",
                },
                {
                    key = "ice_barrier",
                    name = "Ice Barrier",
                    icon = "Interface\\Icons\\Spell_Ice_Lament",
                    school = "Frost",
                    prio = 5,
                    rankMax = 8,
                    reason = "Defensive frost shield absorbing heavy damage and preventing spell interruption.",
                },
                {
                    key = "arcane_missiles",
                    name = "Arcane Missiles",
                    icon = "Interface\\Icons\\Spell_Nature_StarFall",
                    school = "Arcane",
                    prio = 6,
                    rankMax = 8,
                    reason = "Channeled burst of missiles to quickly finish off immobilized targets.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Scales Blizzard tick damage and Cone of Cold burst output.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Dramatically expands Blizzard radius to cover entire screen lanes.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows constant Frost Nova and Cone of Cold cycling for permanent control.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Turns Blizzard into a catastrophic blizzard storm that vaporizes enemy waves.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+33% Haste", "+40% CDR" },
                    equip = "Increases casting speed and hastens cooldown recovery.",
                    why = "Accelerates Blizzard tick rate and missile channeling speed.",
                },
            },
            tactics = {
                "Wait until mobs bunch up around you, pop Frost Nova to freeze them, then unleash Cone of Cold.",
                "Keep Ice Barrier active at all times so rogue stragglers cannot break your shield.",
                "Position Blizzard slightly ahead of running enemy packs so they walk through its full duration.",
            },
        },
        {
            id = "mage_firestorm",
            title = "Firestorm Igniter",
            spec = "Fire",
            role = "Pyroblast & Flamestrike Burst Meta",
            summary = "High-risk, high-reward raw fire devastation. Rains Flamestrikes and hurls Pyroblasts to trigger massive rolling Ignite critical debuffs.",
            statPriority = "Fire Spell Damage > Spell Crit Chance > Cooldown Reduction > Area",
            stats = {
                { name = "Fire Spell Damage", note = "Increases all fire spell damage and Ignite burn ticks" },
                { name = "Spell Crit Chance", note = "Triggers the Ignite talent, adding 40% bonus damage as a DoT" },
                { name = "Cooldown Reduction", note = "Accelerates Pyroblast and Fire Blast availability" },
                { name = "Area Radius", note = "Widens Flamestrike and Blast Wave radius" },
            },
            spells = {
                {
                    key = "flamestrike",
                    name = "Flamestrike",
                    icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
                    school = "Fire",
                    prio = 1,
                    rankMax = 8,
                    reason = "Pillar of fire that deals massive initial burst and leaves burning ground.",
                },
                {
                    key = "pyroblast",
                    name = "Pyroblast",
                    icon = "Interface\\Icons\\Spell_Fire_Fireball02",
                    school = "Fire",
                    prio = 2,
                    rankMax = 8,
                    reason = "Giant fiery boulder dealing the highest single-target spell damage in the game.",
                },
                {
                    key = "fireball",
                    name = "Fireball",
                    icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
                    school = "Fire",
                    prio = 3,
                    rankMax = 8,
                    reason = "Core long-range fire projectile that applies a stacking burn debuff.",
                },
                {
                    key = "fire_blast",
                    name = "Fire Blast",
                    icon = "Interface\\Icons\\Spell_Fire_Fireball",
                    school = "Fire",
                    prio = 4,
                    rankMax = 8,
                    reason = "Instant-cast fire burst to execute low-health runners without cast time.",
                },
                {
                    key = "blast_wave",
                    name = "Blast Wave",
                    icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
                    school = "Fire",
                    prio = 5,
                    rankMax = 8,
                    reason = "Radial blast wave knocking back and dazing surrounding enemies in emergencies.",
                },
                {
                    key = "scorch",
                    name = "Scorch",
                    icon = "Interface\\Icons\\Spell_Fire_SoulBurn",
                    school = "Fire",
                    prio = 6,
                    rankMax = 8,
                    reason = "Fast cast fire spell applying the Fire Vulnerability debuff to bosses.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "The ultimate fire mage necklace, boosting all fire attacks significantly.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 3,
                    slot = "Finger",
                    benefit = "+21% Area of Effect",
                    stats = { "+85% Fire Dmg", "+30% Burn" },
                    equip = "Increases Fire damage and enhances fire damage-over-time burns.",
                    why = "Adds fire damage and crit chance to feed rolling Ignite ticks.",
                },
                                ring2 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Massive multiplier for Pyroblast and Flamestrike critical hits.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Powers up Flamestrike ground damage to incinerate elite waves.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+180% Dmg", "+35% Crit" },
                    equip = "Increases spell damage and spell critical strike chance.",
                    why = "Flat high spell damage bonus ensuring no spells resist.",
                },
            },
            tactics = {
                "Stack Flamestrikes on chokepoints and kite enemies through the burning ground.",
                "Target Pyroblast directly onto Guardians and Bosses to chunk their health.",
                "Use Blast Wave if enemies get too close to knock them back into your fire zones.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- WARLOCK
    -- ------------------------------------------------------------------------
    WARLOCK = {
        {
            id = "warlock_affliction_vampire",
            title = "Affliction Vampire",
            spec = "Affliction",
            role = "Immortal Drain Life & DoT Siphon Meta",
            summary = "The unkillable drain tank. Spreads Corruption, Curse of Agony, and Siphon Life, constantly funneling stolen health back into your life bar.",
            statPriority = "Shadow Spell Damage > Lifesteal > Cooldown Reduction > Duration",
            stats = {
                { name = "Shadow Spell Damage", note = "Increases damage of all shadow DoTs and Drain Life ticks" },
                { name = "Lifesteal / Healing", note = "Multiplies the health received from Drain Life and Siphon Life" },
                { name = "Cooldown Reduction", note = "Enables faster re-application of curses and Death Coil" },
                { name = "Max Health", note = "Provides a deep buffer to absorb incoming strikes safely" },
            },
            spells = {
                {
                    key = "drain_life",
                    name = "Drain Life",
                    icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
                    school = "Shadow",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core channeled siphon. Deals continuous shadow damage while refilling your HP bar.",
                },
                {
                    key = "corruption",
                    name = "Corruption",
                    icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
                    school = "Shadow",
                    prio = 2,
                    rankMax = 8,
                    reason = "Rapidly spreading shadow DoT ticking down all infected enemies simultaneously.",
                },
                {
                    key = "curse_of_agony",
                    name = "Curse of Agony",
                    icon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
                    school = "Shadow",
                    prio = 3,
                    rankMax = 8,
                    reason = "Accelerating curse whose damage ramps up over time, shredding high-HP foes.",
                },
                {
                    key = "siphon_life",
                    name = "Siphon Life",
                    icon = "Interface\\Icons\\Spell_Shadow_Requiem",
                    school = "Shadow",
                    prio = 4,
                    rankMax = 8,
                    reason = "Passive leech DoT. Transfers 100% of damage dealt directly to your health.",
                },
                {
                    key = "shadow_bolt",
                    name = "Shadow Bolt",
                    icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
                    school = "Shadow",
                    prio = 5,
                    rankMax = 8,
                    reason = "Heavy shadow nuke applying Shadow Vulnerability for increased DoT tick damage.",
                },
                {
                    key = "death_coil",
                    name = "Death Coil",
                    icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
                    school = "Shadow",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant panic button. Horrifies the target and restores an instant chunk of your health.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Boosts every single tick of Corruption, Agony, Siphon Life, and Drain Life.",
                },
                                ring1 = {
                    name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+12% Lifesteal",
                    stats = { "+12% Lifesteal" },
                    equip = "Heals you for 12% of all damage dealt to enemy units.",
                    why = "Stacks on top of Siphon Life for unmatched passive health regeneration.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Ensures rapid Death Coil availability and zero downtime on DoTs.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Increases all DoT tick rates and magnitudes to melt elites.",
                },
                                trinket2 = {
                    name = "Lifegiving Gem",
                    icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+60% HP & Heal",
                    stats = { "+60% HP & Heal" },
                    equip = "Increases maximum health and provides an emergency heal when low.",
                    why = "Massive health cushion ensuring you never get one-shot before your drains kick in.",
                },
            },
            tactics = {
                "Tag incoming enemies with Corruption and Siphon Life so they feed your health pool as they walk.",
                "Channel Drain Life on the highest HP enemy in range to stay permanently capped at 100% HP.",
                "Save Death Coil for emergency crowd control when an elite gets into melee range.",
            },
        },
        {
            id = "warlock_destruction_hellfire",
            title = "Destruction Hellfire",
            spec = "Destruction",
            role = "AoE Infernal Blast & Chaos Fire Meta",
            summary = "Raw explosive chaos. Unleashes Hellfire and Rain of Fire to incinerate everything on screen with devastating fire crits.",
            statPriority = "Fire / Shadow Spell Damage > Spell Crit > Area Radius > Max Health",
            stats = {
                { name = "Fire / Spell Damage", note = "Increases Hellfire, Rain of Fire, and Immolate scaling" },
                { name = "Spell Crit Chance", note = "Ruin talent boosts destruction spell crits to 200% bonus damage" },
                { name = "Area Radius", note = "Dramatically enlarges Hellfire and Rain of Fire coverage" },
                { name = "Max Health", note = "Provides the health pool required to channel self-damaging Hellfire safely" },
            },
            spells = {
                {
                    key = "hellfire",
                    name = "Hellfire",
                    icon = "Interface\\Icons\\Spell_Fire_Incinerate",
                    school = "Fire",
                    prio = 1,
                    rankMax = 8,
                    reason = "High-frequency radial inferno vaporizing all enemies in close quarters around you.",
                },
                {
                    key = "rain_of_fire",
                    name = "Rain of Fire",
                    icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
                    school = "Fire",
                    prio = 2,
                    rankMax = 8,
                    reason = "Rains burning meteors across a wide targeted area, staggering swarming mobs.",
                },
                {
                    key = "immolate",
                    name = "Immolate",
                    icon = "Interface\\Icons\\Spell_Fire_Immolation",
                    school = "Fire",
                    prio = 3,
                    rankMax = 8,
                    reason = "Direct fire impact followed by heavy burning ticks.",
                },
                {
                    key = "shadow_bolt",
                    name = "Shadow Bolt",
                    icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
                    school = "Shadow",
                    prio = 4,
                    rankMax = 8,
                    reason = "Ruin-empowered shadow nuke with double critical strike damage.",
                },
                {
                    key = "searing_pain",
                    name = "Searing Pain",
                    icon = "Interface\\Icons\\Spell_Fire_SoulBurn",
                    school = "Fire",
                    prio = 5,
                    rankMax = 8,
                    reason = "High-crit chance instant fire burst for fast mobile targeting.",
                },
                {
                    key = "soul_fire",
                    name = "Soulfire",
                    icon = "Interface\\Icons\\Spell_Fire_Fireball02",
                    school = "Fire",
                    prio = 6,
                    rankMax = 8,
                    reason = "Ultimate destructive fire explosion that obliterates priority targets.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Directly boosts the fire scaling of Hellfire and Rain of Fire.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Expands the radius of Hellfire and Rain of Fire to hit wider swarms.",
                },
                                ring2 = {
                    name = "Heavy Dark Iron Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_14",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+40% HP",
                    stats = { "+40% HP" },
                    equip = "Increases your maximum health pool and damage resistance.",
                    why = "Gives the substantial health buffer needed to safely channel Hellfire.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Doubles the tick damage of Hellfire during intense mob swarms.",
                },
                                trinket2 = {
                    name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+236% Crit Dmg",
                    stats = { "+236% Crit Dmg" },
                    equip = "Increases the critical damage multiplier of all attacks and spells.",
                    why = "Combines with Ruin talent for 200% critical damage destruction strikes.",
                },
            },
            tactics = {
                "Only channel Hellfire when your HP is healthy or when surrounded by dense packs.",
                "Pre-cast Rain of Fire on approaching waves before they enter your melee radius.",
                "Use Soulfire on Bosses to knock off major percentages of their health bar.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- ROGUE
    -- ------------------------------------------------------------------------
    ROGUE = {
        {
            id = "rogue_blade_flurry",
            title = "Blade Flurry Poisoner",
            spec = "Combat",
            role = "Dual-Wield Swarm Blender Meta",
            summary = "Hyper-speed melee slicer. Blade Flurry and Slice and Dice turn you into a whirlwind of strikes that shreds packs of monsters in melee.",
            statPriority = "Attack Speed > Attack Power > Cooldown Reduction > Critical Strike",
            stats = {
                { name = "Attack Speed", note = "Increases weapon swing frequency and poison application rates" },
                { name = "Attack Power", note = "Scales Sinister Strike and Eviscerate weapon formulas" },
                { name = "Cooldown Reduction", note = "Reduces Blade Flurry and Adrenaline Rush cooldowns" },
                { name = "Critical Strike", note = "Builds rapid combo points and triggers critical weapon strikes" },
            },
            spells = {
                {
                    key = "blade_flurry",
                    name = "Blade Flurry",
                    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core cleave ability. Causes all your melee attacks to strike adjacent enemies while boosting attack speed.",
                },
                {
                    key = "sinister_strike",
                    name = "Sinister Strike",
                    icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Spam combo builder delivering heavy physical hits to build finisher points.",
                },
                {
                    key = "eviscerate",
                    name = "Eviscerate",
                    icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Massive finishing burst that expends combo points to deal devastating damage.",
                },
                {
                    key = "slice_and_dice",
                    name = "Slice and Dice",
                    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Steroid buff boosting your attack speed by +30% for high-frequency hits.",
                },
                {
                    key = "adrenaline_rush",
                    name = "Adrenaline Rush",
                    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Doubles energy regeneration rate, allowing non-stop Sinister Strike spam.",
                },
                {
                    key = "gouge",
                    name = "Gouge",
                    icon = "Interface\\Icons\\Ability_Gouge",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Incapacitates frontal threats, allowing you to reposition safely.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "The premier melee necklace for physical rogues.",
                },
                                ring1 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Drastically lowers Blade Flurry and Adrenaline Rush cooldowns.",
                },
                                ring2 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+65% Dmg",
                    stats = { "+65% Dmg" },
                    equip = "Increases all damage dealt by your spells and physical attacks.",
                    why = "Ensures no off-hand misses and multiplies total physical output.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Insane synergy with high attack speed; procs extra swings continuously.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+210% Dmg",
                    stats = { "+210% Dmg" },
                    equip = "Increases physical and weapon attack power by a massive percentage.",
                    why = "Huge flat attack power steroid that aligns with Adrenaline Rush phases.",
                },
            },
            tactics = {
                "Keep Slice and Dice running at all times before spending combo points on Eviscerate.",
                "Activate Blade Flurry whenever swarms arrive to double your total damage output.",
                "Pop Adrenaline Rush during boss battles to unleash an unending barrage of Sinister Strikes.",
            },
        },
        {
            id = "rogue_shadow_assassin",
            title = "Shadow Assassin",
            spec = "Subtlety",
            role = "Ambush & Bleed Boss Killer Meta",
            summary = "Deadly burst assassin. Uses Ambush and Backstab with Hemorrhage debuffs and Rupture bleeds to execute priority targets in seconds.",
            statPriority = "Critical Strike > Armor Penetration > Attack Power > Movement Speed",
            stats = {
                { name = "Critical Strike", note = "Backstab and Ambush gain massive critical damage multipliers" },
                { name = "Armor Penetration", note = "Pierces boss armor for maximum physical puncture" },
                { name = "Attack Power", note = "Increases all weapon and bleed damage formulas" },
                { name = "Movement Speed", note = "Allows swift repositioning behind target flanks" },
            },
            spells = {
                {
                    key = "backstab",
                    name = "Backstab",
                    icon = "Interface\\Icons\\Ability_BackStab",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Primary physical attack dealing extreme critical damage when striking from behind.",
                },
                {
                    key = "ambush",
                    name = "Ambush",
                    icon = "Interface\\Icons\\Ability_Rogue_Ambush",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Lethal high-potency opener capable of one-shotting elite targets.",
                },
                {
                    key = "hemorrhage",
                    name = "Hemorrhage",
                    icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Applies a debuff increasing physical damage taken from all subsequent attacks.",
                },
                {
                    key = "rupture",
                    name = "Rupture",
                    icon = "Interface\\Icons\\Ability_Rogue_Rupture",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Armor-ignoring physical bleed that steadily drains boss health bars.",
                },
                {
                    key = "ghostly_strike",
                    name = "Ghostly Strike",
                    icon = "Interface\\Icons\\Spell_Shadow_Curse",
                    school = "Physical",
                    prio = 5,
                    rankMax = 8,
                    reason = "Heavy strike that also grants +15% Dodge chance for 7 seconds.",
                },
                {
                    key = "eviscerate",
                    name = "Eviscerate",
                    icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Direct damage finisher to burst down low-health enemies.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Maximizes Backstab and Ambush critical strike likelihood.",
                },
                                ring1 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Turns every Backstab into a monstrous critical hit.",
                },
                                ring2 = {
                    name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+12% Lifesteal",
                    stats = { "+12% Lifesteal" },
                    equip = "Heals you for 12% of all damage dealt to enemy units.",
                    why = "Provides vital sustain when fighting in close proximity to guardians.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Triggers additional attacks that can land as extra critical Backstabs.",
                },
                                trinket2 = {
                    name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+236% Crit Dmg",
                    stats = { "+236% Crit Dmg" },
                    equip = "Increases the critical damage multiplier of all attacks and spells.",
                    why = "Consistent crit bonus required to reach soft crit caps.",
                },
            },
            tactics = {
                "Keep Hemorrhage debuff active on bosses before casting Backstab.",
                "Use Ghostly Strike on cooldown to keep your Dodge defense high in combat.",
                "Maintain a 5-point Rupture on bosses so damage ticks continuously while maneuvering.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- SHAMAN
    -- ------------------------------------------------------------------------
    SHAMAN = {
        {
            id = "shaman_chain_lightning",
            title = "Chain Lightning Storm",
            spec = "Elemental",
            role = "Arc Lightning & Overload Waveclear Meta",
            summary = "Master of elemental storms. Hurls bouncing Chain Lightning and detonates Fire Nova totems to vaporize entire screens of monsters.",
            statPriority = "Nature / Fire Spell Damage > Cooldown Reduction > Spell Crit > Radius",
            stats = {
                { name = "Nature / Fire Spell Damage", note = "Increases Chain Lightning, Lightning Bolt, and Fire Nova" },
                { name = "Cooldown Reduction", note = "Reduces the Chain Lightning and Shock cooldown cycles" },
                { name = "Spell Crit Chance", note = "Elemental Fury talent gives 100% bonus critical damage" },
                { name = "Area Radius", note = "Expands Fire Nova and Magma Totem blast coverage" },
            },
            spells = {
                {
                    key = "chain_lightning",
                    name = "Chain Lightning",
                    icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
                    school = "Nature",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core bouncing lightning strike. Arcs across multiple enemies with high burst damage.",
                },
                {
                    key = "fire_nova",
                    name = "Fire Nova",
                    icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
                    school = "Fire",
                    prio = 2,
                    rankMax = 8,
                    reason = "Radial explosion detonating around your position, shredding surrounding hordes.",
                },
                {
                    key = "lightning_bolt",
                    name = "Lightning Bolt",
                    icon = "Interface\\Icons\\Spell_Nature_Lightning",
                    school = "Nature",
                    prio = 3,
                    rankMax = 8,
                    reason = "Heavy single-target nature projectile with high spell damage coefficients.",
                },
                {
                    key = "earth_shock",
                    name = "Earth Shock",
                    icon = "Interface\\Icons\\Spell_Nature_EarthShock",
                    school = "Nature",
                    prio = 4,
                    rankMax = 8,
                    reason = "Instant-cast nature shock dealing high burst and interrupting enemy spells.",
                },
                {
                    key = "magma_totem",
                    name = "Magma Totem",
                    icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
                    school = "Fire",
                    prio = 5,
                    rankMax = 8,
                    reason = "Pulsing fire totem continuously damaging all enemies walking in its vicinity.",
                },
                {
                    key = "flame_shock",
                    name = "Flame Shock",
                    icon = "Interface\\Icons\\Spell_Fire_FlameShock",
                    school = "Fire",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant fire strike applying a persistent burning DoT on high-HP targets.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Increases both Nature and Fire spell power across all your shocks and totems.",
                },
                                ring1 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows rapid Chain Lightning and Earth Shock firing.",
                },
                                ring2 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Dramatically expands Fire Nova and Magma Totem explosion radii.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Powers up Chain Lightning into an apocalyptic screen-clearing lightning storm.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+33% Haste", "+40% CDR" },
                    equip = "Increases casting speed and hastens cooldown recovery.",
                    why = "Increases casting rate so you cycle through spells with zero latency.",
                },
            },
            tactics = {
                "Line up Chain Lightning so it bounces through whole clusters of incoming mobs.",
                "Drop Fire Nova when surrounded to instantly vaporize nearby swarms.",
                "Rotate Earth Shock on bosses for instant burst without cast delays.",
            },
        },
        {
            id = "shaman_windfury_brawler",
            title = "Windfury Brawler",
            spec = "Enhancement",
            role = "Windfury Multi-Hit Melee Brawler Meta",
            summary = "Unleashes the legendary Windfury weapon imbue. Hits trigger chain reactions of bonus attacks that turn bosses into mulch.",
            statPriority = "Attack Power > Critical Strike > Attack Speed > Lifesteal",
            stats = {
                { name = "Attack Power", note = "Multiplied by Windfury extra attack procs for massive burst" },
                { name = "Critical Strike", note = "Triggers Flurry attack speed boosts and heavy physical hits" },
                { name = "Attack Speed", note = "More weapon swings per second equal more Windfury chances" },
                { name = "Lifesteal", note = "Recovers large health chunks on every Windfury multi-hit" },
            },
            spells = {
                {
                    key = "stormstrike",
                    name = "Stormstrike",
                    icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Double weapon strike that grants a +20% nature damage debuff on the target.",
                },
                {
                    key = "windfury",
                    name = "Windfury",
                    icon = "Interface\\Icons\\Spell_Nature_Cyclone",
                    school = "Nature",
                    prio = 2,
                    rankMax = 8,
                    reason = "Chance on hit to grant 2 extra instant attacks with bonus attack power.",
                },
                {
                    key = "earth_shock",
                    name = "Earth Shock",
                    icon = "Interface\\Icons\\Spell_Nature_EarthShock",
                    school = "Nature",
                    prio = 3,
                    rankMax = 8,
                    reason = "Empowered by Stormstrike's nature debuff for double-damage shock bursts.",
                },
                {
                    key = "frost_shock",
                    name = "Frost Shock",
                    icon = "Interface\\Icons\\Spell_Frost_FrostShock",
                    school = "Frost",
                    prio = 4,
                    rankMax = 8,
                    reason = "Instant chilling shock that prevents fast melee mobs from flanking you.",
                },
                {
                    key = "healing_wave",
                    name = "Healing Wave",
                    icon = "Interface\\Icons\\Spell_Nature_MagicImmunity",
                    school = "Nature",
                    prio = 5,
                    rankMax = 8,
                    reason = "High-potency nature heal to recover your health bar between brawls.",
                },
                {
                    key = "searing_totem",
                    name = "Searing Totem",
                    icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
                    school = "Fire",
                    prio = 6,
                    rankMax = 8,
                    reason = "Automated fire turret providing consistent background DPS.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Top neck for maximizing physical attack power and Windfury procs.",
                },
                                ring1 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Multiplies critical strike damage on every Windfury hit.",
                },
                                ring2 = {
                    name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+12% Lifesteal",
                    stats = { "+12% Lifesteal" },
                    equip = "Heals you for 12% of all damage dealt to enemy units.",
                    why = "Heals you for huge numbers whenever a multi-attack Windfury procs.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "The holy grail synergy: Hand of Justice can proc Windfury, which can proc Hand of Justice!",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+210% Dmg",
                    stats = { "+210% Dmg" },
                    equip = "Increases physical and weapon attack power by a massive percentage.",
                    why = "Colossal AP burst that turns your Windfury swings into boss erasers.",
                },
            },
            tactics = {
                "Hit Stormstrike first to apply the Nature debuff, then follow up with Earth Shock.",
                "With Hand of Justice equipped, stay in melee range and let extra attack chains melt elites.",
                "Use Healing Wave whenever your health drops below 50% to maintain high uptime.",
            },
        },
        {
            id = "shaman_totem_overlord",
            title = "Totem Overlord",
            spec = "Totemic Elemental",
            role = "Automated Fire Turrets & Radial Zone Meta",
            summary = "Transforms you into an automated fiery fortress. Deploys Searing and Magma Totems amplified by Call of Flame and Fire Nova, while Lightning Shield electrocutes anything daring to approach.",
            statPriority = "Fire Spell Damage > Cooldown Reduction > Area / Radius > Attack Speed",
            stats = {
                { name = "Fire Spell Damage", note = "Directly scales Magma Totem, Searing Totem, and Fire Nova" },
                { name = "Cooldown Reduction", note = "Allows rapid deployment of fresh totems and constant Fire Nova detonations" },
                { name = "Area / Radius", note = "Expands Magma Totem pulsing radius and Fire Nova to blanket whole screens" },
                { name = "Attack Speed / Haste", note = "Increases Searing Totem projectile spitfire rate" },
            },
            spells = {
                {
                    key = "magma_totem",
                    name = "Magma Totem",
                    icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
                    school = "Fire",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core pulsating fire AoE totem. Emits devastating radial fire pulses that incinerate waves of monsters clustered around your position.",
                },
                {
                    key = "searing_totem",
                    name = "Searing Totem",
                    icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
                    school = "Fire",
                    prio = 2,
                    rankMax = 8,
                    reason = "Automated rapid-fire turret. Continuously fires bolts of fire at nearby targets and bosses while you focus on movement.",
                },
                {
                    key = "fire_nova",
                    name = "Fire Nova",
                    icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
                    school = "Fire",
                    prio = 3,
                    rankMax = 8,
                    reason = "Detonates a massive radial blast wave of flame centered around your fire totems, obliterating nearby hordes.",
                },
                {
                    key = "call_of_flame",
                    name = "Call of Flame",
                    icon = "Interface\\Icons\\Spell_Fire_Immolation",
                    school = "Fire",
                    prio = 4,
                    rankMax = 8,
                    reason = "Massively amplifies the damage and burning output of all your fire totems, turning them into lethal infernos.",
                },
                {
                    key = "lightning_shield",
                    name = "Lightning Shield",
                    icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                    school = "Nature",
                    prio = 5,
                    rankMax = 8,
                    reason = "Defensive perimeter barrier. Automatically retaliates with heavy lightning damage whenever a monster strikes you.",
                },
                {
                    key = "flame_shock",
                    name = "Flame Shock",
                    icon = "Interface\\Icons\\Spell_Fire_FlameShock",
                    school = "Fire",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant fire nuke leaving a lingering burning DoT to melt elite guardians and stage bosses.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Directly multiplies every single tick of Magma Totem, Searing Totem, and Fire Nova.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Widens the radius of Magma Totem and Fire Nova so they cover the entire battlefield.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Lowers cooldowns to ensure fresh totems are always active on the ground.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Empowers Magma Totem into an unstoppable wave-shredding inferno during high-density swarms.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+33% Haste", "+40% CDR" },
                    equip = "Increases casting speed and hastens cooldown recovery.",
                    why = "Accelerates Searing Totem projectile firing frequency for rapid boss melting.",
                },
            },
            tactics = {
                "Rush Magma Totem and Call of Flame early to establish your automated fire perimeter.",
                "With Ring of Spell Power equipped, Magma Totem covers nearly the entire screen in pulsing fire.",
                "Circle tightly around your totems during boss fights so Searing Totem and Lightning Shield melt them effortlessly.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- PRIEST
    -- ------------------------------------------------------------------------
    PRIEST = {
        {
            id = "priest_shadow_melter",
            title = "Shadow Melter",
            spec = "Shadow",
            role = "Shadow Word & Mind Flay Melting Meta",
            summary = "Shadowform terror. Melts enemies with Shadow Word: Pain and Mind Flay while Devouring Plague and Power Word: Shield keep you entirely unharmed.",
            statPriority = "Shadow Spell Damage > Cooldown Reduction > Spell Crit > Max Health",
            stats = {
                { name = "Shadow Spell Damage", note = "Directly increases SW:Pain, Mind Flay, and Devouring Plague" },
                { name = "Cooldown Reduction", note = "Allows frequent Mind Blast bursts and Psychic Scream fears" },
                { name = "Spell Crit Chance", note = "Increases Mind Blast critical strike chance" },
                { name = "Max Health", note = "Ensures Power Word: Shield buffer stays strong against hits" },
            },
            spells = {
                {
                    key = "sw_pain",
                    name = "Shadow Word: Pain",
                    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
                    school = "Shadow",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core shadow DoT. Spreads across all approaching enemies, ticking down their life.",
                },
                {
                    key = "mind_flay",
                    name = "Mind Flay",
                    icon = "Interface\\Icons\\Spell_Shadow_SiphonMana",
                    school = "Shadow",
                    prio = 2,
                    rankMax = 8,
                    reason = "Channeled shadow beam that deals rapid damage and slows target movement by 50%.",
                },
                {
                    key = "mind_blast",
                    name = "Mind Blast",
                    icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
                    school = "Shadow",
                    prio = 3,
                    rankMax = 8,
                    reason = "High-impact single-target shadow nuke with rapid cycling.",
                },
                {
                    key = "devouring_plague",
                    name = "Devouring Plague",
                    icon = "Interface\\Icons\\Spell_Shadow_BlackPlague",
                    school = "Shadow",
                    prio = 4,
                    rankMax = 8,
                    reason = "Devastating shadow disease dealing heavy periodic damage while healing the priest.",
                },
                {
                    key = "pw_shield",
                    name = "Power Word: Shield",
                    icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
                    school = "Holy",
                    prio = 5,
                    rankMax = 8,
                    reason = "Absorbs incoming physical and magical blows, preventing spell interruptions.",
                },
                {
                    key = "psychic_scream",
                    name = "Psychic Scream",
                    icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
                    school = "Shadow",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant radial fear causing up to 5 nearby enemies to flee in terror.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Scales all periodic shadow ticks and Mind Blast damage.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Boosts spell power and widens Psychic Scream range.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Enables faster Mind Blast cycling and frequent Shield refreshes.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Multiplies Shadow Word: Pain and Devouring Plague tick values.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+180% Dmg", "+35% Crit" },
                    equip = "Increases spell damage and spell critical strike chance.",
                    why = "Provides high flat spell power to ensure shadow spells never miss.",
                },
            },
            tactics = {
                "Keep Power Word: Shield active so you can channel Mind Flay without knockback.",
                "Apply Devouring Plague to priority champions to gain constant healing.",
                "Use Psychic Scream when mobs close in to send them scattering into your DoT fields.",
            },
        },
        {
            id = "priest_holy_smiter",
            title = "Holy Smiter",
            spec = "Holy / Discipline",
            role = "Holy Nova & Radiant Burst Meta",
            summary = "Radiant holy avenger. Spams Holy Nova to deal 360-degree holy damage while healing yourself and allies, backed by Smite and Holy Fire nukes.",
            statPriority = "Holy Spell Damage > Cooldown Reduction > Healing Power > Area Radius",
            stats = {
                { name = "Holy Spell Damage", note = "Increases Holy Nova, Smite, and Holy Fire damage" },
                { name = "Cooldown Reduction", note = "Enables non-stop Holy Nova casting" },
                { name = "Healing Power", note = "Amplifies Holy Nova and Renew self-healing" },
                { name = "Area Radius", note = "Expands Holy Nova blast circle to hit wider mob packs" },
            },
            spells = {
                {
                    key = "holy_nova",
                    name = "Holy Nova",
                    icon = "Interface\\Icons\\Spell_Holy_HolyNova",
                    school = "Holy",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core radial burst dealing holy damage to all enemies and healing you simultaneously.",
                },
                {
                    key = "smite",
                    name = "Smite",
                    icon = "Interface\\Icons\\Spell_Holy_HolySmite",
                    school = "Holy",
                    prio = 2,
                    rankMax = 8,
                    reason = "Primary single-target holy nuke with high holy spell damage scaling.",
                },
                {
                    key = "holy_fire",
                    name = "Holy Fire",
                    icon = "Interface\\Icons\\Spell_Holy_SearingLight",
                    school = "Holy",
                    prio = 3,
                    rankMax = 8,
                    reason = "Heavy direct holy blast leaving a high-damage holy burning DoT.",
                },
                {
                    key = "pw_shield",
                    name = "Power Word: Shield",
                    icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
                    school = "Holy",
                    prio = 4,
                    rankMax = 8,
                    reason = "Absorb shield ensuring zero interruption to your holy cast rotation.",
                },
                {
                    key = "renew",
                    name = "Renew",
                    icon = "Interface\\Icons\\Spell_Holy_Renew",
                    school = "Holy",
                    prio = 5,
                    rankMax = 8,
                    reason = "Persistent heal-over-time keeping your health pool topped off automatically.",
                },
                {
                    key = "holy_shock",
                    name = "Holy Shock",
                    icon = "Interface\\Icons\\Spell_Holy_SearingLight",
                    school = "Holy",
                    prio = 6,
                    rankMax = 8,
                    reason = "Instant-cast holy spell for burst damage or emergency triage heal.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Scales Holy Nova damage and Smite burst potency.",
                },
                                ring1 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows high-frequency Holy Nova spams.",
                },
                                ring2 = {
                    name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+65% Dmg",
                    stats = { "+65% Dmg" },
                    equip = "Increases all damage dealt by your spells and physical attacks.",
                    why = "Multiplies all holy spell damage output.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Turns Holy Nova into a screen-shredding explosion of light.",
                },
                                trinket2 = {
                    name = "Lifegiving Gem",
                    icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+60% HP & Heal",
                    stats = { "+60% HP & Heal" },
                    equip = "Increases maximum health and provides an emergency heal when low.",
                    why = "Deepens your survival cushion against high-damage guardian slams.",
                },
            },
            tactics = {
                "Run through monster packs while casting Holy Nova on cooldown for both damage and healing.",
                "Keep Renew ticking on yourself to smooth out incoming damage spikes.",
                "Use Holy Fire and Smite on approaching champions before they reach melee range.",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- DRUID
    -- ------------------------------------------------------------------------
    DRUID = {
        {
            id = "druid_balance_hurricane",
            title = "Moonkin Starfall & Hurricane",
            spec = "Balance",
            role = "Hurricane Storm & Starfire Nuke Meta",
            summary = "Avatar of nature and stars. Summons massive Hurricane tempests to slow and shred waves, followed by devastating Starfire nukes on bosses.",
            statPriority = "Nature / Arcane Spell Damage > Area Radius > Cooldown Reduction > Spell Crit",
            stats = {
                { name = "Nature / Arcane Spell Damage", note = "Scales Hurricane, Moonfire, and Starfire formulas" },
                { name = "Area Radius", note = "Expands Hurricane storm coverage across multiple screen zones" },
                { name = "Cooldown Reduction", note = "Enables faster Starfire and Barkskin availability" },
                { name = "Spell Crit Chance", note = "Triggers high-multiplier Starfire astral crits" },
            },
            spells = {
                {
                    key = "hurricane",
                    name = "Hurricane",
                    icon = "Interface\\Icons\\Spell_Nature_Cyclone",
                    school = "Nature",
                    prio = 1,
                    rankMax = 8,
                    reason = "Screen-wide swirling tempest slowing enemy move speed and dealing rapid nature damage.",
                },
                {
                    key = "moonfire",
                    name = "Moonfire",
                    icon = "Interface\\Icons\\Spell_Nature_StarFall",
                    school = "Arcane",
                    prio = 2,
                    rankMax = 8,
                    reason = "Instant lunar strike applying a continuous arcane burn debuff.",
                },
                {
                    key = "starfire",
                    name = "Starfire",
                    icon = "Interface\\Icons\\Spell_Arcane_StarFire",
                    school = "Arcane",
                    prio = 3,
                    rankMax = 8,
                    reason = "Devastating astral blast dealing the highest single-hit magic damage for druids.",
                },
                {
                    key = "wrath",
                    name = "Wrath",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishPoison",
                    school = "Nature",
                    prio = 4,
                    rankMax = 8,
                    reason = "Fast-cast nature projectile filler between cooldowns.",
                },
                {
                    key = "entangling_roots",
                    name = "Entangling Roots",
                    icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
                    school = "Nature",
                    prio = 5,
                    rankMax = 8,
                    reason = "Roots dangerous enemies in place, holding them inside your Hurricane storm.",
                },
                {
                    key = "barkskin",
                    name = "Barkskin",
                    icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem",
                    school = "Nature",
                    prio = 6,
                    rankMax = 8,
                    reason = "Defensive ironbark buff granting 20% flat damage reduction.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+138% Dur, +69% Dmg",
                    stats = { "+138% Dur, +69% Dmg, +1% HP" },
                    equip = "Increases spell damage, health, and extends the duration of all elemental effects.",
                    why = "Increases Nature and Arcane damage across all balance spells.",
                },
                                ring1 = {
                    name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+45% Area, +50% Dmg",
                    stats = { "+45% Area", "+50% Dmg" },
                    equip = "Increases the area and explosion radius of all area-of-effect spells.",
                    why = "Essential for maximizing Hurricane storm diameter.",
                },
                                ring2 = {
                    name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07",
                    quality = 4,
                    slot = "Finger",
                    benefit = "93% CDR",
                    stats = { "93% CDR" },
                    equip = "Reduces the cooldown of all abilities and spells.",
                    why = "Allows high-frequency Hurricane storms with minimal downtime.",
                },
                                trinket1 = {
                    name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+246% Dmg",
                    stats = { "+246% Dmg" },
                    equip = "Increases spell damage and periodic effect strength.",
                    why = "Powers up Hurricane into a lethal vortex that shreds monster waves.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+20% Damage",
                    stats = { "+33% Haste", "+40% CDR" },
                    equip = "Increases casting speed and hastens cooldown recovery.",
                    why = "Speeds up Starfire casting time and Hurricane tick frequency.",
                },
            },
            tactics = {
                "Channel Hurricane on chokepoints and watch whole waves dissolve inside the storm.",
                "Use Entangling Roots on fast charging champions to trap them inside your storm.",
                "Pop Barkskin when boss mechanics hit to shrug off incoming damage.",
            },
        },
        {
            id = "druid_feral_shredder",
            title = "Feral Bleed Shredder",
            spec = "Feral Combat",
            role = "Cat & Bear Bleed Shredding Meta",
            summary = "Primal beast fury. Strips target armor with Faerie Fire, then shreds enemies with Rake, Rip, and Swipe into a flurry of bleed ticks.",
            statPriority = "Attack Power > Critical Strike > Attack Speed > Lifesteal",
            stats = {
                { name = "Attack Power", note = "Directly scales Shred, Swipe, and Rip bleed damage" },
                { name = "Critical Strike", note = "Triggers double combo points and bonus physical bursts" },
                { name = "Attack Speed", note = "More claw strikes per second to refresh bleeds" },
                { name = "Lifesteal", note = "Provides steady sustain during prolonged melee combat" },
            },
            spells = {
                {
                    key = "shred",
                    name = "Shred",
                    icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",
                    school = "Physical",
                    prio = 1,
                    rankMax = 8,
                    reason = "Core physical claw strike dealing extreme damage when positioned behind targets.",
                },
                {
                    key = "rip",
                    name = "Rip",
                    icon = "Interface\\Icons\\Ability_GhoulFrenzy",
                    school = "Physical",
                    prio = 2,
                    rankMax = 8,
                    reason = "Devastating finishing bleed that tears through enemy health pools.",
                },
                {
                    key = "rake",
                    name = "Rake",
                    icon = "Interface\\Icons\\Ability_Druid_Disembowel",
                    school = "Physical",
                    prio = 3,
                    rankMax = 8,
                    reason = "Slashing opener applying initial physical damage and a stacking bleed.",
                },
                {
                    key = "swipe",
                    name = "Swipe",
                    icon = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
                    school = "Physical",
                    prio = 4,
                    rankMax = 8,
                    reason = "Frontal melee swipe cleaving through up to 3 surrounding enemies.",
                },
                {
                    key = "faerie_fire",
                    name = "Faerie Fire",
                    icon = "Interface\\Icons\\Spell_Nature_FaerieFire",
                    school = "Nature",
                    prio = 5,
                    rankMax = 8,
                    reason = "Strips target armor by 500+, massively increasing all physical strike and bleed damage.",
                },
                {
                    key = "ferocious_bite",
                    name = "Ferocious Bite",
                    icon = "Interface\\Icons\\Ability_Druid_FerociousBite",
                    school = "Physical",
                    prio = 6,
                    rankMax = 8,
                    reason = "Heavy finisher converting surplus energy into direct burst damage.",
                },
            },
            jewelry = {
                                neck = {
                    name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09",
                    quality = 4,
                    slot = "Necklace",
                    benefit = "+44% Crit, +120% AP",
                    stats = { "+44% Crit", "+120% AP" },
                    equip = "Increases attack power and critical strike chance with physical attacks.",
                    why = "Top physical neck for feral druids.",
                },
                                ring1 = {
                    name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+44% Crit",
                    stats = { "+44% Crit" },
                    equip = "Increases the chance of all spells and attacks to strike critically.",
                    why = "Massive critical strike damage multiplier on Shred and Ferocious Bite.",
                },
                                ring2 = {
                    name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49",
                    quality = 4,
                    slot = "Finger",
                    benefit = "+12% Lifesteal",
                    stats = { "+12% Lifesteal" },
                    equip = "Heals you for 12% of all damage dealt to enemy units.",
                    why = "Provides the vital sustain needed when fighting toe-to-toe with monsters.",
                },
                                trinket1 = {
                    name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01",
                    quality = 3,
                    slot = "Trinket",
                    benefit = "+35% Echo",
                    stats = { "+35% Echo" },
                    equip = "Grants a 35% chance for any spell or attack to immediately strike twice.",
                    why = "Procs additional claw swipes to rapidly generate combo points.",
                },
                                trinket2 = {
                    name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                    quality = 4,
                    slot = "Trinket",
                    benefit = "+210% Dmg",
                    stats = { "+210% Dmg" },
                    equip = "Increases physical and weapon attack power by a massive percentage.",
                    why = "Colossal attack power boost that turns Rip bleeds into lethal damage over time.",
                },
            },
            tactics = {
                "Apply Faerie Fire to tough targets immediately to strip their armor.",
                "Build combo points with Rake and Shred, then apply a 5-point Rip bleed.",
                "Use Swipe continuously when fighting groups of 3 or more monsters.",
            },
        },
    },
};

-- ----------------------------------------------------------------------------
-- Helper Functions & Lookups
-- ----------------------------------------------------------------------------

local function NormalizeText(str)
    if not str then return ""; end
    local s = string.lower(str);
    s = string.gsub(s, "[%s%p_]", "");
    return s;
end

-- Fast spell lookup across all builds: normalized name/key -> table of matching build spells
local spellLookup = {};
for classKey, buildList in pairs(BordoUI_BuildData.Builds) do
    for bIdx = 1, table.getn(buildList) do
        local build = buildList[bIdx];
        for sIdx = 1, table.getn(build.spells) do
            local sp = build.spells[sIdx];
            local normKey = NormalizeText(sp.key);
            local normName = NormalizeText(sp.name);
            spellLookup[normKey] = spellLookup[normKey] or {};
            table.insert(spellLookup[normKey], { classKey = classKey, buildIdx = bIdx, spell = sp });
            if normName ~= normKey then
                spellLookup[normName] = spellLookup[normName] or {};
                table.insert(spellLookup[normName], { classKey = classKey, buildIdx = bIdx, spell = sp });
            end
        end
    end
end
BordoUI_BuildData.SpellLookup = spellLookup;

function BordoUI_GetClassBuilds(classKey)
    if not classKey then return nil; end
    local upper = string.upper(classKey);
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.customBuilds = BordoUIDB.customBuilds or {};
    if not BordoUIDB.customBuilds[upper] then
        BordoUIDB.customBuilds[upper] = {};
    end

    -- Backwards compatibility: If old customBuilds[class] was a single build table, migrate it to Slot 1
    if BordoUIDB.customBuilds[upper].spells or BordoUIDB.customBuilds[upper].title then
        local old = BordoUIDB.customBuilds[upper];
        BordoUIDB.customBuilds[upper] = { [1] = old };
    end

    local cInfo = BordoUI_BuildData and BordoUI_BuildData.Classes and BordoUI_BuildData.Classes[upper];
    local cName = (cInfo and cInfo.name) or upper;
    local defTalents = (BordoUI_BuildData and BordoUI_BuildData.Builds and BordoUI_BuildData.Builds[upper] and BordoUI_BuildData.Builds[upper][1] and BordoUI_BuildData.Builds[upper][1].talents);

    local list = {};
    for idx = 1, 3 do
        if not BordoUIDB.customBuilds[upper][idx] then
            BordoUIDB.customBuilds[upper][idx] = {
                id = "custom_" .. string.lower(upper) .. "_" .. idx,
                name = cName .. " Build " .. idx,
                title = "Build " .. idx,
                tag = "[Custom Build " .. idx .. "]",
                desc = "Your custom crafted " .. cName .. " build #" .. idx .. ". Click spells or jewelry slots to configure pick priorities.",
                statPriority = "Custom Stat Priority",
                isCustom = true,
                spells = {},
                jewelry = {},
                talents = defTalents,
            };
        end
                local b = BordoUIDB.customBuilds[upper][idx];
        if b and b.spells then
            for sIdx = 1, 6 do
                local sp = b.spells[sIdx];
                if sp and (not sp.rankMax or sp.rankMax <= 5) then
                    sp.rankMax = 8;
                end
            end
        end
        if b and b.jewelry then
            for jKey, jItem in pairs(b.jewelry) do
                if jItem then
                    if jKey == "neck" then
                        jItem.slotType = "NECK";
                        if (not jItem.spell or jItem.spell == "") and jItem.name and string.find(jItem.name, ":") then
                            local _, _, sp = string.find(jItem.name, ":%s*([^:]+)");
                            if sp then
                                jItem.spell = string.gsub(sp, "%s+[IVXLCDMivxlcdm%d]+$", "");
                            end
                        end
                        local nName = jItem.name or "";
                        local nSpell = jItem.spell or "";
                        if nName == "Amulet of the Inferno: Exorcism" or nSpell == "Exorcism" or string.find(nName, "Exorcism") then
                            jItem.name = "Eye of the Splitting Sky: Exorcism";
                            jItem.icon = "Interface\\Icons\\INV_Jewelry_Necklace_16";
                            jItem.benefit = "+1 Tgt, +24% Dmg, Leap";
                            jItem.desc = "Legendary amulet - remakes Exorcism\nEquip: Exorcism strikes 1 more target.\nEquip: Increases the damage of Exorcism by 24%.\nEquip: Exorcism's hits leap to 2 more enemies for 36%.";
                            jItem.spell = "Exorcism";
                            jItem.quality = 5;
                        end
                    elseif jKey == "ring1" or jKey == "ring2" then
                        jItem.slotType = "RING";
                    else
                        jItem.slotType = "TRINKET";
                    end
                end
            end
        end
        list[idx] = b;
    end
    return list;
end

function BordoUI_GetActiveBuild()
    BordoUIDB = BordoUIDB or {};
    if not BordoUIDB.activeBuild or not BordoUIDB.activeBuild.classKey then
        return nil, nil, nil;
    end

    local actClass = BordoUIDB.activeBuild.classKey;
    local actIdx = tonumber(BordoUIDB.activeBuild.buildIdx) or 1;
    if actIdx < 1 or actIdx > 3 then actIdx = 1; end

    local builds = BordoUI_GetClassBuilds(actClass);
    if builds and builds[actIdx] then
        return builds[actIdx], actClass, actIdx;
    end
    return nil, nil, nil;
end

function BordoUI_ClearActiveBuild()
    BordoUIDB = BordoUIDB or {};
    BordoUIDB.activeBuild = nil;
end

function BordoUI_IsBuildActiveInRun()
    local b = BordoUI_GetActiveBuild();
    return (b ~= nil);
end

function BordoUI_SetActiveBuild(classKey, buildIdx)
    BordoUIDB = BordoUIDB or {};
    local cUpper = string.upper(classKey);
    local idx = tonumber(buildIdx) or 1;
    if idx < 1 or idx > 3 then idx = 1; end

    local builds = BordoUI_GetClassBuilds(cUpper);
    local b = builds and builds[idx];
    if b then
        BordoUIDB.activeBuild = {
            classKey = cUpper,
            buildIdx = idx,
            id = b.id,
            title = b.title or ("Build " .. idx),
            isCustom = true,
        };
        return b;
    end
    return nil;
end

local SPELL_CANONICAL_KEYS = {
    ["powerwordshield"]     = "pw_shield",
    ["power_word_shield"]   = "pw_shield",
    ["pwshield"]            = "pw_shield",
    ["pw_shield"]           = "pw_shield",

    ["shadowwordpain"]      = "sw_pain",
    ["shadow_word_pain"]    = "sw_pain",
    ["swpain"]              = "sw_pain",
    ["sw_pain"]             = "sw_pain",

    ["demoralizingshout"]   = "demo_shout",
    ["demoralizing_shout"]  = "demo_shout",
    ["demoshout"]           = "demo_shout",
    ["demo_shout"]          = "demo_shout",

    ["huntersmark"]         = "hunters_mark",
    ["hunter_mark"]         = "hunters_mark",
    ["hunters_mark"]        = "hunters_mark",
    ["huntermark"]          = "hunters_mark",

    ["soulfire"]            = "soul_fire",
    ["soul_fire"]           = "soul_fire",

    ["judgment"]            = "judgement",
    ["judgement"]           = "judgement",
};

local function CanonicalSpellKey(str)
    if not str then return ""; end
    local clean = string.lower(string.gsub(tostring(str), "[^%a]", ""));
    return SPELL_CANONICAL_KEYS[clean] or clean;
end

-- Checks if a spell (by key or name) belongs to the currently active build
-- Returns: isMatch (bool), priority (number 1-6), spellData (table)
function BordoUI_IsActiveBuildSpell(spellNameOrKey)
    if not spellNameOrKey then return false, nil, nil; end
    local activeBuild = BordoUI_GetActiveBuild();
    if not (activeBuild and activeBuild.spells) then return false, nil, nil; end
    local targetCanon = CanonicalSpellKey(spellNameOrKey);
    for i = 1, 6 do
        local sp = activeBuild.spells[i];
        if sp and sp.name then
            local spCanonKey = CanonicalSpellKey(sp.key);
            local spCanonName = CanonicalSpellKey(sp.name);
            if targetCanon ~= "" and (targetCanon == spCanonKey or targetCanon == spCanonName) then
                return true, sp.prio or i, sp;
            end
        end
    end
    return false, nil, nil;
end


-- ============================================================================
-- 51-Point Talent Builds & Milestones for All 19 Meta Builds
-- Structured matching Azeroth Survivors Armory Talents UI (3 trees + milestones)
-- ============================================================================
local TALENT_DB = {
    hunter_volley_trapper = {
        summary = "0 / 20 / 31",
        trees = {
            {
                name = "Beast Mastery", points = 0, icon = "Interface\\Icons\\Ability_Hunter_BeastCall",
                milestones = {
                    { pts = 10, name = "Endurance Training", active = false, desc = "Increases health and movement speed." },
                    { pts = 20, name = "Frenzy", active = false, desc = "Increases attack speed after critical strikes." },
                    { pts = 30, name = "Bestial Wrath", active = false, desc = "Enrages you and companions, granting 50% more damage." },
                },
                talents = {},
            },
            {
                name = "Marksmanship", points = 20, icon = "Interface\\Icons\\Ability_Marksmanship",
                milestones = {
                    { pts = 10, name = "Piercing Shots", active = true, desc = "Auto Shot pierces: every arrow strikes 1 extra enemy for 50% damage." },
                    { pts = 20, name = "Mortal Shots", active = true, desc = "Every 5th shot you fire is followed by a free Aimed Shot." },
                    { pts = 30, name = "Trueshot Aura", active = false, desc = "Increases attack power of all nearby allies." },
                },
                talents = {
                    { name = "Efficiency", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_WizardMark", desc = "Reduces cooldowns and mana costs of shots by 10%." },
                    { name = "Lethal Shots", points = 5, max = 5, icon = "Interface\\Icons\\Ability_SearingArrow", desc = "Increases critical strike chance by 5%." },
                    { name = "Aimed Shot", points = 1, max = 1, icon = "Interface\\Icons\\INV_Spear_07", desc = "An aimed shot that deals heavy physical weapon damage." },
                    { name = "Hawk Eye", points = 3, max = 3, icon = "Interface\\Icons\\Ability_TownWatch", desc = "Increases range of all shots by 6 yards." },
                    { name = "Mortal Shots", points = 5, max = 5, icon = "Interface\\Icons\\Ability_PierceDamage", desc = "Increases critical strike damage bonus by 30%." },
                    { name = "Barrage", points = 1, max = 1, icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive", desc = "Increases damage of Multi-Shot and Volley by 5%." },
                },
            },
            {
                name = "Survival", points = 31, icon = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
                milestones = {
                    { pts = 10, name = "Entrapment", active = true, desc = "Traps hold what they hit: 30% chance to root targets for 2 sec." },
                    { pts = 20, name = "Explosive Ammunition", active = true, desc = "Enemies killed by shots or traps explode for 15% of max health." },
                    { pts = 30, name = "Lock and Load", active = true, desc = "Trap triggers grant 2 instant, free shot volleys." },
                },
                talents = {
                    { name = "Monster Slaying", points = 3, max = 3, icon = "Interface\\Icons\\INV_Misc_MonsterHead_01", desc = "Increases damage dealt to monsters by 3%." },
                    { name = "Humanoid Slaying", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing", desc = "Increases critical damage against humanoids by 3%." },
                    { name = "Deflection", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance and damage mitigation." },
                    { name = "Trap Mastery", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", desc = "Greatly reduces enemy resistance to traps." },
                    { name = "Survivalist", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Twilight", desc = "Increases maximum health by 10%." },
                    { name = "Surefooted", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Kick", desc = "Increases hit chance and movement impairing resist." },
                    { name = "Killer Instinct", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_BlessingOfStamina", desc = "Increases critical strike chance with all attacks by 3%." },
                    { name = "Resourcefulness", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Hunter_LockAndLoad", desc = "Reduces cooldown of all traps by 20%." },
                    { name = "Wyvern Sting", points = 2, max = 2, icon = "Interface\\Icons\\INV_Spear_02", desc = "Potent sting putting targets to sleep and dealing poison." },
                },
            },
        },
    },

    hunter_aimed_sniper = {
        summary = "0 / 31 / 20",
        trees = {
            {
                name = "Beast Mastery", points = 0, icon = "Interface\\Icons\\Ability_Hunter_BeastCall",
                milestones = {
                    { pts = 10, name = "Endurance Training", active = false, desc = "Increases health and movement speed." },
                    { pts = 20, name = "Frenzy", active = false, desc = "Increases attack speed after critical strikes." },
                    { pts = 30, name = "Bestial Wrath", active = false, desc = "Enrages you and companions, granting 50% more damage." },
                },
                talents = {},
            },
            {
                name = "Marksmanship", points = 31, icon = "Interface\\Icons\\Ability_Marksmanship",
                milestones = {
                    { pts = 10, name = "Piercing Shots", active = true, desc = "Auto Shot pierces: every arrow strikes 1 extra enemy for 50% damage." },
                    { pts = 20, name = "Mortal Shots", active = true, desc = "Every 5th shot you fire is followed by a free Aimed Shot." },
                    { pts = 30, name = "Trueshot Aura", active = true, desc = "Grants 100 bonus ranged attack power to all attacks." },
                },
                talents = {
                    { name = "Efficiency", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_WizardMark", desc = "Reduces shot cooldowns and costs." },
                    { name = "Lethal Shots", points = 5, max = 5, icon = "Interface\\Icons\\Ability_SearingArrow", desc = "Increases critical strike chance by 5%." },
                    { name = "Aimed Shot", points = 1, max = 1, icon = "Interface\\Icons\\INV_Spear_07", desc = "Deals massive physical single-target burst." },
                    { name = "Hawk Eye", points = 3, max = 3, icon = "Interface\\Icons\\Ability_TownWatch", desc = "Increases range of all shots by 6 yards." },
                    { name = "Mortal Shots", points = 5, max = 5, icon = "Interface\\Icons\\Ability_PierceDamage", desc = "Increases critical strike damage bonus by 30%." },
                    { name = "Barrage", points = 3, max = 3, icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive", desc = "Increases damage of Multi-Shot by 15%." },
                    { name = "Ranged Weapon Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Weapon_Bow_08", desc = "Increases physical ranged damage by 5%." },
                    { name = "Trueshot Aura", points = 1, max = 1, icon = "Interface\\Icons\\Ability_TrueShot", desc = "Aura increasing ranged and melee attack power." },
                    { name = "Piercing Shots", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Gouge", desc = "Critical strikes cause enemies to bleed." },
                },
            },
            {
                name = "Survival", points = 20, icon = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
                milestones = {
                    { pts = 10, name = "Entrapment", active = true, desc = "Traps hold what they hit: 30% chance to root targets for 2 sec." },
                    { pts = 20, name = "Explosive Ammunition", active = true, desc = "Enemies killed by shots or traps explode for 15% of max health." },
                    { pts = 30, name = "Lock and Load", active = false, desc = "Trap triggers grant 2 instant, free shot volleys." },
                },
                talents = {
                    { name = "Monster Slaying", points = 3, max = 3, icon = "Interface\\Icons\\INV_Misc_MonsterHead_01", desc = "Increases damage dealt to monsters by 3%." },
                    { name = "Humanoid Slaying", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing", desc = "Increases critical damage against humanoids by 3%." },
                    { name = "Deflection", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance and damage mitigation." },
                    { name = "Survivalist", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Twilight", desc = "Increases maximum health by 10%." },
                    { name = "Surefooted", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Kick", desc = "Increases hit chance and movement impairing resist." },
                    { name = "Killer Instinct", points = 1, max = 3, icon = "Interface\\Icons\\Spell_Holy_BlessingOfStamina", desc = "Increases critical strike chance with all attacks by 1%." },
                },
            },
        },
    },

    paladin_retribution = {
        summary = "11 / 8 / 32",
        trees = {
            {
                name = "Holy", points = 11, icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
                milestones = {
                    { pts = 10, name = "Divine Favor", active = true, icon = "Interface\\Icons\\Spell_Holy_Heal", desc = "Milestone. You start every run with Holy Shock, and each of its bolts leaps to 2 more enemies for 50% of it." },
                    { pts = 20, name = "Daybreak", active = false, icon = "Interface\\Icons\\Spell_Holy_Excorcism", desc = "Milestone. Holy Shock's critical strikes call down a free Holy Wrath around you, at most once every 3 sec." },
                    { pts = 30, name = "Light's Grace", active = false, icon = "Interface\\Icons\\Spell_Holy_SearingLight", desc = "Capstone. A Holy Wrath bursts from you on its own every 14 sec." },
                },
                talents = {
                    { name = "Divine Strength", row = 1, col = 1, points = 5, max = 5, icon = "Interface\\Icons\\Ability_GolemThunderClap", desc = "Increases your Strength by 10%." },
                    { name = "Divine Intellect", row = 1, col = 3, points = 0, max = 5, icon = "Interface\\Icons\\Spell_Nature_Sleep", desc = "Increases your total Intellect by 10%." },
                    { name = "Spiritual Focus", row = 2, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Arcane_Blink", desc = "Gives your spells a 70% chance to avoid interruption caused by damage." },
                    { name = "Improved Lay on Hands", row = 2, col = 3, points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_LayOnHands", desc = "Gives the target 30% bonus armor and refunds mana." },
                    { name = "Consecration", row = 3, col = 1, points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_InnerFire", desc = "Consecrates the ground beneath you, dealing Holy damage over 8 sec." },
                    { name = "Unyielding Faith", row = 4, col = 1, points = 0, max = 5, icon = "Interface\\Icons\\Spell_Holy_UnyieldingFaith", desc = "Increases resistance to Fear and Disorient effects by 10%." },
                    { name = "Holy Power", row = 4, col = 3, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_Power", desc = "Increases the critical strike chance of Holy spells by 5%." },
                    { name = "Lasting Judgement", row = 5, col = 1, points = 0, max = 1, icon = "Interface\\Icons\\Spell_Holy_HealingAura", desc = "Holy Shock's cooldown is 20% shorter." },
                    { name = "Sanctified Light", row = 6, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_HealingFocus", desc = "Holy spells deal 10% more damage." },
                    { name = "Purifying Power", row = 6, col = 3, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_Purify", desc = "Holy Wrath and Consecration reach 25% farther." },
                },
            },
            {
                name = "Protection", points = 8, icon = "Interface\\Icons\\Spell_Holy_DevotionAura",
                milestones = {
                    { pts = 10, name = "Hallowed Ground", active = false, icon = "Interface\\Icons\\Spell_Holy_SealOfProtection", desc = "Milestone. Every Hammer of Justice that lands hallows the ground beneath you: a free Consecration, at most once every 4 sec." },
                    { pts = 20, name = "Ardent Defender", active = false, icon = "Interface\\Icons\\Spell_Holy_HolyProtection", desc = "Milestone. You start every run with Hammer of Justice. Every Consecration raises a shield of 20% max health, stacking up to 30%, and while a shield holds, you deal 20% more damage." },
                    { pts = 30, name = "Hammer of the Righteous", active = false, icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection", desc = "Capstone. Max health is 15% higher, every spell deals extra 1% max health, Hammer of Justice strikes for 1.5% target max health, and a shield that breaks bursts in holy light." },
                },
                talents = {
                    { name = "Redoubt", row = 1, col = 1, points = 5, max = 5, icon = "Interface\\Icons\\Ability_Defend", desc = "Increases block chance by 30% after taking a hit." },
                    { name = "Improved Devotion Aura", row = 1, col = 3, points = 0, max = 5, icon = "Interface\\Icons\\Spell_Holy_DevotionAura", desc = "Increases armor bonus of Devotion Aura by 25%." },
                    { name = "Improved Consecration", row = 2, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_InnerFire", desc = "Every tick of Consecration deals an extra 1% of your maximum health." },
                    { name = "Precision", row = 2, col = 3, points = 3, max = 3, icon = "Interface\\Icons\\Ability_Marksmanship", desc = "Increases chance to hit with melee attacks and spells by 3%." },
                    { name = "Weighted Hammer", row = 3, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_SealOfMight", desc = "Hammer of Justice deals an extra 2% of your maximum health." },
                    { name = "Judgement of the Crusader", row = 4, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_HolySmite", desc = "Enemies burning in Consecration take 15% more damage from you for 3 sec." },
                    { name = "Righteous Fury", row = 4, col = 3, points = 0, max = 1, icon = "Interface\\Icons\\Spell_Holy_SealOfFury", desc = "Every spell you cast deals an extra 1% of your maximum health." },
                    { name = "Improved Hammer of Justice", row = 5, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_SealOfWrath", desc = "Hammer of Justice deals 20% more damage and recovers faster." },
                    { name = "Blessed Life", row = 5, col = 3, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary", desc = "Consecration's shield holds 9% more of your maximum health." },
                    { name = "Divine Intervention", row = 6, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Spell_Nature_TimeStop", desc = "A blow that would kill you leaves you at 30% health instead, wrapped in Divine Shield and Consecration. Once every 90 sec." },
                    { name = "Sacred Duty", row = 6, col = 3, points = 0, max = 1, icon = "Interface\\Icons\\Spell_Holy_DivineIntervention", desc = "While a shield holds, you deal 20% more damage." },
                },
            },
            {
                name = "Retribution", points = 32, icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
                milestones = {
                    { pts = 10, name = "Seal of Command", active = true, icon = "Interface\\Icons\\Ability_Warrior_InnerRage", desc = "Milestone. You start every run with Judgement, and every Judgement also strikes 2 more enemies near its target for 50% of it." },
                    { pts = 20, name = "The Art of War", active = true, icon = "Interface\\Icons\\Spell_Holy_Excorcism_02", desc = "Milestone. Your critical strikes have a 50% chance to hurl a free Exorcism, at most once a second." },
                    { pts = 30, name = "Divine Storm", active = true, icon = "Interface\\Icons\\Spell_Holy_SealOfRighteousness", desc = "Capstone. You start every run with Exorcism, and every Exorcism bursts on its target, striking every enemy within 5 yd for 50% of it." },
                },
                talents = {
                    { name = "Improved Judgement", row = 1, col = 1, points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_RighteousFury", desc = "Judgement's cooldown is 2 sec shorter." },
                    { name = "Benediction", row = 1, col = 3, points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_WindWalkOn", desc = "Reduces the mana cost of your Judgement and Seal spells by 15%." },
                    { name = "Conviction", row = 2, col = 1, points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_RetributionAura", desc = "Increases your chance to get a critical strike with melee weapons and spells by 5%." },
                    { name = "Deflection", row = 2, col = 3, points = 0, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases your Parry chance by 5%." },
                    { name = "Pursuit of Justice", row = 4, col = 1, points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_PersuitOfJustice", desc = "Increases your movement speed by 15%." },
                    { name = "Two-Handed Weapon Spec", row = 4, col = 3, points = 3, max = 3, icon = "Interface\\Icons\\INV_Hammer_04", desc = "Increases the damage you deal with two-handed melee weapons by 6%." },
                    { name = "Sanctity Aura", row = 5, col = 1, points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_MindVision", desc = "Increases Holy damage dealt by 10%." },
                    { name = "Crusade", row = 5, col = 3, points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_CrusaderStrike", desc = "Increases all damage caused by 3%." },
                    { name = "Righteous Hammer", row = 6, col = 1, points = 0, max = 3, icon = "Interface\\Icons\\Ability_ThunderBolt", desc = "Hammer of Wrath has a 30% chance to strike its target again." },
                    { name = "Vindication", row = 6, col = 3, points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_Vindication", desc = "Reduces the target's physical damage dealt and increases your damage." },
                },
            },
        },
    },
    paladin_holy_bulwark = {
        summary = "11 / 31 / 9",
        trees = {
            {
                name = "Holy", points = 11, icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
                milestones = {
                    { pts = 10, name = "Healing Light", active = true, desc = "Increases healing and spell damage by 12%." },
                    { pts = 20, name = "Illumination", active = false, desc = "Spell criticals refund 100% mana." },
                    { pts = 30, name = "Divine Favor", active = false, desc = "Next spell cast is guaranteed critical strike." },
                },
                talents = {
                    { name = "Divine Strength", points = 5, max = 5, icon = "Interface\\Icons\\Ability_GolemThunderClap", desc = "Increases Strength by 10%." },
                    { name = "Divine Intellect", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_Sleep", desc = "Increases total Intellect by 10%." },
                    { name = "Consecration", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_InnerFire", desc = "Consecrates ground, damaging all entering enemies." },
                },
            },
            {
                name = "Protection", points = 31, icon = "Interface\\Icons\\Spell_Holy_DevotionAura",
                milestones = {
                    { pts = 10, name = "Redoubt", active = true, desc = "Increases block chance after taking hits." },
                    { pts = 20, name = "Blessing of Sanctuary", active = true, desc = "Reduces damage taken and deals holy damage on block." },
                    { pts = 30, name = "Holy Shield", active = true, desc = "Increases block chance by 30% and reflects holy damage." },
                },
                talents = {
                    { name = "Redoubt", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Defend", desc = "Increases block chance by 30% after taking a hit." },
                    { name = "Precision", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Marksmanship", desc = "Increases chance to hit by 3%." },
                    { name = "Toughness", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_DevotionAura", desc = "Increases armor value from items by 10%." },
                    { name = "Shield Specialization", points = 3, max = 3, icon = "Interface\\Icons\\INV_Shield_06", desc = "Increases damage absorbed by shield by 30%." },
                    { name = "Blessing of Sanctuary", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_LightningShield", desc = "Reduces damage taken and deals holy retaliation." },
                    { name = "Reckoning", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_BlessingOfStrength", desc = "Grants extra attack swing upon being critically struck." },
                    { name = "One-Handed Weapon Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Sword_20", desc = "Increases damage with 1H weapons by 10%." },
                    { name = "Holy Shield", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection", desc = "Increases block chance by 30% and damages attackers." },
                    { name = "Ardent Defender", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_ArdentDefender", desc = "Reduces damage taken below 35% health by 20%." },
                },
            },
            {
                name = "Retribution", points = 9, icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
                milestones = {
                    { pts = 10, name = "Seal of Command", active = false, desc = "Attacks have chance to deal holy weapon damage." },
                    { pts = 20, name = "Sanctity Aura", active = false, desc = "Increases Holy damage dealt by 10%." },
                    { pts = 30, name = "Vengeance", active = false, desc = "Crits grant 15% bonus physical and holy damage." },
                },
                talents = {
                    { name = "Benediction", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_WindWalkOn", desc = "Reduces mana cost of Judgement and Seals." },
                    { name = "Deflection", points = 4, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance by 4%." },
                },
            },
        },
    },

    warrior_whirlwind_cleaver = {
        summary = "31 / 20 / 0",
        trees = {
            {
                name = "Arms", points = 31, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                milestones = {
                    { pts = 10, name = "Deep Wounds", active = true, desc = "Critical strikes cause bleed for 60% of weapon damage." },
                    { pts = 20, name = "Sweeping Strikes", active = true, desc = "Next 5 melee strikes hit an additional nearby enemy." },
                    { pts = 30, name = "Mortal Strike", active = true, desc = "A vicious strike dealing heavy damage and reducing healing taken." },
                },
                talents = {
                    { name = "Rend", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Gouge", desc = "Increases bleed damage of Rend by 35%." },
                    { name = "Tactical Mastery", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_EnchantArmor", desc = "Retains rage upon changing combat stances." },
                    { name = "Deep Wounds", points = 3, max = 3, icon = "Interface\\Icons\\Ability_BackStab", desc = "Crits cause bleed for 60% of weapon damage." },
                    { name = "Impale", points = 2, max = 2, icon = "Interface\\Icons\\Ability_SearingArrow", desc = "Increases critical strike damage bonus of abilities by 20%." },
                    { name = "Two-Handed Weapon Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Axe_09", desc = "Increases damage with two-handed weapons by 5%." },
                    { name = "Sweeping Strikes", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Rogue_DualWeild", desc = "Your next 5 attacks strike an extra nearby target." },
                    { name = "Poleaxe Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Axe_06", desc = "Increases critical strike chance with Axes and Polearms by 5%." },
                    { name = "Mortal Strike", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Warrior_SavageBlow", desc = "A vicious strike dealing weapon damage plus bonus." },
                    { name = "Blood Frenzy", points = 6, max = 6, icon = "Interface\\Icons\\Ability_Warrior_BloodFrenzy", desc = "Increases physical damage taken by bleeding targets by 4%." },
                },
            },
            {
                name = "Fury", points = 20, icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
                milestones = {
                    { pts = 10, name = "Piercing Howl", active = true, desc = "Slows all enemies within 10 yards by 50% for 6 sec." },
                    { pts = 20, name = "Death Wish", active = true, desc = "Increases physical damage by 20% but increases damage taken." },
                    { pts = 30, name = "Bloodthirst", active = false, desc = "Instantly attacks target and causes next attacks to heal." },
                },
                talents = {
                    { name = "Cruelty", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate", desc = "Increases critical strike chance with melee weapons by 5%." },
                    { name = "Unbridled Wrath", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem", desc = "Gives a chance to generate an additional Rage point on hits." },
                    { name = "Piercing Howl", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_DeathScream", desc = "Slows all nearby enemies by 50%." },
                    { name = "Blood Craze", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_SummonImp", desc = "Regenerates 3% of total health after being critically struck." },
                    { name = "Enrage", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy", desc = "Gives 25% melee damage bonus after being struck by a crit." },
                    { name = "Flurry", points = 1, max = 5, icon = "Interface\\Icons\\Ability_GhoulFrenzy", desc = "Increases attack speed by 10% after dealing a critical hit." },
                },
            },
            {
                name = "Protection", points = 0, icon = "Interface\\Icons\\INV_Shield_06",
                milestones = {
                    { pts = 10, name = "Last Stand", active = false, desc = "Grants 30% of maximum health for 20 sec." },
                    { pts = 20, name = "Concussion Blow", active = false, desc = "Stuns target for 5 sec." },
                    { pts = 30, name = "Shield Slam", active = false, desc = "Slams target with shield, dealing heavy damage." },
                },
                talents = {},
            },
        },
    },

    warrior_shield_slam_prot = {
        summary = "5 / 5 / 41",
        trees = {
            {
                name = "Arms", points = 5, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                milestones = {
                    { pts = 10, name = "Tactical Mastery", active = false, desc = "Retains rage upon changing stances." },
                    { pts = 20, name = "Sweeping Strikes", active = false, desc = "Next 5 melee strikes hit an additional nearby enemy." },
                    { pts = 30, name = "Mortal Strike", active = false, desc = "A vicious strike dealing heavy damage and reducing healing taken." },
                },
                talents = {
                    { name = "Deflection", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance by 5%." },
                },
            },
            {
                name = "Fury", points = 5, icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
                milestones = {
                    { pts = 10, name = "Piercing Howl", active = false, desc = "Slows all nearby enemies by 50%." },
                    { pts = 20, name = "Death Wish", active = false, desc = "Increases physical damage by 20%." },
                    { pts = 30, name = "Bloodthirst", active = false, desc = "Instantly attacks target and causes next attacks to heal." },
                },
                talents = {
                    { name = "Cruelty", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate", desc = "Increases critical strike chance with melee weapons by 5%." },
                },
            },
            {
                name = "Protection", points = 41, icon = "Interface\\Icons\\INV_Shield_06",
                milestones = {
                    { pts = 10, name = "Last Stand", active = true, desc = "Grants 30% of maximum health for 20 sec upon reaching critical health." },
                    { pts = 20, name = "Concussion Blow", active = true, desc = "A brutal strike that stuns the target for 5 sec." },
                    { pts = 30, name = "Shield Slam", active = true, desc = "Empowers Shield Slam: deals 50% more damage and has a 50% chance to dispel magic." },
                },
                talents = {
                    { name = "Shield Specialization", points = 5, max = 5, icon = "Interface\\Icons\\INV_Shield_06", desc = "Increases block chance by 5% and generates 1 rage on block." },
                    { name = "Anticipation", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_MirrorImage", desc = "Increases Defense skill by 10." },
                    { name = "Toughness", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_Devotion", desc = "Increases armor value from items by 10%." },
                    { name = "Iron Will", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Magic_MageArmor", desc = "Increases resistance to Stun and Charm effects by 15%." },
                    { name = "Improved Shield Block", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Defensivestate", desc = "Increases block chance from Shield Block and allows an additional block." },
                    { name = "Defiance", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Warrior_InnerRage", desc = "Increases threat and physical damage mitigation." },
                    { name = "One-Handed Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Sword_20", desc = "Increases damage dealt when a one-handed melee weapon is equipped by 10%." },
                    { name = "Shield Slam", points = 1, max = 1, icon = "Interface\\Icons\\INV_Shield_05", desc = "Slams the target with your shield, causing heavy physical damage modified by your shield block value." },
                },
            },
        },
    },
    warrior_bleed_berserker = {
        summary = "31 / 5 / 15",
        trees = {
            {
                name = "Arms", points = 31, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                milestones = {
                    { pts = 10, name = "Deep Wounds", active = true, desc = "Critical strikes cause bleed for 60% of weapon damage." },
                    { pts = 20, name = "Sweeping Strikes", active = true, desc = "Next 5 melee strikes hit an additional nearby enemy." },
                    { pts = 30, name = "Mortal Strike", active = true, desc = "A vicious strike dealing heavy damage and reducing healing taken." },
                },
                talents = {
                    { name = "Deflection", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance by 5%." },
                    { name = "Tactical Mastery", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_EnchantArmor", desc = "Retains rage upon changing stances." },
                    { name = "Deep Wounds", points = 3, max = 3, icon = "Interface\\Icons\\Ability_BackStab", desc = "Crits cause bleed for 60% of weapon damage." },
                    { name = "Impale", points = 2, max = 2, icon = "Interface\\Icons\\Ability_SearingArrow", desc = "Increases critical strike damage bonus of abilities by 20%." },
                    { name = "Two-Handed Weapon Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Axe_09", desc = "Increases damage with two-handed weapons by 5%." },
                    { name = "Sweeping Strikes", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Rogue_DualWeild", desc = "Your next 5 attacks strike an extra nearby target." },
                    { name = "Sword Spec", points = 5, max = 5, icon = "Interface\\Icons\\INV_Sword_27", desc = "Grants 5% chance to get an extra attack on same target." },
                    { name = "Mortal Strike", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Warrior_SavageBlow", desc = "A vicious strike dealing weapon damage plus bonus." },
                    { name = "Blood Frenzy", points = 4, max = 4, icon = "Interface\\Icons\\Ability_Warrior_BloodFrenzy", desc = "Increases physical damage taken by bleeding targets by 4%." },
                },
            },
            {
                name = "Fury", points = 5, icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
                milestones = {
                    { pts = 10, name = "Piercing Howl", active = false, desc = "Slows all nearby enemies by 50%." },
                    { pts = 20, name = "Death Wish", active = false, desc = "Increases physical damage by 20%." },
                    { pts = 30, name = "Bloodthirst", active = false, desc = "Instantly attacks target and causes next attacks to heal." },
                },
                talents = {
                    { name = "Cruelty", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate", desc = "Increases critical strike chance with melee weapons by 5%." },
                },
            },
            {
                name = "Protection", points = 15, icon = "Interface\\Icons\\INV_Shield_06",
                milestones = {
                    { pts = 10, name = "Last Stand", active = true, desc = "Grants 30% of maximum health for 20 sec." },
                    { pts = 20, name = "Concussion Blow", active = false, desc = "Stuns target for 5 sec." },
                    { pts = 30, name = "Shield Slam", active = false, desc = "Slams target with shield, dealing heavy damage." },
                },
                talents = {
                    { name = "Shield Specialization", points = 5, max = 5, icon = "Interface\\Icons\\INV_Shield_06", desc = "Increases block chance by 5% and generates rage." },
                    { name = "Anticipation", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_MirrorImage", desc = "Increases Defense skill by 10." },
                    { name = "Toughness", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_DevotionAura", desc = "Increases armor value from items by 10%." },
                },
            },
        },
    },

    mage_frost_shatter = {
        summary = "18 / 0 / 33",
        trees = {
            {
                name = "Arcane", points = 18, icon = "Interface\\Icons\\Spell_Nature_WispSplode",
                milestones = {
                    { pts = 10, name = "Arcane Concentration", active = true, desc = "Clearcasting state reduces next spell mana cost to 0." },
                    { pts = 20, name = "Arcane Meditation", active = false, desc = "Allows mana regeneration while casting." },
                    { pts = 30, name = "Arcane Power", active = false, desc = "Increases spell damage by 30% but increases cost." },
                },
                talents = {
                    { name = "Arcane Subtlety", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_DispelMagic", desc = "Reduces target resistance to all spells by 10." },
                    { name = "Arcane Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Arcane_StarFire", desc = "Increases hit chance of Arcane spells by 6%." },
                    { name = "Arcane Concentration", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_ManaBurn", desc = "10% chance of entering Clearcasting state on hit." },
                    { name = "Magic Absorption", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_AstralRecalGroup", desc = "Increases resistances and restores mana on resist." },
                    { name = "Arcane Meditation", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_SiphonMana", desc = "Allows 15% of mana regen to continue while casting." },
                },
            },
            {
                name = "Fire", points = 0, icon = "Interface\\Icons\\Spell_Fire_FireBolt02",
                milestones = {
                    { pts = 10, name = "Ignite", active = false, desc = "Crits deal 40% additional damage over 4 sec." },
                    { pts = 20, name = "Blast Wave", active = false, desc = "Wave of flame radiates outward, dazing enemies." },
                    { pts = 30, name = "Combustion", active = false, desc = "Critical strike chance increased until 3 crits occur." },
                },
                talents = {},
            },
            {
                name = "Frost", points = 33, icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
                milestones = {
                    { pts = 10, name = "Ice Shards", active = true, desc = "Increases critical strike damage bonus of Frost spells by 100%." },
                    { pts = 20, name = "Cold Snap", active = true, desc = "Instantly finishes cooldown of all Frost spells." },
                    { pts = 30, name = "Ice Barrier", active = true, desc = "Shields you, absorbing heavy damage and preventing interruption." },
                },
                talents = {
                    { name = "Frost Warding", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Frost_FrostWard", desc = "Increases armor and frost resistance." },
                    { name = "Elemental Precision", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Ice_MagicDamage", desc = "Reduces chance enemies resist Frost and Fire spells by 6%." },
                    { name = "Ice Shards", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_IceShard", desc = "Increases critical strike damage bonus by 100%." },
                    { name = "Improved Blizzard", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Frost_IceStorm", desc = "Adds a chill effect to Blizzard, slowing movement by 65%." },
                    { name = "Piercing Ice", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Frost_Frostbolt", desc = "Increases damage of Frost spells by 6%." },
                    { name = "Frost Channeling", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Frost_Stun", desc = "Reduces mana cost and cooldown of Frost spells." },
                    { name = "Shatter", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_FrostShock", desc = "Increases critical strike chance against frozen targets by 50%." },
                    { name = "Ice Block", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Frost_Frost", desc = "Encases you in a block of ice, protecting from all attacks." },
                    { name = "Ice Barrier", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Ice_Lament", desc = "Instantly shields you with an absorb barrier." },
                    { name = "Winter's Chill", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_ChillingBlast", desc = "Frost spells increase crit chance by up to 10%." },
                    { name = "Arctic Reach", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_DarkRitual", desc = "Increases Blizzard and Frost Nova radius by 20%." },
                },
            },
        },
    },

    mage_firestorm = {
        summary = "11 / 40 / 0",
        trees = {
            {
                name = "Arcane", points = 11, icon = "Interface\\Icons\\Spell_Nature_WispSplode",
                milestones = {
                    { pts = 10, name = "Arcane Concentration", active = true, desc = "Clearcasting state reduces next spell mana cost to 0." },
                    { pts = 20, name = "Arcane Meditation", active = false, desc = "Allows mana regeneration while casting." },
                    { pts = 30, name = "Arcane Power", active = false, desc = "Increases spell damage by 30%." },
                },
                talents = {
                    { name = "Arcane Concentration", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_ManaBurn", desc = "10% chance of Clearcasting state on hit." },
                    { name = "Arcane Impact", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_WispSplode", desc = "Increases critical strike chance of Arcane spells by 6%." },
                    { name = "Arcane Meditation", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_SiphonMana", desc = "Allows 15% of mana regen while casting." },
                },
            },
            {
                name = "Fire", points = 40, icon = "Interface\\Icons\\Spell_Fire_FireBolt02",
                milestones = {
                    { pts = 10, name = "Ignite", active = true, desc = "Crits deal 40% additional damage over 4 sec." },
                    { pts = 20, name = "Blast Wave", active = true, desc = "Wave of flame radiates outward, dazing enemies." },
                    { pts = 30, name = "Combustion", active = true, desc = "Critical strike chance increased until 3 crits occur." },
                },
                talents = {
                    { name = "Improved Fireball", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_FlameBolt", desc = "Reduces cast time of Fireball by 0.5 sec." },
                    { name = "Ignite", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_Incinerate", desc = "Fire spell crits burn target for 40% more over 4 sec." },
                    { name = "Flame Throwing", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Fire_Flare", desc = "Increases range of all Fire spells by 6 yards." },
                    { name = "Incinerate", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Fire_SoulBurn", desc = "Increases critical strike chance of Fire Blast by 4%." },
                    { name = "Pyroblast", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Fire_Fireball02", desc = "Hurls an immense fiery boulder that causes massive burn." },
                    { name = "Burning Soul", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Fire_Fire", desc = "Reduces pushback on Fire spells by 70%." },
                    { name = "Improved Flamestrike", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", desc = "Increases critical strike chance of Flamestrike by 15%." },
                    { name = "Critical Mass", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_WispHeal", desc = "Increases critical strike chance of all Fire spells by 6%." },
                    { name = "Blast Wave", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_Excorcism_02", desc = "Radial wave of fire dazing and burning all surrounding foes." },
                    { name = "Fire Power", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Increases damage of all Fire spells by 10%." },
                    { name = "Combustion", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Fire_SealOfFire", desc = "Guarantees consecutive fire critical strikes." },
                    { name = "Molten Fury", points = 10, max = 10, icon = "Interface\\Icons\\Spell_Fire_MoltenBlood", desc = "Increases damage against enemies below 50% health by 20%." },
                },
            },
            {
                name = "Frost", points = 0, icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
                milestones = {
                    { pts = 10, name = "Ice Shards", active = false, desc = "Increases crit damage of Frost spells by 100%." },
                    { pts = 20, name = "Cold Snap", active = false, desc = "Resets cooldown of all Frost spells." },
                    { pts = 30, name = "Ice Barrier", active = false, desc = "Shields you, absorbing heavy damage." },
                },
                talents = {},
            },
        },
    },

    warlock_affliction_vampire = {
        summary = "31 / 8 / 12",
        trees = {
            {
                name = "Affliction", points = 31, icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
                milestones = {
                    { pts = 10, name = "Nightfall", active = true, desc = "Corruption ticks have chance to grant instant Shadow Bolt." },
                    { pts = 20, name = "Siphon Life", active = true, desc = "Transfers health from target to caster every 3 sec." },
                    { pts = 30, name = "Shadow Mastery", active = true, desc = "Increases damage dealt by Shadow spells by 10%." },
                },
                talents = {
                    { name = "Suppression", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding", desc = "Reduces chance enemies resist Affliction spells by 10%." },
                    { name = "Improved Corruption", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", desc = "Reduces cast time of Corruption by 2 sec (Instant)." },
                    { name = "Improved Drain Life", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02", desc = "Increases health drained by Drain Life by 10%." },
                    { name = "Fel Concentration", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_FingerOfDeath", desc = "70% chance to avoid pushback while draining." },
                    { name = "Amplify Curse", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_Contagion", desc = "Increases effect of next Curse of Agony by 50%." },
                    { name = "Grim Reach", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_CallofBone", desc = "Increases range of Affliction spells by 20%." },
                    { name = "Nightfall", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_Twilight", desc = "4% chance per Corruption tick to grant instant Shadow Bolt." },
                    { name = "Siphon Life", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_Requiem", desc = "Transfers life from target to you continuously." },
                    { name = "Shadow Mastery", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Shade", desc = "Increases Shadow spell damage and drains by 10%." },
                },
            },
            {
                name = "Demonology", points = 8, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
                milestones = {
                    { pts = 10, name = "Fel Stamina", active = false, desc = "Increases max health." },
                    { pts = 20, name = "Master Demonologist", active = false, desc = "Grants powerful stat buffs." },
                    { pts = 30, name = "Soul Link", active = false, desc = "Shares 30% of damage taken with demon companion." },
                },
                talents = {
                    { name = "Demonic Embrace", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis", desc = "Increases total Stamina by 15%." },
                    { name = "Fel Intellect", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_MagicalSentry", desc = "Increases total Intellect by 9%." },
                },
            },
            {
                name = "Destruction", points = 12, icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
                milestones = {
                    { pts = 10, name = "Shadowburn", active = true, desc = "Instantly blasts target for heavy shadow damage." },
                    { pts = 20, name = "Ruin", active = false, desc = "Increases critical strike damage bonus by 100%." },
                    { pts = 30, name = "Conflagrate", active = false, desc = "Ignites Immolate to trigger massive explosion." },
                },
                talents = {
                    { name = "Cataclysm", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_WindBreath", desc = "Reduces mana cost of Destruction spells by 5%." },
                    { name = "Bane", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_DeathPact", desc = "Reduces cast time of Shadow Bolt and Immolate." },
                    { name = "Shadowburn", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_ScourgeBuild", desc = "Instant heavy shadow damage nuke." },
                    { name = "Devastation", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Fire_FlameShock", desc = "Increases critical strike chance of Destruction spells by 1%." },
                },
            },
        },
    },

    warlock_destruction_hellfire = {
        summary = "7 / 5 / 39",
        trees = {
            {
                name = "Affliction", points = 7, icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
                milestones = {
                    { pts = 10, name = "Nightfall", active = false, desc = "Corruption ticks have chance to grant instant Shadow Bolt." },
                    { pts = 20, name = "Siphon Life", active = false, desc = "Transfers health from target to caster." },
                    { pts = 30, name = "Shadow Mastery", active = false, desc = "Increases damage dealt by Shadow spells." },
                },
                talents = {
                    { name = "Suppression", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding", desc = "Reduces enemy spell resist by 10%." },
                    { name = "Improved Corruption", points = 2, max = 5, icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", desc = "Reduces Corruption cast time by 0.8 sec." },
                },
            },
            {
                name = "Demonology", points = 5, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
                milestones = {
                    { pts = 10, name = "Fel Stamina", active = false, desc = "Increases max health." },
                    { pts = 20, name = "Master Demonologist", active = false, desc = "Grants powerful stat buffs." },
                    { pts = 30, name = "Soul Link", active = false, desc = "Shares 30% damage taken." },
                },
                talents = {
                    { name = "Demonic Embrace", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis", desc = "Increases total Stamina by 15%." },
                },
            },
            {
                name = "Destruction", points = 39, icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
                milestones = {
                    { pts = 10, name = "Shadowburn", active = true, desc = "Instantly blasts target for heavy shadow damage." },
                    { pts = 20, name = "Ruin", active = true, desc = "Increases critical strike damage bonus of Destruction spells by 100%." },
                    { pts = 30, name = "Conflagrate", active = true, desc = "Ignites Immolate to trigger massive explosion." },
                },
                talents = {
                    { name = "Cataclysm", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_WindBreath", desc = "Reduces mana cost of spells." },
                    { name = "Bane", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_DeathPact", desc = "Reduces cast time of Shadow Bolt by 0.5 sec." },
                    { name = "Improved Shadow Bolt", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt", desc = "Critical strikes grant 20% bonus shadow damage." },
                    { name = "Shadowburn", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_ScourgeBuild", desc = "Instant heavy shadow damage nuke." },
                    { name = "Devastation", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_FlameShock", desc = "Increases critical strike chance of Destruction spells by 5%." },
                    { name = "Searing Pain", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_SoulBurn", desc = "Increases critical strike chance of Searing Pain by 10%." },
                    { name = "Ruin", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", desc = "Increases critical strike damage bonus by 100%." },
                    { name = "Conflagrate", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Fire_Fireball", desc = "Ignites Immolate, dealing massive immediate fire burst." },
                    { name = "Fire and Brimstone", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Increases damage of Immolate and Incinerate by 10%." },
                    { name = "Destructive Reach", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_CallofBone", desc = "Increases range of Destruction spells by 20%." },
                    { name = "Pyroclasm", points = 4, max = 4, icon = "Interface\\Icons\\Spell_Fire_Volcano", desc = "Rain of Fire and Hellfire have chance to stun enemies." },
                },
            },
        },
    },

    rogue_blade_flurry = {
        summary = "19 / 32 / 0",
        trees = {
            {
                name = "Assassination", points = 19, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                milestones = {
                    { pts = 10, name = "Deadly Poison", active = true, desc = "Strikes poison: every swing adds Deadly Poison for 6 sec." },
                    { pts = 20, name = "Lethality", active = false, desc = "Increases critical strike damage bonus." },
                    { pts = 30, name = "Cold Blood", active = false, desc = "Guarantees a critical strike on next ability." },
                },
                talents = {
                    { name = "Malice", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Racial_BloodRage", desc = "Increases critical strike chance by 5%." },
                    { name = "Ruthlessness", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Druid_Disembowel", desc = "60% chance to add a combo point on finishing move." },
                    { name = "Murder", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_DeathPact", desc = "Increases all damage dealt by 2%." },
                    { name = "Relentless Strikes", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike", desc = "Finishing moves have 20% chance per combo point to refund energy." },
                    { name = "Lethality", points = 5, max = 5, icon = "Interface\\Icons\\Ability_CriticalStrike", desc = "Increases critical strike damage bonus of Sinister Strike by 30%." },
                    { name = "Vile Poisons", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Rogue_FeignDeath", desc = "Increases poison damage by 15%." },
                },
            },
            {
                name = "Combat", points = 32, icon = "Interface\\Icons\\Ability_BackStab",
                milestones = {
                    { pts = 10, name = "Blade Flurry", active = true, desc = "Sinister Strike & Eviscerate strike 2 additional nearby targets." },
                    { pts = 20, name = "Adrenaline Rush", active = true, desc = "Every 15th kill floods you with adrenaline: 60% faster cooldowns for 11 sec." },
                    { pts = 30, name = "Surprise Attacks", active = true, desc = "Your finishing moves cannot be dodged and deal 10% more damage." },
                },
                talents = {
                    { name = "Improved Sinister Strike", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice", desc = "Reduces energy cost of Sinister Strike by 5." },
                    { name = "Lightning Reflexes", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_Invisibility", desc = "Increases dodge chance by 3%." },
                    { name = "Deflection", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Parry", desc = "Increases parry chance by 5%." },
                    { name = "Precision", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Marksmanship", desc = "Increases chance to hit with melee weapons by 5%." },
                    { name = "Dual Wield Spec", points = 5, max = 5, icon = "Interface\\Icons\\Ability_DualWield", desc = "Increases damage dealt by off-hand weapon by 50%." },
                    { name = "Blade Flurry", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow", desc = "Increases attack speed by 20% and cleaves nearby enemies." },
                    { name = "Weapon Expertise", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_BlessingOfStrength", desc = "Increases weapon skill by 5." },
                    { name = "Aggression", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Racial_Avatar", desc = "Increases damage of Sinister Strike and Eviscerate by 6%." },
                    { name = "Adrenaline Rush", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate", desc = "Doubles energy regeneration rate for 15 sec." },
                    { name = "Surprise Attacks", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Rogue_SurpriseAttack", desc = "Increases ability damage by 10%." },
                },
            },
            {
                name = "Subtlety", points = 0, icon = "Interface\\Icons\\Ability_Stealth",
                milestones = {
                    { pts = 10, name = "Ghostly Strike", active = false, desc = "Strikes target and increases dodge chance." },
                    { pts = 20, name = "Preparation", active = false, desc = "Resets cooldown of rogue abilities." },
                    { pts = 30, name = "Premeditation", active = false, desc = "Adds 2 combo points immediately." },
                },
                talents = {},
            },
        },
    },

    rogue_shadow_assassin = {
        summary = "31 / 8 / 12",
        trees = {
            {
                name = "Assassination", points = 31, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
                milestones = {
                    { pts = 10, name = "Deadly Poison", active = true, desc = "Strikes poison: every swing adds Deadly Poison for 6 sec." },
                    { pts = 20, name = "Lethality", active = true, desc = "Sinister Strike & Backstab hit twice at once for 50% blow." },
                    { pts = 30, name = "Vigor", active = true, desc = "Increases maximum Energy and combat resource cap." },
                },
                talents = {
                    { name = "Malice", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Racial_BloodRage", desc = "Increases critical strike chance by 5%." },
                    { name = "Ruthlessness", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Druid_Disembowel", desc = "60% chance to add combo point on finishing move." },
                    { name = "Murder", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_DeathPact", desc = "Increases all damage dealt by 2%." },
                    { name = "Relentless Strikes", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike", desc = "Finishing moves refund energy." },
                    { name = "Lethality", points = 5, max = 5, icon = "Interface\\Icons\\Ability_CriticalStrike", desc = "Increases critical strike damage bonus by 30%." },
                    { name = "Vile Poisons", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Rogue_FeignDeath", desc = "Increases poison damage by 20%." },
                    { name = "Cold Blood", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Ice_Lohn", desc = "Guarantees next ability deals critical damage." },
                    { name = "Seal Fate", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_ChillTouch", desc = "Critical strikes grant additional combo point." },
                    { name = "Vigor", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_EarthBindTotem", desc = "Increases maximum Energy by 10." },
                    { name = "Master Poisoner", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Creature_Poison_06", desc = "Increases poison application chance." },
                },
            },
            {
                name = "Combat", points = 8, icon = "Interface\\Icons\\Ability_BackStab",
                milestones = {
                    { pts = 10, name = "Blade Flurry", active = false, desc = "Cleaves nearby enemies." },
                    { pts = 20, name = "Adrenaline Rush", active = false, desc = "Cooldown recovery speed boosted." },
                    { pts = 30, name = "Surprise Attacks", active = false, desc = "Finishing moves cannot be dodged." },
                },
                talents = {
                    { name = "Improved Sinister Strike", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice", desc = "Reduces energy cost of Sinister Strike." },
                    { name = "Precision", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Marksmanship", desc = "Increases melee hit chance by 5%." },
                    { name = "Endurance", points = 1, max = 2, icon = "Interface\\Icons\\Spell_Shadow_ShadowWard", desc = "Reduces Sprint and Evasion cooldown." },
                },
            },
            {
                name = "Subtlety", points = 12, icon = "Interface\\Icons\\Ability_Stealth",
                milestones = {
                    { pts = 10, name = "Ghostly Strike", active = true, desc = "Strikes target and increases dodge chance." },
                    { pts = 20, name = "Preparation", active = false, desc = "Resets cooldown of abilities." },
                    { pts = 30, name = "Premeditation", active = false, desc = "Adds 2 combo points immediately." },
                },
                talents = {
                    { name = "Master of Deception", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Charm", desc = "Reduces chance enemies detect stealth." },
                    { name = "Opportunity", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Warrior_WarCry", desc = "Increases damage of Backstab and Ambush by 20%." },
                    { name = "Ghostly Strike", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_Curse", desc = "Strikes enemy and increases dodge by 15%." },
                    { name = "Elusiveness", points = 1, max = 2, icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty", desc = "Reduces cooldown of Vanish and Blind." },
                },
            },
        },
    },

    shaman_chain_lightning = {
        summary = "31 / 0 / 20",
        trees = {
            {
                name = "Elemental", points = 31, icon = "Interface\\Icons\\Spell_Nature_Lightning",
                milestones = {
                    { pts = 10, name = "Lightning Overload", active = true, desc = "Lightning Bolt and Chain Lightning have a 25% chance to strike again for free." },
                    { pts = 20, name = "Elemental Fury", active = true, desc = "Chain Lightning jumps to 3 more enemies and loses nothing with each jump." },
                    { pts = 30, name = "Elemental Mastery", active = true, desc = "Start every run with Chain Lightning, and a 2nd Chain Lightning casts itself every 3 sec." },
                },
                talents = {
                    { name = "Convection", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_WispSplode", desc = "Reduces mana cost and cooldown of Shock and Lightning spells." },
                    { name = "Concussion", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_Fireball", desc = "Increases damage of Shock and Lightning spells by 5%." },
                    { name = "Call of Flame", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Increases damage of Fire Nova and Flame Shock by 15%." },
                    { name = "Elemental Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_ManaBurn", desc = "Clearcasting state reduces next spell mana cost to 0." },
                    { name = "Reverberation", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_FrostWard", desc = "Reduces cooldown of Shock spells by 1 sec." },
                    { name = "Call of Thunder", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_CallStorm", desc = "Increases critical strike chance of Lightning spells by 6%." },
                    { name = "Eye of the Storm", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Nature_EyeOfTheStorm", desc = "Grants 100% pushback resistance on critical hit." },
                    { name = "Elemental Fury", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Fire_Volcano", desc = "Increases critical strike damage bonus of Fire and Nature spells by 100%." },
                    { name = "Lightning Mastery", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01", desc = "Nature spells deal 10% more damage." },
                },
            },
            {
                name = "Enhancement", points = 0, icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                milestones = {
                    { pts = 10, name = "Windfury", active = false, desc = "Melee swings can proc extra hits." },
                    { pts = 20, name = "Maelstrom Weapon", active = false, desc = "Reduces spell cast times." },
                    { pts = 30, name = "Feral Spirit", active = false, desc = "Summons spirit wolves." },
                },
                talents = {},
            },
            {
                name = "Restoration", points = 20, icon = "Interface\\Icons\\Spell_Nature_MagicImmunity",
                milestones = {
                    { pts = 10, name = "Call of the Elements", active = true, desc = "Totem pulse radius increased and pulse intervals faster." },
                    { pts = 20, name = "Reincarnation", active = true, desc = "Upon death, rise again at half health with a massive knockback." },
                    { pts = 30, name = "Totemic Wrath", active = false, desc = "All totems emit damaging shockwaves." },
                },
                talents = {
                    { name = "Tidal Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_ManaRecharge", desc = "Reduces mana cost and cooldown of healing spells." },
                    { name = "Ancestral Healing", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_UndyingStrength", desc = "Increases target armor by 25% on critical heal." },
                    { name = "Totemic Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_MoonKey", desc = "Reduces mana cost and cooldown of all totems by 25%." },
                    { name = "Healing Way", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_HealingWay", desc = "Increases healing of subsequent Healing Waves." },
                    { name = "Restorative Totems", points = 4, max = 5, icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", desc = "Increases effect of Mana Spring and Healing Stream totems." },
                },
            },
        },
    },

    shaman_windfury_brawler = {
        summary = "0 / 32 / 19",
        trees = {
            {
                name = "Elemental", points = 0, icon = "Interface\\Icons\\Spell_Nature_Lightning",
                milestones = {
                    { pts = 10, name = "Lightning Overload", active = false, desc = "Spells have chance to strike again." },
                    { pts = 20, name = "Elemental Fury", active = false, desc = "Increases crit damage by 100%." },
                    { pts = 30, name = "Elemental Mastery", active = false, desc = "Guarantees critical strike." },
                },
                talents = {},
            },
            {
                name = "Enhancement", points = 32, icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                milestones = {
                    { pts = 10, name = "Windfury", active = true, desc = "Melee swings can proc extra hits with massive attack power bonus." },
                    { pts = 20, name = "Maelstrom Weapon", active = true, desc = "Critical hits reduce ability cooldowns and cast times." },
                    { pts = 30, name = "Feral Spirit", active = true, desc = "Summons two Spirit Wolves to shred nearby enemies." },
                },
                talents = {
                    { name = "Shield Specialization", points = 5, max = 5, icon = "Interface\\Icons\\INV_Shield_06", desc = "Increases block chance by 5% and block value by 25%." },
                    { name = "Thundering Strikes", points = 5, max = 5, icon = "Interface\\Icons\\Ability_ThunderBolt", desc = "Increases critical strike chance with all attacks by 5%." },
                    { name = "Improved Ghost Wolf", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Nature_SpiritWolf", desc = "Makes Ghost Wolf instant cast." },
                    { name = "Two-Handed Axes/Maces", points = 1, max = 1, icon = "Interface\\Icons\\INV_Axe_10", desc = "Allows wielding two-handed axes and maces." },
                    { name = "Anticipation", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_MirrorImage", desc = "Increases Dodge chance by 5%." },
                    { name = "Flurry", points = 5, max = 5, icon = "Interface\\Icons\\Ability_GhoulFrenzy", desc = "Increases attack speed by 30% after dealing a critical strike." },
                    { name = "Weapon Mastery", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Warrior_WeaponMastery", desc = "Increases damage dealt by weapons by 10%." },
                    { name = "Stormstrike", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_SealOfMight", desc = "Instantly attacks with both weapons and increases nature damage." },
                    { name = "Elemental Weapons", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Fire_FlameBlades", desc = "Increases attack power bonus of Windfury Weapon by 40%." },
                },
            },
            {
                name = "Restoration", points = 19, icon = "Interface\\Icons\\Spell_Nature_MagicImmunity",
                milestones = {
                    { pts = 10, name = "Call of the Elements", active = true, desc = "Totem pulse radius increased and pulse intervals faster." },
                    { pts = 20, name = "Reincarnation", active = false, desc = "Upon death, rise again at half health." },
                    { pts = 30, name = "Totemic Wrath", active = false, desc = "All totems emit damaging shockwaves." },
                },
                talents = {
                    { name = "Tidal Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_ManaRecharge", desc = "Reduces mana cost and cooldown of healing." },
                    { name = "Ancestral Healing", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_UndyingStrength", desc = "Increases target armor by 25% on critical heal." },
                    { name = "Totemic Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_MoonKey", desc = "Reduces totem cooldowns by 25%." },
                    { name = "Healing Way", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_HealingWay", desc = "Increases healing of subsequent Healing Waves." },
                    { name = "Restorative Totems", points = 3, max = 5, icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", desc = "Increases effect of Mana and Healing totems by 25%." },
                },
            },
        },
    },

    shaman_totem_overlord = {
        summary = "22 / 12 / 17",
        trees = {
            {
                name = "Elemental", points = 22, icon = "Interface\\Icons\\Spell_Nature_Lightning",
                milestones = {
                    { pts = 10, name = "Lightning Overload", active = true, desc = "Lightning Bolt and Chain Lightning have a 25% chance to strike again for free." },
                    { pts = 20, name = "Elemental Fury", active = true, desc = "Chain Lightning jumps to 3 more enemies and loses nothing with each jump." },
                    { pts = 30, name = "Elemental Mastery", active = false, desc = "Start every run with Chain Lightning, and a 2nd casts every 3 sec." },
                },
                talents = {
                    { name = "Convection", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_WispSplode", desc = "Reduces cooldowns and mana costs of Shock and Lightning spells." },
                    { name = "Concussion", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Fire_Fireball", desc = "Increases damage of Shock and Lightning spells by 5%." },
                    { name = "Call of Flame", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Fire Nova, Magma Totem and Flame Shock deal 15% more damage." },
                    { name = "Elemental Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_ManaBurn", desc = "Clearcasting state reduces next spell cost to 0." },
                    { name = "Call of Thunder", points = 4, max = 5, icon = "Interface\\Icons\\Spell_Nature_CallStorm", desc = "Increases critical strike chance of Lightning spells by 5%." },
                    { name = "Eye of the Storm", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Nature_EyeOfTheStorm", desc = "Grants 100% pushback resistance on critical hit." },
                },
            },
            {
                name = "Enhancement", points = 12, icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                milestones = {
                    { pts = 10, name = "Windfury", active = true, desc = "Melee swings can proc extra hits with massive attack power bonus." },
                    { pts = 20, name = "Maelstrom Weapon", active = false, desc = "Reduces spell cast times." },
                    { pts = 30, name = "Feral Spirit", active = false, desc = "Summons spirit wolves." },
                },
                talents = {
                    { name = "Shield Specialization", points = 5, max = 5, icon = "Interface\\Icons\\INV_Shield_06", desc = "Increases block chance by 5% and block value by 25%." },
                    { name = "Guardian Totems", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem", desc = "Increases armor granted by Stoneskin Totem and reduces Grounding Totem CD." },
                    { name = "Thundering Strikes", points = 5, max = 5, icon = "Interface\\Icons\\Ability_ThunderBolt", desc = "Increases critical strike chance with all attacks by 5%." },
                },
            },
            {
                name = "Restoration", points = 17, icon = "Interface\\Icons\\Spell_Nature_MagicImmunity",
                milestones = {
                    { pts = 10, name = "Call of the Elements", active = true, desc = "Totem pulse radius increased and pulse intervals faster." },
                    { pts = 20, name = "Reincarnation", active = false, desc = "Upon death, rise again at half health." },
                    { pts = 30, name = "Totemic Wrath", active = false, desc = "All totems emit damaging shockwaves." },
                },
                talents = {
                    { name = "Tidal Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Frost_ManaRecharge", desc = "Reduces mana cost and cooldown of healing spells." },
                    { name = "Ancestral Healing", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_UndyingStrength", desc = "Increases target armor by 25% on critical heal." },
                    { name = "Totemic Focus", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_MoonKey", desc = "Reduces mana cost and cooldown of all totems by 25%." },
                    { name = "Healing Way", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_HealingWay", desc = "Increases healing of subsequent Healing Waves." },
                    { name = "Restorative Totems", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", desc = "Increases effect of Mana Spring and Healing Stream totems by 25%." },
                },
            },
        },
    },

    priest_shadow_melter = {
        summary = "14 / 0 / 37",
        trees = {
            {
                name = "Discipline", points = 14, icon = "Interface\\Icons\\Spell_Holy_WordFortitude",
                milestones = {
                    { pts = 10, name = "Divine Aegis", active = true, desc = "Start every run with Power Word: Shield; breaking bursts in holy light." },
                    { pts = 20, name = "Meditation", active = false, desc = "Mana regeneration continues while casting." },
                    { pts = 30, name = "Power Infusion", active = false, desc = "Infuses target with power, increasing spell damage by 20%." },
                },
                talents = {
                    { name = "Unbreakable Will", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Magic_MageArmor", desc = "Increases resistance to Stun, Fear, and Silence by 15%." },
                    { name = "Silent Resolve", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", desc = "Reduces threat and pushback." },
                    { name = "Improved Power Word: Shield", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_PowerWordShield", desc = "Increases damage absorbed by shield by 15%." },
                    { name = "Inner Focus", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Frost_WindWalkOn", desc = "Next spell cost 0 mana and +25% critical chance." },
                    { name = "Meditation", points = 2, max = 3, icon = "Interface\\Icons\\Spell_Nature_Sleep", desc = "Allows 10% of mana regeneration to continue while casting." },
                },
            },
            {
                name = "Holy", points = 0, icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
                milestones = {
                    { pts = 10, name = "Holy Nova", active = false, desc = "Burst of light damaging enemies and healing allies." },
                    { pts = 20, name = "Inspiration", active = false, desc = "Increases armor on critical heals." },
                    { pts = 30, name = "Spirit of Redemption", active = false, desc = "Become spirit upon death." },
                },
                talents = {},
            },
            {
                name = "Shadow", points = 37, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
                milestones = {
                    { pts = 10, name = "Mind Flay", active = true, desc = "Assaults enemy mind with shadow damage and slows movement." },
                    { pts = 20, name = "Vampiric Embrace", active = true, desc = "Afflicts target with shadow energy; 20% of shadow damage heals party." },
                    { pts = 30, name = "Shadowform", active = true, desc = "Assume a Shadowform, increasing shadow damage dealt by 15%." },
                },
                talents = {
                    { name = "Spirit Tap", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Requiem", desc = "Gives 100% bonus to Spirit after killing an enemy." },
                    { name = "Darkness", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_Twilight", desc = "Increases Shadow spell damage by 10%." },
                    { name = "Shadow Affinity", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_ShadowWard", desc = "Reduces threat generated by Shadow spells." },
                    { name = "Shadow Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_BurningSpirit", desc = "Reduces chance enemies resist Shadow spells by 10%." },
                    { name = "Improved Mind Blast", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy", desc = "Reduces cooldown of Mind Blast by 2.5 sec." },
                    { name = "Mind Flay", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_SiphonMana", desc = "Continuous beam of shadow slowing and shredding target." },
                    { name = "Shadow Reach", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_ChillTouch", desc = "Increases range of Shadow spells by 20%." },
                    { name = "Shadow Weaving", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Shadow_BlackPlague", desc = "Shadow damage increases target shadow vulnerability by up to 15%." },
                    { name = "Silence", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift", desc = "Silences enemy, preventing all spellcasting." },
                    { name = "Vampiric Embrace", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding", desc = "Shadow spells heal you for 20% of damage dealt." },
                    { name = "Darkness Master", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Shadow_Shadowform", desc = "Increases periodic tick speed of Shadow Word: Pain." },
                },
            },
        },
    },

    priest_holy_smiter = {
        summary = "20 / 31 / 0",
        trees = {
            {
                name = "Discipline", points = 20, icon = "Interface\\Icons\\Spell_Holy_WordFortitude",
                milestones = {
                    { pts = 10, name = "Divine Aegis", active = true, desc = "Start every run with Power Word: Shield; breaking bursts in holy light." },
                    { pts = 20, name = "Meditation", active = true, desc = "Mana regeneration continues while casting." },
                    { pts = 30, name = "Power Infusion", active = false, desc = "Increases spell damage by 20%." },
                },
                talents = {
                    { name = "Wand Specialization", points = 5, max = 5, icon = "Interface\\Icons\\INV_Wand_01", desc = "Increases damage with Wands by 25%." },
                    { name = "Silent Resolve", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", desc = "Reduces threat generated by spells." },
                    { name = "Improved Fortitude", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_WordFortitude", desc = "Increases effect of Power Word: Fortitude by 30%." },
                    { name = "Inner Focus", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Frost_WindWalkOn", desc = "Next spell cost 0 mana and +25% critical chance." },
                    { name = "Meditation", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_Sleep", desc = "Allows 15% of mana regeneration while casting." },
                    { name = "Mental Agility", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Hibernation", desc = "Reduces mana cost of instant cast spells by 10%." },
                    { name = "Mental Strength", points = 1, max = 5, icon = "Interface\\Icons\\Spell_Nature_EnchantArmor", desc = "Increases maximum mana by 2%." },
                },
            },
            {
                name = "Holy", points = 31, icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
                milestones = {
                    { pts = 10, name = "Holy Nova", active = true, desc = "A Holy Nova bursts from you on its own every 24 sec." },
                    { pts = 20, name = "Inspiration", active = true, desc = "Increases target armor by 25% for 15 sec after a crit heal." },
                    { pts = 30, name = "Spiritual Guidance", active = true, desc = "Increases spell damage and healing by 25% of your Spirit." },
                },
                talents = {
                    { name = "Holy Specialization", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_SealOfSalvation", desc = "Increases critical strike chance of Holy spells by 5%." },
                    { name = "Divine Fury", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_SealOfWrath", desc = "Reduces cast time of Smite and Holy Fire by 0.5 sec." },
                    { name = "Holy Nova", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Holy_HolyNova", desc = "Radial explosion of holy light damaging all nearby monsters." },
                    { name = "Searing Light", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_SearingLightPriest", desc = "Increases damage of Smite and Holy Fire by 10%." },
                    { name = "Inspiration", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_LayOnHands", desc = "Increases armor on critical heal by 25%." },
                    { name = "Holy Reach", points = 2, max = 2, icon = "Interface\\Icons\\Spell_Holy_Purify", desc = "Increases range of Smite and radius of Holy Nova by 20%." },
                    { name = "Spiritual Guidance", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Holy_SpiritualGuidence", desc = "Increases spell damage and healing by 25% of Spirit." },
                    { name = "Spiritual Healing", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_MoonGlow", desc = "Increases amount healed by spells by 10%." },
                    { name = "Lightwell", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Holy_SummonLightwell", desc = "Creates a healing lightwell." },
                },
            },
            {
                name = "Shadow", points = 0, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
                milestones = {
                    { pts = 10, name = "Mind Flay", active = false, desc = "Assaults enemy mind." },
                    { pts = 20, name = "Vampiric Embrace", active = false, desc = "Heals from shadow damage." },
                    { pts = 30, name = "Shadowform", active = false, desc = "Increases shadow damage by 15%." },
                },
                talents = {},
            },
        },
    },

    druid_balance_hurricane = {
        summary = "31 / 0 / 20",
        trees = {
            {
                name = "Balance", points = 31, icon = "Interface\\Icons\\Spell_Nature_StarFall",
                milestones = {
                    { pts = 10, name = "Omen of Clarity", active = true, desc = "Every spell cast has an 11% chance to call down a free Starfire." },
                    { pts = 20, name = "Moonkin Form", active = true, desc = "Stars fall around you: a free Starfire strikes every 4 sec." },
                    { pts = 30, name = "Starfall", active = true, desc = "Hurricane reaches 50% farther and calls relentless lunar strikes." },
                },
                talents = {
                    { name = "Nature's Grasp", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_NaturesWrath", desc = "When struck, chance to entangle attacker in roots." },
                    { name = "Improved Nature's Grasp", points = 4, max = 4, icon = "Interface\\Icons\\Spell_Nature_NaturesWrath", desc = "Increases trigger chance of Nature's Grasp by 65%." },
                    { name = "Starlight Wrath", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_AbolishPoison", desc = "Reduces cast time of Wrath and Starfire by 0.5 sec." },
                    { name = "Improved Moonfire", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_StarFall", desc = "Increases damage and critical strike chance of Moonfire by 10%." },
                    { name = "Brambles", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_Thorns", desc = "Increases damage dealt by Thorns and Entangling Roots by 75%." },
                    { name = "Vengeance", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_Purge", desc = "Increases critical strike damage bonus of Starfire and Wrath by 100%." },
                    { name = "Nature's Grace", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_NaturesBlessing", desc = "Spell critical strikes reduce cast time of next spell by 0.5 sec." },
                    { name = "Moonglow", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_Sentinal", desc = "Reduces mana cost of Moonfire, Starfire, and Wrath by 9%." },
                    { name = "Moonkin Form", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_ForceOfNature", desc = "Increases spell critical strike chance of all nearby allies by 3%." },
                    { name = "Nature's Reach", points = 3, max = 3, icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow", desc = "Increases range of Balance spells by 20%." },
                },
            },
            {
                name = "Feral", points = 0, icon = "Interface\\Icons\\Ability_Racial_BearForm",
                milestones = {
                    { pts = 10, name = "Feral Charge", active = false, desc = "Charges enemy, immobilizing them." },
                    { pts = 20, name = "Faerie Fire (Feral)", active = false, desc = "Decreases enemy armor." },
                    { pts = 30, name = "Leader of the Pack", active = false, desc = "Increases critical strike chance." },
                },
                talents = {},
            },
            {
                name = "Restoration", points = 20, icon = "Interface\\Icons\\Spell_Nature_HealingTouch",
                milestones = {
                    { pts = 10, name = "Swiftmend", active = true, desc = "Falling below 40% health makes a free Regrowth bloom on you." },
                    { pts = 20, name = "Tranquility", active = true, desc = "Every heal you cast also strikes every enemy within 12 yd for Nature damage." },
                    { pts = 30, name = "Gift of Nature", active = false, desc = "Increases all healing effects by 10%." },
                },
                talents = {
                    { name = "Furor", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_Unregenerate", desc = "Gives 100% chance to gain 10 Rage or 40 Energy when shapeshifting." },
                    { name = "Nature's Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater", desc = "70% chance to avoid interruption while casting healing spells." },
                    { name = "Subtlety", points = 5, max = 5, icon = "Interface\\Icons\\Ability_EyeOfTheOwl", desc = "Reduces threat and pushback from healing spells by 20%." },
                    { name = "Omen of Clarity", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_CrystalBall", desc = "Enter Clearcasting state on attacks, reducing cost to 0." },
                    { name = "Gift of Nature", points = 4, max = 5, icon = "Interface\\Icons\\Spell_Nature_ProtectionformNature", desc = "Increases the effect of all healing spells by 8%." },
                },
            },
        },
    },

    druid_feral_shredder = {
        summary = "0 / 32 / 19",
        trees = {
            {
                name = "Balance", points = 0, icon = "Interface\\Icons\\Spell_Nature_StarFall",
                milestones = {
                    { pts = 10, name = "Omen of Clarity", active = false, desc = "Chance to grant free Starfire." },
                    { pts = 20, name = "Moonkin Form", active = false, desc = "Free Starfire every 4 sec." },
                    { pts = 30, name = "Starfall", active = false, desc = "Hurricane reaches 50% farther." },
                },
                talents = {},
            },
            {
                name = "Feral", points = 32, icon = "Interface\\Icons\\Ability_Racial_BearForm",
                milestones = {
                    { pts = 10, name = "Thick Hide", active = true, desc = "20% more max health and 8% less damage taken; start with Swipe and Shred." },
                    { pts = 20, name = "Blood Frenzy", active = true, desc = "Critical strikes rip the target open, causing bleed for 6 sec." },
                    { pts = 30, name = "Leader of the Pack", active = true, desc = "Increases melee and ranged critical strike chance of all party members by 3%." },
                },
                talents = {
                    { name = "Ferocity", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Hunter_Pet_Hyena", desc = "Reduces the cost of Maul, Swipe, Claw, and Rake by 5." },
                    { name = "Feral Aggression", points = 5, max = 5, icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar", desc = "Increases attack power reduction and Ferocious Bite damage by 15%." },
                    { name = "Brutal Impact", points = 2, max = 2, icon = "Interface\\Icons\\Ability_Druid_Bash", desc = "Increases the stun duration of Bash and Pounce by 1 sec." },
                    { name = "Thick Hide", points = 5, max = 5, icon = "Interface\\Icons\\INV_Misc_Pelt_Bear_03", desc = "Increases armor contribution from items by 10%." },
                    { name = "Feral Charge", points = 1, max = 1, icon = "Interface\\Icons\\Ability_Hunter_Pet_Bear", desc = "Causes you to charge an enemy, immobilizing them." },
                    { name = "Sharpened Claws", points = 3, max = 3, icon = "Interface\\Icons\\INV_Misc_MonsterClaw_04", desc = "Increases critical strike chance in Bear and Cat forms by 6%." },
                    { name = "Predatory Strikes", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Hunter_Pet_Cat", desc = "Increases attack power in Cat and Bear forms by 150% of level." },
                    { name = "Primal Fury", points = 2, max = 2, icon = "Interface\\Icons\\Ability_Racial_Cannibalize", desc = "Critical strikes in Cat form add an extra combo point." },
                    { name = "Savage Fury", points = 2, max = 2, icon = "Interface\\Icons\\Ability_Druid_Ravage", desc = "Increases the damage dealt by Claw, Rake, and Mangle by 20%." },
                    { name = "Faerie Fire (Feral)", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_FaerieFire", desc = "Decreases enemy armor and prevents stealth." },
                    { name = "Heart of the Wild", points = 3, max = 5, icon = "Interface\\Icons\\Spell_Holy_BlessingOfAgility", desc = "Increases total Stamina by 12% and Strength by 12%." },
                },
            },
            {
                name = "Restoration", points = 19, icon = "Interface\\Icons\\Spell_Nature_HealingTouch",
                milestones = {
                    { pts = 10, name = "Swiftmend", active = true, desc = "Falling below 40% health makes a free Regrowth bloom on you." },
                    { pts = 20, name = "Tranquility", active = false, desc = "Heals strike enemies for Nature damage." },
                    { pts = 30, name = "Gift of Nature", active = false, desc = "Increases all healing effects." },
                },
                talents = {
                    { name = "Furor", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_Unregenerate", desc = "Gives 100% chance to gain 10 Rage or 40 Energy when shapeshifting." },
                    { name = "Nature's Focus", points = 5, max = 5, icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater", desc = "70% chance to avoid interruption while casting healing spells." },
                    { name = "Subtlety", points = 5, max = 5, icon = "Interface\\Icons\\Ability_EyeOfTheOwl", desc = "Reduces threat and pushback from healing spells by 20%." },
                    { name = "Omen of Clarity", points = 1, max = 1, icon = "Interface\\Icons\\Spell_Nature_CrystalBall", desc = "Enter Clearcasting state on attacks, reducing cost to 0." },
                    { name = "Improved Enrage", points = 3, max = 3, icon = "Interface\\Icons\\Ability_Druid_Enrage", desc = "Enrage instantly generates 15 Rage." },
                },
            },
        },
    },
};

-- Bind talents to each build in BordoUI_BuildData.Builds
for classKey, classBuildList in pairs(BordoUI_BuildData.Builds) do
    for bIdx = 1, table.getn(classBuildList) do
        local b = classBuildList[bIdx];
        if b and b.id and TALENT_DB[b.id] then
            b.talents = TALENT_DB[b.id];
        end
    end
end

-- ============================================================================
-- BORDOUI MASTER CATALOG: ALL CLASS SPELLS & JEWELRY / TRINKETS FOR CUSTOM BUILDS
-- ============================================================================
BordoUI_Catalog = {};

BordoUI_Catalog.Spells = {
    PALADIN = {
        { name = "Consecration", key = "consecration", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_InnerFire", desc = "Core persistent holy field. Damages all enemies walking through it." },
        { name = "Holy Wrath", key = "holy_wrath", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_Excorcism", desc = "Radial holy blast. Delivers massive damage and brief stuns to demons and undead." },
        { name = "Judgement", key = "judgement", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_RighteousFury", desc = "Frequent targeted holy burst with short cooldown." },
        { name = "Exorcism", key = "exorcism", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_Excorcism_02", desc = "Heavy direct holy nuke that deals bonus damage against undead." },
        { name = "Hammer of Wrath", key = "hammer_of_wrath", school = "Holy", icon = "Interface\\Icons\\Ability_ThunderClap", desc = "The holy execute hammer. Deals gigantic damage to enemies below 20% HP." },
        { name = "Hammer of Justice", key = "hammer_of_justice", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_SealOfMight", desc = "Essential 5-second stun to lock down charging elites and interrupt dangerous casts." },
        { name = "Holy Shield", key = "holy_shield", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection", desc = "Increases block chance and retaliates with holy damage whenever an attack is blocked." },
        { name = "Holy Shock", key = "holy_shock", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_SearingLight", desc = "Instant holy energy burst that blasts enemies and can leap to extra targets." },
        { name = "Holy Light", key = "holy_light", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_HolyBolt", desc = "Core holy healing wave that refills massive chunks of health." },
        { name = "Divine Shield", key = "divine_shield", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_DivineIntervention", desc = "Complete invulnerability bubble protecting you from all damage." },
        { name = "Redemption", key = "redemption", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_Resurrection", desc = "Empowered holy light that blasts surrounding foes and restores massive health." },
    },
    WARRIOR = {
        { name = "Whirlwind", school = "Physical", icon = "Interface\\Icons\\Ability_Whirlwind", desc = "Core spinning attack hitting all surrounding targets in a 360-degree radius." },
        { name = "Cleave", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_Cleave", desc = "Sweeping strike that cuts through multiple foes in front of you." },
        { name = "Mortal Strike", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_SavageBlow", desc = "Primary weapon nuke delivering high base physical damage and mortal wounds." },
        { name = "Bloodthirst", school = "Physical", icon = "Interface\\Icons\\Spell_Nature_BloodLust", desc = "Instantly attacks the target and heals for a percentage of maximum health." },
        { name = "Shield Slam", school = "Physical", icon = "Interface\\Icons\\INV_Shield_05", desc = "Bashes target for massive physical damage scaled by your shield block value." },
        { name = "Execute", school = "Physical", icon = "Interface\\Icons\\INV_Sword_48", desc = "Devastating execution blow against wounded enemies below 20% health." },
        { name = "Revenge", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_Revenge", desc = "Counterattack triggered by blocking, dodging or parrying." },
        { name = "Thunder Clap", school = "Physical", icon = "Interface\\Icons\\Spell_Nature_ThunderClap", desc = "Blasts the ground, damaging nearby enemies and slowing their attack speed." },
        { name = "Rend", school = "Physical", icon = "Interface\\Icons\\Ability_Gouge", desc = "Wounds the target causing severe bleeding over several seconds." },
        { name = "Battle Shout", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_WarCry", desc = "Increases attack power of you and all nearby allies." },
        { name = "Shield Block", school = "Physical", icon = "Interface\\Icons\\Ability_Defensivestate", desc = "Raises block chance by 100%, absorbing physical damage." },
        { name = "Sweeping Strikes", school = "Physical", icon = "Interface\\Icons\\Ability_Rogue_SliceDice", desc = "Causes your next attacks to strike an additional nearby enemy." },
        { name = "Overpower", school = "Physical", icon = "Interface\\Icons\\Ability_MeleeDamage", desc = "Unavoidable counter-strike when an enemy dodges your attack." },
        { name = "Slam", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike", desc = "Heavy focused overhead swing dealing high single-target damage." },
    },
    HUNTER = {
        { name = "Volley", school = "Arcane", icon = "Interface\\Icons\\Ability_Marksmanship", desc = "Continuously rains arrows in a large radius, decimating dense enemy packs." },
        { name = "Aimed Shot", school = "Physical", icon = "Interface\\Icons\\INV_Spear_07", desc = "Premier boss killing nuke. High multiplier dealing colossal single-target chunks." },
        { name = "Multi-Shot", school = "Physical", icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive", desc = "Fires a volley of 3 arrows, hitting multiple enemies simultaneously." },
        { name = "Serpent Sting", school = "Nature", icon = "Interface\\Icons\\Ability_Hunter_Quickshot", desc = "Stings the target, dealing nature damage over 15 seconds." },
        { name = "Explosive Trap", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", desc = "Places a fire trap that detonates, creating a persistent fire ring." },
        { name = "Immolation Trap", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Detonates for heavy initial fire damage and ignites targets." },
        { name = "Frost Trap", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_FreezingBreath", desc = "Creates an ice slick that heavily slows all entering enemies." },
        { name = "Arcane Shot", school = "Arcane", icon = "Interface\\Icons\\Ability_ImpalingBolt", desc = "An instant shot that causes arcane damage to the target." },
        { name = "Concussive Shot", school = "Physical", icon = "Interface\\Icons\\Spell_Frost_Stun", desc = "Dazes the target, slowing its movement speed by 50%." },
        { name = "Rapid Fire", school = "Physical", icon = "Interface\\Icons\\Ability_Hunter_RunningShot", desc = "Increases ranged attack speed by 40% for 15 seconds." },
    },
    MAGE = {
        { name = "Blizzard", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_IceStorm", desc = "Screen-wide ice storm heavily slowing all approaching mobs with continuous damage." },
        { name = "Cone of Cold", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_Glacier", desc = "Short-range frontal cone frost burst that freezes and slows advancing waves." },
        { name = "Frostbolt", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_FrostBolt02", desc = "Single-target frost projectile dealing heavy damage and slowing movement." },
        { name = "Flamestrike", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", desc = "Pillar of fire that deals massive initial burst and leaves burning ground." },
        { name = "Pyroblast", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_Fireball02", desc = "Giant fiery boulder that deals catastrophic damage and burns over time." },
        { name = "Fireball", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_FlameBolt", desc = "Classic incendiary projectile that burns for lingering fire damage." },
        { name = "Blast Wave", school = "Fire", icon = "Interface\\Icons\\Spell_Holy_Excorcism_02", desc = "Radial wave of flame detonating around you, dazing all enemies hit." },
        { name = "Arcane Missiles", school = "Arcane", icon = "Interface\\Icons\\Spell_Nature_StarFall", desc = "Channels a stream of arcane missiles into target with no travel delay." },
        { name = "Arcane Explosion", school = "Arcane", icon = "Interface\\Icons\\Spell_Nature_WispSplode", desc = "Instant blast of arcane magic dealing damage to all nearby enemies." },
        { name = "Scorch", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SoulBurn", desc = "Fast-casting fire spell that stacks Fire vulnerability on the target." },
        { name = "Frost Nova", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_FrostNova", desc = "Blasts nearby enemies for frost damage and freezes them in place for 8 sec." },
        { name = "Ice Barrier", school = "Frost", icon = "Interface\\Icons\\Spell_Ice_Lament", desc = "Instantly shields you with a thick frost barrier absorbing incoming damage." },
    },
    WARLOCK = {
        { name = "Corruption", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", desc = "Core shadow curse ticking relentless damage while feeding passives." },
        { name = "Curse of Agony", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras", desc = "Curse of increasing agony that ramps up damage over time." },
        { name = "Shadow Bolt", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt", desc = "Premier shadow projectile hitting hard and applying Shadow Vulnerability." },
        { name = "Drain Life", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02", desc = "Core channeled siphon dealing continuous damage while refilling health." },
        { name = "Siphon Life", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_Requiem", desc = "Persistent leech pulling health from target to restore your pool." },
        { name = "Death Coil", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_DeathCoil", desc = "Emergency life drain and fear that instantly heals you." },
        { name = "Hellfire", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_Incinerate", desc = "High-frequency radial inferno vaporizing all enemies in close quarters." },
        { name = "Rain of Fire", school = "Fire", icon = "Interface\\Icons\\Spell_Shadow_RainOfFire", desc = "Fiery meteors raining down continuously in a designated target zone." },
        { name = "Immolate", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_Immolation", desc = "Burns the enemy for initial fire damage plus periodic burn." },
        { name = "Searing Pain", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SoulBurn", desc = "Instant searing blast with high critical strike chance." },
        { name = "Soulfire", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_Fireball02", desc = "Massive demon flame nuke incinerating target for colossal single-hit damage." },
    },
    ROGUE = {
        { name = "Blade Flurry", school = "Physical", icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow", desc = "Core cleave ability causing melee attacks to strike adjacent enemies." },
        { name = "Sinister Strike", school = "Physical", icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice", desc = "Primary combo generator delivering reliable physical weapon strikes." },
        { name = "Eviscerate", school = "Physical", icon = "Interface\\Icons\\Ability_Rogue_Eviscerate", desc = "Finishing move that unloads combo points for catastrophic burst damage." },
        { name = "Backstab", school = "Physical", icon = "Interface\\Icons\\Ability_BackStab", desc = "Extreme critical damage attack when striking enemies from behind." },
        { name = "Ambush", school = "Physical", icon = "Interface\\Icons\\Ability_Rogue_Ambush", desc = "Devastating opening strike from stealth dealing lethal critical damage." },
        { name = "Slice and Dice", school = "Physical", icon = "Interface\\Icons\\Ability_Rogue_SliceDice", desc = "Increases melee attack speed by 30% for high sustained DPS." },
        { name = "Rupture", school = "Physical", icon = "Interface\\Icons\\Ability_Rogue_Rupture", desc = "Finishing move causing targets to bleed heavily over time." },
        { name = "Hemorrhage", school = "Physical", icon = "Interface\\Icons\\Spell_Shadow_LifeDrain", desc = "Physical strike causing target to take additional damage from all physical sources." },
        { name = "Gouge", school = "Physical", icon = "Interface\\Icons\\Ability_Gouge", desc = "Gouges the enemy's eyes, incapacitating them for up to 5.5 seconds." },
        { name = "Ghostly Strike", school = "Physical", icon = "Interface\\Icons\\Spell_Shadow_Curse", desc = "Strikes the enemy and increases your dodge chance by 15%." },
        { name = "Adrenaline Rush", school = "Physical", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate", desc = "Increases energy regeneration and attack tempo by 100%." },
    },
    SHAMAN = {
        { name = "Chain Lightning", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_ChainLightning", desc = "Core bouncing lightning strike that arcs across multiple enemies." },
        { name = "Lightning Bolt", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_Lightning", desc = "Cast of pure electrical energy dealing heavy single-target nature damage." },
        { name = "Earth Shock", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_EarthShock", desc = "Instant shock dealing nature damage and interrupting enemy spellcasting." },
        { name = "Flame Shock", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_FlameShock", desc = "Instant shock burning target for fire damage and periodic burn." },
        { name = "Frost Shock", school = "Frost", icon = "Interface\\Icons\\Spell_Frost_FrostShock", desc = "Instant frost blast slowing target movement speed by 50%." },
        { name = "Magma Totem", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", desc = "Pulsating fire AoE totem emitting radial fire pulses that incinerate mobs." },
        { name = "Searing Totem", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SearingTotem", desc = "Summons a stationary totem that fires continuous searing fire bolts." },
        { name = "Fire Nova", school = "Fire", icon = "Interface\\Icons\\Spell_Fire_SealOfFire", desc = "Causes your active fire totem to detonate with a massive nova wave." },
        { name = "Stormstrike", school = "Physical", icon = "Interface\\Icons\\Spell_Holy_SealOfMight", desc = "Double weapon strike granting +20% nature damage debuff on target." },
        { name = "Windfury", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_Cyclone", desc = "Imbues your weapon for a chance to unleash 2 extra instant attacks." },
        { name = "Lightning Shield", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_LightningShield", desc = "Surrounds you with lightning orbs that shock attackers." },
        { name = "Healing Wave", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_MagicImmunity", desc = "Heals you for a significant amount of lost health." },
    },
    PRIEST = {
        { name = "Shadow Word: Pain", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", desc = "Core shadow DoT spreading across approaching enemies, ticking down life." },
        { name = "Mind Flay", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_SiphonMana", desc = "Channels shadow energy to assault the mind, slowing movement by 50%." },
        { name = "Mind Blast", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy", desc = "High-damage shadow burst dealing critical direct damage." },
        { name = "Devouring Plague", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_BlackPlague", desc = "Vile disease afflicting target for continuous shadow damage." },
        { name = "Holy Nova", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_HolyNova", desc = "Core radial burst dealing holy damage to all enemies and healing simultaneously." },
        { name = "Smite", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_HolySmite", desc = "Direct holy beam dealing focused single-target holy damage." },
        { name = "Holy Fire", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_SearingLight", desc = "Engulfs target in holy flames with heavy direct and lingering damage." },
        { name = "Power Word: Shield", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_PowerWordShield", desc = "Draws on the soul of the friendly target to shield them from all damage." },
        { name = "Renew", school = "Holy", icon = "Interface\\Icons\\Spell_Holy_Renew", desc = "Heals target over 15 seconds, providing persistent survival." },
        { name = "Psychic Scream", school = "Shadow", icon = "Interface\\Icons\\Spell_Shadow_PsychicScream", desc = "Emits a psychic scream, causing 5 nearby enemies to flee in terror." },
    },
    DRUID = {
        { name = "Hurricane", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_Cyclone", desc = "Screen-wide swirling tempest slowing enemy move speed and dealing rapid nature damage." },
        { name = "Moonfire", school = "Arcane", icon = "Interface\\Icons\\Spell_Nature_StarFall", desc = "Instant lunar strike dealing arcane damage and burning over 12 seconds." },
        { name = "Starfire", school = "Arcane", icon = "Interface\\Icons\\Spell_Arcane_StarFire", desc = "Calls down a heavy celestial blast dealing catastrophic arcane damage." },
        { name = "Wrath", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_AbolishPoison", desc = "Quick nature bolt that continuously chips away at advancing foes." },
        { name = "Swipe", school = "Physical", icon = "Interface\\Icons\\INV_Misc_MonsterClaw_03", desc = "Bear form claw swipe hitting multiple surrounding enemies." },
        { name = "Shred", school = "Physical", icon = "Interface\\Icons\\Spell_Shadow_VampiricAura", desc = "Cat form claw strike dealing extreme damage from behind targets." },
        { name = "Rip", school = "Physical", icon = "Interface\\Icons\\Ability_GhoulFrenzy", desc = "Finishing move causing target to bleed for heavy physical damage." },
        { name = "Rake", school = "Physical", icon = "Interface\\Icons\\Ability_Druid_Disembowel", desc = "Rakes the target for bleed damage over 9 seconds." },
        { name = "Ferocious Bite", school = "Physical", icon = "Interface\\Icons\\Ability_Druid_FerociousBite", desc = "Cat finisher biting target with raw kinetic force." },
        { name = "Barkskin", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem", desc = "Turns skin as tough as bark, reducing all damage taken by 20%." },
        { name = "Entangling Roots", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_StrangleVines", desc = "Roots target in place, rendering them completely immobile." },
        { name = "Thorns", school = "Nature", icon = "Interface\\Icons\\Spell_Nature_Thorns", desc = "Sprouts thorns on you that retaliate with nature damage when struck." },
    },
};

BordoUI_Catalog.Jewelry = {
    -- UNIVERSAL NECKLACES (Authentic Azeroth Survivors Codex)
    { slotType = "NECK", name = "Amulet of Vek'nilash", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_01", quality = 4, benefit = "Spells: +1 Target, +5% Dmg", desc = "Your spells: +1 target\n+5% damage" },
    { slotType = "NECK", name = "Amulet of the Darkmoon", icon = "Interface\\Icons\\INV_Jewelry_Necklace_14", quality = 2, benefit = "-12% Cooldowns, +8% Spd", desc = "-12% cooldowns\n+8% movement speed" },
    { slotType = "NECK", name = "Animated Chain Necklace", icon = "Interface\\Icons\\INV_Jewelry_Necklace_01", quality = 2, benefit = "+25% Max HP, +8% Dmg Red", desc = "+25% max health\n+8% damage reduction" },
    { slotType = "NECK", name = "Choker of Enlightenment", icon = "Interface\\Icons\\INV_Jewelry_Necklace_10", quality = 4, benefit = "Hits leap to 1 more for 30%", desc = "Your hits leap to 1 more enemy for 30%" },
    { slotType = "NECK", name = "Choker of the Fire Lord",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_05", quality = 5, benefit = "Kills explode for 15% HP", desc = "Enemies you kill explode for 15% of their max health" },
    { slotType = "NECK", name = "Jeklik's Opaline Talisman", icon = "Interface\\Icons\\INV_Jewelry_Necklace_03", quality = 3, benefit = "3% Leech, +1.0 Heal on Kill", desc = "3% of damage dealt heals\nEach kill heals 1.0" },
    { slotType = "NECK", name = "Malice Stone Pendant", icon = "Interface\\Icons\\INV_Jewelry_Necklace_29", quality = 4, benefit = "20% Cast Twice, -8% CD", desc = "20% chance to cast twice\n-8% cooldowns" },
    { slotType = "NECK", name = "Mark of Fordring", icon = "Interface\\Icons\\INV_Jewelry_Talisman_07", quality = 1, benefit = "+15% Damage", desc = "+15% damage" },
    { slotType = "NECK", name = "Medallion of Steadfast Might",
                    icon = "Interface\\Icons\\INV_Jewelry_Amulet_03", quality = 3, benefit = "+10% Red, +15% HP, Thorns", desc = "+10% damage reduction\n+15% max health\nMelee attackers take 100% of their damage" },
    { slotType = "NECK", name = "Onyxia Tooth Pendant",
                    icon = "Interface\\Icons\\INV_Jewelry_Necklace_09", quality = 5, benefit = "+4% Crit, +20% Crit Dmg, Splash", desc = "+4% critical strike\n+20% critical strike damage\nCrits splash 30% within 5 yd" },
    { slotType = "NECK", name = "Pendant of the Fallen Dragon", icon = "Interface\\Icons\\INV_Jewelry_Necklace_12", quality = 4, benefit = "Cheat Death 60s, +20% HP, +5 HP/s", desc = "A killing blow leaves you at 50% health, once every 60 sec\n+20% max health\n+5.0 health per second" },
    { slotType = "NECK", name = "Prestor's Talisman of Connivery", icon = "Interface\\Icons\\INV_Jewelry_Necklace_17", quality = 2, benefit = "+16% Damage, +4% Crit", desc = "+16% damage\n+4% critical strike" },
    { slotType = "NECK", name = "Pristine Enchanted South Seas Kelp", icon = "Interface\\Icons\\INV_Jewelry_Necklace_26", quality = 1, benefit = "+30% Luck, +25% Gold", desc = "+30% luck\n+25% gold" },
    { slotType = "NECK", name = "Talvash's Enhancing Necklace", icon = "Interface\\Icons\\INV_Jewelry_Necklace_02", quality = 1, benefit = "-10% Cooldowns", desc = "-10% cooldowns" },
    { slotType = "NECK", name = "The Eye of Hakkar", icon = "Interface\\Icons\\INV_Jewelry_Necklace_22", quality = 3, benefit = "+5% Crit, Crits burn/bleed 80%", desc = "+5% critical strike\nCrits burn and bleed for 80% more over 4 sec" },
    { slotType = "NECK", name = "Woven Ivy Necklace", icon = "Interface\\Icons\\INV_Misc_Herb_15", quality = 2, benefit = "+6.0 HP/s, +12% HP, +12% Spd", desc = "+6.0 health per second\n+12% max health\n+12% movement speed" },

    -- UNIVERSAL RINGS (Authentic Azeroth Survivors Codex - Base Rank I)
    { slotType = "RING", name = "Archimtiros' Ring of Reckoning",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_40", quality = 3, benefit = "+4.4% Dmg Red, +18% Max HP", desc = "+4.4% damage reduction, +18% max health" },
    { slotType = "RING", name = "Band of Accuria",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_03", quality = 4, benefit = "+26% Damage", desc = "+26% damage" },
    { slotType = "RING", name = "Blooddrinker's Band",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_49", quality = 3, benefit = "1.5% Leech", desc = "1.5% of damage dealt heals" },
    { slotType = "RING", name = "Heavy Dark Iron Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_14", quality = 2, benefit = "+25% Max HP", desc = "+25% max health" },
    { slotType = "RING", name = "Master Dragonslayer's Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_41", quality = 4, benefit = "+6% Critical Strike", desc = "+6% critical strike chance" },
    { slotType = "RING", name = "Quick Strike Ring",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_07", quality = 4, benefit = "-14% Cooldowns", desc = "-14% cooldowns" },
    { slotType = "RING", name = "Ring of Spell Power",
                    icon = "Interface\\Icons\\INV_Jewelry_Ring_38", quality = 3, benefit = "+21% Area of Effect", desc = "+21% area of effect" },
    { slotType = "RING", name = "Ring of the Devoured", icon = "Interface\\Icons\\INV_Jewelry_Ring_AhnQiraj_05", quality = 4, benefit = "+2.2 Health/sec", desc = "+2.2 health per second" },
    { slotType = "RING", name = "Seal of the Damned", icon = "Interface\\Icons\\INV_Jewelry_Ring_51", quality = 4, benefit = "Faster DoT ticks", desc = "Faster damage over time" },

    -- UNIVERSAL TRINKETS (Authentic Azeroth Survivors Codex - Base Rank I)
    { slotType = "TRINKET", name = "Blackhand's Breadth",
                    icon = "Interface\\Icons\\INV_Misc_ArmorKit_09", quality = 3, benefit = "+29% Critical Strike Damage", desc = "+29% critical strike damage" },
    { slotType = "TRINKET", name = "Carrot on a Stick", icon = "Interface\\Icons\\INV_Misc_Food_54", quality = 2, benefit = "+12% Movement Speed", desc = "+12% movement speed" },
    { slotType = "TRINKET", name = "Earthstrike",
                    icon = "Interface\\Icons\\Spell_Nature_AbolishMagic", quality = 4, benefit = "+20% Damage", desc = "+20% damage" },
    { slotType = "TRINKET", name = "Gnomish Universal Remote", icon = "Interface\\Icons\\INV_Misc_Gear_08", quality = 2, benefit = "+52% Pickup Range", desc = "+52% pickup range" },
    { slotType = "TRINKET", name = "Hand of Justice",
                    icon = "Interface\\Icons\\INV_Jewelry_Talisman_01", quality = 4, benefit = "9% Chance to Cast Twice", desc = "9% chance to cast twice" },
    { slotType = "TRINKET", name = "Horn of the Warchief", icon = "Interface\\Icons\\INV_Misc_Horn_01", quality = 3, benefit = "Buffs 22% Stronger", desc = "Buffs 22% stronger" },
    { slotType = "TRINKET", name = "Insignia of the Horde", icon = "Interface\\Icons\\INV_Jewelry_TrinketPVP_02", quality = 3, benefit = "+18% Experience", desc = "+18% experience" },
    { slotType = "TRINKET", name = "Lifegiving Gem",
                    icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05", quality = 4, benefit = "+20% Max HP", desc = "+20% max health" },
    { slotType = "TRINKET", name = "Major Soulstone", icon = "Interface\\Icons\\INV_Misc_Orb_04", quality = 4, benefit = "+1 Return to Life", desc = "+1 return to life" },
    { slotType = "TRINKET", name = "Mark of the Chosen", icon = "Interface\\Icons\\INV_Jewelry_Talisman_08", quality = 2, benefit = "+22% Luck", desc = "+22% luck" },
    { slotType = "TRINKET", name = "Onyxia Blood Talisman", icon = "Interface\\Icons\\Spell_Shadow_LifeDrain", quality = 4, benefit = "Each kill heals 3.0", desc = "Each kill heals 3.0" },
    { slotType = "TRINKET", name = "Royal Seal of Eldre'Thalas", icon = "Interface\\Icons\\INV_Jewelry_Talisman_10", quality = 3, benefit = "+38% Gold", desc = "+38% gold" },
    { slotType = "TRINKET", name = "Star of Mystaria",
                    icon = "Interface\\Icons\\INV_Enchant_EssenceMagicLarge", quality = 3, benefit = "+25% Max HP, +4% Dmg Red", desc = "+25% max health, +4% damage reduction" },
    { slotType = "TRINKET", name = "Talisman of Ephemeral Power",
                    icon = "Interface\\Icons\\INV_Misc_StoneTablet_11", quality = 4, benefit = "-10% Cooldowns", desc = "-10% cooldowns" },

    -- CLASS-SPECIFIC LEGENDARY NECKLACES (Remakes class spells)
    -- PALADIN Legendary Amulets
    { slotType = "NECK", class = "PALADIN", spell = "Consecration", name = "Amulet of the Inferno: Consecration", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Consecration", desc = "Legendary amulet - remakes Consecration\nConsecration strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "PALADIN", spell = "Holy Shock", name = "Stormcaller's Amulet: Holy Shock", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Holy Shock", desc = "Legendary amulet - remakes Holy Shock\nReduces Holy Shock cooldown by 15% and increases damage by 20%." },
    { slotType = "NECK", class = "PALADIN", spell = "Exorcism", name = "Eye of the Splitting Sky: Exorcism", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "+1 Tgt, +24% Dmg, Leap", desc = "Legendary amulet - remakes Exorcism\nEquip: Exorcism strikes 1 more target.\nEquip: Increases the damage of Exorcism by 24%.\nEquip: Exorcism's hits leap to 2 more enemies for 36%." },
    { slotType = "NECK", class = "PALADIN", spell = "Holy Wrath", name = "Amulet of the Inferno: Holy Wrath", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Holy Wrath", desc = "Legendary amulet - remakes Holy Wrath\nHoly Wrath strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "PALADIN", spell = "Judgement", name = "Amulet of the Inferno: Judgement", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Judgement", desc = "Legendary amulet - remakes Judgement\nReduces Judgement cooldown by 15% and increases damage by 25%." },
    { slotType = "NECK", class = "PALADIN", spell = "Hammer of Wrath", name = "Amulet of the Inferno: Hammer of Wrath", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Hammer of Wrath", desc = "Legendary amulet - remakes Hammer of Wrath\nIncreases the damage of Hammer of Wrath by 30%." },
    { slotType = "NECK", class = "PALADIN", spell = "Holy Shield", name = "Amulet of the Inferno: Holy Shield", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Holy Shield", desc = "Legendary amulet - remakes Holy Shield\nIncreases Holy Shield absorb by 25% and damage by 15%." },
    { slotType = "NECK", class = "PALADIN", spell = "Divine Shield", name = "Amulet of the Inferno: Divine Shield", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Divine Shield", desc = "Legendary amulet - remakes Divine Shield\nReduces the cooldown of Divine Shield by 20%." },
    { slotType = "NECK", class = "PALADIN", spell = "Holy Light", name = "Amulet of the Inferno: Holy Light", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Holy Light", desc = "Legendary amulet - remakes Holy Light\nIncreases the healing of Holy Light by 30%." },
    { slotType = "NECK", class = "PALADIN", spell = "Redemption", name = "Amulet of the Inferno: Redemption", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Redemption", desc = "Legendary amulet - remakes Redemption\nIncreases Redemption damage by 25% and healing by 20%." },
    { slotType = "NECK", class = "PALADIN", spell = "Hammer of Justice", name = "Amulet of the Inferno: Hammer of Justice", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_04", quality = 5, benefit = "Remakes Hammer of Justice", desc = "Legendary amulet - remakes Hammer of Justice\nIncreases stun duration by 1.5s and reduces cooldown by 20%." },
    -- WARRIOR Legendary Amulets
    { slotType = "NECK", class = "WARRIOR", spell = "Whirlwind", name = "Medallion of the Bladestorm: Whirlwind", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Whirlwind", desc = "Legendary amulet - remakes Whirlwind\nWhirlwind strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "WARRIOR", spell = "Cleave", name = "Medallion of the Bladestorm: Cleave", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Cleave", desc = "Legendary amulet - remakes Cleave\nCleave strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "WARRIOR", spell = "Mortal Strike", name = "Medallion of the Bladestorm: Mortal Strike", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Mortal Strike", desc = "Legendary amulet - remakes Mortal Strike\nIncreases Mortal Strike damage by 30%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Shield Slam", name = "Medallion of the Bladestorm: Shield Slam", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Shield Slam", desc = "Legendary amulet - remakes Shield Slam\nShield Slam deals extra damage equal to 15% of your max health." },
    { slotType = "NECK", class = "WARRIOR", spell = "Execute", name = "Medallion of the Bladestorm: Execute", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Execute", desc = "Legendary amulet - remakes Execute\nIncreases Execute damage by 35%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Bloodthirst", name = "Medallion of the Bladestorm: Bloodthirst", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Bloodthirst", desc = "Legendary amulet - remakes Bloodthirst\nIncreases Bloodthirst damage by 25% and healing by 30%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Thunder Clap", name = "Medallion of the Bladestorm: Thunder Clap", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Thunder Clap", desc = "Legendary amulet - remakes Thunder Clap\nIncreases Thunder Clap area by 25% and damage by 20%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Demoralizing Shout", name = "Medallion of the Bladestorm: Demoralizing Shout", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Demoralizing Shout", desc = "Legendary amulet - remakes Demoralizing Shout\nIncreases Demoralizing Shout weakening by 25%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Battle Shout", name = "Medallion of the Bladestorm: Battle Shout", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Battle Shout", desc = "Legendary amulet - remakes Battle Shout\nIncreases Battle Shout strength buff by 30%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Rend", name = "Medallion of the Bladestorm: Rend", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Rend", desc = "Legendary amulet - remakes Rend\nIncreases Rend bleed damage by 30%." },
    { slotType = "NECK", class = "WARRIOR", spell = "Bloodrage", name = "Medallion of the Bladestorm: Bloodrage", icon = "Interface\\Icons\\INV_Jewelry_Necklace_18", quality = 5, benefit = "Remakes Bloodrage", desc = "Legendary amulet - remakes Bloodrage\nBloodrage procs 25% more often and grants extra attack power." },
    -- SHAMAN Legendary Amulets
    { slotType = "NECK", class = "SHAMAN", spell = "Magma Totem", name = "Amulet of the Ancients: Magma Totem", icon = "Interface\\Icons\\INV_Jewelry_Necklace_23", quality = 5, benefit = "Remakes Magma Totem", desc = "Legendary amulet - remakes Magma Totem\nEvery Magma Totem pulse heals you for 2% of max health and deals +25% damage." },
    { slotType = "NECK", class = "SHAMAN", spell = "Searing Totem", name = "Amulet of the Ancients: Searing Totem", icon = "Interface\\Icons\\INV_Jewelry_Necklace_23", quality = 5, benefit = "Remakes Searing Totem", desc = "Legendary amulet - remakes Searing Totem\nIncreases Searing Totem attack rate and damage by 30%." },
    { slotType = "NECK", class = "SHAMAN", spell = "Flame Shock", name = "Pendant of the Plague: Flame Shock", icon = "Interface\\Icons\\INV_Jewelry_Necklace_28", quality = 5, benefit = "Remakes Flame Shock", desc = "Legendary amulet - remakes Flame Shock\nFlame Shock burn damage ticks 40% faster and deals +25% damage." },
    { slotType = "NECK", class = "SHAMAN", spell = "Lightning Bolt", name = "Stormcaller's Amulet: Lightning Bolt", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Lightning Bolt", desc = "Legendary amulet - remakes Lightning Bolt\nLightning Bolt strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "SHAMAN", spell = "Chain Lightning", name = "Stormcaller's Amulet: Chain Lightning", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Chain Lightning", desc = "Legendary amulet - remakes Chain Lightning\nChain Lightning jumps to 2 more targets and loses nothing per jump." },
    { slotType = "NECK", class = "SHAMAN", spell = "Earth Shock", name = "Stormcaller's Amulet: Earth Shock", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Earth Shock", desc = "Legendary amulet - remakes Earth Shock\nReduces Earth Shock cooldown by 20% and increases damage by 25%." },
    { slotType = "NECK", class = "SHAMAN", spell = "Frost Shock", name = "Stormcaller's Amulet: Frost Shock", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Frost Shock", desc = "Legendary amulet - remakes Frost Shock\nIncreases Frost Shock slow duration and damage by 25%." },
    { slotType = "NECK", class = "SHAMAN", spell = "Lightning Shield", name = "Stormcaller's Amulet: Lightning Shield", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_02", quality = 5, benefit = "Remakes Lightning Shield", desc = "Legendary amulet - remakes Lightning Shield\nLightning Shield discharges retaliate for 35% more damage." },
    { slotType = "NECK", class = "SHAMAN", spell = "Fire Nova", name = "Amulet of the Ancients: Fire Nova", icon = "Interface\\Icons\\INV_Jewelry_Necklace_23", quality = 5, benefit = "Remakes Fire Nova", desc = "Legendary amulet - remakes Fire Nova\nIncreases Fire Nova area by 30% and damage by 25%." },
    { slotType = "NECK", class = "SHAMAN", spell = "Healing Wave", name = "Amulet of the Ancients: Healing Wave", icon = "Interface\\Icons\\INV_Jewelry_Necklace_23", quality = 5, benefit = "Remakes Healing Wave", desc = "Legendary amulet - remakes Healing Wave\nIncreases Healing Wave healing by 35%." },
    { slotType = "NECK", class = "SHAMAN", spell = "Call of Flame", name = "Amulet of the Ancients: Call of Flame", icon = "Interface\\Icons\\INV_Jewelry_Necklace_23", quality = 5, benefit = "Remakes Call of Flame", desc = "Legendary amulet - remakes Call of Flame\nIncreases all fire totem damage and radius by 30%." },
    -- MAGE Legendary Amulets
    { slotType = "NECK", class = "MAGE", spell = "Blizzard", name = "Talisman of the Tempest: Blizzard", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Blizzard", desc = "Legendary amulet - remakes Blizzard\nBlizzard area increased by 25% and damage increased by 20%." },
    { slotType = "NECK", class = "MAGE", spell = "Frostbolt", name = "Talisman of the Tempest: Frostbolt", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Frostbolt", desc = "Legendary amulet - remakes Frostbolt\nFrostbolt strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "MAGE", spell = "Fireball", name = "Talisman of the Tempest: Fireball", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Fireball", desc = "Legendary amulet - remakes Fireball\nFireball deals +30% damage and burns for 40% more." },
    { slotType = "NECK", class = "MAGE", spell = "Flamestrike", name = "Talisman of the Tempest: Flamestrike", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Flamestrike", desc = "Legendary amulet - remakes Flamestrike\nFlamestrike area increased by 30% and lingering burn by 35%." },
    { slotType = "NECK", class = "MAGE", spell = "Arcane Missiles", name = "Talisman of the Tempest: Arcane Missiles", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Arcane Missiles", desc = "Legendary amulet - remakes Arcane Missiles\nFires 2 additional missiles and deals +25% damage." },
    { slotType = "NECK", class = "MAGE", spell = "Arcane Explosion", name = "Talisman of the Tempest: Arcane Explosion", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Arcane Explosion", desc = "Legendary amulet - remakes Arcane Explosion\nArcane Explosion area increased by 25% and damage by 25%." },
    { slotType = "NECK", class = "MAGE", spell = "Cone of Cold", name = "Talisman of the Tempest: Cone of Cold", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Cone of Cold", desc = "Legendary amulet - remakes Cone of Cold\nCone of Cold width increased and deals +30% damage." },
    { slotType = "NECK", class = "MAGE", spell = "Pyroblast", name = "Talisman of the Tempest: Pyroblast", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Pyroblast", desc = "Legendary amulet - remakes Pyroblast\nPyroblast explosion splashes for 40% within 8 yd." },
    { slotType = "NECK", class = "MAGE", spell = "Blast Wave", name = "Talisman of the Tempest: Blast Wave", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Blast Wave", desc = "Legendary amulet - remakes Blast Wave\nBlast Wave daze duration increased by 2s and deals +25% damage." },
    { slotType = "NECK", class = "MAGE", spell = "Frost Nova", name = "Talisman of the Tempest: Frost Nova", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Frost Nova", desc = "Legendary amulet - remakes Frost Nova\nReduces Frost Nova cooldown by 25% and deals +30% damage." },
    { slotType = "NECK", class = "MAGE", spell = "Ice Barrier", name = "Talisman of the Tempest: Ice Barrier", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Ice Barrier", desc = "Legendary amulet - remakes Ice Barrier\nIce Barrier absorb increased by 35%." },
    { slotType = "NECK", class = "MAGE", spell = "Scorch", name = "Talisman of the Tempest: Scorch", icon = "Interface\\Icons\\INV_Jewelry_Necklace_30", quality = 5, benefit = "Remakes Scorch", desc = "Legendary amulet - remakes Scorch\nScorch casts 25% faster and deals +25% damage." },
    -- ROGUE Legendary Amulets
    { slotType = "NECK", class = "ROGUE", spell = "Sinister Strike", name = "The Reaper's Amulet: Sinister Strike", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Sinister Strike", desc = "Legendary amulet - remakes Sinister Strike\nSinister Strike deals +25% damage and has 15% chance to hit twice." },
    { slotType = "NECK", class = "ROGUE", spell = "Blade Flurry", name = "The Reaper's Amulet: Blade Flurry", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Blade Flurry", desc = "Legendary amulet - remakes Blade Flurry\nBlade Flurry cleaves to 1 additional target for 50% damage." },
    { slotType = "NECK", class = "ROGUE", spell = "Eviscerate", name = "The Reaper's Amulet: Eviscerate", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Eviscerate", desc = "Legendary amulet - remakes Eviscerate\nEviscerate deals +35% damage on finishing moves." },
    { slotType = "NECK", class = "ROGUE", spell = "Backstab", name = "The Reaper's Amulet: Backstab", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Backstab", desc = "Legendary amulet - remakes Backstab\nBackstab critical damage multiplier increased by 40%." },
    { slotType = "NECK", class = "ROGUE", spell = "Ambush", name = "The Reaper's Amulet: Ambush", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Ambush", desc = "Legendary amulet - remakes Ambush\nAmbush critical strike damage increased by 50%." },
    { slotType = "NECK", class = "ROGUE", spell = "Rupture", name = "The Reaper's Amulet: Rupture", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Rupture", desc = "Legendary amulet - remakes Rupture\nRupture bleed ticks 30% faster and deals +30% damage." },
    { slotType = "NECK", class = "ROGUE", spell = "Slice and Dice", name = "The Reaper's Amulet: Slice and Dice", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Slice and Dice", desc = "Legendary amulet - remakes Slice and Dice\nSlice and Dice attack speed bonus increased by 15%." },
    { slotType = "NECK", class = "ROGUE", spell = "Gouge", name = "The Reaper's Amulet: Gouge", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Gouge", desc = "Legendary amulet - remakes Gouge\nGouge incapacitate duration increased by 2s." },
    { slotType = "NECK", class = "ROGUE", spell = "Ghostly Strike", name = "The Reaper's Amulet: Ghostly Strike", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Ghostly Strike", desc = "Legendary amulet - remakes Ghostly Strike\nGhostly Strike dodge chance increased by 10% and deals +25% damage." },
    { slotType = "NECK", class = "ROGUE", spell = "Adrenaline Rush", name = "The Reaper's Amulet: Adrenaline Rush", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Adrenaline Rush", desc = "Legendary amulet - remakes Adrenaline Rush\nAdrenaline Rush duration increased by 3s and cooldown reduced by 20%." },
    { slotType = "NECK", class = "ROGUE", spell = "Seal Fate", name = "The Reaper's Amulet: Seal Fate", icon = "Interface\\Icons\\INV_Jewelry_Necklace_27", quality = 5, benefit = "Remakes Seal Fate", desc = "Legendary amulet - remakes Seal Fate\nSeal Fate generates combo points 25% faster." },
    -- PRIEST Legendary Amulets
    { slotType = "NECK", class = "PRIEST", spell = "Shadow Word: Pain", name = "The Eternal Talisman: Shadow Word: Pain", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Shadow Word: Pain", desc = "Legendary amulet - remakes Shadow Word: Pain\nShadow Word: Pain ticks 30% faster and deals +25% damage." },
    { slotType = "NECK", class = "PRIEST", spell = "Mind Flay", name = "The Eternal Talisman: Mind Flay", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Mind Flay", desc = "Legendary amulet - remakes Mind Flay\nMind Flay slow increased to 60% and deals +25% damage." },
    { slotType = "NECK", class = "PRIEST", spell = "Mind Blast", name = "The Eternal Talisman: Mind Blast", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Mind Blast", desc = "Legendary amulet - remakes Mind Blast\nMind Blast deals +35% damage and cooldown reduced by 15%." },
    { slotType = "NECK", class = "PRIEST", spell = "Devouring Plague", name = "The Eternal Talisman: Devouring Plague", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Devouring Plague", desc = "Legendary amulet - remakes Devouring Plague\nDevouring Plague damage and self-heal increased by 30%." },
    { slotType = "NECK", class = "PRIEST", spell = "Holy Nova", name = "The Eternal Talisman: Holy Nova", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Holy Nova", desc = "Legendary amulet - remakes Holy Nova\nHoly Nova area increased by 25%, damage and heal increased by 25%." },
    { slotType = "NECK", class = "PRIEST", spell = "Smite", name = "The Eternal Talisman: Smite", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Smite", desc = "Legendary amulet - remakes Smite\nSmite strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "PRIEST", spell = "Holy Fire", name = "The Eternal Talisman: Holy Fire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Holy Fire", desc = "Legendary amulet - remakes Holy Fire\nHoly Fire direct and burn damage increased by 30%." },
    { slotType = "NECK", class = "PRIEST", spell = "Power Word: Shield", name = "The Eternal Talisman: Power Word: Shield", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Power Word: Shield", desc = "Legendary amulet - remakes Power Word: Shield\nPower Word: Shield absorb increased by 30%." },
    { slotType = "NECK", class = "PRIEST", spell = "Renew", name = "The Eternal Talisman: Renew", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Renew", desc = "Legendary amulet - remakes Renew\nRenew healing increased by 35% and ticks 25% faster." },
    { slotType = "NECK", class = "PRIEST", spell = "Psychic Scream", name = "The Eternal Talisman: Psychic Scream", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Psychic Scream", desc = "Legendary amulet - remakes Psychic Scream\nReduces Psychic Scream cooldown by 25% and affects 2 more targets." },
    { slotType = "NECK", class = "PRIEST", spell = "Lightwell", name = "The Eternal Talisman: Lightwell", icon = "Interface\\Icons\\INV_Jewelry_Necklace_21", quality = 5, benefit = "Remakes Lightwell", desc = "Legendary amulet - remakes Lightwell\nLightwell turn interval accelerated by 30%." },
    -- WARLOCK Legendary Amulets
    { slotType = "NECK", class = "WARLOCK", spell = "Shadow Bolt", name = "The Legionlord's Medallion: Shadow Bolt", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Shadow Bolt", desc = "Legendary amulet - remakes Shadow Bolt\nShadow Bolt strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "WARLOCK", spell = "Corruption", name = "The Legionlord's Medallion: Corruption", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Corruption", desc = "Legendary amulet - remakes Corruption\nCorruption ticks 35% faster and deals +25% damage." },
    { slotType = "NECK", class = "WARLOCK", spell = "Curse of Agony", name = "The Legionlord's Medallion: Curse of Agony", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Curse of Agony", desc = "Legendary amulet - remakes Curse of Agony\nCurse of Agony ramp-up accelerated and deals +30% damage." },
    { slotType = "NECK", class = "WARLOCK", spell = "Immolate", name = "The Legionlord's Medallion: Immolate", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Immolate", desc = "Legendary amulet - remakes Immolate\nImmolate initial burst and burn increased by 30%." },
    { slotType = "NECK", class = "WARLOCK", spell = "Drain Life", name = "The Legionlord's Medallion: Drain Life", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Drain Life", desc = "Legendary amulet - remakes Drain Life\nDrain Life siphons 35% more damage and healing." },
    { slotType = "NECK", class = "WARLOCK", spell = "Hellfire", name = "The Legionlord's Medallion: Hellfire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Hellfire", desc = "Legendary amulet - remakes Hellfire\nHellfire area increased by 25% and self-damage reduced by 50%." },
    { slotType = "NECK", class = "WARLOCK", spell = "Rain of Fire", name = "The Legionlord's Medallion: Rain of Fire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Rain of Fire", desc = "Legendary amulet - remakes Rain of Fire\nRain of Fire meteors fall 30% faster with +25% damage." },
    { slotType = "NECK", class = "WARLOCK", spell = "Searing Pain", name = "The Legionlord's Medallion: Searing Pain", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Searing Pain", desc = "Legendary amulet - remakes Searing Pain\nSearing Pain critical strike chance increased by 20%." },
    { slotType = "NECK", class = "WARLOCK", spell = "Death Coil", name = "The Legionlord's Medallion: Death Coil", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Death Coil", desc = "Legendary amulet - remakes Death Coil\nDeath Coil cooldown reduced by 25% and heal increased by 35%." },
    { slotType = "NECK", class = "WARLOCK", spell = "Soul Fire", name = "The Legionlord's Medallion: Soul Fire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_13", quality = 5, benefit = "Remakes Soul Fire", desc = "Legendary amulet - remakes Soul Fire\nSoul Fire deals +40% catastrophic damage." },
    -- DRUID Legendary Amulets
    { slotType = "NECK", class = "DRUID", spell = "Wrath", name = "Heart of the Earthshaker: Wrath", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Wrath", desc = "Legendary amulet - remakes Wrath\nWrath strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "DRUID", spell = "Moonfire", name = "Heart of the Earthshaker: Moonfire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Moonfire", desc = "Legendary amulet - remakes Moonfire\nMoonfire burn ticks 30% faster and deals +25% damage." },
    { slotType = "NECK", class = "DRUID", spell = "Starfire", name = "Heart of the Earthshaker: Starfire", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Starfire", desc = "Legendary amulet - remakes Starfire\nStarfire splashes 35% damage to nearby enemies." },
    { slotType = "NECK", class = "DRUID", spell = "Hurricane", name = "Heart of the Earthshaker: Hurricane", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Hurricane", desc = "Legendary amulet - remakes Hurricane\nHurricane area increased by 25% and damage by 25%." },
    { slotType = "NECK", class = "DRUID", spell = "Swipe", name = "Heart of the Earthshaker: Swipe", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Swipe", desc = "Legendary amulet - remakes Swipe\nSwipe strikes 1 more target and deals +25% damage." },
    { slotType = "NECK", class = "DRUID", spell = "Shred", name = "Heart of the Earthshaker: Shred", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Shred", desc = "Legendary amulet - remakes Shred\nShred critical strike damage multiplier increased by 35%." },
    { slotType = "NECK", class = "DRUID", spell = "Rip", name = "Heart of the Earthshaker: Rip", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Rip", desc = "Legendary amulet - remakes Rip\nRip bleed damage increased by 30%." },
    { slotType = "NECK", class = "DRUID", spell = "Rake", name = "Heart of the Earthshaker: Rake", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Rake", desc = "Legendary amulet - remakes Rake\nRake bleed ticks 25% faster and deals +25% damage." },
    { slotType = "NECK", class = "DRUID", spell = "Ferocious Bite", name = "Heart of the Earthshaker: Ferocious Bite", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Ferocious Bite", desc = "Legendary amulet - remakes Ferocious Bite\nFerocious Bite deals +35% damage." },
    { slotType = "NECK", class = "DRUID", spell = "Entangling Roots", name = "Heart of the Earthshaker: Entangling Roots", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Entangling Roots", desc = "Legendary amulet - remakes Entangling Roots\nRoots deal periodic nature damage while holding targets." },
    { slotType = "NECK", class = "DRUID", spell = "Thorns", name = "Heart of the Earthshaker: Thorns", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Thorns", desc = "Legendary amulet - remakes Thorns\nThorns retaliate for 100% more nature damage." },
    { slotType = "NECK", class = "DRUID", spell = "Rejuvenation", name = "Heart of the Earthshaker: Rejuvenation", icon = "Interface\\Icons\\INV_Jewelry_Necklace_AhnQiraj_03", quality = 5, benefit = "Remakes Rejuvenation", desc = "Legendary amulet - remakes Rejuvenation\nWhile Rejuvenation heals you, 5% of damage dealt heals you too." },
    -- HUNTER Legendary Amulets
    { slotType = "NECK", class = "HUNTER", spell = "Auto Shot", name = "Eye of the Splitting Sky: Auto Shot", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Auto Shot", desc = "Legendary amulet - remakes Auto Shot\nAuto Shot fires 1 additional projectile at nearest enemy." },
    { slotType = "NECK", class = "HUNTER", spell = "Arcane Shot", name = "Eye of the Splitting Sky: Arcane Shot", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Arcane Shot", desc = "Legendary amulet - remakes Arcane Shot\nArcane Shot deals +30% damage and cooldown reduced by 15%." },
    { slotType = "NECK", class = "HUNTER", spell = "Multi-Shot", name = "Eye of the Splitting Sky: Multi-Shot", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Multi-Shot", desc = "Legendary amulet - remakes Multi-Shot\nMulti-Shot strikes 2 more targets and deals +25% damage." },
    { slotType = "NECK", class = "HUNTER", spell = "Serpent Sting", name = "Eye of the Splitting Sky: Serpent Sting", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Serpent Sting", desc = "Legendary amulet - remakes Serpent Sting\nSerpent Sting ticks 30% faster and deals +25% damage." },
    { slotType = "NECK", class = "HUNTER", spell = "Volley", name = "Eye of the Splitting Sky: Volley", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Volley", desc = "Legendary amulet - remakes Volley\nVolley area increased by 25% and damage by 25%." },
    { slotType = "NECK", class = "HUNTER", spell = "Explosive Trap", name = "Eye of the Splitting Sky: Explosive Trap", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Explosive Trap", desc = "Legendary amulet - remakes Explosive Trap\nExplosive Trap explosion radius increased by 30% and damage by 30%." },
    { slotType = "NECK", class = "HUNTER", spell = "Concussive Shot", name = "Eye of the Splitting Sky: Concussive Shot", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Concussive Shot", desc = "Legendary amulet - remakes Concussive Shot\nConcussive Shot daze duration increased by 2s and deals +25% damage." },
    { slotType = "NECK", class = "HUNTER", spell = "Aimed Shot", name = "Eye of the Splitting Sky: Aimed Shot", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Aimed Shot", desc = "Legendary amulet - remakes Aimed Shot\nAimed Shot critical damage multiplier increased by 40%." },
    { slotType = "NECK", class = "HUNTER", spell = "Immolation Trap", name = "Eye of the Splitting Sky: Immolation Trap", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Immolation Trap", desc = "Legendary amulet - remakes Immolation Trap\nImmolation Trap burn damage increased by 35%." },
    { slotType = "NECK", class = "HUNTER", spell = "Frost Trap", name = "Eye of the Splitting Sky: Frost Trap", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Frost Trap", desc = "Legendary amulet - remakes Frost Trap\nFrost Trap ice patch area increased by 30% and slow increased." },
    { slotType = "NECK", class = "HUNTER", spell = "Hunter's Mark", name = "Eye of the Splitting Sky: Hunter's Mark", icon = "Interface\\Icons\\INV_Jewelry_Necklace_16", quality = 5, benefit = "Remakes Hunter's Mark", desc = "Legendary amulet - remakes Hunter's Mark\nHunter's Mark increases all damage dealt to target by an extra 15%." },
};
