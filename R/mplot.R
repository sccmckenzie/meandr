#' Create simply line plot from x + y coordinates. Designed for `meandr` but can be used in other applications.
#'
#' @param x A numeric vector or data frame containing at least two numeric columns.
#' Numeric vector will be automatically paired with x-values in sequence from 0 to 1.
#'
#' @return An object of class `gg`
#' @export
#'
#' @import ggplot2
#'
#' @examples
mplot <- function(.df) {
  df <- dplyr::tibble(x = .df[1][[1]], y = .df[2][[1]])

  ggplot(df, aes(x, y)) +
    geom_line(size = 2, color = "#175C4A") +
    labs(x = "", y = "") +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank())
}
