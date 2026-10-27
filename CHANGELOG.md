# Changelog - Bordo UI

All notable changes to **Bordo UI** for *Azeroth Survivors* (World of Warcraft 1.12.1) are documented in this file.

---

## [2.8.5] - 2026-10-27

### Fixed & Restored
- **Fully Restored Pre-Totem Baseline (0c7f099):**
  - **Minimap Loot Caches & Boss Pins:** Restored authentic Chestlight engine with golden chests (bag.tga + pulsing glow.tga), count grouping, yard distance, off-screen edge arrow, and boss pins.
  - **Miniboss Tracker Heraldic Marks & Rotational Arrows:** Restored authentic heraldic marks atlas (LairMarks.tga) and live 3D rotational arrows pointing to active guardians.
  - **Authentic Textures:** Restored all original binary texture assets in Art/ and Media/.
- **Shaman Totem Health Bar Suppression (Nameplates.lua):**
  - Completely hides health bars and nameplates for all Shaman totems to eliminate clutter.
  - Added /bordo totems toggle command.

---

## [2.7.4] - 2026-10-25

### Removed & Streamlined
- **Removed Left Loot Log Window:**
  - Completely removed the secondary left-side loot panel (`BordoUI_LootLogFrame`) to eliminate screen clutter and overlaps.
  - The clean, modern top-center toast directly above the character (`BordoUI_LootAlertFrame`) is now the single, dedicated notification for all boss drops.
- **Strict Enemy Boss Drop Filtering Maintained:**
  - Boss loot notifications trigger exclusively on true enemy drops (`CHAT_MSG_LOOT` / `CHAT_MSG_SYSTEM`).
  - Augments, level-up choices, and Neck ability amulets remain strictly excluded.
  - Native right-side engine popup remains cleanly suppressed (`AZS_SetHudShown("loot", false)`).

---

## [2.7.3] - 2026-10-25

