import random
import string

class TestDataGenerator:
    """
    Eigene Robot Framework Library zur Generierung von Testdaten.
    Jede öffentliche Methode (Funktion) in dieser Klasse wird automatisch
    zu einem Keyword in Robot Framework.
    """

    def get_random_name(self):
        """
        Generiert einen zufälligen Benutzernamen.
        In Robot Framework wird dies automatisch zum Keyword: "Get Random Name"
        
        Beispiel Aufruf in Robot:
        ${name}=    Get Random Name
        """
        # Erzeugt eine zufällige Zahl zwischen 1000 und 9999
        random_id = random.randint(1000, 9999)
        return f"TestUser_{random_id}"

    def get_random_email(self):
        """
        Generiert eine zufällige E-Mail-Adresse.
        In Robot Framework wird dies automatisch zum Keyword: "Get Random Email"
        
        Beispiel Aufruf in Robot:
        ${email}=    Get Random Email
        """
        # Erzeugt einen 5-stelligen String aus Kleinbuchstaben und Zahlen
        random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=5))
        return f"user_{random_string}@example.com"

