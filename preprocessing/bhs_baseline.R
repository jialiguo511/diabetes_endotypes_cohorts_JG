# The purpose of this file is to create baseline data for the BHS data
# created by Zhongyu, March 2024 


rm(list=ls()); gc(); source(".Rprofile")

names(z510rev3)



## check units
summary(z510rev3)
#cholestrol,ldlc,hdlc,and vldlv, and tgl appear to be mg/dl
#fasting insulin appears to be in uu/ml 
#urine albumin, unit appears to be  mg/g 
#urine creatinine, unit appears to be mmol/L or mg/g
#serum creatinine, unit appears to be mg/dl 

table(z510rev3$fasting)
summary(z510rev3$glucose) 

source("preprocessing/bhs_adult.R")
bhs<-z510rev3 %>% 
  mutate(glucosef = case_when(
    fasting == 3 ~ glucose,
    TRUE ~ NA_real_), 
    med_bp_use = recode(med_bp_use, `3` = 1, `1` = 0, .default = NA_real_),
    female = recode(female, `2` = 1, `1` = 0, .default = NA_real_),
    diab_126 = case_when(
      glucosef >=126 ~1,
      TRUE ~ 0 
    ))%>% select(-glucose,-fasting)

saveRDS(bhs,paste0(path_endotypes_folder,"/working/cleaned/bhs_baseline.RDS"))

  
  