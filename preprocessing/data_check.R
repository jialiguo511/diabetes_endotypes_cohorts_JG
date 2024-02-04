## Created by Zhongyu Li
## Feb 2024 
## To check cleaned data sets & to compared replicated data sets 


### JHS ### 
jhs_JV <- readRDS(paste0(path_cleaned_folder,"/jhs.RDS"))
jhs_ZL <- readRDS(paste0(path_cleaned_folder,"/jhs_zl.RDS"))          

identical(jhs_JV,jhs_ZL)


