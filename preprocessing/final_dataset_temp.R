# the purpose of this file is to prepare a final dataset for ML in python 
# created in March 2024 by ZL 
# This file is later modified to adjust units for glucose and insulin required in HOMA2 from fasting insulin and glucose (taged "2") by ZL in March 2024
# In April 2024, new cohort: ARIC, MESA, and CARIA are added. HOMA2 will also be created for them 
# In May 2024, we have decided to add more variables to build the prediction model
# In May 2024, we have decided to use the five-variable and the nine-variable methods to run K means and logistic regression for the analysis.
# In August 2024, we have decided: 
## 1) removed all DPP intervention arms; 
## 2) cleaned data once more to ensure that all lab measures were collected with 12 month AFTER diagnosis (DPP, DPPOS and CARIDA); 
## 3) removed shared ARIC participants from JHS.

###### 
# In June 2024, renamed with _temp, so that it is clear that this is for temporary/intermediate final dataset only. 
# In July 2024, extracted gender and race. created a new variable named "race_rev" to code African American and White
#####
# K means with eight cohorts (LA, JHS, DPP, ACCORD, DDPOS, ARIC, CARDIA, MESA)
library(dplyr)
library(tidyr)

### load datasets
# VARIABES [our approach]: 
## age (this should be dmagediag), BMI, HbA1c, LDL cholesterol, HDL cholesterol, triglycerides, 
## systolic and diastolic blood pressure, and TGL:HDL ratio)

# ADDED variables [for EHR prediction model, NOT NEEDED! but included in the dataset as of May 2024]: 
## JHS: serumcreatinine, urinealbumin, urinecreatinine, egfr,totalc
## Look Ahead: serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr
## ACCORD: serumcreatinine, urinealbumin, urinecreatinine, uacr, egfr, alt,totalc
## DPP: serumcreatinine, urinecreatinine
## DPPOS: serumcreatinine, ast, alt,totalc
## ARIC: serumcreatinine,urinealbumin,totalc
## CARDIA: serumcreatinine, urinealbumin, uacr, egfr, totalc
## MESA: urinealbumin, urinecreatinine, uacr,serumcreatinine, egfr,totalc

## JHS [okay]
#some duplicates in ids, values appear to differ, reason unknown, created new id and renamed to study_id. 


jhs<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/jhs.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                race_rev = "AA")%>% 
  rename(race = race_eth)%>% 
                #new_id = row_number())%>% 
  #rename(study_id = new_id)%>% 
  dplyr::filter(aric == 0)%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration,glucosef2,insulinf2,
                serumcreatinine, urinealbumin, urinecreatinine, egfr, totalc,female,race,race_rev) 

jhs_newdm <- jhs[jhs$dmduration%in% c(0, 1), ] # check THIS! 
jhs_newdm$study = "jhs" # n = 1174 (with ARIC shared); n = 728 without ARIC shared

## Look Ahead [okay,no fasting insulin & glucose]

la<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc, 
                uacr= uacr*1000)%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr) #no fasting insulin

la_newdm <- la[la$dmduration%in% c(0, 1), ] 
la_newdm$study = "la" #N=877

## ACCORD [okay,no fasting insulin&glucose]
accord<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/accord.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                bmi = weight/((height/100)^2)
                )%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration,
                serumcreatinine, urinealbumin, urinecreatinine, uacr, egfr, alt,totalc) # no fasting insulin

accord_newdm <-accord[accord$dmduration%in% c(0, 1), ] 
accord_newdm$study = "accord" #N=601 

## DPP 

dpp<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dpp.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                race_rev = case_when(
                  race_eth == "NH White" ~ "White",
                  race_eth == "NH Black" ~ "AA",
                  race_eth %in% c("Hispanic", "NH Other") ~ "Other",
                  TRUE ~ NA_character_  
                ))%>% 
  rename(race = race_eth)%>% 
  dplyr::filter(treatment == "Placebo") %>% # remove all intervention arms [decision made on 8.14.24]
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2,
                serumcreatinine, urinecreatinine,female,race,race_rev) 

dpp$study = "dpp" #n=800 all intervention arms; n = 291 placebo only. 


## DPPOS 
dppos<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dppos.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                race_rev = case_when(
                  race_eth == "NH White" ~ "White",
                  race_eth == "NH Black" ~ "AA",
                  race_eth %in% c("Hispanic", "NH Other") ~ "Other",
                  TRUE ~ NA_character_  
                ))%>% 
  rename(race = race_eth)%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2,
                serumcreatinine, ast, alt,totalc,female,race,race_rev,treatment) %>% 
  dplyr::filter(!study_id %in% dpp$study_id)

dppos$study = "dppos" # n = 1077

#dpp$study_id <- NULL
#dppos$study_id <- NULL

table(dppos$race)
#### In these three cohorts, loaded data are new DM cases only, therefore age = dmagediag if dmagediag not already created 

