# Changelog - Bordo UI

All notable changes to **Bordo UI** for *Azeroth Survivors* (World of Warcraft 1.12.1) are documented in this file.

---

## [2.6.0] - 2026-10-24

### Added
- **Feature 1: Sleek XP Bar & Dynamic Kills + Gold Tracker:**
  - Modern horizontal XP progress bar cleanly anchored at the bottom of the screen.
  - Replaced all cluttered bottom datatext numbers with ONLY two elegant, centered indicators:
    - **Kills Tracker:** High-resolution red skull icon (`Art\Kills.tga`) + live white kill count (`811`).
    - **Gold / Chest Ratio Tracker:** Gold coin icon (`Art\Coin.tga`) + live gold / next chest cost (`516 / 155`).
    - **Smart Affordability Glow:** The instant player gold meets or exceeds the chest price (`gold >= chest`), the cost text turns bright lime-green (`|cff33ff33`), and the coin activates a pulsating golden aura (`Art\PaceGlow.tga` & `Art\PaceSpark.tga`), making it obvious when a chest can be opened.
- **Feature 2: Modern 4-Section Stats Window (`StatsWindow.lua`):**
  - Replaces the old multipliers box with a sleek, modern, 4-category Stats window matching the EllesmereUI/SurvivorUI reference:
    - `─── Offense ───` (Orange/Red): Crit, Crit Dmg, Damage, Haste, Echo.
    - `─── Defense ───` (Steel Blue): Health, Regen, Lifesteal, Armor, Kill Heal, Thorns, Lives.
    - `─── Reach ───` (Purple): Area, Targets, Pickup.
    - `─── Utility ───` (Emerald Green): Speed, Experience, Gold, Luck, Buff Power.
  - Permanently visible on screen throughout survivor runs (no need to open the character pane with 'C').
  - Draggable with saved position (`BordoUIDB.statsPos`), scalable with mousewheel.
  - Interactive tooltips on hover detailing each stat's effect and breakdown of bonuses contributed by worn gear.
- **Feature 3: Boss & Miniboss Spawn Panel with 3D Directional Arrows (`BossTracker.lua`):**
  - Replaces the old boss text list with an all-new modern encounter HUD:
    - **Top Header:** Current zone title in gold (e.g. `Naxxramas`) + Big Run Clock (`4:26 / 20:00`).
    - **Boss Timeline Bar:** Visual progress bar with white tick marks for scheduled bosses (`3:33`, `7:33`, `11:33`, `15:33`) and green fill progress.
    - **Scheduled Bosses List:** Color-coded boss entries:
      - Green (`0.30, 1.00, 0.40`) when spawned or defeated (`Anub'Rekhan 4:00 / 4:24`).
      - White/Yellow with countdown when upcoming (`Noth the Plaguebringer in 3:33  8:00`).
      - Dimmed grey for future bosses (`Patchwerk 12:00`).
    - **Guardians Segment Bar:** Lair boxes with heraldic marks (`Art\LairMarks.tga` - Crossed Swords, Shield, Crown, Chalice, etc.):
      - When Slain / Dead: Crimson red background with live countdown timer until respawn (`0:39`, `1:51`, etc.).
      - When Spawned / Alive: Vibrant green background with a **live 3D rotational directional arrow** (`Art\GuardianArrow.tga` with 64 dynamic angles) pointing toward the guardian in the 3D world relative to hero facing. Arrow glows gold when facing or within 10 yards.
      - When In Combat: Amber background with health % / fight status.
    - **Achievement Line:** Tracks "Slay 4 guardians before 8:00" progress (`4/4 by 8:00 • done`).
    - **Elites Counter:** Live counter for active elite mobs.
- **Feature 4: Build List (6/6) & Jewelry Panel (`BuildList.lua` + `AbilityTooltip.lua`):**
  - **Build List:**
    - Top header displaying `Build` and slot count `6 / 6`.
    - 6 skill rows showing learned spells from `AZS_SPELLS`: square spell icon, spell name colored by school, cooldown/interval indicator, and current rank.
    - Dedicated racial ability row underneath.
  - **Custom Modern Ability Tooltips (`AbilityTooltip.lua`):**
    - Intercepts default Blizzard game tooltips to render modern stylized cards:
      - Spell school colors (Holy, Fire, Frost, Shadow, Nature, Arcane, Physical).
      - Highlighted numeric damage and cooldown values.
      - Thin divider lines.
      - Categorized breakdown sections: `Upgrades` (Gold), `Your bonuses` (Green), `Talents` (Blue).
  - **Jewelry Panel:**
    - Dedicated `Jewelry` section directly underneath the build list displaying 5 equipped gear slots (Neck, Ring 1, Ring 2, Trinket 1, Trinket 2).
    - Color-coded borders and backgrounds matching item quality (Legendary Orange, Epic Purple, Rare Blue, Uncommon Green, Common Grey).
    - Displays item name/type + roman rank (e.g. `Evisce. IV`, `Ring II`, `Trinket I`).
    - Automatically parses rolled stats into concise tag lines (e.g. `+69% DMG • 77% SPLASH`, `8.8% DMG RED • +35% HP`, `+13% CRIT`, `72% THORNS`).
    - Hovering any jewelry piece displays full item tooltip.
- **Minimap Pins Dual-Engine (`MapPins.lua`):**
  - Fully upgraded minimap pins to show **BOTH** Caches (`Art\PinCache.tga`) and Boss/Guardian Lairs (`Art\PinLair.tga` + `Art\LairMarks.tga`).
  - Active lairs shine bright; empty lairs dim softly.
  - Fixed issue where bosses/guardians were missing on the minimap in instance maps (Naxxramas, SM, AQ).
  - Calibrated yard scaling for indoor and outdoor maps with out-of-range directional edge pins.

### Maintained & Integrated
- **Teammate Green Health Bars:**
  - Overhead Nameplates: Friendly group members feature bright lime-green health bars (`0.12, 0.95, 0.22`) with `🛡️` or `👑` badges.
  - Party Frames: Sleek unit frames with green health bars (`0.15, 0.88, 0.25`), 3D portraits, and leader crowns.
- **Damage Font & Highest Crit Record:**
  - Clean floating combat text via `DamageFont.lua`.
  - Highest crit record & per-spell crit breakdown table via `StatsTable.lua` (`/bordo table`).
- **Death Recap:** Modern popup window upon death via `DeathRecap.lua`.
- **Removed:** "This run" panel and co-op damage meter completely removed as requested.

---

## [2.5.0] - 2026-10-23
- Initial Teammate Green Nameplates & Party Frames release.
