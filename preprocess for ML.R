# the purpose of this file is to prepare dataset for ML in python 
# created in March 2024 by ZL 
# This file is later modified to adjust units for glucose and insulin required in HOMA2 from fasting insulin and glucose (taged "2") by ZL in March 2024
# In April 2024, new cohort: ARIC, MESA, and CARIA are added. HOMA2 will also be created for them 

# K means with eight cohorts (LA, JHS, DPP, ACCORD, DDPOS, ARIC, CARDIA, MESA)
library(dplyr)
library(tidyr)

### load datasets
# VARIABES [our approach]: 
## age(this should be dmagediag), BMI, HbA1c, LDL cholesterol, HDL cholesterol, triglycerides, 
## systolic and diastolic blood pressure, and TGL:HDL ratio)

## JHS 
#some duplicates in ids, values appear to differ, reason unknown, created new id and renamed to study_id. 
jhs<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/jhs.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6)%>% 
                #new_id = row_number())%>% 
  #rename(study_id = new_id)%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration,glucosef2,insulinf2) 

jhs_newdm <- jhs[jhs$dmduration%in% c(0, 1), ] 
jhs_newdm$study = "jhs"


## Look Ahead 
la<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc)%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration) #no fasting insulin

la_newdm <- la[la$dmduration%in% c(0, 1), ] #N=877
la_newdm$study = "la"

## ACCORD
accord<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/accord.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                bmi = weight/((height/100)^2)
                )%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration) # no fasting insulin


accord_newdm <-accord[accord$dmduration%in% c(0, 1), ] #N=601 
accord_newdm$study = "accord"

## DPP 
dpp<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dpp.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6)%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2) #n=802 

dpp$study = "dpp"

## DPPOS 
dppos<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dppos.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6
                )%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2)# n = 907

dppos$study = "dppos"

#### In these three cohorts, loaded data are new DM cases only, therefore age = dmagediag if dmagediag not already created 

## ARIC 
# in this cohort new dm case data, baseline dm is not included. 
aric<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/aric_new_dm.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6)%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2) # n = 3587

aric$study = "aric"

# check if dmagediag was created correctly for ARIC. It is most likely to be right but could compare with age variable to double check 

## CARDIA 
# first, drop baseline DM 

#cardia <-readRDS(paste0(path_endotypes_folder,"/working/cleaned/CARDIA_newdm.RDS"))
cardia <-readRDS(paste0(path_endotypes_folder,"/working/cleaned/CARDIA_newdm.RDS"))%>% 
  dplyr::filter(year!=0)%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinf*6,
                dmagediag = case_when(
                  abs(dmagediag-age)<=1 ~dmagediag,
                  TRUE ~age
                ))%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2)
summary(cardia) #n=791 after y = 0 removed 

cardia$study = "cardia"

## MESA 
# first, drop baseline DM 
mesa<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/MESA_newdm.RDS"))%>% 
  dplyr::filter(exam!=1)%>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                glucosef2=glucosef*0.0555,
                insulinf2=insulinr*6)%>% 
    rename(dmagediag=age)%>% 
  dplyr::select(bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,glucosef2,insulinf2) # n = 3587

mesa$study = "mesa"

#merge data and remove all NAs, imputation could be used in sensitivity analysis to increase sample size
data_8c<-bind_rows(jhs_newdm,la_newdm,accord_newdm,dpp,dppos,aric,cardia,mesa)%>% 
  select(-study_id,-dmduration)%>% 
  mutate(study_id=row_number()) # 8682 new dm cases 

# for nine variable method 
var_sel <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag")
data_8c_nona <- data_8c[complete.cases(data_8c[,var_sel]),] # 5128 no NA new dm cases 
data_8c_nona <- data_8c_nona[c("study_id", setdiff(names(data_8c_nona), "study_id"))]

# for homa2 comparison, five variable method 
var_sel2 <- c("bmi","hba1c","glucosef2","insulinf2","dmagediag")
data_homa2 <-data_8c[complete.cases(data_8c[,var_sel2]),]
data_homa2 <- data_homa2[c("study_id", setdiff(names(data_homa2), "study_id"))]


# export to pyhton 
data_array <- as.matrix(data_8c_nona)
write.csv(data_array, paste0(path_endotypes_folder,"/working/processed/data_array.csv"), row.names = FALSE)

# the HOMA2 is calculated using the excel calculator released by University of Oxford.Some observations will be removed due to extreme values out of the range. 
data_array_homa2 <- as.matrix(data_homa2)
write.csv(data_array_homa2, paste0(path_endotypes_folder,"/working/processed/data_array_homa2.csv"), row.names = FALSE)


