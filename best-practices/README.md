# Tutorial-Projekt: stabile Webtests mit Robot Framework

Dieses Projekt setzt die Best Practices aus `../README.md` in ein lauffaehiges Beispiel um. Es enthaelt eine kleine Mock-Webseite und Robot-Framework-Tests, die echte User-Flows pruefen, statt technische Klickfolgen in Testfaelle zu schreiben.

## Analyse der Best Practices

Die README laeuft auf diese Architektur hinaus:

- Testfaelle beschreiben fachliche Ablaeufe wie Login, Passwort-Reset, Benutzerverwaltung und Checkout.
- Selektoren sind stabil und bevorzugen `data-testid`, `id`, `name` und fachliche XPath-Ausdruecke.
- Technische Details liegen in Keywords und Page-Resources, nicht in den Testfaellen.
- Browser-Setup, Testdaten und Locators sind zentral abgelegt.
- Tests nutzen Waits und fachliche Assertions statt `Sleep`.
- Jeder Test startet mit sauberem Zustand und ist unabhaengig ausfuehrbar.
- Negative Tests gehoeren dazu, damit Fehlermeldungen und Validierungen abgesichert sind.

## Projektstruktur

```text
tutorial-webtests/
  web/
    index.html
    styles.css
    app.js
  tests/
    login_tests.robot
    user_management_tests.robot
    checkout_tests.robot
  resources/
    common/
      browser.resource
      test_data.resource
    pages/
      login_page.resource
      dashboard_page.resource
      users_page.resource
      checkout_page.resource
  variables/
    local.py
  run_tests.ps1
  run_tests.bat
```

## Mock-Webseite

Die Webseite simuliert eine kleine Admin-Anwendung:

- Login mit gueltigen und ungueltigen Zugangsdaten
- Passwort-Reset
- Dashboard nach erfolgreichem Login
- Benutzer suchen, erstellen, bearbeiten und loeschen
- Checkout mit Pflichtfeldvalidierung

Testdaten:

```text
E-Mail:    demo@example.com
Passwort:  secret123
```

## Tests starten

Aus dem Repo-Root:

```powershell
cd .\best-practices\tutorial-webtests
.\run_tests.ps1
```

Der Runner startet einen lokalen Static-Server fuer `web/` auf `http://127.0.0.1:8010`, fuehrt die Tests aus und schreibt Report, Log und Screenshots nach `results/`.

Alternativ manuell:

```powershell
python -m http.server 8010 --bind 127.0.0.1 --directory .\web
..\..\.venv\Scripts\python.exe -m robot --variablefile .\variables\local.py --outputdir .\results .\tests
```

Die Mock-Webseite kann auch direkt im Browser geoeffnet werden:

```text
http://127.0.0.1:8010
```

## Was die Tests zeigen

- `login_tests.robot`: Happy Path, negativer Login, Passwort-Reset.
- `user_management_tests.robot`: getrennte User-Flows fuer Erstellen, Suchen, Bearbeiten, Loeschen und Pflichtfeldvalidierung.
- `checkout_tests.robot`: erfolgreicher Checkout und negativer Checkout ohne AGB-Bestaetigung.

Alle technischen Selektoren liegen in den Page-Resources. Die Testfaelle bleiben dadurch fachlich lesbar:

```robot
Admin Can Create New User
    Open User Management
    Create User    ${NEW_USER_NAME}    ${NEW_USER_EMAIL}    Editor
    User Row Should Be Visible    ${NEW_USER_NAME}
```

## Uebungen

1. Aendere im Frontend ein Button-Layout, aber lasse `data-testid` gleich. Die Tests sollten stabil bleiben.
2. Fuege einen negativen Test fuer eine ungueltige E-Mail-Adresse in der Benutzeranlage hinzu.
3. Ersetze einen stabilen Locator testweise durch einen absoluten XPath und beobachte, wie fragil der Test wird.
4. Starte einzelne Tests, zum Beispiel:

```powershell
..\..\.venv\Scripts\python.exe -m robot --variablefile .\variables\local.py --outputdir .\results --test "Login Fails With Invalid Password" .\tests
```
