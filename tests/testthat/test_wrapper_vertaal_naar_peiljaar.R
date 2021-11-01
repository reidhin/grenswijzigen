library(grenswijzigingen)
library(cbsodataR)
library(dplyr)

kolommen_te_laden <- c(
  "WijkenEnBuurten", "Gemeentenaam_1",
  "AantalInwoners_5", "k_65JaarOfOuder_12",
  "GemiddeldeHuishoudensgrootte_32"
)


test_that("wrapper vertaal naar peiljaar op wijkniveau", {

  # laad de kerncijfers per wijk voor 2017 en 2018
  df <- rbind(
    cbs_get_data(
      id="83765NED",
      WijkenEnBuurten = has_substring("WK"),
      select = kolommen_te_laden
    ) %>% mutate(jaar=2017),
    cbs_get_data(
      id="84286NED",
      WijkenEnBuurten = has_substring("WK"),
      select = kolommen_te_laden
    ) %>% mutate(jaar=2018)
  ) %>% rename(
    wijkcode=WijkenEnBuurten,
    gemeentenaam=Gemeentenaam_1,
    aantal_inwoners=AantalInwoners_5,
    aantal_65plus=k_65JaarOfOuder_12
  )

  # laat de wijken in Wageningen zien
  expect_snapshot(
    filter(df, grepl("Wageningen", gemeentenaam))
  )

  # Omzetten van de data van 2017 naar 2018
  df_omgezet <- wrapper_vertaal_naar_peiljaar(
    as.data.frame(df),
    peiljaar = 2018,
    model="model.2"
  )

  # laat de wijken in Wageningen zien
  expect_snapshot(
    filter(df_omgezet, grepl("Wageningen", gemeentenaam))
  )
})


test_that("wrapper vertaal naar peiljaar op gemeenteniveau", {

  # laad de kerncijfers per wijk voor 2017 en 2018
  df <- rbind(
    cbs_get_data(
      id="84286NED",
      WijkenEnBuurten = has_substring("GM"),
      select = kolommen_te_laden
    ) %>% mutate(jaar=2018),
    cbs_get_data(
      id="84583NED",
      WijkenEnBuurten = has_substring("GM"),
      select = kolommen_te_laden
    ) %>% mutate(jaar=2019)
  ) %>% rename(
    wijkcode=WijkenEnBuurten,
    gemeentenaam=Gemeentenaam_1,
    aantal_inwoners=AantalInwoners_5,
    aantal_65plus=k_65JaarOfOuder_12
  )

  # laat de wijken in Groningen zien
  expect_snapshot(
    filter(df, grepl("^Groningen", gemeentenaam))
  )

  # Omzetten van de data van 2018 naar 2019
  df_omgezet <- wrapper_vertaal_naar_peiljaar(
    as.data.frame(df),
    peiljaar = 2019,
    model="model.2",
    regionaalniveau="gemeente"
  )

  # laat de wijken in Groningen zien
  expect_snapshot(
    filter(df_omgezet, grepl("^Groningen", gemeentenaam))
  )
})

