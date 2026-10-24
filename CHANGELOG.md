# Changelog - Bordo UI

All notable changes to **Bordo UI** for *Azeroth Survivors* (World of Warcraft 1.12.1) are documented in this file.

---

## [3.2.0] - 2026-10-24

### Added
- **Modern Floating Damage Numbers & Combat Text Font (`DamageFont.lua`):**
  - Restored our crisp, modern sans-serif floating combat font (`Interface\AddOns\BordoUI\Media\modern.ttf`).
  - Sets `DAMAGE_TEXT_FONT` and compact 75% combat text scale so damage numbers stay ultra-crisp without cluttering screen view.
- **Attack & Highest Crit Statistics Window (`StatsTable.lua`):**
  - Restored the comprehensive Attack & Highest Crit table window!
  - **Overview Header:** Shows the run's **★ Highest Crit / Bester Krit** with ability name and spell icon, your character sheet crit rate vs. real measured crit rate (`Char Crit: X% | Actual: Y%`), and live DPS.
  - **Per-Attack Breakdown:** Displays every ability used, spell icon, Max Crit (highlighted in gold), measured Crit Rate (% and count), and DPS.
  - **Interactivity:** Scalable (`[-]` / `[+]` or mousewheel), collapsible, draggable anywhere on screen, close button `[X]`.
  - Slash commands: `/crit` or `/crits` or `/bordo crit`.
- **Always-Visible On-Screen Stats HUD Window (`CharacterPane.lua`):**
  - Permanently enables the standalone Stats HUD panel on screen so you never need to press 'C' to check your build!
  - Displays all 4 character attribute categories in real time: Offense (Crit, Crit Dmg, Haste, Echo), Defense (Health, Regen, Lifesteal, Armor, Thorns, Lives), Reach (Area, Targets, Pickup), and Utility (Speed, XP, Gold, Luck, Buff Power).
  - Positioned at the top-left of the screen (`16, -14`), movable with Alt-drag and resizable via the corner grip.
  - Slash command: `/stats` or `/bordo stats` to toggle.

### Removed / Hidden
- **Removed "This Run" Overview Panel (`RunPanel.lua`):**
  - Disabled and hid the bulky "This Run" window by default (`runPanel = false`) to free up valuable screen real estate for the Stats HUD and Crit Table.

---

## [3.1.0] - 2026-10-24

### Added
- **Movable Bottom-Center Gold & Dynamic Chest Price Tracker (`Core.lua`):**
  - Added a dedicated, movable HUD widget positioned by default at the bottom-center (`BOTTOM`, `0`, `185`).
  - Displays current player gold on the left and dynamic chest cost on the right: `[Coin] 400 / 20`.
  - Automatically updates as chests become increasingly expensive across the run (`20`, `40`, `60`, ...).
  - **Visual Affordability Indicators:** When you have enough gold to open a chest (`gold >= chestCost`), the chest price highlights in bright green (`|cff33ff33`), the widget border glows golden, and the coin icon pulses with an animated breath glow!
  - **Interactive Drag-and-Drop:** Left-click and drag anywhere on screen to reposition; position is automatically saved to `BordoUIDB.goldPos` across reloads.
  - Informative hover tooltip with breakdown of current gold, next chest cost, affordability status, and drag instructions.
  - Slash commands: `/gold` and `/bordo gold` (use `/gold reset` to reset position, `/gold test` to preview outside runs).

### Fixed & Improved
- **Minimap Boss & Lair Pin Visibility (`MapPins.lua`):**
  - **Universal Coordinate Parsing:** Resolved a critical bug where boss lairs stored in indexed arrays (`[6]=x, [7]=y, [9]=mx, [10]=my`) returned `nil` in `WayTo()`, preventing boss markers from generating on the minimap.
  - **Lair State Detection:** Replaced non-existent `lair.active` field with proper Azeroth Survivors state inspection (`state ~= "empty"`), ensuring alive bosses are never hidden by the empty lair filter.
  - **Dynamic Combat & Awake Detection:** Integrated real-time awake detection via `AZS_GetGuardians` and `AZS_UNITS`. Bosses engaged in combat are enlarged (135% size) and pulse with a fiery red/orange glow.
  - **Edge-Clamped Boss Pins:** Boss pins now stay clamped to the minimap perimeter with directional indicators (`pin.isBoss = true`), even when distant or when `pinEdge == "hide"` is configured.
  - **Informative Boss Tooltips:** Hovering boss pins displays clean titles (`★ BOSS: Mor'Ladim ★`), combat status (`⚠ AWAKE & FIGHTING!`, `● Waiting in Lair`, or `○ Slain (Respawning in Xs)`), and exact yard distance.
  - **Complete Texture Path Resolution:** Fixed lingering `SurvivorUI/Art` texture paths across all 18 UI files (`Art\PinLair`, `Art\PinCache`, `Art\Coin`, `Art\PaceGlow`, etc.), restoring minimap icons, coin graphics, and buttons.

