
# for nine variable method(Method 4)
var_sel <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag")
data_8c_nona <- data_8c[complete.cases(data_8c[,var_sel]),] # 6104 no NA new DM cases 
data_8c_nona <- data_8c_nona[c("study_id", setdiff(names(data_8c_nona), "study_id"))] # rearrange the columns 

# for homa2 comparison, five variable method (Method 3A and 3B)
var_sel2 <- c("bmi","hba1c","glucosef2","insulinf2","dmagediag")
data_homa2 <-data_8c[complete.cases(data_8c[,var_sel2]),]
data_homa2 <- data_homa2[c("study_id", setdiff(names(data_homa2), "study_id"))] #3818 no NA for five variable methods  


# export to pyhton 
data_array <- as.matrix(data_8c_nona)
write.csv(data_array, paste0(path_endotypes_folder,"/working/processed/data_8c.csv"), row.names = FALSE)

# the HOMA2 is calculated using the excel calculator released by University of Oxford.Some observations will be removed due to extreme values out of the range. 
data_array_homa2 <- as.matrix(data_homa2)

#NOTE!!the data_array_home2.csv does not contain the HOME2IR and HOME2B when generated from R. You need to use the HOME2 calculator and paste these values to the file. 
write.csv(data_array_homa2, paste0(path_endotypes_folder,"/working/processed/data_6c_homa2.csv"), row.names = FALSE)

# Merge two datasets to generate a final data. 

#################################################################################################################################
# NOTE:Before merge, make sure that HOME2 values are added to csv file! 

# Load the datasets
data_4m <- read.csv(paste0(path_endotypes_folder,"/working/processed/data_8c.csv"))
data_3m <- read.csv(paste0(path_endotypes_folder,"/working/processed/data_6c_homa2.csv")) 

# Add indicator columns
data_3m$method3 <- 1  
data_4m$method4 <- 1  

names(data_8c)

# Merge dataset using left_join
var_sel3 <- c("bmi","hba1c","ldlc","hdlc","tgl","sbp","dbp","ratio_th","dmagediag","glucosef2","insulinf2","study","serumcreatinine",
              "urinealbumin","urinecreatinine","egfr","totalc", "alt","ast")
merged <- full_join(data_4m, data_3m, by = "study_id", suffix = c("_A", "_B"))

choose_value <- function(a, b) {
  if (!is.na(a)) {
    return(a)  # If dataset_A has a non-missing value, use it
  } else {
    return(b)  # Otherwise, use dataset_B's value
  }
}

# Reconcile each variable in the list
for (var in var_sel3) {
  merged <- merged %>%
    mutate(
      !!var := mapply(choose_value, .data[[paste0(var, "_A")]], .data[[paste0(var, "_B")]])
    )
}

# Drop the intermediate columns (those with suffixes "_A" and "_B")
final_dataset <- merged %>%
  dplyr::select(-ends_with("_A"), -ends_with("_B")) %>%
  dplyr::select("study_id", everything())


# Fill missing indicator values with 0
final_dataset$method3[is.na(final_dataset $method3)] <- 0
final_dataset$method4[is.na(final_dataset $method4)] <- 0

# reorder
final_dataset <- final_dataset%>%
  select(-c(study,method3, method4), study,method3, method4)  # Reorder with 'method3' and 'method4' last

# check sample size for method 3 & 4 

temp <- final_dataset %>% 
  dplyr::filter(method3==1 & method4 ==1)

non_na_counts_temp <- temp %>%
  summarise(across(everything(), ~ sum(!is.na(.))))

print(non_na_counts_temp)

# just to compare counts with previous results
sum_test <- final_dataset %>% 
  dplyr::filter(method3==1) %>% 
  group_by(study)%>%
  summarise(across(everything(), ~ sum(!is.na(.)), .names = "n_{.col}"))


# Save the merged dataset to a CSV
write_csv(final_dataset, paste0(path_endotypes_folder,"/working/processed/final_dataset_cc.csv"))

