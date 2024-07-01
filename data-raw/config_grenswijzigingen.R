# config bestand grenswijzigingen

# data frame met URL's, paden en bestandsnamen
adressen_CBS <- data.frame(
  jaar=2016:2023,
  url=c(
    "https://www.cbs.nl/-/media/_excel/2016/38/2016-cbs-pc6huisnr20160801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2017/38/2017-cbs-pc6huisnr20170801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2018/36/2018-cbs-pc6huisnr20180801_buurt--vs2.zip",
    "https://www.cbs.nl/-/media/_excel/2019/42/2019-cbs-pc6huisnr20190801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2020/39/2020-cbs-pc6huisnr20200801-buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2021/36/2021-cbs-pc6huisnr20200801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2022/37/2022-cbs-pc6huisnr20210801_buurt.zip",
    "https://download.cbs.nl/maatwerk/2023-cbs-pc6huisnr20230801_buurt.zip"
  ),
  pc6hnr=c(
    "pc6hnr20160801_gwb.csv",
    "pc6hnr20170801_gwb.csv",
    "pc6hnr20180801_gwb-vs2.csv",
    "pc6hnr20190801_gwb.csv",
    "pc6hnr20200801_gwb.csv",
    "pc6hnr20210801_gwb.csv",
    "pc6hnr20220801_gwb.csv",
    "2023-cbs-pc6huisnr20230801_buurt/pc6hnr20230801_gwb.csv"
  ),
  path=c(
    "2016-cbs-pc6huisnr20160801_buurt",
    "2017-cbs-pc6huisnr20170801_buurt",
    "2018-cbs-pc6huisnr20180801_buurt -vs2",
    "2019-cbs-pc6huisnr20190801_buurt",
    "2020-cbs-pc6huisnr20200801-buurt",
    "2021-cbs-pc6huisnr20200801_buurt",
    "2022-cbs-pc6huisnr20220801_buurt",
    "2023-cbs-pc6huisnr20230801_buurt"
  ),
  gemeente=c(
    "gemeentenaam2016.dbf",
    "gemeentenaam2017.csv",
    "gemeentenaam2018.csv",
    "gem2019.csv",
    "gem2020.csv",
    "gem2021.csv",
    "gem2022.csv",
    "2023-cbs-pc6huisnr20230801_buurt/gemeenten_2023.csv"
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
