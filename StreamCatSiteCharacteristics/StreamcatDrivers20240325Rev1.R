#Pull out site characteristics from StreamCat
#Using Streamcat database for lithology, climate, and maybe some land use data for each site
#May also use streamstats for land use
#3/25/2024
#Sydney Shelton

Sys.setlocale("LC_ALL", "C")

#Call in libraries
library(tidyverse)
library(nhdplusTools)
library(StreamCatTools) 
#note, StreamCatTools isn't on CRAN - install with directions here: https://github.com/USEPA/StreamCatTools/

#Read in a csv with your site coordinates. This csv should have 4 columns -
#Site Abbreviation, Full name, Lat, Long
#You need to input the State for streamstats - this column should have the State's 2 letter abbreviation. All of DC is included in MD
sitelatlong <- read.csv("SheltonSitesLatLong.csv")
#Make sure lat/long are numeric
sitelatlong$Lat <- as.numeric(sitelatlong$Lat)
sitelatlong$Long <- as.numeric(sitelatlong$Long)

#Make empty dataframe for site characteristic data
catsitecharacteristics <- data.frame()
statsitecharacteristics <- data.frame()

#Make a for loop to pull in land use data for each site
for(i in unique(sitelatlong$SiteAbbreviation)){
  print(i)
  #filter latlong to one site
  onelatlong <- filter(sitelatlong, SiteAbbreviation == i)
  
  #For each site, first, we need to find the comid
  #Read the latitude/longitude
  lat <- onelatlong$Lat
  long <- onelatlong$Long
  #Create a point
  point <- sf::st_sfc(sf::st_point(c(long,lat)), crs = 4326)
  #Then get comid
  comid <- discover_nhdplus_id(point)
  
  #Then, we need to call in the data - aoi = watershed since we want the results for the entire watershed
  #See streamcat_variable_info_sortedforuse.xlsx to see a description of each tag
  #This comid data should work for lithology/climate since it won't vary much for sites in different parts of the same comid
  onecharacteristic <- sc_get_data(metric = 'BFI,CanalDens,Elev,NPDESDens,TRIDens,SuperfundDens,
                    PctAlkIntruVol,PctWater,PctSilicic,PctSalLake,PctNonCarbResid,
                    PctHydric,PctGlacTilLoam,PctGlacTilCrs,PctGlacTilClay,PctGlacLakeFine,
                    PctGlacLakeCrs,PctExtruVol,PctEolFine,PctEolCrs,PctColluvSed,
                    PctCoastCrs,PctCarbResid,PctAlluvCoast,PctBl2019,PctWdWet2019,
                    PctUrbOp2019,PctUrbMd2019,PctUrbLo2019,PctUrbHi2019,PctShrb2019,
                    PctOw2019,PctMxFst2019,PctIce2019,PctHbWet2019,PctHay2019,PctGrs2019,
                    PctDecid2019,PctCrop2019,PctConif2019,Precip8110,RdDens,RdCrs,Runoff,
                    HUDen2010,PopDen2010,PctImp2019,PctImp2019', comid = comid, aoi = 'watershed')
  #To data, add columns with lat/long/site
  onecharacteristic$Site <- i
  onecharacteristic$Lat <- lat
  onecharacteristic$Long <- long
  #And add that site to the list for the whole dataset
  catsitecharacteristics <- rbind(catsitecharacteristics,onecharacteristic)
}

write.csv(catsitecharacteristics, "SheltonStreamCatSiteCharacteristics.csv")

#There is also potential to download some of this data from USGS streamstats - where it delineates a watershed from a specific point,
#rather than by COMID, which is a chunk between tributaries. I figured out how to install it, but more work is needed to 
#make this work with a list of lat/longs.
#Installing the streamstats package: https://github.com/markwh/streamstats?tab=readme-ov-file
#Need to install archived packages: maptools & rgdal
#To do this, download a version of them (in Github folder)
#Then, install a version of Rtools that is compatible with you version of R: https://cran.r-project.org/bin/windows/Rtools/
#Then, in R Studio click - Packages -> Install -> Install from: Package Archive File -> select the package -> install
#Then, actually install the package:
#devtools::install_github("markwh/streamstats")
#library(streamstats)

#Or with Macrosheds: https://github.com/MacroSHEDS/macrosheds