---

## [3.0.0] - 2026-10-24

### Added & Merged
- **Complete Survivor UI Suite Integration:**
  - Integrated the full, modern Azeroth Survivors interface suite: centered unit frames, action bar (buttons 1–6 and =), square minimap, career tracking, run panel, build list, jewelry crafting, pace tracker, boss encounter bars, loot logger, and in-game settings panel (`/sui opt` or `/bordo opt`).
  - Integrated high-performance Plater-style nameplates (`SurvivorPlates.lua`) featuring execute range markers (30% HP), boss tiers, and target debuffs.
- **Preserved Death Recap System (`DeathRecap.lua`):**
  - Retained our signature, fully translated Death Recap tracking lethal overkill, attacker, ability, and last incoming hits. Toggle with `/bordo`, `/bordo recap`, or `/recap`.
- **Integrated High-Visibility Green Teammate Health Bars:**
  - Embedded vibrant lime-green teammate nameplates (`130x14px`, color `0.12, 0.95, 0.22`) with emerald green borders and `🛡️ Teammate` / `👑 Leader` badges directly into the Plater nameplate engine.
  - Teammates always remain visible regardless of mob filtering settings.
  - Automatically activates native WoW 1.12 friendly nameplates (`ShowFriendNameplates()`) upon login and joining parties.
  - Matching lime-green health bars applied to party unit cards in `Party.lua`.
- **Core Slash Commands & Camera Zoom:**
  - Retained `/bordo zoom` for maximum 50-yard camera distance, `/bordo plates` / `/plates` for force-enabling nameplates, and `/bordo` for instant Death Recap toggle.

### Removed
- **Obsolete Custom UI Modules:**
  - Cleaned up redundant legacy files (`ThemeUI.lua`, `StatsTable.lua`, `PartyFrames.lua`, `DamageFont.lua`) replaced by the official Survivor UI architecture.

---

## [2.5.0] - 2026-10-23

### Added
- **High-Visibility Teammate Green Health Bars (Nameplates.lua):**
  - Added dedicated friendly nameplate styling for party and raid members.
  - Teammates now feature an unmistakable, vibrant lime-green health bar (`130x15px`, color `0.12, 0.95, 0.22`) floating over their heads in the 3D world, making them instantly recognizable in crowds of 50+ red-barred enemies.
  - Emerald green borders (`0.15, 0.85, 0.30`) with special shield (`🛡️ Name`) and gold crown (`👑 Name` for Party Leader) title tags.
  - Displays live health percentage in the center of the teammate nameplate and red `DEAD` warning when fallen.
  - **Native Vanilla 1.12.1 Engine Integration:** Automatically calls native `ShowFriendNameplates()` and `ShowNameplates()` upon login, zone change, and party events. Continuously monitors group state to ensure friendly nameplates remain active throughout intense survivor rounds.
  - Added `/bordo plates` and `/plates` slash commands to instantly force-enable teammate & enemy nameplates.
- **Teammate Green Health Bars in Party Frames (PartyFrames.lua):**
  - Updated party member unit cards with vibrant green health bars (`0.15, 0.88, 0.25`) for visual consistency with overhead nameplates, preserving class-colored player names.
- **Quick Party Frames Toggle Button:** Added a `[👥 Party]` button in the Damage Stats table header for instant one-click access.

### Removed
- **Co-op Damage Meter:** Completely removed `CoopMeter.lua` and all associated background sync workers, slash commands (`/coop`), and saved variables at user request.

