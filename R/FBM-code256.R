################################################################################

#' Class FBM.code256
#'
#' A reference class for storing and accessing up to 256 arbitrary different
#' values using a Filebacked Big Matrix of type `unsigned char`. Compared to a
#' [Filebacked Big Matrix][FBM-class], it adds a slot `code` which is used as
#' a lookup table of size 256.
#'
#' @param x A [FBM][FBM-class].
#' @param code A numeric vector (of length 256).
#' You should construct it with `rep(NA_real_, 256)` and then replace the values
#' which are of interest for you.
#' @inheritParams FBM
#'
#' @examples
#' X <- FBM(10, 10, type = "raw")
#' X[] <- sample(as.raw(0:3), size = length(X), replace = TRUE)
#' X[]
#'
#' code <- rep(NA_real_, 256)
#' code[1:3] <- c(1, 3, 5)
#'
#' X.code <- add_code256(X, code)
#' X.code[]
#'
#' # Or directly
#' X.code2 <- FBM.code256(10, 10, code, init = sample(as.raw(0:3), 100, TRUE))
#' X.code2[]
#'
#' # Copy the FBM with another code
#' X.code3 <- X.code$copy(code = rnorm(256))
#' stopifnot(all.equal(X.code$code256, code))
#'
#' @include FBM.R
#'
#' @exportClass FBM.code256
#'
FBM.code256_RC <- methods::setRefClass(

  "FBM.code256",

  contains = "FBM",

  fields = list(
    code256 = "vector"
  ),

  methods = list(
    initialize = function(..., code) {
      .self$code256 <- code
      callSuper(...)
    },

    copy = function(code = .self$code256) {
      add_code256(.self, code = code)
    },

    as.FBM = function() {
      FBM(
        nrow = .self$nrow,
        ncol = .self$ncol,
        type = "unsigned char",
        init = NULL,
        backingfile = sub_bk(.self$backingfile),
        create_bk = FALSE
      )
    },

    show = function() {
      callSuper("code 256")
    }
  )
)

################################################################################

#' Wrapper constructor for class `FBM.code256`.
#'
#' @inheritParams FBM
#'
#' @rdname FBM.code256-class
#'
#' @export
#'
FBM.code256 <- function(nrow, ncol,
                        code = rep(NA_real_, 256),
                        init = NULL,
                        backingfile = tempfile(),
                        create_bk = TRUE) {

  if (length(code) != 256)
    stop("'code' must be of length 256.")

  do.call(methods::new, args = c(Class = "FBM.code256",
                                 type = "unsigned char",
                                 as.list(environment())))
}

#' Converter from class `FBM` to `FBM.code256`.
#'
#' @rdname FBM.code256-class
#'
#' @export
#'
add_code256 <- function(x, code) {

  if (x$type != 1)
    stop2("'x' must be of type 'raw' (unsigned char)")

  FBM.code256(
    nrow = x$nrow,
    ncol = x$ncol,
    code = code,
    init = NULL,
    backingfile = sub_bk(x$backingfile),
    create_bk = FALSE
  )
}

################################################################################

#' Methods for the FBM.code256 class
#'
#' @name FBM.code256-methods
#'
#' @rdname FBM.code256-methods
NULL

#' Accessor method for class `FBM.code256`.
#'
#' @param x A [FBM.code256][FBM.code256-class].
#' @inheritParams FBM-methods
#'
#' @rdname FBM.code256-methods
#'
#' @export
#'
setMethod(
  '[', signature(x = "FBM.code256"),
  Extract(
    extract_vector = function(x, i) {
      decodeVec(extractVec(x$address, i), x$code256)
    },
    extract_matrix = function(x, i, j) {
      decodeMat(extractMat(x$address, i, j), x$code256)
    }
  )
)

################################################################################
