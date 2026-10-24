# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-2.6.0-brightgreen.svg)](https://github.com)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** is a sleek, modern, and high-performance all-in-one user interface suite for **Azeroth Survivors** (World of Warcraft 1.12.1 / Interface 11200). Designed for fluid responsiveness, clear combat visibility, and clean modern aesthetics.

---

## ✨ Key Features & Modules

### 1. 🛡️ Centered Combat Unit Frames & Ability Bar
- **3D Class Portraits:** Seamlessly flush with the player health bar.
- **Dynamic Class Colors:** Tailored to all 9 WoW classes.
- **Centered HUD with Racial Ability:** 6 Survivor action buttons plus a dedicated **Racial Ability slot** with golden border and real-time cooldown numbers.

### 2. ⚡ Bottom XP Bar & Kills / Gold Tracker
- **Streamlined XP Progress Bar:** High-visibility progress bar anchored at the bottom of the screen.
- **Clean Kills & Gold Display:** Replaces cluttered datatext with ONLY two centered indicators:
  - **Kills Tracker:** Red skull icon (`Art\Kills.tga`) + live kill count (`811`).
  - **Gold / Chest Ratio Tracker:** Gold coin icon (`Art\Coin.tga`) + live gold / next chest cost (`516 / 155`).
  - **Smart Affordability Glow:** When `gold >= chest`, the chest cost turns bright lime-green (`|cff33ff33`), and the coin breathes with a golden pulsing aura (`Art\PaceGlow.tga`).

### 3. 📊 Modern 4-Section Stats Window (`StatsWindow.lua`)
- **EllesmereUI/SurvivorUI Aesthetic:** Clean dark panel with colored category dividers:
  - `─── Offense ───` (Orange/Red): Crit, Crit Dmg, Damage, Haste, Echo.
  - `─── Defense ───` (Steel Blue): Health, Regen, Lifesteal, Armor, Kill Heal, Thorns, Lives.
  - `─── Reach ───` (Purple): Area, Targets, Pickup.
  - `─── Utility ───` (Emerald Green): Speed, Experience, Gold, Luck, Buff Power.
- **Always Visible:** Sits permanently on screen during runs (no need to open character window with 'C').
- **Interactive Tooltips:** Hovering any stat explains what it does and shows bonuses from worn gear.
- **Draggable & Scalable:** Reposition freely with saved coordinates (`BordoUIDB.statsPos`), resize with mouse wheel.

### 4. 🧭 Boss Timeline & Miniboss Tracker with 3D Directional Arrows (`BossTracker.lua`)
- **Zone Title & Big Run Clock:** Displays current zone (e.g. `Naxxramas`) and run clock (`4:26 / 20:00`).
- **Boss Timeline Bar:** Visual progress bar with tick marks for scheduled bosses (`3:33`, `7:33`, `11:33`, `15:33`) and green fill progress.
- **Scheduled Bosses List:** Color-coded boss entries:
  - Green (`0.30, 1.00, 0.40`) when spawned or defeated (`Anub'Rekhan 4:00 / 4:24`).
  - White/Yellow countdown when upcoming (`Noth the Plaguebringer in 3:33  8:00`).
  - Dimmed grey for future bosses (`Patchwerk 12:00`).
- **Guardians Bar:** Segment boxes with heraldic marks (`Art\LairMarks.tga` - Crossed Swords, Shield, Crown, Chalice, etc.):
  - **Dead / Respawning:** Red bar with countdown timer (`0:39`, `1:51`).
  - **Alive / Spawned:** Vibrant green bar with a **live 3D rotational directional arrow** (`Art\GuardianArrow.tga` with 64 dynamic angles) pointing toward the guardian in the 3D world relative to hero facing. Arrow glows gold when facing or near.
  - **Awake / Fighting:** Orange bar with health percentage.
- **Achievement & Elites:** Tracks "Slay 4 guardians before 8:00" progress and active elite count.

### 5. 📜 Build List (6/6) & Jewelry Panel (`BuildList.lua` + `AbilityTooltip.lua`)
- **Build List:** Shows 6 learned skills with icons, spell school colors, cooldown/interval indicator, and current rank, plus racial ability.
- **Custom Modern Ability Tooltips (`AbilityTooltip.lua`):** Intercepts game tooltips to render stylized cards with school colors, highlighted numbers, divider rules, and categorized sections (`Upgrades`, `Your bonuses`, `Talents`).
- **Jewelry Panel:** 5 equipped slots (Neck, Ring 1, Ring 2, Trinket 1, Trinket 2) with rarity-colored borders (Legendary Orange, Epic Purple, Rare Blue, etc.) and rolled stats (e.g. `+69% DMG • 77% SPLASH`, `8.8% DMG RED • +35% HP`, `+13% CRIT`).

### 6. 🗺️ Dual Minimap Pins Engine (Caches & Boss Lairs) (`MapPins.lua`)
- Renders **BOTH** Chests (`PinCache.tga`) and Boss/Guardian Lairs (`PinLair.tga` + `LairMarks.tga`).
- Active lairs shine bright; empty lairs dim softly.
- Fixed boss visibility in instances (**Naxxramas, Scarlet Monastery, Ahn'Qiraj**) with calibrated yard scaling and out-of-range edge arrows.

### 7. 👥 Teammate High-Visibility Green Health Bars
- **Overhead Nameplates (`Nameplates.lua`):** Teammates feature an unmistakable lime-green health bar (`0.12, 0.95, 0.22`) with `🛡️` or `👑` badges, making party members instantly recognizable among 50+ red enemy health bars.
- **Party Frames (`PartyFrames.lua`):** Modern unit cards with green health bars (`0.15, 0.88, 0.25`), 3D portraits, leader crowns, and live test mode (`/bordo party test`).

### 8. ⚔️ Damage Font, Highest Crit Tracker & Death Recap
- Floating combat text font customization via `DamageFont.lua`.
- Highest crit records and damage breakdown table via `StatsTable.lua` (`/bordo table`).
- Modern death recap popup window via `DeathRecap.lua`.

---

## ⌨️ Slash Commands

| Command | Action |
|---|---|
| `/bordo` or `/azs` | Toggle Attack & Crit Statistics table |
| `/bordo lock` / `/lock` | Lock all UI windows in place (prevents dragging) |
| `/bordo unlock` / `/unlock` | Unlock all UI windows for free dragging |
| `/bordo plates` / `/plates` | Force enable teammate & enemy overhead nameplates |
| `/bordo party` / `/bparty` | Toggle Party Frames |
| `/bordo party test` | Toggle Party Frames simulated test mode |
| `/bordo reset` | Reset all UI window positions to default |
