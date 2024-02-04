rm(list=ls()); gc(); source(".Rprofile")

study_name = "JHS"
source("preprocessing/jhspre01_analysis datasets from visits.R")

#### Existing file, do not rerun ####
jhs <- jhs_analysis

# recreate, use new name to compare 
jhs_zl<- jhs_analysis

saveRDS(jhs_zl,paste0(path_endotypes_folder,"/working/cleaned/jhs_zl.RDS"))
