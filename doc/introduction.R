## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(ggplot2)
set.seed(17)
theme_set(theme_minimal())

## ---- fig.width=7, fig.height=2-----------------------------------------------
# Set up quick plot function
library(ggplot2)
plot_f <- function(df) {
  ggplot(df, aes(t, f)) +
    geom_point(color = "#175C4A") +
    geom_line(color = "#175C4A")
}

# Generate data
approach_1 <- data.frame(t = 1:100,
                         f = rnorm(100))
plot_f(approach_1)

## ---- fig.width=7, fig.height=2-----------------------------------------------
approach_2 <- data.frame(t = 1:100,
                         f = cumsum(rnorm(100)))
plot_f(approach_2)

## ---- fig.width=7, fig.height=3-----------------------------------------------
library(meandr)

approach_3 <- meandr(n_points = 100,
                     n_nodes = 20,
                     wt = c(1, -1),
                     seed = 10)

plot_f(approach_3)

## ---- fig.width=7, fig.height=3-----------------------------------------------
plot_f(
  meandr(n_points = 100,
         n_nodes = 100, # increased from 20
         wt = c(1, -1),
         seed = 10)
)

## ---- fig.width=7, fig.height=3-----------------------------------------------
plot_f(
  meandr(n_points = 100,
         n_nodes = 3,
         wt = c(1, -1),
         seed = 20)
  )

## ---- fig.width=7, fig.height=3-----------------------------------------------
plot_f(
  meandr(n_points = 100,
         n_nodes = 100,
         wt = c(1, -0.8),
         seed = 21
  )
)

## -----------------------------------------------------------------------------
res1 <- meandr(n_points = 10, # low resolution
               n_nodes = 500,
               wt = c(1, -1),
               seed = 33)

res2 <- meandr(n_points = 1000, # high resolution
               n_nodes = 500,
               wt = c(1, -1),
               seed = 33)

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
library(dplyr)

res1 <- mutate(res1, curve = "res1")
res2 <- mutate(res2, curve = "res2")

bind_rows(res1, res2) %>% 
  ggplot(aes(t, f)) +
  geom_line(aes(color = curve, group = curve), size = 1.2) +
  ggsci::scale_color_lancet()

## ---- message = FALSE, warning = FALSE----------------------------------------
library(purrr)

scale <- map_dfr(1:5, ~ {
  meandr(n_points = 100,
         n_nodes = 500,
         wt = c(1, -1),
         scale = .x,
         seed = 33) %>% 
    mutate(scale = .x)
})

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
scale %>% 
  ggplot(aes(t, f)) +
  geom_line(aes(color = factor(scale), group = factor(scale)), size = 1.2) +
  ggsci::scale_color_locuszoom(name = "scale")

## ---- eval = FALSE------------------------------------------------------------
#  library(dplyr)
#  
#  meandr(scale = 4) %>%
#    mutate(with_noise = f + rnorm(100, sd = 0.2))

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
library(tidyr)

df1 <- meandr(n_points = 100, n_nodes = 500, wt = c(1, -1), scale = 4, seed = 33)
df2 <- meandr(n_points = 100, n_nodes = 20, wt = c(1, -1), scale = 4, seed = 10)
df3 <- meandr(n_points = 100, n_nodes = 50, wt = c(1, -1), scale = 4, seed = 14)

imap_dfr(list(df1, df2, df3), ~ {
  .x %>% 
    mutate(curve = .y,
           with_noise = f + rnorm(100, sd = 0.2)) %>% 
    rename(without_noise = f) %>% 
    pivot_longer(cols = c(with_noise, without_noise), names_to = "type", values_to = "f")
}) %>% 
  ggplot() +
  geom_line(aes(t, f, color = type, alpha = type), size = 1) +
  scale_alpha_discrete(range = c(1, 0.8)) +
  facet_wrap(~ curve, nrow = 1) +
  scale_color_manual(values = rev(ggsci::pal_lancet()(2))) +
  theme(legend.position = "none",
        panel.spacing = unit(1, "lines"),
        axis.text.x = element_blank()) +
  labs(x = "", y = "")

## -----------------------------------------------------------------------------
wt <- c(1, -1) # default value
set.seed(10)
nodes <- sample(c(1, -1), size = 20, replace = TRUE)
nodes

## ---- fig.width=7, fig.height=2, echo=FALSE-----------------------------------
# define x-values
x <- seq(1/100, 1, length.out = 100)

quasi_equal <- function(x, y, tol = 1e-7) {
  abs(x - y) < tol
}
quasi_greater_equal <- function(x, y, tol = 1e-7) {
  quasi_equal(x, y, tol) | (x > y)
}
node_int <- seq(0, 1, length.out = length(nodes) + 1)[-(length(nodes) + 1)]
x_int = rowSums(outer(x, node_int, FUN = "quasi_greater_equal"))
# 2nd derivative
f2 = nodes[x_int]

ggplot(data.frame(t = x, f = f2), aes(t, f)) +
  geom_point() +
  geom_line() +
  labs(y = "f''(t)")

## ---- fig.width=7, fig.height=2, echo=FALSE-----------------------------------
inc <- c(node_int, 0)[-1] - node_int
c1 <- c(0, cumsum(nodes * inc))
c1 <- c1[-length(c1)]

x_offset <- x - node_int[x_int]
f1 <- x_offset * f2 + c1[x_int]

ggplot(data.frame(t = x, f = f1), aes(t, f)) +
  geom_point(color = "#22B6FF") +
  geom_line(color = "#22B6FF") +
  labs(y = "f'(t)")

## ---- fig.width=7, fig.height=2, echo=FALSE-----------------------------------
ggplot(approach_3, aes(t, f)) +
  geom_point(color = "#0063A6") +
  geom_line(color = "#0063A6") +
  geom_line(aes(t, f1), data = data.frame(t = x, f = f1), color = "#22B6FF")

