
data_path <- paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Form_Data/Data")

study_name = "DPP"

q08 <- data_extract(study_name,"q08",data_path)
r04 <- data_extract(study_name,"r04",data_path)
s05 <- data_extract(study_name,"s05",data_path)


smoking <- bind_rows(q08, r04, s05) %>% 
  distinct(study_id, visit, StudyDays, .keep_all = TRUE)

saveRDS(smoking,paste0(path_endotypes_folder,"/working/interim/dpppre06_lifestyle.RDS"))
