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
