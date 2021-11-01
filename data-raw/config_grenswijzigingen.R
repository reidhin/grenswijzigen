# config bestand grenswijzigingen

# data frame met URL's, paden en bestandsnamen
adressen_CBS <- data.frame(
  jaar=2016:2020, 
  url=c(
    "https://www.cbs.nl/-/media/_excel/2016/38/2016-cbs-pc6huisnr20160801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2017/38/2017-cbs-pc6huisnr20170801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2018/36/2018-cbs-pc6huisnr20180801_buurt--vs2.zip",
    "https://www.cbs.nl/-/media/_excel/2019/42/2019-cbs-pc6huisnr20190801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2020/39/2020-cbs-pc6huisnr20200801-buurt.zip"
  ),
  pc6hnr=c(
    "pc6hnr20160801_gwb.csv",
    "pc6hnr20170801_gwb.csv",
    "pc6hnr20180801_gwb-vs2.csv",
    "pc6hnr20190801_gwb.csv", 
    "pc6hnr20200801_gwb.csv"
  ),
  path=c(
    "2016-cbs-pc6huisnr20160801_buurt",
    "2017-cbs-pc6huisnr20170801_buurt",
    "2018-cbs-pc6huisnr20180801_buurt -vs2",
    "2019-cbs-pc6huisnr20190801_buurt",
    "2020-cbs-pc6huisnr20200801-buurt"
  ),
  gemeente=c(
    "gemeentenaam2016.csv",
    "gemeentenaam2017.csv",
    "gemeentenaam2018.csv",
    "gem2019.csv",
    "gem2020.csv"
  )
)


Koplopers=c(
  "Rotterdam",
  "Groningen",
  "Weert",
  "Almelo",
  "Dinkelland",
  "Borne",
  "Enschede",
  "Hellendoorn",
  "Rijssen-Holten",
  "Haaksbergen",
  "Hof van Twente",
  "Wierden",
  "Tubbergen",
  "Losser",
  "Oldenzaal",
  "Hengelo",
  "Twenterand",
  "Roosendaal",
  "Zoetermeer",
  "Ede",
  "Midden-Groningen",
  "Deventer",
  "Bodegraven-Reeuwijk",
  "Hollands Kroon",
  "Raalte",
  "Veenendaal",
  "Nijmegen",
  "Cuijk",
  "Grave",
  "Mill en Sint Hubert",
  "Helmond",
  "Boxtel",
  "Sint-Michielsgestel",
  "Schouwen-Duiveland",
  "Delft",
  "Lansingerland",
  "Meppel",
  "West Betuwe",
  "Hulst",
  "Venray",
  "Hilversum"
)