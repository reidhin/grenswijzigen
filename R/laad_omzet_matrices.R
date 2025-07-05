"
Script met functies om de omzetmatrices op te halen

Auteur: Hans Weda, rond consulting
Datum: 8 april 2021
Update: 9 mei 2022
"

laad_omzet_matrices <- function(
  van_jaar,
  naar_jaar,
  toevoeging=FALSE,
  regionaalniveau="wijk",
  postcode=FALSE
)  {
  "
  Laden van omzet matrices van het 'van_jaar' naar het 'naar_jaar'.
  De omzet-matrices zijn op wijk- of gemeenteniveau.

  Parameters:
    van_jaar: int met jaar van waar het moet worden omgezet
    naar_jaar: int met jaar waar naar toe het moet worden omgezet
    toevoeging:
      * indien toevoeging = FALSE; De matrices zijn gebouwd naar rato van het
        aantal adressen (PC6 en huisnummer). Woonfunctie of toevoeging aan het
        huisnummer worden niet meegenomen.
      * indien toevoeging = TRUE: De omzetting gebeurt naar rato van het aantal
        volledige adressen met  woonfunctie (PC6 en huisnummer, huisnummertoevoeging).
    regionaalniveau: van welk niveau moeten de matrices geladen worden? Keuze uit 'wijk' en 'gemeente'.
    postcode:
      * indien postcode = TRUE; laad de matrices om postcode om te zetten naar regio.
        Alleen beschikmaar indien toevoeging = FALSE
      * indien postcode = FALSE; laad matrices om de regionale data om te zetten
        van het ene naar andere jaar (default)

  Returns:
    De matrix voor de omzetting.
    De rij-namen zijn de wijkcodes van 'naar_jaar'
    De kolom-namen zijn de wijkcodes van 'van_jaar'
  "

  if (postcode) {
    # matrix-naam voor de omzetting van postcode naar regio
    if (toevoeging) {
      stop("De combinatie postcode=TRUE en toevoeging=TRUE is niet beschikbaar.")
    } else {
      matrix.naam <- paste0(
        "grenswijziging_",
        regionaalniveau,
        "_van_",
        van_jaar,
        '_naar_',
        naar_jaar,
        '_voor_postcode'
      )
    }
  } else {
    # matrix-naam voor de omzetting van het ene naar ander jaar (default)
    if (toevoeging) {
      matrix.naam <- paste0(
        "grenswijziging_toevoeging_",
        regionaalniveau,
        "_van_",
        van_jaar,
        '_naar_',
        naar_jaar
      )
    } else {
      matrix.naam <- paste0(
        "grenswijziging_",
        regionaalniveau,
        "_van_",
        van_jaar,
        '_naar_',
        naar_jaar
      )
    }
  }

  getdata <- function(...) {
    e <- new.env()
    name <- utils::data(list=c(...), envir = e)[1]
    e[[name]]
  }

  out <- tryCatch(
    getdata(matrix.naam),
    condition = function(e) {
      writeLines(
        sprintf(
          "De matrix '%s' bestaat niet.",
          matrix.naam
        )
      )
      writeLines(
        "
        Nieuwe matrices voor omzettingen kunnen gemaakt worden door de code
        vanuit GitLab te clonen. De code hiervoor kan in de folder 'raw-data'
        worden gevonden.
        "
      )
      stop(e)
    }
  )

  return(out)
}
