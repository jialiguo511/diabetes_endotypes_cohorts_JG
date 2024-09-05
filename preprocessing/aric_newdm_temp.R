
############ create diabetes variables ################ 

# visit 1 diabetes - establish the baseline 
aric_new<-aric_analysis%>% 
  mutate(diab_126_fast = case_when(
    diab_126_fast=="1"|diab_126_fast=="T"~1,
    diab_126_fast=="0"~0,
    TRUE ~ NA_real_),
    diab_evr = case_when(
      diab_evr=="Y"~1,
      diab_evr=="N"~0,
      TRUE ~ NA_real_),
    diab_v1 = case_when(
      (visit==1)&(diab_126_fast==1|diab_evr==1|diab_ind==1)~1,
      TRUE~0)
  )

#table(aric_new$diab_v1)


# Identify participants with baseline diabetes
baseline_ids_row <- which(aric_new$visit == 1 & aric_new$diab_v1 == 1)
baseline_ids <-aric_new$study_id[baseline_ids_row] # n = 1838 with baseline DM


# Mark all occurrences of these participants in all visits
aric_new$baseline_diabetes <- ifelse(aric_new$study_id %in% baseline_ids, 1, 0)
table(aric_new$baseline_diabetes)

# Identify participants with first age of DX (dmagediag variable in V3 only)

aric_new <- aric_new %>%
  group_by(study_id) %>%
  mutate(dmagediag = ifelse(visit %in% c(1, 2) & is.na(dmagediag), dmagediag[visit == 3], dmagediag)) %>%
  ungroup()

aric_new$age_diff <-aric_new$age-aric_new$dmagediag 

table(aric_new$age_diff >= 0 & aric_new$age_diff <= 1)

rows_with_correct_age_diff_v1 <- which(aric_new$age_diff >= 0 & aric_new$age_diff <= 1 & aric_new$visit == 1)

selected_ids_v1 <- aric_new$study_id[rows_with_correct_age_diff_v1]
selected_ids_v1 # N = 147 participants in V1 meets the criteria

rows_with_correct_age_diff_v2 <- which(aric_new$age_diff >= 0 & aric_new$age_diff <= 1 & aric_new$visit == 2)
selected_ids_v2 <- aric_new$study_id[rows_with_correct_age_diff_v2]
selected_ids_v2 # 188 participant in V2 meets the criteria

rows_with_correct_age_diff_v3 <- which(aric_new$age_diff >= 0 & aric_new$age_diff <= 1 & aric_new$visit == 3)
selected_ids_v3 <- aric_new$study_id[rows_with_correct_age_diff_v3]
summary(selected_ids_v3)# 194 participant in V3 meet the criteria



#### for participants not in seleted_ids_v1 but in baseline_ids, they should be removed 

baseline_ids <- setdiff(baseline_ids, selected_ids_v1)

#### for participants in the selected_ids_v1, they should be kept in the final dataset 

#### Now, new DM in V2 
#Need to modify:1)dmagediag = age if new DM; 2)create a diab_new_vx variable


aric_new <-aric_new %>% 
  mutate(
    diab_doc = case_when(
      diab_doc=="Y"~1,
      diab_doc=="N"~0, #there are other letters with unknown meanings in v3,v4 and v5,code to NA for now 
      TRUE ~ NA_real_),
    diab_new_v2 = case_when(
      (visit==2)&(diab_126_fast==1|diab_doc==1|diab_ind==1)&baseline_diabetes==0 ~ 1,
      visit!=2~NA_real_,
      TRUE~0),
    dmagediag = case_when(
      diab_new_v2 == 1 ~ age,
      visit == 2 & diab_new_v2 != 1 ~ NA_real_, 
      TRUE ~ dmagediag  # Preserve original values for other conditions
    ))

table(aric_new$diab_new_v2) # 762 with new DM 

# extract participant IDs with new DM in v2 
newdm_v2_rows <- which(aric_new$diab_new_v2==1)
newdm_v2_ids <-aric_new$study_id[newdm_v2_rows]


#### Now, new DM in V3 
#Need to modify:1)dmagediag = age if new DM; 2)create a diab_new_vx variable 

