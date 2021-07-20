library(tidyverse)
library(rvest)

scrape_gi <- function(yearstub){

  gi_url <- paste0("https://www.yojoe.com/action/",yearstub)

  gi_page <- read_html(gi_url) %>%
    html_elements(".corners") %>%
    html_elements("a[href$='shtml']")

  gi_table <- tibble(
    name = gi_page %>% html_attr("title"),
    img = gi_page %>% html_element("img") %>% html_attr("src"),
    url = gi_page %>% html_attr("href"),
  )

  return(gi_table)
}

gi_float_years <- c(1982:2018) %>% str_sub(3,4)
gi_tables <- map_dfr(gi_float_years, possibly(scrape_gi,otherwise = tibble()))

gi_tables_2 <- tibble(
  years = 1982:2018
) %>%
  mutate(
    id = str_sub(years, 3,4),
    data = map(id, possibly(scrape_gi,otherwise = tibble()))
  ) %>%
  unnest(data)


# gi_alpha <- gi_url %>%
#   read_html() %>%
#   html_element("#alphabeticalList") %>%
#   html_elements("a")
#
# gi_table <- tibble(
#   name = html_text(gi_alpha),
#   url = html_attr(gi_alpha, "href")
# )
