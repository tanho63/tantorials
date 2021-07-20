library(tidyverse)
library(rvest)
library(httr)
library(janitor)

track_url <- "https://www.tfrrs.org/results_search.html"

scrape_track <- function(season){

  track_page <- POST("https://www.tfrrs.org/results_search.html",
                     body = list(
                       meet_name = "",
                       sport = "track:xc",
                       state = "",
                       month = "",
                       year = season)) %>%
    httr::content() %>%
    html_element("table")

  meet_links <- tibble(
    url  = track_page %>% html_elements("a") %>% html_attr("href")
  )

  track_table <- html_table(track_page) %>%
    bind_cols(meet_links) %>%
    clean_names()

  return(track_table)
}

df_track <- map_dfr(2009:2021, scrape_track)
