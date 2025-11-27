# 📶 WlanPasswords v1.0.0 📶

> **Extrahiere alle gespeicherten WLAN-Passwörter mit einem Klick!** 🔐  
> *Ein PowerShell-basiertes Tool für Windows zur einfachen Wiederherstellung von WiFi-Passwörtern.*

Ein Windows-basiertes WLAN-Passwort-Extraktions-Tool, das alle gespeicherten WiFi-Zugangsdaten von deinem PC/Laptop ausliest.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2F11-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🎯 Features

### Kernfunktionen
- **Alle Passwörter extrahieren**: Hole alle gespeicherten WLAN-Passwörter auf einmal
- **In Datei exportieren**: Speichere alle Zugangsdaten in eine Textdatei mit Zeitstempel
- **Einzelnes Netzwerk suchen**: Suche nach einem bestimmten WiFi-Netzwerk nach Namen
- **Interaktives Menü**: Einfach zu bedienende Konsolenoberfläche
- **Silent-Modus**: Nicht-interaktiv per Kommandozeile ausführen
- **About-Seite**: Mit Bart Simpson ASCII-Art! 🎭

### Sprachunterstützung
- Funktioniert mit englischen und deutschen Windows-Installationen
- Erkennt automatisch die Systemsprache für die netsh-Ausgabe

## ⚠️ Rechtlicher Hinweis

**Dieses Tool ist nur für legitime Zwecke gedacht!**

- Nutze es NUR auf deinen eigenen Geräten
- Nutze es NUR um Passwörter wiederherzustellen, die du vorher gespeichert hast
- Nutze es NICHT für unbefugten Zugriff auf Netzwerke
- Die Autoren sind NICHT verantwortlich für Missbrauch

## 🚀 Schnellstart

### Voraussetzungen
- Windows 10/11
- PowerShell 5.1 oder höher (vorinstalliert auf Windows 10/11)
- Administrator-Rechte (empfohlen für vollen Zugriff)

### Installation

1. **Herunterladen oder Klonen**
   ```bash
   git clone https://github.com/iamrealguexoxo/wlanpasswords.git
   cd wlanpasswords
   ```

2. **Tool ausführen**
   - Doppelklick auf `run.bat`
   - ODER: Rechtsklick auf `run.bat` → "Als Administrator ausführen"
   - ODER: Direkt in PowerShell ausführen:
     ```powershell
     .\WlanPasswords.ps1
     ```

### Kommandozeilen-Nutzung

```powershell
# Interaktiver Modus (Standard)
.\WlanPasswords.ps1

# Alle Passwörter direkt in Datei exportieren
.\WlanPasswords.ps1 -Export

# Silent exportieren (keine Eingabeaufforderungen)
.\WlanPasswords.ps1 -Export -Silent
```

## 🎮 Verwendung

### Hauptmenü

```
========================================
    WiFi WlanPasswords v1.0.0
========================================

  by iamrealguexoxo

  [1] Alle WLAN-Passwörter anzeigen
  [2] Alle Passwörter in Datei exportieren
  [3] Einzelnes Netzwerk suchen
  [4] Über
  [5] Beenden

========================================
```

### Optionen erklärt

| Option | Beschreibung |
|--------|--------------|
| **[1] Alle anzeigen** | Zeigt alle gespeicherten WLAN-Zugangsdaten in der Konsole |
| **[2] Exportieren** | Speichert alle Zugangsdaten in eine Textdatei |
| **[3] Suchen** | Sucht nach einem bestimmten Netzwerk per SSID |
| **[4] Über** | Zeigt Programminfo und Bart! |
| **[5] Beenden** | Schließt die Anwendung |

## 📁 Projektstruktur

```
wlanpasswords/
├── WlanPasswords.ps1    # Haupt-PowerShell-Skript
├── run.bat              # Windows Batch-Launcher
├── README.md            # Englische Dokumentation
├── README_DE.md         # Diese Datei
├── LICENSE              # MIT-Lizenz
└── .gitignore           # Git Ignore-Regeln
```

## 📄 Export-Format

Beim Exportieren von Passwörtern sieht die Datei so aus:

```
============================================
 WlanPasswords - WLAN Password Export
 by iamrealguexoxo
 Generated: 2024-01-15 14:30:00
============================================

Total profiles found: 5

============================================

SSID: MeinHeimWiFi
Password: SuperGeheimesPasswort123
--------------------------------------------

SSID: Büro-Netzwerk
Password: ArbeitPasswort456
--------------------------------------------

SSID: Café_Gast
Password: (No password / Open network)
--------------------------------------------

============================================
 End of Export
============================================
```

## ⚙️ Funktionsweise

Das Tool verwendet den in Windows eingebauten `netsh`-Befehl, um WLAN-Informationen zu extrahieren:

1. **Profile auflisten**: `netsh wlan show profiles`
2. **Passwort holen**: `netsh wlan show profile name="SSID" key=clear`

Das PowerShell-Skript analysiert die Ausgabe und extrahiert die relevanten Informationen.

## 🔧 Problembehandlung

### "Keine WLAN-Profile gefunden"
- Stelle sicher, dass du dich zuvor mit WiFi-Netzwerken verbunden hast
- Als Administrator ausführen für vollen Zugriff
- Prüfe, ob der WLAN-Dienst läuft: `services.msc` → WLAN AutoConfig

### "Zugriff verweigert"
- Rechtsklick auf `run.bat` → "Als Administrator ausführen"
- Einige Netzwerke benötigen möglicherweise erhöhte Berechtigungen

### Skript läuft nicht
- Prüfe die PowerShell-Ausführungsrichtlinie:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Oder nutze `run.bat`, welches die Ausführungsrichtlinie umgeht

## 🛡️ Sicherheitstipps

- **Lösche Export-Dateien** nach der Verwendung - sie enthalten sensible Daten!
- **Teile nicht** exportierte Passwort-Dateien
- **Verschlüssele** sensible Exporte, wenn du sie speichern musst
- Erwäge stattdessen einen **Passwort-Manager**

## 🙏 Credits

- **Erstellt von**: [iamrealguexoxo](https://github.com/iamrealguexoxo) 🎭
- **Stil von**: BartsTOK & DeadMan Projekten

## 📜 Lizenz

MIT-Lizenz - Siehe [LICENSE](LICENSE) für Details.

## 🤝 Mitwirken

Beiträge sind willkommen! Bitte:
1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Teste gründlich
4. Erstelle einen Pull Request

## 🌍 Sprachen

- **English**: [README.md](README.md)
- **Deutsch**: Diese Datei

---

**Viel Spaß mit WlanPasswords!** 📶🔐

*Denk daran: Mit großer Macht kommt große Verantwortung. Nutze es weise!* 😎
