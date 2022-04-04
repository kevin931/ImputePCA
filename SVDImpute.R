SVDImpute <- function(data, init=c("Mean", "Median", "KNN"), pc=NA, min_var = NA,
                      n_neighbors = NA, max_iter=50, tol=NA, verbose = TRUE) {
  
  root_mean_squared <- function(data) {
    if (!is.matrix(data)) {
      data <- as.matrix(data)
    }
    return(sqrt(sum(data^2)/length(data)))
  }
  
  minimum_pc_needed <- function(pca_object, var_threshold=0.75) {
    pca_variance <- pca_object$sdev^2
    pca_variance <- pca_variance/sum(pca_variance)
    
    var_explained <- 0
    for (pc in 1:length(pca_variance)) {
      var_explained <- var_explained + pca_variance[pc]
      if (var_explained >= var_threshold) {
        break
      }
    }
    return(pc)
  }
  
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
  
  
  # Tolerance
  if (is.na(tol)) {tol <- .Machine$double.eps}
  if (tol <= 0) {stop("Tolerance must be positive.")}
  # Check for NA and sanity
  if (!is.matrix(data)) {
    data <- as.matrix(data)
  }
  na_index <- which(is.na(data))
  na_col <- apply(data, 2, function(x) any(is.na(x)))
  na_col_index <- apply(data, 2, function(x) which(is.na(x)))
  
  # PC Selection Criteria
  if (!is.na(pc) & !is.na(min_var)) {
    cat(sprintf("Warning: Using %d PC instead of variance condition", pc))
  } else if (is.na(pc) & is.na(min_var)) {
    stop("No PC selection criteria specified.")
  } else if (!is.na(pc)) {
    pc_selection <- "num"
  } else {
    pc_selection <- "var"
  }
  
  # Initialization
  if (init == "Mean") {
    init_matrix <- matrix(colMeans(data, na.rm = T), nrow=nrow(data),
                          ncol=ncol(data), byrow=T)
    data[na_index] <- init_matrix[na_index]
  } else if (init == "Median") {
    init_matrix <- apply(data, 2, median, na.rm=T)
    init_matrix <- matrix(init_matrix, nrow=nrow(data),
                          ncol=ncol(data), byrow=T)
    data[na_index] <- init_matrix[na_index]
  } else if (init == "KNN") {
    data <- KNNImpute(data, n_neighbors = n_neighbors)
  } else {
    stop("Unsupported Init!")
  }
  
  # Here are the goodies: Imputation
  prev <- data
  rms_prev <- root_mean_squared(data)
  counter <- 1
  while(T) {
    pca_reduction <- princomp(data)
    if (pc_selection == "num") {
      pca_reduction <- pca_reduction$scores[,1:pc]
    } else {
      pc_num <- minimum_pc_needed(pca_reduction, var_threshold = min_var)
      pca_reduction <- pca_reduction$scores[,1:pc_num]
    }
    
    for (column in which(na_col)) {
      data_model <- as.data.frame(data[-na_col_index[[column]],column, drop=F])
      colnames(data_model) <- "y"
      data_model <- cbind(data_model, as.data.frame(pca_reduction)[-na_col_index[[column]],, drop=F])
      model <- lm(y~., data=data_model)
      
      pred <- predict(model, newdata = as.data.frame(pca_reduction)[na_col_index[[column]],, drop=F])
      data[na_col_index[[column]], column] <- pred
    }
    
    rms <- root_mean_squared(data)
    if (verbose) {cat(sprintf("Iteration %d: RMS=%.3f\n", counter, rms))}
    if (counter >= max_iter) {
      break
    } else if (abs(rms-rms_prev) <= rms_prev*tol) {
      break
    } else {
      rms_prev <- rms
      counter <- counter + 1
    }
  }
  cat(sprintf("Total Iteration: %d; Delta RMS=%.3f\n",
              counter, abs(rms_prev - rms)))
  return(data)
}