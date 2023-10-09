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
all_2018_2023 <- rbindlist(list(K2023, I2023,
                                K2022, I2022,
                                K2021, I2021,
                                K2020, I2020,
                                K2019, I2019,
                                A2018), use.names=TRUE)


# STEP 6
# Extra cleaning
# Alter the info for the New Orleans case 
all_2018_2023$State[which(all_2018_2023$Incident.Date == "2022-06-27" & all_2018_2023$Address == "1400 block of Iberville St")] <- "Tennessee"
all_2018_2023$City.Or.County[which(all_2018_2023$Incident.Date == "2022-06-27" & all_2018_2023$Address == "1400 block of Iberville St")] <- "Erin"
all_2018_2023$Address[which(all_2018_2023$Incident.Date == "2022-06-27" & all_2018_2023$Address == "1400 block of Iberville St")] <- "300 block of Highway 149"

# Add Officer Harry Gunderson to the 2021-08-19 Albuquerque case
if (!"Officer Harry Gunderson" %in% all_2018_2023$Participant.Name & !"Harry Gunderson" %in% all_2018_2023$Participant.Name) {
  all_2018_2023$Incident.Date <- as.Date(all_2018_2023$Incident.Date)
  harry <- list(as.Date("2021-08-19"), "New Mexico", "Albuquerque", "1105 Juan Tabo Blvd NE", "male", "Officer Harry Gunderson", "Injured")
  all_2018_2023 <- rbindlist(list(all_2018_2023, harry), fill=TRUE)
} else {
  print("Have a look on the data.")
}

# Alter the 2021-11-19 Cameron Glen Dr NW case
all_2018_2023$City.Or.County[which(all_2018_2023$Incident.Date == "2021-11-19" & all_2018_2023$Address == "Cameron Glen Dr NW")] <- "Sandy Springs"

# Drop one row for the 2020-12-04 4085 Ely Ave Bronx case
all_2018_2023 <- all_2018_2023[-which(all_2018_2023$Incident.Date == "2020-12-04" & all_2018_2023$Address == "4085 Ely Ave")[3], ]

# Add the 2021-03-15 Chicago case
if (!"2021-03-15" %in% all_2018_2023$Incident.Date[which(all_2018_2023$City.Or.County == "Chicago")]) {
  chicago_20210315 <- list(as.Date("2021-03-15"), "Illinois", "Chicago", "8900 block of S Stony Island Avenue", "male", "Officer", "Injured")
  all_2018_2023 <- rbindlist(list(all_2018_2023, chicago_20210315), fill=TRUE)
} else {
  print("Have a look on the data.")
}

# Add the 2021-12-16 NYC Corona (Queens) case
if (!"2021-12-16" %in% all_2018_2023$Incident.Date[which(all_2018_2023$City.Or.County == "Corona (Queens)")]) {
  queens_20211216 <- list(as.Date("2021-12-16"), "New York", "Corona (Queens)", "56-15 Northern Blvd", "male", "Lieutenant", "Injured")
  all_2018_2023 <- rbindlist(list(all_2018_2023, queens_20211216), fill=TRUE)
} else {
  print("Have a look on the data.")
}

# Add three more rows for the 2019-01-28 Huston case
if (length(which(all_2018_2023$City.Or.County == "Houston" & all_2018_2023$Incident.Date == "2019-01-28")) == 2) {
  houston_20211216 <- data.table(Incident.Date = rep(as.Date("2019-01-28"), 3),
                                 State = rep("Texas", 3),	
                                 City.Or.County	= rep("Houston", 3),
                                 Address = rep("7815 Harding St", 3),
                                 Participant.Gender = c("N/A", "male", "male"),
                                 Participant.Name	= c("Officer", "Officer Gerald Goines", "Officer Steven Bryant"),
                                 Outcome = rep("Injured", 3))
  all_2018_2023 <- rbindlist(list(all_2018_2023, houston_20211216), fill=TRUE)
}

# Alter the 2020-07-02 Independence Ave and Hardesty Ave Kansas City case
all_2018_2023 <- all_2018_2023[-which(all_2018_2023$Incident.Date == "2020-07-02" & all_2018_2023$Address == "Independence Ave and Hardesty Ave" & all_2018_2023$Participant.Gender == "female"), ]
all_2018_2023$Participant.Gender[which(all_2018_2023$Incident.Date == "2020-07-02" & all_2018_2023$Address == "Independence Ave and Hardesty Ave")] <- "male"

# Add the 2022-08-11 Las Vegas case
if (length(which(all_2018_2023$City.Or.County == "Las Vegas" & all_2018_2023$Incident.Date == "2022-08-11")) == 0) {
  lasvegas_20220811 <- data.table(Incident.Date = rep(as.Date("2022-08-11"), 3),
                                  State = rep("Nevada", 3),	
                                  City.Or.County	= rep("Las Vegas", 3),
                                  Address = rep(NA, 3),
                                  Participant.Gender = rep(NA, 3),
                                  Participant.Name	= c("K9 Officer", "Officer", "Officer"),
                                  Outcome = rep("Injured", 3))
  all_2018_2023 <- rbindlist(list(all_2018_2023, lasvegas_20220811), fill=TRUE)
}

# Drop one row for the 2021-07-29 239 Gilkeson Rd Pittsburgh case
all_2018_2023 <- all_2018_2023[-which(all_2018_2023$Incident.Date == "2021-07-29" & all_2018_2023$Address == "239 Gilkeson Rd")[2], ]

# Save the final result
fwrite(all_2018_2023, "data/All_2018_2023.csv")

