vl_column1 = "pfha"
vl_column2 = "analysis1"
vl_column3 = "hhxa"
vl_column4 = "analysis2"
vl_column5 = "pfhb"
vl_column6 = "analysis3"

data_path_analysisV <-  paste0(path_endotypes_folder,"/working/jhs/Data/Analysis_Data")
data_path1 <-  paste0(path_endotypes_folder,"/working/jhs/Data/Visit1")
data_path2 <-  paste0(path_endotypes_folder,"/working/jhs/Data/Visit2")
data_path3 <-  paste0(path_endotypes_folder,"/working/jhs/Data/Visit3")


# These can be accessed at https://github.com/jvargh7/functions
# not run for replication purpose in Feb 2024 by ZL, files exist already 


#source("C:/code/external/functions/preprocessing/convert_formats.R")

#convert_formats(data_path_analysisV,
#               file_name = "analysis1.sas7bdat",dest_type = "csv")
#convert_formats(data_path_analysisV,
#                file_name = "analysis2.sas7bdat",dest_type = "csv")
#convert_formats(data_path_analysisV,
#                file_name = "analysis3.sas7bdat",dest_type = "csv")

#convert_formats(data_path1,
#                file_name = "pfha.sas7bdat",dest_type = "csv")
#convert_formats(data_path2,
#                file_name = "hhxa.sas7bdat",dest_type = "csv")
#convert_formats(data_path3,
#                file_name = "pfhb.sas7bdat",dest_type = "csv")

#study_name = "JHS"
analysis1 <- data_extract(study_name,vl_column2,data_path_analysisV) 
analysis2 <- data_extract(study_name,vl_column4,data_path_analysisV) 
analysis3 <- data_extract(study_name,vl_column6,data_path_analysisV) 

pfha <- data_extract(study_name,vl_column1,data_path1) 
hhxa <- data_extract(study_name,vl_column3,data_path2) 
phfb <- data_extract(study_name,vl_column5,data_path3) 
table(analysis3$diabetes)

jhs_analysis <- bind_rows(
  left_join(analysis1,pfha,by="study_id") %>% mutate(visit = 1),
  left_join(analysis2,hhxa,by="study_id") %>% mutate(visit = 2),
  left_join(analysis3,phfb,by="study_id") %>% mutate(visit = 3))

saveRDS(jhs_analysis,paste0(path_endotypes_folder,"/working/interim/jhspre01_jhs_analysis.RDS"))

rm(analysis1,analysis2,analysis3,pfha,hhxa,phfb)
