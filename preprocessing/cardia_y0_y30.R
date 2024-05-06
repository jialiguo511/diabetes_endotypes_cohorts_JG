## the purpose of this R file is to extract variables from Y0-25 in the CARDIA cohort 
rm(list=ls()); gc(); source(".Rprofile")

library(dplyr)

#CSV files are already present for this cohort, no need to convert. 

###  YEAR0 Baseline 

data_path_y0 <-  paste0(path_cardia_folder,"/Y00/DATA/csv")

vl_column <-c("aaf09gen","aaref","aaf01","aaf07","aaf10","aaf11","aaf20","aaf02","aains","aaf05","aachem","aalip","aaf08v2")
y0_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y0)
  if (is.null(y0_merged)) {
    y0_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y0_merged <- merge(y0_merged, new_data, by = "study_id", all = TRUE)
  }}

summary(y0_merged)

##Y0 issues ## 
# insulin, unit need to re-code,unknown status, fasting or not? create a random insulin if not fasting 
# glucose, unknown status: fasting or random? check the fasting variable. create a random glucose if not fasting
# creatinine, unknown source, serum or urine? likely serum. 
# albumin, unknown source, serum or urine? likely serum. 
# age, race, and sex, need to compare with y2. compare EXAMAGE in Y0 and Y2 to check if they are the same. only need to keep one after merge. 
# MISSING: HbA1c, weight, and height


#MODIFICATIONS:
# SEX, assumed, 1=male, 2=female 
# RACE, coding unclear, keep all there variables 
# Medication use, assumed, 1=no, 2=yes, 8=missing
# TO DROP: sex_ver_y2, age_tel, age_ver, insulin_uuml,creatinine_unkn,albumin_unkn,glucose_mg100,fasting_min

table(y0_merged$fasting)
dat_y0 <- y0_merged %>%
  mutate(insulinf=case_when(
    fasting =="YES"~insulin_uuml,
    TRUE~NA_real_),
    insulinr=case_when(
    fasting =="NO"~ insulin_uuml,
    TRUE~NA_real_),
    glucosef=case_when(
      fasting =="YES"~glucose_mg100,
      TRUE~NA_real_),
    glucoser=case_when(
      fasting =="NO"~ glucose_mg100,
      TRUE~NA_real_),
    serumcreatinine = creatinine_unkn,
    serumalbumin = albumin_unkn,
    )%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  select(-sex_ver_y2, -age_tel, -age_ver, -insulin_uuml,-creatinine_unkn,-albumin_unkn,-glucose_mg100,-fasting_min,-fasting, -sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3)

summary(dat_y0)

### YEAR2 
data_path_y2 <-  paste0(path_cardia_folder,"/Y02/DATA/csv")

vl_column <-c("baf09dib","baref","baf07","baf02","baf10","baf20","baf08v2","baf09mht","baf09mhb")
y2_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y2)
  if (is.null(y2_merged)) {
    y2_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y2_merged <- merge(y2_merged, new_data, by = "study_id", all = TRUE)
  }}
summary(y2_merged)

## Y2 issues
# weight is in lb, need to convert to kg
# MISSING: insulin, HbA1c, glucose, all lipids
# DECISION(?): drop YEAR 2 or merge with year 0. 

#MODIFICATIONS:
# SEX, assumed, 1=male, 2=female 
# RACE, coding unclear, keep all there variables 
# Medication use, assumed, 1=no, 2=yes, 8=missing

dat_y2<-y2_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
         )%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3)




### YEAR5 
data_path_y5 <-  paste0(path_cardia_folder,"/Y05/DATA/csv")

vl_column <-c("caf08","caref","caf11","caf20","caf02","calip","caf39","caapob")
y5_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y5)
  if (is.null(y5_merged)) {
    y5_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y5_merged <- merge(y5_merged, new_data, by = "study_id", all = TRUE)
  }}

summary(y5_merged)

## Y5 issues
# weight is in lb, need to convert to kg
# Urine creatinine, day1-3 measurements, NOT SURE how to use, average? 
# MISSING: insulin, HbA1c, glucose

