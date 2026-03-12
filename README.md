# GleisGuru
GleisGuru ist eine Flutter-Anwendung zur Visualisierung von Sensordaten, die über eine HTTP-API bereitgestellt werden. Die App ruft regelmäßig Daten von einem Server ab und stellt sie übersichtlich in Form von Werten und Diagrammen dar.

## Funktionen
- Abrufen von Sensordaten über eine REST-API
- Anzeige aktueller Messwerte
- Diagramme für historische Daten (z. B. Geschwindigkeit, Temperatur, Batterie)
- Einstellungsseite zur Konfiguration von Server-IP und Port
- Aktualisierung der Daten per Pull-to-Refresh
- Möglichkeit, einzelne Werte oder alle Werte zurückzusetzen
- Anzeige von Verbindungsstatus und Ladezustand

## Technologien
- **Flutter**
- **Dart**
- **fl_chart** für Diagramme
- HTTP-Kommunikation mit einer externen API


## Installation
- Lade die neuste Version von [releases](https://github.com/Lmntrixpy/gleisguru/releases/latest) herunter.
- Installiere die .exe

## Entwickeln
1. Repository klonen

```bash
git clone https://github.com/Lmntrixpy/gleisguru.git
cd gleisguru
flutter pub get # get dependencies
flutter run # run app
```

## Konfiguration
Die Verbindung zum Server wird in der **Einstellungsseite** konfiguriert.
Dort können folgende Werte gesetzt werden:
- Server IP
- Port
Die App verwendet diese Daten, um API-Anfragen an den Server zu senden.

## API
Die App erwartet eine HTTP-API, die Sensordaten liefert, zum Beispiel:
- Geschwindigkeit
- Temperatur
- Batterie
- Spannung
Zusätzlich können Endpunkte zum Zurücksetzen einzelner Werte oder aller Werte vorhanden sein.
Die genaue Implementierung der API orientiert sich an dem zugehörigen Python-Server.

## Diagramme
Die App speichert einen Verlauf bestimmter Messwerte und stellt diese als Diagramm dar:
- Geschwindigkeit
- Temperatur
- Batteriestand
- Spannung
Die Diagramme werden mit der Bibliothek **fl_chart** gerendert.
