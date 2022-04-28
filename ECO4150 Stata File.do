//Working Directory 
cd "/Users/ashnaareeb/Desktop/ECO4150"


//SETUP
//Import the Excel File
import excel "/Users/ashnaareeb/Desktop/ECO4150/Books of the Bible - NT.xlsx", sheet("Panel Data") firstrow


//Convert state to numeric
rename State BState
label var BState "State as String"
encode BState, gen(State)
label var State "State as Numeric"

//Convert Region to numeric 
encode Region, gen(NRegion)

//Convert Month to numeric 
encode Month, gen(Months)

//https://www.pewresearch.org/fact-tank/2016/02/29/how-religious-is-your-state/?state=alabama
//Creating a prayer score dummy - % of people who say they pray daily 
gen Prayer = 0  
replace Prayer = 1 if PrayerScore > 0.33
replace Prayer =2 if PrayerScore > 0.6
label var Prayer "% of adults that pray daily"

//Creating a Religious Score dummy - % of people who say religion is important to their lives
gen Religion = 0 
replace Religion =1 if 0.33 < ReligiousImportance 
replace Religion =2 if ReligiousImportance > 0.66
label var Religion "% of people who say religion is important to them"

//NATIONAL LOCKDOWN VARIABLE DUMMY
gen Lockdown = 0 
replace Lockdown =1 if Date >= td(01mar2020)
label var Lockdown "Lockdown Start Date"

//GENERATING BIBLE BELT VARIABLE 
gen Belt = 0
replace Belt = 1 if (State ==1 | State ==4 | State == 8 | State == 48 | State == 10 | State==11 | State == 18 | State==19 | State==21| State ==25 | State==26 | State == 34 | State == 37 | State == 41 | State== 43 | State ==44 | State==47 | State==49)
label var Belt "Bible Belt States"



// ---------------------------------NEW TESTAMENT ANALYSIS ---------------------------
//DIFF INDIFF ANALYSIS FOR STATE LEVEL DATA 


//METHOD 1 - State of Emergency Dummy POST (March or April or Control)
//Based on https://www.nashp.org/2020-state-reopening-chart/
//Indicating time when the treatment started 

