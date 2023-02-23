//Old Testament Book - Psalms Analysis 

//---------------------------------------------Setup-----------------------------------------------------------
//Working Directory 
cd "/Users/ashnaareeb/Desktop/ECO4150"

//Import the Excel File
clear 
import excel "/Users/ashnaareeb/Desktop/ECO4150/Books of the Bible - OT.xlsx", sheet("Panel Data") firstrow

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

gen logpsalms = log(Psalms)

//Format date variable 
gen monthly_date = mofd(Date)

format monthly_date %tm

//Setting up Stata to handle the appropriate panel data
xtset State monthly_date, monthly

//Testing for unit root 
xtunitroot llc Psalms // No unit root - do not need to difference 

//first difference the Pslams variable 
by State: gen newpsalms = Psalms[_n]- Psalms[_n-1] //



//PRE-POST ANALYSIS 

//Looking at the trend for the states
xtline Psalms, tline(1mar2020)

//Looking at a few states in particular (highest populations) - FIGURE 2
//California, Texas, Florida, New York
xtline Psalms if State==5 | State==44 | State ==10 | State ==33, tline(1mar2020)
xtline newpsalms if State==5 | State==44 | State ==10 | State ==33, tline(1mar2020)


eststo clear
xtreg Psalms Lockdown,fe
eststo B11
reg Psalms Lockdown Belt Prayer Religion i.State
eststo B22
reg Psalms Lockdown Belt Prayer Religion i.Months i.State
eststo B33
reg Psalms Lockdown Belt Prayer Religion i.Year i.State //Maybe not include lol 
eststo B44
reg Psalms Lockdown Belt Prayer Religion i.Year i.Months i.State //Maybe not include lol 
eststo B55
esttab B11 B22 B33 B44 B55 using psalms1.tex, replace se noobs notes label title(Initial Pre-post Analysis (Psalms) \label{tab1})


//interaction effects between prayer and religion and lockdown 
eststo clear
reg  Psalms Lockdown Belt Prayer Religion i.NRegion Belt#Lockdown Prayer#Lockdown Religion#Lockdown i.State
eststo i44
reg Psalms Lockdown Belt Prayer Religion i.NRegion Belt#Lockdown Prayer#Lockdown Religion#Lockdown i.Months i.State
eststo i55

esttab i44 i55 using psalmsinteracts.tex, replace se notes wide label title(Reduced Model Versions: Testing Psalms Searches with Interaction Effects between Lockdown and Other Covariates \label{tab1})



//--------------------------------------- Robustness Check ----------------------------------------
//Generate fake lockdown period to perform a Robustness Check using a different date

gen RobustLockdown = 0 
replace RobustLockdown = 1 if Date >= td(2006m3)

xtreg Psalms RobustLockdown,fe
eststo r1
reg Psalms RobustLockdown Belt Prayer Religion i.NRegion i.State
eststo r2
reg Psalms RobustLockdown Belt Prayer Religion i.Year i.State
eststo r4
reg Psalms RobustLockdown Belt Prayer Religion i.NRegion i.Months i.State
eststo r5 
reg  Psalms RobustLockdown Belt Prayer Religion i.NRegion Belt#RobustLockdown Prayer#RobustLockdown Religion#RobustLockdown i.Months i.State
eststo r6 

esttab r5 r6 using robustness.tex, replace se noobs wide notes label title(First Approach: Estimation using Fake Lockdown Periods\label{tab1})

gen RobustLockdown3 = 0 
replace RobustLockdown3 = 1 if Date >= td(2021m3)

xtreg Psalms RobustLockdown3,fe
eststo r12
reg Psalms RobustLockdown3 Belt Prayer Religion i.NRegion i.State
eststo r13
reg Psalms RobustLockdown3 Belt Prayer Religion i.Months i.State
eststo r14
reg Psalms RobustLockdown3 Belt Prayer Religion i.NRegion i.Months i.State
eststo r15
reg  Psalms RobustLockdown3 Belt Prayer Religion i.NRegion Belt#RobustLockdown3 Prayer#RobustLockdown3 Religion#RobustLockdown3 i.Months i.State
eststo r16

esttab r15 r16 using robustness2.tex, replace se wide noobs notes label title(First Approach: Estimation using Fake Lockdown Periods\label{tab1})

















//DIFF-IN-DIFF - STATE LEVEL 

