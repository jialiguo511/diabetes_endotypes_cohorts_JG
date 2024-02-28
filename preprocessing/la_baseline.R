rm(list=ls()); gc(); source(".Rprofile")

study_name = "Look AHEAD"
source("preprocessing/lapre01_baseline variables.R")
source("preprocessing/lapre02_laboratory measures.R")
source("preprocessing/lapre03_physical measures.R")

look_ahead <- baseline %>% 
  # dplyr::filter(dmduration <= duration_cutoff) %>% 
  left_join(laboratory,
            by="study_id") %>% 
  left_join(physical,
            by = "study_id") %>% 
  mutate(dmagediag = bsage - dmduration)


### compare with the cleaned dataset created by JV 

look_ahead_zl <- look_ahead
look_ahead_jv <- readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS"))

colnames(look_ahead_jv)
colnames(look_ahead_zl)
library(compare)
compare(look_ahead_zl,look_ahead_jv) #two data sets appear to be identical. 

saveRDS(look_ahead_zl,paste0(path_endotypes_folder,"/working/cleaned/look_ahead_zl.RDS"))


saveRDS(look_ahead,paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS"))
# look_ahead <- readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS"))
