# Bordo UI - Modern UI Suite for Azeroth Survivors

[![Interface](https://img.shields.io/badge/Interface-11200-blue.svg)](https://github.com)
[![Version](https://img.shields.io/badge/Version-2.0.0-brightgreen.svg)](https://github.com)
[![Game](https://img.shields.io/badge/Game-World%20of%20Warcraft%201.12.1-orange.svg)](https://github.com)
[![Mod](https://img.shields.io/badge/Mod-Azeroth%20Survivors-purple.svg)](https://github.com)

**Bordo UI** ist eine moderne, aufgeräumte und leistungsstarke All-in-One Benutzeroberfläche für **Azeroth Survivors** (World of Warcraft 1.12.1 / Benilla-Client). Entwickelt von Bordo für maximale Übersicht, Reaktionsschnelligkeit und elegante Ästhetik.

---

## ✨ Features im Überblick

### 1. 🛡️ Zentrierte Unit-Frames (Player & Boss)
- **3D-Klassenportraits:** Nahtlos und bündig in den Lebensbalken integriert mit dunkler Umrandung.
- **Klassenfarben & Status:** Vollständig an alle 9 WoW-Klassen angepasst (Krieger-Braun, Magier-Hellblau, Schurken-Gelb etc.).
- **Absorb-Schilde:** Dynamische Überlagerung von Schilden auf dem Lebensbalken.
- **Zentrierte Aktionsleiste:** Zauber-Icons und Cooldown-Anzeigen direkt zwischen Spieler und Boss.

### 2. 📊 Bottom Datatext Bar & Bündiger XP-Balken
- **Kompakte Datatext-Leiste:** Zeigt Level, XP%, Kills, Gold, nächste Kistenkosten, Leben, Rerolls, Gesamtschaden und FPS in edlem Dunkel-Cyan-Design.
- **Bündiger XP-Balken:** Direkt an die Leiste angeheftet (0px Lücke). Die XP-Zahlenanzeige sitzt sauber und ungestört direkt über dem blauen Fortschrittsbalken.

### 3. 🗺️ Kisten-Radar (Battleground Caches)
- **Originalgetreue Beutel-Optik (`bag.tga` & `glow.tga`):** Schicke Beutel mit pulsierendem Gold-Glühen.
- **100% Fest & Statisch in allen Zonen:** Speziell angepasste 3D-Koordinaten-Engine für Instanzen ohne 2D-Karte (**Naxxramas, Scharlachrotes Kloster, AQ**). Die Kisten wandern beim Laufen nicht mit, sondern bleiben felsenfest auf dem Gelände verankert.
- **Richtungspfeil:** Violetter Richtungspfeil am Minimap-Rand mit Distanzanzeige zur nächsten Kiste außerhalb des Sichtfelds.
- **Cluster-Funktion:** Nahe beieinander liegende Kisten (unter 10m) werden zu einem Icon mit Kistenanzahl gebündelt.

### 4. ⚔️ Detaillierte DPS- & Statistik-Tabelle (`/bordo` oder `/azs`)
- **Fähigkeiten-Icons:** Automatischer Spellbook-Scanner und Wörterbuch zeigen vor jedem Zauber das passende 16x16 Klassen-Icon.
- **Detaillierte Metriken:** Schaden, DPS, Anteil %, Treffer, Krits, Krit-Quote und höchster Krit-Treffer.
- **Größenanpassung:** Frei skalierbar und verschiebbar.

### 5. 💀 Death Recap (`/bordo death`)
- Analysiert den tödlichen Schlag und listet die 8 stärksten Schadensquellen vor deinem Tod übersichtlich mit Icons auf.

### 6. ⏱️ Boss-Zeitplan & Multiplikatoren
- Bis zu 6 Wächter/Minibosse gleichzeitig in der Boss-Timeline und in dynamischen Encounter-Leisten.
- Multiplikatoren-Übersicht für Schaden, Cooldown, Krit-Chance, Rüstung, Flächeneffekt und Laufgeschwindigkeit.

---

## 📥 Installation

1. Lade die neueste **`BordoUI.zip`** von der [Releases-Seite](https://github.com) herunter (oder klicke oben grün auf **`Code -> Download ZIP`**).
2. Entpacke die ZIP-Datei.
3. Kopiere den Ordner **`BordoUI`** in dein WoW-Addon-Verzeichnis:
   ```text
   World of Warcraft/Interface/AddOns/BordoUI
   ```
   *(Hinweis: Bei Benilla-Installationen typischerweise `benilla-config/AddOns/BordoUI`)*
4. **Wichtig:** Achte darauf, dass der Ordner exakt **`BordoUI`** heißt (nicht `BordoUI-main`).
5. Starte das Spiel oder gib im Chat `/reload` ein.

---

## ⌨️ Chat-Befehle

| Befehl | Funktion |
|---|---|
| `/bordo` oder `/azs` | Öffnet / schließt die detaillierte Statistik-Tabelle |
| `/bordo dmg 0.75` | Ändert die Größe der schwebenden Schadenszahlen (0.4 – 1.5) |
| `/bordo size 0.8` | Ändert die Skalierung der Statistik-Tabelle (0.4 – 1.5) |
| `/bordo death` | Öffnet das Death-Recap-Fenster nach deinem Tod |
| `/bordo boss` | Blendet die Boss-Zeitplan-Liste ein oder aus |
| `/bordo zoom` | Schaltet maximalen Kamera-Zoom frei (Faktor 4 / 50 Yards) |
| `/bordo reset` | Setzt alle UI-Positionen auf die Standardwerte zurück |
| `/cl` oder `/chestlight` | Steuerung des Kisten-Radars (`/cl arrow` für Richtungspfeil, `/cl chat` für Spawn-Meldungen) |

---

## 👥 Credits & Support
- **Author:** Bordo
- **Basis & Engine:** WoW 1.12.1 Vanilla API, Chestlight Engine von Kindagrey
- **Discord:** [Azeroth Survivors Discord](https://discord.gg/CXAvQ6ZTXe)
