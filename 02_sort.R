## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Script name: 02_sort.R
##
## Purpose of script: To sort by cities so we can identify the cities that we need to further collect transport mode info on.
##
## Author: Cal Chengqi Fang
##
## Date Created: 2023-09-29
##
## Copyright (c) Cal Chengqi Fang, 2024
## Email: cal.cf@uchicago.edu
##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Notes:
##   This is to group by cities and sort them to see what cities have met the criteria 
## (at least 10 incidents during the analysis period.)
##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~

## set working directory for Mac and PC
setwd("/Users/atchoo/Documents/GitHub/HomeboyDropOff")  # Cal's working directory (mac)
# setwd("C:/Users/")     # Cal's working directory (PC)

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm(list=ls())
options(scipen=6, digits=4)         # I prefer to view outputs in non-scientific notation
memory.limit(30000000)                  # this is needed on some PCs to increase memory allowance, but has no impact on macs.

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~

## load up the packages we will need:  (uncomment as required)

require(tidyverse)
require(data.table)

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
raw <- fread("data/interm/recordsCleaned.csv")

# ----------------------------------------------- STEP 1 ----------------------------------------------- 
# Sort by case number
above10_list <- raw %>% 
  mutate(geo = paste0(State, "_", City.Or.County)) %>% 
  group_by(geo) %>% 
  summarise(casenum = n()) 

# Filter by case number and also add Staten Island back since NYC should be considered as a whole
above10_list <- above10_list %>% 
  filter(casenum >= 10 | geo == "New York_Staten Island")


# ----------------------------------------------- STEP 2 ----------------------------------------------- 
# Filter the observations by the above10_list
above10 <- raw %>% 
  mutate(geo = paste0(State, "_", City.Or.County)) %>% 
  filter(geo %in% above10_list$geo) %>% 
  select(Incident.Date, State, City.Or.County, Address,
         Outcome, Participant.Name, Participant.Gender)


# ----------------------------------------------- STEP 3 ----------------------------------------------- 
fwrite(above10, "data/interm/recordsFiltered.csv")

