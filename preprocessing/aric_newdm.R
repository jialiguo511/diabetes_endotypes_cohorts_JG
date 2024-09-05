# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the ARIC cohort
# final dataset should be named as aric_newdm.rds

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



step0 <- readRDS(paste0(path_endotypes_folder,"/working/interim/aric_analysis.RDS")) %>%
  mutate(across(contains("evr"),function(x) case_when(x=="N" ~ 0,
                                                      x == "Y" ~ 1,
                                                      TRUE ~ NA_real_))) %>% 
  arrange(study_id,visit) %>% 
  group_by(study_id) %>% 
  mutate(dmagediag_V3 = min(dmagediag,na.rm=TRUE))  %>% 
  ungroup() %>% 
  mutate(dmagediag_V3 = case_when(dmagediag_V3 == Inf ~ NA_real_,
                                  TRUE ~ dmagediag_V3)) %>% 
  mutate(
    
    # VISIT 1
    diab_126_fast = case_when(
    diab_126_fast=="1"|diab_126_fast=="T"~1,
    diab_126_fast=="0"~0,
    TRUE ~ NA_real_),
    diab_evr = case_when(
      diab_evr=="Y"~1,
      diab_evr=="N"~0,
      TRUE ~ NA_real_),
    # VISIT 2 
    diab_doc = case_when(
      diab_doc=="Y"~1,
      diab_doc=="N"~0, #there are other letters with unknown meanings in v3,v4 and v5,code to NA for now 
      TRUE ~ NA_real_),
    
    # VISIT 3 -------
    diab_126 = case_when(
      diab_126=="1"|diab_126=="T"~1,
      diab_126=="0"~0,
      TRUE ~ NA_real_),
    diab_140 = case_when(
      diab_140=="1"|diab_140=="T"~1,
      diab_140=="0"~0,
      TRUE ~ NA_real_),
    diab_med_2w = case_when(
      diab_med_2w=="Y"~1,
      diab_med_2w=="N"~0,
      TRUE ~ NA_real_),
    
    # VISIT 4 ---------
    diab_trt= case_when(
      diab_trt == "Y"~1,
      diab_trt=="N"~0,
      TRUE ~ NA_real_),
    diab_med_any = case_when(
      diab_med_any=="Y"~1,
      diab_med_any=="N"~0,
      TRUE ~ NA_real_),
    
    # VISIT 5 -------
    diab_a1c65= case_when(
      diab_a1c65 == "1"|diab_a1c65 =="T"~1,
      diab_a1c65=="0"~0,
      TRUE ~ NA_real_),
    diab_med_4w= case_when(
      diab_med_4w == "1"|diab_med_4w =="T"~1,
      diab_med_4w=="0"~0,
      TRUE ~ NA_real_)
    
    
    )
  
  

step1 <- step0 %>% 
  dplyr::filter(visit == 1) %>% 
  mutate(baseline_dm = case_when(!is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 1,
                                 # We need to add this in order to catch incident DM at Visit 1
                                 # Don't remove this
                                 # Else they will be excluded based on diab_evr if their incidence was 1 year before...
                                 !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 0,
                                 diab_evr == 1 ~ 1,
                                 TRUE ~ 0)) %>% 
  dplyr::filter(baseline_dm == 1)


step2 <- step0 %>% 
  dplyr::filter(!study_id %in% step1$study_id) %>% 
  mutate(visit1_newdm = case_when(visit > 1 ~ NA_real_,
                                  # !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0, --> not required
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3)%in% c(0,1) ~ 1,
                                  (diab_126_fast==1|diab_ind==1|diab_evr == 1) ~ 1,
                                  TRUE ~ 0),
         visit2_newdm = case_when(visit!=2~NA_real_,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 1,
                                  (diab_126_fast==1|diab_doc==1|diab_ind==1) ~ 1,
                                  TRUE~0),
         
         visit3_newdm = case_when(visit!=3~NA_real_,
                                  #Important to exclude individuals who will otherwise get diagnosed in between two waves but will not be captured
                                  # E.g. visit 2 = 52, visit 3 = 56, dmagediag = 54 --> should not count as newly diagnosed in either
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 1,
                                  (diab_126==1|diab_doc==1) ~ 1,
           TRUE~0),
         visit4_newdm = case_when(visit!=4~NA_real_,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 1,
                                  (diab_126==1|diab_doc==1|(glucosef >= 126 & !is.na(glucosef))|(glucose2h >= 200 & !is.na(glucose2h))) ~ 1,
           TRUE~0),
         visit5_newdm = case_when(visit!=5~NA_real_,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 1,
                                  (diab_126==1|diab_a1c65==1|diab_doc==1|(glucosef >= 126 & !is.na(glucosef))|(hba1c >= 6.5 & !is.na(hba1c))) ~ 1,
                                  TRUE~0),
         visit6_newdm = case_when(visit!=6~NA_real_,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) >=2 ~ 0,
                                  !is.na(dmagediag_V3) & (age - dmagediag_V3) %in% c(0,1) ~ 1,
                                  (diab_126==1|diab_a1c65==1|(glucosef >= 126 & !is.na(glucosef))) ~ 1,
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
    visit4_newdm == 1 ~ 4,
    visit5_newdm == 1 ~ 5,
    visit6_newdm == 1 ~ 6,
    TRUE ~ NA_real_))


aric_newdm = step2 %>% 
  dplyr::filter(visit == dmdiagvisit) %>% 
  mutate(dmagediag = case_when(age < dmagediag_V3 ~ age,
                               !is.na(dmagediag_V3) ~ dmagediag_V3,
                               TRUE ~ age))

aric_newdm %>% 
  dplyr::filter((age-dmagediag) <= 1) %>% 
  nrow()
aric_newdm %>% 
  dplyr::filter((age-dmagediag) > 1) %>% 
 View()

saveRDS(aric_newdm,paste0(path_endotypes_folder,"/working/cleaned/aric_newdm.RDS")) #this dataset has one obs per participant 
