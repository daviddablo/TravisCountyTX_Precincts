install.packages("data.table")
library(data.table)
library(tidyverse)

#load in data
tctx1 <- fread("G20CVR-0.csv")
tctx2 <- fread("G20CVR-1.csv")
tctx3 <- fread("G20CVR-2.csv")
tctx4 <- fread("G20CVR-3.csv")
tctx5 <- fread("G20CVR-4.csv")
tctx6 <- fread("G20CVR-5.csv")
tctx7 <- fread("G20CVR-6.csv")

#create large list using data
l = list(tctx1,tctx2,tctx3,tctx4,tctx5,tctx6,tctx7)
#bind data into one table
primarytctx <- rbindlist(l,TRUE)

#clear start imports
rm(tctx1)
rm(tctx2)
rm(tctx3)
rm(tctx4)
rm(tctx5)
rm(tctx6)
rm(tctx7)
rm(l)

#get column names
#only pick CVR number, precinct code, and president
colnames(primarytctx)

#select important data
presidentialonly <- select(primarytctx,"Cast Vote Record","Precinct","President/Vice President")

#fix column names...
colnames(presidentialonly)[1] = Cast.Vote.Record
colnames(presidentialonly)[3] = President.Vice.President

#only choose vote records that chose Biden or Trump
bidentrumponly <- presidentialonly %>% 
  filter(President.Vice.President=="DEM Joseph R. Biden" | President.Vice.President=="REP Donald J. Trump")

#replace variables with 0 and 1
bidentrumponly$President.Vice.President[bidentrumponly$President.Vice.President == "DEM Joseph R. Biden"] <- 1
bidentrumponly$President.Vice.President[bidentrumponly$President.Vice.President == "REP Donald J. Trump"] <- 0

#fix asnumeric
bidentrumponly$President.Vice.President <- as.numeric(bidentrumponly$President.Vice.President)

#test numeric -> 72.98% Biden in the district
mean(bidentrumponly$President.Vice.President)

#group by precinct and voter choice, then count each observation
bidentrumpfinal <- bidentrumponly %>%
  group_by(Precinct, President.Vice.President) %>%
  summarise(count = n())

#export data as csv
write.csv(bidentrumpfinal,"TravisCountyTX_Precincts.csv")