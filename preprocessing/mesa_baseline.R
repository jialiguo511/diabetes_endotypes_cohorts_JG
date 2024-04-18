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
table(e1_dat$dia_med_kc)#should those people be treated as new DM? yes for now. 

newdm_e1 <- e1_dat %>%
  dplyr::filter(dia_ada == 2 | dia_ada == 3 | dia_sr == 1 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(dia_type_e1 != 1)
  
id_sel1 <- newdm_e1$study_id# n = 670 at E1. Add to this and use to remove unwanted visits from previous diagnosis, rename to year number after adding ids


### EXAM2 

newdm_e2 <- e2_dat %>%
  dplyr::filter(dia_ada == 2 | dia_ada == 3 | dia_urine == 1 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel1)

id_sel2<-c(id_sel1,newdm_e2$study_id) #n=390 new DM in exam2, total = 1060 


### EXAM3 

newdm_e3 <- e3_dat %>%
  dplyr::filter(dia_ada == 2 | dia_ada == 3 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel2)

id_sel3<-c(id_sel2,newdm_e3$study_id) #n=111 new DM in exam3, total = 1171


### EXAM4 

newdm_e4 <- e4_dat %>%
  dplyr::filter(dia_ada == 2 | dia_ada == 3 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel3)

id_sel4<-c(id_sel3,newdm_e4$study_id) #n=159 new DM in exam4, total = 1330


### EXAM5 

newdm_e5 <- e5_dat %>%
  dplyr::filter(dia_ada == 2 | dia_ada == 3 | dia_dx_lv ==1 | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel4)

id_sel5<-c(id_sel4,newdm_e5$study_id) #n=247 new DM in exam4, total = 1557

### merge all new DM cases 
newdm_dat <- bind_rows(newdm_e1,newdm_e2,newdm_e3,newdm_e4,newdm_e5)
## merge all exams 
all_dat <- bind_rows(e1_dat,e2_dat,e3_dat,e4_dat,e5_dat)

saveRDS(newdm_dat,paste0(path_endotypes_folder,"/working/cleaned/MESA_newdm.RDS"))

saveRDS(all_dat,paste0(path_endotypes_folder,"/working/cleaned/MESA_all.RDS"))






