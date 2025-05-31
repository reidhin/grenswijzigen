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
      1     28901 2017        4729.300    422.801059                        2.250470
      2     28901 2018        4725.000    440.000000                        2.300000
      3     28902 2017        2480.629      2.484142                        1.085815
      4     28902 2018        2480.000      5.000000                        1.100000
      5     28903 2017        2752.354    530.585375                        2.161249
      6     28903 2018        2750.000    540.000000                        2.200000
      7     28904 2018        2085.000    360.000000                        2.200000
      8     28904 2017        2086.186    355.257005                        2.172495
      9     28905 2018        3175.000     30.000000                        1.400000
      10    28905 2017        3177.293     20.828830                        1.372402
      11    28906 2017        6916.012   1350.951964                        1.584218
      12    28906 2018        6895.000   1435.000000                        1.700000
      13    28907 2018        5190.000    750.000000                        1.800000
      14    28907 2017        5198.698    715.207363                        1.725506
      15    28908 2017        2507.767    548.933549                        1.558570
      16    28908 2018        2505.000    560.000000                        1.600000
      17    28909 2017        3533.743    490.026861                        1.351131
      18    28909 2018        3530.000    505.000000                        1.400000
      19    28910 2017        2527.308    700.767143                        1.861657
      20    28910 2018        2525.000    710.000000                        1.900000
      21    28911 2018        1175.000    405.000000                        2.300000
      22    28911 2017        1175.408    403.368158                        2.283867
      23    28912 2017        1370.303    383.788552                        2.088000
      24    28912 2018        1370.000    385.000000                        2.100000
         berekend                             gemeentenaam   wijkcode
      1      TRUE Wageningen                               WK028901  
      2     FALSE Wageningen                               WK028901  
      3      TRUE Wageningen                               WK028902  
      4     FALSE Wageningen                               WK028902  
      5      TRUE Wageningen                               WK028903  
      6     FALSE Wageningen                               WK028903  
      7     FALSE Wageningen                               WK028904  
      8      TRUE Wageningen                               WK028904  
      9     FALSE Wageningen                               WK028905  
      10     TRUE Wageningen                               WK028905  
      11     TRUE Wageningen                               WK028906  
      12    FALSE Wageningen                               WK028906  
      13    FALSE Wageningen                               WK028907  
      14     TRUE Wageningen                               WK028907  
      15     TRUE Wageningen                               WK028908  
      16    FALSE Wageningen                               WK028908  
      17     TRUE Wageningen                               WK028909  
      18    FALSE Wageningen                               WK028909  
      19     TRUE Wageningen                               WK028910  
      20    FALSE Wageningen                               WK028910  
      21    FALSE Wageningen                               WK028911  
      22     TRUE Wageningen                               WK028911  
      23     TRUE Wageningen                               WK028912  
      24    FALSE Wageningen                               WK028912  

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
      1       14 2019          231299         33349                        1.700000
      2       14 2018          229963         32387                        1.666373
        berekend                             gemeentenaam   wijkcode
      1    FALSE Groningen                                GM0014    
      2     TRUE Groningen                                GM0014    

