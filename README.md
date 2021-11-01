
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Grenswijzigingen

<!-- badges: start -->
<!-- badges: end -->

Deze repository bevat de code voor grenswijzigingen.

Dit is experimentele code waar nog aan gewerkt wordt!

## Modellen

Alle modellen zijn gebasseerd op het volgen van adressen door de tijd
heen. Hierdoor kan worden achterhaalt bij welke wijk een adres hoort op
in elk jaar. Vervolgens zijn er verschillende manieren om deze
informatie te benutten. In deze repository zijn er drie modellen
geïmplementeerd voor het uitvoeren van grenswijzigingen.

-   Model.0 gaat uit van een uniforme verdeling van wijkkenmerken over
    de wijk heen. Dat wil zeggen dat wordt aangenomen dat kenmerken,
    bijvoorbeeld het aantal 65-plussers, gelijkelijk verdeeld zijn over
    de wijk. Bij het delen van de wijk in kleinere stukken kunnen deze
    kenmerken dan evenredig met het aantal adressen in deze stukken
    worden toegekend. In Model.0 zijn adressen gedefinieerd als
    postcode + huisnummer. Huisnummertoevoegingen en gebruiksfunctie van
    adressen worden niet meegenomen. Model.0 is daarmee een heel
    toegankelijk model dat een redelijk goede grenswijziging uitvoerd,
    maar dat faalt in geval van wijken met veel huisnummertoevoegingen
    (bijvoorbeeld hoogbouw of flats) en wijken met veel adressen zonder
    woonfunctie (bijvoorbeeld winkels, scholen en fabrieken).

-   Model.1 werkt gelijk aan Model.0 maar neemt daarentegen wel de
    huisnummertoevoeging en gebruiksfunctie van het adres mee. In
    Model.1 worden alleen adressen met een woonfunctie beschouwt.
    Daarmee presteert Model.1 aanzienlijk beter dan Model.0 voor wijken
    met veel huisnummertoevoegingen en andere gebruiksfuncties dan
    wonen. Model.1 gaat echter nog wel altijd uit van een uniforme
    verdeling van de wijkkenmerken over de wijk heen. Daarnaast wordt er
    een VNG api gebruikt om de huisnummertoevoegingen en gebruiksfunctie
    te achterhalen Dat kost het tamelijk veel tijd om uit te voeren voor
    alle adressen in Nederland. Daarom zijn ook vooraf berekende
    omzetmatrices beschikbaar gesteld in deze repository.

-   Model.2 neemt een andere benadering. Hier worden adressen opgedeeld
    in blokken gedefinieerd door de overlappingen tussen wijken in het
    ene jaar en de wijken in het volgende jaar. Voor elk blok wordt een
    variabele gedefinieerd die het gemiddelde van een wijkkenmerk in dat
    blok weergeeft. Voor deze variabelen wordt een stelsel formules
    opgesteld zodat de sommen van de adressen maal de gemiddelden gelijk
    zijn aan de wijkkenmerken zoals gepubliceerd door het CBS. Daarnaast
    wordt aangenomen dat deze gemiddelden van jaar tot jaar nauwelijks
    wijzigen. Dat lijkt een redelijke aanname: bijvoorbeeld het
    gemiddelde aantal 65-plussers per adres zal van jaar tot jaar
    ongeveer gelijk zijn. Dit stelsel vergelijkingen wordt opgelost wat
    tot grensgewijzigde data leidt. In dit model wordt eveneens
    uitgegaan van adressen met huisnummertoevoegingen en woonfunctie.

## Installatie

### Pakket als bibliotheek

Het pakket van ‘grenswijzigen’ kan geïnstalleerd worden vanuit GitHub
als:

``` r
# Install the development version from GitHub
devtools::install_github("VNG-Realisatie/grenswijzigen") 
```

### Opzetten project

Indien gewenst kan de gehele code ook vanuit GitHub gecloned worden. We
gebruiken Renv voor het versiebeheer van de packages en de R-versie. Om
direct te kunnen beginnen installeer je alle relevante packages met het
commando `renv::restore()`.

