# Homeboy Drop Off

## STEP 0 Retrieve needed data from GVA
We would need to download historical records from the [Gun Violence Archive](https://www.gunviolencearchive.org/). For our analysis, we downloaded the following files:
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

This script used the download link generated from the GVA website to download the data sets mentioned above and stored them as the *recordsRaw.Rdata* file. This script works smoothly as of July 10th, 2024. However, since download links can change, become unavailable, or require different methods of access in the future, if researchers trying to reproduce this research are experiencing difficulties running it, I recommend using the links above and manually downloading and reading the files. As long as the files are named in the same fashion as detailed in **00_read.R**, doing so should not affect the following steps.


## STEP 1 Clean and combine raw data files
I first dropped the "Operations" and "Participant.Age.Group" columns from records of 2019-2024. And then I did some time-wise cleaning and case-wise cleaning.
### Time-wise cleaning  
Since we have decided the time window should be from 2018-04-30 to 2024-04-30 for this project, we would need to drop all records prior to this period for the 2018 file and all records post to this period for the 2023 files.

### Reformatting 
GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis, we would need to do some extra cleaning and proofreading for ***2018 records***. The 2018 file have following features:
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

Based on this storing logic, I cleaned the 2018 file into the same format as the other years' records in the following steps:
1. Among rows where either Victims.Killed or Victims.Injured is larger than 1,
   1. Export these rows as a new file with a new column of the address of the incident report webpage;
   2. Open this new file outside R and break each row into multiple rows so that each row would represent one police injured or one police killed with reference to the webpage incident report;
   3. Add more information from the webpage incident report so the result file has 7 columns including "Incident.Date", "State", "City.Or.County", "Address", "Participant.Name", "Outcome", and "Participant.Gender".
2. Among the rest rows where either Victims.Killed or Victims.Injured is 1, 
   1. Keep the 148 rows where only one of these two columns is 1, as each of these rows marked exactly one police injured or killed;
   2. Keep the row of [incident 1172042](https://www.gunviolencearchive.org/incident/1172042) since both injured and killed victims were police;
   3. Assign 0 to Victims.Killed to the row of [incident 1185588](https://www.gunviolencearchive.org/incident/1185588) since the killed victim is not police;
   4. Transform this file from wide to long and drop unuseful columns so that it would have 5 columns including "Incident.Date", "State", "City.Or.County", "Address", and "Outcome";
   5. Add two NA columns "Participant.Name" and "Participant.Gender".
3. Combine the two data.table and obtain a reformated cleaned 2018 record file.

### Combining 
After cleaning the 2018 files, all years' records were row-bound together to create the general file. 

### Case-specific cleaning
There are several changes needed to be made in specific cases. Although in my actual analysis, these were found in a later step, to ensure the accuracy of sorting and filtering, it makes more sense for anyone trying to reproduce the result to change these first;:
1. GVA recorded [a police shot and injured](https://www.gunviolencearchive.org/incident/2342312) in New Orleans, LA because the suspect was arrested in New Orleans. However, the injured police was shot in Erin, TN, and is a part of the Erin police department;
2. GVA recorded [three police shot and injured](https://www.gunviolencearchive.org/incident/2094830) for the 2021-08-19 Albuquerque NM case. However, there were actually four police shot and injured. One extra row for Officer Harry Gunderson needs to be added;
3. GVA recorded [one police shot and injured](https://www.gunviolencearchive.org/incident/2170769) in Atlanta GA on 2021-11-19. This police was actually shot and injured at Sandy Springs. He also works for the Sandy Springs Police Department. This case should be altered;
4. GVA recorded [three marshals shot and injured](https://www.gunviolencearchive.org/incident/1868904) in Bronx NYC on 2020-12-04. This was early misinformation. There were only two marshals injured according to later news;
5. GVA did not record any case for 2021-03-15 in Chicago, but there actually was [an off-duty police shot and injured](https://abc7chicago.com/chicago-shooting-police-office-shot-injured-cpd-cop/10419984/) that day in South Chicago;
6. GVA did not record any case for 2021-12-16 in Corona (Queens) NYC, but there actually was [an off-duty police shot and injured](https://sunnysidepost.com/off-duty-cop-shot-robbery-suspect-killed-in-wild-shootout-outside-woodside-nightclub) that day at 56-15 Northern Blvd;
7. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/1314289) in Houston on 2019-01-28. There were actually [five officers shot and injured](https://www.fox26houston.com/news/sergeant-who-sustained-knee-injury-during-shooting-released-from-hospital);
8. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/1723067) in Kansas City, MI at 2020-07-02. There was actually only [one male officer shot and injured](https://fox4kc.com/news/missouri-highway-patrol-responding-to-kansas-city-officer-involved-shooting/). The other injured person is a Kansas City Bus driver and should not be included here;
9. GVA did not record any case for 2022-08-11 in Las Vegas NV but there actually was [three officer injured](https://www.youtube.com/watch?v=c075Xx138Uc&ab_channel=LasVegasMetropolitanPolice) in a shoutout that day;
10. GVA did not record any case for 2022-10-13 in New Orleans	LA but there actually was [an off-duty police shot and injured](https://www.nola.com/news/crime_police/article_ca714662-4bf4-11ed-a467-4b49e4d22e1d.html) that day at 300 block of N Rendon St;
11. GVA recorded [two officers shot and injured](https://www.gunviolencearchive.org/incident/2077587) in Pittsburgh on 2021-07-29. One of them suffered from a minor injury [not related to gunfire](https://www.pennlive.com/news/2021/07/pa-man-killed-parents-shot-at-police-died-in-crash-reports.html).

It is possible these mistakes could be corrected from GVA's end. So anyone trying to reproduce the result should examine whether these mistakes still persist before running this part of code.

The script used for this step is named **01_clean.R**. The result is saved as *recordsCleaned.csv*


## STEP 2 Sort and identify the analysis subject cities
After making these changes accordingly, I created the set for transport mode information collection in the following steps:
1. Group the data by State and City.Or.County and summarize the total case number for each State-City.Or.County pair;
2. Filter the *recordsCleaned.csv* and only keep the State-City.Or.County pairs that had more than 10 police injured or killed during this period of time;
3. One of the five boroughs of NYC, Staten Island, was dropped. But it does not make sense to exclude it so I manually added it back.

| State                | City.Or.County       | Injury.And.Death |
|:---------------------|:---------------------|:----------------:|
| Alabama              | Birmingham           |        13        |
| Arizona              | Phoenix              |        34        |
| Arizona              | Tucson               |        12        |
| California           | Los Angeles          |        20        |
| Colorado             | Denver               |        13        |
| District of Columbia | Washington           |        21        |
| Florida              | Miami                |        11        |
| Georgia              | Atlanta              |        13        |
| Illinois             | Chicago              |        62        |
| Indiana              | Indianapolis         |        12        |
| Kentucky             | Louisville           |        15        |
| Louisiana            | New Orleans          |        12        |
| Maryland             | Baltimore            |        17        |
| Michigan             | Detroit              |        13        |
| Missouri             | Kansas City          |        15        |
| Missouri             | Saint Louis          |        23        |
| Nevada               | Las Vegas            |        18        |
| New Mexico           | Albuquerque          |        12        |
| New York             | Bronx                |        17        |
| New York             | Brooklyn             |        15        |
| New York             | Corona (Queens)      |        17        |
| New York             | New York (Manhattan) |        10        |
| New York             | Staten Island        |        6         |
| North Carolina       | Charlotte            |        13        |
| Ohio                 | Columbus             |        15        |
| Pennsylvania         | Philadelphia         |        45        |
| Tennessee            | Memphis              |        21        |
| Texas                | Dallas               |        14        |
| Texas                | Houston              |        46        |
| Texas                | San Antonio          |        16        |
| Wisconsin            | Milwaukee            |        17        |

Here, only State-City.Or.County pairs that had more than 10 police injured or killed were kept for two concerns: 1) when a city had very little police shot in five years, we are not so sure whether the number is truly showing a pattern or just a random number. We arbitrarily used 10 as the threshold for this; 2) More importantly, it consumes a lot of time to do the media search and there were in total around 2000 police shot through these five years. This project has only one analyst and it is simply not realistic to collect transport mode information for all cases. The only exception is Staten Island as it is one of the five boroughs of NYC and should be considered along with the rest four.

The script used for this step is named **02_sort.R**. The result is saved as *recordsFiltered.csv*.

## STEP 3 Collect the transport mode information
Since GVA does not record what transport mode was used to carry each police to ER/hospitals, I copy-pasted the *recordsFiltered.csv* into [this Google Sheets document](https://docs.google.com/spreadsheets/d/1w_BaFUAuatmUQBt3qtRBzhm9tTDV4B9lRjTGTq79bAg/edit?usp=sharing), and then used following resources to manually record such information. 
- GVA collected some news links for each case on their website which is a good starting point;
- If the news collected by GVA did not disclose the transport mode, I would google the keyword to look for others (especially later reports);
- For each police-engaged case, the police department usually would have a media brief. The videos are usually uploaded online for transparency. Sometimes Chiefs would disclose how injured/killed officers were transported.

All transport mode information was stored in the new Response.Type column. Two extra columns, "Detail" and "News.Source", were also created. 
- For all cases where the transport mode used was identified, I documented the source in the "News.Source" column. 
- I also marked all suicide cases in the "Detail" column since these cases are fundamentally different in terms of the response mechanism and should be excluded from our analysis.


# STEP 4 Analysis
After adding transport information, I did three more things:
1. Replaced five NYC boroughs with NYC since we would want to analyze them as a whole;
2. Dropped suicide case since these cases' emergency response differs from occupation gunshot scenarios;
3. Dropped cities where there are more than 30% cases for which we cannot identify the transport mode information.

This left us with 382 cases. Using these cases, I made some pivot tables trying to answer two descriptive questions:
1. How were police transported in these cities?
2. Is there any trend through time?

The script used for this step is named **04_analysis.Rmd**. It would knit out a .pdf file named [*pivottables.pdf*](https://github.com/Cal-Fang/homeboydropoff/blob/main/pivottables.pdf).