---

## [2.4.2] - 2026-10-23

### Fixed & Improved
- **Dual-Channel Synchronization (Party + Whisper):** Co-op damage broadcasts are now transmitted over both `PARTY` and direct `WHISPER` addon messages, ensuring data passes through even if a server blocks or throttles party chat channels.
- **Embedded Name Payload:** Character names are now embedded directly within the message payload (`NAME;DMG;DPS;CLASS;...`), completely eliminating reliance on `arg4` (sender token) which can be nil or reformatted across different 1.12 clients.
- **Unrestricted Group Sync:** Removed restrictive phase checks (`ph == "playing"`) so background sync runs continuously as long as you are in a party or raid.
- **Live Diagnostics Tool (`/coop debug`):** Added a diagnostic command that outputs live packets sent, packets received, raw payload, and teammate status to pinpoint setup issues in seconds.

---

## [2.4.1] - 2026-10-23

### Fixed & Improved
- **Robust Multi-Language Addon Synchronization:**
  - Fixed an issue where localized class names (German umlauts like `Jäger` or Cyrillic characters like `Воин`) caused `string.find` regex pattern matching to drop incoming teammate sync packets.
  - Switched to delimiter splitting (`[^;]+`) to parse damage, DPS, kills, and health without locale encoding errors.
  - Converted float damage/DPS values to integer values (`math.floor`) before broadcast, preventing decimal comma vs point locale parsing mismatches.
  - Dual prefix broadcast (`BordoCoop` and `BORDO_COOP`) for universal private server packet compatibility.
  - Case-insensitive teammate name matching for party member data lookup.
- **Enhanced Combat Log Tracking for Teammates Without Addon:**
  - Expanded combat log event listeners across all spell, periodic, creature, and friendly player damage events (`CHAT_MSG_SPELL_*` and `CHAT_MSG_COMBAT_*`).
  - Switched party member name matching to plain substring search (`plain = true`) to prevent pattern escaping bugs with player names.
  - Multi-language damage extraction supporting English (`for 190`), German (`190 Schaden`, `für 190`), and Russian (`190 ед.`, `190 урона`).
- **Faster Broadcast Rate:** Increased sync broadcast frequency from every 1.0s to every 0.5s and enabled sync during card selection (`choosing` phase).

---

## [2.4.0] - 2026-10-23

### Added
- **Modern Bordo UI Party Frames (`PartyFrames.lua`):** Complete redesign of the group/party window matching Bordo UI's sleek dark glass aesthetic, replacing the default Blizzard party frames.
- **Square 3D Portrait Cards:** Clean square portraits with cropped textures (`0.12, 0.88`), Leader gold crown badges, and master looter indicators.
- **Class-Colored Health & Dynamic Power Bars:**
  - Full class-colored health status bars (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, Druid) across English, German, and Russian client locales.
  - Live health percentage and current HP display (`1,250 (83%)`).
  - Dynamic power bars (Mana [Blue], Rage [Red], Energy [Yellow]).
- **Combat Status & Range Fade:**
  - Displays instant `|cffff2222DEAD|r` and `|cff888888OFFLINE|r` status overlays.
  - Smooth range-based opacity dimming when teammates are out of interact range.
- **Universal Frame Movement & Global Lock Integration:**
  - Freely draggable anywhere on screen by clicking and dragging the header or any party frame.
  - Position is automatically saved to `BordoUIDB.partyPos` and restored on login/reload.
  - Full integration with `/bordo lock`, `/bordo unlock`, and the `[L]` / `[U]` header button.
- **Interactive Unit Interaction:**
  - Left-Click on any teammate to instantly target them (`TargetUnit`).
  - Right-Click to open the native Blizzard party dropdown menu (Inspect, Whisper, Promote, etc.).
  - Mouse hover cyan border highlight and native unit tooltip.
- **Auto-Suppression of Blizzard Default Frames:** Safely hides and disables the legacy `PartyMemberFrame1-4` frames to eliminate overlapping with the Multipliers panel.
- **Live Preview / Test Mode (`/bparty test` or `/partyframes test`):** Instant preview mode simulating 4 teammates (`Byoo`, `Wunderling`, `Doprecious`, `Wildsomon`) with full bars, levels, and leader status.
- **New Slash Commands:** Added `/bparty`, `/partyframes`, and `/bordo party` (with `/bparty test` and `/bparty reset`).

