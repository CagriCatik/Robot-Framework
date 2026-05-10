# Robot Framework

Dieses Dokument enthält tiefgreifende, detaillierte und praxisnahe Code-Snippets für die Arbeit mit dem Robot Framework und der SeleniumLibrary. Diese Snippets decken von den Basics bis hin zu fortgeschrittenen Architektur-Patterns alles ab.

---

## 1. Setup, Teardown & Globale Konfiguration
Wie man Browser-Sessions sauber startet und wieder aufräumt, um Seiteneffekte zwischen Tests zu vermeiden.

```robot
*** Settings ***
Library           SeleniumLibrary
Suite Setup       Starte Testumgebung
Suite Teardown    Close All Browsers
Test Setup        Gehe Zur Startseite
Test Teardown     Screenshot Bei Fehler Machen

*** Variables ***
${BASE_URL}       https://meine-app.de
${BROWSER}        chrome

*** Keywords ***
Starte Testumgebung
    # Optionen übergeben (z.B. Headless für CI/CD Pipelines)
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --window-size\=1920,1080
    
    Open Browser    about:blank    ${BROWSER}    options=${chrome_options}
    Set Selenium Implicit Wait    0s    # Verhindert Konflikte mit expliziten Waits
    Set Browser Implicit Wait     0s

Gehe Zur Startseite
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    css:nav.main-menu    timeout=10s

Screenshot Bei Fehler Machen
    Run Keyword If Test Failed    Capture Page Screenshot    EMBED
```

---

## 2. Session-Management: Cookies & Logins überspringen
Ein großer Zeitfresser ist das ständige Einloggen. In echten Projekten setzt man oft einen Cookie, um direkt in die App zu springen.

```robot
*** Test Cases ***
Login via Cookie (Zeit sparen)
    [Setup]    None
    Open Browser    ${BASE_URL}    ${BROWSER}
    
    # Cookie setzen, der normalerweise nach dem Login vom Server kommt
    # Pfad und Domain müssen zur App passen!
    Add Cookie      session_id    abc123xyz_token    path=/    domain=meine-app.de
    
    # Seite neu laden - wir sind nun eingeloggt ohne das Login-Formular zu nutzen!
    Reload Page
    Wait Until Element Is Visible    id:user-dashboard    timeout=5s
```

---

## 3. Datei-Upload (Ohne OS-Dialog)
Viele Anfänger scheitern daran, den Windows-Datei-Dialog zu automatisieren. Der Trick: Man interagiert direkt mit dem versteckten `<input type="file">`.

```robot
*** Test Cases ***
Profilbild hochladen
    Go To    ${BASE_URL}/profile/settings
    
    # Den absoluten Pfad zur Datei ermitteln (Best Practice: ${CURDIR} nutzen)
    ${file_path}=    Normalize Path    ${CURDIR}/resources/images/avatar.jpg
    
    # Choose File zielt direkt auf das Input-Element, nicht auf den sichtbaren "Upload"-Button!
    Choose File    css:input[type='file']    ${file_path}
    
    Click Button   id:save-changes
    Wait Until Page Contains    Bild erfolgreich hochgeladen
```

---

## 4. Mobile Emulation (Responsive Design)
Prüfe direkt in Chrome, ob deine Seite auf einem Smartphone korrekt dargestellt wird.

```robot
*** Keywords ***
Öffne Browser als iPhone
    # Gerätetyp definieren
    ${mobile_emulation}=    Create Dictionary    deviceName=iPhone X
    
    # Chrome-Optionen konfigurieren
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_experimental_option    mobileEmulation    ${mobile_emulation}
    
    # Browser mit Emulation starten
    Create Webdriver    Chrome    options=${chrome_options}
    Go To    ${BASE_URL}
```

---

## 5. Shadow DOM (Moderne Web-Komponenten)
Standard-Selektoren (CSS/XPath) finden Elemente innerhalb eines "Shadow Roots" oft nicht. Hier hilft JavaScript-Piercing.

```robot
*** Test Cases ***
Element im Shadow DOM klicken
    # In modernen Web-Apps liegen Elemente oft tief versteckt hinter Shadow Roots
    ${element}=    Execute Javascript    
    ...    return document.querySelector('user-widget').shadowRoot.querySelector('button.logout-btn')
    
    # Jetzt mit dem von JavaScript zurückgegebenen Element interagieren
    Click Element    ${element}
```

---

## 6. Hybrid Testing: API & UI kombinieren
Nutze API-Calls (RequestsLibrary) für schnelle Vorbereitungen und prüfe dann das visuelle Ergebnis im Browser.

```robot
*** Settings ***
Library    RequestsLibrary
Library    SeleniumLibrary

*** Test Cases ***
User löschen via API und UI-Check
    # 1. API Session erstellen und User löschen (dauert Millisekunden statt Sekunden)
    Create Session    my_api    ${BASE_URL}/api
    ${resp}=    DELETE On Session    my_api    /users/42    expected_status=204
    
    # 2. Im Browser prüfen, ob der User wirklich aus der UI-Tabelle verschwunden ist
    Go To    ${BASE_URL}/user-list
    Wait Until Element Is Not Visible    id:user-42    timeout=5s
```

---

## 7. Hartnäckige Fehler: Automatische Wiederholung (Retry)
Wenn eine Webseite instabil ist oder langsame CSS-Animationen nutzt, lässt man den Befehl einfach mehrfach versuchen.

```robot
*** Test Cases ***
Warte bis Button wirklich klickbar ist
    # Versuche 5 Mal alle 2 Sekunden den Button zu klicken, bis es klappt oder Zeit abläuft
    Wait Until Keyword Succeeds    5x    2s    Klicke Und Prüfe Ergebnis

*** Keywords ***
Klicke Und Prüfe Ergebnis
    Click Button    id:submit-btn
    Page Should Contain    Daten erfolgreich gesendet
```

