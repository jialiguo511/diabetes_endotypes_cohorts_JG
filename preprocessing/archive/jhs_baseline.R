rm(list=ls()); gc(); source(".Rprofile")

study_name = "JHS"
source("preprocessing/jhspre01_analysis datasets from visits.R")

jhs <- jhs_analysis  %>% 
  mutate(dmduration = case_when(diabetes == 1 & !is.na(dmagediag) ~ age - dmagediag,
                                # Need to make sure that the below condition makes sense
                                # dmagediag might be missing because they forgot
                                # diabetes == 1 usually for someone with glucosef >= 126
                                (diabetes == 0 | is.na(dmagediag)) & (glucosef >= 126 | hba1c >=6.5) ~ 0,
                                TRUE ~ NA_real_
  ),
  dmagediag = case_when(dmduration == 0 ~ age, # Zhongyu added here
                        TRUE ~ dmagediag),
  race_eth = "NH Black",
  female = case_when(female == "Female" ~ 1,
                     female == "Male" ~ 0,
                     TRUE ~ NA_real_)) %>% 
  dplyr::filter(aric == 0)



saveRDS(jhs,paste0(path_endotypes_folder,"/working/cleaned/jhs.RDS"))

