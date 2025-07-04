rm(list=ls()); gc(); source(".Rprofile")

study_name = "ACCORD"
source("preprocessing/accpre01_baseline characteristics.R")
source("preprocessing/accpre02_biomarkers.R")

# N = 10,251
accord_dat_all <- baseline %>% 
  # dplyr::filter(dmduration <= duration_cutoff) %>%
  dplyr::select(-visit,-sbp,-dbp,-ldlc) %>% 
  right_join(biomarkers,
            by = "study_id") %>% 
  mutate(dmagediag = bsage - dmduration,
         # every 4 months
         age = bsage + StudyDays/365)

# path_accord_folder could be defined in .Rprofile
saveRDS(accord_dat_all,paste0(path_endotypes_folder,"/working/interim/accord_dat_all.RDS"))
