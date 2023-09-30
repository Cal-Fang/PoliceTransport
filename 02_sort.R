## ---------------------------
##
## Script name: 02_sort.R
##
## Purpose of script: To sort by cities so we can identify the cities that we need to further collect transport mode info on.
##
## Author: Cal Chengqi Fang
##
## Date Created: 2023-09-29
##
## Copyright (c) Cal Chengqi Fang, 2023
## Email: cal.cf@uchicago.edu
##
## ---------------------------
##
## Notes:
##   This is to group by cities and sort them to see what cities have met the criteria (at least 10 incidents during the analysis period.)
##
## ---------------------------

## set working directory for Mac and PC
setwd("/Users/atchoo/Documents/GitHub/homeboydropoff")  # Cal's working directory (mac)
# setwd("C:/Users/")     # Cal's working directory (PC)

## ---------------------------

rm(list=ls())
options(scipen=6, digits=4)         # I prefer to view outputs in non-scientific notation
memory.limit(30000000)                  # this is needed on some PCs to increase memory allowance, but has no impact on macs.

## ---------------------------

## load up the packages we will need:  (uncomment as required)

require(tidyverse)
require(data.table)
require(lubridate)

## ---------------------------
raw <- fread("data/All_2018_2023.csv")

# STEP 1
# Alter the info for the New Orleans case 
raw$State[which(raw$Incident.Date == "2022-06-27" & raw$Address == "1400 block of Iberville St")] <- "Tennessee"
raw$City.Or.County[which(raw$Incident.Date == "2022-06-27" & raw$Address == "1400 block of Iberville St")] <- "Erin"
raw$Address[which(raw$Incident.Date == "2022-06-27" & raw$Address == "1400 block of Iberville St")] <- "300 block of Highway 149"

# Add Harry Gunderson to the 2021-08-19 Albuquerque
if (!"Officer Harry Gunderson" %in% raw$Participant.Name & !"Harry Gunderson" %in% raw$Participant.Name) {
  raw$Incident.Date <- as.Date(raw$Incident.Date)
  harry <- list(as.Date("2021-08-19"), "New Mexico", "Albuquerque", "1105 Juan Tabo Blvd NE", "male", "Officer Harry Gunderson", "Injured")
  raw <- rbindlist(list(raw, harry), fill=TRUE)
}


# STEP 2
## Sorting
above10_list <- raw %>% 
  mutate(geo = paste0(State, "_", City.Or.County)) %>% 
  group_by(geo) %>% 
  summarise(casenum = n()) %>% 
  filter(casenum >= 10)

## Filtering the observations by the above10_list
## And also adding back the other one borough of NYC
above10 <- raw %>% 
  mutate(geo = paste0(State, "_", City.Or.County)) %>% 
  filter(geo %in% above10_list$geo | 
           City.Or.County %in% c("Bronx", "Brooklyn", "Corona (Queens)", "New York (Manhattan)", "Staten Island")) %>% 
  select(-geo)

fwrite(above10, "data/Above10_2018_2023.csv")