//METHOD 1 - Emergency Restrictions Dummy 
gen epost = 0
label var epost "State of Emergency (Time After Treatment)"
replace epost=1 if inlist(BState, "Alabama", "Alaska", "District of Columbia", "Florida", "Georgia", "Maine", "Missouri", "Nevada", "South Carolina") & Date >= td(01apr2020)
replace epost = 1 if inlist(BState, "Arizona", "California", "Colarado", "Connecticut", "Delaware", "Hawaii", "Idaho", "Illinois", "Indiana") & Date >= td(01mar2020)
replace epost=1 if inlist(BState, "Kansas", "Kentucky","New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "Ohio", "Oklahoma") & Date >= td(01mar2020)
replace epost =1 if inlist(BState, "Oregon", "Pennyslvania", "Rhode Island","Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington") & Date >= td(01mar2020)
replace epost=1 if inlist(BState, "West Virginia", "Wisconsin", "Louisiana", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Montana") & Date >=td(01mar2020)

// METHOD 2 - Travel Restrictions Dummy
gen travelpost = 0 
label var travelpost "Travel Restrictions Imposed (Time After Treatment)"
replace travelpost =1 if inlist(BState, "Alaska", "California", "Connecticut", "Hawaii", "Kansas", "Kentucky", "Maryland", "Massachusetts", "New Hampshire") & Date>= td(01mar2020)
replace travelpost =1 if inlist(BState, "New Jersey", "New Mexico", "New York", "Ohio", "Oregon", "Pennyslvania", "Rhode Island") & Date>= td(01mar2020)
replace travelpost =1 if inlist(BState, "Vermont", "Washington", "Wisconsin") & Date >=td(01mar2020)
replace travelpost =1 if inlist(BState, "District of Columbia", "Maine") & Date >= td(01apr2020)


//Using emergency order day by state (March, April, or none) on state-level data

//TABLE 9
eststo clear
xtdidregress (Psalms) (epost), group(State) time(monthly_date) nogteffects //No time effects 
eststo did11
xtdidregress (Psalms) (epost), group(State) time(monthly_date) //including group and time effects 
eststo did22

//Using emergency travel restriction order by state (March, April, or none) on state-level data 
//TABLE 9 CONTINUED
xtdidregress (Psalms) (travelpost), group(State) time(monthly_date) nogteffects //No time effects 
eststo did33
xtdidregress (Psalms) (travelpost), group(State) time(monthly_date)
eststo did44

esttab did11 did22 did33 did44 using psalmsstatediffindiff.tex, replace se noobs notes label title(First Approach: State Emergency Declarations on Book of Revelation Searches\label{tab1})








//-------------------------ANALYSIS - DIFF INDIFF USING METRO LEVEL DATA    ------------------------

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

//Format date variable 
gen monthly_date = mofd(Date)

format monthly_date %tm

//Setting up Stata to handle the appropriate panel data
xtset Metroarea monthly_date, monthly

//Simple OLS; regressing Book of Revelation on Lockdown Dummy
eststo clear 
xtreg Psalms Lockdown, fe
eststo metro11
xtreg Psalms Lockdown i.Months, fe
eststo metro22
xtreg Psalms Lockdown i.Year, fe
eststo metro33 
xtreg Psalms Lockdown i.Months i.Year, fe
eststo metro44
esttab metro11 metro22 metro33 metro44 using psalmsmetroprepost.tex, replace se noobs notes label title(Second Approach: Metro Emergency Declarations on Book of Revelation Searches\label{tab1})

//Found a representative county for each metro 
//Replace countyemergency date with 0 if missing 
replace CountyEmergencyDate = 0 if missing(CountyEmergencyDate)

//TABLE 10 
//Running a regression using County level emergency dates on each metro area 
xtdidregress (Psalms) (CountyEmergencyDate), group(Metroarea) time(monthly_date) nogteffects //No time effects
eststo metro44 
xtdidregress (Psalms) (CountyEmergencyDate), group(Metroarea) time(monthly_date) //Including time effects
eststo metro55

esttab metro44 metro55 using psalmsmetrodiffindiff.tex, replace se noobs notes label title(Second Approach: Metro Emergency Declarations on Book of Revelation Searches\label{tab1})
//Significant results 

//Represenative county to numeric 
encode RepresentativeCounty, gen(County)
keep if RepresentativeCounty != "0" 