---

## [2.3.1] - 2026-10-23

### Fixed & Improved
- **Dedicated Background Worker Frame (`BordoUI_CoopWorkerFrame`):** In WoW 1.12.1, hidden frames do not receive `OnUpdate` ticks. Separated the auto-show, party detection, and addon broadcast logic into an always-active background worker frame, guaranteeing that the Co-op meter automatically displays when in a party without requiring manual commands.
- **Conflict-Free Default Position:** Positioned under the Minimap (`TOPRIGHT, -12, -160`) to avoid overlapping the Azeroth Survivors Co-op Boss schedule / event list on the left side of the screen.
- **Multi-Language Combat Log Fallback:** Enhanced combat log parser to match party members and damage numbers across Russian, German, and English game clients.
- **Session Memory:** Respects manual closing (`[X]` button) during an active run while auto-opening for new games or when toggled with `/coop`.

---

## [2.3.0] - 2026-10-23

### Added
- **Co-op Team Damage Meter (`/bordo coop` or `/coop`):** Real-time multiplayer damage and DPS leaderboard designed specifically for Azeroth Survivors Co-op mode.
- **Dual Tracking Engine:**
  - **High-Precision Addon Sync:** Automatically syncs exact damage and DPS with party members via background addon messages (`SendAddonMessage("BORDO_COOP", ..., "PARTY")`).
  - **Combat Log Fallback:** Tracks and attributes damage for teammates who do not have Bordo UI installed yet via combat log events.
- **Class-Colored Progress Bars:** Proportional fill bars with official WoW class colors (Warrior, Mage, Rogue, Hunter, Priest, Warlock, Druid, Paladin, Shaman).
- **Interactive Tooltips & Stats:** Hover over any player to view their total damage, exact DPS, team contribution share %, kills, and sync status.
- **Test / Preview Mode:** Type `/coop test` or `/bordo coop test` to immediately preview the meter on screen even when playing solo.
- **Quick-Launch Header Button:** Added a `[👥 Co-op]` button directly into the Damage Stats table header for one-click access.

---

## [2.2.0] - 2026-10-23

### Added
- **Movable Chat Window:** The sleek dark chat box can now be grabbed and moved anywhere on screen (`LeftButton` on chat text, border, or chat tab).
- **Saved Chat Position:** Its position is automatically saved to `BordoUIDB.chatPos` and restored on login/reload.
- **Universal Frame Movement:** All major UI windows can now be freely repositioned:
  - Chat Window (`chatPos`)
  - Multipliers Panel (`multPanelPos`)
  - Attack Damage & DPS Stats Table (`statsPos`)
  - Centered Combat HUD: Player, Boss & 7 Ability Slots (`centerHudPos`)
  - Boss Encounter & Miniboss HP Bars (`encounterBarsPos`)
  - Bottom Datatext & XP Bar (`bottomBarPos`)
  - Death Recap (`deathRecapPos`)
- **Global UI Window Lock (`/bordo lock` & `/bordo unlock`):**
  - Lock all UI windows to prevent any accidental dragging during combat.
  - Interactive lock button `[L]` / `[U]` directly on the Multipliers panel header with tooltips and live status.
  - Slash commands: `/bordo lock`, `/bordo unlock`, `/bordo move` (or `/lock`, `/unlock`).

---

## [2.1.3] - 2026-10-23

### Fixed & Improved
- **100% English Death Recap & Log:** Replaced all remaining legacy German strings (e.g. `Nahkampf` -> `Melee`, `Gegner` -> `Enemy`, `Umgebung` -> `Environment`, `Sturz` -> `Fall Damage`).
- **Accurate Fatal Blow Damage:** Fixed the killing blow calculation. Previously, a non-lethal hit (such as a 4-damage strike 1.5s prior to death) could incorrectly be shown as `216 HP [ -4 Damage ]> 0 HP`. The recap now calculates the true lethal damage that brought the player's HP to 0 (`216 HP [ -216 Damage ]> 0 HP [DEFEATED]`).
- **Missing Combat Log Events Registered:** Added listeners for Environmental Damage (falling, lava, slime, fire, drowning, fatigue), self damage, and damage shields.
- **New Slash Commands:** Added `/bordo recap` and `/bordo death` (in addition to legacy `/azs recap` and `/azs death`).

