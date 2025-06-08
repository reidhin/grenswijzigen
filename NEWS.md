# Grenswijzigen 0.1.1

* Toevoegen Vignette
* Toevoegen website

# Grenswijzigen 0.1.0

* Verwijderen renv uit het project
* Toevoegen van het jaar 2024
* Aanpassen van de omzet-matrices: de rij- en kolomnamen zijn nu strings:
  Voor gemeenten strings van lengte 4 met leading zeros,
  voor wijken strings van lengte 6 met leading zeros.
  Deze wijziging was nodig in verband met de nieuwe codering van wijken - hier
  worden nu ook letters in gebruikt. Vermoedelijk in verband met het hoge aantal
  wijken in sommige gemeenten.

# Grenswijzigen 0.0.3

* Toevoegen van het jaar 2023

# Grenswijzigen 0.0.2

* Toevoegen van het jaar 2022

# Grenswijzigen 0.0.1

* Update en uitbreiding van README

# Grenswijzigen 0.0.0.9005

* Reparatie bug: het is nu ook mogelijk om data op postcode niveau uit jaar x
  om te zetten naar regionaal niveau (wijk of gemeente) voor hetzelfde jaar x.

# Grenswijzigen 0.0.0.9004

* Toevoegen van optie om data op postcode niveau om te zetten naar regionaal
  niveau (wijk of gemeente).

# Grenswijzigen 0.0.0.9003

* Herstel van een bug - de volgorde van de ingevoerde data-frame doet er nu niet toe.

* Instructieve foutmelding bij de afwezigheid van 'gwb_code' in enkele functies.

# Grenswijzigen 0.0.0.9002

* Herstel van een bug - de code werkt nu ook in afwezigheid van wijzigingen.

# Grenswijzigen 0.0.0.9001

* Update van de omzetmatrices: het is nu mogelijk de jaren 2016 t/m 2021 om te zetten.

* Update van README met uitleg welke kolommen verplicht aanwezig moeten zijn.

* Instructieve foutmelding bij de afwezigheid van de verplichte kolommen.
