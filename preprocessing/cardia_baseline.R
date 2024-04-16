#The purpose of this file is to merge all nine exams for CARDIA 

rm(list=ls()); gc(); source(".Rprofile")
source("preprocessing/cardia_y0_y25.R")

## merge all nine exams 

dat_y0$year = 0 
dat_y2$year = 2 
dat_y5$year = 5 
dat_y7$year = 7 
dat_y10$year = 10 
dat_y15$year = 15 
dat_y20$year = 20 
dat_y25$year = 25
dat_y30$year = 30 

dat_all <- bind_rows(dat_y0, dat_y2, dat_y5, dat_y7, dat_y10, dat_y15, dat_y20, dat_y25, dat_y30)

head(dat_all)


############# To identify new diabetes ######### 
names(dat_all)
### criteria and variables: dmagediag, diab_st, diab_ind, glucosef(>=126),glucose2h(>=200),hba1c(.=6.5),glucoser(>=200)

table(dat_all$diab_st) # not sure about its coding, not used. 
table(dat_all$diab_ind) # assumed coding: 1 = no diabetes, 2 = diabetes, 8 = unknown (recode to NA)

### select new DM from each visit
#### this method will include participants with the visit at which they are diagnosed and not any other visits 

## Year 0, baseline

summary(dat_y0)
newdm_y0 <- dat_y0%>% 
  dplyr::filter((glucosef>=126&!is.na(glucosef))|((glucoser>=200&!is.na(glucoser)))) #should those people be treated as new DM? yes for now. 

id_sel0 <- newdm_y0$study_id# add to this and use to remove unwanted visits from previous diagnosis, rename to year number after adding ids

## Year 2, based on the diab_ind = 2 for now

summary(dat_y2)
table(dat_y2$diab_ind)
newdm_y2 <-dat_y2%>%
  dplyr::filter(diab_ind==2&(!study_id %in% id_sel0))

newdm_y2<- newdm_y2[!duplicated(newdm_y2$study_id),]

id_sel2<-c(id_sel0,newdm_y2$study_id)


## Year 5, missing glucose and hba1c. same approach as y2: based on the diab_ind = 2 for now. 
summary(dat_y5)
table(dat_y5$diab_ind)

newdm_y5 <-dat_y5%>%
  dplyr::filter(diab_ind==2&(!study_id %in% id_sel2))

id_sel5<-c(id_sel2,newdm_y5$study_id) #n=123 new DM after year 5 

## Year7
summary(dat_y7)

newdm_y7 <- dat_y7 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) | (glucoser >= 200 & !is.na(glucoser)))%>% 
  dplyr::filter(!study_id %in% id_sel5)

id_sel7<-c(id_sel5,newdm_y7$study_id) #n=161 new DM after year 7 


## Year 10

summary(dat_y10)

newdm_y10 <- dat_y10 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) | (glucose2h >= 200 & !is.na(glucose2h)))%>% 
  dplyr::filter(!study_id %in% id_sel7)

id_sel10<-c(id_sel7,newdm_y10$study_id) #n=218 new DM after year 10

id_sel10[duplicated(id_sel10)]#id = 946210 in y2 is a duplicate 

## Year 15 

summary(dat_y15)
table(dat_y15$med_diab)#use of diabetes medication, assumed code 2 = yes, used as diagnosis criteria

newdm_y15 <- dat_y15 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) | (med_diab==2))%>% 
  dplyr::filter(!study_id %in% id_sel10)

id_sel15<-c(id_sel10,newdm_y15$study_id) #n=276 new DM after year 15

#ISSUE: some participants have (abs(age - dmagediag) <=1) > 1

## YEAR 20: 
summary(dat_y20)

table(dat_y20$med_diab_nin)#use of diabetes medications, assumed code 2 = yes, used as diagnosis criteria


newdm_y20 <- dat_y20 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) |(glucose2h >= 200 & !is.na(glucose2h)) | med_diab==2 | med_diab_nin ==2) %>% 
  dplyr::filter(!study_id %in% id_sel15)

id_sel20<-c(id_sel15,newdm_y20$study_id) #n=478 new DM after year 20


## YEAR 25

summary(dat_y25)

table(dat_y25$med_diab)#use of diabetes medications, assumed code 2 = yes, used as diagnosis criteria


newdm_y25 <- dat_y25 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) |(glucose2h >= 200 & !is.na(glucose2h)) | med_diab==2) %>% 
  dplyr::filter(!study_id %in% id_sel20)

id_sel25<-c(id_sel20,newdm_y25$study_id) #n=628 new DM after year 25


## YEAR 30 

summary(dat_y30)
table(dat_y30$med_diab_nin)#use of diabetes medications, assumed code 2 = yes, used as diagnosis criteria


newdm_y30 <- dat_y30 %>%
  dplyr::filter((abs(age - dmagediag) <=1) | (glucosef >= 126 & !is.na(glucosef)) |(glucose2h >= 200 & !is.na(glucose2h)) | med_diab==2 | med_diab_nin ==2) %>% 
  dplyr::filter(!study_id %in% id_sel25)

id_sel30<-c(id_sel25,newdm_y30$study_id) #n=822 new DM after year 20

id_sel30 <- id_sel30[!duplicated(id_sel30)]# n=821 new DM after the one duplicate removed. 

# MODIFICATIONS merged data:
# SEX, assumed, 1=male, 2=female 
# RACE, coding unclear, keep all there variables 
# Medication use, assumed, 1=no, 2=yes, 8=missing
# #id = 946210 in new dm y2 is a duplicate 

## merge all new DM cases from y0 to y30 
dat_newdm <- bind_rows(newdm_y0, newdm_y2, newdm_y5, newdm_y7, newdm_y10, newdm_y15, newdm_y20, newdm_y25, newdm_y30)
summary(dat_newdm)

saveRDS(dat_newdm,paste0(path_endotypes_folder,"/working/cleaned/CARDIA_newdm.RDS"))

saveRDS(dat_all,paste0(path_endotypes_folder,"/working/cleaned/CARDIA_all.RDS"))



