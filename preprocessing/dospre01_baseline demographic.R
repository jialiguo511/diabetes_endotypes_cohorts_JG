
vl_column = "demographic"

# DPP data DEMOGRAPHIC includes one record for each participant in the released database. 
# Data in this file is identical to the BASELINE data included in the DPP Full Scale data release, 
# but includes only those participants with consent for the bridge data release, and contains the following variables

data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Non_Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Non_Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Non_Form_Based")

bridge <- data_extract(study_name,vl_column,data_path1) 
phase1 <- data_extract(study_name,vl_column,data_path2) 
phase2 <- data_extract(study_name,vl_column,data_path3) 

demographic <- bind_rows(bridge %>% mutate(release = "BRIDGE"),
                         phase1 %>% mutate(release = "PHASE 1"),
                         phase2 %>% mutate(release = "PHASE 2")) %>% 
  mutate(female = case_when(sex == 1 ~ 0,
                            sex == 2 ~ 1,
                            TRUE ~ NA_real_),
         race_eth = case_when(race_eth == 1 ~ "NH White",
                              race_eth == 2 ~ "NH Black",
                              race_eth == 3 ~ "Hispanic",
                              race_eth == 4 ~ "NH Other",
                              TRUE ~ NA_character_))


saveRDS(demographic,paste0(path_endotypes_folder,"/working/interim/dospre01_demographic.RDS"))

rm(bridge,phase1,phase2)
