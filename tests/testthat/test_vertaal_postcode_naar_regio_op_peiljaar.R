library(grenswijzigen)
require(cbsodataR)
require(dplyr)


test_that("vertaal data op postcode niveau naar wijkniveau 2020 -> 2021", {

  # laad de bevolkingsgrootte per 4-cijferige postcode
  df.postcode <- cbs_get_data(
    id = "83502NED",
    Geslacht = "T001038",
    Leeftijd = "10000",
    Postcode = has_substring("PC"),
    Perioden = "2020JJ00",
    select = c("Geslacht", "Leeftijd", "Postcode", "Perioden", "Bevolking_1")
  ) %>% mutate(
    Postcode = gsub("\\D", "", Postcode)
  ) %>% select("Postcode", "Bevolking_1")

  # zet om naar wijk
  df.vertaald = vertaal_postcode_naar_regio_op_peiljaar(
    df.postcode,
    oorspronkelijk_jaar = 2020,
    peiljaar = 2021,
    type_kolommen = "aantal",
    regionaalniveau = "wijk"
  )

  # Hieronder staat de omgezette postcode data
  expect_snapshot(head(df.vertaald))
})


test_that("vertaal data op postcode niveau naar wijkniveau 2023 -> 2024", {

  # laad de bevolkingsgrootte per 4-cijferige postcode
  df.postcode <- cbs_get_data(
    id = "83502NED",
    Geslacht = "T001038",
    Leeftijd = "10000",
    Postcode = has_substring("PC"),
    Perioden = "2023JJ00",
    select = c("Geslacht", "Leeftijd", "Postcode", "Perioden", "Bevolking_1")
  ) %>% mutate(
    Postcode = gsub("\\D", "", Postcode)
  ) %>% select("Postcode", "Bevolking_1")

  # zet om naar wijk
  df.vertaald = vertaal_postcode_naar_regio_op_peiljaar(
    df.postcode,
    oorspronkelijk_jaar = 2023,
    peiljaar = 2024,
    type_kolommen = "aantal",
    regionaalniveau = "wijk"
  )

  # Hieronder staat de omgezette postcode data
  expect_snapshot(head(df.vertaald))
})
