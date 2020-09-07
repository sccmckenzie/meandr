#' Simulate random coordinates following a continuous differentiable trajectory.
#'
#' @description
#' meandr
#'
#' @details
#'
#' recommended method for wt
#'
#' @param n_points An integer. Controls output "resolution". (Underlying calculus is unaffected).
#' @param n_nodes An integer. Defines number of distinct inflection points in function.
#' @param wt A numeric vector of values. These will be sampled (with replacement) \code{n_nodes} times to create inflection points.
#' @param scale A number. Adjusts all y-values so that \code{max(y) = scale}.
#' @param seed A number passed to \code{set.seed} for repeatability. If \code{NULL}, no seed created.
#' @param output Either \code{"vector"} or \code{"tibble"}.
#'
#' @return
#' A tibble containing x & y coordinates of resulting function.
#' @export
#'
#' @examples
meandr <- function(n_points = 100L, n_nodes = 100L, wt = c(1.0, -1.0), scale = 1.0, seed = NULL, output = c("vector", "tibble")) {

  # verify inputs
  output <- match.arg(output)

  n_nodes <- natural(n_nodes, x_arg = "n_nodes")
  wt <- vctrs::vec_cast(wt, double(), x_arg = "wt")

  # seed
  if (!is.null(seed)) {
    set.seed(
      vctrs::vec_cast(seed, to = double())
    )
  }

  # create nodes
  wts <- sample(wt, size = n_nodes, replace = TRUE)

  # call create_path
  df <- suppressMessages(
    create_path(n_points, nodes = wts, scale = scale)
  )

  # output
  switch(output,
         vector = return(df$f),
         tibble = return(df)
  )
}
