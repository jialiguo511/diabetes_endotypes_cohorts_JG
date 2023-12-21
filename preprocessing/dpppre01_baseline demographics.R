vl_column = "demographic"

data_path <- paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Non-Form_Data/Data")


demographic <- data_extract(study_name,vl_column,data_path,df_name = "basedata") %>% 
  left_join(data_extract(study_name,vl_column,data_path,df_name = "age_weight_bmi"),
            by = "study_id") %>% 
  mutate(female = case_when(sex == 1 ~ 0,
                            sex == 2 ~ 1,
                            TRUE ~ NA_real_),
         race_eth = case_when(race_eth == 1 ~ "NH White",
                              race_eth == 2 ~ "NH Black",
                              race_eth == 3 ~ "Hispanic",
                              race_eth == 4 ~ "NH Other",
                              TRUE ~ NA_character_))
