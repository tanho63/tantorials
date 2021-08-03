sr_raw <- readRDS(url("https://github.com/guga31bb/sport_radar/blob/master/data/participation/c2b24b1a-98c5-465c-8f83-b82e746b4fcf.rds?raw=true"))

sr <- sr_raw %>%
  magrittr::extract(c("summary","plays")) %>%
  list() %>%
  tibble() %>%
  unnest_wider(1) %>%
  unnest_wider(summary) %>%
  unnest_wider(season, names_sep = "_") %>%
  unnest_wider(week, names_sep = "_") %>%
  unnest_wider(venue, names_sep = "_") %>%
  unnest_wider(home, names_sep = "_") %>%
  unnest_wider(away, names_sep = "_") %>%
  select(season = season_year,
         week = week_sequence,
         venue_name,
         home_alias,
         away_alias,
         plays) %>%
  unnest(plays, names_sep = "_") %>%
  select(season,
         week,
         venue_name,
         home_alias,
         away_alias,
         plays_id,
         plays_description,
         home_players=plays_home.players,
         away_players=plays_away.players
         ) %>%
  mutate(
    home_player_names = map(home_players, ~ .x$name %>% paste(collapse = "; ")),
    away_player_names = map(away_players, ~ .x$name %>% paste(collapse = "; ")),
    home_average_jersey = map_dbl(home_players, ~.x$jersey %>% as.numeric() %>% mean()),
    away_average_jersey = map_dbl(away_players, ~.x$jersey %>% as.numeric() %>% mean())
  )
