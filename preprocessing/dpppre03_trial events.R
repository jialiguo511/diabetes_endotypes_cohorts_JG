vl_column = "events"

data_path <-  paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Non-Form_Data/Data")

events <- data_extract(study_name,vl_column,data_path,df_name = "events")
saveRDS(events,paste0(path_endotypes_folder,"/working/interim/dpppre03_events.RDS"))
