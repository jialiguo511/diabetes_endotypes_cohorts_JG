vl_column1 = "activitystatus"
vl_column2 = "bloodpressure"
vl_column3 = "hba1c"
vl_column4 = "lipids"
vl_column5 = "otherlabs"

data_path <- paste0(path_endotypes_folder,"/working/accord/Main_Study/3-Data_Sets-Analysis/3a-Analysis_Data_Sets/csv")

activitystatus <- data_extract(study_name,vl_column1,data_path)
bloodpressure <- data_extract(study_name,vl_column2,data_path)
hba1c <- data_extract(study_name,vl_column3,data_path)
lipids <- data_extract(study_name,vl_column4,data_path)
otherlabs <- data_extract(study_name,vl_column5,data_path)

biomarkers <- activitystatus %>% 
  left_join(bloodpressure,
            by=c("study_id","visit")) %>% 
  left_join(hba1c,
            by=c("study_id","visit")) %>% 
  left_join(lipids,
            by=c("study_id","visit")) %>% 
  left_join(otherlabs,
            by=c("study_id","visit"))

rm(activitystatus,bloodpressure,hba1c,lipids,otherlabs)
