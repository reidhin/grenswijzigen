# wrapper vertaal naar peiljaar op wijkniveau

    Code
      filter(df, grepl("Wageningen", gemeentenaam))
    Output
      # A tibble: 14 x 6
         wijkcode    gemeentenaam aantal_inwoners aantal_65plus GemiddeldeHuishouden~1
         <chr>       <chr>                  <int>         <int>                  <dbl>
       1 "WK028900 ~ "Wageningen~           33885          5125                    1.7
       2 "WK028901 ~ "Wageningen~            4570           800                    1.9
       3 "WK028901 ~ "Wageningen~            4725           440                    2.3
       4 "WK028902 ~ "Wageningen~            2480             5                    1.1
       5 "WK028903 ~ "Wageningen~            2750           540                    2.2
       6 "WK028904 ~ "Wageningen~            2085           360                    2.2
       7 "WK028905 ~ "Wageningen~            3175            30                    1.4
       8 "WK028906 ~ "Wageningen~            6895          1435                    1.7
       9 "WK028907 ~ "Wageningen~            5190           750                    1.8
      10 "WK028908 ~ "Wageningen~            2505           560                    1.6
      11 "WK028909 ~ "Wageningen~            3530           505                    1.4
      12 "WK028910 ~ "Wageningen~            2525           710                    1.9
      13 "WK028911 ~ "Wageningen~            1175           405                    2.3
      14 "WK028912 ~ "Wageningen~            1370           385                    2.1
      # i abbreviated name: 1: GemiddeldeHuishoudensgrootte_32
      # i 1 more variable: jaar <dbl>

---

    Code
      filter(df_omgezet, grepl("Wageningen", gemeentenaam))
    Output
         gwb_code jaar aantal_inwoners aantal_65plus GemiddeldeHuishoudensgrootte_32
      1    028901 2018        4725.000    440.000000                        2.300000
      2    028901 2017        4729.277    422.893689                        2.254756
      3    028902 2017        2480.632      2.473616                        1.086976
      4    028902 2018        2480.000      5.000000                        1.100000
      5    028903 2018        2750.000    540.000000                        2.200000
      6    028903 2017        2751.938    532.249797                        2.167788
      7    028904 2018        2085.000    360.000000                        2.200000
      8    028904 2017        2086.185    355.258833                        2.174806
      9    028905 2018        3175.000     30.000000                        1.400000
      10   028905 2017        3177.715     19.140689                        1.371744
      11   028906 2018        6895.000   1435.000000                        1.700000
      12   028906 2017        6916.329   1349.684404                        1.593126
      13   028907 2018        5190.000    750.000000                        1.800000
      14   028907 2017        5198.683    715.267173                        1.731809
      15   028908 2018        2505.000    560.000000                        1.600000
      16   028908 2017        2507.733    549.068773                        1.562280
      17   028909 2018        3530.000    505.000000                        1.400000
      18   028909 2017        3533.583    490.668989                        1.356198
      19   028910 2018        2525.000    710.000000                        1.900000
      20   028910 2017        2527.318    700.728511                        1.864797
      21   028911 2017        1175.408    403.367688                        2.285217
      22   028911 2018        1175.000    405.000000                        2.300000
      23   028912 2018        1370.000    385.000000                        2.100000
      24   028912 2017        1370.201    384.197838                        2.091296
         berekend                             gemeentenaam   wijkcode
      1     FALSE Wageningen                               WK028901  
      2      TRUE Wageningen                               WK028901  
      3      TRUE Wageningen                               WK028902  
      4     FALSE Wageningen                               WK028902  
      5     FALSE Wageningen                               WK028903  
      6      TRUE Wageningen                               WK028903  
      7     FALSE Wageningen                               WK028904  
      8      TRUE Wageningen                               WK028904  
      9     FALSE Wageningen                               WK028905  
      10     TRUE Wageningen                               WK028905  
      11    FALSE Wageningen                               WK028906  
      12     TRUE Wageningen                               WK028906  
      13    FALSE Wageningen                               WK028907  
      14     TRUE Wageningen                               WK028907  
      15    FALSE Wageningen                               WK028908  
      16     TRUE Wageningen                               WK028908  
      17    FALSE Wageningen                               WK028909  
      18     TRUE Wageningen                               WK028909  
      19    FALSE Wageningen                               WK028910  
      20     TRUE Wageningen                               WK028910  
      21     TRUE Wageningen                               WK028911  
      22    FALSE Wageningen                               WK028911  
      23    FALSE Wageningen                               WK028912  
      24     TRUE Wageningen                               WK028912  

# wrapper vertaal naar peiljaar op gemeenteniveau

    Code
      filter(df, grepl("^Groningen", gemeentenaam))
    Output
      # A tibble: 2 x 6
        wijkcode     gemeentenaam aantal_inwoners aantal_65plus GemiddeldeHuishouden~1
        <chr>        <chr>                  <int>         <int>                  <dbl>
      1 "GM0014    " "Groningen ~          202810         25697                    1.6
      2 "GM0014    " "Groningen ~          231299         33349                    1.7
      # i abbreviated name: 1: GemiddeldeHuishoudensgrootte_32
      # i 1 more variable: jaar <dbl>

---

    Code
      filter(df_omgezet, grepl("^Groningen", gemeentenaam))
    Output
        gwb_code jaar aantal_inwoners aantal_65plus GemiddeldeHuishoudensgrootte_32
      1     0014 2019          231299         33349                        1.700000
      2     0014 2018          229963         32387                        1.665328
        berekend                             gemeentenaam   wijkcode
      1    FALSE Groningen                                GM0014    
      2     TRUE Groningen                                GM0014    

