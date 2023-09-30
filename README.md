# homeboydropoff

## STEP 0 Retrieve needed data from GVA
We would need to download historical records from the [Gun Violence Archive](https://www.gunviolencearchive.org/). For our analysis, we downloaded the following files:
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

## STEP 1 Clean and combine raw data files
I at first dropped the "Operations" and "Participant.Age.Group" columns from records of 2019-2023. And then I did some time-wise cleaning and case-wise cleaning.
### Time-wise cleaning  
Since we have decided the time window should be from 2018-04-30 to 2023-04-30 for this project, we would need to drop all records prior to this period for the 2018 file and all records post to this period for the 2023 files.

### Case-wise cleaning  
GVA data is stored in another format for all records prior to 2019-01-01. So for our analysis, we would need to do some extra cleaning and proofreading for ***2018 records***. The 2018 file has following features:
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
After cleaning the 2018 files, all years' records were row-bound together to create the cleaned file. It was saved as *All_2018_2023.csv*. 

The script used for this step is named **01_clean.R**. 


## STEP 2 Sort and identify the analysis subject cities
Before sorting and filtering, there are two changes needed to be made:
1. GVA recorded [a police shot and injured](https://www.gunviolencearchive.org/incident/2342312) in New Orleans, LA because the suspect was arrested in New Orleans. However, the injured police was shot in Erin, TN, and is a part of the Erin police department. Although this was found in a later step in my actual analysis, I rewrote the original script to move this step here to ensure the accuracy of sorting and filtering;
2. GVA recorded [three police shot and injured](https://www.gunviolencearchive.org/incident/2094830) for the 2021-08-19 Albuquerque NM case. However, there were actually four police shot and injured.

After making changes to these two cases, I created the set for transport mode information collection in the following steps:
1. Group the data by State and City.Or.County and summarize the total case number for each State-City.Or.County pair;
2. Filter the *All_2018_2023.csv* and only keep the State-City.Or.County pairs that had more than 10 police injured or killed during this period of time;
3. One of the five boroughs of NYC, Staten Island, was dropped. But it does not make sense to exclude it so I manually added it back.

This process gave me the records that I needed to manually collect the transport mode information. It is saved as *Above10_2018_2023.csv*.

|State               | City.Or.County      | Injury.And.Death |
|--------------------|---------------------|:----------------:|
|Alabama             | Birmingham          |        13        |
|Arizona             | Phoenix             |        28        |
|California          | Los Angeles         |        17        |
|Colorado            | Denver              |        10        |
|District of Columbia| Washington          |        14        |
|Georgia             | Atlanta             |        14        |
|Illinois            | Chicago             |        53        |
|Indiana             | Indianapolis        |        10        |
|Kentucky            | Louisville          |        12        |
|Louisiana           | New Orleans         |        12        |
|Maryland            | Baltimore           |        17        |
|Michigan            | Detroit             |        11        |
|Missouri            | Kansas City         |        15        |
|Missouri            | Saint Louis         |        22        |
|Nevada              | Las Vegas           |        12        |
|New Mexico          | Albuquerque         |        10        |
|New York            | Bronx               |        17        |
|New York            | Brooklyn            |        13        |
|New York            | Corona (Queens)     |        13        |
|New York            | New York (Manhattan)|        10        |
|New York            | Staten Island       |        6         |
|Ohio                | Columbus            |        13        |
|Pennsylvania        | Philadelphia        |        33        |
|Pennsylvania        | Pittsburgh          |        10        |
|Tennessee           | Memphis             |        15        |
|Texas               | Dallas              |        10        |
|Texas               | Houston             |        38        |
|Texas               | San Antonio         |        10        |
|Wisconsin           | Milwaukee           |        16        |

The script used for this step is named **02_sort.R**. 















