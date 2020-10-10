#' Check if two numbers are approximately equal
#'
#' @param x A number
#' @param y A number
#' @param tol A number
#'
#' @return logical
quasi_equal <- function(x, y, tol = 1e-7) {
  abs(x - y) < tol
}

#' Check if one number is approximately greather than or equal to another
#'
#' @param x A number
#' @param y A number
#' @param tol A number
#'
#' @return logical
quasi_greater_equal <- function(x, y, tol = 1e-7) {
  quasi_equal(x, y, tol) | (x > y)
}

#' Force numeric to natural number
#'
#' @param x A numeric
#' @param x_arg Argument name for x. Used in error message to inform user about location of incompatible type
#'
#' @return integer
natural <- function(x, x_arg = "x") {
  x <- x[1]

  if(!is.numeric(x) | is.na(x)) {
    stop(glue::glue("{x_arg} must be integer greater than 0"), call. = FALSE)
  } else {
    max(1L, as.integer(x), na.rm = TRUE)
  }
}

#' Perform sequential sample with weighted replacement
#'
#' @param x vector of elements from which to choose
#' @param n a positive number, the number of items to choose from
#' @param gain Tuning parameter.
#'
#' @importFrom utils tail
#'
#' @return numeric vector
sample_roll <- function(x, n, gain = 0.75) {
  prob <- matrix(1, nrow = n, ncol = length(x))

  out <- vctrs::vec_cast(vector(length = n), to = x)

  for (i in seq_along(out)) {
    j <- sample(seq_along(x), size = 1, prob = prob[i, ])
    out[i] <- x[j]

    if (i < length(out)) {

      out_filled <- out[!is.na(out)]

      r_n  <- min(
        max(
          round(length(out) * 0.25, 0),
          1
        ),
        length(out_filled)
      )

      # 1st derivative moving avg
      s <- tail(
        RcppRoll::roll_meanr(
          cumsum(out_filled),
          n = r_n
          ),
        1
      )

      if (s > 0) {
        prob[i + 1,][x < 0] <- prob[i + 1,][x < 0] * exp(gain * s)
      } else {
        prob[i + 1,][x >= 0] <- prob[i + 1,][x >= 0] * exp(-gain * s)
      }
    }
  }
  out
}
