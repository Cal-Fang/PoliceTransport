## ---------------------------
##
## Script name: 04_analysis.R
##
## Purpose of script: To make some pivot tables for the transport mode info.
##
## Author: Cal Chengqi Fang
##
## Date Created: 2023-09-30
##
## Copyright (c) Cal Chengqi Fang, 2023
## Email: cal.cf@uchicago.edu
##
## ---------------------------
##
## Notes:
##   
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
require(googlesheets4)

## ---------------------------
# Read google sheets data into R
final <- read_sheet('1w_BaFUAuatmUQBt3qtRBzhm9tTDV4B9lRjTGTq79bAg')

# Replace NYC boroughs with NYC
final$City.Or.County[final$City.Or.County=="Bronx"] <- "NYC"
final$City.Or.County[final$City.Or.County=="Brooklyn"] <- "NYC"
final$City.Or.County[final$City.Or.County=="Corona (Queens)"] <- "NYC"
final$City.Or.County[final$City.Or.County=="New York (Manhattan)"] <- "NYC"
final$City.Or.County[final$City.Or.County=="Staten Island"] <- "NYC"

# Combine city name and state name
final$GEO <- str_c(final$City.Or.County, ", ", append(state.abb, "DC")[match(final$State, append(state.name, "District of Columbia"))])

# Drop suicide case
final <- final %>% 
  filter(Detail != "Suicide" | is.na(Detail))

# Make pivot tables
pivot_count <- final %>% 
  group_by(GEO, Response.Type) %>% 
  summarize(count = n()) %>% 
  pivot_wider(names_from = Response.Type, values_from = count) 

pivot_prop <- pivot_count %>% 
  mutate(Ambulance_prop = Ambulance / sum(Ambulance, Others, Unknown, `Police Self-transfer`, na.rm = TRUE),
         Others_prop = Others / sum(Ambulance, Others, Unknown, `Police Self-transfer`, na.rm = TRUE),
         Unknown_prop = Unknown / sum(Ambulance, Others, Unknown, `Police Self-transfer`, na.rm = TRUE),
         `Police Self-transfer_prop` = `Police Self-transfer` / sum(Ambulance, Others, Unknown, `Police Self-transfer`, na.rm = TRUE)) %>% 
  select(-c(Ambulance, Others, Unknown, `Police Self-transfer`)) %>% 
  mutate_if(is.numeric, round, digits=4)

# Save the result
fwrite(pivot_count, "data/pivot1.csv")
fwrite(pivot_prop, "data/pivot2.csv")