gen epost = 0
label var epost "State of Emergency (Time After Treatment)"
replace epost=1 if inlist(BState, "Alabama", "Alaska", "District of Columbia", "Florida", "Georgia", "Maine", "Missouri", "Nevada", "South Carolina") & Date >= td(01apr2020)
replace epost = 1 if inlist(BState, "Arizona", "California", "Colarado", "Connecticut", "Delaware", "Hawaii", "Idaho", "Illinois", "Indiana") & Date >= td(01mar2020)
replace epost=1 if inlist(BState, "Kansas", "Kentucky","New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "Ohio", "Oklahoma") & Date >= td(01mar2020)
replace epost =1 if inlist(BState, "Oregon", "Pennyslvania", "Rhode Island","Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington") & Date >= td(01mar2020)
replace epost=1 if inlist(BState, "West Virginia", "Wisconsin", "Louisiana", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Montana") & Date >=td(01mar2020)

//Countries where treatment is applied - did not use as we used a different Stata code 
//gen postt = 0 
//label var postt "States that had emergency order"
//replace postt = 1 if inlist(BState, "Alabama", "Alaska", "District of Columbia", "Florida", "Georgia", "Maine", "Missouri", "Nevada", "South Carolina")
//replace postt = 1 if inlist(BState,"Arizona", "California", "Colarado", "Connecticut", "Delaware", "Hawaii", "Idaho", "Illinois", "Indiana" )
//replace postt =1 if inlist(BState,"Kansas", "Kentucky","New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "Ohio", "Oklahoma" )
//replace postt=1 if inlist(BState, "Oregon", "Pennyslvania", "Rhode Island","Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington")
//replace postt=1 if inlist("West Virginia", "Wisconsin", "Louisiana", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Montana")

// METHOD 2 - Travel Restrictions Dummy
gen travelpost = 0 
label var travelpost "Travel Restrictions Imposed (Time After Treatment)"
replace travelpost =1 if inlist(BState, "Alaska", "California", "Connecticut", "Hawaii", "Kansas", "Kentucky", "Maryland", "Massachusetts", "New Hampshire") & Date>= td(01mar2020)
replace travelpost =1 if inlist(BState, "New Jersey", "New Mexico", "New York", "Ohio", "Oregon", "Pennyslvania", "Rhode Island") & Date>= td(01mar2020)
replace travelpost =1 if inlist(BState, "Vermont", "Washington", "Wisconsin") & Date >=td(01mar2020)
replace travelpost =1 if inlist(BState, "District of Columbia", "Maine") & Date >= td(01apr2020)

//States where the travel restrictions were initated - did not use as we used a different Stata code 
//gen travel = 0
//label var travel "States that had travel restrictions"
//replace travel =1 if inlist(BState, "Alaska", "California", "Connecticut", "Hawaii", "Kansas", "Kentucky", "Maryland", "Massachusetts", "New Hampshire") 
//replace travel =1 if inlist(BState, "New Jersey", "New Mexico", "New York", "Ohio", "Oregon", "Pennyslvania", "Rhode Island") 
//replace travel =1 if inlist(BState, "Vermont", "Washington", "Wisconsin")
//replace travel =1 if inlist(BState, "District of Columbia", "Maine")

//Robustness test Dummy 
gen repost = 0
label var repost "State of Emergency (Time After Treatment)"
replace repost=1 if inlist(BState, "Alabama", "Alaska", "District of Columbia", "Florida", "Georgia", "Maine", "Missouri", "Nevada", "South Carolina") & Date >= td(01apr2009)
replace repost = 1 if inlist(BState, "Arizona", "California", "Colarado", "Connecticut", "Delaware", "Hawaii", "Idaho", "Illinois", "Indiana") & Date >= td(01mar2009)
replace repost=1 if inlist(BState, "Kansas", "Kentucky","New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "Ohio", "Oklahoma") & Date >= td(01mar2009)
replace repost =1 if inlist(BState, "Oregon", "Pennyslvania", "Rhode Island","Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington") & Date >= td(01mar2009)
replace repost=1 if inlist(BState, "West Virginia", "Wisconsin", "Louisiana", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Montana") & Date >=td(01mar2009)


//Summary Stats - TABLE 1
eststo clear 
eststo: estpost sum BookofRevelation PrayerScore ReligiousImportance Belt State NRegion Date Months Year Lockdown epost travelpost 
esttab using sumstats.tex, cells("mean sd min max")

//Save as dta file 
save "/Users/ashnaareeb/Desktop/ECO4150/ECO4150BoR.dta", replace







//-------------------------------------- ANALYSIS - SETUP -------------------------------------------

//Setting up Stata to handle the appropriate panel data
xtset State Date

//Looking at the trend for the states
xtline BookofRevelation, tline(1mar2020)

//Looking at a few states in particular (highest populations) - FIGURE 2
//California, Texas, Florida, New York
xtline BookofRevelation if State==5 | State==44 | State ==10 | State ==33, tline(1mar2020)


//--------------------------------------- ANALYSIS - PRE-POST -------------------------------------- 
//Simple OLS; regressing Book of Revelation on Lockdown Dummy
//Y_it = BX_it + a_i + e_it

//TABLE 4 
eststo clear
xtreg BookofRevelation Lockdown,fe
eststo B1
reg BookofRevelation Lockdown Belt Prayer Religion i.State
eststo B2
reg BookofRevelation Lockdown Belt Prayer Religion i.Months i.State
eststo B3
reg BookofRevelation Lockdown Belt Prayer Religion i.Year i.State
eststo B4
reg Bookof Lockdown Belt Prayer Religion i.Year i.Months i.State
eststo B5
esttab B1 B2 B3 B4 B5 using firstreg.tex, replace se noobs notes label title(Initial Pre-post Analysis \label{tab1})

//TABLE 5
//interaction effects between prayer and religion and lockdown 
eststo clear
reg  BookofRevelation Lockdown Belt Prayer Religion i.NRegion Belt#Lockdown Prayer#Lockdown Religion#Lockdown i.State
eststo i4
reg Bookof Lockdown Belt Prayer Religion i.NRegion Belt#Lockdown Prayer#Lockdown Religion#Lockdown i.Months i.State
eststo i5

esttab i4 i5 using interactions1.tex, replace se notes wide label title(Reduced Model Versions: Testing Book of Revelation Searches with Interaction Effects between Lockdown and Other Covariates \label{tab1})



//--------------------------------------- Robustness Check ----------------------------------------
//Generate fake lockdown period to perform a Robustness Check using a different date

//TABLE 7
gen RobustLockdown = 0 
replace RobustLockdown = 1 if Date >= td(01mar2006)

xtreg BookofRevelation RobustLockdown,fe
eststo r1
reg BookofRevelation RobustLockdown Belt Prayer Religion i.NRegion i.State
eststo r2
reg BookofRevelation RobustLockdown Belt Prayer Religion i.Year i.State
eststo r4
reg Bookof RobustLockdown Belt Prayer Religion i.NRegion i.Months i.State
eststo r5 
reg  BookofRevelation RobustLockdown Belt Prayer Religion i.NRegion Belt#RobustLockdown Prayer#RobustLockdown Religion#RobustLockdown i.Months i.State
eststo r6 

esttab r5 r6 using robustness.tex, replace se noobs wide notes label title(First Approach: Estimation using Fake Lockdown Periods\label{tab1})

//TABLE 8
gen RobustLockdown3 = 0 
replace RobustLockdown3 = 1 if Date >= td(01mar2021)

xtreg BookofRevelation RobustLockdown3,fe
eststo r12
reg BookofRevelation RobustLockdown3 Belt Prayer Religion i.NRegion i.State
eststo r13
reg BookofRevelation RobustLockdown3 Belt Prayer Religion i.Months i.State
eststo r14
reg Bookof RobustLockdown3 Belt Prayer Religion i.NRegion i.Months i.State
eststo r15
reg  BookofRevelation RobustLockdown3 Belt Prayer Religion i.NRegion Belt#RobustLockdown3 Prayer#RobustLockdown3 Religion#RobustLockdown3 i.Months i.State
eststo r16

esttab r15 r16 using robustness2.tex, replace se wide noobs notes label title(First Approach: Estimation using Fake Lockdown Periods\label{tab1})


//CHECKING OTHER BOOKS - Not included in my paper (would recommend for further analysis)
xi: reg GospelofMark Lockdown
xi: reg ActsoftheApostles Lockdown
xi: reg EpistletotheRomans Lockdown
xi: reg FirstEpistletotheCorinthians Lockdown 
xi: reg SecondEpistletotheCorinthian Lockdown //significant 
xi: reg EpistletotheGalatians Lockdown
xi: reg EpistletotheEphesians Lockdown //significant
xi: reg EpistletothePhilippians Lockdown 
xi: reg FirstEpistletotheThessalonia Lockdown //significant
xi: reg EpistletotheColossians Lockdown //significant
xi: reg SecondEpistletotheThessaloni Lockdown //significant
xi: reg PremiÃrelettreÃTimothÃe Lockdown //significant 
xi: reg SecondEpistletoTimothy Lockdown //significant
xi: reg EpistletoTitus Lockdown 
xi: reg EpistletoPhilemon Lockdown 
xi: reg EpistletotheHebrews Lockdown 
xi: reg EpistleofJames Lockdown //significant 
xi: reg FirstEpistleofPeter Lockdown //significant
xi: reg SecondEpistleofPeter Lockdown //significant 
xi: reg FirstEpistleofJohn Lockdown //significant 
xi: reg SecondEpistleofJohn Lockdown //significant 
xi: reg ThirdEpistleofJohn Lockdown //significant 
xi: reg EpistleofJude Lockdown

xi: reg BookofRevelation Lockdown GospelofMark ActsoftheApostles EpistletotheRomans FirstEpistletotheCorinthians SecondEpistletotheCorinthian EpistletotheGalatians EpistletotheEphesians EpistletothePhilippians EpistletotheColossians FirstEpistletotheThessalonia SecondEpistletotheThessaloni PremiÃrelettreÃTimothÃe SecondEpistletoTimothy EpistletoTitus EpistletoPhilemon EpistletotheHebrews EpistleofJames FirstEpistleofPeter SecondEpistleofPeter FirstEpistleofJohn SecondEpistleofJohn ThirdEpistleofJohn EpistleofJude








//-----------------------------ANALYSIS- DIFF-INDIFF USING STATE LEVEL DATA--------------------------
//Setting up Stata to handle the appropriate panel data
xtset State Date

//Using emergency order day by state (March, April, or none) on state-level data

//TABLE 9
eststo clear
xtdidregress (BookofRevelation) (epost), group(State) time(Date) nogteffects //No time effects 
eststo did1
xtdidregress (BookofRevelation) (epost), group(State) time(Date) //including group and time effects 
eststo did2

//Using emergency travel restriction order by state (March, April, or none) on state-level data 
//TABLE 9 CONTINUED
xtdidregress (BookofRevelation) (travelpost), group(State) time(Date) nogteffects //No time effects 
eststo did3
xtdidregress (BookofRevelation) (travelpost), group(State) time(Date)
eststo did4

esttab did1 did2 did3 did4 using firstapproachdiff.tex, replace se noobs notes label title(First Approach: State Emergency Declarations on Book of Revelation Searches\label{tab1})











//-------------------------ANALYSIS - DIFF INDIFF USING METRO LEVEL DATA ------------------------

//IMPORT METRO LEVEL DATA
clear
import excel "/Users/ashnaareeb/Desktop/ECO4150/Metro Level Data.xlsx", sheet("Metro Level") firstrow

//Create national lockdown variable again 
gen Lockdown = 0 
replace Lockdown =1 if Date >= td(01mar2020)
label var Lockdown "Lockdown Start Date"

//Changing month to numeric 
encode Month, gen(Months)
encode Metro, gen(Metroarea)

//Dropping missing data 
drop if Metroarea ==.

//Set panel data to metro 
xtset Metroarea Date

//Summary Stats - TABLE 2 
eststo clear 
eststo: estpost sum BookofRevelation Metroarea Lockdown CountyEmergencyDate Date Months 
esttab using sumstats2.tex, cells("mean sd min max")

//TABLE 6
//Simple OLS; regressing Book of Revelation on Lockdown Dummy
eststo clear 
xtreg BookofRevelation Lockdown, fe
eststo metro1
xtreg BookofRevelation Lockdown i.Months, fe
eststo metro2
xtreg Bookof Lockdown i.Year, fe
eststo metro3 
xtreg Bookof Lockdown i.Months i.Year, fe
eststo metro4
esttab metro1 metro2 metro3 metro4 using secondapproachmetrodiff.tex, replace se noobs notes label title(Second Approach: Metro Emergency Declarations on Book of Revelation Searches\label{tab1})

//Found a representative county for each metro 
//Replace countyemergency date with 0 if missing 
replace CountyEmergencyDate = 0 if missing(CountyEmergencyDate)

//TABLE 10 
//Running a regression using County level emergency dates on each metro area 
xtdidregress (BookofRevelation) (CountyEmergencyDate), group(Metroarea) time(Date) nogteffects //No time effects
eststo metro4 
xtdidregress (BookofRevelation) (CountyEmergencyDate), group(Metroarea) time(Date) //Including time effects
eststo metro5

esttab metro4 metro5 using secondapproachmetrodiff2.tex, replace se noobs notes label title(Second Approach: Metro Emergency Declarations on Book of Revelation Searches\label{tab1})
//Significant results 

//Represenative county to numeric 
encode RepresentativeCounty, gen(County)
keep if RepresentativeCounty != "0" 




//---------------------------- ANALYSIS - PRE-POST USING Canadian Data ------------------------
//Import Canadian Data
clear
import excel "/Users/ashnaareeb/Desktop/ECO4150/Canadian Data.xlsx", sheet("Panel Data") firstrow

//encoding the variables to numeric provinces
rename Province BProvince
label var BProvince "Province as String"
encode BProvince, gen(Province)
label var Province "Province as Numeric"


//setting up panel data
xtset Province Date

//removing observations that are skewed - FIGURE 3
keep if Date>=td(01jan2008)
xtline BookofRevelation if Province==9 | Province==7 | Province == 2|Province ==1, tline(1mar2020) 

//Lockdown dummy
gen Lockdown = 0 
replace Lockdown =1 if Date >= td(01mar2020)
label var Lockdown "Lockdown Start Date"

//Month dummy 
encode Month, gen(Months)

//summary stats - TABLE 3 
eststo clear 
eststo: estpost sum BookofRevelation Province Lockdown ProvincialEmergency Date Year Months 
esttab using sumstats3.tex, cells("mean sd min max") 

//TABLE 11
eststo clear 
xtreg BookofRevelation Lockdown,fe
eststo can 
reg Bookof Lockdown i.Months i.Province
eststo can2
reg Bookof Lockdown i.Year i.Province
eststo can3
esttab can can2 can3 using canadianprepost.tex, replace se noobs notes label title(Canadian Government Policy: National Emergency Declaration (Province Level) \label{tab1})




//Diff indiff - TABLE 12
xtdidregress (BookofRevelation) (ProvincialEmergency), group(Province) time(Date) nogteffects //No time effects in the model 
eststo province1 

xtdidregress (BookofRevelation) (ProvincialEmergency), group(Province) time(Date) //Including time effects
eststo province2

//TABLE 13
gen RobustLockdown = 0 
replace RobustLockdown =1 if Date >= td(01jan2009)
xi: reg BookofRevelation RobustLockdown i.Province 
xi: reg Bookof RobustLockdown i.Province i.Months

gen RobustLockdown2 = 0 
replace RobustLockdown2 =1 if Date >=td(01aug2021)
xi: reg Bookof RobustLockdown2 i.Province
xi: reg Bookof RobustLockdown2 i.Province i.Months

