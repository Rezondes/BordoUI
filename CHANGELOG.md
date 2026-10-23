# Changelog - Bordo UI

All notable changes to **Bordo UI** for *Azeroth Survivors* (World of Warcraft 1.12.1) are documented in this file.

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
