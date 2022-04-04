[![forthebadge](https://forthebadge.com/images/badges/built-by-hipsters.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/powered-by-coffee.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/for-you.svg)](https://forthebadge.com)

## Imputation for PCA

Have you ever heard of missing data? Do you ever crave the magic of PCA? If you do, you've found your **Home**. Here, we bring you a few methods to deal with missing data effectively so that you can run your PCA smoothly!

### SVD Impute

This method was proposed by [Troyanskaya et al.](https://academic.oup.com/bioinformatics/article/17/6/520/272365?login=true). In essence, it runs iteratively runs regression imputation using the top PCs obtained until convergence. Another imputation method is used as initialization.

### KNN Impute

This is a more conventional method that is also mentioned by [Troyanskaya et al.](https://academic.oup.com/bioinformatics/article/17/6/520/272365?login=true). It imputes by finding a weighted average from its nearest neighbors. This method does not require PCA: it can be a general-purpose imputation method.

### InDaPCA

This is a newly developed method proposed by [Podani et al.](https://www.sciencedirect.com/science/article/pii/S1574954121000261). It skips the problem of imputation entirely: namely, it attempts to perform PCA without imputing. It uses the pairwise complete observation to compute Eigen-decomposition and then set all missing values to 0 while computing the scores.

## Running Imputation

You won't need other packages. All you need to do is to source the scripts and run the methods.


## References

Podani, J., Kalapos, T., Barta, B., & Schmera, D. (2021). Principal component analysis of incomplete data-A simple solution to an old problem. Ecological Informatics, 61, 101235.

Troyanskaya, O., Cantor, M., Sherlock, G., Brown, P., Hastie, T., Tibshirani, R., ... & Altman, R. B. (2001). Missing value estimation methods for DNA microarrays. Bioinformatics, 17(6), 520-525.
