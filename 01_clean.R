## ---------------------------
##
## Script name: 01_clean.R
##
## Purpose of script: To clean the raw record files downloaded from GVA website.
##
## Author: Cal Chengqi Fang
##
## Date Created: 2023-09-26
##
## Copyright (c) Cal Chengqi Fang, 2023
## Email: cal.cf@uchicago.edu
##
## ---------------------------
##
## Notes:
##   1. Time-wise: drop all records outside the analysis period, from 2018-04-20 to 2023-04-20
##   2. GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis,
##      meaning we would need to do extra cleaning and proofreading for 2018 records since the GVA file 
##      also includes cases where police were engaged but no officer was shot or killed. Such cleaning 
##      cannot really be automated easily so would be done by hand outside this script.
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

## ---------------------------

# STEP 1 
# Read in the data
load("data/rawrecords.Rdata")

## Write a function to
##  1) Change the date column format for each data.table;
##  2) Drop the Operation column
##  3) Create a Outcome column to inform whether the corresponding officer is killed or injured.
format_homeboy <- function(dt, outcome) {
  temp <- dt %>% 
    select(-c(Operations, Participant.Age.Group)) %>% 
    mutate(Incident.Date = mdy(Incident.Date),
           Outcome = outcome)

  return(temp)
}

K2023 <- format_homeboy(K2023, "Killed")
K2022 <- format_homeboy(K2022, "Killed")
K2021 <- format_homeboy(K2021, "Killed")
K2020 <- format_homeboy(K2020, "Killed")
K2019 <- format_homeboy(K2019, "Killed")

I2023 <- format_homeboy(I2023, "Injured")
I2022 <- format_homeboy(I2022, "Injured")
I2021 <- format_homeboy(I2021, "Injured")
I2020 <- format_homeboy(I2020, "Injured")
I2019 <- format_homeboy(I2019, "Injured")

A2018 <- mutate(A2018, Incident.Date = mdy(Incident.Date))


# STEP 2
# Time-wise clean for the 2023 and 2018 files
K2023 <- filter(K2023, Incident.Date <= "2023-04-30")
I2023 <- filter(I2023, Incident.Date <= "2023-04-30")
A2018 <- filter(A2018, Incident.Date >= "2018-04-30")


# STEP 3
# Case-wise clean for the 2018 file
## Filter out rows of records with more than one individual killed or injured
A2018_nKnI <- A2018 %>% 
  filter(Victims.Killed > 1 | Victims.Injured > 1)

## Clean outside R
A2018_nKnI$WebAddress <- paste0("https://www.gunviolencearchive.org/incident/", A2018_nKnI$Incident.ID)
fwrite(A2018_nKnI, "data/A2018_nKnI.csv")

## Read back in the file cleaned and proofread in google sheet
A2018_nKnI <- fread("data/A2018_nKnI_cleaned.csv") %>% 
  mutate(Incident.Date = mdy(Incident.Date))

## Take out the rest rows
A2018_1K1I <- A2018 %>% 
  filter(Victims.Killed <= 1 & Victims.Injured <= 1)

## Make change to one special row
A2018_1K1I[A2018_1K1I$Incident.ID=="1185588", "Victims.Killed"] <- 0

## Transform the data from long to wide
A2018_1K1I <- A2018_1K1I %>% 
  select(-c(Suspects.Killed, Suspects.Injured, Suspects.Arrested, Operations)) %>% 
  rename(Killed = Victims.Killed,
         Injured = Victims.Injured) %>% 
  pivot_longer(cols=c("Killed", "Injured"),
               names_to='Outcome',
               values_to='Num') %>% 
  filter(Num != 0) %>% 
  select(-c(Incident.ID, Num)) 


# STEP 4 
# Stack back to get the ultimate set for 2018
A2018 <- A2018_1K1I %>% 
  mutate(Participant.Name = NA,
         Participant.Gender = NA) %>% 
  rbind(A2018_nKnI) %>% 
  as.data.table()

# STEP 5
# Combine all data.table to obtain a large data.table for online searching
A2018_2023 <- rbindlist(list(K2023, I2023,
                             K2022, I2022,
                             K2021, I2021,
                             K2020, I2020,
                             K2019, I2019,
                             A2018), use.names=TRUE)

fwrite(A2018_2023, "data/A2018_2023.csv")

