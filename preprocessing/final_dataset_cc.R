# the purpose of this R script is to generate complete case datasets for five-variable and nine-variable methods 

# read datasets 
# As of June 2024, only six cohort dataset is used 

data_6c <- read.csv(paste0(path_endotypes_folder,"/working/processed/final_data_temp_6c.csv")) #8414 new DM cases 

# for nine variable method(Method 4)
var_sel <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag")
data_9v_nona <- data_6c[complete.cases(data_6c[,var_sel]),] # 6104 no NA new DM cases 
data_9v_nona <- data_9v_nona[c("study_id", setdiff(names(data_9v_nona), "study_id"))] # rearrange the columns 

# for homa2 comparison, five variable method (Method 3A and 3B)
var_sel2 <- c("bmi","hba1c","glucosef2","insulinf2","dmagediag")
data_5v_nona <-data_6c[complete.cases(data_6c[,var_sel2]),]
data_5v_nona <- data_5v_nona[c("study_id", setdiff(names(data_5v_nona), "study_id"))] #3818 no NA for five variable methods. Only these people will have HOMA2


# for complete cases on both 5var and 9var method 
var_sel3 <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag","glucosef2","insulinf2")
data_6c_cc <- data_6c[complete.cases(data_6c[,var_sel3]),] # 3782 no NA new DM cases for both 5var and 9 vrar
data_6c_cc <- data_6c_cc[c("study_id", setdiff(names(data_6c_cc), "study_id"))] # rearrange the columns 

# output a complate dataset for six cohorts to be used in both 5var and 9var methods. HOMA2 still need to be added manually. 
write.csv(data_6c_cc, paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_cc.csv"), row.names = FALSE)
sd(data_6c_cc$dmagediag,na.rm = TRUE)


2276/3782

1721/3782
