vl_column = "PHYSICALMEASURES_BP_BMI"

data_path <-  paste0(path_endotypes_folder,"/working/look ahead/Data/Intervention/Data/Measurement Data")

physical <- data_extract(study_name,vl_column,data_path) %>% 
  dplyr::filter(visit == "Baseline") %>% 
  mutate(sbp = rowMeans(.[,c("bssbp1","bssbp2")],na.rm = TRUE),
         dbp = rowMeans(.[,c("bsdbp1","bsdbp2")],na.rm = TRUE),
         weight = rowMeans(.[,c("bswgt1","bswgt2")],na.rm = TRUE)) %>% 
  mutate(height = sqrt(weight/bmi)*100) %>% 
  dplyr::select(-visit,-StudyDays)