dat_y5<-y5_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
         urinecreatinine = mean(c(urinecreatinine_d1,urinecreatinine_d2,urinecreatinine_d3),na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
    select(-sbp1,-sbp2,-sbp3,
                  -dbp1,-dbp2,-dbp3,
           -urinecreatinine_d1,-urinecreatinine_d2,-urinecreatinine_d3) 
names(dat_y5)

### YEAR7
data_path_y7 <-  paste0(path_cardia_folder,"/Y07/DATA/csv")

vl_column <-c("daf08","daref","daf20","daf02","dains","daf05a","daglu","dalip")
y7_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y7)
  if (is.null(y7_merged)) {
    y7_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y7_merged <- merge(y7_merged, new_data, by = "study_id", all = TRUE)
  }}

summary(y7_merged)

## Y7 issues
# weight is in lb, need to convert to kg
# insulin, unknown status, fasting or not
# glucose, unknown status, fastig or not 
# MISSING: HbA1c 

names(y7_merged)

dat_y7<-y7_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
  )%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536,
         insulinf=case_when(
           fasting =="YES"~insulin_uuml,
           TRUE~NA_real_),
         insulinr=case_when(
           fasting =="NO"~ insulin_uuml,
           TRUE~NA_real_),
         glucosef=case_when(
           fasting =="YES"~glucose_ug, #the unit should be mg/dl as suggested by the range 
           TRUE~NA_real_),
         glucoser=case_when(
           fasting =="NO"~ glucose_ug,
           TRUE~NA_real_),
         )%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3,
         -insulin_uuml,-glucose_ug,
         -fasting_min,-fasting)


### YEAR10
data_path_y10 <-  paste0(path_cardia_folder,"/Y10/DATA/csv")

vl_column <-c("eaf08","eaf11","earef","eaf20","eaf02","eaglu","eains","ealip","eachem","eamicro","eaapob")
y10_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y10)
  if (is.null(y10_merged)) {
    y10_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y10_merged <- merge(y10_merged, new_data, by = "study_id", all = TRUE)
  }}


## Y10 issues 
# weight is in lb, need to convert to kg
# return visits, averaged. 
# MISSING: HbA1c 

dat_y10 <- y10_merged %>%
  rename(baseage = age_ver_y2) %>%
  rowwise() %>%
  mutate(sbp = mean(c(sbp1, sbp2, sbp3), na.rm = TRUE),
         dbp = mean(c(dbp1, dbp2, dbp3), na.rm = TRUE),
         insulinf = if (!is.na(insulinf) & !is.na(insulinf_y10r)) {
           (insulinf + insulinf_y10r) / 2
         } else if (is.na(insulinf) & !is.na(insulinf_y10r)) {
           insulinf_y10r
         } else {
           insulinf
         },
         insulin2h = if (!is.na(insulin_2h_uuml) & !is.na(insulin_2h_y10r)) {
           (insulin_2h_uuml + insulin_2h_y10r) / 2
         } else if (is.na(insulin_2h_uuml) & !is.na(insulin_2h_y10r)) {
           insulin_2h_y10r
         } else {
           insulin_2h_uuml
         },
         glucose2h = if (!is.na(glucose2h) & !is.na(glucose2h_y10r)) {
           (glucose2h + glucose2h_y10r) / 2
         } else if (is.na(glucose2h) & !is.na(glucose2h_y10r)) {
           glucose2h_y10r
         } else {
           glucose2h
         },
         glucosef = if (!is.na(glucosef) & !is.na(glucosef_y10r)) {
           (glucosef + glucosef_y10r) / 2
         } else if (is.na(glucosef) & !is.na(glucosef_y10r)) {
           glucosef_y10r
         } else {
           glucosef
         }
  ) %>%
  ungroup() %>%
  mutate(weight = weight * 0.4536)%>% 
  select(
    -sbp1,-sbp2,-sbp3,
    -dbp1,-dbp2,-dbp3,
    -insulin_2h_uuml,-insulin_2h_y10r,-insulinf_y10r,-glucosef_y10r,-glucose2h_y10r)


names(dat_y10)

