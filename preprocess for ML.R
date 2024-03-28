# the purpose of this file is to prepare dataset for ML in python 
# created in March 2024 by ZL 

# K means with five cohorts (LA, JHS, DPP, ACCORD, DDPOS)
library(dplyr)
library(tidyr)
# load dtidyr# load datasets
# variables (age(this should be dmagediag), BMI, HbA1c, LDL cholesterol, HDL cholesterol, triglycerides, 
## systolic and diastolic blood pressure, and TGL:HDL ratio)

jhs<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/jhs.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc)%>% 
  dplyr::select(study_id,age,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration)

jhs_newdm <- jhs[jhs$dmduration%in% c(0, 1), ] #some duplicates, reason unknown 


la<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc)%>% 
  dplyr::select(study_id,bsage,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration)%>% 
  rename(age=bsage)

la_newdm <- la[la$dmduration%in% c(0, 1), ] #N=877

accord<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/accord.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,bmi = weight/((height/100)^2))%>% 
  dplyr::select(study_id,bsage,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag,dmduration)%>% 
  rename(age=bsage)

accord_newdm <-accord[accord$dmduration%in% c(0, 1), ] #N=601 

dpp<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dpp.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc)%>% 
  dplyr::select(study_id,bsage,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag)%>% 
  rename(age=bsage) #n=802 

dppos<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/dppos.RDS"))%>% 
  dplyr::mutate(ratio_th=tgl/hdlc)%>% 
  dplyr::select(study_id,bmi,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,dmagediag) # n = 907

view(dppos)

#merge data and remove all NAs, imputation could be used in sensitivity analysis to increase sample size
data<-bind_rows(jhs_newdm,la_newdm,accord_newdm,dpp,dppos)%>% 
  dplyr::select(-dmduration,-study_id,-age)%>% 
  drop_na() 


# export to pyhton 
data_array <- as.matrix(data)
write.csv(data_array, paste0(path_endotypes_folder,"/working/processed/data_array.csv"), row.names = FALSE)