---

## [2.1.2] - 2026-10-23

### Added
- **Movable Multipliers Panel:** The Multipliers panel can now be freely dragged and repositioned anywhere on screen using `LeftButton`.
- **Saved Position:** Its custom position is automatically saved across sessions and restored on login/reload (`multPanelPos`).
- **Dynamic Docking Follow:** When moving the Multipliers panel, the docked Attack Stats table automatically moves along with it.
- **Intelligent Click vs Drag:** Clicking the panel toggles the attack stats table without accidentally triggering movement, while dragging moves the panel smoothly.

---

## [2.1.1] - 2026-10-23

### Added
- **Visual Button on Multipliers Panel:** Added a dedicated interactive button `[ 📖 Attack Stats >> ]` at the bottom of the Multipliers panel so players immediately see that the damage stats table is clickable.
- **Button Hover & Tooltip:** Button border glows golden on hover, text turns bright amber, and an explanatory tooltip appears explaining the full attack breakdown.
- **Header Close Button [X]:** Added a red `[X]` button to the top-right of the stats table header for quick closing.
- **ESC Key Support:** Registered the stats table with `UISpecialFrames` so pressing the `ESC` key instantly closes the window.

### Changed
- **Zero-Overlap Docking:** The damage stats table now docks seamlessly directly to the right edge of the Multipliers panel (`TOPLEFT` anchored to `TOPRIGHT` with 6px gap), eliminating all overlap.
- **Strata & Opacity Fix:** Raised the stats table to `MEDIUM` frame strata with a solid 98% opaque dark backdrop, preventing underlying boss timers or chat text from bleeding through.
- **Localized Window Header:** Updated stats table title from legacy German `AZS Krit-Statistik` to English `Bordo UI Damage Stats`.

---

## [2.1.0] - 2026-10-23

### Added
- **Dedicated Racial Ability Slot:** Integrated a 7th action button slot into the centered combat HUD specifically for your racial ability (Orc *Blood Fury*, Troll *Berserking*, Dwarf *Stoneform*, Tauren *War Stomp*, Undead *Will of the Forsaken*, Human *Perception*, Gnome *Escape Artist*, Night Elf *Shadowmeld*).
- **Racial Cooldown Tracking:** Live cooldown timer (seconds/minutes) and icon automatically tracked from `AZS_SPELLS`.
- **Radiant Gold Accent:** Styled the racial ability slot with a distinctive golden border and 4px separator gap to differentiate it from regular Survivor skills.

### Changed
- **Centered HUD Width:** Expanded central skills container from 188px to 224px, maintaining perfect horizontal symmetry with player and boss unit frames.

---

## [2.0.0] - 2026-10-23 - *Initial Bordo UI Release*

### Added
- **Full English Localization:** Translated all menus, headers, tooltips, slash commands, chat messages, death recap, boss timers, and nameplates into English.
- **Damage Meter Friendly Tooltip:** Relocated mob/unit mouseover tooltips from bottom-right to middle-right (`RIGHT`, 20px padding), leaving the bottom-right corner 100% unobstructed for DPS meters (DPSMate, SW_Stats, Recount).
- **100% Stationary Chest Radar:** Custom 3D coordinate math ensuring Battleground Cache icons remain completely stationary on the ground in indoor instances without maps (**Naxxramas, Scarlet Monastery, Ahn'Qiraj**).
- **Centered Combat HUD:** Modern unit frames featuring 3D animated class portraits flush with health bars (4px border overlap), class colors, dynamic absorb shields, and centered cooldowns.
- **Bottom Datatext Bar & Flush XP Bar:** Compact stats footer with a seamless XP progress bar attached directly on top.
- **Detailed Damage & DPS Stats Table (`/bordo`):** Real-time breakdown of every attack, 16x16 spellbook icons, real crit rate vs sheet crit, top crits, and full resizing support.
- **Death Recap (`/bordo recap`):** Detailed post-death window highlighting the killing blow, overkill, and chronological HP loss of the last 6 hits received before death.