### YEAR15

data_path_y15 <-  paste0(path_cardia_folder,"/Y15/DATA/csv")

vl_column <-c("faf08","faref","faf20","fains","faglu","falip","famicro","fachem","faf02")
y15_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y15)
  if (is.null(y15_merged)) {
    y15_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y15_merged <- merge(y15_merged, new_data, by = "study_id", all = TRUE)
  }}


## Y15 issues 
# weight is in lb, need to convert to kg
# MISSING: HbA1c and hip measurement

names(y15_merged)

dat_y15<-y15_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
  )%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3)

names(dat_y15)

### YEAR20


data_path_y20 <-  paste0(path_cardia_folder,"/Y20/DATA/csv")

vl_column <-c("gaf08","garef","gaf20","gaf02","gahba1c","gains","gaglu","galip","gachem","gamicro","gaf83")
y20_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y20)
  if (is.null(y20_merged)) {
    y20_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y20_merged <- merge(y20_merged, new_data, by = "study_id", all = TRUE)
  }}


## Y20 issues 
# weight is in lb, need to convert to kg
# compare insulin with calibrated insulin
# compare the egfr variables
# check HbA1c values 
# MODIFICATION: if calibrated values, take average

dat_y20<-y20_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
         egfr=mean(c(egfr,egfr_rev), na.rm = TRUE),
         insulinf=mean(c(insulinf,insulinf_cali), na.rm = TRUE),
         serumcreatinine = mean(c(serumcreatinine,serumcreatinine_cali),na.rm = TRUE)
  )%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3,
         -egfr_rev,-insulinf_cali,-serumcreatinine_cali)
summary(dat_y20)

### YEAR25


data_path_y25 <-  paste0(path_cardia_folder,"/Y25/DATA/csv")

vl_column <-c("haf08","haf11","haref","haf20","haf02","hahba1c","hains","haglu","halip","hachem","hamicro")
y25_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y25)
  if (is.null(y25_merged)) {
    y25_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y25_merged <- merge(y25_merged, new_data, by = "study_id", all = TRUE)
  }}

## Y25 issues 
# weight is in lb, need to convert to kg
# check HbA1c values
# compare two insulin values 

dat_y25<-y25_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
         glucosef = if (!is.na(glucosef) & !is.na(glucosef_delay)) {
           (glucosef + glucosef_delay) / 2
         } else if (is.na(glucosef) & !is.na(glucosef_delay)) {
           glucosef_delay
         } else {
           glucosef
         },
         insulinf = if (!is.na(insulinf) & !is.na(insulinf_y25_hm)) {
           (insulinf + insulinf_y25_hm) / 2
         } else if (is.na(insulinf) & !is.na(insulinf_y25_hm)) {
           insulinf_y25_hm
         } else {
           insulinf
         })%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3,
         -insulinf_y25_hm,-glucosef_delay)

names(dat_y25)

### YEAR30


data_path_y30 <-  paste0(path_cardia_folder,"/Y30/DATA/csv")

vl_column <-c("iaf08","iaref","iaf20","iaf02","iahba1c","iains","iaglu","ialip","iachem","iamicro")
y30_merged <- NULL

for (vl in vl_column) {
  new_data <- data_extract("CARDIA", vl, data_path_y30)
  if (is.null(y30_merged)) {
    y30_merged <- new_data
  } else {
    # Merge the new_data with the existing merged_data by study_id
    y30_merged <- merge(y30_merged, new_data, by = "study_id", all = TRUE)
  }}

summary(y30_merged)
names(y30_merged)
## Y30 issues 
# weight is in lb, need to convert to kg

dat_y30<-y30_merged%>% 
  rename(baseage = age_ver_y2)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE),
         glucosef = if (!is.na(glucosef) & !is.na(glucosef_delay)) {
           (glucosef + glucosef_delay) / 2
         } else if (is.na(glucosef) & !is.na(glucosef_delay)) {
           glucosef_delay
         } else {
           glucosef
         })%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,
         -dbp1,-dbp2,-dbp3,
         -glucosef_delay)

names(dat_y30)


