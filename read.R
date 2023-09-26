## ---------------------------
##
## Script name: read.R
##
## Purpose of script: To read in 2018-2023 records from GVA website.
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
##   This is to read all record files from GVA website for the homeboy drop off project 
##  that I worked on with Dr. Prachi Sanghavi.
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
prefix <- "https://www.gunviolencearchive.org/export-finished/download?uuid=436a0477-9747-4396-a32c-71086dcce9bf&filename=public%3A//"

# 2023
K2023 <- fread(paste0(prefix, "export-e9cadfb9-6eac-43ce-9804-17c2893f01a6.csv"), check.names=TRUE)
I2023 <- fread(paste0(prefix, "export-849e34d3-4fda-48d0-80d1-53bfaa95b410.csv"), check.names=TRUE) 

# 2022
K2022 <- fread(paste0(prefix, "export-ac8e6404-47e0-4750-b741-21ce08a41bd6.csv"), check.names=TRUE) 
I2022 <- fread(paste0(prefix, "export-aaaef91b-0fbf-4a0a-8219-c6b5f387ce6e.csv"), check.names=TRUE) 

# 2021
K2021 <- fread(paste0(prefix, "export-00261eef-de98-4efc-9bc9-e09ea1c03cd2.csv"), check.names=TRUE) 
I2021 <- fread(paste0(prefix, "export-fbf17a22-aab7-4c53-99bf-f268152fffc2.csv"), check.names=TRUE) 

# 2020
K2020 <- fread(paste0(prefix, "export-2ee1216a-f11b-4cf2-895d-3e81f55058bc.csv"), check.names=TRUE) 
I2020 <- fread(paste0(prefix, "export-5ec9be8d-b570-4e1d-b8d8-e8c787d15bce.csv"), check.names=TRUE) 

# 2019
K2019 <- fread(paste0(prefix, "export-126979de-4456-4960-b761-daa6c2272756.csv"), check.names=TRUE) 
I2019 <- fread(paste0(prefix, "export-d39f0b61-43b5-4e45-b5ee-e2c421c02e34.csv"), check.names=TRUE) 

# 2018
A2018 <- fread(paste0(prefix, "export-eb4c5abd-c297-4966-8dc6-435cc744a672.csv"), check.names=TRUE) 


# Save all raw data file for later cleaning and merging
save(K2023, I2023,
     K2022, I2022,
     K2021, I2021,
     K2020, I2020,
     K2019, I2019,
     A2018, 
     file="data/rawrecords.Rdata")

