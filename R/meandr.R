#' Generate random coordinates following continuous trajectory
#'
#' @description
#' \code{meandr()} offers a calculus-driven approach to simulating random time-series behavior.
#' Inputs \code{n_nodes} and \code{wt} serve as tuning knobs for overall smoothness and direction, respectively.
#'
#' For greater control over curve shape, see \code{create_path()}
#'
#' @details
#' For \code{wt}, recommend using length \code{2} comprising of positive and negative element -
#' though any numeric vector will be accepted.
#' Default value, \code{c(1, -1)}, will tend to produce curves with greatest directional variety.
#' As magnitude between \code{wt[1]} and \code{wt[2]} deviates, overall curve will veer to +/- \code{Inf}.
#'
#' Each call to \code{meandr()} follows below execution flow:\cr
#' (1) Build piecewise function, "f2", of "nodes" sampled (with replacement) from \code{wt}.\cr
#' (2) Integrate "f2" twice to obtain continuously differentiable function, "f".\cr
#' (3) Interval (0, 1] is cut into \code{n_points} - resulting values passed to "f".\cr
#' (4) Output coordinates in \code{tibble}
#'
#' @param n_nodes An integer. Defines number of distinct inflection points in function.
#' @param wt A numeric vector of values. These will be sampled (with replacement) \code{n_nodes} times to create inflection points.
#' @param gain Tuning parameter.
#' @param n_points An integer. Controls output "resolution". (Underlying calculus is unaffected).
#' @param scale A number. Adjusts all y-values so that \code{max(y) = scale}.
#' @param seed A number passed to \code{set.seed} for repeatability. If \code{NULL}, no seed created.
#'
#' @return
#' A \code{tibble} containing coordinates of resulting function.
#' @export
#'
#' @examples
#'
#' # See vignette("meandr")
#'
#' # each call produces unique output
#' meandr()
#'
#' # use meandr::mplot for quick plotting
#' mplot(meandr())
#'
#' # n_nodes has the most impact on curve complexity
#' curve1 <- meandr(n_nodes = 5)
#' mplot(curve1) # simple piecewise quadratic
#'
#' curve2 <- meandr(n_nodes = 200)
#' mplot(curve2) # more meandering!
#'
#'
meandr <- function(n_nodes = 100L, wt = c(1.0, -1.0), gain = 0.75, n_points = 100L, scale = 1.0, seed = NULL) {

  n_nodes <- natural(n_nodes, x_arg = "n_nodes")
  wt <- vctrs::vec_cast(wt, double(), x_arg = "wt")

  # seed
  if (!is.null(seed)) {
    set.seed(
      vctrs::vec_cast(seed, to = double())
    )
  }

  # create nodes
  wts <- sample_roll(wt, n = n_nodes, gain = gain)

  # call create_path
  df <- suppressMessages(
    create_path(n_points, nodes = wts, scale = scale)
  )

  # output
  df
}
