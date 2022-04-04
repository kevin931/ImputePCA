InDaPCA <- function(data) {
  
  if (!is.matrix(data)) {
    data <- as.matrix(data)
  }
  
  data <- scale(data)
  cor_mat <- cor(data, use="pairwise.complete.obs")
  eigen_mat <- eigen(cor_mat)
  
  data[is.na(data)] <- 0
  loadings <- eigen_mat$vectors
  variance_explained <- eigen_mat$values/sum(eigen_mat$values)
  scores <- data %*% loadings
  
  return(list(loadings = loadings, scores = scores, sdev = sqrt(eigen_mat$values)))
}