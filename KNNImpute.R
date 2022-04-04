KNNImpute <- function(data, n_neighbors = 10) {
  
  if (!is.matrix(data)) {
    data <- as.matrix(data)
  }
  
  na_row <- apply(data, 1, function(x) any(is.na(x)))
  for (i in which(na_row)) {
    na_col <- which(is.na(data[i, ]))
    temp <- data[,-na_col]
    temp_complete <- complete.cases(data)
    
    neighbors <- rep(Inf, nrow(temp))
    
    for (j in which(temp_complete)) {
      neighbors[j] <- sqrt(sum((temp[i,]-temp[j,])^2))
    }
    
    knn <- sort(neighbors, index.return=T)$ix[2:(n_neighbors+1)]
    weights <- neighbors[knn]/sum(neighbors[knn])
    weights <- matrix(weights, nrow=1)
    
    data[i, na_col] <- weights %*% data[knn,na_col]
  }
  return(data)
}