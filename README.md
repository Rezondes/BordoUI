# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-3.2.0-brightgreen.svg)](https://github.com)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** is an all-in-one user interface suite for **Azeroth Survivors** (World of Warcraft 1.12.1 / Benilla client). Powered by the comprehensive **Survivor UI & Survivor Plates** framework (by morderous) and customized with **Bordo's Signature Death Recap** and **High-Visibility Lime-Green Teammate Nameplates**.

---

## ✨ Key Features

### 1. 🛡️ Centered Combat Unit Frames & Action Bar
- **EllesmereUI/Plater-Inspired Layout:** Clean, flat unit frames and compact action bar buttons (1–6 and =) sitting under your hero.
- **Dynamic Class Colors & Absorb Shields:** Clean absorption overlays directly on unit frames.
- **Target Debuffs & Cooldowns:** Real-time debuff rows with stack counts and button cooldowns.

### 2. 🟢 High-Visibility Teammate Green Nameplates (`SurvivorPlates.lua`)
- **Instant Teammate Spotting:** Teammates in party or raid feature vibrant lime-green health bars (`0.12, 0.95, 0.22`, `130x14px`) with emerald borders and `🛡️ Name` / `👑 Leader` badges.
- **Native 1.12 Engine Integration:** Automatically calls `ShowFriendNameplates()` upon login, zone change, and party join. Teammates are always rendered even when rank-and-file enemy nameplates are filtered.
- **Execute Markers & Boss Tiers:** Enormous visual clarity with gold execute markers (30% HP), boss strata, and guardian highlights.

### 3. 💀 Bordo Death Recap System (`DeathRecap.lua`)
- **Exact Cause of Death:** Detailed fatal blow analysis with overkill calculation and chronological history of the last 7 incoming damage events.
- **HP Progression:** Displays health before hit, attacker, ability, damage taken, and health remaining.
- **Instant Access:** Automatically pops up on death, or reopen anytime with `/bordo`, `/bordo recap`, or `/recap`.

### 4. 📊 Built-In Meter, Run Panel & Career Tracker
- **Real-Time Combat Meter (`Meter.lua`):** Accurate damage, DPS, and top ability breakdowns.
- **Run Panel & History:** Full statistics, multipliers, jewelry crafting UI, pace tracker, and boss encounter bars.
- **Configurable Settings Panel:** Type `/sui opt` or `/bordo opt` to customize every aspect of the interface.

### 5. 💰 Movable Gold & Dynamic Chest Tracker (`Core.lua`)
- **Bottom-Center HUD Widget:** Clean, movable gold display showing current player gold vs. current chest price: `[Coin] 400 / 20`.
- **Dynamic Cost Scaling:** Automatically adjusts as chest costs scale higher throughout the run (`20`, `40`, `60`, ...).
- **Affordability Visual Alert:** Lights up in bright green (`|cff33ff33`) with a golden border and glowing coin icon as soon as you have enough gold to open a chest!
- **Draggable & Persistent:** Left-click and drag anywhere on screen. Position is remembered across reloads.
- **Quick Slash Command:** Use `/gold` or `/bordo gold` to reset position or toggle test preview.

### 6. 🗺️ Enhanced Minimap Boss & Lair Tracking (`MapPins.lua`)
- **All Boss Lairs Displayed:** Bosses are reliably rendered with marks and skulls, supporting both modern array coordinates and named table structures.
- **Combat & Awake Detection:** Active bosses engaged in battle are enlarged and pulse with a fiery red/orange glow.
- **Edge Direction Clamping:** Boss pins stay clamped to the minimap boundary when distant, ensuring you always know the exact direction to the nearest boss.
- **Detailed Tooltips:** Displays boss name, combat status (`AWAKE & FIGHTING!`, `Waiting in Lair`, or `Slain (Respawning)`), and exact yard distance.

### 7. 🎯 Attack & Highest Crit Statistics Table (`StatsTable.lua`)
- **Highest Crit Record Tracker:** Displays your run's **★ Highest Crit / Bester Krit** with ability name and spell icon.
- **Per-Attack Breakdown:** Tracks every ability used, spell icon, Max Crit (highlighted in gold), measured Crit Rate (% and count), and live DPS.
- **Crit Rate Comparison:** Displays your character sheet crit chance vs. measured actual combat crit rate (`Char Crit: X% | Actual: Y%`).
- **Scalable & Movable:** Scalable with `[-]` / `[+]` buttons or mousewheel over header, collapsible, draggable anywhere on screen.
- **Quick Slash Command:** Toggle with `/crit`, `/crits`, or `/bordo crit`.

### 8. 📋 Always-On Stats HUD Window (`CharacterPane.lua`)
- **No Need to Press 'C':** The full Azeroth Survivors character attribute window is permanently embedded on-screen.
- **Real-Time Attributes:** Displays all 4 categories live: Offense (Crit, Crit Dmg, Haste, Echo), Defense (Health, Regen, Lifesteal, Armor, Thorns, Lives), Reach (Area, Targets, Pickup), and Utility (Speed, XP, Gold, Luck, Buff Power).
- **Movable & Resizable:** Drag by its top grip or hold Alt and drag. Resize via bottom-right corner grip.
- **Quick Slash Command:** Toggle with `/stats` or `/bordo stats`.

### 9. 💥 Modern Floating Combat Text Font (`DamageFont.lua`)
- **Crisp Damage Font:** Replaces default Blizzard damage font with modern sans-serif font (`Media\modern.ttf`).
- **Compact 75% Scale:** Streamlines floating damage numbers so they remain readable in 50+ mob swarms without cluttering the screen.

---

## ⌨️ Slash Commands

| Command | Description |
| :--- | :--- |
| `/bordo` or `/recap` | Open the Death Recap & Lethal Hits breakdown |
| `/crit` or `/crits` | Toggle Attack & Highest Crit Statistics Table |
| `/stats` or `/bordo stats` | Toggle On-Screen Stats HUD Window (No need to press C) |
| `/gold` or `/bordo gold` | Gold & Chest Tracker options (`/gold reset` to center) |
| `/bordo opt` or `/sui opt` | Open the Survivor UI Settings Panel |
| `/bordo plates` or `/plates` | Force-enable Teammate (green) & Enemy nameplates |
| `/bordo zoom` | Unlock maximum camera distance (50 yards / 4x zoom) |
| `/bordo reset` | Reset Death Recap, Crit Table & Gold tracker positions |
| `/splates` | Configure Plater-style nameplate tiers and scaling |
| `/sui` | Survivor UI core commands (`/sui help` for details) |

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
