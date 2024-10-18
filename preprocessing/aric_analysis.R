#The purpose of this file is to merge all six visits datasets for ARIC 
# the final merged dataset is named as aric_analysis 
# refer to the notes in "checking ARIC variables.R" to check details for each visit. 

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/aric_visits1_6_data.R")

library(dplyr)
#V1 

v1_all<- derive13 %>%
  full_join(anta, by = "study_id") %>%
  full_join(chma, by = "study_id") %>% 
  full_join(sbpa02, by = "study_id") %>% 
  full_join(hom, by = "study_id") %>% 
  full_join(lipa, by = "study_id") %>% 
  full_join(hmta, by = "study_id") 

v1_new<- v1_all %>%
  mutate(insulin_uuml = insulin_pmoll/6)%>%
  mutate(insulinf= case_when(
    fast_8 ==1 | fast_12 ==1  ~ insulin_uuml, # insulin conversion: 1 μIU/mL = 6.00 pmol/L
    TRUE ~ NA_real_
  ))%>% 
  mutate(glucosef = case_when( # identify fasting glucose 
    fast_8 ==1 | fast_12 ==1 ~ glucose_value,
    TRUE ~ NA_real_
    ))%>% 
  mutate(glucoser= case_when(
    fast_8 !=1 & fast_12 !=1 ~ glucose_value,
    TRUE ~ NA_real_
    ))%>% rowwise() %>%
  mutate(sbp=mean(c(sbp1, sbp2, sbp3), na.rm = TRUE),
           dbp=mean(c(dbp1, dbp2, dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.454, 
         visit =1, 
         med_chol_use = case_when(
           med_chol_2nd_4w ==1 | med_chol_2w == 1 ~ 1,
           TRUE ~ 0 
         ), 
         med_bp_use = case_when(
           med_bp_2w ==1 | sr_bp_2w == 1 ~ 1,
           TRUE ~ 0 
         ))%>% 
  mutate(mf_his = case_when(
    mf_his == "1"| mf_his =="T" ~1,
    mf_his == "0" ~ 0,
    TRUE ~ NA_real_
  ),
  drk_cur=case_when(
    drk_cur=="1"|drk_cur=="T"~1,
    drk_cur=="0"~0,
    TRUE~ NA_real_
  )) %>% 
  select(-insulin_pmoll,-insulin_uuml,-fast_8,-fast_12,-glucose_value,-med_chol_2nd_4w,
         -med_chol_2w,-sr_bp_2w,-med_bp_2w,-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)

v1_new_fill <- v1_new %>% select(study_id, female, race)

#V2

v2_all<- derive2_10 %>%
  full_join(hhxb, by = "study_id") %>%
  full_join(antb, by = "study_id") %>% 
  full_join(sbpb02, by = "study_id") %>% 
  full_join(chmb, by = "study_id") %>% 
  full_join(lipb, by = "study_id") %>% 
  full_join(hmtb, by = "study_id") 

v2_all$weight<-as.numeric(v2_all$weight)
v2_new <- v2_all %>% 
  mutate(glucosef = case_when(  
  fast_8 ==1 | fast_12 ==1 ~ glucose_value,
  TRUE ~ NA_real_), 
  glucoser= case_when(
    fast_8 !=1 & fast_12 !=1 ~ glucose_value,
    TRUE ~ NA_real_)
  )%>%
  rowwise() %>%
  mutate(sbp=mean(c(sbp1, sbp2, sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1, dbp2, dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.454, 
         visit =2, 
         med_chol_use = case_when(
           med_chol_2nd_4w ==1 | med_chol_2w == 1 ~ 1,
           TRUE ~ 0), 
         med_bp_use = case_when(
           med_bp_2w ==1 | sr_bp_2w == 1 ~ 1,
           TRUE ~ 0 
         ))%>% 
  mutate(drk_evr = case_when(
    drk_evr == "NA"| drk_evr=="N"~0,
    drk_evr == "Y" ~1,
    TRUE ~ NA_real_
  ),
  drk_cur = case_when(
    drk_cur=="Y"~1,
    drk_cur=="N"~0,
    TRUE ~ NA_real_
  ))%>%
  select(-glucose_value,-med_chol_2nd_4w,-fast_8,-fast_12,
         -med_chol_2w,-sr_bp_2w,-med_bp_2w,-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)

v2_new$wc<-as.numeric(v2_new$wc)
v2_new$totalc<-as.numeric(v2_new$totalc)
v2_new$tgl<-as.numeric(v2_new$tgl)


#V3 

v3_all<- derive37 %>%
  full_join(amha02, by = "study_id") %>%
  full_join(lipc04, by = "study_id") %>% 
  full_join(hemc31, by = "study_id") %>% 
  full_join(msrc04, by = "study_id") %>% 
  full_join(phxa04, by = "study_id") %>% 
  full_join(antc04, by = "study_id") %>%
  full_join(sbpc04_02, by = "study_id") %>%
  full_join(hmtcv301, by = "study_id")


v3_new <- v3_all %>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1, sbp2, sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1, dbp2, dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.454, 
         visit = 3, 
         med_chol_use = case_when(
           med_chol_2nd_4w ==1 | med_chol_2w == 1 ~ 1,
           TRUE ~ 0), 
         med_bp_use = case_when(
           med_bp_2w ==1 | sr_bp_2w == 1 ~ 1,
           TRUE ~ 0 
         ))%>% 
  mutate(glucosef = case_when(  
    fast_8 ==1 | fast_12 ==1 ~ glucose_value,
    TRUE ~ NA_real_), 
    glucoser= case_when(
      fast_8 !=1 & fast_12 !=1 ~ glucose_value,
      TRUE ~ NA_real_))%>%
  mutate(drk_evr = case_when(
    drk_evr =="N"~0,
    drk_evr =="Y"~1,
    TRUE ~ NA_real_),
    drk_cur = case_when(
      drk_cur =="N" | drk_cur == "0"~0,
      drk_cur =="Y"~1, 
      TRUE ~ NA_real_
    ))%>%
  select(-glucose_value,-fast_8,-fast_12,-med_chol_2nd_4w,
         -med_chol_2w,-sr_bp_2w,-med_bp_2w,-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3)

# add gender and race from v1 to v3 
v3_new <- v3_new %>%
  left_join(v1_new_fill, by = "study_id")


#V4 
v4_all<- derive47 %>%
  full_join(phxb04, by = "study_id") %>%
  full_join(antd05, by = "study_id") %>% 
  full_join(sbpd04_02, by = "study_id") %>% 
  full_join(hmtcv401, by = "study_id") %>% 
  full_join(lipd04, by = "study_id") %>% 
  full_join(gtsa04, by = "study_id") %>%
  full_join(msrd04, by = "study_id")


v4_new <- v4_all %>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1, sbp2), na.rm = TRUE),
         dbp=mean(c(dbp1, dbp2), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(weight = weight*0.454, 
         visit = 4,
         med_chol_use = case_when(
           med_chol_2nd_4w ==1 | med_chol_2w == 1 ~ 1,
           TRUE ~ 0), 
         med_bp_use = case_when(
           med_bp_2w ==1 | sr_bp_2w == 1 ~ 1,
           TRUE ~ 0 
         ))%>% 
  mutate(insulinf = case_when(  
    fast_8 ==1 | fast_12 ==1 ~ insulin_no_unit,
    TRUE ~ NA_real_), 
    drk_cur=case_when(
      drk_cur=="Y"~1,
      drk_cur=="N"~0,
      TRUE~NA_real_),
    drk_evr=case_when(
      drk_evr=="Y"~1,
      drk_evr=="N"~0,
      TRUE~NA_real_)
  )%>%
  select(-fast_8,-fast_12,-med_chol_2nd_4w,
         -med_chol_2w,-sr_bp_2w,-med_bp_2w,-sbp1,-sbp2,-dbp1,-dbp2,-insulin_no_unit)


#V5 

v5_all<- derive51 %>%
  full_join(status51, by = "study_id") %>%
  full_join(rex, by = "study_id") %>% 
  full_join(ant, by = "study_id") %>% 
  full_join(sbp, by = "study_id") %>% 
  full_join(cbc, by = "study_id") %>% 
  full_join(lip, by = "study_id") %>%
  full_join(chm, by = "study_id")

v5_new<- v5_all%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(insulinf = case_when(  
    fast_8 ==1 | fast_12 ==1 ~ insulin_uuml,
    TRUE ~ NA_real_), 
    visit = 5
  )%>%
  mutate(med_chol_use = case_when(
           med_chol_2nd_4w ==1 | med_chol_4w == 1 ~ 1,
           TRUE ~ 0), 
         med_bp_use = case_when(
           med_bp_4w ==1 | sr_bp_4w == 1 ~ 1,
           TRUE ~ 0 
         ))%>% 
  mutate(drk_cur=case_when(
    drk_cur=="0"~0,
    drk_cur=="T"|drk_cur=="1"~1,
    TRUE ~ NA_real_),
    drk_evr=case_when(
      drk_evr=="1"|drk_evr=="T"~1,
      drk_evr=="0"~0,
      TRUE ~ NA_real_
    ),
    mf_his = case_when(
      mf_his =="1"|mf_his=="T"~1,
      mf_his =="0"~0,
      TRUE ~ NA_real_)
    )%>% 
  select(-fast_8,-fast_12,-med_chol_2nd_4w,
         -med_chol_4w,-sr_bp_4w,-med_bp_4w,-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3,
         -insulin_uuml)

v5_new$smk_cur<-as.character(v5_new$smk_cur)

# add gender and race variables from v1 
v5_new <- v5_new %>%
  left_join(v1_new_fill, by = "study_id")

#V6 

v6_all<- derive61 %>%
  full_join(status61, by = "study_id") %>%
  full_join(lipf, by = "study_id") %>% 
  full_join(ant_v6, by = "study_id") %>% 
  full_join(sbp_v6, by = "study_id") %>% 
  full_join(chem2, by = "study_id") 


v6_new<-v6_all%>% 
  rowwise() %>%
  mutate(sbp=mean(c(sbp1,sbp2,sbp3), na.rm = TRUE),
         dbp=mean(c(dbp1,dbp2,dbp3), na.rm = TRUE))%>% 
  ungroup()%>% 
  mutate(glucosef = case_when(  
    fast_8 ==1 | fast_12 ==1 ~ glucose_value,
    glucose_value == NA ~ glucosef_si*18,
    TRUE ~ NA_real_), 
    visit = 6
  )%>%
  mutate(med_chol_use = case_when(
    med_chol_2nd_4w ==1 | med_chol_4w == 1 ~ 1,
    TRUE ~ 0), 
    med_bp_use = case_when(
      med_bp_4w ==1 | sr_bp_4w == 1 ~ 1,
      TRUE ~ 0 
    ),
    drk_cur = case_when(
      drk_cur=="1"|drk_cur=="T"~1,
      drk_cur=="0"~0, 
      TRUE ~ NA_real_
    ),
   drk_evr = case_when(
      drk_evr=="1"|drk_evr=="T"~1,
      drk_evr=="0"~0, 
      TRUE ~ NA_real_
    ))%>% 
  select(-fast_8,-fast_12,-med_chol_2nd_4w,
         -med_chol_4w,-sr_bp_4w,-med_bp_4w,-sbp1,-sbp2,-sbp3,-dbp1,-dbp2,-dbp3,
         -glucosef_si,-glucose_value)



# join six visit, long format 

aric_analysis<- bind_rows(v1_new,v2_new,v3_new,v4_new,v5_new,v6_new) # new cases are not yet identified in this dataset.

aric_analysis_filled <- aric_analysis %>% 
  group_by(study_id) %>% 
  arrange(study_id,visit) %>%
  fill(female,race, .direction = "downup")%>% 
  ungroup()

# fill missing values of race and race_rev and gender 
saveRDS(aric_analysis_filled,paste0(path_endotypes_folder,"/working/interim/aric_analysis.RDS"))
