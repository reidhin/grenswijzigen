# Utility functies voor grenswijzigingen

matrix_keer_vector <- function(mat, vec) {
  "
  Functie die een matrix met een vector vermenigvuldigd.
  Een NA in de vector heeft alleen consequenties voor de uitkomst als deze met
  een waarde ongelijk aan nul wordt vermenigvuldigd.

  parameters:
    mat: matrix
    vec: vector waarvan sommige elementen NA kunnen zijn

  returns:
    out: vector als resultaat van out = mat %*% vec
  "
  # vind de posities van de NA in vec
  na_posities <- is.na(vec)

  # zorg dat er geen NA meer in vec aanwezig is
  vec[na_posities] <- 0

  # doe de matrix vermenigvuldiging
  out <- mat %*% vec

  # vind de posities in de uit-vector die NA moeten worden gezet
  if (sum(na_posities) == 1) {
    # maar 1 positie, dan werkt rowSums niet
    na_out_posities <- mat[,na_posities] != 0
  } else {
    na_out_posities <- rowSums(mat[,na_posities] != 0) > 0
  }
  out[na_out_posities] <- NA

  return(out)
}


speciale_merge <- function(df.a, df.b) {
  "
  speciale merge, die ook verstandige output levert als 1 van beide
  data frames leeg is.

  parameters:
    df.a, df.b: data-frames die gemerged moeten worden

  returns:
    gemerged data-frame. Indien 1 van beide dataframes leeg is, dan wordt enkel
    de andere dataframe geretourneerd.
  "
  if (nrow(df.a) == 0) {
    if (nrow(df.b) > 0) {
      return(df.b)
    } else {
      return(data.frame())
    }
  } else {
    if (nrow(df.b) > 0) {
      return(merge(df.a, df.b))
    } else {
      return(df.a)
    }
  }
}


splits_matrix_in_blokken <- function(mat) {
  "
  Deze functie splitst de matrix op in blokken. Dit is met name interessant voor
  sparse matrices. Deze matrices bestaan vooral uit nullen, met hier en daar een
  entry ongelijk aan nul. Deze functie groepeert de stukken ongelijk aan nul in
  blokken.

  Parameters:
    mat: sparse matrix die moet worden opgesplitst in blokken

  Returns:
    lijst met matrices
  "

  # zet de matrix om in een Matrix
  mat <- Matrix::Matrix(mat)

  # bereken de 'edges', de verbindingen tussen rij en kolom
  edges <- as.matrix(Matrix::summary(mat)[c('j', 'i')])

  # zet de namen op in de rij en kolom namen
  edges[,"i"] <- sprintf("new_%s", rownames(mat)[edges[, "i"]])
  edges[,"j"] <- sprintf("old_%s", colnames(mat)[as.numeric(edges[, "j"])])

  # maak van de 'edges' een grafiek
  g <- igraph::graph.edgelist(edges)

  # vind de onverbonden groepen
  groups <- igraph::groups(igraph::components(g))

  # definieer een functie voor subsetting
  my_subset_matrix <- function(gr, mat.l) {
    Matrix::Matrix(
      mat.l[
        rownames(mat.l) %in% substring(grep("^new", gr, value=T), 5),
        colnames(mat.l) %in% substring(grep("^old", gr, value=T), 5),
        drop=FALSE
      ]
    )
  }

  # pas het subsetten toe
  return(sapply(groups, my_subset_matrix, mat))
}

