# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-2.5.0-brightgreen.svg)](https://github.com)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** is a modern, clean, and high-performance all-in-one user interface suite for **Azeroth Survivors** (World of Warcraft 1.12.1 / Benilla client). Designed by Bordo for maximum combat visibility, fluid responsiveness, and sleek dark aesthetic.

---

## ✨ Key Features

### 1. 🛡️ Centered Combat Unit Frames & Ability Bar
- **3D Class Portraits:** Seamlessly flush with the health bar with a sleek dark border.
- **Dynamic Class Colors:** Tailored to all 9 WoW classes (Warrior brown, Mage sky blue, Rogue yellow, etc.).
- **Absorb Shields:** Clean overlay of active shield absorption amounts directly on the health bar.
- **Centered HUD with Racial Ability:** 6 Survivor skills plus a dedicated **Racial Ability slot** (with radiant golden border and real-time cooldown tracking) positioned between player and boss.

### 2. 📊 Bottom Datatext Bar & Seamless XP Bar
- **Compact Datatext Bar:** Displays Level, XP%, Kills, Gold, Next Chest Cost, Health, Rerolls, Total Damage, and FPS in an elegant dark-cyan theme.
- **Flush XP Bar:** Snapped flush above the bottom bar with zero gap. Experience numbers rest cleanly above the blue bar with high-contrast text shadow.

### 3. 🗺️ Stationary Chest Radar (Battleground Caches)
- **Authentic Pouch Icons (`bag.tga` & `glow.tga`):** Crisp bags with a pulsing golden glow.
- **100% Stationary in All Zones:** Specially adapted 3D indoor coordinate engine for instances without 2D maps (**Naxxramas, Scarlet Monastery, Ahn'Qiraj**). Chests never follow your character movement—they remain fixed on the ground.
- **Directional Arrow:** Purple pointer arrow along the minimap rim indicating the distance and heading towards the nearest off-screen chest.
- **Cluster Merging:** Clusters of chests within 10 yards merge into a single icon showing the total chest count.

### 4. ⚔️ Detailed Damage & DPS Statistics Table (`/bordo` or `/azs`)
- **Ability Spell Icons:** Automated spellbook scanner and dictionary displays 16x16 spell icons next to each ability.
- **In-Depth Metrics:** Total Damage, DPS, Breakdown %, Hits, Crits, Real Crit Rate vs Sheet Crit, and Highest Critical Hit.
- **Fully Scalable & Movable:** Resize with mouse wheel or [-] / [+] buttons. Quick-launch button for the Co-op Team Meter in the header.

### 5. 👥 Modern Party Frames (`/bparty` or `/bordo party`)
- **Sleek Bordo Glass Style:** Replaces legacy Blizzard party frames with modern, compact dark glass unit cards.
- **Square 3D Portraits:** Cropped square unit portraits (`0.12, 0.88`) with gold Leader Crown icons and master looter markers.
- **Teammate Green Health Bars:** High-visibility green health bars with class-colored player names across English, German, and Russian client languages, with slim power bars (Mana/Rage/Energy).
- **Status Alerts & Range Fade:** Instant `DEAD` and `OFFLINE` indicators and smooth range-based alpha dimming.
- **Interactive Targeting:** Click any card to target, right-click to open the native WoW party menu.
- **Freely Movable & Lockable:** Drag the header or any card to reposition anywhere on screen. Position is saved to `BordoUIDB.partyPos` and respects `/bordo lock`.
- **Live Test Mode:** Type `/bparty test` to immediately preview with 4 simulated party members!

### 6. 🛡️ High-Visibility Teammate Green Nameplates (`Nameplates.lua`)
- **Instant Teammate Spotting:** Floating overhead nameplates above party members are rendered with an unmistakable, **vibrant lime-green health bar** (`0.12, 0.95, 0.22`), making teammates immediately identifiable even inside swarms of 50+ red-barred monsters.
- **Custom Allied Badges:** Teammates display `🛡️ Name` (or `👑 Name` for Party Leader) with emerald borders and real-time health percentage numbers.
- **Auto-Activation:** Automatically enables friendly player nameplates upon login and when joining a party.

### 6. 💀 Death Recap (`/bordo recap`)
- Instant post-death breakdown showing the killing blow, overkill, and a chronological history of the last 6 hits received before death with exact timestamps and attacker names.

### 7. ⏱️ Boss Timeline & Encounter Tracker
- Real-time tracking of up to 6 Guardians / Minibosses with combat status and respawn timers.
- Boss schedule timeline showing active encounters, upcoming spawns, and endless boss timers.

### 7. 🎯 Smart Tooltip Placement (Damage Meter Friendly)
- Mob, add, and world unit tooltips are anchored to the **middle-right** of the screen (`RIGHT`), leaving the **bottom-right** corner completely clear for your favorite damage meters (Recount, SW_Stats, DPSMate, etc.).

---

## 📥 Installation

1. Download the latest **`BordoUI.zip`** from the [Releases](https://github.com) section.
2. Extract the ZIP archive.
3. Move the **`BordoUI`** folder into your WoW AddOns directory:
   ```text
   World of Warcraft/Interface/AddOns/BordoUI
   ```
   *(For Benilla client setups, this is typically `benilla-config/AddOns/BordoUI`)*
4. **Important:** Ensure the folder is named exactly **`BordoUI`** (not `BordoUI-main`).
5. Launch the game or type `/reload` in chat.

---

## ⌨️ Slash Commands

| Command | Description |
|---|---|
| `/bordo` or `/azs` | Toggle the detailed Damage Stats table |
| `/bparty` or `/bordo party` | Toggle Modern Party Frames (`/bparty test` for preview) |
| `/plates` or `/bordo plates` | Force-enable Teammate (vibrant green) & Enemy nameplates |
| `/bordo lock` | Lock all UI windows in place (disables dragging) |
| `/bordo unlock` | Unlock all UI windows (freely drag & reposition on screen) |
| `/bordo move` | Toggle between locked and unlocked state |
| `/bordo dmg 0.75` | Adjust floating combat text scale (0.4 – 1.5) |
| `/bordo size 0.8` | Adjust stats table window scale (0.4 – 1.5) |
| `/bordo recap` | Open the Death Recap window |
| `/bordo boss` | Toggle the Boss Schedule timeline |
| `/bordo zoom` | Unlock maximum camera distance (50 yards / 4x zoom) |
| `/bordo reset` | Reset all UI frame positions to default |
| `/cl` or `/chestlight` | Control chest radar (`/cl arrow` for direction arrow, `/cl chat` for spawn alerts) |

---

## 📜 Changelog
Full version history and updates are tracked in [CHANGELOG.md](CHANGELOG.md).

---

## 👥 Credits & Support
- **Author:** Bordo
- **Engine & Foundations:** WoW 1.12.1 Vanilla API, Chestlight Engine by Kindagrey
- **Community:** [Azeroth Survivors Discord](https://discord.gg/CXAvQ6ZTXe)
