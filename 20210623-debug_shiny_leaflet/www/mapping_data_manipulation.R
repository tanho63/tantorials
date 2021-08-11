library(tidyverse)
library(sf)
library(leaflet)
library(leaflet.extras)
library(rmapshaper)

## Read in the data
merged_df <- read_rds("www/merged_df.rds")
merged_df <- merged_df %>% 
  mutate(across(-value, ~trimws(.)))

## Subset the dataset
# 
# my_df <- merged_df %>%
#   filter(Goal == "SDG 3 : Good Health and Well-being" &
#            Topic == "Health: Mortality" &
#            `Indicator Name` == "Mortality rate, under-5 (per 1,000 live births)")

my_df <- merged_df

## Read in the shapefiles
africa_shp <- read_sf("www/afr_g2014_2013_0/afr_g2014_2013_0.shp")
africa_shp <- rmapshaper::ms_simplify(africa_shp, keep = 0.05)
africa_shp <- africa_shp %>% 
  mutate(ISO3 = trimws(ISO3)) %>% 
  mutate(ADM0_NAME = ifelse(ADM0_NAME=="C�te d'Ivoire", "Côte d'Ivoire",
                            ifelse(ISO3 == "SSD", "South Sudan",ADM0_NAME))) %>% 
  select(ADM0_CODE, ADM0_NAME, ISO3) %>% 
  filter(!ADM0_NAME %in% c("Abyei", "Western Sahara", "Hala'ib triangle",
                           "Ma'tan al-Sarra", "Ilemi triangle") &
           !is.na(ADM0_NAME))

## Filter the data to have the records of interest
## Goal: SDG 7 : Affordable and Clean Energy
## Topic: Environment: Energy production & use

my_df <- my_df %>% 
  mutate(`Country Code` = trimws(`Country Code`))

## Merge the data with the shapefiles
merged_mapping_df <- africa_shp %>% 
  left_join(.,my_df,  by = c("ISO3" = "Country Code")) 

# years <- as.character(unique(merged_mapping_df$Year))