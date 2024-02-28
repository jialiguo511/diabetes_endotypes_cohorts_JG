### The purpose of this file is to generate summary statistics for nine cohorts 

library(dplyr)

#### JHS 
jhs<- readRDS(paste0(path_cleaned_folder,"/jhs.RDS"))

jhs <- jhs %>%
  mutate(hl_ratio = tgl/hdlc)

colnames(jhs)
var_list <- c("age","female","smoking","alcohol","bmi","hba1c","ldlc","hdlc","tgl","hl_ratio","dbp","sbp","glucosef","insulinf")

## subset newly diagnosed DM by duration 

sub_allnew <- jhs[jhs$dmduration%in% c(0, 1), ]
sub_allnew_sorted <- sub_allnew[order(sub_allnew$study_id), ]

# remove duplicates 
duplicates <- sub_allnew_sorted[duplicated(sub_allnew_sorted$study_id),]

newDM<- sub_allnew_sorted[!duplicated(sub_allnew_sorted$study_id),] #N=478 

mean_stats_jhs<- newDM %>%
  summarise_at(all_of(var_list), list(mean = ~round(mean(., na.rm = TRUE), 2)))

table(newDM$race_eth)
library(writexl)
path_save<-paste0(path_cleaned_folder,"/sum_stats/mean_stats_jhs.xlsx")
write_xlsx(mean_stats_jhs, path_save)

### Look Ahead 

la<- readRDS(paste0(path_cleaned_folder,"/look_ahead.RDS"))
colnames(la)

la <- la %>%
  mutate(hl_ratio = tgl/hdlc)
newDM_la <- la[la$dmduration%in% c(0, 1), ] #N=877

var_list_la <- c("bsage","female","alcohol","dmfamilyhistory","bmi","hba1c","ldlc","hdlc","tgl","hl_ratio","dbp",
                 "sbp","glucosef")

mean_stats_la<- newDM_la %>%
  summarise_at(all_of(var_list_la), list(mean = ~round(mean(., na.rm = TRUE), 2)))

path_save_la<-paste0(path_cleaned_folder,"/sum_stats/mean_stats_la.xlsx")
write_xlsx(mean_stats_la, path_save_la)

table(newDM_la$race)
(147+104)/877
table(newDM_la$smoking)
(46+398)/877

### ACCORD 

accord<- readRDS(paste0(path_cleaned_folder,"/accord.RDS"))
colnames(accord)
accord <- accord %>%
  mutate(hl_ratio = tgl/hdlc,
         bmi = weight/((height/100)^2))

newDM_accord <- accord[accord$dmduration%in% c(0, 1), ] #N=601 

var_list_ac <- c("bsage","female","alcohol","bmi","hba1c","ldlc","hdlc","tgl","hl_ratio","dbp",
                 "sbp","glucosef")

mean_stats_accord<- newDM_accord %>%
  summarise_at(all_of(var_list_ac), list(mean = ~round(mean(., na.rm = TRUE), 2)))

table(newDM_accord$race_eth)
(50+117+70)/(50+117+70+364)

path_save_ac<-paste0(path_cleaned_folder,"/sum_stats/mean_stats_accord.xlsx")
write_xlsx(mean_stats_accord, path_save_ac)

### DPP 
dpp<- readRDS(paste0(path_cleaned_folder,"/dpp.RDS"))
colnames(dpp)
view(dpp)
summary(dpp)







