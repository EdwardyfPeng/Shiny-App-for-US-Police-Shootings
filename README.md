# Shiny-App-for-US-Police-Shootings
Homework 2 of STAT436 for 2025 Spring in UW-Madison

## Introduction

Michael Brown, an unarmed Black man, was killed in 2014 by police in Ferguson, Mo., which increased nationwide focus on police accountability. Since a subsequent investigation by Post found that data reported to the FBI on fatal police shootings was undercounted by more than half, the Washington Post began in 2015 to log every person shot and killed by an on-duty police officer in the US.

A shiny app has been developed to display the shooting information based on the data recorded by the Washington Post. It has already been hosted online (https://edwardpeng.shinyapps.io/homework2/). 

The dataset I used contains the detailed information of police shooting cases in the US from 2015 to 2022, which can be found in Kaggle. This dataset includes 5016 incidents in total (I removed incidents from AK and HI) and 19 columns after data preprocessing, capturing key details such as the location, date, and circumstances of each shooting, as well as demographic information about the individuals involved.

## Questions of Interest

- What are the geographic, gender, and racial distributions of police shooting incidents?

- Are there any changes in proportion of races in these cases across different years and different states?

- Does racial bias exist in police shootings? Specifically, were certain racial groups disproportionately shot, even when they were unarmed?

## Interface
<img width="723" alt="Interface" src="https://github.com/user-attachments/assets/1b28b4fa-5ba8-48d9-889f-d5874ef9034f" />

## Findings

- From the map scatter plot, the majority of those shot were male and White (Maybe because the
proportion of White in US population is also large). The states with the highest number of incidents
were California, Texas, and Florida from 2015 to 2022.

- When I brush over the map, I can find that in Western America, a significant proportion of those
shot were Hispanic (approximately 37%). In Eastern America, the majority of victims were Black
(about 38%) and White (about 53%). In Middle America, the figures shifted, with White individuals
comprising 58% of those shot, while Black individuals accounted for 31%.

- From 2015 to 2022, there was an increase in the proportion of Black shot, from about 25% to 33%,
while the proportion of White individuals fluctuated around 50% over the same period.

- In general, the Black and Hispanic were more likely to be shot, although they were unarmed. In
particular, this issue was more severe in California but less severe in the middle and Eastern region of
America. This is kind of beyond my expectation because California is often perceived as a progressive
state. Moreover, this issue continued to exist throughout 2015 to 2022 in California.

## References

[1] https://www.washingtonpost.com/graphics/investigations/police-shootings-database/

[2] https://github.com/washingtonpost/data-police-shootings

[3] Thomas MD, Jewell NP, Allen AM. Black and unarmed: statistical interaction between age, perceived
mental illness, and geographic region among males fatally shot by police using case-only design. Ann
Epidemiol. 2021 Jan;53:42-49.e3. doi: 10.1016/j.annepidem.2020.08.014.
