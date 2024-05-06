## the purpose of this R file is to extract variables from E1-5 in the MESA cohort 
rm(list=ls()); gc(); source(".Rprofile")

library(dplyr)

#CSV files are already present for this cohort, no need to convert. 

#### Exam 1, baseline

data_path_e1 <-  paste0(path_mesa_folder,"/Primary/Exam1/Data")
e1_temp <- data_extract("MESA","mesae1dres06192012",data_path_e1) 


### Exam 1 Issues ### 
# gender1, check coding --> checked, female = 1, male = 0 
# race1c, check coding --> checked, 1= caucasian, 2 = Chinese, 3 = AA, 4= Hispanic 
# weight in lb, convert to Kg
# insulin "inslnr1t", unknown fasting or not, no fasting indicator, unit need to convert 
# glucose "glucos1c", check units --> checked, most likely mg/dl 
# HDL, multiple measures, used the simple ones 
# creatin1, check if serum, likely, checked, yes, most likely serum
# MISSING: HbA1c 
## CODING: most 1 = yes, 0 = no, and 9 = unknown 
# Checked EGFR, looks normal, unit is likely mL/min/1.73 m² 


e1_temp$egfr
e1_dat <- e1_temp %>% 
  rename(insulinr = ins_r)%>% 
  rename(glucosef = glucosef_unk)%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
    select(-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)

  
#### Exam 2 

data_path_e2 <-  paste0(path_mesa_folder,"/Primary/Exam2/Data")
e2_temp1 <- data_extract("MESA","mesae2dres06222012",data_path_e2) 
e2_temp2 <- data_extract("MESA","mesaexam2dm_drepos_20220301",data_path_e2) 
e2_temp <- merge(e2_temp1, e2_temp2, by = "study_id", all = TRUE)


### Exam 2 Issues ### 
# weight in lb, convert to Kg
# Serum Hemoglobin A1c, hba1c, check unit --> checked, most likely %
# MISSING: insulin, serum creatine, egfr
# familiy history of dm: 0 = no history of dm, 1=history of t1dm, 2=history of t2dm
e2_dat <- e2_temp %>% 
  rename(hba1c= hba1c_unk )%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)


#### Exam 3

data_path_e3 <-  paste0(path_mesa_folder,"/Primary/Exam3/Data")
e3_temp <- data_extract("MESA","mesae3dres06222012",data_path_e3) 

### Exam 3 Issues ### 
# weight in lb, convert to Kg
# creatin3, check if serum, likely --> checked, most likely serum 
# MISSING: HbA1c, insulin

e3_dat <- e3_temp %>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)



#### Exam 4

data_path_e4 <-  paste0(path_mesa_folder,"/Primary/Exam4/Data")
e4_temp <- data_extract("MESA","mesae4dres06222012",data_path_e4) 

### Exam 4 Issues ### 
# weight in lb, convert to Kg
# creatin4, check if serum, likely --> checked, most likely serum
# MISSING: HbA1c, insulin, urine creatinine, urine albumin 
# checked egfr, looked okay 
e4_dat <- e4_temp %>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)


#### Exam 5

data_path_e5 <-  paste0(path_mesa_folder,"/Primary/Exam5/Data")
e5_temp <- data_extract("MESA","mesae5_drepos_20210920",data_path_e5) 


### Exam 5 Issues ### 
# weight in lb, convert to Kg
# Serum Hemoglobin A1c, hba1c, check unit --> checked unit, most likely % 
# insulin "INSULIN5", fasting or not, unknown, unit needs to convert --> much higher than insulin measured in Exam1 
# check "CEPGFR5C", also in e1 and e4 to see if values make sense. 
# checked egfr, looks okay 
e5_dat <- e5_temp %>% 
  rename(hba1c= hba1c_unk )%>% 
  rename(insulinr= ins_r )%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.4536)%>% 
  select(-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)

