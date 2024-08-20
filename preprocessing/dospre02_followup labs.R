
vl_column = "lab"

# DPP data DEMOGRAPHIC inludes one record for each participant in the released database. 
# Data in this file is identical to the BASELINE data included in the DPP Full Scale data release, 
# but includes only those participants with consent for the bridge data release, and contains the following variables

data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Non_Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Non_Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Non_Form_Based")


# o INT: Interim (unscheduled) visits.
# o CON: Confirmation visits to confirm or not-confirm diabetes status; usually completed within 6 weeks of the trigger visit.
# o POV: Primary outcome visits completed after glucose confirmation. Note: Data collected at primary outcome visits included all data that were not collected at the visit where the participant’s glucose was first elevated (trigger visit).
# o WOV: washout visits (washout data only)
# o WCV: washout confirmation visits (washout data only)

bridge <- data_extract(study_name,vl_column,data_path1) %>% 
  mutate(quarter = case_when(visit %in% c("SCR","BAS") ~ 0,
                             visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                             str_detect(visit,"M") ~ str_replace(visit,"M","") %>% as.numeric(.)/3,
                             str_detect(visit,"Y") ~ str_replace(visit, "Y","") %>% as.numeric(.)*4,
                             TRUE ~ NA_real_
                             ),
         semi = quarter/2)
  
# Visit coding changed from DPP to DPPOS. 
# During DPP visits were coded based on the time from randomization as M03, M06, M09, Y01, M15, etc. 
# During DPPOS however, visits were coded as Annual (corresponding to the approximate month and day of randomization) 
# or Mid-year during each calendar year of DPPOS allowing for a 2-month window around each visit. 
# Thus visits occurred at the following time ranges:
phase1 <- data_extract(study_name,vl_column,data_path2,df_name = "laboratory") %>% 
  mutate(semi = case_when(str_detect(visit,"(A|M)") ~ floor(StudyDays/182.625),
                          visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                          TRUE ~ NA_real_),
         quarter = semi*2)
phase2 <- data_extract(study_name,vl_column,data_path3)   %>% 
  mutate(semi = case_when(str_detect(visit,"(A|M)") ~ floor(StudyDays/182.625),
                          visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                          TRUE ~ NA_real_),
         quarter = semi*2)

lab <- bind_rows(bridge %>% mutate(release = "BRIDGE"),
                         phase1 %>% mutate(release = "PHASE 1"),
                         phase2 %>% mutate(release = "PHASE 2"))

saveRDS(lab,paste0(path_endotypes_folder,"/working/interim/dospre02_labs.RDS"))


rm(bridge,phase1,phase2)
