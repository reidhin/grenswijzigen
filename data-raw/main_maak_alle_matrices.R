"
Dit script is bedoeld om de benodigde omzetmatrices te maken vanuit de
bronnen.

Auteur: Hans Weda
Datum: 21 juni 2022
Update: 5 januari 2023 - toevoegen jaar 2022
Update: 1 juli 2024 - toevoegen jaar 2023
Update: 31 mei 2025 - toevoegen jaar 2024
"

# libraries
library(usethis)

# maak de environment leeg
rm(list=ls())

# benodigde functies
source(file.path("data-raw", "maak_omzet_matrices.R"))

# Moeten bestaande datasets opnieuw worden opgehaald?
cache <- TRUE

# Van welke jaren moeten matrices gemaakt worden?
van_jaren <- 2016:2023
naar_jaren <- 2017:2024

# welke regionale niveaus?
regionale_niveaus <- c("gemeente", "wijk")

# check of de data-documentatie al bestaat
if (!file.exists("R/data.R")) {
  writeLines("", "R/data.R")
}


# maak omzetmatrices voor regionale niveaus
for (naar_jaar in naar_jaren) {
  for (van_jaar in min(van_jaren):(naar_jaar-1)) {
    for (regionaalniveau in regionale_niveaus) {

      # maak voor alle combinaties van van_jaar en naar_jaar omzetmatrices
      maak_omzet_matrices(
        van_jaar,
        naar_jaar,
        cache=cache,
        regionaalniveau=regionaalniveau
      )

      # maak voor alle combinaties van van_jaar en naar_jaar omzetmatrices
      # met toevoeging
      maak_omzet_matrices_toevoeging(
        van_jaar,
        naar_jaar,
        cache=cache,
        regionaalniveau=regionaalniveau
      )

    }
  }
}

# maak omzetmatrices voor postcode omzettingen
for (naar_jaar in naar_jaren) {
  for (van_jaar in min(van_jaren):naar_jaar) {
    for (regionaalniveau in regionale_niveaus) {

      # maak voor alle combinaties voor postcode uit van_jaar en regio uit
      # naar-jaar de omzetmatrices
      maak_omzet_matrices_voor_postcode(
        van_jaar,
        naar_jaar,
        cache=cache,
        regionaalniveau=regionaalniveau
      )

    }
  }
}


# werk de documentatie bij
devtools::document()
