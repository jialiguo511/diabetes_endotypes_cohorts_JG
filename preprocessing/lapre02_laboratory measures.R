vl_column = "LABORATORYMEASURES_V2"

data_path <-  paste0(path_endotypes_folder,"/working/look ahead/Data/Intervention/Data/Measurement Data")

laboratory <- data_extract(study_name,vl_column,data_path) %>% 
  dplyr::filter(visit == "Baseline") %>% 
  dplyr::select(-visit,-StudyDays)
