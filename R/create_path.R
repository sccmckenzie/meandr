#' Create coordinates following defined trajectory
#'
#' @description
#'
#' Manually create data points corresponding to piecewise polynomial.
#'
#' Use \code{create_path()} to exert full control over trajectory shape. Starting
#' with scalar values defined by \code{nodes}, \code{create_path()} integrates twice to
#' create continuously differentiable function.
#'
#' \code{create_path()} is the underlying function to \code{meandr()}.
#'
#'
#' @param n_points An integer. Controls output "resolution". (Underlying calculus is unaffected).
#' @param nodes A numeric vector corresponding to 2nd derivative values. This determines the overall shape of the function.
#' @param node_int A numeric vector assigning x-values for nodes. Automatically calculated if \code{NULL}.
#' @param scale A number. Adjusts all y-values so that max(y) = \code{scale}.
#'
#' @return
#' A tibble containing x & y coordinates of resulting function.
#' @export
#'
#' @examples
#' Write vignette first
create_path <- function(n_points = 100, nodes = c(1, -1, -1, 2, 0), node_int = NULL, scale = 1.0) {

  # verify inputs
  scale <- vctrs::vec_cast(scale, double(), x_arg = "scale")

  n_points <- natural(n_points, x_arg = "n_points")

  nodes <- vctrs::vec_cast(nodes, double(), x_arg = "nodes")

  # define node_int
  if (!is.null(node_int)) {
    node_int <- vctrs::vec_cast(node_int, double(), x_arg = "node_int")
    if (min(node_int) != 0) stop("Minimum node interval value must be 0", call. = FALSE)
    if (length(nodes) != length(node_int)) stop("node values & intervals must have same length", call. = FALSE)
    if (dplyr::n_distinct(node_int) != length(node_int)) stop("node intervals must be unique", call. = FALSE)
    node_int <- sort(node_int)
  } else {
    node_int <- seq(0, 1, length.out = length(nodes) + 1)[-(length(nodes) + 1)]
    message(glue::glue("Creating even-spaced node intervals at {paste0(scales::percent(node_int), collapse = \", \")}"))
  }

  # define x-values
  x <- seq(1/n_points, 1, length.out = n_points)
  x_int = rowSums(outer(x, node_int, FUN = "quasi_greater_equal"))

  # 2nd derivative
  f2 = nodes[x_int]

  # 1st derivative
  inc <- c(node_int, 0)[-1] - node_int
  c1 <- c(0, cumsum(nodes * inc))
  c1 <- c1[-length(c1)]

  x_offset <- x - node_int[x_int]
  f1 <- x_offset * f2 + c1[x_int]

  # parent fn
  c0 <- c(0, cumsum(nodes * inc ^ 2 / 2 + c1 * inc))
  c0 <- c0[-length(c0)]

  f <- f2 * x_offset ^ 2 / 2 + c1[x_int] * x_offset + c0[x_int]

  f <- f * scale / max(abs(f))

  dplyr::tibble(t = x, f)
}
