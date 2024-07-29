## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Script name: 01_clean.R
##
## Purpose of script: To clean the raw record files downloaded from GVA website.
##
## Author: Cal Chengqi Fang
##
## Date Created: 2023-09-26
##
## Copyright (c) Cal Chengqi Fang, 2024
## Email: cal.cf@uchicago.edu
##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Notes:
##   1. Time-wise: drop all records outside the analysis period, from 2018-04-20 to 2024-04-20
##   2. GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis,
##      meaning we would need to do extra cleaning and proofreading for 2018 records since the GVA file 
##      also includes cases where police were engaged but no officer was shot or killed. Such cleaning 
##      cannot really be automated easily so would be done by hand outside this script.
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
require(lubridate)      # For date handling

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------- STEP 1 ----------------------------------------------- 
# Read in the data
load("data/recordsRaw.Rdata")


# ----------------------------------------------- STEP 2 ----------------------------------------------- 
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

K2024 <- format_homeboy(K2024, "Killed")
K2023 <- format_homeboy(K2023, "Killed")
K2022 <- format_homeboy(K2022, "Killed")
K2021 <- format_homeboy(K2021, "Killed")
K2020 <- format_homeboy(K2020, "Killed")
K2019 <- format_homeboy(K2019, "Killed")

I2024 <- format_homeboy(I2024, "Injured")
I2023 <- format_homeboy(I2023, "Injured")
I2022 <- format_homeboy(I2022, "Injured")
I2021 <- format_homeboy(I2021, "Injured")
I2020 <- format_homeboy(I2020, "Injured")
I2019 <- format_homeboy(I2019, "Injured")

A2018 <- mutate(A2018, Incident.Date = mdy(Incident.Date))


# ----------------------------------------------- STEP 3 ----------------------------------------------- 
# Time-wise clean for the 2024 and 2018 files
K2024 <- filter(K2024, Incident.Date <= "2024-04-30")
I2024 <- filter(I2024, Incident.Date <= "2024-04-30")
A2018 <- filter(A2018, Incident.Date >= "2018-04-30")


# ----------------------------------------------- STEP 4 ----------------------------------------------- 
# Case-wise clean for the 2018 file
# Filter out rows of records with more than one individual killed or injured
A2018_nKnI <- A2018 %>% 
  filter(Victims.Killed > 1 | Victims.Injured > 1)

# Clean outside R
A2018_nKnI$WebAddress <- paste0("https://www.gunviolencearchive.org/incident/", A2018_nKnI$Incident.ID)
fwrite(A2018_nKnI, "data/interm/nKnI2018.csv")

# Read back in the file cleaned and proofread in google sheet
A2018_nKnI <- fread("data/interm/nKnI2018Cleaned.csv") %>% 
  mutate(Incident.Date = mdy(Incident.Date))

# Take out the rest rows
A2018_1K1I <- A2018 %>% 
  filter(Victims.Killed <= 1 & Victims.Injured <= 1)

# Make change to one special row
A2018_1K1I[A2018_1K1I$Incident.ID=="1185588", "Victims.Killed"] <- 0

# Transform the data from long to wide
A2018_1K1I <- A2018_1K1I %>% 
  select(-c(Suspects.Killed, Suspects.Injured, Suspects.Arrested, Operations)) %>% 
  rename(Killed = Victims.Killed,
         Injured = Victims.Injured) %>% 
  pivot_longer(cols=c("Killed", "Injured"),
               names_to='Outcome',
               values_to='Num') %>% 
  filter(Num != 0) %>% 
  select(-c(Incident.ID, Num)) 

# Stack back to get the cleaned set for 2018
A2018 <- A2018_1K1I %>% 
  mutate(Participant.Name = NA,
         Participant.Gender = NA) %>% 
  rbind(A2018_nKnI) %>% 
  as.data.table()


# ----------------------------------------------- STEP 5 ----------------------------------------------- 
# Combine all data.table to obtain a large data.table for online searching
A2018_2024 <- rbindlist(list(K2024, I2024,
                             K2023, I2023,
                             K2022, I2022,
                             K2021, I2021,
                             K2020, I2020,
                             K2019, I2019,
                             A2018), use.names=TRUE)


