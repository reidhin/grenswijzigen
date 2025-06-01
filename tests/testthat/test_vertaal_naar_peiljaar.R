library(grenswijzigen)
library(cbsodataR)
library(dplyr)


test_that("vertaal naar peiljaar", {
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
    gwb_code=trimws(gsub("^WK", "", WijkenEnBuurten))
  ) %>% select(-WijkenEnBuurten)

  # laat de wijken in Wageningen zien (gwb_code begint met 0289)
  expect_snapshot(
    filter(df, grepl("^0289", gwb_code))
  )

  # Omzetten van de data van 2017 naar 2018
  df_omgezet <- vertaal_naar_peiljaar(
    df %>% filter(jaar==2017),
    oorspronkelijk_jaar = 2017,
    peiljaar = 2018,
    type_kolommen = "aantal",
    model="model.1"
  )

  # laat de omgezette wijken in Wageningen zien
  expect_snapshot(
    filter(df_omgezet, grepl("^0289", gwb_code))
  )

})