aric_new<-aric_new%>% 
  mutate(diab_126 = case_when(
    diab_126=="1"|diab_126=="T"~1,
    diab_126=="0"~0,
    TRUE ~ NA_real_),
    diab_140 = case_when(
      diab_140=="1"|diab_140=="T"~1,
      diab_140=="0"~0,
      TRUE ~ NA_real_),
    diab_med_2w = case_when(
      diab_med_2w=="Y"~1,
      diab_med_2w=="N"~0,
      TRUE ~ NA_real_),
    diab_new_v3 = case_when(
      (visit==3)&(diab_126==1|diab_doc==1)&baseline_diabetes==0 ~ 1,
      visit!=3~NA_real_,
      TRUE~0),
    dmagediag = case_when(
      diab_new_v3 == 1 ~ age,
      visit == 3 & diab_new_v3 != 1 ~ NA_real_, 
      TRUE ~ dmagediag  # Preserve original values for other conditions
    ))

table(aric_new$diab_new_v3) # 842 with new DM 

newdm_v3_rows <- which(aric_new$diab_new_v3==1)
newdm_v3_ids <-aric_new$study_id[newdm_v3_rows]


#### Now, new DM in V4 
#Need to modify:1)dmagediag = age if new DM; 2)create a diab_new_vx variable 

aric_new<-aric_new%>% 
  mutate(diab_trt= case_when(
    diab_trt == "Y"~1,
    diab_trt=="N"~0,
    TRUE ~ NA_real_),
    diab_med_any = case_when(
      diab_med_any=="Y"~1,
      diab_med_any=="N"~0,
      TRUE ~ NA_real_),
    diab_new_v4 = case_when(
      (visit==4)&(diab_126==1|diab_doc==1|(glucosef >= 126 & !is.na(glucosef))|(glucose2h >= 200 & !is.na(glucose2h)))&baseline_diabetes==0 ~ 1,
      visit!=4~NA_real_,
      TRUE~0),
    dmagediag = case_when(
      diab_new_v4 == 1 ~ age,
      visit == 4 & diab_new_v4 != 1 ~ NA_real_, 
      TRUE ~ dmagediag  # Preserve original values for other conditions
    ))

summary(v4_new)

table(aric_new$diab_new_v4) # 1581 with new DM 

newdm_v4_rows <- which(aric_new$diab_new_v4==1)
newdm_v4_ids <-aric_new$study_id[newdm_v4_rows]


#### Now, new DM in V5 
#Need to modify:1)dmagediag = age if new DM; 2)create a diab_new_vx variable 

summary(v5_new)
aric_new<-aric_new%>% 
  mutate(diab_a1c65= case_when(
    diab_a1c65 == "1"|diab_a1c65 =="T"~1,
    diab_a1c65=="0"~0,
    TRUE ~ NA_real_),
    diab_med_4w= case_when(
      diab_med_4w == "1"|diab_med_4w =="T"~1,
      diab_med_4w=="0"~0,
      TRUE ~ NA_real_),
    diab_new_v5 = case_when(
      (visit==5)&(diab_126==1|diab_a1c65==1|diab_doc==1|(glucosef >= 126 & !is.na(glucosef))|(hba1c >= 6.5 & !is.na(hba1c)))&baseline_diabetes==0 ~ 1,
      visit!=5~NA_real_,
      TRUE~0),
    dmagediag = case_when(
      diab_new_v5 == 1 ~ age,
      visit == 5 & diab_new_v5 != 1 ~ NA_real_, 
      TRUE ~ dmagediag  # Preserve original values for other conditions
    ))

table(aric_new$diab_new_v5) # 1897 with new DM 

newdm_v5_rows <- which(aric_new$diab_new_v5==1)
newdm_v5_ids <-aric_new$study_id[newdm_v5_rows]