# ----------------------------------------------- STEP 6 ----------------------------------------------- 
# Extra cleaning
# Alter the info for the 2022-06-27 1400 block of Iberville St New Orleans, LA case 
A2018_2024$State[which(A2018_2024$Incident.Date == "2022-06-27" & A2018_2024$Address == "1400 block of Iberville St")] <- "Tennessee"
A2018_2024$City.Or.County[which(A2018_2024$Incident.Date == "2022-06-27" & A2018_2024$Address == "1400 block of Iberville St")] <- "Erin"
A2018_2024$Address[which(A2018_2024$Incident.Date == "2022-06-27" & A2018_2024$Address == "1400 block of Iberville St")] <- "300 block of Highway 149"

# Add Officer Harry Gunderson to the 2021-08-19 1105 Juan Tabo Blvd NE Albuquerque, NM case
if (!"Officer Harry Gunderson" %in% A2018_2024$Participant.Name & !"Harry Gunderson" %in% A2018_2024$Participant.Name) {
  A2018_2024$Incident.Date <- as.Date(A2018_2024$Incident.Date)
  harry <- list(as.Date("2021-08-19"), "New Mexico", "Albuquerque", "1105 Juan Tabo Blvd NE", "male", "Officer Harry Gunderson", "Injured")
  A2018_2024 <- rbindlist(list(A2018_2024, harry), fill=TRUE)
} else {
  print("Have a look on the data.")
}

# Alter the 2021-11-19 Cameron Glen Dr NW Atlanta, GA case
A2018_2024$City.Or.County[which(A2018_2024$Incident.Date == "2021-11-19" & A2018_2024$Address == "Cameron Glen Dr NW")] <- "Sandy Springs"

# Drop one row for the 2020-12-04 4085 Ely Ave Bronx, NY case
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2020-12-04" & A2018_2024$Address == "4085 Ely Ave")[3], ]

# Add three more rows for the 2019-01-28 7815 Harding St Huston, TX case
if (length(which(A2018_2024$City.Or.County == "Houston" & A2018_2024$Incident.Date == "2019-01-28")) == 2) {
  houston_20211216 <- data.table(Incident.Date = rep(as.Date("2019-01-28"), 3),
                                 State = rep("Texas", 3),	
                                 City.Or.County	= rep("Houston", 3),
                                 Address = rep("7815 Harding St", 3),
                                 Participant.Gender = c("N/A", "male", "male"),
                                 Participant.Name	= c("Officer", "Officer Gerald Goines", "Officer Steven Bryant"),
                                 Outcome = rep("Injured", 3))
  A2018_2024 <- rbindlist(list(A2018_2024, houston_20211216), fill=TRUE)
} else {
  print("Have a look on the data.")
}

# Alter the 2020-07-02 Independence Ave and Hardesty Ave Kansas City, MO case
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2020-07-02" & A2018_2024$Address == "Independence Ave and Hardesty Ave" & A2018_2024$Participant.Gender == "female"), ]
A2018_2024$Participant.Gender[which(A2018_2024$Incident.Date == "2020-07-02" & A2018_2024$Address == "Independence Ave and Hardesty Ave")] <- "male"

# Drop one row for the 2021-07-29 239 Gilkeson Rd Pittsburgh, PA case
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2021-07-29" & A2018_2024$Address == "239 Gilkeson Rd")[2], ]

# Drop the 2023-07-25	778 Parkrose Rd Memphis, TN	case as the injured person is not a police officer
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2023-07-25" & A2018_2024$Address == "778 Parkrose Rd"), ]

# Drop the 2020-04-09 945 W Belmont Ave Chicago, IL	case as the injured person is not a police officer
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2020-04-09" & A2018_2024$Address == "945 W Belmont Ave"), ]

# Drop the 2023-07-01 3200 E Washington St Phoenix, AZ case as neither officer was shot
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2023-07-01" & A2018_2024$Address == "3200 E Washington St"), ]

# Drop the 2022-03-18 600 block of S Independence Blvd Chicago, IL case as this is an mistake
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2022-03-18" & A2018_2024$Address == "600 block of S Independence Blvd"), ]

# Drop the 2018-07-25 200 block of Sheridan St NE Washington DC case as this police was not shot
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2018-07-25" & A2018_2024$Address == "200 block of Sheridan St NE"), ]

# Drop the 2022-04-16 34 Market Pl Baltimore MD case as this police was not shot
A2018_2024 <- A2018_2024[-which(A2018_2024$Incident.Date == "2022-04-16" & A2018_2024$Address == "34 Market Pl"), ]


# ----------------------------------------------- STEP 7 ----------------------------------------------- 
# Save the final result
fwrite(A2018_2024, "data/interm/recordsCleaned.csv")