De hoofdfunctie voor het uitvoeren van de code is de functie
`wrapper_vertaal_naar_peiljaar` in het bestand grenswijzigingen.R.
Indicatoren die bestaan uit aantallen (bijvoorbeeld aantal inwoners in
de wijk of aantal 65-plussers in de wijk) worden intern op een andere
manier behandeld dan indicatoren die bestaan uit percentages of aandelen
(bijvoorbeeld gemiddelde huishoudgrootte of aandeel arbeidsongeschikten
per wijk). De functie `wrapper_vertaal_naar_peiljaar` probeert op basis
van kolomnamen zelf in te schatten of het om aantallen of aandelen gaat.

## Voorbeeld

Hieronder staat een basis voorbeeld hoe de code gebruikt kan worden:

``` r
library(grenswijzigingen)
library(cbsodataR)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

kolommen_te_laden <- c(
  "WijkenEnBuurten", "Gemeentenaam_1",
  "AantalInwoners_5", "k_65JaarOfOuder_12",
  "GemiddeldeHuishoudensgrootte_32"
)

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
print(filter(df, grepl("Wageningen", gemeentenaam)))
#> # A tibble: 14 x 6
#>    wijkcode  gemeentenaam   aantal_inwoners aantal_65plus GemiddeldeHuish~  jaar
#>    <chr>     <chr>                    <int>         <int>            <dbl> <dbl>
#>  1 "WK02890~ "Wageningen  ~           33885          5125              1.7  2017
#>  2 "WK02890~ "Wageningen  ~            4570           800              1.9  2017
#>  3 "WK02890~ "Wageningen  ~            4725           440              2.3  2018
#>  4 "WK02890~ "Wageningen  ~            2480             5              1.1  2018
#>  5 "WK02890~ "Wageningen  ~            2750           545              2.2  2018
#>  6 "WK02890~ "Wageningen  ~            2085           365              2.2  2018
#>  7 "WK02890~ "Wageningen  ~            3170            35              1.4  2018
#>  8 "WK02890~ "Wageningen  ~            6890          1435              1.7  2018
#>  9 "WK02890~ "Wageningen  ~            5185           755              1.8  2018
#> 10 "WK02890~ "Wageningen  ~            2505           560              1.6  2018
#> 11 "WK02890~ "Wageningen  ~            3530           510              1.4  2018
#> 12 "WK02891~ "Wageningen  ~            2520           710              1.9  2018
#> 13 "WK02891~ "Wageningen  ~            1175           410              2.3  2018
#> 14 "WK02891~ "Wageningen  ~            1365           385              2.1  2018

# Omzetten van de data van 2017 naar 2018
df_omgezet <- wrapper_vertaal_naar_peiljaar(
  as.data.frame(df),
  peiljaar = 2018,
  model="model.2"
)
#> ----------------------------
#> De volgende kolommen worden niet meegenomen in de grensomzetting
#> wijkcode
#> gemeentenaam
#> jaar
#> gwb_code
#> ----------------------------
#> [1] "Aantal rijen omgezette data-frame: 3085"
#> [1] "Aantal rijen omgezette data-frame: 3085"


# laat de wijken in Wageningen zien
print(filter(df_omgezet, grepl("Wageningen", gemeentenaam)))
#>    gwb_code jaar aantal_inwoners aantal_65plus GemiddeldeHuishoudensgrootte_32
#> 1     28901 2017        4731.450    420.221218                        2.250470
#> 2     28901 2018        4725.000    440.000000                        2.300000
#> 3     28902 2017        2480.943      2.106764                        1.085815
#> 4     28902 2018        2480.000      5.000000                        1.100000
#> 5     28903 2017        2753.530    534.173181                        2.161249
#> 6     28903 2018        2750.000    545.000000                        2.200000
#> 7     28904 2018        2085.000    365.000000                        2.200000
#> 8     28904 2017        2086.779    359.545556                        2.172495
#> 9     28905 2018        3170.000     35.000000                        1.400000
#> 10    28905 2017        3173.439     24.453154                        1.372402
#> 11    28906 2017        6921.518   1338.344758                        1.584218
#> 12    28906 2018        6890.000   1435.000000                        1.700000
#> 13    28907 2018        5185.000    755.000000                        1.800000
#> 14    28907 2017        5198.047    714.988467                        1.725506
#> 15    28908 2017        2509.150    547.273581                        1.558570
#> 16    28908 2018        2505.000    560.000000                        1.600000
#> 17    28909 2017        3535.615    492.780891                        1.351131
#> 18    28909 2018        3530.000    510.000000                        1.400000
#> 19    28910 2017        2523.462    699.382214                        1.861657
#> 20    28910 2018        2520.000    710.000000                        1.900000
#> 21    28911 2018        1175.000    410.000000                        2.300000
#> 22    28911 2017        1175.612    408.123382                        2.283867
#> 23    28912 2017        1365.454    383.606834                        2.088000
#> 24    28912 2018        1365.000    385.000000                        2.100000
#>    berekend                             gemeentenaam   wijkcode
#> 1      TRUE Wageningen                               WK028901  
#> 2     FALSE Wageningen                               WK028901  
#> 3      TRUE Wageningen                               WK028902  
#> 4     FALSE Wageningen                               WK028902  
#> 5      TRUE Wageningen                               WK028903  
#> 6     FALSE Wageningen                               WK028903  
#> 7     FALSE Wageningen                               WK028904  
#> 8      TRUE Wageningen                               WK028904  
#> 9     FALSE Wageningen                               WK028905  
#> 10     TRUE Wageningen                               WK028905  
#> 11     TRUE Wageningen                               WK028906  
#> 12    FALSE Wageningen                               WK028906  
#> 13    FALSE Wageningen                               WK028907  
#> 14     TRUE Wageningen                               WK028907  
#> 15     TRUE Wageningen                               WK028908  
#> 16    FALSE Wageningen                               WK028908  
#> 17     TRUE Wageningen                               WK028909  
#> 18    FALSE Wageningen                               WK028909  
#> 19     TRUE Wageningen                               WK028910  
#> 20    FALSE Wageningen                               WK028910  
#> 21    FALSE Wageningen                               WK028911  
#> 22     TRUE Wageningen                               WK028911  
#> 23     TRUE Wageningen                               WK028912  
#> 24    FALSE Wageningen                               WK028912
```

