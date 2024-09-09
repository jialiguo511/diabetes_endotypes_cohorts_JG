# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the cardia cohort
# final dataset should be named as cardia_newdm.rds

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/cardia_y0_y30.R")

#### workflow for cohorts: ARIC, JHS, MESA and CARDIA ### 
# step 0: if age at diagnosis [dmagediag] is known, we will use the minimal dmagediag as the dmagediag for ALL participants for all visits
# step 1: Identify baseline DM cases in VISIT #1: These participants will be categorized as existing DM and will be removed from the dataset.
## 1) [dmduration] = [age]-[dmagediag] >=2 --> baseline DM = 1 
## 2) self report DM = 1 & [dmduration] !=0 or 1 --> baseline DM = 1 
## 3) other conditions --> baseline DM = 0 
# step 2: in VISIT#1 to last VISIT: identify new DMs by [dmduration], self-reported DM, and lab cutoffs
## 1) [dmduration] = [age]-[dmagediag] >=2 --> new_dm = 0 
## 2) [dmduration] = [age]-[dmagediag] = 1 --> new_dm = 1 
## 3) self reported DM = 1 --> new_dm =1 
## 4) meeting lab cutoffs --> new_dm = 1 

step0 <- readRDS(paste0(path_endotypes_folder,"/working/interim/cardia_dat_all.RDS"))%>% 
  arrange(study_id,year)%>% 
  group_by(study_id)%>% 
  mutate(dmagediag_ever = min(dmagediag,na.rm=TRUE)) %>% 
  ungroup() %>% 
  mutate(dmagediag_ever = case_when(dmagediag_ever == Inf ~ NA_real_,
                                    TRUE ~ dmagediag_ever)) 

step1 <- step0 %>% 
  dplyr::filter(year == 0) %>% 
  mutate(baseline_dm = case_when(!is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 1,
                                 # We need to add this in order to catch incident DM at Visit 1
                                 # Don't remove this
                                 # Else they will be excluded based on diab_evr if their incidence was 1 year before...
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) %in% c(0,1) ~ 0,
                                 diab_ind == 2 ~ 1,
                                 TRUE ~ 0)) %>% 
  dplyr::filter(baseline_dm == 1) 

saveRDS(step1,paste0(path_endotypes_folder,"/working/interim/cardia_baseline_dm.RDS"))

step2<- step0 %>% 
  dplyr::filter(!study_id %in% step1$study_id) %>% 
  mutate(year0_newdm = case_when (year > 0 ~ NA_real_,
                                  # !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, --> not required
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  diab_ind == 2 ~ 1,
                                  (glucosef>=126&!is.na(glucosef)) ~ 1,
                                  TRUE~0), 
         year2_newdm = case_when(year!=2 ~ NA_real_,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                 diab_ind == 2 ~ 1,
                                 # no lab for year 2
                                 TRUE~0),
         year5_newdm = case_when(year!=5 ~ NA_real_,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                 diab_ind == 2 ~ 1,
                                 # no lab for year 5
                                 TRUE~0),
         year7_newdm = case_when(year!=7 ~ NA_real_,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                 diab_ind == 2 ~ 1,
                                 (glucosef>=126&!is.na(glucosef)) ~ 1,
                                 TRUE~0), 
         year10_newdm = case_when(year!=10 ~ NA_real_,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                 diab_ind == 2 ~ 1,
                                 (glucosef>=126&!is.na(glucosef)) ~ 1,
                                 TRUE~0), 
         year15_newdm = case_when(year!=15 ~ NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (diab_ind == 2 |med_diab ==2) ~ 1,
                                  (glucosef>=126&!is.na(glucosef)) ~ 1,
                                  TRUE~0), 
         year20_newdm = case_when(year!=20 ~ NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (diab_ind == 2 |med_diab ==2 |med_diab_nin ==2) ~ 1,
                                  ((glucosef >= 126 & !is.na(glucosef)) |(hba1c >=6.5 & !is.na(hba1c))) ~ 1,
                                  TRUE~0), 
         year25_newdm = case_when(year!=25 ~ NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (diab_ind == 2 |med_diab ==2 |med_diab_nin ==2) ~ 1,
                                  ((glucosef >= 126 & !is.na(glucosef)) |(hba1c >=6.5 & !is.na(hba1c))) ~ 1,
                                  TRUE~0), 
         year30_newdm = case_when(year!=30 ~ NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (diab_ind == 2 |med_diab ==2 |med_diab_nin ==2) ~ 1,
                                  ((glucosef >= 126 & !is.na(glucosef)) |(hba1c >=6.5 & !is.na(hba1c))) ~ 1,
                                  TRUE~0), 
         ) %>%
  distinct(study_id,year,bmi,.keep_all =TRUE) %>% 
  group_by(study_id) %>% 
  mutate(across(matches("(year[0-30]_newdm)"),function(x) zoo::na.locf(x,na.rm=FALSE))) %>% 
  dplyr::filter(!is.na(age)) %>% 
  mutate(earliest_age = min(age,na.rm=TRUE)) %>% 
  # mutate(across(matches("(diab_new_v)"),function(x) zoo::na.locf(x,fromLast = TRUE,na.rm=FALSE))) %>% 
  ungroup() %>% 
  mutate(dmdiagvisit = case_when(
    year0_newdm == 1 ~ 0,
    year2_newdm == 1 ~ 2,
    year5_newdm == 1 ~ 5,
    year7_newdm == 1 ~ 7,
    year10_newdm == 1 ~ 10,
    year15_newdm == 1 ~ 15,
    year20_newdm == 1 ~ 20,
    year25_newdm == 1 ~ 25,
    year30_newdm == 1 ~ 30,
    TRUE ~ NA_real_))

cardia_newdm <- step2 %>% 
  dplyr::filter(year == dmdiagvisit) %>% 
  mutate(dmagediag = case_when(age < dmagediag_ever ~ age,
                                !is.na(dmagediag_ever) ~ dmagediag_ever,
                                TRUE ~ age))
  
cardia_newdm %>% 
  dplyr::filter((age-dmagediag) <= 1 & (age-dmagediag) >=0) %>% 
  nrow()
cardia_newdm %>% 
  dplyr::filter((age-dmagediag) > 1) %>% 
  View()
  
saveRDS(cardia_newdm,paste0(path_endotypes_folder,"/working/cleaned/cardia_newdm.RDS")) #this dataset has one obs per participant 

  
  
         
         
         
         