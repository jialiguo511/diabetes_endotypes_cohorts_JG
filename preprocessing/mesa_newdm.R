#The purpose of this file is to merge all five exams for MESA 

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/mesa_e1_e5.R")


library(dplyr)

e1_dat$exam = 1 
e2_dat$exam = 2 
e3_dat$exam = 3 
e4_dat$exam = 4 
e5_dat$exam = 5 

############# To identify new diabetes ######### 

### EXAM1 
#diab medication not used in diagnosis due to unclear "0" and "NA" for not using or not having diabetes and therefore not using.
#diab medication should NOT be used as a criteria for new DM. 
#Exam1 DM will be removed from the merged new DM dataset 


newdm_e1 <- e1_dat %>%
  dplyr::filter(dia_ada == 2 | dia_sr == 1 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(dia_type_e1 != 1) #remove type I DM.
  
id_sel1 <- newdm_e1$study_id# n = 655 at E1. Add to this and use to remove unwanted visits from previous diagnosis, rename to year number after adding ids


### EXAM2 

newdm_e2 <- e2_dat %>%
  dplyr::filter(dia_ada == 2 | dia_urine == 1 | (glucosef >= 126 & !is.na(glucosef)) | (hba1c >= 6.5 & !is.na(hba1c))) %>%
  dplyr::filter(!study_id %in% id_sel1)

id_sel2<-c(id_sel1,newdm_e2$study_id) #n=457 new DM in exam2, total = 1112 


### EXAM3 

newdm_e3 <- e3_dat %>%
  dplyr::filter(dia_ada == 2 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel2)

id_sel3<-c(id_sel2,newdm_e3$study_id) #n=47 new DM in exam3, total = 1159


### EXAM4 
newdm_e4 <- e4_dat %>%
  dplyr::filter(dia_ada == 2 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel3)

id_sel4<-c(id_sel3,newdm_e4$study_id) #n=75 new DM in exam4, total = 1234


### EXAM5 
newdm_e5 <- e5_dat %>%
  dplyr::filter(dia_ada == 2 | dia_dx_lv ==1 | (glucosef >= 126 & !is.na(glucosef))| (hba1c >= 6.5 & !is.na(hba1c))) %>%
  dplyr::filter(!study_id %in% id_sel4)

id_sel5<-c(id_sel4,newdm_e5$study_id) #n=322 new DM in exam4, total = 1556

### merge all new DM cases 
newdm_dat <- bind_rows(newdm_e2,newdm_e3,newdm_e4,newdm_e5) #exam1 is the baseline, not included. 

## merge all exams 
all_dat <- bind_rows(e1_dat,e2_dat,e3_dat,e4_dat,e5_dat)

saveRDS(newdm_dat,paste0(path_endotypes_folder,"/working/cleaned/mesa_newdm.RDS"))

#un-commment when all vists are needed
# saveRDS(all_dat,paste0(path_endotypes_folder,"/working/cleaned/MESA_all.RDS"))






