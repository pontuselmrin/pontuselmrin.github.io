##By Pontus Elmrin, 2020-01-05

##load packages
library(tidyverse) 
library(zoo)
library(stringi)
library(lubridate)

setwd("~/Desktop/Portfolio Management/replication") #set workspace

linktable <-read_csv("~/Desktop/Portfolio Management/replication/WRDS/linking table.csv") #read linking table
crsp <-read_csv(("~/Desktop/Portfolio Management/replication/WRDS/crsp.csv")) #read CRSP data from 1963-2014
cstat <-read_csv(("~/Desktop/Portfolio Management/replication/WRDS/cstat.csv")) #read merged compustat/CRSP data from 1963-2014
colnames(linktable) <- tolower(colnames(linktable)) #set columns to lowercase
colnames(crsp) <- tolower(colnames(crsp)) #set columns to lowercase
colnames(cstat) <- tolower(colnames(cstat)) #set columns to lowercase


#format the dates
stri_sub(linktable$linkdt, 5, 4) <- "-" 
stri_sub(linktable$linkdt, 8, 7) <- "-" 
stri_sub(linktable$linkenddt, 5, 4) <- "-" 
stri_sub(linktable$linkenddt, 8, 7) <- "-" 
stri_sub(cstat$datadate, 5, 4) <- "-" 
stri_sub(cstat$datadate, 8, 7) <- "-" 
stri_sub(crsp$date, 5, 4) <- "-" 
stri_sub(crsp$date, 8, 7) <- "-" 

##setting up new columns with needed values
crsp$fyear <- substr(crsp$date, 1, 4) #add the fiscal year to CSRP-data
crsp$month <- substr(crsp$date, 5, 6) #add month to CRSP-data
crsp$me <- (abs(crsp$prc)*crsp$shrout)/1000 #M/E ratio: number of shares outstanding * price. Divide by 1000 to get the same format as CSTAT
cstat$be <- ((cstat$seq)+(cstat$txditc)-(cstat$pstk)) #don't have access to post-retirement
cstat$mev <- ((cstat$prcc_f)*(cstat$csho)) #cstat market equity value
cstat$mv <- ((cstat$mev)+(cstat$at)-(cstat$be)) #cstat market equity value

#rename to "permno"
linktable <- linktable %>%
  rename(
    permno = lpermno,
    permco = lpermco
  )

##set dates as.Dates
crsp <- crsp %>%
  mutate(fyear = fyear %>% as.integer,
         date = as.Date(date)) %>%
  arrange(fyear, month)

cstat <- cstat %>%
  mutate(
    datadate = as.Date(datadate)
  )


###merge linktable with cstat
cstat <-linktable %>%
  merge(cstat, by="gvkey") %>% 
  mutate(permno = as.factor(permno), #mutate through tidyverse-dplyr
         permco = as.factor(permco),
         liid = as.factor(liid),
         linkdt = as.Date(linkdt),
         linkenddt = as.Date(linkenddt),
         linktype = factor(linktype, levels=c("LC", "LU", "LS")),
         linkprim = factor(linkprim, levels=c("P", "C", "J"))) %>%
  arrange(datadate, permno, linktype, linkprim) %>%
  distinct(datadate, permno, .keep_all = TRUE)
####


# set fyear and month as integers
crsp$fyear <- as.integer(crsp$fyear)
crsp$month <- as.integer(crsp$month)

# decile portfolios
crsp$portfo=cut(crsp$me, breaks=quantile(crsp$me,probs=seq(0,1,0.1),na.rm=T),labels=F)

# decile portfolios, NYSE breakpoints only
NYSE <- filter(crsp, exchcd == 1) # NYSE exchange


# Lag assets
cstat <- cstat %>% 
  group_by(permno) %>% 
  arrange(desc(datadate)) %>% 
  mutate(lag_assets = lag(at) ,
         shift_earn = lag(oiadp, k = -1)
  )

# remove all lagged NA
cstat <- filter(cstat, lag_assets != "NA")
cstat <- filter(cstat, shift_earn != "NA")


# merge crsp and compustat
merged63 <- cstat %>%  
  mutate(date = datadate) %>% # map to next year June period when data is known (must occur in previous year)
  merge(crsp, .,by=c("date","permno"), all.x=TRUE, allow.cartesian=TRUE) %>%  # keep all CRSP records (Compustat only goes back to 1950)
  arrange(permno, date, desc(datadate)) %>%
  distinct(permno, date, .keep_all = TRUE) %>% # drop older datadates (must sort by desc(datadate))
  arrange(date, permno, be, at, lt, me, portfo, oiadp, lag_assets, shift_earn, mv)

