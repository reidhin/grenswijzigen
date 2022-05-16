"
Script met functies om Wijken te vertalen naar peiljaar

Auteur: Hans Weda, rond consulting
Datum: 8 april 2021
"

source(file.path("data-raw", "AdresDataOphalen.R"))

# plek om de modellen op te slaan
model_dir <- file.path("data-raw", "models")


maak_omzet_matrices <- function(
  van_jaar,
  naar_jaar,
  cache=TRUE,
  regionaalniveau="wijk"
)  {
  "
  Creëren van omzet matrices van het 'van_jaar' naar het 'naar_jaar'.
  De omzetting gebeurt naar rato van het aantal adressen (PC6 en huisnummer).
  Woonfunctie of toevoeging aan het huisnummer worden niet meegenomen.
  De omzet-matrices zijn op wijk- of gemeenteniveau.

  Parameters:
    van_jaar: int met jaar van waar het moet worden omgezet
    naar_jaar: int met jaar waar naar toe het moet worden omgezet
    cache: indien cache=T, laadt de matrix vanuit een lokaal bestand
    regionaalniveau: op welk regionaalniveau moet de omzetting plaats vinden?
      Keuze uit 'wijk' en 'gemeente'.

  Returns:
    De matrix voor de omzetting.
    De rij-namen zijn de wijkcodes van 'naar_jaar'
    De kolom-namen zijn de wijkcodes van 'van_jaar'
  "


  # de naam van het matrix object
  matrix.naam <- paste0(
    "grenswijziging_",
    regionaalniveau,
    "_van_",
    van_jaar,
    '_naar_',
    naar_jaar
  )

  # de naam van het bestand
  full.file.name <- file.path(model_dir, paste0(matrix.naam, '.rds'))

  writeLines(
    sprintf(
      "Bereken de matrix voor de omzetting uit jaar %d naar jaar %d voor regio %s",
      van_jaar,
      naar_jaar,
      regionaalniveau
      )
  )

  # laad de adresbestanden
  dt_adres <- laad_adressen(jaren=c(van_jaar, naar_jaar))

  # Voeg de peilgemeente-code toe aan de data-table
  peildata <- dt_adres[
    Jaar==naar_jaar,
    .(PC, Huisnummer, Gemeente, Wijk, Buurt)
    ]
  setnames(
    peildata,
    c("Gemeente", "Wijk", "Buurt"),
    c("Gemeente_peil", "Wijk_peil", "Buurt_peil")
  )
  dt_adres <- merge(dt_adres[Jaar==van_jaar], peildata, by=c("PC", "Huisnummer"))

  if (regionaalniveau == "wijk") {
    # welke wijken zijn gewijzigd (op basis van adressen)
    gewijzigde_wijken <- unique(
      dt_adres[
        Wijk != Wijk_peil,
        c(Wijk, Wijk_peil)
        ]
      )

    # maak de matrix
    mat <- as.matrix(
      dcast(
        dt_adres[Wijk %in% gewijzigde_wijken, .N, by=.(Wijk, Wijk_peil)],
        Wijk_peil ~ Wijk,
        value.var = "N",
        fill=0
        ),
      rownames = "Wijk_peil"
    )
  } else if (regionaalniveau == "gemeente") {
    # welke gemeenten zijn gewijzigd (op basis van adressen)
    gewijzigde_gemeenten <- unique(
      dt_adres[
        Gemeente != Gemeente_peil,
        c(Gemeente, Gemeente_peil)
      ]
    )

    if (length(gewijzigde_gemeenten)==0) {
      # geen gewijzigde gemeenten
      mat <- matrix(NA, nrow=0, ncol=0)
    } else {
      # maak de matrix
      mat <- as.matrix(
        dcast(
          dt_adres[Gemeente %in% gewijzigde_gemeenten, .N, by=.(Gemeente, Gemeente_peil)],
          Gemeente_peil ~ Gemeente,
          value.var = "N",
          fill=0
        ),
        rownames = "Gemeente_peil"
      )
    }

  } else {
    stop("Fout in regionaalniveau")
  }


  # sla de matrix op voor later gebruik
  saveRDS(mat, full.file.name)

  # geef het matrix object de matrix.naam
  assign(matrix.naam, mat)

  # voeg toe aan het pakket
  do.call("use_data", list(as.name(matrix.naam), overwrite = TRUE))

  # voeg documentatie toe
  data.documentatie <- readLines("R/data.R")

  if (!any(grepl(matrix.naam, data.documentatie))) {
    # Deze dataset is nog niet in de documentatie opgenomen.

    # Regels om toe te voegen
    doc.plus = c(
      sprintf(
        "#' Matrix grenswijzigingen %s-%s",
        van_jaar,
        naar_jaar
      ),
      "#' ",
      sprintf(
        "#' Een matrix voor het omzetten van indicatoren uit jaar %s naar jaar %s voor regio %s",
        van_jaar,
        naar_jaar,
        regionaalniveau
      ),
      "#' De omzetting gebeurt naar rato van het aantal adressen (PC6 en huisnummer).",
      "#' Woonfunctie of toevoeging aan het huisnummer worden niet meegenomen.",
      sprintf("#' De omzet-matrices zijn op %sniveau.", regionaalniveau),
      "#' ",
      "#' @docType data",
      "#' ",
      sprintf("#' @usage data(%s)", matrix.naam),
      "#' ",
      sprintf("\"%s\"", matrix.naam)
    )

    writeLines(c(data.documentatie, doc.plus), "R/data.R")
  }

  return(NULL)
}


