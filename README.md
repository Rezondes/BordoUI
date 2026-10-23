# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-2.0.0-brightgreen.svg)](https://github.com)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** is a modern, clean, and high-performance all-in-one user interface suite for **Azeroth Survivors** (World of Warcraft 1.12.1 / Benilla client). Designed by Bordo for maximum combat visibility, fluid responsiveness, and sleek dark aesthetic.

---

## ✨ Key Features

### 1. 🛡️ Centered Combat Unit Frames (Player & Boss)
- **3D Class Portraits:** Seamlessly flush with the health bar with a sleek dark border.
- **Dynamic Class Colors:** Tailored to all 9 WoW classes (Warrior brown, Mage sky blue, Rogue yellow, etc.).
- **Absorb Shields:** Clean overlay of active shield absorption amounts directly on the health bar.
- **Centered HUD:** Action bar cooldowns and abilities positioned right between you and the enemy.

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
- **Fully Scalable & Movable:** Resize with mouse wheel or [-] / [+] buttons.

### 5. 💀 Death Recap (`/bordo recap`)
- Instant post-death breakdown showing the killing blow, overkill, and a chronological history of the last 6 hits received before death with exact timestamps and attacker names.

### 6. ⏱️ Boss Timeline & Encounter Tracker
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
| `/bordo dmg 0.75` | Adjust floating combat text scale (0.4 – 1.5) |
| `/bordo size 0.8` | Adjust stats table window scale (0.4 – 1.5) |
| `/bordo recap` | Open the Death Recap window |
| `/bordo boss` | Toggle the Boss Schedule timeline |
| `/bordo zoom` | Unlock maximum camera distance (50 yards / 4x zoom) |
| `/bordo reset` | Reset all UI frame positions to default |
| `/cl` or `/chestlight` | Control chest radar (`/cl arrow` for direction arrow, `/cl chat` for spawn alerts) |

---

## 👥 Credits & Support
- **Author:** Bordo
- **Engine & Foundations:** WoW 1.12.1 Vanilla API, Chestlight Engine by Kindagrey
- **Community:** [Azeroth Survivors Discord](https://discord.gg/CXAvQ6ZTXe)
