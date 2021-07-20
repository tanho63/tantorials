library(tidyverse)
library(rvest)

limpopo_url <- "https://www.dmr.gov.za/mineral-policy-promotion/operating-mines/limpopo"

accordion <- limpopo_url %>%
  read_html() %>%
  html_element("#accordion")

mines <- tibble(
  mines = accordion %>% html_elements(".panel-title") %>% html_text(),
  data = accordion %>%
    html_elements('.panel-body') %>%
    map(~ html_elements(.x, ".col-md-6") %>%
          html_text2())
) %>%
  unnest(data) %>%
  separate(
    data,
    into = c("name","value"),
    sep = ": "
  ) %>%
  pivot_wider(
    names_from = name,
    values_from = value
  )

