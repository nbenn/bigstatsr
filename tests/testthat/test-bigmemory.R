################################################################################

context("BIGMEMORY")

################################################################################

for (t in c("integer", "float", "double")) {

  X <- FBM(10, 10, type = t)
  X[1] <- NA

  # Conversion works
  expect_s4_class(X$bm.desc(), "big.matrix.descriptor")
  expect_s4_class(X2 <- X$bm(), "big.matrix")
  expect_identical(typeof(X2), typeof(X))
  if (t != "float") expect_equal(as.numeric(X2[1]), as.numeric(X[1]))

  # Product works with BM
  library(bigalgebra)
  A <- matrix(1, 10, 10)
  expect_error(X %*% A)
  if (t == "double") expect_s4_class(X2 %*% A, "big.matrix")
}

################################################################################