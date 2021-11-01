library(grenswijzigen)
library(cbsodataR)
library(dplyr)


test_that("vertaal naar peiljaar limSolve", {
  # laad de kerncijfers per wijk voor 2017 en 2018
  df <- rbind(
    cbs_get_data(
      id="83765NED",
      WijkenEnBuurten = has_substring("WK"),
      select=c("WijkenEnBuurten", "AantalInwoners_5", "k_65JaarOfOuder_12")
    ) %>% mutate(
      jaar=2017
    ),
    cbs_get_data(
      id="84286NED",
      WijkenEnBuurten = has_substring("WK"),
      select=c("WijkenEnBuurten", "AantalInwoners_5", "k_65JaarOfOuder_12")
    ) %>% mutate(
      jaar=2018
    )
  ) %>% mutate(
    gwb_code=as.numeric(gsub("\\D", "", WijkenEnBuurten))
  ) %>% select(-WijkenEnBuurten)

  # laat de wijken in Wageningen zien (gwb_code begint met 289)
  expect_snapshot(
    filter(df, grepl("^289", as.character(gwb_code)))
  )

  # Omzetten van de data van 2019 naar 2020
  df_omgezet <- vertaal_naar_peiljaar_limSolve(
    df,
    oorspronkelijk_jaar = 2017,
    peiljaar = 2018,
    type_kolommen = "aantal"
  )

  # laat de omgezette wijken in Wageningen zien
  expect_snapshot(
    filter(df_omgezet, grepl("^289", as.character(gwb_code)))
  )

})


