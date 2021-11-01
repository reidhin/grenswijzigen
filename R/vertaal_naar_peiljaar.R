#' Functie die indicatoren corrigeert voor grenswijzigingen
#'
#' Deze functie corrigeert indicatoren op basis van model.0 of model.1. Het is
#' nodig om zelf het type indicator aan te geven ('aandeel' of 'aantal'). Het
#' wordt geadviseerd gebruik te maken van de generieke wrapper functie
#' \code{\link{wrapper_vertaal_naar_peiljaar}}.
#'
#' @param df dataframe met features op wijkniveau op basis van wijkindeling
#' van 1 bepaald jaar (oorspronkelijk_jaar).
#' @param oorspronkelijk_jaar  jaar waarin de features in df zijn gegeven
#' @param peiljaar jaar waarnaartoe de features moeten worden omgezet
#' @param type_kolommen welk type is de kolom, 'aantal' of 'aandeel'?
#' @param model welk model wordt gekozen? Keuze uit 'model.0' en 'model.1'.
#' * model.0 neemt alleen de postcode+huisnummer mee in de berekening
#' * model.1 neemt postcode+huisnummer+toevoeging waarvan de gebruiksfunctie 'woonfunctie' is.
#' @param regionaalniveau op welk regionaalniveau moet de omzetting plaats vinden? Keuze uit 'wijk' en 'gemeente'.
#'
#' @return  dataframe met features op wijkniveau op basis van wijkindeling van peiljaar
#' @export
#'
#' @examples
#' library(grenswijzigingen)
#' library(cbsodataR)
#' library(dplyr)
#'
#'
#' # laad de kerncijfers per wijk voor 2017 en 2018
#' df <- rbind(
#'   cbs_get_data(
#'     id="83765NED",
#'     WijkenEnBuurten = has_substring("WK"),
#'     select=c("WijkenEnBuurten", "AantalInwoners_5", "k_65JaarOfOuder_12")
#'   ) %>% mutate(
#'     jaar=2017
#'   ),
#'   cbs_get_data(
#'     id="84286NED",
#'     WijkenEnBuurten = has_substring("WK"),
#'     select=c("WijkenEnBuurten", "AantalInwoners_5", "k_65JaarOfOuder_12")
#'   ) %>% mutate(
#'     jaar=2018
#'   )
#' ) %>% mutate(
#'   gwb_code=as.numeric(gsub("\\D", "", WijkenEnBuurten))
#' ) %>% select(-WijkenEnBuurten)
#'
#' # laat de wijken in Wageningen zien (gwb_code begint met 289)
#' print(filter(df, grepl("^289", as.character(gwb_code))))
#' #
#' #
#' # Omzetten van de data van 2017 naar 2018
#' df_omgezet <- vertaal_naar_peiljaar(
#'   df %>% filter(jaar==2017),
#'   oorspronkelijk_jaar = 2017,
#'   peiljaar = 2018,
#'   type_kolommen = "aantal",
#'   model="model.1"
#' )
#'
#' # laat de omgezette wijken in Wageningen zien
#' print(filter(df_omgezet, grepl("^289", as.character(gwb_code))))
#'
vertaal_naar_peiljaar <- function(
  df,
  oorspronkelijk_jaar,
  peiljaar,
  type_kolommen="aantal",
  model="model.0",
  regionaalniveau="wijk"
) {
  # zet de data table om naar data frame, indien nodig
  df <- as.data.frame(df)

  # indien het data frame leeg is (1-kolom met gwb-code) retourneer dan een leeg
  # data frame
  if (ncol(df) == 1) return(data.frame())

  # vind de matrix om oorspronkelijk jaar in peiljaar om te zetten
  if (model=="model.0") {
    mat <- laad_omzet_matrices(
      van_jaar = oorspronkelijk_jaar,
      naar_jaar = peiljaar,
      toevoeging = FALSE,
      regionaalniveau = regionaalniveau
    )
  } else if (model=="model.1") {
    mat <- laad_omzet_matrices(
      van_jaar = oorspronkelijk_jaar,
      naar_jaar = peiljaar,
      toevoeging = TRUE,
      regionaalniveau = regionaalniveau
    )
  } else {
    stop("niet-bestaand model gekozen, kies uit c('model 0', 'model 1')")
  }

  # Als de kolommen aantallen zijn moet je normaliseren per kolom,
  # als de kolommen aandelen zijn moet je normaliseren per rij.
  switch(type_kolommen,
         aantal={
           # normaliseer de matrix per kolom
           mat <- t(t(mat) / colSums(mat))
         },
         aandeel={
           # normaliseer de matrix per rij
           mat <- mat / rowSums(mat)
         },
         stop("Verkeerde invoer voor 'type_kolommen'")
  )

  # splits de df in wijken die omgezet moeten worden en wijken die zo kunnen
  # blijven
  df_onveranderd <- df[!(df[,"gwb_code"] %in% as.numeric(colnames(mat))),]
  df_omtezetten <- df[df[,"gwb_code"] %in% as.numeric(colnames(mat)),]

  # zet de rijen van df_omtezetten in de goede volgorde
  df_omtezetten <- df_omtezetten[match(df_omtezetten$gwb_code, colnames(mat)),]

  # bereid de omgezette data frame voor
  df_omgezet <- data.frame(gwb_code=as.numeric(rownames(mat)))

  if (dim(df_omtezetten)[1] != dim(mat)[2]){
    stop(
      sprintf(
        "Let op: alle %sen van 1 jaar moeten aanwezig zijn voor de grensomzetting!!!",
        regionaalniveau
      )
    )
  }

  # zet de kolommen 1 voor 1 om
  kolommen <- setdiff(colnames(df_omtezetten), "gwb_code")
  for (kolom in kolommen) {
    df_omgezet[,kolom] <- matrix_keer_vector(mat, df_omtezetten[,kolom])
  }

  # voeg extra kolommen toe
  df_omgezet[,"berekend"] <- TRUE
  df_onveranderd[,"berekend"] <- FALSE

  # voeg de dataframes weer samen
  df <- rbind(df_onveranderd, df_omgezet)

  # voeg extra kolommen toe
  df[,"jaar"] <- oorspronkelijk_jaar

  # print aantal rijen
  writeLines(
    sprintf("Aantal rijen omgezette data-frame: %d", dim(df)[1])
  )

  return(df)

}
