# Police Transport

[`Read`](#Retrieve-needed-data-from-GVA) [`Clean`](#Clean-and-combine-raw-data-files) [`Sort`](#Sort-and-identify-the-analysis-subject-cities) [`Collect`](#Collect-the-transport-mode-information) [`Validate`](#Validate) [`Analyze`](#Analyze)

## STEP 0 Retrieve needed data from GVA
For our analysis, we downloaded the following files from the [Gun Violence Archive](https://www.gunviolencearchive.org/):
- 2024
  - [OFFICER INVOLVED OFFICER KILLED IN 2024](https://www.gunviolencearchive.org/reports/officer-killed?year=2024)
  - [OFFICER INVOLVED OFFICER INJURED IN 2024](https://www.gunviolencearchive.org/reports/officer-shot?year=2024)
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

The script used for this step is named **00_read.R**. 

This script used the download link generated from the GVA website to download the data sets mentioned above and stored them as the *recordsRaw.Rdata* file. This script worked smoothly as of July 10th, 2024. However, since download links can change, become unavailable, or require different methods of access in the future, if researchers trying to reproduce this research are experiencing difficulties running it, we recommend using the links above and manually downloading and reading the files. As long as the files are named in the same fashion as detailed in **00_read.R**, doing so should not affect the following steps.


## STEP 1 Clean and combine raw data files
We first dropped the Operations and Participant.Age.Group columns from records of 2019-2024. And then we did some time-wise cleaning and case-wise cleaning.
### Time-wise cleaning  
Since we decided the time window should be from 2018-04-30 to 2024-04-30 for this project, we needed to drop all records prior to this period for the 2018 file and all records after this period for the 2024 files.

### Reformatting 
GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis, we needed to do some extra cleaning and proofreading for ***2018 records***. The 2018 file has the following features:
1. Each case is summarized into one row;
2. Every case recorded in this document had at least one police killed or injured;
3. Victims.Killed and Victims.Injured also count non-police subject (citizen) killed or injured in the corresponding case.

The table below gives some examples:
<table>
  <tr>
    <th>What happened </th>
    <th>Victims.Killed </th>
    <th>Victims.Injured </th>
  </tr>
  <tr>
    <td> 2 police killed, 0 police injured;<br/> 0 citizen killed, 1 citizen injured </td>
    <td> 2  </td>
    <td> 1  </td>
  <tr>
    <td> 0 police killed, 1 police injured;<br/> 2 citizen killed, 0 citizen injured </td>
    <td> 2  </td>
    <td> 1  </td>
  </tr>
  <tr>
    <td> 1 police killed, 0 police injured;<br/> 0 citizen killed, 0 citizen injured </td>
    <td> 1  </td>
    <td> 0  </td>
  </tr>
  <tr>
    <td> 0 police killed, 1 police injured;<br/> 0 citizen killed, 0 citizen injured </td>
    <td> 0  </td>
    <td> 1  </td>
  </tr>
  <tr>
    <td> 0 police killed, 0 police injured;<br/> 0 citizen killed, 1 citizen injured </td>
    <td colspan="2"> Not recorded in this file  </td>
  </tr>
  <tr>
    <td> 0 police killed, 0 police injured;<br/> 1 citizen killed, 0 citizen injured </td>
    <td colspan="2"> Not recorded in this file  </td>
  </tr>
</table>

Based on this storing logic, we cleaned the 2018 file into the same format as the other years' records in the following steps:
1. Among rows where either Victims.Killed or Victims.Injured is larger than 1,
   1. Export these rows as a new file with a new column of the address of the incident report webpage;
   2. Open this new file outside R and break each row into multiple rows so that each row would represent one police injured or one police killed with reference to the webpage incident report;
   3. Add more information from the webpage incident report so the result file has 7 columns including Incident.Date, State, City.Or.County, Address, Participant.Name, Outcome, and Participant.Gender.
2. Among the rest rows where either Victims.Killed or Victims.Injured is 1, 
   1. Keep the 148 rows where only one of these two columns is 1, as each of these rows marked exactly one police injured or killed;
   2. Keep the row of [incident 1172042](https://www.gunviolencearchive.org/incident/1172042) since both injured and killed victims were police;
   3. Assign 0 to Victims.Killed to the row of [incident 1185588](https://www.gunviolencearchive.org/incident/1185588) since the killed victim is not police;
   4. Transform this file from wide to long and drop unuseful columns so that it would have 5 columns including Incident.Date, State, City.Or.County, Address, and Outcome;
   5. Add two NA columns Participant.Name and Participant.Gender.
3. Combine the two data.table and obtain a reformated cleaned 2018 record file.

### Combining 
After cleaning the 2018 files, all years' records were row-bound together to create the general file. 

### Case-specific cleaning
There are several changes needed to be made in specific cases. Although in the actual analysis, these were found in a later step, to ensure the accuracy of sorting and filtering, it makes more sense for anyone trying to reproduce the result to change these first:
1. GVA recorded [a police shot and injured](https://www.gunviolencearchive.org/incident/2342312) in New Orleans, LA because the suspect was arrested in New Orleans. However, the injured police was shot in Erin, TN, and is a part of the Erin police department;
2. GVA recorded [three police shot and injured](https://www.gunviolencearchive.org/incident/2094830) for the 2021-08-19 Albuquerque, NM case. However, there were actually four police shot and injured. One extra row needs to be added;
3. GVA recorded [one police shot and injured](https://www.gunviolencearchive.org/incident/2170769) in Atlanta, GA on 2021-11-19. This police was actually shot and injured at Sandy Springs. He also works for the Sandy Springs Police Department. This case should be altered;
4. GVA recorded [three marshals shot and injured](https://www.gunviolencearchive.org/incident/1868904) in Bronx NYC on 2020-12-04. This was early misinformation. There were only two marshals injured according to later news;
5. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/1314289) in Houston on 2019-01-28. There were actually [five officers shot and injured](https://www.fox26houston.com/news/sergeant-who-sustained-knee-injury-during-shooting-released-from-hospital);
6. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/1723067) in Kansas City, MI at 2020-07-02. There was actually only [one male officer shot and injured](https://fox4kc.com/news/missouri-highway-patrol-responding-to-kansas-city-officer-involved-shooting/). The other injured person is a Kansas City Bus driver and should not be included here;
7. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/2077587) in Pittsburgh on 2021-07-29. One of them suffered from a minor injury [not related to gunfire](https://www.pennlive.com/news/2021/07/pa-man-killed-parents-shot-at-police-died-in-crash-reports.html);
8. GVA recorded [one officer shot and injured](https://www.gunviolencearchive.org/incident/2663163) in Memphis on 2023-07-25. This injured person is [not a police officer](https://www.actionnews5.com/2023/07/25/school-security-guard-injured-westwood-shooting/);
9. GVA recorded [one officer shot and injured](https://www.gunviolencearchive.org/incident/1655454) in Chicago on 2020-04-09. This injured person is [not a police officer](https://cwbchicago.com/2020/04/security-guard-licensed-to-carry-a-gun-for-2-weeks-accidentally-shoots-teen-on-red-line.html);
10. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/2640515) in Phoenix on 2023-07-01. Neither of them was shot in this case as [the suspect did not hold a gun and only grabbed officers' taser](https://www.phoenix.gov/newsroom/police/2807);
11. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/2256840) in Chicago on 2022-03-18. This is a mistake. The information recorded for this case on GVA website is identical to the case recorded for [Chicago on 2022-03-18](https://www.gunviolencearchive.org/incident/2246372) and no news of police shot on 2022-03-18 can be found online;
12. GVA recorded [one officer shot and injured](https://www.gunviolencearchive.org/incident/1171913) in Washington DC on 2018-07-25. This police [was injured but not shot](https://www.wusa9.com/article/news/local/dc/suspect-injured-in-police-involved-shooting-in-dc/65-577500936);
13. GVA recorded [one officer injured](https://www.gunviolencearchive.org/incident/2281841) in Baltimore MD on 2022-04-16. This police [was injured but not shot](https://www.baltimoresun.com/2022/04/17/baltimore-police-officer-injured-saturday-night-outside-power-plant-live-after-trying-to-break-up-fight/).

It is possible these mistakes could be corrected from GVA's end. So anyone trying to reproduce the result should examine whether these mistakes still persist before running this part of code.

The script used for this step is named **01_clean.R**. The result is saved as *recordsCleaned.csv*


## STEP 2 Sort and identify the analysis subject cities
After making these changes accordingly, we created the set for transport mode information collection in the following steps:
1. Group the data by State and City.Or.County and summarize the total case number for each State-City.Or.County pair;
2. Filter the *recordsCleaned.csv* and only keep the State-City.Or.County pairs that had more than 10 police injured or killed during this period of time;
3. One of the five boroughs of NYC, Staten Island, was dropped. But it does not make sense to exclude it so we manually added it back.

| State                | City.Or.County       | Injury.And.Death |
|:---------------------|:---------------------|:----------------:|
| Alabama              | Birmingham           |        13        |
| Arizona              | Phoenix              |        32        |
| Arizona              | Tucson               |        12        |
| California           | Los Angeles          |        20        |
| Colorado             | Denver               |        13        |
| District of Columbia | Washington           |        20        |
| Florida              | Miami                |        11        |
| Georgia              | Atlanta              |        13        |
| Illinois             | Chicago              |        58        |
| Indiana              | Indianapolis         |        12        |
| Kentucky             | Louisville           |        15        |
| Louisiana            | New Orleans          |        11        |
| Maryland             | Baltimore            |        16        |
| Michigan             | Detroit              |        13        |
| Missouri             | Kansas City          |        15        |
| Missouri             | Saint Louis          |        23        |
| Nevada               | Las Vegas            |        15        |
| New Mexico           | Albuquerque          |        12        |
| New York             | Bronx                |        17        |
| New York             | Brooklyn             |        15        |
| New York             | Corona (Queens)      |        16        |
| New York             | New York (Manhattan) |        10        |
| New York             | Staten Island        |        6         |
| North Carolina       | Charlotte            |        13        |
| Ohio                 | Columbus             |        15        |
| Pennsylvania         | Philadelphia         |        45        |
| Tennessee            | Memphis              |        20        |
| Texas                | Dallas               |        14        |
| Texas                | Houston              |        46        |
| Texas                | San Antonio          |        17        |
| Wisconsin            | Milwaukee            |        17        |

Here, only State-City.Or.County pairs that had more than 10 police injured or killed were kept. This was because when a city had very few police shot in five years, we were not sure whether the number truly reflected a pattern or just a random number. We arbitrarily chose 10 as the threshold for this. All five boroughs of NYC were kept.

The script used for this step is named **02_sort.R**. The result is saved as *recordsFiltered.csv*.

## STEP 3 Collect the transport mode information
Since GVA does not record what transport mode was used to carry each police to ER/hospitals, we copy-pasted the *recordsFiltered.csv* into [this Google Sheets document](https://docs.google.com/spreadsheets/d/1fCjbfK5wkWyoP2V0U5rAVWbhzJjAER9SPFYSm_38IKA/edit?usp=sharing), and then used the following resources to manually record such information. 
- GVA collected some news links for each case on their website which is a good starting point;
- If the news collected by GVA did not disclose the transport mode, we would google the keyword to look for others (especially later reports);
- For each police-engaged case, the police department usually has a media brief. The videos are usually uploaded online for transparency. Sometimes these disclose how injured/killed officers were transported.

All transport mode information was stored in the new Response.Type column. Two extra columns, Detail and News.Source, were also created. 
- For all cases where the transport mode used was identified, we documented the source in the News.Source column. 
- We also marked all suicide cases in the Detail column since these cases are fundamentally different in terms of the response mechanism and were excluded from our analysis.

The Detail column is available upon request.

## STEP 4 Validate
Two other analysts from Dr. Sanghavi's Lab, Jessy Nguyen and Nadia Ghazali, then helped validate the transport mode labeled. Using the [Google Sheets document](https://docs.google.com/spreadsheets/d/1fCjbfK5wkWyoP2V0U5rAVWbhzJjAER9SPFYSm_38IKA/edit?usp=sharing), they examined the News.Source and determined whether the label assigned was appropriate. 

If they didn't agree with the transport mode information assigned, they would mark it. And then we discussed to reach a consensus. If an agreement could not be reached, Dr. Prachi Sanghavi reviewed the case and made the final call.

## STEP 5 Analyze
After adding transport information, we did three more things:
1. Replaced five NYC boroughs with NYC since we would want to analyze them as a whole, which left us 27 cities;
2. Dropped suicide case since these cases' emergency response differs from occupation gunshot scenarios, which left us 544 police shot;
3. Dropped cities where there are more than 30% cases for which we cannot identify the transport mode information, which left us 18 cities and 403 police shot.

Using the 18 cities and 403 police sample, we made one pivot table for our perspective article to demonstrate how police were transported in these cities.

We also used the 544 police sample to make two extra tables for supporting information used in our perspective article or fun:
1. What is the outcome of such transport mode?
2. Is there any time trend?

The script used for this step is named **05_analysis.Rmd**. It would knit out a .pdf file named [*pivottables.pdf*](https://github.com/Cal-Fang/HomeboyDropOff/blob/main/results/analysisResults.pdf).
