vl_column1 = "q08"
vl_column2 = "r04"

study_name = "DPPOS"

data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Form_Based")

bridge <- bind_rows(data_extract(study_name,vl_column1,data_path1),
                    data_extract(study_name,vl_column2,data_path1)) 

phase1 <- data_extract(study_name,vl_column2,data_path2) 

phase2 <- data_extract(study_name,vl_column2,data_path3)

smoking <- bind_rows(bridge,
                     phase1,
                     phase2) %>% 
  distinct(study_id, visit,.keep_all = TRUE)

saveRDS(smoking,paste0(path_endotypes_folder,"/working/interim/dospre06_lifestyle.RDS"))
