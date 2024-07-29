rm(list=ls());gc();source(".Rprofile")

source("analysis/decan_analytic sample.R")
rm(analytic_dataset_after_imputation,analytic_dataset_before_imputation,dec_an02)

source("C:/code/external/functions/nhst/table1_summary.R")

newly_diagnosed <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_data_temp_6c_homa2.csv"))

excluded_diagnosed = newly_diagnosed %>% 
  anti_join(analytic_dataset_cluster,
            by=c("study_id","study"))

complete_cases = analytic_dataset_cluster %>% 
  dplyr::filter(!is.na(dmagediag),!is.na(bmi),!is.na(hba1c),
                !is.na(homa2b),!is.na(homa2ir),!is.na(ldlc),
                !is.na(hdlc),!is.na(tgl),!is.na(sbp),!is.na(dbp))

c_vars = c("dmagediag","bmi","hba1c","glucosef2","insulinf2","homa2b","homa2ir","ldlc","hdlc","tgl","sbp","dbp","ratio_th",
           "ast","alt","urinealbumin","urinecreatinine","uacr","egfr")

p_vars = c("female")
g_vars = c("race_rev","study")


table_df <- bind_rows(newly_diagnosed %>% 
            mutate(dataset = "newly_diagnosed"),
            excluded_diagnosed %>% 
              mutate(dataset = "excluded_diagnosed"),
          analytic_dataset_cluster %>% 
            mutate(dataset = "analytic"),
          complete_cases %>% 
            mutate(dataset="complete"))%>% 
  table1_summary(.,c_vars = c_vars,p_vars = p_vars,g_vars = g_vars,id_vars = "dataset")

write_csv(table_df,"analysis/descriptives/decan_descriptives03_comparison of analytic and complete cases.csv")
  
