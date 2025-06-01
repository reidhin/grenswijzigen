#' Functie die data op postcode niveau omzet naar data op wijk- of gemeenteniveau
#'
#' @param df data.frame op postcode niveau dat omgezet moet worden.
#' @param oorspronkelijk_jaar het jaar waaruit de data in df afkomstig is.
#' @param peiljaar jaar waarnaartoe de features moeten worden omgezet
#' @param type_kolommen welk type is de kolom, 'aantal' of 'aandeel'?
#' @param regionaalniveau op welk regionaalniveau moet de omzetting plaats vinden? Keuze uit 'wijk' en 'gemeente'.
#'
#' @return Omgezet data-frame
#' @export
#'
#' @examples
#' library(grenswijzigen)
#' library(cbsodataR)
#' library(dplyr)
#'
#' # laad de bevolkingsgrootte per 4-cijferige postcode
#' df.postcode <- cbs_get_data(
#'   id = "83502NED",
#'   Geslacht = "T001038",
#'   Leeftijd = "10000",
#'   Postcode = has_substring("PC"),
#'   Perioden = "2020JJ00",
#'   select = c("Geslacht", "Leeftijd", "Postcode", "Perioden", "Bevolking_1")
#' ) %>% mutate(
#'   Postcode = gsub("\\D", "", Postcode)
#' ) %>% select("Postcode", "Bevolking_1")
#'
#' # zet om naar wijk
#' df.vertaald = vertaal_postcode_naar_regio_op_peiljaar(
#'   df.postcode,
#'   oorspronkelijk_jaar = 2020,
#'   peiljaar = 2021,
#'   type_kolommen = "aantal",
#'   regionaalniveau = "wijk"
#' )
#'
#' print(head(df.vertaald))
#' # gwb_code Bevolking_1 jaar
#' # 1     1400   23400.192 2020
#' # 2     1401   19864.358 2020
#' # 3     1402   14374.962 2020
#' # 4     1403   18545.000 2020
#' # 5     1404   11841.837 2020
#' # 6     1405    3996.121 2020
#'
#' # laad de bevolkingsgrootte uit de KWB-data
#' df.wijk <- cbs_get_data(
#'   id="85039NED",
#'   WijkenEnBuurten = has_substring("WK"),
#'   select = c("WijkenEnBuurten", "AantalInwoners_5")
#' )
#'
#' print(head(df.wijk %>% arrange(WijkenEnBuurten)))
#' # # A tibble: 6 x 2
#' #   WijkenEnBuurten AantalInwoners_5
#' #   <chr>                      <int>
#' # 1 "WK001400  "               22730
#' # 2 "WK001401  "               19695
#' # 3 "WK001402  "               14055
#' # 4 "WK001403  "               18410
#' # 5 "WK001404  "               12355
#' # 6 "WK001405  "                3290
#'
#'
vertaal_postcode_naar_regio_op_peiljaar <- function(
  df,
  oorspronkelijk_jaar,
  peiljaar,
  type_kolommen="aantal",
  regionaalniveau="wijk"
) {
  "
  Parameters:
    df: dataframe met features op postcodeniveau op basis van 1
        bepaald jaar (oorspronkelijk_jaar).
    oorspronkelijk_jaar: jaar waarin de features in df zijn gegeven
    peiljaar: jaar waarnaartoe de features moeten worden omgezet
    type_kolommen: welk type is de kolom, 'aantal' of 'aandeel'?
    regionaalniveau: op welk regionaalniveau moet de omzetting plaats vinden?
      Keuze uit 'wijk' en 'gemeente'.

  Returns:
    df: dataframe met features op wijkniveau op basis van wijkindeling van
        peiljaar
  "

  # zet de data table om naar data frame, indien nodig
  df <- as.data.frame(df)

  # check de input
  if (!("Postcode" %in% names(df))) {
    stop(
      "Het is noodzakelijk dat het data-frame naast de indicatoren ook de kolom 'Postcode' bevat. "
    )
  }

  # vind de matrix om oorspronkelijk jaar in peiljaar om te zetten
  mat <- laad_omzet_matrices(
    van_jaar = oorspronkelijk_jaar,
    naar_jaar = peiljaar,
    regionaalniveau = regionaalniveau,
    postcode = TRUE
  )

  # Vind de overlap in postcodes
  postcodes <- intersect(colnames(mat), df$Postcode)

  # neem enkel deze postcodes mee
  mat <- mat[,postcodes]
  df <- df[df$Postcode %in% postcodes,]

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

  # zet de rijen van df_omtezetten in de goede volgorde
  df <- df[match(df$Postcode, colnames(mat)),]

  # bereid de omgezette data frame voor
  df_omgezet <- data.frame(gwb_code=rownames(mat))

  if (dim(df)[1] != dim(mat)[2]){
    stop(
      sprintf(
        "Niet alle %sen van %d zijn aanwezig voor de grensomzetting!!!",
        regionaalniveau,
        oorspronkelijk_jaar
      )
    )
  }

  # zet de kolommen 1 voor 1 om
  kolommen <- setdiff(colnames(df), "Postcode")
  for (kolom in kolommen) {
    df_omgezet[,kolom] <- matrix_keer_vector(mat, df[,kolom])
  }

  # voeg extra kolommen toe
  df_omgezet[,"jaar"] <- oorspronkelijk_jaar

  # print aantal rijen
  print(
    sprintf("Aantal rijen omgezette data-frame: %d", dim(df_omgezet)[1])
  )

  return(df_omgezet)

}
