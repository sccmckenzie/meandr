#' Create simply line plot from x + y coordinates. Designed for `meandr` but can be used in other applications.
#'
#' @param .df A data frame containing at least two numeric columns.
#'
#' @return An object of class `gg`
#' @export
#'
#' @import ggplot2
#'
#' @examples
#' mplot(data.frame(x = 1:10, y = 1:10))
#'
#' mplot(meandr())
mplot <- function(.df) {
  df <- dplyr::tibble(x = .df[1][[1]], y = .df[2][[1]])

  x <- NULL
  y <- NULL

  ggplot(df, aes(x, y)) +
    geom_line(size = 2, color = "#175C4A") +
    labs(x = "", y = "") +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank())
}
