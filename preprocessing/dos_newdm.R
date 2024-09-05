rm(list=ls()); gc(); source(".Rprofile")

study_name = "DPPOS"
# source("preprocessing/dospre01_baseline demographics.R")
# source("preprocessing/dospre02_trial labs.R")
# source("preprocessing/dospre03_trial events.R")
# source("preprocessing/dospre04_trial anthro.R")


# Each 'release' contributed a row
demographic <- readRDS(paste0(path_endotypes_folder,"/working/interim/dospre01_demographic.RDS")) %>% 
  distinct(study_id,.keep_all=TRUE)

# There were some cases when the same 'lab_StudyDays' had multiple  values for the same parameter
lab <- readRDS(paste0(path_endotypes_folder,"/working/interim/dospre02_labs.RDS")) %>% 
  rename(lab_StudyDays = StudyDays) %>% 
  dplyr::select(-quarter,-semi,-quarter,-release,-visit) %>% 
  group_by(study_id,lab_StudyDays) %>% 
  summarize(across(everything(),~mean(.,na.rm=TRUE))) %>% 
  ungroup()

anthro <- readRDS(paste0(path_endotypes_folder,"/working/interim/dospre04_anthro.RDS")) %>% 
  rename(anthro_StudyDays = StudyDays) %>% 
  dplyr::select(-visit,-semi,-quarter,-visit) %>% 
  group_by(study_id,anthro_StudyDays) %>% 
  summarize(across(everything(),~mean(.,na.rm=TRUE))) %>% 
  ungroup()

confirmed_dm <- readRDS(paste0(path_endotypes_folder,"/working/interim/dospre03_events.RDS")) %>% 
  mutate(diagDays = round(diabt*365.25)) %>% 
  distinct(study_id,diagDays,diabf) %>% 
  group_by(study_id,diagDays) %>% 
  summarize(diabf = max(diabf),
            n = n()) %>% 
  ungroup() %>% 
  # There were some cases when diabf was both 0 and 1 --> checked a few against actual labs of glucosef and glucose2h 
  dplyr::select(-n) %>% 
  group_by(study_id) %>% 
  dplyr::filter(diabf == 1) %>% 
  dplyr::filter(diagDays == min(diagDays)) %>% 
  ungroup() 


anthro_vars <- c("sbp","dbp","weight","height","wc","hc","triceps","iliac","abdominal","medial","bmi","preg")
# "urinecreatinine",
lab_vars <- c("hba1c","insulinf","glucosef","glucose2h","vldlc","tgl","hdlc","ldlc",
              "serumcreatinine", "ast","alt")


lab_matched <- map_dfr(lab_vars,
                       function(v){
                         merged <- lab %>% 
                           dplyr::select(study_id,lab_StudyDays,one_of(v)) %>% 
                           rename_at(vars(one_of(v)),~"variable") %>% 
                           left_join(confirmed_dm,
                                     by = "study_id") %>% 
                           # dplyr::mutate(diffDays = round(diagDays - StudyDays)) %>% 
                           dplyr::mutate(diffDays = round(lab_StudyDays - diagDays)) %>% 
                           dplyr::filter(!is.na(diffDays)) %>% 
                           dplyr::filter(!is.na(variable),diffDays %in% c(0:365)) %>% 
                           group_by(study_id) %>% 
                           dplyr::filter(diffDays == min(diffDays))  %>% 
                           ungroup() %>% 
                           dplyr::select(study_id,diagDays,lab_StudyDays,variable) %>% 
                           pivot_longer(cols=one_of(c("lab_StudyDays","variable")),
                                        names_to="var_name",values_to="values") %>% 
                           mutate(var_name = case_when(var_name == "lab_StudyDays" ~ paste0(v,"_days"),
                                                       TRUE ~ v)) %>% 
                           mutate(values = as.numeric(values))
                         
                         return(merged)
                         
                         
                       }) %>% 
  distinct(var_name,diagDays,study_id,.keep_all=TRUE) %>% 
  pivot_wider(names_from=var_name,values_from=values)

anthro_matched <- map_dfr(anthro_vars,
                          function(v){
                            merged <- anthro %>% 
                              dplyr::select(study_id,anthro_StudyDays,one_of(v)) %>% 
                              rename_at(vars(one_of(v)),~"variable") %>% 
                              left_join(confirmed_dm,
                                        by = "study_id") %>% 
                              # dplyr::mutate(diffDays = round(diagDays - StudyDays)) %>% 
                              dplyr::mutate(diffDays = round(anthro_StudyDays - diagDays)) %>% 
                              dplyr::filter(!is.na(variable),diffDays %in% c(0:365)) %>% 
                              group_by(study_id) %>% 
                              dplyr::filter(diffDays == min(diffDays)) %>% 
                              ungroup() %>% 
                              dplyr::select(study_id,diagDays,anthro_StudyDays,variable) %>% 
                              pivot_longer(cols=one_of(c("StudyDays","variable")),
                                           names_to="var_name",values_to="values") %>% 
                              mutate(var_name = case_when(var_name == "anthro_StudyDays" ~ paste0(v,"_days"),
                                                          TRUE ~ v))
                            
                            return(merged)
                            
                            
                          }) %>% 
  pivot_wider(names_from=var_name,values_from=values)


dos_newdm <- full_join(lab_matched,
                       anthro_matched,
                       by = c("study_id","diagDays")) %>% 
  left_join(demographic %>% distinct(study_id,.keep_all=TRUE),by="study_id") %>% 
  mutate(dmagediag = case_when(agegroup == 1 ~ 37 + diagDays/365, # Less than 40
                               agegroup == 2 ~ 42 + diagDays/365,
                               agegroup == 3 ~ 47 + diagDays/365,
                               agegroup == 4 ~ 52 + diagDays/365,
                               agegroup == 5 ~ 57 + diagDays/365,
                               agegroup == 6 ~ 62 + diagDays/365,
                               agegroup == 7 ~ 67 + diagDays/365)) %>% 
  distinct(study_id,diagDays,.keep_all=TRUE)

confirmed_dm %>% 
  anti_join(dos_newdm,
            by="study_id") %>% View() #619 cases

saveRDS(dos_newdm,paste0(path_endotypes_folder,"/working/cleaned/dos_newdm.RDS"))