maak_omzet_matrices_toevoeging <- function(
  van_jaar,
  naar_jaar,
  cache=TRUE,
  regionaalniveau="wijk"
)  {
  "
  Creëren van omzet matrices van het 'van_jaar' naar het 'naar_jaar'.
  De omzetting gebeurt naar rato van het aantal volledige adressen met
  woonfunctie (PC6 en huisnummer, huisnummertoevoeging).
  De omzet-matrices zijn op wijk- of gemeenteniveau.

  Parameters:
    van_jaar: int met jaar van waar het moet worden omgezet
    naar_jaar: int met jaar waar naar toe het moet worden omgezet
    cache: indien cache=T, laadt de matrix vanuit een lokaal bestand
    regionaalniveau: op welk regionaalniveau moet de omzetting plaats vinden?
      Keuze uit 'wijk' en 'gemeente'.


  Returns:
    De matrix voor de omzetting.
    De rij-namen zijn de wijkcodes van 'naar_jaar'
    De kolom-namen zijn de wijkcodes van 'van_jaar'
  "

  # de naam van het matrix object
  matrix.naam <- paste0(
    "grenswijziging_toevoeging_",
    regionaalniveau,
    "_van_",
    van_jaar,
    '_naar_',
    naar_jaar
  )

  # bestandsnaam van het model
  full.file.name <- file.path(model_dir, paste0(matrix.naam, '.rds'))

  writeLines(
    c(
      sprintf(
        "Bereken de matrix voor de omzetting uit jaar %d naar jaar %d voor %s niveau",
        van_jaar,
        naar_jaar,
        regionaalniveau
      ),
      "Rekening houdend met huisnummertoevoegingen en gebruiksfunctie."
    )
  )

  # laad de adresbestanden
  dt_adres <- laad_adressen(jaren=c(van_jaar, naar_jaar))

  # Voeg de peilgemeente-code toe aan de data-table
  peildata <- dt_adres[
    Jaar==naar_jaar,
    .(PC, Huisnummer, Gemeente, Wijk, Buurt)
  ]
  setnames(
    peildata,
    c("Gemeente", "Wijk", "Buurt"),
    c("Gemeente_peil", "Wijk_peil", "Buurt_peil")
  )
  dt_adres <- merge(dt_adres[Jaar==van_jaar], peildata, by=c("PC", "Huisnummer"))

  # voeg aantallen eenheden woonfunctie toe aan het adres:
  # per adres (postcode + huisnummer) wordt het aantal toevoegingen met een
  # woonfunctie toegevoegd
  dt_woonfunctie <- laad_aantallen_woonfunctie()
  dt_adres <- merge(
    dt_adres,
    dt_woonfunctie,
    by=c("PC", "Huisnummer"),
    all=FALSE
  )

  if (regionaalniveau == "wijk") {

    # welke wijken zijn gewijzigd (op basis van adressen)
    gewijzigde_wijken <- unique(
      dt_adres[
        Wijk != Wijk_peil,
        c(Wijk, Wijk_peil)
      ]
    )

    # maak de matrix - sommeer over aantalen_woonfunctie
    mat <- as.matrix(
      dcast(
        dt_adres[Wijk %in% gewijzigde_wijken, .(sum_N=sum(N)), by=.(Wijk, Wijk_peil)],
        Wijk_peil ~ Wijk,
        value.var = "sum_N",
        fill=0
      ),
      rownames = "Wijk_peil"
    )

  } else if (regionaalniveau == "gemeente") {

    # welke gemeenten zijn gewijzigd (op basis van adressen)
    gewijzigde_gemeenten <- unique(
      dt_adres[
        Gemeente != Gemeente_peil,
        c(Gemeente, Gemeente_peil)
      ]
    )

    if (length(gewijzigde_gemeenten)==0) {
      # geen gewijzigde gemeenten
      mat <- matrix(NA, nrow=0, ncol=0)
    } else {

      # maak de matrix - sommeer over aantalen_woonfunctie
      mat <- as.matrix(
        dcast(
          dt_adres[Gemeente %in% gewijzigde_gemeenten, .(sum_N=sum(N)), by=.(Gemeente, Gemeente_peil)],
          Gemeente_peil ~ Gemeente,
          value.var = "sum_N",
          fill=0
        ),
        rownames = "Gemeente_peil"
      )
    }

  } else {
    stop("Fout in regionaalniveau")
  }


  # sla de matrix op voor later gebruik
  saveRDS(mat, full.file.name)

  # geef het matrix object de matrix.naam
  assign(matrix.naam, mat)

  # voeg toe aan het pakket
  do.call("use_data", list(as.name(matrix.naam), overwrite = TRUE))

  # voeg documentatie toe
  data.documentatie <- readLines("R/data.R")

  if (!any(grepl(matrix.naam, data.documentatie))) {
    # Deze dataset is nog niet in de documentatie opgenomen.

    # Regels om toe te voegen
    doc.plus = c(
      sprintf(
        "#' Matrix grenswijzigingen %s-%s",
        van_jaar,
        naar_jaar
      ),
      "#' ",
      sprintf(
        "#' Een matrix voor het omzetten van indicatoren uit jaar %s naar jaar %s voor regio %s.",
        van_jaar,
        naar_jaar,
        regionaalniveau
      ),
      "#' De omzetting gebeurt naar rato van het aantal volledige adressen met",
      "#' woonfunctie (PC6 en huisnummer, huisnummertoevoeging).",
      sprintf("#' De omzet-matrices zijn op %sniveau.", regionaalniveau),
      "#' ",
      "#' @docType data",
      "#' ",
      sprintf("#' @usage data(%s)", matrix.naam),
      "#' ",
      sprintf("\"%s\"", matrix.naam)
    )

    writeLines(c(data.documentatie, doc.plus), "R/data.R")
  }

  return(NULL)
}