## Contact

Neem contact met ons op in geval van vragen of opmerkingen.

Voor technische vragen, mail naar <hans.weda@vng.nl>

Voor project-gerelateerde vragen, mail naar <janneke.lummen@vng.nl>

## Licentie

<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.nl"><img alt="Creative Commons-Licentie" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />Dit
werk valt onder een
<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.nl">Creative
Commons Naamsvermelding-NietCommercieel-GelijkDelen 4.0
Internationaal-licentie</a>.

## Project Organization

    │   DESCRIPTION
    │   grenswijzigingen.Rproj
    │   LICENSE.md
    │   NAMESPACE
    │   README.md
    │   README.Rmd                      <- De top-level README voor ontwikkelaars die gebruik maken van het project.
    │   renv.lock                       
    │
    ├───data                            <- Plek waar de omzetmatrices worden opgeslagen  
    │
    ├───data-raw
    │   │   AdresDataOphalen.R
    │   │   config_grenswijzigingen.R
    │   │   maak_omzet_matrices.R
    │   │   main_maak_alle_matrices.R   <- script om de omzetmatrices vanaf de bron opnieuw te maken
    │   │
    │   ├───external                    <- de externe data kan hier worden opgeslagen
    │   │
    │   └───models
    │
    ├───man                             <- help-bestanden
    │
    ├───R
    │       data.R
    │       laad_omzet_matrices.R
    │       util_functies_grenswijzigingen.R
    │       vertaal_naar_peiljaar.R
    │       vertaal_naar_peiljaar_limSolve.R
    │       wrapper_vertaal_naar_peiljaar.R   <- dit is de hoofdfunctie voor het omzetten van grenzen
    │
    ├───reports
    │       .gitkeep
    │
    └───uitproberen                     <- oude scripts

------------------------------------------------------------------------

<p>
<small>Project based on the
<a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter
data science project template</a>. \#cookiecutterdatascience</small>
</p>
