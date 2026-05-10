# Best Practices für Webseiten-Tests mit Robot Framework

## 1. Nicht die Webseite „durchscannen“, sondern User-Flows testen

Teste keine technischen Details, sondern fachliche Abläufe.

Beispiele:

```text
Login
Registrierung
Passwort zurücksetzen
Produkt suchen
Formular absenden
Eintrag bearbeiten
Eintrag löschen
Checkout
```

Ein guter Test beschreibt, was ein Nutzer tut:

```robot
*** Test Cases ***
User Can Login Successfully
    Open Login Page
    Login With Credentials    demo@example.com    secret123
    Dashboard Should Be Visible
```

Nicht so:

```robot
*** Test Cases ***
Click Many Elements
    Click Element    xpath:/html/body/div[2]/div[1]/button
    Input Text       css:.input-abc123    demo@example.com
```

---

## 2. Stabile Selektoren priorisieren

Verwende Selektoren in dieser Reihenfolge:

```text
1. data-testid / data-test / data-qa
2. id
3. name
4. aria-label / role / label
5. stabiler CSS-Selektor
6. fachlich sinnvoller XPath
7. absoluter XPath nur als Notlösung
```

Gut:

```robot
Click Element    css:[data-testid="login-submit"]
Input Text       id:email    demo@example.com
Input Text       name:password    secret123
```

Schlecht:

```robot
Click Element    xpath:/html/body/div[3]/div[2]/button[1]
Click Element    css:.css-1a2b3c
```

Absolute XPaths und generierte CSS-Klassen sind instabil.

---

## 3. `data-testid` gezielt im Frontend einbauen

Wenn du Einfluss auf das Frontend hast, lass wichtige Elemente mit Test-Attributen versehen.

```html
<input data-testid="login-email" />
<input data-testid="login-password" />
<button data-testid="login-submit">Login</button>
```

Robot Framework:

```robot
Input Text       css:[data-testid="login-email"]       demo@example.com
Input Text       css:[data-testid="login-password"]    secret123
Click Element    css:[data-testid="login-submit"]
```

Das ist meist die wartungsärmste Lösung.

---

## 4. XPath nur verwenden, wenn er fachlich sinnvoll ist

XPath ist nicht grundsätzlich schlecht. Schlecht sind nur fragile XPaths.

Gut:

```robot
Click Element    xpath://button[normalize-space(.)="Speichern"]
```

Gut für Tabellen:

```robot
Click Element    xpath://tr[td[normalize-space(.)="Max Mustermann"]]//button[normalize-space(.)="Bearbeiten"]
```

Gut für Label/Input-Beziehungen:

```robot
Input Text    xpath://label[normalize-space(.)="E-Mail"]/following::input[1]    test@example.com
```

Schlecht:

```robot
Click Element    xpath:/html/body/div[4]/div[2]/div[3]/button
```

---

## 5. Selektoren zentral verwalten

Selektoren nicht überall in Testfällen verstreuen.

Besser:

```robot
*** Variables ***
${LOGIN_EMAIL}       css:[data-testid="login-email"]
${LOGIN_PASSWORD}    css:[data-testid="login-password"]
${LOGIN_BUTTON}      css:[data-testid="login-submit"]
${DASHBOARD_TITLE}   css:[data-testid="dashboard-title"]
```

Dann in Keywords verwenden:

```robot
*** Keywords ***
Login With Credentials
    [Arguments]    ${email}    ${password}
    Input Text       ${LOGIN_EMAIL}       ${email}
    Input Text       ${LOGIN_PASSWORD}    ${password}
    Click Element    ${LOGIN_BUTTON}
```

Vorteil: Wenn sich ein Selektor ändert, änderst du ihn nur an einer Stelle.

---

## 6. Fachliche Keywords statt technische Klickskripte

Ein Testfall sollte lesbar sein wie eine fachliche Beschreibung.

Gut:

```robot
*** Test Cases ***
User Can Reset Password
    Open Password Reset Page
    Request Password Reset For    demo@example.com
    Password Reset Confirmation Should Be Visible
```

Weniger gut:

```robot
*** Test Cases ***
User Can Reset Password
    Click Element    css:.menu > div:nth-child(2)
    Click Element    xpath://a[normalize-space(.)="Forgot password"]
    Input Text       id:email    demo@example.com
    Click Element    css:.btn-primary
    Page Should Contain    Email sent
```

Technische Details gehören in Keywords, nicht in den Testfall.

---

## 7. Keine festen Sleeps verwenden

Schlecht:

```robot
Sleep    5s
Click Element    ${LOGIN_BUTTON}
```

Besser:

```robot
Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=10s
Click Element    ${LOGIN_BUTTON}
```

Oder bei Browser Library:

