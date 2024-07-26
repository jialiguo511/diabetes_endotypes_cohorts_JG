rm(list=ls());gc();source(".Rprofile")


mean_vars = c("dmagediag","bmi","glucosef2","insulinf2","ldlc","hdlc","tgl","sbp","dbp",
              "ast","alt","urinealbumin","urinecreatinine")

median_vars = c("hba1c","homa2b","homa2ir","ratio_th","uacr","egfr")

table_df <- read_csv("analysis/descriptives/decan_descriptives01_pooled analytic cohort.csv") %>% 
  dplyr::mutate(selected_rows = case_when(variable %in% mean_vars & est %in% c("mean","sd") ~ 1,
                                          variable %in% median_vars & est %in% c("median","q25","q75") ~ 1,
                                          !variable %in% c(mean_vars,median_vars) ~ 1,
                                          TRUE ~ 0
                                          )) %>% 
  dplyr::filter(selected_rows == 1) %>% 
  dplyr::select(cluster_label,group,variable,est,value) %>% 
  pivot_wider(names_from=est,values_from=value) %>% 
  mutate(output = case_when(variable %in% mean_vars ~ paste0(round(mean,1)," (",round(sd,1),")"),
                            variable %in% median_vars ~ paste0(round(median,1)," (",round(q25,1),", ",round(q75,1),")"),
                            TRUE ~ paste0(round(freq,0)," (",round(proportion,1),"%)")
                            )) %>% 
  dplyr::select(variable,group,cluster_label,output) %>% 
  pivot_wider(names_from=cluster_label,values_from=output) %>% 
  dplyr::select(variable,group,Total,SIDD,SIRD,MOD,MARD)

write_csv(table_df,"paper/table_descriptive characteristics by cluster.csv")  
