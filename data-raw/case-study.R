library(meandr)
library(dplyr)
library(lubridate)
library(tidyr)


l <- 12 * 60 * 60 / 5

p0 <- meandr(n_points = l, n_nodes = 100, wt = seq(-1, 1, length.out = 10), seed = 1, scale = 1) %>%
  mutate(f = f * 50 + 2400 + rnorm(l, sd = 0.5),
         t = seq(as_datetime("2020-03-01 00:00:00"), as_datetime("2020-03-01 12:00:00"), length.out = l))
p1 <- p0

l2 <- 3 * 60 / 5
p2 <- create_path(n_points = l2, nodes = c(0.5, -0.5, 0, -.1,  .2, 2)) %>%
  mutate(f = f + rnorm(l2, sd = 0.025),
         f = 1000 * f / max(f))


p1[seq(l - l2 + 1, l), "f"] <- p1[seq(l - l2 + 1, l), "f"] + p2$f

set.seed(1)
E <- tibble(i = 1:10,
       avg = runif(10, 2000, 3000)) %>%
  rowwise() %>%
  mutate(data = list(meandr(n_points = l, n_nodes = 100, wt = seq(-1, 1, length.out = 10), scale = 1))) %>%
  unnest(cols = data) %>%
  with_groups(i, mutate,
              f = f * 50 + avg + rnorm(l, sd = 0.5),
              t = seq(as_datetime("2020-03-01 00:00:00"), as_datetime("2020-03-01 12:00:00"), length.out = l),
              .keep = "unused")


use_data(p0, p1, E, internal = TRUE, overwrite = TRUE)
