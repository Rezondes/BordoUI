# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-2.7.6-brightgreen.svg)](https://github.com)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/threenox/BordoUI/total.svg?color=blue)](https://github.com/threenox/BordoUI/releases)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** is a sleek, modern, and high-performance all-in-one user interface suite for **Azeroth Survivors** (World of Warcraft 1.12.1 / Interface 11200). Designed for fluid responsiveness, clear combat visibility, and clean modern aesthetics.

---

## ✨ Key Features & Modules

### 1. 🛡️ Centered Combat HUD (`SurvivorUI` 1:1 Architecture)
- **Centered 7-Slot Action Bar (`SurvivorUIRow`):** Buttons 1 to 6 plus slot 12 (racial ability) with dark bordered backing slots, cropped icon textures (`0.08, 0.92, 0.08, 0.92`), and built-in numerical cooldown countdown overlays (`CooldownFrame_SetTimer` hook) that turn red when `< 2.0s`.
- **Player Unit Frame (`SurvivorUIPlayer`):** 150x32 class-colored health bar with 1px black border, 36x36 square cropped 3D portrait on far left, 150x3 power bar, absorb shield overlay (`ShieldStripes.tga`), player name on left, live `HP | %` on right (`257 | 100%`).
- **Player Buffs & Debuffs Row (`SurvivorUIBuffs`):** 12 aura buttons directly above the player frame with remaining duration countdowns, stack counts, black border for buffs, crimson red border for debuffs, and right-click to cancel.
- **Target Unit Frame (`SurvivorUITarget`):** Mirrored 150x32 health bar on left, 36x36 portrait on far right, power bar underneath, red for enemy (`0.80, 0.22, 0.22`), class color for player targets, name on left, `HP | %` or `%` on right. Shows when target exists, cleanly hides when no target.
- **Target Debuffs Row:** 8 debuff icons directly above target frame with stack counts.
- **Integrated Bottom XP Bar & Kills/Gold Tracker:** Full-width (650px) bar beneath the HUD featuring a sleek XP bar, Red Skull kill tracker, Gold Coin chest ratio tracker, and smart golden pulse glow when affordable!

### 2. 👥 1:1 Co-op Party Frames (`PartyFrames.lua`)
- **Anchored to Player Frame:** Positioned directly to the left of `SurvivorUIPlayer`, stacked upwards from bottom to top (`party1` at bottom).
- **Teammate Rows (165x24):** 24x24 square class icon with leader crown, 140x24 class-colored health bar, teammate name, and live health percentage.
- **Full Co-op States:** `Offline` (dark gray), `DOWN` (crimson red fill and text), `Reviving %` (gold rescue bar fill), `Reviving you` (gold text if teammate is rescuing you).
- **Live Hover Tooltip:** Shows damage dealt this run, DPS, and top damage spell (`AZS_PARTY` / `AZS_GetPartyMeter`).
- **Click-to-Target:** Left-click instantly targets teammate.
- **Revive Bar:** Visual rescue progress bar while down or bringing a friend back.
- **Test Preview Mode:** `/bordo party test` toggles sample party frames with realistic damage stats and co-op states.

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

### 9. 🎁 Top-Center Boss Loot Toast (`LootAlert.lua`)
- **Centered Boss Drop Alert:** Displays a prominent, high-visibility loot toast directly above your character when an enemy boss drops equipment or jewelry.
- **Authentic Item Icons & Quality Borders:** Real item textures (Pants, Rings, Helmets, Weapons) with glowing borders matched to item rarity (Uncommon, Rare, Epic, Legendary).
- **Clean & Focused:** Exclusively triggers on actual enemy boss drops. Level-up choices, augments, and starting amulets are cleanly filtered out.
- **Suppressed Game Engine Popups:** Automatically hides the game's default right-side popup (`AZS_SetHudShown("loot", false)`) so loot remains unified and uncluttered.
- **Fully Movable:** Alt-drag or `/bordo unlock` to position anywhere on screen.

---

## ⌨️ Slash Commands

| Command | Action |
|---|---|
| `/bordo` or `/azs` | Toggle Attack & Crit Statistics table |
| `/bordo lock` / `/lock` | Lock all UI windows in place (prevents dragging) |
| `/bordo unlock` / `/unlock` | Unlock all UI windows for free dragging |
| `/bordo testloot` | Preview Boss Loot Toast with an Epic Ring (`[Band of Accuria]`) |
| `/bordo testloot pants` | Preview Boss Loot Toast with Epic Pants (`[Wildheart Pants]`) |
| `/bordo testloot helm` | Preview Boss Loot Toast with an Epic Headpiece (`[Crown of Destruction]`) |
| `/bordo plates` / `/plates` | Force enable teammate & enemy overhead nameplates |
| `/bordo totems` | Toggle Shaman totem health bars (hidden by default) |
| `/bordo party` / `/bparty` | Toggle Party Frames |
| `/bordo party test` | Toggle Party Frames simulated test mode |
| `/bordo reset` | Reset all UI window positions to default |

---

## 🙏 Credits & Acknowledgments

Bordo UI stands on the shoulders of giants and wouldn't be possible without the incredible work of the Azeroth Survivors and Vanilla WoW addon community:

- **[Survivor UI](https://github.com/morderous/survivor-ui) by [morderous](https://github.com/morderous):**
  A huge, heartfelt thank you to **morderous** for creating the exceptional [Survivor UI](https://github.com/morderous/survivor-ui). Several components, custom artwork assets (`.tga` files in `Art/`), architecture design, and core layout implementations (such as `AbilityTooltip`, `BuildList`, `CharacterPane`, and `PartyFrames`) originate from or build upon Survivor UI, used and distributed under the terms of the **GNU General Public License v3.0 (GPL-3.0)**.
- **Azeroth Survivors Team:** For developing an outstanding game mode and exposing custom client/server API hooks (`AZS_*`).
- **Ellesmere:** For UI layout, spacing, and styling inspiration.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for the full license text.
