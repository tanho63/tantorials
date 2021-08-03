library(tidyverse)
library(jsonlite)

obs_raw <- read_json("https://github.com/rpodcast/r_media_prod/raw/master/data/shinydevseries_scene_collection_livestream_1080p.json")

obs_sources <- obs_raw %>%
  pluck("sources") %>%
  tibble() %>%
  hoist(1,
        "id",
        "name",
        "enabled",
        "settings"
        )

obs_file_sources <- obs_sources %>%
  filter(str_detect(id,"source$")) %>%
  select(
    id,
    name,
    enabled,
    settings
  ) %>%
  hoist(
    settings,
    "file"="file",
    "local_file"="local_file",
    "text"="text",
    "file_text"="text_file"
     ) %>%
  mutate(
    file = coalesce(file, local_file, file_text),
    local_file = NULL,
    file_text = NULL,
    settings = NULL
  )
