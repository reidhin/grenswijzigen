"
Functies om de adres data op te halen.

Er zijn twee belangrijke functies:

* laad_adressen haalt de data op die adressen aan wijken en buurten koppelt.
  Deze data is per jaar beschikbaar. De adressen zijn gedefinieerd als postcode
  en huisnummer. Er zijn geen huisnummertoevoegingen beschikbaar. De data is
  openbaar beschikbaar vanuit het CBS

* laad_aantallen_woonfunctie haalt details op per adres. Het betreft hier met
  name de gebruiksfunctie, waarbij we met name in de woonfunctie geinteresseerd
  zijn. De adressen zijn beschikbaar als postcode, huisnummer en
  huisnummertoevoeging. De data is beschikbaar gesteld via een open api bij het
  VNG.

Auteur: Hans Weda, rond consulting
Datum: 8 april 2021
"

library(cbsodataR)


source(file.path("data-raw", "config_grenswijzigingen.R"))

raw_data_dir <- file.path("data-raw", "external")

# functie om cijfers te verwijderen
remove_digits <- function(x) {
  gsub("[[:digit:]]+", "", x)
}



laad_adressen <- function(jaren=2016:2021) {
  "
  Deze functie haalt de data op die adressen aan wijken en buurten koppelt.
  Deze data is per jaar beschikbaar. De adressen zijn gedefinieerd als postcode
  en huisnummer. Er zijn geen huisnummertoevoegingen beschikbaar. De data is
  openbaar beschikbaar vanuit het CBS

  Parameters:
    - jaren: vector met integer jaren waarvoor de data moet worden opgehaald

  Returns:
    - data.table met postcode, huisnummer, buurt, wijk, gemeente

  "

  # De url's en bestanden staan gedefinieerd in config_grenswijzigingen
  adressen_CBS <- adressen_CBS[adressen_CBS$jaar %in% jaren,]

  # lees de data in
  dt <- data.table()
  for (row in 1:nrow(adressen_CBS)) {
    writeLines(sprintf("Processing %s", adressen_CBS[row, "jaar"]))

    full.file.name <- file.path(
      raw_data_dir, adressen_CBS[row, "path"], adressen_CBS[row, "pc6hnr"]
    )

    # check of de zip al is gedownload
    if(!file.exists(full.file.name)){
      # bestand bestaat niet
      print(
        sprintf(
          "Het bestand %s bestaat niet; opnieuw laden via url",
          full.file.name
        )
      )

      # maak directory
      dir.create(
        file.path(raw_data_dir, adressen_CBS[row, "path"]),
        showWarnings = FALSE
      )

      # download het zip-bestand en pak het uit in de directory
      temp <- tempfile()
      download.file(adressen_CBS[row, "url"], temp)
      unzip(zipfile=temp, exdir=file.path(raw_data_dir, adressen_CBS[row, "path"]))
      unlink(temp)
    }


    # read postcode info
    pc6hnr <- fread(
      file.path(raw_data_dir, adressen_CBS[row, "path"], adressen_CBS[row, "pc6hnr"])
      )

    # remove digits
    setnames(pc6hnr, remove_digits)

    # voeg jaar toe
    pc6hnr[, "Jaar" := adressen_CBS[row, "jaar"]]

    # read gemeente info
    if (grepl(".dbf$", adressen_CBS[row, "gemeente"])) {
      gemeentes <- read.dbf(
        file.path(raw_data_dir, adressen_CBS[row, "path"], adressen_CBS[row, "gemeente"])
      )
    } else {
      gemeentes <- fread(
        file.path(raw_data_dir, adressen_CBS[row, "path"], adressen_CBS[row, "gemeente"])
      )
    }

    # change column names if necessary
    if ("GEMEENTECO" %in% names(gemeentes)) {
      setnames(gemeentes, c("GEMEENTECO", "GEMNAAM"), c("Gemcode", "Gemeentenaam"))
    }
    if ("GWBcode8" %in% names(gemeentes)) {
      setnames(gemeentes, c("GWBcode8", "GWBlabel"), c("Gemcode", "Gemeentenaam"))
    }
    if ("GEM2017" %in% names(gemeentes)) {
      setnames(gemeentes, c("GEM2017", "GEMNAAM"), c("Gemcode", "Gemeentenaam"))
    }
    if ("Gem" %in% names(pc6hnr)) {
      setnames(pc6hnr, "Gem", "Gemeente")
    }
    if ("wijkcode" %in% names(pc6hnr)) {
      setnames(pc6hnr, c("pc", "huisnummer", "gwb_code", "wijkcode", "gemeentecode"), c("PC", "Huisnummer", "Buurt", "Wijk", "Gemeente"))
    }
    print(names(pc6hnr))

    # remove digits
    setnames(gemeentes, remove_digits)

    # merge
    pc6hnr <- merge(pc6hnr, gemeentes, by.x="Gemeente", by.y="Gemcode")

    # rbind
    dt <- rbind(dt, pc6hnr)
  }
  return(dt)
}


laad_aantallen_woonfunctie <- function() {
  "
  Functie die de aantallen adressen met woonfunctie ophaalt per
  huisnummer-postcode combinatie. Hierbij wordt gebruik gemaakt van een
  data-dump van het BAG die door Stephan Preeker beschikbaar is gesteld via een
  api.
  Let op: deze data is een momentopname, veranderingen door de tijd van
  gebruikfunctie kunnen hiermee niet worden opgehaald.

  Parameters:
    - None

  Returns:
    - data.table met huisnummer, postcode en aantal adressen met woonfunctie.
  "

  full.file.name <- file.path(
    raw_data_dir, "aantallen_woonfunctie_per_adres.csv"
  )

  # check of de aantallen voor woonfunctie al is gedownload
  if(!file.exists(full.file.name)){
    # bestand bestaat niet
    print(
      sprintf(
        "Het bestand %s bestaat niet; opnieuw laden via api",
        full.file.name
      )
    )

    # maak directory
    dir.create(
      file.path(raw_data_dir),
      showWarnings = FALSE
    )

    # Vindt eerst alle gemeentecodes die beschikbaar zijn
    url <- paste0(
      "https://ds.vboenergie.commondatafactory.nl/list/?",
      "groupby", "=", "gemeentecode",
      "&",
      "reduce", "=", "count"
    )

    # lees api in
    dat <- fromJSON(url)

    gemeentecodes = names(dat)
    gemeentecodes = gemeentecodes[gemeentecodes != ""]

    out = data.table()
    for (gemeentecode in gemeentecodes) {
      writeLines(
        sprintf("Processing %s", gemeentecode)
      )

      url <- paste0(
        "https://ds.vboenergie.commondatafactory.nl/list/?match-",
        "gemeentecode", "=", gemeentecode,
        "&",
        "contains-gebruiksdoelen", "=", "woonfunctie",
        "&",
        "groupby", "=", "postcodehuisnummer",
        "&",
        "reduce", "=", "count"
      )

      # lees api in
      dat <- fromJSON(url)

      # zet om naar data.table dit geeft je een data.table met lists -
      # deze lists zou je dan unlisten
      dt <- data.table(lapply(dat, unlist))

      # zet de namen expliciet goed
      dt$PC = unlist(lapply(strsplit(names(dat), " "), function(x) x[1]))
      dt$Huisnummer = unlist(lapply(strsplit(names(dat), " "), function(x) x[2]))
      setnames(dt, "V1", "N")

      out <- rbind(out, dt)
    }

    fwrite(out, file = full.file.name)

  } else {

    out <- fread(full.file.name)

  }

  return(out)
}
