# homeboydropoff

# STEP 1 Retrieve needed data from GVA
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
 
One thing to be noted for later cleaning is, GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis, we would need to do some extra cleaning and proofreading for ***2018 records*** since the GVA file also includes cases where police were engaged but no officer was shot or killed.

# STEP 2 Combine and clean raw data files
