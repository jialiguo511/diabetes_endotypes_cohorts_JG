# the purpose of this R script is to generate complete case datasets for five-variable and nine-variable methods 
rm(list=ls()); gc(); source(".Rprofile")
# read datasets 
# As of June 2024, only six cohort dataset is used 
# In August 2024, a "_clean" tag is added to all dataset to reflect revisions made in datasets, see "final_dataset_temp.R" for details. 
# In September 2024, new workflow is implemented to select new DMs. 

data_6c_clean <- read.csv(paste0(path_endotypes_folder,"/working/processed/final_data_temp_6c_clean.csv")) #7623 new DM cases 

# for imputation purpose 
var_sel_mi <- c("hba1c","dmagediag","bmi") #4862 ==> n = 3390
data_6c_clean_mi<- data_6c_clean[complete.cases(data_6c_clean[,var_sel_mi]),] 

write.csv(data_6c_clean_mi, paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_clean_mi.csv"), row.names = FALSE)




# for nine variable method (Method 4)
var_sel <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag")
data_9v_nona <- data_6c_clean[complete.cases(data_6c_clean[,var_sel]),] # 3,299 no NA new DM cases 
data_9v_nona <- data_9v_nona[c("study_id", setdiff(names(data_9v_nona), "study_id"))] # rearrange the columns 

# for homa2 comparison, five variable method (Method 3A and 3B)
var_sel2 <- c("bmi","hba1c","glucosef2","insulinf2","dmagediag")
data_5v_nona <-data_6c_clean[complete.cases(data_6c_clean[,var_sel2]),]
data_5v_nona <- data_5v_nona[c("study_id", setdiff(names(data_5v_nona), "study_id"))] #2831 no NA for five variable methods. Only these people will have HOMA2


# for complete cases on both 5var and 9var method 
var_sel3 <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag","glucosef2","insulinf2")
data_6c_cc_clean <- data_6c_clean[complete.cases(data_6c_clean[,var_sel3]),] # 2784 no NA new DM cases for both 5var and 9 vrar
data_6c_cc_clean <- data_6c_cc_clean[c("study_id", setdiff(names(data_6c_cc_clean), "study_id"))] # rearrange the columns 

# output a complete dataset for six cohorts to be used in both 5var and 9var methods. HOMA2 still need to be added manually. 
write.csv(data_6c_cc_clean, paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_cc_clean.csv"), row.names = FALSE)
sd(data_6c_cc_clean$dmagediag,na.rm = TRUE) ## after HOMA2 is added, the final sample size = xx, after excluding out of range fasting insulin and glucose values (n=xx). 

