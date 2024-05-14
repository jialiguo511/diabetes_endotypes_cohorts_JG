rm(list=ls()); gc(); source(".Rprofile")

study_name = "DPP"
source("preprocessing/dpppre01_baseline demographics.R")
source("preprocessing/dpppre02_trial labs.R")
source("preprocessing/dpppre03_trial events.R")
source("preprocessing/dpppre04_trial anthro.R")


confirmed_dm <- events %>% 
  dplyr::filter(diabf == 1) %>% 
  distinct(study_id,diabt) %>% 
  group_by(study_id) %>% 
  dplyr::filter(diabt == min(diabt)) %>% 
  ungroup() %>% 
  mutate(diagDays = diabt*365.25) %>% 
  dplyr::select(-diabt) 


anthro_vars <- c("sbp","dbp","weight","height","wc","hc","triceps","iliac","abdominal","medial","bmi","preg")
lab_vars <- c("hba1c","insulinf","glucosef","glucose2h","vldlc","tgl","hdlc","ldlc",
              "serumcreatinine", "urinecreatinine","ast","alt")


lab_matched <- map_dfr(lab_vars,
                       function(v){
                         merged <- lab %>% 
                           dplyr::select(study_id,StudyDays,one_of(v)) %>% 
                           rename_at(vars(one_of(v)),~"variable") %>% 
                           left_join(confirmed_dm,
                                     by = "study_id") %>% 
                           dplyr::mutate(diffDays = round(diagDays - StudyDays)) %>% 
                           dplyr::filter(!is.na(diffDays)) %>% 
                           dplyr::filter(!is.na(variable),diffDays %in% c(0:365)) %>% 
                           group_by(study_id) %>% 
                           dplyr::filter(diffDays == min(diffDays))  %>% 
                           ungroup() %>% 
                           dplyr::select(study_id,diagDays,StudyDays,variable) %>% 
                           pivot_longer(cols=one_of(c("StudyDays","variable")),
                                        names_to="var_name",values_to="values") %>% 
                           mutate(var_name = case_when(var_name == "StudyDays" ~ paste0(v,"_days"),
                                                       TRUE ~ v)) %>% 
                           mutate(values = as.numeric(values))
                         
                         return(merged)
                         
                         
                       }) %>% 
  distinct(var_name,diagDays,study_id,.keep_all=TRUE) %>% 
  pivot_wider(names_from=var_name,values_from=values)

anthro_matched <- map_dfr(anthro_vars,
                          function(v){
                            merged <- anthro %>% 
                              dplyr::select(study_id,StudyDays,one_of(v)) %>% 
                              rename_at(vars(one_of(v)),~"variable") %>% 
                              left_join(confirmed_dm,
                                        by = "study_id") %>% 
                              dplyr::mutate(diffDays = round(diagDays - StudyDays)) %>% 
                              dplyr::filter(!is.na(variable),diffDays %in% c(0:365)) %>% 
                              group_by(study_id) %>% 
                              dplyr::filter(diffDays == min(diffDays)) %>% 
                              ungroup() %>% 
                              dplyr::select(study_id,diagDays,StudyDays,variable) %>% 
                              pivot_longer(cols=one_of(c("StudyDays","variable")),
                                           names_to="var_name",values_to="values") %>% 
                              mutate(var_name = case_when(var_name == "StudyDays" ~ paste0(v,"_days"),
                                                          TRUE ~ v))
                            
                            return(merged)
                            
                            
                          }) %>% 
  pivot_wider(names_from=var_name,values_from=values)


dpp <- full_join(lab_matched,
                   anthro_matched,
                   by = c("study_id","diagDays")) %>% 
  left_join(demographic %>% distinct(study_id,.keep_all=TRUE),by="study_id") %>% 
  mutate(dmagediag = case_when(agegroup == 1 ~ 37 + diagDays/365, # Less than 40
                               agegroup == 2 ~ 42 + diagDays/365,
                               agegroup == 3 ~ 47 + diagDays/365,
                               agegroup == 4 ~ 52 + diagDays/365,
                               agegroup == 5 ~ 57 + diagDays/365,
                               agegroup == 6 ~ 62 + diagDays/365,
                               agegroup == 7 ~ 67 + diagDays/365))
  
saveRDS(dpp,paste0(path_endotypes_folder,"/working/cleaned/dpp.RDS"))