```robot
Wait For Elements State    ${LOGIN_BUTTON}    visible    timeout=10s
Click    ${LOGIN_BUTTON}
```

Feste Sleeps machen Tests langsam und trotzdem instabil.

---

## 8. Nach Aktionen immer fachlich prüfen

Nicht nur klicken, sondern Ergebnis validieren.

Schlecht:

```robot
Click Element    ${LOGIN_BUTTON}
```

Gut:

```robot
Click Element    ${LOGIN_BUTTON}
Page Should Contain Element    ${DASHBOARD_TITLE}
```

Oder:

```robot
Click Element    ${SAVE_BUTTON}
Page Should Contain    Änderungen wurden gespeichert
```

Jeder Test braucht klare Assertions.

---

## 9. Testdaten kontrolliert halten

Nutze stabile Testdaten und vermeide Abhängigkeiten zwischen Tests.

Gut:

```robot
*** Variables ***
${VALID_USER_EMAIL}       demo@example.com
${VALID_USER_PASSWORD}    secret123
```

Besser bei größeren Projekten:

```robot
*** Variables ***
${TEST_USER_EMAIL}        %{TEST_USER_EMAIL}
${TEST_USER_PASSWORD}     %{TEST_USER_PASSWORD}
```

Dann kommen Zugangsdaten aus Umgebungsvariablen, nicht aus dem Repository.

---

## 10. Tests unabhängig voneinander schreiben

Ein Test sollte nicht voraussetzen, dass ein anderer Test vorher erfolgreich war.

Schlecht:

```text
Test 1 erstellt Benutzer
Test 2 bearbeitet denselben Benutzer
Test 3 löscht denselben Benutzer
```

Besser:

```text
Jeder Test erzeugt oder nutzt seine eigenen definierten Testdaten.
Jeder Test räumt relevante Daten wieder auf.
```

So kann man Tests einzeln, parallel und zuverlässig ausführen.

---

## 11. Saubere Projektstruktur verwenden

Beispielstruktur:

```text
tests/
  login_tests.robot
  user_management_tests.robot

resources/
  pages/
    login_page.robot
    dashboard_page.robot
    user_page.robot
  common/
    browser.robot
    assertions.robot
    test_data.robot

variables/
  dev.yaml
  staging.yaml
```

Beispiel:

```robot
*** Settings ***
Resource    ../resources/pages/login_page.robot
Resource    ../resources/pages/dashboard_page.robot
```

Das hält Tests lesbar und wartbar.

---

## 12. Browser-Setup zentralisieren

Nicht in jedem Test Browser-Setup wiederholen.

```robot
*** Settings ***
Suite Setup       Open Test Browser
Suite Teardown    Close Browser
```

```robot
*** Keywords ***
Open Test Browser
    Open Browser    ${BASE_URL}    chrome
    Maximize Browser Window
```

Bei Browser Library:

```robot
*** Keywords ***
Open Test Browser
    New Browser    chromium    headless=${HEADLESS}
    New Context
    New Page    ${BASE_URL}
```

---

## 13. Umgebung konfigurierbar machen

Keine URLs hart in Tests schreiben.

Schlecht:

```robot
Open Browser    https://staging.example.com/login    chrome
```

Gut:

```robot
Open Browser    ${BASE_URL}/login    chrome
```

Start über Kommandozeile:

```bash
robot --variable BASE_URL:https://staging.example.com tests/
```

Oder:

```bash
robot --variablefile variables/staging.yaml tests/
```

---

## 14. Fehler sichtbar machen

Aktiviere Screenshots bei Fehlern.

SeleniumLibrary:

```robot
Register Keyword To Run On Failure    Capture Page Screenshot
```

Browser Library:

```robot
Take Screenshot
```

Hilfreich sind außerdem:

```text
HTML-Report
Log-Datei
Screenshots
Browser-Konsole
Netzwerkfehler
Videorecording, falls Browser Library / Playwright genutzt wird
```

---

## 15. Browser Library für neue Projekte prüfen

Für neue Web-Tests ist die Robot Framework Browser Library oft angenehmer, weil sie auf Playwright basiert.

Beispiel:

```robot
*** Settings ***
Library    Browser

*** Test Cases ***
User Can Login
    New Browser    chromium    headless=false
    New Page    ${BASE_URL}/login
    Fill Text    css:[data-testid="login-email"]       demo@example.com
    Fill Text    css:[data-testid="login-password"]    secret123
    Click        css:[data-testid="login-submit"]
    Get Text     css:[data-testid="dashboard-title"]    ==    Dashboard
```

SeleniumLibrary ist ebenfalls möglich, besonders bei bestehenden Projekten.

---

## 16. Locators aus Browser/DevTools schnell extrahieren