save(merged63, file = "merged63.Rdata")
load("merged63.Rdata") 

## regression

require(lme4)

merged63$shiftearn_at <- ((merged63$shift_earn)/(merged63$at))
merged63$mv_be <- ((merged63$mv)/(merged63$be))
merged63$div_be <- ((merged63$dvt)/(merged63$be))
merged63$earn_lagat <- ((merged63$oiadp)/(merged63$lag_assets))


#standardize values to get a more inferrable model since the data is spaced
earningsStd = ((merged63$oiadp - mean(merged63$oiadp, na.rm = T)) / (sd(merged63$oiadp, na.rm = T)))
assetsStd = ((merged63$at - mean(merged63$at, na.rm = T)) / (sd(merged63$at, na.rm = T)))
earn_shiftStd = ((merged63$shift_earn - mean(merged63$shift_earn, na.rm = T)) / (sd(merged63$shift_earn, na.rm = T)))
lagged_assetsStd = ((merged63$lag_assets - mean(merged63$lag_assets, na.rm = T)) / (sd(merged63$lag_assets, na.rm = T)))
mvStd = ((merged63$mv - mean(merged63$mv, na.rm = T)) / (sd(merged63$mv, na.rm = T)))
beStd = ((merged63$be - mean(merged63$be, na.rm = T)) / (sd(merged63$be, na.rm = T)))
divStd = ((merged63$dvt - mean(merged63$dvt, na.rm = T)) / (sd(merged63$dvt, na.rm = T)))

merged63$shiftearn_at_Std <- (((merged63$shiftearn_at) - mean(merged63$shiftearn_at, na.rm = T)) / (sd(merged63$shiftearn_at, na.rm = T)))
merged63$mv_be_Std = ((merged63$mv_be - mean(merged63$mv_be, na.rm = T)) / (sd(merged63$mv_be, na.rm = T)))
merged63$div_be_Std = ((merged63$div_be - mean(merged63$div_be, na.rm = T)) / (sd(merged63$div_be, na.rm = T)))
merged63$earn_lagat_Std = ((merged63$earn_lagat - mean(merged63$earn_lagat, na.rm = T)) / (sd(merged63$earn_lagat, na.rm = T)))
merged63$divDummy = (ifelse(merged63$dvt == 0, 1, 0))



#merged63 <- filter(merged63, shiftearn_at != "NA")
#merged63 <- filter(merged63, mv_be != "NA")
#merged63 <- filter(merged63, div_be != "NA")
#merged63 <- filter(merged63, earn_lagat != "NA")
#merged63 <- filter(merged63, shiftearn_at_Std != "NA")
#merged63 <- filter(merged63, mv_be_Std != "NA")
#merged63 <- filter(merged63, div_be_Std != "NA")
#merged63 <- filter(merged63, earn_lagat_Std != "NA")

#linear ==> ANDRE, it doesnt work even for a standard linear regression. 
model <- lm(merged63$shiftearn_at ~ merged63$mv_be + merged63$divDummy + merged63$div_be, na.action = na.exclude)

#merged63$shiftearn_at[which(is.nan(merged63$shiftearn_at))] = NA
#merged63$shiftearn_at[which(merged63$shiftearn_at==Inf)] = NA

#merged63$mv_be[which(is.nan(merged63$mv_be))] = NA
#merged63$mv_be[which(merged63$mv_be==Inf)] = NA

#merged63$div_be[which(is.nan(merged63$div_be))] = NA
#merged63$div_be[which(merged63$div_be==Inf)] = NA

#merged63$earn_lagat[which(is.nan(merged63$earn_lagat))] = NA
#merged63$earn_lagat[which(merged63$earn_lagat==Inf)] = NA

#merged63$divDummy[which(is.nan(merged63$divDummy))] = NA
#merged63$divDummy[which(merged63$divDummy==Inf)] = NA


##multilvel regression
profit <- cbind(merged63$permno, merged63$shiftearn_at_Std, merged63$mv_be_Std, merged63$div_be_Std, merged63$earn_lagat_Std, merged63$divDummy)
profit <- profit[complete.cases(profit)]
profit[,7] <- as.factor(profit[,7])
earn_lagat_Std <- as.factor(earn_lagat_Std)
model <-  lmer(merged63$shiftearn_at ~ merged63$mv_be + merged63$divDummy + merged63$div_be + (1 | merged63$earn_lagat), data = as.data.frame(profit))
