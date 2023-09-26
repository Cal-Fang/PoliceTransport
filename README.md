# homeboydropoff

# STEP 0 Retrieve needed data from GVA
We would need to download historical records prior to 2023-01-01 from the [Past Summary Ledgers](https://www.gunviolencearchive.org/past-tolls) page and up-to-date records since 2023-01-01 from the [homepage](https://www.gunviolencearchive.org/). For our analysis, we downloaded the following files:
- 2023
  - [OFFICER INVOLVED OFFICER KILLED IN 2023](https://www.gunviolencearchive.org/reports/officer-killed?year=2023)
  - [OFFICER INVOLVED OFFICER INJURED IN 2023](https://www.gunviolencearchive.org/reports/officer-shot?year=2023)
- 2022
  - [OFFICER INVOLVED OFFICER KILLED IN 2022](https://www.gunviolencearchive.org/reports/officer-killed?year=2022)
  - [OFFICER INVOLVED OFFICER INJURED IN 2022](https://www.gunviolencearchive.org/reports/officer-shot?year=2022)
- 2021
  - [OFFICER INVOLVED OFFICER KILLED IN 2021](https://www.gunviolencearchive.org/reports/officer-killed?year=2021)
  - [OFFICER INVOLVED OFFICER INJURED IN 2021](https://www.gunviolencearchive.org/reports/officer-shot?year=2021)
- 2020
  - [OFFICER INVOLVED OFFICER KILLED IN 2020](https://www.gunviolencearchive.org/reports/officer-killed?year=2020)
  - [OFFICER INVOLVED OFFICER INJURED IN 2020](https://www.gunviolencearchive.org/reports/officer-shot?year=2020)
- 2019
  - [OFFICER INVOLVED OFFICER KILLED IN 2019](https://www.gunviolencearchive.org/reports/officer-killed?year=2019)
  - [OFFICER INVOLVED OFFICER INJURED IN 2019](https://www.gunviolencearchive.org/reports/officer-shot?year=2019)
- 2018
  - [OFFICER SHOT OR KILLED](https://www.gunviolencearchive.org/reports/officer-shot-killed?year=2018)

The script used for this step is named as **00_clean.R**.

# STEP 1 Combine and clean raw data files
Time-wise:  
Since we have decided the time window should be from 2018-04-30 to 2023-04-30 for this project, we would need to drop all records prior to this period for the 2018 file and all records post to this period for the 2023 files.

Case-wise:  
GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis, we would need to do some extra cleaning and proofreading for ***2018 records*** since the GVA file also includes cases where police were engaged but no officer was shot or killed.