Nutze DevTools, aber kopiere nicht blind den XPath.

Schneller Analyse-Snippet für die Browser-Konsole:

```javascript
(() => {
  const elements = [...document.querySelectorAll(
    'input, button, select, textarea, a, [role], [data-testid], [data-test], [data-qa], label'
  )];

  console.table(elements.map((el, i) => ({
    index: i,
    tag: el.tagName.toLowerCase(),
    text: (el.innerText || el.value || '').trim().slice(0, 80),
    id: el.id || '',
    name: el.getAttribute('name') || '',
    type: el.getAttribute('type') || '',
    role: el.getAttribute('role') || '',
    aria: el.getAttribute('aria-label') || '',
    testid:
      el.getAttribute('data-testid') ||
      el.getAttribute('data-test') ||
      el.getAttribute('data-qa') ||
      '',
    suggestedSelector:
      el.getAttribute('data-testid') ? `css:[data-testid="${el.getAttribute('data-testid')}"]` :
      el.getAttribute('data-test') ? `css:[data-test="${el.getAttribute('data-test')}"]` :
      el.getAttribute('data-qa') ? `css:[data-qa="${el.getAttribute('data-qa')}"]` :
      el.id ? `id:${el.id}` :
      el.getAttribute('name') ? `name:${el.getAttribute('name')}` :
      el.getAttribute('aria-label') ? `css:[aria-label="${el.getAttribute('aria-label')}"]` :
      el.innerText?.trim() ? `xpath://${el.tagName.toLowerCase()}[normalize-space(.)="${el.innerText.trim()}"]` :
      ''
  })));
})();
```

Ziel: schnell erkennen, welche Elemente testbar sind.

---

## 17. Assertions gezielt und robust wählen

Nicht zu breite Prüfungen:

```robot
Page Should Contain    OK
```

Besser:

```robot
Element Text Should Be    ${SUCCESS_MESSAGE}    Benutzer wurde gespeichert
```

Oder:

```robot
Page Should Contain Element    ${USER_TABLE}
Page Should Contain Element    xpath://tr[td[normalize-space(.)="${USERNAME}"]]
```

Prüfe das relevante Ergebnis, nicht irgendeinen zufälligen Text auf der Seite.

---

## 18. Negative Tests ergänzen

Nicht nur Happy Path testen.

Beispiele:

```text
Login mit falschem Passwort
Pflichtfeld leer
Ungültige E-Mail-Adresse
Zu kurzes Passwort
Keine Berechtigung
Session abgelaufen
Serverfehler / Fehlermeldung
```

Beispiel:

```robot
*** Test Cases ***
Login Fails With Invalid Password
    Open Login Page
    Login With Credentials    demo@example.com    wrong-password
    Login Error Should Be Visible
```

---

## 19. Tests nicht zu groß machen

Ein Test sollte einen klaren Zweck haben.

Schlecht:

```text
Ein Test macht Login, Benutzeranlage, Bearbeitung, Suche, Export und Logout.
```

Besser:

```text
Test 1: Login funktioniert
Test 2: Benutzer kann erstellt werden
Test 3: Benutzer kann gesucht werden
Test 4: Benutzer kann bearbeitet werden
```

Große Tests sind schwer zu debuggen.

---

## 20. Naming Convention verwenden

Gute Namen:

```robot
*** Test Cases ***
User Can Login With Valid Credentials
Login Fails With Invalid Password
Admin Can Create New User
User Cannot Save Form Without Required Fields
```

Gute Keyword-Namen:

```robot
Open Login Page
Login With Credentials
Submit Login Form
Dashboard Should Be Visible
Error Message Should Be Visible
```

Schlechte Namen:

```robot
Test Login
Click Button
Check Page
Do Stuff
```

---

## Kompakte Checkliste

- [ ] Testet der Fall einen echten User-Flow?
- [ ] Sind Selektoren stabil?
- [ ] Werden data-testid/id/name bevorzugt?
- [ ] Sind XPaths fachlich und nicht absolut?
- [ ] Sind Selektoren zentral abgelegt?
- [ ] Sind Tests lesbar durch Keywords?
- [ ] Gibt es keine festen Sleeps?
- [ ] Gibt es klare Assertions?
- [ ] Sind Testdaten kontrolliert?
- [ ] Sind Tests unabhängig?
- [ ] Ist die Umgebung konfigurierbar?
- [ ] Werden Screenshots/Logs bei Fehlern erzeugt?
- [ ] Sind negative Fälle abgedeckt?


## Grundregel

Ein guter Robot-Framework-Webtest sollte fachlich lesbar sein und technisch stabil bleiben, auch wenn sich Layout oder CSS-Klassen ändern.
