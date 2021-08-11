library(tidyverse)
library(openxlsx)

## Read in the datasets
merged_df <- read_rds("www/merged_df.rds")
merged_df <- merged_df %>% 
                mutate(across(-value, ~trimws(.)))

sdg_file_codebook <- read.xlsx("www/WB_SDG.xlsx", sheet = "codebook")
goal_target_cols  <- read.xlsx("www/WB_SDG.xlsx", sheet = "goal_target")

## Inputs lists
goals_list <- trimws(unique(as.character(sort(merged_df$Goal))))
target_list <- trimws(goal_target_cols$Target)
topic_list <- trimws(sort(unique(merged_df$Topic)))
indicator_list <- trimws(sort(unique(merged_df$`Indicator Name`)))


