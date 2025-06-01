#' Functie die indicatoren corrigeert voor grenswijzigingen
#'
#' Deze functie corrigeert indicatoren op basis van model.2. Het is
#' nodig om zelf het type indicator aan te geven ('aandeel' of 'aantal'). Het
#' wordt geadviseerd gebruik te maken van de generieke wrapper functie
#' \code{\link{wrapper_vertaal_naar_peiljaar}}. Deze functie is gebasseerd het
#' oplossen van een stelsel vergelijkingen met behulp van de functie
#' \code{\link[limSolve]{lsei}}.
#'
#' @param df dataframe met features op wijkniveau op basis van wijkindeling van
#' 1 bepaald jaar (oorspronkelijk_jaar) en peiljaar.
#' @param oorspronkelijk_jaar jaar waarin de features in df zijn gegeven
#' @param peiljaar jaar waarnaartoe de features moeten worden omgezet
#' @param type_kolommen welk type is de kolom, 'aantal' of 'aandeel'?
#' @param regionaalniveau op welk regionaalniveau moet de omzetting plaats vinden?
#' Keuze uit 'wijk' en 'gemeente'.
#'
#' @return dataframe met features op wijkniveau op basis van wijkindeling van
#' peiljaar
#' @export
#'
#' @examples
#' library(grenswijzigen)
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
#'   gwb_code=trimws(gsub("^WK", "", WijkenEnBuurten))
#' ) %>% select(-WijkenEnBuurten)
#'
#' # laat de wijken in Wageningen zien (gwb_code begint met 0289)
#' print(filter(df, grepl("^0289", gwb_code)))
#' #
#' #
#' # Omzetten van de data van 2017 naar 2018
#' df_omgezet <- vertaal_naar_peiljaar_limSolve(
#'   df,
#'   oorspronkelijk_jaar = 2017,
#'   peiljaar = 2018,
#'   type_kolommen = "aantal"
#' )
#'
#' # laat de omgezette wijken in Wageningen zien
#' print(filter(df_omgezet, grepl("^0289", gwb_code)))
#'
vertaal_naar_peiljaar_limSolve <- function(
  df,
  oorspronkelijk_jaar,
  peiljaar,
  type_kolommen="aantal",
  regionaalniveau="wijk"
) {

  # zet de data table om naar data frame, indien nodig
  df <- as.data.frame(df)

  if (!setequal(df[,"jaar"], c(oorspronkelijk_jaar, peiljaar))) {
    stop("De dataframe moet zowel het oorspronkelijke jaar als het peiljaar
         bevatten.")
  }

  # check de input
  if (!("gwb_code" %in% names(df))) {
    stop(
      "Het is noodzakelijk dat het data-frame naast de indicatoren ook de kolom 'gwb_code' bevat. ",
      "'gwb_code' bestaat uit een string die de code van de wijk of gemeente aangeeft.",
      "Voor `regionaalniveau` wijk moet deze string 6 characters bevatten met leading zeros;",
      "voor `regionaalniveau` gemeente 4 characters bevatten met leading zeros.",
    )
  }

  # indien het data frame leeg is (enkel twee kolommen: jaar en gwb-code)
  # retourneer dan een leeg data frame
  if (ncol(df) == 2) return(data.frame())

  # vind de matrix om oorspronkelijk jaar in peiljaar om te zetten
  mat <- laad_omzet_matrices(
    van_jaar = oorspronkelijk_jaar,
    naar_jaar = peiljaar,
    toevoeging = TRUE,
    regionaalniveau = regionaalniveau
  )

  # splits de df in wijken die omgezet moeten worden en wijken die zo kunnen
  # blijven
  df_onveranderd <-
    df[df[,"jaar"]==oorspronkelijk_jaar & !(df[,"gwb_code"] %in% colnames(mat)),]
  df_omtezetten <- rbind(
    df[df[,"jaar"]==oorspronkelijk_jaar & df[,"gwb_code"] %in% colnames(mat),],
    df[df[,"jaar"]==peiljaar & df[,"gwb_code"] %in% rownames(mat),]
  )

  # bereid de omgezette data frame voor
  df_omgezet <- data.frame(gwb_code=rownames(mat))

  if (dim(df_omtezetten)[1] != sum(dim(mat))){
    stop(
      sprintf(
        "Let op: alle Nederlandse %sen van 1 jaar moeten aanwezig zijn voor de grensomzetting!!!",
        regionaalniveau
      )
    )
  }

  if (nrow(df_omgezet)>0) {

    # de mat matrix is vaak te groot. Splits deze matrix op in kleinere blokken
    # en voer de omzetting om per blok
    mat.groepen <- splits_matrix_in_blokken(mat = mat)

    # zet de kolommen 1 voor 1 om
    kolommen <- setdiff(colnames(df_omtezetten), c("jaar", "gwb_code"))

    for (kolom in kolommen) {

      # creeer een leeg data frame
      temp.df <- data.frame()

      for (mat.groep in mat.groepen) {
        # Definieer alle matrices
        # minimize (least squares) \min((Ax-b)^2)
        A <- cbind(
          Matrix::Diagonal(length(mat.groep)),
          -Matrix::Diagonal(length(mat.groep))
        )
        B <- rep(0, length(mat.groep))

        mat_list <- lapply(seq_len(ncol(mat.groep)), function(i) mat.groep[,i])

        # Equality, subject to Ex=f
        # gebruik Diagonal om sparse matrices te creeeren
        E_oud <- Matrix::t(Matrix::bdiag(mat_list))
        E_nieuw <- do.call(
          cbind,
          lapply(mat_list, Matrix::Diagonal, n=nrow(mat.groep))
        )

        if (type_kolommen=="aandeel") {
          # neem gewogen som voor aandelen
          E_oud <- E_oud / Matrix::rowSums(E_oud)
          E_nieuw <- E_nieuw / Matrix::rowSums(E_nieuw)
        }

        E <- Matrix::bdiag(E_oud, E_nieuw)

        # inequality, subject to Gx>=h
        G <- Matrix::Diagonal(2*length(mat.groep))
        H <- rep(0, 2*length(mat.groep))

        # eventueel gewichten toe voegen aan minimalisatie
        Wa <- c(mat.groep)

        # zet de randvoorwaarde vast
        F.oorspronkelijk <- df_omtezetten[
          df_omtezetten$jaar==oorspronkelijk_jaar
          & df_omtezetten$gwb_code %in% colnames(mat.groep),
        ]
        F.peiljaar <- df_omtezetten[
          df_omtezetten$jaar==peiljaar
          & df_omtezetten$gwb_code %in% rownames(mat.groep),
        ]
        F <- c(
          F.oorspronkelijk[match(colnames(mat.groep), F.oorspronkelijk$gwb_code), kolom],
          F.peiljaar[match(rownames(mat.groep), F.peiljaar$gwb_code), kolom]
        )

        # vind de posities van de NA in vec
        na_posities <- is.na(F)

        # zorg dat er geen NA meer in vec aanwezig is
        F[na_posities] <- 0

        # los het lsei inverse probleem op
        res <- tryCatch(
          limSolve::lsei(A=A, B=B, E=E, F=F, G=G, H=H, fulloutput = FALSE),
          warning = function(c) {
            # Als er een fout optreedt is dit vaak te wijten aan een tegenspraak
            # in de ongelijkheden ('inequalities contradictory'). Vermoedelijk
            # heeft dit te maken met de afronding door het CBS op veelvouden van
            # 5. Dit kan omzeilt worden door de vergelijkingen ook in de
            # minimalisatie op te nemen.
            msg <- conditionMessage(c)
            if (grepl("inequalities contradictory", msg)) {
              A <- rbind(A, E)
              B <- c(B, F)
              limSolve::lsei(A=A, B=B, G=G, H=H, fulloutput = FALSE, type=2)
            } else {
              warning(msg)
            }
          }
        )

        # # bereken de nieuwe waarden
        # print(E_nieuw %*% head(res$X, length(mat.groep)))
        # print(E_nieuw %*% tail(res$X, length(mat.groep)))

        out <- as.numeric(E_nieuw %*% utils::head(res$X, length(mat.groep)))

        # vind de posities in de uit-vector die NA moeten worden gezet
        if (sum(na_posities) > 0) {
          na_out_posities <- Matrix::rowSums(
            mat.groep[,utils::head(na_posities, ncol(mat.groep)), drop=FALSE] != 0
          ) > 0
          out[na_out_posities] <- NA
        }


        # voor oorspronkelijk jaar en kolom
        kolom.df <- data.frame(
          "gwb_code"=rownames(mat.groep),
          "jaar"=oorspronkelijk_jaar,
          "berekend"=TRUE,
          "temp.naam"=out
        )
        names(kolom.df)[names(kolom.df)=="temp.naam"] <- kolom

        # voeg samen in een tijdelijke data.frame
        temp.df <- rbind(temp.df, kolom.df)

      }
      df_omgezet <- merge(df_omgezet, temp.df)
    }
  }

  # voeg extra kolommen toe
  df_onveranderd[,"berekend"] <- FALSE

  # voeg de dataframes weer samen
  df <- rbind(df_onveranderd, df_omgezet)

  # print aantal rijen
  print(
    sprintf("Aantal rijen omgezette data-frame: %d", dim(df)[1])
  )

  return(df)

}
