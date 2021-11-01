"
Dit script is bedoeld om de benodigde omzetmatrices te maken vanuit de
bronnen.

Auteur: Hans Weda, rond consulting
Datum: 29 september 2021
"

# libraries
library(data.table)
library(usethis)

# maak de environment leeg
rm(list=ls())

# benodigde functies
source(file.path("data-raw", "maak_omzet_matrices.R"))

# Moeten bestaande datasets opnieuw worden opgehaald?
cache <- TRUE

# Van welke jaren moeten matrices gemaakt worden?
van_jaren <- 2017:2019
naar_jaren <- 2018:2020

# welke regionale niveaus?
regionale_niveaus <- c("gemeente", "wijk")

# check of de data-documentatie al bestaat
if (!exists("R/data.R")) {
  writeLines("", "R/data.R")
}

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

# werk de documentatie bij
devtools::document()
