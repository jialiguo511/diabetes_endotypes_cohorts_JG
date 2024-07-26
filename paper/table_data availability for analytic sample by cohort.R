rm(list=ls());gc();source(".Rprofile")


selected_vars = c("dmagediag","bmi","hba1c","glucosef2","insulinf2","homa2b","homa2ir","ldlc","hdlc","tgl","sbp","dbp","ratio_th",
                           "ast","alt","urinealbumin","urinecreatinine","uacr","egfr")

table_df <- read_csv("analysis/descriptives/decan_descriptives02_summary by cohort.csv") %>% 
  dplyr::filter(est =="missing",variable %in% selected_vars) %>% 
  dplyr::select(study,variable,value) %>% 
  pivot_wider(names_from=variable,values_from=value)

write_csv(table_df,"paper/table_data availability for analytic sample.csv")
