# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the mesa cohort
# final dataset should be named as cardia_newdm.rds

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/mesa_e1_e5.R")

#### workflow for cohorts: ARIC, JHS, MESA and CARDIA ### 
# step 0: if age at diagnosis [dmagediag] is known, we will use the minimal dmagediag as the dmagediag for ALL participants for all visits
# step 1: Identify baseline DM cases in VISIT #1: These participants will be categorized as existing DM and will be removed from the dataset.
## 1) [dmduration] = [age]-[dmagediag] >=2 --> baseline DM = 1 
## 2) self report DM = 1 & [dmduration] !=0 or 1 --> baseline DM = 1 
## 3) other conditions --> baseline DM = 0 
# step 2: in VISIT#1 to last VISIT: identify new DMs by [dmduration], self-reported DM, and lab cutoffs
## 1) [dmduration] = [age]-[dmagediag] >=2 --> new_dm = 0 
## 2) [dmduration] = [age]-[dmagediag] = 1 --> new_dm = 1 
## 3) self reported DM = 1 --> new_dm =1 
## 4) meeting lab cutoffs --> new_dm = 1 

# run this after connection is fixed. 
#step0 <- readRDS(paste0(path_endotypes_folder,"/working/interim/mesa_dat_all.RDS"))

dat_all <- bind_rows(e1_dat,
                       e2_dat,
                       e3_dat,
                       e4_dat,
                       e5_dat)

summary(dat_all)

step0 <- dat_all %>% 
  
  





