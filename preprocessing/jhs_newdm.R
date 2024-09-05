rm(list=ls()); gc(); source(".Rprofile")

study_name = "JHS"


# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the JHS cohort
# final dataset should be named as jhs_newdm.rds

#### workflow for cohorts: ARIC, JHS, MESA and CARDIA ### 
# key variables: age at study visit [age]; age at diagnosis [dmagediag];self reported DM; lab measurements
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

# source("preprocessing/jhspre01_analysis datasets from visits.R")
step0 <- readRDS(paste0(path_endotypes_folder,"/working/interim/jhspre01_jhs_analysis.RDS")) %>% 
  dplyr::filter(aric == 0) %>% 
  arrange(study_id,visit) %>% 
  group_by(study_id) %>% 
  mutate(dmagediag_ever = min(dmagediag,na.rm=TRUE)) %>% 
  ungroup() %>% 
  mutate(dmagediag_ever = case_when(dmagediag_ever == Inf ~ NA_real_,
                                  TRUE ~ dmagediag_ever),
         race_eth = "NH Black",
         female = case_when(female == "Female" ~ 1,
                            female == "Male" ~ 0,
                            TRUE ~ NA_real_))


step1 <- step0 %>% 
  dplyr::filter(visit == 1) %>% 
  mutate(baseline_dm = case_when(!is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 1,
                                 # We need to add this in order to catch incident DM at Visit 1
                                 # Don't remove this
                                 # Else they will be excluded based on diab_evr if their incidence was 1 year before...
                                 !is.na(dmagediag_ever) & (age - dmagediag_ever) %in% c(0,1) ~ 0,
                                 (dmmedsoral == 1 | dmmedsins == 1 | dmmeds == 1 | diabetes == 1) ~ 1,
                                 TRUE ~ 0)) %>% 
  dplyr::filter(baseline_dm == 1) 


step2 <- step0 %>% 
  dplyr::filter(!study_id %in% step1$study_id) %>% 
  mutate(visit1_newdm = case_when(visit > 1 ~ NA_real_,
                                  # !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, --> not required
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (dmmedsoral == 1 | dmmedsins == 1 | dmmeds == 1 | diabetes == 1) ~ 1,
                                  (glucosef >= 126 | hba1c >=6.5) ~ 0,
                                   TRUE ~ 0),
         visit2_newdm = case_when(visit!=2~NA_real_,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0,
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (dmmedsoral == 1 | dmmedsins == 1 | dmmeds == 1 | diabetes == 1) ~ 1,
                                  (glucosef >= 126 | hba1c >=6.5) ~ 0,
                                  TRUE~0),
         
         visit3_newdm = case_when(visit!=3~NA_real_,
                                  #Important to exclude individuals who will otherwise get diagnosed in between two waves but will not be captured
                                  # E.g. visit 2 = 52, visit 3 = 56, dmagediag = 54 --> should not count as newly diagnosed in either
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever) >=2 ~ 0, 
                                  !is.na(dmagediag_ever) & (age - dmagediag_ever)%in% c(0,1) ~ 1,
                                  (dmmedsoral == 1 | dmmedsins == 1 | dmmeds == 1 | diabetes == 1) ~ 1,
                                  (glucosef >= 126 | hba1c >=6.5) ~ 0,
                                  TRUE~0)
  ) %>% 
  # dplyr::filter(!is.na(age)) %>% 
  distinct(study_id,visit,bmi,.keep_all =TRUE) %>%
  group_by(study_id) %>%
  mutate(across(matches("(visit[0-9]_newdm)"),function(x) zoo::na.locf(x,na.rm=FALSE))) %>% 
  dplyr::filter(!is.na(age)) %>% 
  mutate(earliest_age = min(age,na.rm=TRUE)) %>% 
  # mutate(across(matches("(diab_new_v)"),function(x) zoo::na.locf(x,fromLast = TRUE,na.rm=FALSE))) %>% 
  ungroup() %>% 
  mutate(dmdiagvisit = case_when(
    visit1_newdm == 1 ~ 1,
    visit2_newdm == 1 ~ 2,
    visit3_newdm == 1 ~ 3,
    TRUE ~ NA_real_))


jhs_newdm = step2 %>% 
  dplyr::filter(visit == dmdiagvisit) %>% 
  mutate(dmagediag = case_when(age < dmagediag_ever ~ age,
                               !is.na(dmagediag_ever) ~ dmagediag_ever,
                               TRUE ~ age))

jhs_newdm %>% 
  dplyr::filter((age-dmagediag) <= 1) %>% 
  nrow()
jhs_newdm %>% 
  dplyr::filter((age-dmagediag) > 1) %>% 
  View()

saveRDS(jhs_newdm,paste0(path_endotypes_folder,"/working/cleaned/jhs_newdm.RDS")) #this dataset has one obs per participant 

