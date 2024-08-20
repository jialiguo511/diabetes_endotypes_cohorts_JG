vl_column = "lab"

data_path <-  paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Non-Form_Data/Data")


lab <- data_extract(study_name,vl_column,data_path,df_name = "lab") %>% 
  mutate(quarter = case_when(visit %in% c("SCR","BAS") ~ 0,
                             visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                             str_detect(visit,"M") ~ str_replace(visit,"M","") %>% as.numeric(.)/3,
                             str_detect(visit,"Y") ~ str_replace(visit, "Y","") %>% as.numeric(.)*4,
                             TRUE ~ NA_real_
  ),
  semi = quarter/2)
saveRDS(lab,paste0(path_endotypes_folder,"/working/interim/dpppre02_labs.RDS"))