---

## 8. Data-Driven Testing (Templates)
Führe denselben Testablauf mit vielen verschiedenen Datensätzen aus.

```robot
*** Settings ***
Test Template    Login Validierung

*** Test Cases ***          USERNAME         PASSWORD        ERROR_MSG
Leeres Passwort             admin            ${EMPTY}        Passwort fehlt
Falscher User               nix              geheim          Benutzer unbekannt
SQL Injection Versuch       ' OR 1=1--       admin           Ungültige Eingabe

*** Keywords ***
Login Validierung
    [Arguments]    ${user}    ${pass}    ${msg}
    Input Text      id:user    ${user}
    Input Password  id:pass    ${pass}
    Click Button    id:login
    Element Should Contain    css:.error-box    ${msg}
```

---

## 9. Fortgeschrittene DOM-Elemente (iFrames & Tabs)
Wenn Elemente in Frames oder neuen Fenstern liegen.

```robot
*** Test Cases ***
Umgang mit iFrames und neuen Tabs
    # 1. In einen iFrame wechseln (z.B. Payment-Widget)
    Select Frame    id:payment-iframe
    Input Text      id:credit-card    1234-5678-9012-3456
    Unselect Frame  # WICHTIG: Wieder ins Hauptdokument zurückkehren!
    
    # 2. Klick auf Link, der einen neuen Tab öffnet
    Click Link      id:agb-link
    Switch Window   NEW
    Page Should Contain    AGB Text
    Close Window    # Schließt den neuen Tab
    Switch Window   MAIN    # Zurück zum Haupt-Tab
```

---

## 10. Listen auslesen und validieren (Collections Library)
Prüfe ganze Tabelleninhalte auf einmal.

```robot
*** Settings ***
Library    Collections

*** Test Cases ***
Tabelle auf der Webseite prüfen
    # Alle Zeilen einer Spalte holen
    ${elemente}=    Get WebElements    css:table td.username
    ${gelesene_namen}=    Create List
    
    FOR    ${element}    IN    @{elemente}
        ${text}=    Get Text    ${element}
        Append To List    ${gelesene_namen}    ${text}
    END
    
    ${erwartete_namen}=    Create List    Max    Ada    Erika
    Lists Should Be Equal    ${gelesene_namen}    ${erwartete_namen}
```

---

## 11. Native IF/ELSE Logik (Robot 5+)
Moderne Verzweigungen direkt im Testfall ohne Hilfs-Keywords.

```robot
*** Test Cases ***
Dynamische Reaktionen
    ${status}=    Get Text    id:bestell-status
    
    IF    '${status}' == 'Erfolgreich'
        Log To Console    Sieg!
        Click Button      id:quittung-laden
    ELSE IF    '${status}' == 'Wartend'
        Sleep    5s
        Reload Page
    ELSE
        Fail    Unbekannter Status: ${status}
    END
```

---

## 12. Javascript direkt ausführen
Wenn Selenium an seine Grenzen stößt (z.B. versteckte Elemente oder Scroll-Events).

```robot
*** Test Cases ***
Spezielle Browser-Aktionen
    # Ans Ende der Seite scrollen
    Execute Javascript    window.scrollTo(0, document.body.scrollHeight)
    
    # Ein Element "erzwingen" (force click)
    Execute Javascript    document.getElementById('hidden-btn').click()
```

---

## 13. Eigene Python-Libraries (Custom Libraries)
Wenn Robot-Keywords nicht mehr ausreichen (z.B. für komplexe Berechnungen, PDF-Parsing oder Datenbank-Checks), schreibst du einfach eine Python-Klasse.

### Schritt 1: Die Python-Datei (z.B. MyLibrary.py)
Jede Methode in der Klasse wird automatisch zu einem Keyword. Robot Framework wandelt `snake_case` (Python) automatisch in `Space Case` (Robot) um.

```python
import random

class MyLibrary:
    """Diese Klasse wird unsere neue Robot-Library"""

    def generiere_zufalls_passwort(self, laenge=8):
        """
        Keyword: Generiere Zufalls Passwort
        Argumente: laenge (optional, Standard 8)
        """
        zeichen = "abcdefghijkmnpqrstuvwxyz23456789"
        return ''.join(random.sample(zeichen, int(laenge)))

    def berechne_rabatt(self, preis, prozent):
        """Keyword: Berechne Rabatt"""
        return float(preis) * (1 - float(prozent)/100)
```

### Schritt 2: Einbindung im Robot-Skript
Du importierst die Datei einfach unter `*** Settings ***`.

```robot
*** Settings ***
Library    Path/To/MyLibrary.py

*** Test Cases ***
Nutze meine eigene Python Logik
    # 1. Keyword mit Rückgabewert nutzen
    ${passwort}=    Generiere Zufalls Passwort    laenge=12
    Log To Console    Neues Passwort: ${passwort}
    
    # 2. Berechnungen durchführen
    ${endpreis}=    Berechne Rabatt    100    20
    Should Be Equal As Numbers    ${endpreis}    80.0
```

### Warum macht man das? (Best Practice)
- **Komplexität verstecken:** Wenn ein Keyword in Robot 20 Zeilen lang wird, schreib es lieber in 5 Zeilen Python.
- **Wiederverwendbarkeit:** Python-Code lässt sich leichter versionieren und über mehrere Projekte teilen.
- **Performance:** Python ist bei massiven Datenverarbeitungen schneller als Robot-Keywords.

