#Make Bay Dataset downloaded from website in wide format
#Each parameter should be a column
#Download from here:https://datahub.chesapeakebay.net/WaterQuality
#6/29/2023
#SS and DD
#Updated 12/28/2023 by SS
#Measurements with duplicates from different methods are averaged

#Call in the library with pivot_wider
library(tidyr)

#Read in the data from the csv. Make sure your working directory points to the 
#folder your csv is saved in, and the title matches the one written below
data <- read.csv("WaterQualityWaterQualityStation.csv")

#Select the important columns, and drop the ones we don't need
data <- subset(data, select = c(MonitoringStation, Latitude, Longitude, SampleDate, SampleTime, Parameter, MeasureValue, Unit))

#Make one column with parameter name and unit
data$parameterunit <- paste(data$Parameter, data$Unit)

#Remove the separate parameter and measure value columns
data <- subset(data, select = c(-Parameter, -Unit))

#Make the table into a wide format, where each parameter is its own column
#The "values_fn = mean" portion of this function averages the duplicate points
data_wide <- pivot_wider(data, names_from = parameterunit, values_from = MeasureValue, values_fn = mean)

#Now we have the data in a wide format