### Fixed & Added
- **Strict Boss Loot Filtering (Eliminated Augments from Toast):**
  - Removed inventory change triggers that previously caused picked Augment rings (e.g. *Master Dragonslayer's Ring*) to falsely display as a Boss Loot alert.
  - Added strict phase verification (`AZS_GetPhase() ~= "choosing"`) so upgrade choices never trigger the alert.
  - The center Boss Loot toast now fires **exclusively** on true enemy boss item drops (`CHAT_MSG_LOOT` / `CHAT_MSG_SYSTEM`).
- **New Run Loot Log Panel on Left Side ("Links wo höchster Krit ist"):**
  - Added a dedicated, movable run loot panel (`BordoUI_LootLogFrame`) docked directly below *Höchster Krit* (`SurvivorUICrits`) or *This Run* (`SurvivorUIRun`).
  - Displays a clean history of all equipment, armor, and jewelry dropped in the current run (newest first).
  - Every row features the authentic item icon, item name in quality color, drop timestamp (`M:SS`), stack count (`x2`), and `new` collection tags.
  - Full mouseover tooltip (`GameTooltip:SetHyperlink`) and Shift-Click chat insertion.
  - Included in `/bordo unlock` / `/bordo move` mode and auto-resets on each new run or with `/bordo clearloot`.
- **Permanent Right-Side Loot Popup Suppression:**
  - Continuous background maintenance ensures `AZS_SetHudShown("loot", false)` remains active at all times, preventing duplicate popups on the right edge.

---

## [2.7.2] - 2026-10-25

### Fixed & Improved
- **Modern Boss Loot Alert & Authentic Item Icon Resolution (`LootAlert.lua`):**
  - **Live Asynchronous Icon Resolution:** Fixed an issue where the center boss loot notification fell back to a generic wooden box icon (`INV_Box_01`) when items like Pants dropped. The alert now queries local equipment, all bags (0-4), the persistent item cache, and continuously polls `GetItemInfo` on `OnUpdate` to ensure authentic item textures are always displayed immediately.
  - **Smart Keyword-to-Texture Fallbacks:** Implemented instant slot-appropriate icon mapping (e.g. Pants/Hose -> `INV_Pants_02`, Helm -> `INV_Helmet_06`, Ring -> `INV_Jewelry_Ring_15`, Boots -> `INV_Boots_01`, etc.) so that generic box textures are never shown even on the very first frame before server item data returns.
  - **Expanded Equipment Watcher:** Extended run equipment tracking to all gear and armor slots (Head, Shoulders, Chest, Waist, Legs, Feet, Wrist, Hands, Rings, Trinkets, Cloak, Weapons) while strictly filtering out starting ability Amulets (Neck).
  - **Clean UI Centralization:** Automatically suppresses the native game engine's redundant right-side loot popup (`AZS_SetHudShown("loot", false)`), centralizing all boss loot notifications into the modern top-center toast above the character.
  - **Interactive Testing:** Added `/bordo testloot pants` and `/bordo testloot helm` to easily preview different drop types.

---

## [2.7.1] - 2026-10-24

### Fixed & Improved
- **Window Dragging & Universal Move Mode (`/unlock` & `/lock`):**
  - Resolved window dragging issues: Left-clicking and dragging now works directly on all frame backgrounds and headers without requiring keyboard modifiers.
  - Added visual **Move Mode** (`/unlock`, `/bordo move`): Renders prominent translucent drag boxes over every UI element (`Combat HUD`, `Stats Window`, `Boss Tracker`, `Build & Jewelry List`, `Party Frames`).
  - Added on-screen top control bar during Move Mode with one-click buttons: `[ Lock All Windows ]` and `[ Reset Default Layout ]`.
  - Type `/lock` to lock all windows once repositioned.
- **Pixel-Perfect Default Layout Matching Screenshot:**
  - **Eliminated Boss Tracker & Build List Overlap:** Build List now dynamically docks beneath `BossTracker` (`TOPRIGHT, SurvivorUITracker, BOTTOMRIGHT, 0, -8`) with zero overlapping.
  - **Stats Window:** Default position docked in the upper-left corner (`TOPLEFT, 12, -14`).
  - **Sleek Unified Combat HUD:** Eliminated duplicate stock Blizzard XP bars. The sleek XP bar and Kills/Gold tally are now snugly attached directly under the action buttons (`TOP, row, BOTTOM, 0, -4`), moving with the HUD as one unified combat block.
  - **One-Command Reset (`/bordo reset`):** Instantly purges any corrupted or stale saved positions and snaps all frames back to the clean reference layout.

---

## [2.7.0] - 2026-10-24

### Added
- **1:1 SurvivorUI Centered Combat HUD (`ThemeUI.lua`):**
  - **Centered 7-Slot Action Bar (`SurvivorUIRow`):**
    - Centered horizontally under the hero with 7 dark bordered slots for buttons 1 to 6 plus slot 12 (the racial ability). Empty slots maintain clean dark bordered backing frames.
    - Action buttons styled with cropped icons (`0.08, 0.92, 0.08, 0.92`), default Blizzard art textures stripped, and keybind labels cleanly hidden.
    - Built-in numerical cooldown countdown overlays (`CooldownFrame_SetTimer` hook), dimming buttons on cooldown and turning bright red when under 2.0 seconds.
  - **Player Unit Frame (`SurvivorUIPlayer`):**
    - Anchored directly to the left of the action bar (`RIGHT` to `SurvivorUIRow, LEFT, -6, 0`).
    - 36x36 square cropped 3D portrait on the far left with a 1px black border.
    - 150x32 flat class-colored health bar with 1px black border and dark backing.
    - 150x3 slim power bar directly beneath the health bar (Mana Blue, Rage Red, Energy Yellow).
    - Dynamic absorb shield overlay on health bar with diagonal stripes (`Art\ShieldStripes.tga`) and bright leading edge.
    - Name on the left, live `HP | %` on the right (e.g. `257 | 100%`, or `Down`/`Dead` in co-op).
    - Left-click targets player, right-click opens standard Blizzard player menu, Alt-drag moves the entire HUD.
  - **Player Buffs & Debuffs Row (`SurvivorUIBuffs`):**
    - 12 aura buttons (`22x22`) lined up directly above the Player Frame.
    - Time remaining text centered (`10pt`, `1, 0.95, 0.6`, e.g. `30`, `1.5s`, `5m`) and stack counts in bottom-right.
    - 1px black border for helpful buffs, 1px crimson red border for harmful debuffs.
    - Right-click cancels helpful buffs (`CancelPlayerBuff`). Hover shows detailed spell tooltip.
    - Default Blizzard `BuffFrame` and `TemporaryEnchantFrame` are cleanly suppressed.
  - **Target Unit Frame (`SurvivorUITarget`):**
    - Anchored directly to the right of the action bar (`LEFT` to `SurvivorUIRow, RIGHT, 6, 0`).
    - Mirrored layout: 150x32 health bar on left, 150x3 power bar underneath, 36x36 square cropped portrait on the far right.
    - Enemy red health bar (`0.80, 0.22, 0.22`), or class-colored for friendly player targets.
    - Target name on left, live `HP | %` or `%` on right (supports server-sent `AZS_TARGET` exact values).
    - Left-click targets, right-click opens target menu, Alt-drag moves the HUD.
    - Shows when target exists, cleanly hides when no target is selected.
  - **Target Debuffs Row:**
    - 8 debuff icons (`18x18`) lined up directly above the Target Frame.
    - Displays live `UnitDebuff("target", i)` textures, stack counts, and 1px black borders.
  - **Integrated Bottom XP Bar & Kills/Gold Tracker (`UI.bottomBar`):**
    - Full-width (650px) bar anchored directly under the centered combat HUD.
    - Sleek flat XP progress bar on top with percentage and XP values.
    - Centered tally frame underneath with Red Skull (`Art\Kills.tga`) + kill count, and Gold Coin (`Art\Coin.tga`) + Gold/Chest ratio (`516 / 155`).
    - Turns bright lime-green with pulsating golden glow (`Art\PaceGlow.tga`) and twinkling star (`Art\PaceSpark.tga`) whenever the player can afford the next chest!
- **1:1 Co-op Party Frames (`PartyFrames.lua`):**
  - Anchored directly to the left of the player frame (`BOTTOMRIGHT` to `SurvivorUIPlayer, BOTTOMLEFT, -14, 0`), stacked upwards from bottom to top (`party1` at bottom, `party2..4` above).
  - Each teammate row (165x24):
    - 24x24 square class icon with leader crown overlay (`UI-Group-LeaderIcon`).
    - 140x24 flat health bar colored by teammate's class.
    - Teammate name on left, live health percentage on right.
    - Full co-op status integration: `Offline` (dark gray), `DOWN` (crimson red fill and text), `Reviving %` (gold rescue bar fill), `Reviving you` (gold text if teammate is rescuing you).
    - Live hover tooltip displaying damage dealt this run, DPS, and top damage spell (`AZS_PARTY` / `AZS_GetPartyMeter`).
    - Left-click targets the teammate.
    - Movable support via Alt-drag or Shift-drag, saving position to `BordoUIDB.partyLeft` and `BordoUIDB.partyBottom`.
    - Integrated Revive Bar module (`SurvivorUIRevive`) showing rescue progress while down or reviving a friend.
    - Test preview command: `/bordo party test` toggles sample party frames with realistic damage stats and co-op states.

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
