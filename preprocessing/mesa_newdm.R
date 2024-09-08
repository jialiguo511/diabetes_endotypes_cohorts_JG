# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the mesa cohort
# final dataset should be named as cardia_newdm.rds

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/mesa_e1_e5.R")

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


step0 <- readRDS(paste0(path_endotypes_folder,"/working/interim/mesa_dat_all.RDS")) %>% 
  arrange(study_id,exam)%>% 
  group_by(study_id)%>% 
  mutate(dmagediag_ever = min(dia_med_age_st,na.rm=TRUE)) %>% ## dia_med_age_st, available at exam1, the earliest age when started diabetes treatment. 
  ungroup() %>% 
  mutate(dmagediag_ever = case_when(dmagediag_ever == Inf ~ NA_real_,
                                    TRUE ~ dmagediag_ever)) 
colnames(step0)

step1 <- step0 %>% 
  dplyr::filter(exam == 1) %>% 
  mutate(baseline_dm = case_when(!is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 1,
                                 # We need to add this in order to catch incident DM at Visit 1
                                 # Don't remove this
                                 # Else they will be excluded based on diab_evr if their incidence was 1 year before...
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) %in% c(0,1) ~ 0,
                                 (dia_ada == 3 | dia_sr == 1| dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1| !is.na(dia_med_type)|!is.na(dia_med_ins_1st))  ~ 1, #dia_ada = 3 [treated diabetes]; dia_ada = 2 [untreated DM ]
                                 TRUE ~ 0)) %>% 
  dplyr::filter(baseline_dm == 1 | dia_type_e1 == 1) # type I diabetes should also be removed. 

  
  

saveRDS(step1,paste0(path_endotypes_folder,"/working/interim/mesa_baseline_dm.RDS"))


step2<- step0 %>% 
  dplyr::filter(!study_id %in% step1$study_id) %>% 
  mutate(exam1_newdm = case_when (exam > 1 ~ NA_real_,
                                  # !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, --> not required
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (dia_ada == 2 | dia_sr == 1 | dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1| !is.na(dia_med_type)|!is.na(dia_med_ins_1st)) ~ 1,
                                  (glucosef>=126 &!is.na(glucosef)) ~ 1,
                                  TRUE~0),
          exam2_newdm = case_when (exam != 2 ~ NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, 
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (dia_ada == 2 | dia_urine == 1 | dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1) ~ 1,
                                  ((glucosef>=126 &!is.na(glucosef))| (hba1c >= 6.5 & !is.na(hba1c))) ~ 1,
                                   TRUE~0),
          exam3_newdm = case_when (exam != 3 ~ NA_real_,
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, 
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                   (dia_ada == 2 | dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1) ~ 1,
                                    (glucosef>=126 &!is.na(glucosef)) ~ 1,
                                    TRUE~0),
          exam4_newdm = case_when (exam != 4 ~ NA_real_,
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, 
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                   (dia_ada == 2 | dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1) ~ 1,
                                   (glucosef>=126 &!is.na(glucosef)) ~ 1,
                                   TRUE~0),
          exam5_newdm = case_when (exam != 5 ~ NA_real_,
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, 
                                   !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                   (dia_ada == 2 | !is.na(dia_med_type)| dia_med == 1| dia_med_ins_oh == 1|dia_med_kc ==1 |dia_med_ins ==1) ~ 1,
                                   ((glucosef>=126 &!is.na(glucosef))| (hba1c >= 6.5 & !is.na(hba1c))) ~ 1,
                                   TRUE~0),
   )%>% 
     distinct(study_id,exam,bmi,.keep_all =TRUE) %>% 
     group_by(study_id) %>% 
     mutate(across(matches("(exam[0-15]_newdm)"),function(x) zoo::na.locf(x,na.rm=FALSE))) %>% 
     dplyr::filter(!is.na(age)) %>% 
     mutate(earliest_age = min(age,na.rm=TRUE)) %>% 
     # mutate(across(matches("(diab_new_v)"),function(x) zoo::na.locf(x,fromLast = TRUE,na.rm=FALSE))) %>% 
     ungroup() %>% 
     mutate(dmdiagvisit = case_when(
       exam1_newdm == 1 ~ 1,
       exam2_newdm == 1 ~ 2,
       exam3_newdm == 1 ~ 3,
       exam4_newdm == 1 ~ 4,
       exam5_newdm == 1 ~ 5,
       TRUE ~ NA_real_))

mesa_newdm <- step2 %>% 
  dplyr::filter(exam == dmdiagvisit) %>% 
  mutate(dmagediag = case_when(age < dmagediag_ever ~ age,
                               !is.na(dmagediag_ever) ~ dmagediag_ever,
                               TRUE ~ age))

mesa_newdm %>% 
  dplyr::filter((age-dmagediag) <= 1) %>% 
  nrow()
mesa_newdm %>% 
  dplyr::filter((age-dmagediag) > 1) %>% 
  View()

saveRDS(mesa_newdm,paste0(path_endotypes_folder,"/working/cleaned/mesa_newdm.RDS")) #this dataset has one obs per participant 

    
  

          
                                  
                                  

