rm(list=ls()); gc(); source(".Rprofile")

study_name = "Look AHEAD"
source("preprocessing/lapre01_baseline variables.R")
source("preprocessing/lapre02_laboratory measures.R")
source("preprocessing/lapre03_physical measures.R")

la_baseline <- baseline %>% 
  # dplyr::filter(dmduration <= duration_cutoff) %>% 
  left_join(laboratory,
            by="study_id") %>% 
  left_join(physical,
            by = "study_id") %>% 
  mutate(dmagediag = bsage - dmduration)


saveRDS(la_baseline,paste0(path_endotypes_folder,"/working/cleaned/la_baseline.RDS"))
