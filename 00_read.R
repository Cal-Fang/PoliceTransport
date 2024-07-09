## ~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## Script name: 00_read.R
##
## Purpose of script: To read in 2018-2023 records from GVA website.
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
##   This is to read all record files from GVA website for the homeboy drop off project 
## that I worked on with Dr. Prachi Sanghavi.
##   I utilized the download link generated from the website. Since it is not 100% stable,
## researchers trying to reproduce this might need to click-open the website and generate
## new download link and update them to this script in order to run it.
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
require(httr)       # For url requesting and parsing

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------- STEP 1 ----------------------------------------------- 
# Write a function to handle downloading
download <- function(end, pre=prefix){
  # Make the url address
  url <- paste0(prefix, end)
  # Use httr to make the GET request
  response <- GET(url)
  # Parse the content as a CSV
  content <- content(response, "text")
  
  result <- fread(content, check.names=TRUE)
  return(result)
}

# Set up the prefix of the download link - you might need to change this
prefix <- "https://www.gunviolencearchive.org/export-finished/download?uuid=436a0477-9747-4396-a32c-71086dcce9bf&filename=public%3A//"

# 2024
K2024 <- download("export-f5f8702b-eab3-46d1-a11c-d5dee7f36893.csv")
I2024 <- download("export-dce90536-6168-4aea-9856-6c27a311ccb0.csv")

# 2023
K2023 <- download("export-e4a66ab9-84d5-4588-a323-62811dae72c3.csv")
I2023 <- download("export-7eee5b83-3689-4af9-914d-744bb7d585a2.csv") 

# 2022
K2022 <- download("export-6aa98895-6724-4133-92c0-41667dcc7c3e.csv") 
I2022 <- download("export-43c352f5-436b-4ab3-9d32-f4d2449b1e00.csv") 

# 2021
K2021 <- download("export-fb6c41a3-ece1-4f4b-a853-937cf1b246ab.csv") 
I2021 <- download("export-d7eea84b-a7fa-4d4d-9b02-c8d5b5fb1540.csv") 

# 2020
K2020 <- download("export-2d3b7e84-46a4-43d2-89c4-eb23b60386bb.csv") 
I2020 <- download("export-27db3609-e110-42c7-a484-5829770a9477.csv") 

# 2019
K2019 <- download("export-53676e90-6bac-45c4-9d64-061c9d1e4ebf.csv") 
I2019 <- download("export-a6e7ff9b-fbb1-4eef-bf21-ab812663279f.csv") 

# 2018
A2018 <- download("export-e51ddca1-8bbb-4d2b-90b3-f2c8a6b7fd05.csv") 


# ----------------------------------------------- STEP 2 ----------------------------------------------- 
# Save all raw data file for later cleaning and merging
save(K2024, I2024,
     K2023, I2023,
     K2022, I2022,
     K2021, I2021,
     K2020, I2020,
     K2019, I2019,
     A2018, 
     file="data/recordsRaw.Rdata")

