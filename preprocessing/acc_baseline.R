rm(list=ls()); gc(); source(".Rprofile")

study_name = "ACCORD"
source("preprocessing/accpre01_baseline characteristics.R")
source("preprocessing/accpre02_biomarkers.R")

accord <- baseline %>% 
  # dplyr::filter(dmduration <= duration_cutoff) %>%
  dplyr::select(-visit,-sbp,-dbp,-ldlc) %>% 
  left_join(biomarkers %>% 
              dplyr::filter(visit == "BLR"),
            by = "study_id") %>% 
  mutate(dmagediag = bsage - dmduration)

# path_accord_folder could be defined in .Rprofile
saveRDS(accord,paste0(path_endotypes_folder,"/working/cleaned/accord.RDS"))
