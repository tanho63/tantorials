library(tidyverse)
library(jsonlite)

# raw_recipes <- read_csv("RAW_recipes.csv") # too big for git

x <- saveRDS(raw_recipes,"raw_recipes.rds")

recipes <- raw_recipes %>%
  mutate(
    across(
      c("tags", "nutrition", "steps", "ingredients"),
      ~ .x %>% str_remove_all("\\[|\\]|\\'") %>% str_split(",")
           )
  )

tags <- recipes %>%
  select(name, id, tags) %>%
  unnest(tags) %>%
  count(tags)

ingredients <- recipes %>%
  select(name, id, ingredients) %>%
  unnest(ingredients) %>%
  count(ingredients)
