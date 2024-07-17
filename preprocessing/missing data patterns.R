# The purpose of this R script is to generate the missingness patterns in the six cohort dataset 

library(dplyr)
library(tidyr)

data_6c_mi <- read.csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_mi.csv")) #4862 new DM cases, everyone has bmi, hba1c, and age of diagnosis. 

data_6c <- read.csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_cc.csv")) #8414 new DM cases 

# keep only 11 variables

colnames(data_6c_mi)
data_11var <- data_6c_mi %>% 
  select(-serumcreatinine,-urinealbumin,-urinecreatinine,-egfr,-totalc,-race_rev, -ast, -alt, -uacr) 

data_11var_cc <- data_6c %>% 
  select(-serumcreatinine,-urinealbumin,-urinecreatinine,-egfr,-totalc,-race_rev, -ast, -alt, -uacr) 


#install.packages('naniar')
library(naniar)
#vis_miss(data_6c_mi)
#vis_miss(data_6c)
vis_miss(data_11var)

#install.packages('UpSetR')
gg_miss_upset(data_11var,nsets=n_var_miss(data_11var))

gg_miss_var(data_11var,show_pct = TRUE)

library(ggplot2)
gg_miss_fct(x = data_11var, fct = study) + labs(title = "missingness by study sites in the imputation ready dataset (everyone has bmi, hba1c and age)")

gg_miss_fct(x = data_11var_cc, fct = study) + labs(title = "missingness by study sites in the full dataset")

