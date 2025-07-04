rm(list=ls()); gc(); source(".Rprofile")

study_name = "Look AHEAD"
source("preprocessing/lapre01_baseline variables.R")
source("preprocessing/lapre02_laboratory measures.R")
source("preprocessing/lapre03_physical measures.R")

measurements <- laboratory_long %>% 
  left_join(physical_long,
            by=c("study_id","visit")) 

la_dat_all <- baseline %>% 
  # dplyr::filter(dmduration <= duration_cutoff) %>% 
  right_join(measurements,
            by="study_id") %>% 
  mutate(dmagediag = bsage - dmduration) %>% 
  # every 1y, then every 2y
  mutate(StudyMonths = case_when(
    visit == "Baseline" ~ 0,
    visit == "FV12" ~ 12,
    visit == "FV24" ~ 24,
    visit == "FV36" ~ 36,
    visit == "FV48" ~ 48,
    visit == "FV72" ~ 72,
    visit == "FV96" ~ 96,
    visit == "FV120" ~ 120,
    TRUE ~ NA_real_
  )) %>% 
  mutate(age = bsage + StudyMonths/12)

saveRDS(la_dat_all,paste0(path_endotypes_folder,"/working/interim/la_dat_all.RDS"))
