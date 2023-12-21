
vl_column = "events"

# DPP data EVENTS includes one record for each participant. 
# This file is updated from the full data release, and includes also diabetes diagnosed during the washout visit.
data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Non_Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Non_Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Non_Form_Based")

bridge <- data_extract(study_name,vl_column,data_path1) 
phase1 <- data_extract(study_name,vl_column,data_path2) 
phase2 <- data_extract(study_name,vl_column,data_path3) 

events <- bind_rows(bridge %>% mutate(release = "BRIDGE"),
                 phase1 %>% mutate(release = "PHASE 1"),
                 phase2 %>% mutate(release = "PHASE 2"))

rm(bridge,phase1,phase2)