## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(ggplot2)
library(dplyr)
set.seed(17)
theme_set(theme_minimal())

plot_f <- function(df) {
  ggplot(df, aes(t, f)) +
    geom_point(color = "#175C4A") +
    geom_line(color = "#175C4A")
}

## -----------------------------------------------------------------------------
method_1 <- data.frame(t = 1:100,
                       f = rnorm(100))

## ---- echo = FALSE, fig.width = 7, fig.height=2-------------------------------
plot_f(method_1) +
  labs(title = "Method 1")

## -----------------------------------------------------------------------------
method_2 <- data.frame(t = 1:100,
                       f = cumsum(rnorm(100)))

## ---- echo = FALSE, fig.width=7, fig.height=2---------------------------------
plot_f(method_2) +
  labs(title = "Method 2")

## -----------------------------------------------------------------------------
library(meandr)

df1 <- meandr(n_points = 100,
              n_nodes = 20,
              seed = 2)

df1

## ----echo = FALSE, fig.width=7, fig.height=3----------------------------------
plot_f(df1) +
  labs(title = "df1")

## -----------------------------------------------------------------------------
df2 <- meandr(n_points = 100,
              n_nodes = 100, # increased from 20
              wt = c(1, -1),
              seed = 2) # same seed as df1

## ----echo = FALSE, fig.width=7, fig.height=3----------------------------------
df2 %>% 
  mutate(color = t > 0.25) %>% 
  ggplot(aes(t, f)) +
  geom_point(aes(color = color)) +
  geom_line(aes(color = color)) +
  ggsci::scale_color_locuszoom() +
  theme(legend.position = "none") +
geom_vline(xintercept = 0.25, color = "slategray") +
  geom_label(label = "included in df1", fill = "#D43F3AFF", color = "white", x = 0.25, y = 0.35, hjust = 1.05, label.padding = unit(0.25, "lines")) +
  geom_segment(color = "slategray", x = 0.25, xend = 0.2, y = 0.2, yend = 0.2, arrow = arrow(length = unit(0.05, "npc"))) +
  geom_label(label = "new territory with df2", x = 0.25, y = 0.35, hjust = -0.05, label.padding = unit(0.25, "lines"), fill = "#EEA236FF", color = "white") +
  geom_segment(color = "slategray", x = 0.25, xend = 0.3, y = 0.2, yend = 0.2, arrow = arrow(length = unit(0.05, "npc"))) +
  labs(title = "df2")
  

## -----------------------------------------------------------------------------
res1 <- meandr(n_points = 10, # low resolution
               n_nodes = 100,
               seed = 2)

res2 <- meandr(n_points = 1000, # high resolution
               n_nodes = 100,
               seed = 2)

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
library(dplyr)

res1 <- mutate(res1, curve = "res1")
res2 <- mutate(res2, curve = "res2")

bind_rows(res1, res2) %>% 
  ggplot(aes(t, f)) +
  geom_line(aes(color = curve, group = curve), size = 1.2) +
  ggsci::scale_color_lancet() +
  labs(title = "n_points", subtitle = "10 vs 1000")

## ----eval = FALSE-------------------------------------------------------------
#  meandr(n_points = 200,
#         n_nodes = 50,
#         wt = c(-1, 1), # default value
#         seed = 1010)

## ----echo = FALSE, fig.width=7, fig.height=5, echo=FALSE----------------------
set.seed(1010)

nodes <- meandr:::sample_roll(c(1, -1), 50, 0.75)

# define x-values
x <- seq(1/100, 1, length.out = 200)

node_int <- seq(0, 1, length.out = length(nodes) + 1)[-(length(nodes) + 1)]
x_int = rowSums(outer(x, node_int, FUN = meandr:::quasi_greater_equal))
# 2nd derivative
f2 = nodes[x_int]

inc <- c(node_int, 0)[-1] - node_int
c1 <- c(0, cumsum(nodes * inc))
c1 <- c1[-length(c1)]

x_offset <- x - node_int[x_int]
f1 <- x_offset * f2 + c1[x_int]

# parent fn
c0 <- c(0, cumsum(nodes * inc ^ 2 / 2 + c1 * inc))
c0 <- c0[-length(c0)]

f <- f2 * x_offset ^ 2 / 2 + c1[x_int] * x_offset + c0[x_int]

f <- f * 1 / max(abs(f))

gain1 <- tibble(x, `2nd derivative` = f2, `1st derivative` = f1, `final output` = f) %>% 
  tidyr::pivot_longer(-1, names_to = "fn") %>% 
  mutate(fn = forcats::fct_inorder(fn))

gain1 %>% 
  ggplot(aes(x, value, color = fn)) +
  geom_line(size = 1.2) +
  scale_color_manual(values = c("#4EC9DF", "#63A1D0", "#344986")) +
  facet_wrap(~ fn, ncol = 1, scales = "free_y") +
  labs(title = "wt: sampling + integration",
       x = "",
       y = "") +
  theme(legend.position = "none",
        panel.grid.minor = element_blank())

## -----------------------------------------------------------------------------
gain1 <- meandr(n_points = 200,
                n_nodes = 50,
                gain = 0.75, # default
                seed = 1010)

gain2 <- meandr(n_points = 200,
                n_nodes = 50,
                gain = 2, # increase, this will inject more variance into 2nd derivative
                seed = 1010)

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
gain1 <- mutate(gain1, curve = "gain1")
gain2 <- mutate(gain2, curve = "gain2")

bind_rows(gain1, gain2) %>% 
  ggplot(aes(t, f)) +
  geom_line(aes(color = curve, group = curve), size = 1.2) +
  geom_label(label = "Observe gain2 is 'wigglier'", fill = "#D43F3AFF", color = "white", x = 0.6, y = 0, label.padding = unit(0.25, "lines")) +
  ggsci::scale_color_lancet()

## -----------------------------------------------------------------------------
custom_wt <- meandr(n_points = 200,
                    n_nodes = 50,
                    wt = seq(-1, 1, by = 0.01), # more variety in 2nd derivative values
                    gain = 2,
                    seed = 1010)

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=3----
custom_wt %>% 
  ggplot(aes(t, f)) +
  geom_line(color = "#175C4A", size = 1.2) +
  labs(title = "custom_wt")

## ----eval = FALSE-------------------------------------------------------------
#  gain3 <- meandr(gain = 1000) # 1000 doesn't work because exp(1000) returns Inf
#  
#  #> Error in sample.int(length(x), size, replace, prob): NA in probability vector

## ---- message = FALSE, warning = FALSE----------------------------------------
library(purrr)

scale <- map_dfr(1:5, ~ {
  meandr(n_points = 100,
         n_nodes = 20,
         wt = c(1, -1),
         scale = .x,
         seed = 20) %>% 
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

## ---- echo = FALSE, message = FALSE, warning = FALSE, fig.width=7, fig.height=7----
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
  facet_wrap(~ curve, ncol = 1) +
  scale_color_manual(values = rev(ggsci::pal_lancet()(2))) +
  theme(legend.position = "none",
        panel.spacing = unit(1, "lines"),
        axis.text.x = element_blank()) +
  labs(x = "", y = "")

