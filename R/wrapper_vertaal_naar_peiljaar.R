#' Generieke functie die een data-frame omzet naar een peiljaar
#'
#' Deze functie wijzigt de indicatoren in een data-frame naar een bepaald
#' peiljaar. Het is noodzakelijk dat het data-frame naast de indicatoren ook de
#' kolommen 'jaar' en 'wijkcode' bevat. De functie maakt zelf een inschatting
#' van het type kolom: bevat deze relatieve waarden (aandelen of percentages) of
#' absolute waarden (aantallen).
#'
#' Alle modellen zijn gebasseerd op het volgen van adressen door de tijd heen.
#' Hierdoor kan worden achterhaalt bij welke wijk een adres hoort op in elk jaar.
#' Vervolgens zijn er verschillende manieren om deze informatie te benutten.
#' Er zijn drie modellen geïmplementeerd voor het uitvoeren van grenswijzigingen.
#'
#' * Model.0 gaat uit van een uniforme verdeling van wijkkenmerken over de wijk
#' heen. Dat wil zeggen dat wordt aangenomen dat kenmerken, bijvoorbeeld het
#' aantal 65-plussers, gelijkelijk verdeeld zijn over de wijk. Bij het delen
#' van de wijk in kleinere stukken kunnen deze kenmerken dan evenredig met het
#' aantal adressen in deze stukken worden toegekend. In Model.0 zijn adressen
#' gedefinieerd als postcode + huisnummer. Huisnummertoevoegingen en
#' gebruiksfunctie van adressen worden niet meegenomen.
#' Model.0 is daarmee een heel toegankelijk model dat een redelijk goede
#' grenswijziging uitvoerd, maar dat faalt in geval van wijken met veel
#' huisnummertoevoegingen (bijvoorbeeld hoogbouw of flats) en wijken met veel
#' adressen zonder woonfunctie (bijvoorbeeld winkels, scholen en fabrieken).
#'
#' * Model.1 werkt gelijk aan Model.0 maar neemt daarentegen wel de
#' huisnummertoevoeging en gebruiksfunctie van het adres mee. In Model.1 worden
#' alleen adressen met een woonfunctie beschouwt. Daarmee presteert Model.1
#' aanzienlijk beter dan Model.0 voor wijken met veel huisnummertoevoegingen
#' en andere gebruiksfuncties dan wonen. Model.1 gaat echter nog wel altijd uit
#' van een uniforme verdeling van de wijkkenmerken over de wijk heen. Daarnaast
#' wordt er een VNG api gebruikt om de huisnummertoevoegingen en gebruiksfunctie
#' te achterhalen Dat kost het tamelijk veel tijd om uit te voeren voor alle
#' adressen in Nederland. Daarom zijn ook vooraf berekende omzetmatrices
#' beschikbaar gesteld in deze repository.
#'
#' * Model.2 neemt een andere benadering. Hier worden adressen opgedeeld in
#' blokken gedefinieerd door de overlappingen tussen wijken in het ene jaar en
#' de wijken in het volgende jaar. Voor elk blok wordt een variabele
#' gedefinieerd die het gemiddelde van een wijkkenmerk in dat blok weergeeft.
#' Voor deze variabelen wordt een stelsel formules opgesteld zodat de sommen
#' van de adressen maal de gemiddelden gelijk zijn aan de wijkkenmerken zoals
#' gepubliceerd door het CBS. Daarnaast wordt aangenomen dat deze gemiddelden
#' van jaar tot jaar nauwelijks wijzigen. Dat lijkt een redelijke aanname:
#' bijvoorbeeld het gemiddelde aantal 65-plussers per adres zal van jaar tot
#' jaar ongeveer gelijk zijn. Dit stelsel vergelijkingen wordt opgelost wat tot
#' grensgewijzigde data leidt. In dit model wordt eveneens uitgegaan van
#' adressen met huisnummertoevoegingen en woonfunctie.
#'
#' @param df  data.frame dat omgezet moet worden
#' @param peiljaar jaar waarnaartoe de features moeten worden omgezet
#' @param model welk model wordt gekozen? Keuze uit c('model.0', 'model.1', 'model.2').
#'   * model.0 neemt alleen de postcode+huisnummer mee in de berekening;
#'   * model.1 neemt postcode+huisnummer+toevoeging waarvan de gebruiksfunctie 'woonfunctie' is;
#'   * model.2 lost een stelsel vergelijkingen op waarbij wordt uitgegaan van kleine
#'   wijzigingen in gemiddelde waarden per adres van jaar tot jaar
#' @param regionaalniveau op welk regionaalniveau moet de omzetting plaats vinden?
#'   Keuze uit 'wijk' en 'gemeente'.
#' @param kolommen_aantal character vector met kolomnamen van kolommen die uit
#'   aantallen bestaan, zoals 'aantal_inwoners' of 'aantal_65Plus'. Bij dit
#'   type kolommen moet voor een gecombineerde wijk de aantallen worden opgeteld.
#'   Indien deze parameter NULL is, probeert het algoritme zelf het type kolom
#'   te achterhalen.
#' @param kolommen_aandeel character vector met kolomnamen van kolommen die uit
#'   aandelen, gemiddeldes of percentages bestaan, zoals 'gemiddelde_huishoudgrootte'
#'   of 'percentage_65Plus'. Bij dit type kolommen moet voor een gecombineerde
#'   wijk een gewogen gemiddelde worden uitgerekend.
#'   Indien deze parameter NULL is, probeert het algoritme zelf het type kolom
#'   te achterhalen.
#'
#' @return Omgezet data-frame
#' @export
#'
#' @examples
#' library(grenswijzigen)
#' library(cbsodataR)
#' library(dplyr)
#'
#' kolommen_te_laden <- c(
#'   "WijkenEnBuurten", "Gemeentenaam_1",
#'   "AantalInwoners_5", "k_65JaarOfOuder_12",
#'   "GemiddeldeHuishoudensgrootte_32"
#' )
#'
#' # laad de kerncijfers per wijk voor 2017 en 2018
#' df <- rbind(
#'   cbs_get_data(
#'     id="83765NED",
#'     WijkenEnBuurten = has_substring("WK"),
#'     select = kolommen_te_laden
#'   ) %>% mutate(jaar=2017),
#'   cbs_get_data(
#'     id="84286NED",
#'     WijkenEnBuurten = has_substring("WK"),
#'     select = kolommen_te_laden
#'   ) %>% mutate(jaar=2018)
#' ) %>% rename(
#'   wijkcode=WijkenEnBuurten,
#'   gemeentenaam=Gemeentenaam_1,
#'   aantal_inwoners=AantalInwoners_5,
#'   aantal_65plus=k_65JaarOfOuder_12
#' )
#'
#' # laat de wijken in Wageningen zien
#' print(filter(df, grepl("Wageningen", gemeentenaam)))
#'
#' # Omzetten van de data van 2017 naar 2018
#' df_omgezet <- wrapper_vertaal_naar_peiljaar(
#'   as.data.frame(df),
#'   peiljaar = 2018,
#'   model="model.2"
#' )
#'
#'
#' # laat de wijken in Wageningen zien
#' print(filter(df_omgezet, grepl("Wageningen", gemeentenaam)))
#'
wrapper_vertaal_naar_peiljaar <- function(
  df,
  peiljaar,
  model = "model.0",
  regionaalniveau = "wijk",
  kolommen_aantal = NULL,
  kolommen_aandeel = NULL
) {

  # check de input
  if (!("jaar" %in% names(df))) {
    stop(
      "Het is noodzakelijk dat het data-frame naast de indicatoren ook de kolommen 'jaar' en 'wijkcode' bevat. ",
      "Het 'jaar' refereert aan de wijkindeling die voor de indicatoren gebruikt is."
    )
  }

  if (!("wijkcode" %in% names(df))) {
    stop(
      "Het is noodzakelijk dat het data-frame naast de indicatoren ook de kolommen 'jaar' en 'wijkcode' bevat. ",
      "De wijkcode bevat de ",
      "[gwb-code](https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/gemeente/gemeenten-en-regionale-indelingen/codering-gebieden) ",
      "van de wijk in de vorm 'WK036375'."
    )
  }

  # vorm de gwb_code om voor een merge
  df$gwb_code <- as.numeric(gsub("\\D", "", df$wijkcode))

  # welke jaren moeten worden omgezet?
  omtezetten_jaren <- setdiff(unique(df$jaar), peiljaar)

  # wat zijn de gemeente en wijknamen?
  namen <- df[
    df$jaar==peiljaar,
    intersect(
      c("wijknaam", "gemeentenaam", "gwb_code", "wijkcode", "gemeentecode"),
      names(df)
    )
  ]

  if (is.null(kolommen_aantal)) {
    # wat zijn de 'aantal' kolommen?
    kolommen_aantal <- grep("^aantal", names(df), value=TRUE)
  }

  if (is.null(kolommen_aandeel)) {
    # wat zijn de 'aandeel' kolommen?
    kolommen_aandeel <- grep(
      "oppervlakt",
      grep(
        "^aandeel|^relatief|^gemiddeld|^percentage|dichtheid|^L\\d{2}",
        names(df),
        value = TRUE,
        ignore.case = TRUE
      ),
      invert=T,
      value=T
    )
  }

  # De volgende kolommen worden niet meegenomen
  writeLines("----------------------------")
  writeLines("De volgende kolommen worden niet meegenomen in de grensomzetting")
  writeLines(
    setdiff(
      setdiff(names(df), kolommen_aantal),
      kolommen_aandeel
    )
  )
  writeLines("----------------------------")


  # maak de initiele omgezette data-frame
  df_omgezet <- data.frame()
  if (peiljaar %in% unique(df$jaar)) {
    df_omgezet <- df[
      df$jaar==peiljaar,
      c("gwb_code", "jaar", kolommen_aantal, kolommen_aandeel)
    ]
    df_omgezet[,"berekend"] <- FALSE
  }

  if (model=="model.2") {
    for (jaar in omtezetten_jaren) {
      df_omgezet <- rbind(
        df_omgezet,
        speciale_merge(
          vertaal_naar_peiljaar_limSolve(
            df[
              df$jaar %in% c(jaar, peiljaar),
              c("gwb_code", "jaar", kolommen_aantal)
            ],
            oorspronkelijk_jaar = jaar,
            peiljaar = peiljaar,
            type_kolommen = "aantal",
            regionaalniveau = regionaalniveau
          ),
          vertaal_naar_peiljaar_limSolve(
            df[
              df$jaar %in% c(jaar, peiljaar),
              c("gwb_code", "jaar", kolommen_aandeel)
            ],
            oorspronkelijk_jaar = jaar,
            peiljaar = peiljaar,
            type_kolommen = "aandeel",
            regionaalniveau = regionaalniveau
          )
        )
      )
    }
  } else {
    # voeg de jaren 1 voor 1 toe
    for (jaar in omtezetten_jaren) {
      df_omgezet <- rbind(
        df_omgezet,
        speciale_merge(
          vertaal_naar_peiljaar(
            df[df$jaar==jaar, c("gwb_code", kolommen_aantal)],
            oorspronkelijk_jaar = jaar,
            peiljaar = peiljaar,
            type_kolommen = "aantal",
            model = model,
            regionaalniveau = regionaalniveau
          ),
          vertaal_naar_peiljaar(
            df[df$jaar==jaar, c("gwb_code", kolommen_aandeel)],
            oorspronkelijk_jaar = jaar,
            peiljaar = peiljaar,
            type_kolommen = "aandeel",
            model = model,
            regionaalniveau = regionaalniveau
          )
        )
      )
    }
  }

  # voeg namen toe
  df_omgezet <- merge(
    df_omgezet,
    namen,
    by="gwb_code",
    all.y=T
  )

  return(df_omgezet)
}
