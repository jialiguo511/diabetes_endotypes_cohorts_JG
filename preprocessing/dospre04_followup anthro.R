vl_column1 = "f01"
vl_column2 = "f02"

# DPP data DEMOGRAPHIC inludes one record for each participant in the released database. 
# Data in this file is identical to the BASELINE data included in the DPP Full Scale data release, 
# but includes only those participants with consent for the bridge data release, and contains the following variables

data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Form_Based")

# DPP data ------

data_path_dpp <- paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Form_Data/Data")
s03 <- data_extract(study_name,"s03",data_path_dpp) %>% 
  dplyr::select(-visit) %>% 
  mutate(height = rowMeans(.[,c("bshght1","bshght2","bshght3")],na.rm = TRUE))

# Bridge -------
# o INT: Interim (unscheduled) visits.
# o CON: Confirmation visits to confirm or not-confirm diabetes status; usually completed within 6 weeks of the trigger visit.
# o POV: Primary outcome visits completed after glucose confirmation. Note: Data collected at primary outcome visits included all data that were not collected at the visit where the participant’s glucose was first elevated (trigger visit).
# o WOV: washout visits (washout data only)
# o WCV: washout confirmation visits (washout data only)


bridge <- bind_rows(data_extract(study_name,vl_column1,data_path1),
                    data_extract(study_name,vl_column2,data_path1))  %>% 
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

phase1 <- bind_rows(data_extract(study_name,vl_column1,data_path2),
                    data_extract(study_name,vl_column2,data_path2))  %>% 
  mutate(semi = case_when(str_detect(visit,"(A|M)") ~ floor(StudyDays/182.625),
                          visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                          TRUE ~ NA_real_),
         quarter = semi*2)

phase2 <- bind_rows(data_extract(study_name,vl_column1,data_path3),
                    data_extract(study_name,vl_column2,data_path3))  %>% 
  mutate(semi = case_when(str_detect(visit,"(A|M)") ~ floor(StudyDays/182.625),
                          visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                          TRUE ~ NA_real_),
         quarter = semi*2)

anthro <- bind_rows(bridge,
                    phase1,
                    phase2) %>% 
  mutate(sbp = rowMeans(.[,c("sbp1","sbp2")],na.rm = TRUE),
         dbp = rowMeans(.[,c("dbp1","dbp2")],na.rm = TRUE),
         weight = rowMeans(.[,c("wght1","wght2","wght3")],na.rm = TRUE),
         wc = rowMeans(.[,c("wstc1","wstc2","wstc3")],na.rm = TRUE),
         hc = rowMeans(.[,c("hip1","hip2","hip3")],na.rm = TRUE),
         # subscap = rowMeans(.[,c("sfb1","sfb2","sfb3")],na.rm = TRUE),
         triceps = rowMeans(.[,c("sftr1","sftr2","sftr3")],na.rm = TRUE),
         iliac = rowMeans(.[,c("sfsi1","sfsi2","sfsi3")],na.rm = TRUE),
         abdominal = rowMeans(.[,c("sfab1","sfab2","sfab3")],na.rm = TRUE),
         medial = rowMeans(.[,c("sfmc1","sfmc2","sfmc3")],na.rm = TRUE)
         ) %>% 
  left_join(s03 %>% dplyr::select(study_id,height),
            by = "study_id")  %>% 
  mutate(bmi = weight/(height/100)^2)
  
rm(bridge,phase1,phase2)