## ARIC [okay]
# in this cohort new dm case data, baseline dm is not included. 
aric<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/aric_newdm.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                urinealbumin = urinealbumin/10,
                race_rev = case_when(
                  race == "W" ~ "White",
                  race == "B" ~ "AA",
                  TRUE ~ NA_character_  
                ),
                female = case_when(
                  female == "M" ~ 0,  
                  female == "F" ~ 1,  
                  TRUE ~ NA_integer_
                ),
                  race = case_when(
                    race == "W" ~ "NH White",
                    race == "B" ~ "NH Black",
                    TRUE ~ NA_character_  
                  ),
                )%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2,
                serumcreatinine,urinealbumin,totalc,female,race,race_rev) # NOTE: white or AA only, no hispanic or other groups. 

aric$study = "aric" # n = 3802


## CARDIA 
cardia <-readRDS(paste0(path_endotypes_folder,"/working/cleaned/cardia_newdm.RDS"))%>% 
  #dplyr::filter(year!=0)%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                dmagediag = case_when(
                  abs(dmagediag-age)<=1 ~dmagediag,
                  TRUE ~age
                ),
                female = case_when(
                  female == 1 ~ 0,  
                  female == 2 ~ 1,  
                  TRUE ~ NA_integer_
                ),
                race_rev = case_when(
                  race == 4 ~ "AA",
                  race == 5 ~ "White",
                  TRUE ~ NA_character_  
                ),
                race = case_when(
                  race == 4 ~ "NH Black",
                  race == 5 ~ "NH White",
                  TRUE ~ NA_character_), 
                )%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2,
                serumcreatinine, urinealbumin, uacr, egfr,totalc,female,race,race_rev)

table(cardia$race)
cardia$study = "cardia" #n=692

## MESA 

mesa<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/mesa_newdm.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinr*6,
                female = 1 - female,
                race_rev = case_when(
                  race == 1 ~ "White",
                  race == 3 ~ "AA",
                  race == 2 | 4 ~ "Other",
                  TRUE ~ NA_character_  
                ),
                race = case_when(
                  race == 1 ~ "NH White",
                  race == 3 ~ "NH Black",
                  race == 2 ~ "Other",
                  race == 4 ~ "Hispanic",
                  TRUE ~ NA_character_  
                ))%>% 
    rename(dmagediag=age)%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2,
                urinealbumin, urinecreatinine, uacr,serumcreatinine, egfr,totalc,female,race,race_rev) 

mesa$study = "mesa" #n=901


#merge data and remove all NAs, imputation could be used in sensitivity analysis to increase sample size

# "_clean" is added to all final datasets to mark the version made in AUGUST 2024 # 

data_8c_clean<- bind_rows(jhs_newdm,la_newdm,accord_newdm,dpp,dppos,aric,cardia,mesa)%>% 
  select(-study_id,-dmduration)%>% 
  mutate(study_id=row_number())%>%
  select(last_col(),everything()) # 9892 new DM cases 

data_6c_clean<-bind_rows(jhs_newdm,dpp,dppos,aric,cardia,mesa)%>% 
  select(-study_id,-dmduration)%>% 
  mutate(study_id=row_number()) %>%
  select(last_col(),everything())# 8414 new DM cases

data_8c_clean_sum <- data_8c_clean%>% 
  group_by(study)%>%
  summarise(across(everything(), ~ sum(!is.na(.)), .names = "n_{.col}"))

data_6c_clean_sum <- data_6c_clean %>% 
  group_by(study)%>%
  summarise(across(everything(), ~ sum(!is.na(.)), .names = "n_{.col}"))


library(readr)
write_csv(data_8c_clean_sum, paste0(path_endotypes_folder,"/results/updates/count_sum_8c_clean.csv"))
write_csv(data_6c_clean_sum, paste0(path_endotypes_folder,"/results/updates/count_sum_6c_clean.csv"))


### for all eight cohorts ### 
data_8c_mean <- data_8c %>%
  group_by(study) %>%  
  summarise(across(everything(), mean, na.rm = TRUE), .groups = "drop")
# urine albumin is mg/L in ARIC (conversion = /10) [completed on 5.6.24]
# uarc in LA is in wrong unit, corre›ct by x1000 [completed on 5.6.24]

### output a temporary merged dataset for further processing 
write.csv(data_8c, paste0(path_endotypes_folder,"/working/processed/final_data_temp_8c.csv"), row.names = FALSE)

### output a merged dataset for six cohort dataset for HOMA2 to be added. This dataset contains missing data at key variables. 
write.csv(data_6c, paste0(path_endotypes_folder,"/working/processed/final_data_temp_6c.csv"), row.names = FALSE)

plyr::rbind.fill(jhs_newdm,la_newdm,accord_newdm,dpp,dppos,aric,cardia,mesa) %>% 
  rename(original_study_id = study_id)%>% 
  mutate(study_id=row_number())%>%
  select(last_col(),everything()) %>%  # 9892 new DM cases %>% 
 saveRDS(.,paste0(path_endotypes_folder,"/working/processed/final_dataset_temp.RDS"))
