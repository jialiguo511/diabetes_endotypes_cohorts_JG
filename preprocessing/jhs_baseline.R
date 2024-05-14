rm(list=ls()); gc(); source(".Rprofile")

study_name = "JHS"
source("preprocessing/jhspre01_analysis datasets from visits.R")

jhs <- jhs_analysis


saveRDS(jhs,paste0(path_endotypes_folder,"/working/cleaned/jhs.RDS"))

