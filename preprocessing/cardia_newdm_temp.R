#The purpose of this file is to merge all nine exams for CARDIA 

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/cardia_y0_y30.R")

############# To identify new diabetes ######### 
names(dat_all)
### criteria and variables: dmagediag, diab_st, diab_ind, glucosef(>=126) OR hba1c(>=6.5)

table(dat_all$diab_st) # not sure about its coding, not used. 
table(dat_all$diab_ind) # confirmed coding: 1 = no diabetes, 2 = diabetes, 8 = unknown (recode to NA)

### select new DM from each visit
#### this method will include participants with the visit at which they are diagnosed and not any other visits 

## Year 0, baseline

summary(dat_y0)
newdm_y0 <- dat_y0%>% 
  dplyr::filter(glucosef>=126&!is.na(glucosef)) #random glucose should NOT be used; age of diagnosis all missing, not used, baseline diabetes will therefore be removed from final dataset. 

id_sel0 <- newdm_y0$study_id # n = 28 at baseline, add to this and use to remove unwanted visits from previous diagnosis, rename to year number after adding ids

## Year 2, based on the diab_ind = 2 

summary(dat_y2)
table(dat_y2$diab_ind)
newdm_y2 <-dat_y2%>%
  dplyr::filter(diab_ind==2&(!study_id %in% id_sel0)) # diagnosis age not used because all missing 

newdm_y2<- newdm_y2[!duplicated(newdm_y2$study_id),]

id_sel2<-c(id_sel0,newdm_y2$study_id) # n = 70


## Year 5, missing glucose and hba1c. same approach as y2: based on the diab_ind = 2 for now. 
summary(dat_y5)
table(dat_y5$diab_ind)

newdm_y5 <-dat_y5%>%
  dplyr::filter(diab_ind==2&(!study_id %in% id_sel2)) # diagnosis age all missing

id_sel5<-c(id_sel2,newdm_y5$study_id) #n=121 new DM after year 5 

## Year7
summary(dat_y7)

newdm_y7 <- dat_y7 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel5)

id_sel7<-c(id_sel5,newdm_y7$study_id) #n=152 new DM after year 7; after correction for AFTER diagnosis lab measurements n = 31 


## Year 10

summary(dat_y10)

newdm_y10 <- dat_y10 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel7)

id_sel10<-c(id_sel7,newdm_y10$study_id) #n=199 new DM after year 10; after correction for AFTER diagnosis lab measurements n = 47


## Year 15 

summary(dat_y15)
table(dat_y15$med_diab)
newdm_y15 <- dat_y15 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef))) %>%
  dplyr::filter(!study_id %in% id_sel10)

id_sel15<-c(id_sel10,newdm_y15$study_id) #n=244 new DM after year 15; after correction for AFTER diagnosis lab measurements n = 45

#ISSUE: some participants have (abs(age - dmagediag) <=1) > 1. We will deal with this in the merged dataset

## YEAR 20: 
summary(dat_y20)

newdm_y20 <- dat_y20 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef)) |(hba1c >=6.5 & !is.na(hba1c))) %>% 
  dplyr::filter(!study_id %in% id_sel15)

id_sel20<-c(id_sel15,newdm_y20$study_id) #n=394 new DM after year 20;after correction for AFTER diagnosis lab measurements n = 150

table(dat_y20$med_diab_nin)
table(dat_y20$med_diab)

## YEAR 25

summary(dat_y25)

newdm_y25 <- dat_y25 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef)) |(hba1c >= 6.5 & !is.na(hba1c))) %>% 
  dplyr::filter(!study_id %in% id_sel20)

id_sel25<-c(id_sel20,newdm_y25$study_id) #n=545 new DM after year 25;after correction for AFTER diagnosis lab measurements n = 151


## YEAR 30 

summary(dat_y30)

newdm_y30 <- dat_y30 %>%
  dplyr::filter(((dmagediag - age) >= 0 & (dmagediag - age) <= 1) | (glucosef >= 126 & !is.na(glucosef)) |(hba1c >= 6.5 & !is.na(6.5))) %>% 
  dplyr::filter(!study_id %in% id_sel25)

id_sel30<-c(id_sel25,newdm_y30$study_id) #n=666 new DM after year 20;after correction for AFTER diagnosis lab measurements n = 121


# MODIFICATIONS merged data:
# SEX, assumed, 1=male, 2=female 
# RACE, coding unclear, keep all there variables 
# Medication use, assumed, 1=no, 2=yes, 8=missing

## merge all new DM cases from y2 to y30 
dat_newdm_noy0 <- bind_rows(newdm_y2, newdm_y5, newdm_y7, newdm_y10, newdm_y15, newdm_y20, newdm_y25, newdm_y30)

## now we will select those with 0 <= age - diagnosis age <= 1, using the full dataset 
dat_all_temp<- dat_all %>% 
  group_by(study_id) %>%
  mutate(min_dxage = if (all(is.na(dmagediag))) {
    NA_real_  # Return NA if all are NA
  } else {
    min(dmagediag, na.rm = TRUE)  # Compute minimum with NA removal
  }) %>% 
    ungroup()%>%
  mutate(age_diff = abs(min_dxage-age))

dat_sub <- dat_all_temp %>%
  dplyr::filter(age_diff <= 0 & age_diff>= -1) # n = 483 ; after lab measurement correction n = 188. 



id_dmage <- dat_sub$study_id


common_ids = intersect(id_dmage, id_sel30)
only_in_dmage = setdiff(id_dmage, id_sel30)
only_in_sel30 = setdiff(id_sel30, id_dmage)


# Perform a full outer join
merged_data <- full_join(dat_newdm_noy0, dat_sub, by = "study_id", suffix = c("_A", "_B"))

# Identify overlapping columns (excluding 'study_id')
overlapping_cols <- setdiff(intersect(names(dat_newdm_noy0), names(dat_sub)), "study_id")

# Resolve conflicts programmatically
for (col in overlapping_cols) {
  merged_data[[col]] <- if_else(
    !is.na(merged_data[[paste0(col, "_B")]]),  # If B has a value
    merged_data[[paste0(col, "_B")]],  # Use B's value
    merged_data[[paste0(col, "_A")]]  # Otherwise use A's value
  )
  
  # Remove intermediary columns
  merged_data <- merged_data %>%
    select(-paste0(col, "_A"), -paste0(col, "_B"))
}



saveRDS(merged_data,paste0(path_endotypes_folder,"/working/cleaned/cardia_newdm.RDS"))

#un-comment if all visits needed
#saveRDS(dat_all,paste0(path_endotypes_folder,"/working/cleaned/cardia_all.RDS"))



