library(tidyverse)
library(rvest)

realgm_url <- "https://basketball.realgm.com/ncaa/players/2013/A"

realgm_node <- realgm_url %>%
  read_html() %>%
  html_element("table")

player_links <- tibble(
  url  = realgm_node %>% html_elements("a[href^='/player']") %>% html_attr("href")
)

realgm_table <- html_table(realgm_node) %>%
  bind_cols(player_links)
