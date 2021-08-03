# Marine mammals

library(tidyverse)
library(jsonlite)

x <- read_json("https://github.com/kierisi/marinemammalrescue/raw/main/data-raw/sitedata.json")

x %>%
  tibble() %>%
  unnest_longer(1) %>%
  unnest_wider(1)

patients <- x$patients %>%
  tibble() %>%
  unnest_wider(1)

