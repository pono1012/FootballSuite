# FootballSuite ⚽

[![Rainmeter](https://img.shields.io/badge/Rainmeter-4.5%2B-blue.svg)](https://www.rainmeter.net/)
[![Version](https://img.shields.io/badge/Version-2.0.0-emerald.svg)](https://github.com/pono1012/FootballSuite/releases)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Data Source](https://img.shields.io/badge/Data%20Source-OpenLigaDB-orange.svg)](https://www.openligadb.de/)

**FootballSuite** ist ein modernes, leistungsstarkes und hochgradig anpassbares Rainmeter-Skin-Paket für Fußballbegeisterte. Es bringt Live-Tabellen, das nächste Spiel deines Lieblingsteams und ein interaktives Einstellungsmenü direkt auf deinen Desktop.

---

## Highlights & Features

### 1. Live-Tabelle (`Table`)
* **13 Wettbewerbe**: 1. Bundesliga, 2. Bundesliga, 3. Liga, Premier League, La Liga, Ligue 1, Schweizer Super League, Champions League, Europa League, Nations League, EM, WM und Copa América.
* **Dynamisches Layout (12 bis 36 Teams)**: Passt die Fensterhöhe automatisch an die tatsächliche Anzahl der Vereine an (z. B. 12 für Schweizer Liga, 18 für Bundesliga, 20 für Premier League, bis zu 36 für internationale Turniere).
* **Zonenfärbung**: Intelligente Farbbalken für Champions League, Europa League, Relegation und Abstiegsplätze je nach gewählter Liga.
* **Wappen-Erkennung**: Integrierte Club-Logos mit automatischer Zuweisung und Fallback-Handling.
* **Favoriten-Hervorhebung**: Dein Lieblingsteam wird optisch hervorgehoben.

### 2. Nächstes & Letztes Spiel (`NextMatch`)
* **Wettbewerbsübergreifende Spielsuche**: Erkennt nicht nur Ligaspiele, sondern automatisch auch Pokalspiele (z. B. DFB-Pokal) und internationale Partien deines Lieblingsteams.
* **Wettbewerbsanzeige**: Zeigt übersichtlich an, in welchem Wettbewerb das Spiel stattfindet (z. B. *DFB-Pokal*, *2. Bundesliga*, *Champions League*).
* **Große Vereinswappen & Anstoßzeiten / Endergebnisse**.

### 3. 6 Farbschemata & Themes
* **Dark Modern**: Eleganter dunkler Slate-Look mit blauen Akzenten.
* **Frost Glass**: Moderner transparenter Frosted-Glassmorphism-Stil.
* **Pitch OLED**: Echtes Schwarz für OLED-Displays mit maximalem Kontrast.
* **Clean Light**: Helles, klares Design für weiße/helle Setups.
* **Trans Weiss (100% Transparent)**: Völlig rahmenloser, transparenter Hintergrund mit reinweißer Typografie – perfekt für dunkle Desktop-Wallpaper.
* **Trans Schwarz (100% Transparent)**: Völlig rahmenloser, transparenter Hintergrund mit reinschwarzer Typografie – optimal für helle Desktop-Wallpaper.

### 4. Kontrollzentrum (`Settings`)
* 1-Klick-Themeswitcher mit Live-Vorschau und Indikator für das aktive Theme.
* Schnellauswahl der aktiven Liga.
* Interaktive Teamauswahl aus Hunderten von Vereinen oder direkte Eingabe einer beliebigen OpenLigaDB-Team-ID.

### 5. Vereinswappen (Club Badges)
Aus urheberrechtlichen Gründen enthält das Repository und die Installationsdatei keine geschützten Vereinsmarken, sondern das neutrale Ersatzwappen `default.png`.

Wer die offiziellen Vereinswappen für den privaten Eigengebrauch herunterladen möchte, kann einfach das beiliegende PowerShell-Skript ausführen:
* Rechtsklick auf `@Resources\Scripts\DownloadLogos.ps1` ➔ **Mit PowerShell ausführen**.
* Das Skript ruft die aktuellen Wappen direkt von OpenLigaDB ab und aktualisiert die Rainmeter-Skins automatisch.

---

## Voraussetzungen

* **[Rainmeter](https://www.rainmeter.net/)** 4.5.0 oder neuer
* **Windows 10 / 11**
* Aktive Internetverbindung für Live-Daten via OpenLigaDB

---

## Installation

1. Lade die neueste Datei **`FootballSuite_2.0.0.rmskin`** aus den [Releases](https://github.com/pono1012/FootballSuite/releases) herunter.
2. Führe die Datei mit einem Doppelklick aus.
3. Klicke im Rainmeter Skin Installer auf **Install**.
4. Die Widgets werden sofort geladen und können per Drag & Drop auf dem Bildschirm platziert werden.

---

## Lizenz

Dieses Projekt ist unter der **MIT License** lizenziert – siehe [LICENSE](LICENSE) für Details.

**Datenquelle**: Live-Ergebnisse und Spielplandaten stammen von der freien API von [OpenLigaDB](https://www.openligadb.de/).
