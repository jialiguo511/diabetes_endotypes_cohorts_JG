vl_column1 = "f07_baselinehistoryphysicalexam"
vl_column2 = "f01_inclusionexclusionsummary"
vl_column3 = "f02_bptrialscreening"
vl_column4 = "f03_lipidtrialscreening"

data_path1 <- paste0(path_endotypes_folder,"/working/accord/Main_Study/4-Data_Sets-CRFs/4a-CRF_Data_Sets/csv")
data_path2 <- paste0(path_endotypes_folder,"/working/accord/Main_Study/3-Data_Sets-Analysis/3a-Analysis_Data_Sets/csv")

accord_key <- data_extract(study_name,"accord_key",data_path2)
f07 <- data_extract(study_name,vl_column1,data_path1) 
f01 <- data_extract(study_name,vl_column2,data_path1) 
f02 <- data_extract(study_name,vl_column3,data_path1) 
f03 <- data_extract(study_name,vl_column4,data_path1) 


baseline <- accord_key %>% 
  left_join(f07 %>% rename(bs_visit = visit),
            by = "study_id") %>% 
  left_join(f01,
            by = "study_id") %>% 
  left_join(f02,
            by = c("study_id","visit")) %>% 
  left_join(f03,
            by = c("study_id","visit")) %>% 
  rename(race_eth = race_ethnicity) %>% 
  mutate(race_eth = case_when(race_eth == "White" ~ "NH White",
                              race_eth == "Black" ~ "NH Black",
                              race_eth == "Hispanic" ~ "Hispanic",
                              race_eth == "Other" ~ "NH Other",
                              TRUE ~ NA_character_))

rm(accord_key,f07,f01,f02,f03)
