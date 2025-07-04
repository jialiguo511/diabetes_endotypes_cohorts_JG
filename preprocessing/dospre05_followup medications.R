vl_column1 = "f01"
vl_column2 = "f02"
vl_column3 = "f06"

study_name = "DPPOS"

data_path1 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPP_Bridge/Form_Based")
data_path2 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase1/Form_Based")
data_path3 <-  paste0(path_endotypes_folder,"/working/dppos/Data/DPPOS_Phase2/Form_Based")

med_vars <- paste0("med_", letters[1:10])

tr1 <- data_extract(study_name,"tr1",data_path1)

bridge <- bind_rows(data_extract(study_name,vl_column1,data_path1),
                    data_extract(study_name,vl_column2,data_path1)) 

phase1 <- bind_rows(data_extract(study_name,vl_column1,data_path2),
                    data_extract(study_name,vl_column2,data_path2),
                    data_extract(study_name,vl_column3,data_path2)) 

phase2 <- bind_rows(data_extract(study_name,vl_column1,data_path3),
                    data_extract(study_name,vl_column2,data_path3),
                    data_extract(study_name,vl_column3,data_path3)) 

meds <- bind_rows(bridge,
                  phase1,
                  phase2,
                  tr1) %>% 
  select(study_id, visit, StudyDays, all_of(med_vars)) 


meds_long <- meds %>%
  pivot_longer(
    cols = med_vars,
    names_to = "med_code",        
    values_to = "medications") %>% 
  dplyr::filter(!is.na(medications))

unique_meds <- unique(meds_long$medications)
meds_list <- data.frame(medications = unique_meds)

write.csv(meds_list, "preprocessing/dospre05_trial medication list.csv")


meds_class_gpt <- read.csv("preprocessing/dospre05_trial medication classification.csv")

meds_class <- meds_long %>% 
  left_join(meds_class_gpt %>% 
              select(-`Unnamed..0`) %>% 
              mutate(medications = toupper(medications)),
            by = "medications") %>% 
  pivot_wider(
    id_cols = c(study_id, visit, StudyDays,med_dm_use,med_chol_use,med_bp_use,med_dep_use),
    names_from = med_code,
    values_from = medications,
    values_fn = ~ paste(unique(.x), collapse = "; ")
  ) %>% 
  distinct(study_id, visit, StudyDays, .keep_all = TRUE)

saveRDS(meds_class,paste0(path_endotypes_folder,"/working/interim/dospre05_medications.RDS"))