maak_omzet_matrices_voor_postcode <- function(
  van_jaar,
  naar_jaar,
  cache=TRUE,
  regionaalniveau="wijk"
)  {
  "
  Creëren van omzet matrices van het 'van_jaar' naar het 'naar_jaar'.
  De omzetting gebeurt naar rato van het aantal adressen (PC6 en huisnummer).
  Woonfunctie of toevoeging aan het huisnummer worden niet meegenomen.
  De omzet-matrices zijn op van postcode niveau naar wijk- of gemeenteniveau.

  Parameters:
    van_jaar: int met jaar van waar het moet worden omgezet
    naar_jaar: int met jaar waar naar toe het moet worden omgezet
    cache: indien cache=T, laadt de matrix vanuit een lokaal bestand
    regionaalniveau: op welk regionaalniveau moet de omzetting plaats vinden?
      Keuze uit 'wijk' en 'gemeente'.


  Returns:
    De matrix voor de omzetting.
    De rij-namen zijn de gwbcodes van 'naar_jaar'
    De kolom-namen zijn de 4-cijferige postcodes van 'van_jaar'
  "

  # de naam van het matrix object
  matrix.naam <- paste0(
    "grenswijziging_",
    regionaalniveau,
    "_van_",
    van_jaar,
    '_naar_',
    naar_jaar,
    '_voor_postcode'
  )

  # bestandsnaam van het model
  full.file.name <- file.path(model_dir, paste0(matrix.naam, '.rds'))

  # check of het cache bestand bestaat voor dit jaar
  if(!file.exists(full.file.name)){
    # bestand bestaat niet
    print(
      sprintf(
        "Het bestand %s bestaat niet; opnieuw maken vanuit adres-bestanden",
        full.file.name
      )
    )
    cache = FALSE
  }

  if (cache) {
    print(
      sprintf(
        "Lees het bestand %s in van cache", full.file.name
      )
    )
    mat <- readRDS(full.file.name)
    return(mat)
  } else {
    print(
      "Maak de omzet matrix voor postcodes opnieuw vanuit de bestanden"
    )
  }

  print(
    sprintf(
      "Bereken de matrix voor de omzetting van postcode naar wijkcode uit jaar %d naar jaar %d",
      van_jaar,
      naar_jaar
    )
  )

  # laad de adresbestanden
  dt_adres <- laad_adressen(jaren=c(van_jaar, naar_jaar))

  # Voeg de peilgemeente-code toe aan de data-table
  peildata <- dt_adres[
    Jaar==naar_jaar,
    .(PC, Huisnummer, Gemeente, Wijk, Buurt)
  ]
  setnames(
    peildata,
    c("Gemeente", "Wijk", "Buurt"),
    c("Gemeente_peil", "Wijk_peil", "Buurt_peil")
  )
  dt_adres <- merge(dt_adres[Jaar==van_jaar], peildata, by=c("PC", "Huisnummer"))

  # voeg 4-cijferige postcode toe
  dt_adres[,PC4:=substr(PC, 1, 4)]

  if (regionaalniveau=="wijk") {
    # maak de matrix
    mat <- as.matrix(
      dcast(
        dt_adres[, .N, by=.(PC4, Wijk_peil)],
        Wijk_peil ~ PC4,
        value.var = "N",
        fill=0
      ),
      rownames = "Wijk_peil"
    )
  } else if (regionaalniveau=="gemeente") {
    # maak de matrix
    mat <- as.matrix(
      dcast(
        dt_adres[, .N, by=.(PC4, Gemeente_peil)],
        Gemeente_peil ~ PC4,
        value.var = "N",
        fill=0
      ),
      rownames = "Gemeente_peil"
    )
  } else {
    stop("verkeerde regionaalniveau")
  }


  # sla de matrix op voor later gebruik
  saveRDS(mat, full.file.name)

  # geef het matrix object de matrix.naam
  assign(matrix.naam, mat)

  # voeg toe aan het pakket
  do.call("use_data", list(as.name(matrix.naam), overwrite = TRUE))

  # voeg documentatie toe
  data.documentatie <- readLines("R/data.R")

  if (!any(grepl(matrix.naam, data.documentatie))) {
    # Deze dataset is nog niet in de documentatie opgenomen.

    # Regels om toe te voegen
    doc.plus = c(
      sprintf(
        "#' Matrix omzetting postcode naar regio %s-%s",
        van_jaar,
        naar_jaar
      ),
      "#' ",
      sprintf(
        "#' Een matrix voor het omzetten van indicatoren vanuit postcode uit jaar %s naar jaar %s voor regio %s",
        van_jaar,
        naar_jaar,
        regionaalniveau
      ),
      "#' De omzetting gebeurt naar rato van het aantal adressen (PC6 en huisnummer).",
      "#' Woonfunctie of toevoeging aan het huisnummer worden niet meegenomen.",
      sprintf("#' De omzet-matrices zijn op %sniveau.", regionaalniveau),
      "#' ",
      "#' @docType data",
      "#' ",
      sprintf("#' @usage data(%s)", matrix.naam),
      "#' ",
      sprintf("\"%s\"", matrix.naam)
    )

    writeLines(c(data.documentatie, doc.plus), "R/data.R")
  }



  return(NULL)

}