#### Now, new DM in V6 
#Need to modify:1)dmagediag = age if new DM; 2)create a diab_new_vx variable 
summary(v6_new)
aric_new<-aric_new%>% 
  mutate(diab_new_v6 = case_when(
    (visit==6)&(diab_126==1|diab_a1c65==1|(glucosef >= 126 & !is.na(glucosef)))&baseline_diabetes==0 ~ 1,
    visit!=6~NA_real_,
    TRUE~0),
    dmagediag = case_when(
      diab_new_v6 == 1 ~ age,
      visit == 6 & diab_new_v6 != 1 ~ NA_real_, 
      TRUE ~ dmagediag  # Preserve original values for other conditions
    ))

table(aric_new$diab_new_v6) # 1300 with new DM 

newdm_v6_rows <- which(aric_new$diab_new_v6==1)
newdm_v6_ids <-aric_new$study_id[newdm_v6_rows]



#### extract all new DM cases into a new datasets, all new cases should be included in future visits too! 

## check ids from two sets of v2 and v3 ids with new dm 


intersect(selected_ids_v2, newdm_v2_ids)
newdm_v2_ids_c <- unique(c(selected_ids_v2, newdm_v2_ids))

intersect(selected_ids_v3, newdm_v3_ids)
newdm_v3_ids_c <- unique(c(selected_ids_v3, newdm_v3_ids))

## create a dataset with new dm cases from the visit at which the the patient was first diagnosed. 
newdm_v1 <- aric_new %>% 
  dplyr::filter(visit == 1 & study_id %in% selected_ids_v1)

newdm_v2 <- aric_new %>%
  dplyr::filter(visit == 2 & study_id %in% newdm_v2_ids_c) %>% 
  dplyr::filter(!study_id %in% selected_ids_v1)

id_s2 <- c(newdm_v2_ids_c,selected_ids_v1)

newdm_v3 <- aric_new %>%
  dplyr::filter(visit == 3 & study_id %in% newdm_v3_ids_c)%>%
  dplyr::filter(!study_id %in% id_s2)

id_s3 <-c(id_s2,newdm_v3_ids_c) #ids from previous visits should be removed from next visits

newdm_v4 <- aric_new %>%
  dplyr::filter(visit == 4 & study_id %in% newdm_v4_ids)%>%
  dplyr::filter(!study_id %in% id_s3)

id_s4 <-c(id_s3,newdm_v4_ids)

newdm_v5 <- aric_new %>%
  dplyr::filter(visit == 5 & study_id %in% newdm_v5_ids)%>%
  dplyr::filter(!study_id %in% id_s4)

newdm_v5 <- distinct(newdm_v5) #three duplicates removed. 

id_s5 <-c(id_s4,newdm_v5_ids)

newdm_v6 <- aric_new %>%
  dplyr::filter(visit == 6 & study_id %in% newdm_v6_ids)%>%
  dplyr::filter(!study_id %in% id_s5)

id_s6 <-c(id_s5,newdm_v6_ids)

dat_newdm <- bind_rows(newdm_v1,newdm_v2,newdm_v3,newdm_v4,newdm_v5,newdm_v6) #n=3802 --> 4060 new dm cases, use this for analysis, it contains just the visits at which new dm is identified. 

combined_ids <- Reduce(union, list(selected_ids_v1, newdm_v2_ids_c, newdm_v3_ids_c,newdm_v4_ids,newdm_v5_ids,newdm_v6_ids)) #n=3802 --> 4060 new dm cases 

aric_new_dm <- aric_new[aric_new$study_id %in% combined_ids, ]#this contains all visits for new DM cases 


#### From V2 to V6, calculate "dmduration" by subtracting "dmagediag" from "age" at the visit 

library(tidyr)

aric_new_dm_all_visits <- aric_new_dm %>%
  group_by(study_id) %>%
  fill(dmagediag,female,race,edu1,edu2,year_enrolled, .direction = "downup") %>%
  ungroup()%>% 
  mutate(dmduration=age-dmagediag) # 3.18.24, need to keep only one record/participant

#un-comment when all visits are needed
#saveRDS(aric_new_dm_all_visits,paste0(path_endotypes_folder,"/working/cleaned/aric_new_dm_all_visits.RDS"))

saveRDS(dat_newdm,paste0(path_endotypes_folder,"/working/cleaned/aric_newdm.RDS")) #this dataset has one obs per participant 