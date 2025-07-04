vl_column1 = "f01"
vl_column2 = "f02"
vl_column3 = "f06"

data_path <- paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Form_Data/Data")

med_vars <- paste0("med_", letters[1:10])

tr1 <- data_extract(study_name,"tr1",data_path)

meds <- bind_rows(data_extract(study_name,vl_column1,data_path),
                  data_extract(study_name,vl_column2,data_path),
                  data_extract(study_name,vl_column3,data_path)) %>% 
  select(study_id, visit, StudyDays, all_of(med_vars)) %>%
  left_join(tr1, by = c("study_id", "visit", "StudyDays", med_vars))


meds_long <- meds %>%
  pivot_longer(
    cols = med_vars,
    names_to = "med_code",        
    values_to = "medications") %>% 
  dplyr::filter(!is.na(medications))

unique_meds <- unique(meds_long$medications)
meds_list <- data.frame(medications = unique_meds)

write.csv(meds_list, "preprocessing/dpppre05_trial medication list.csv")


# Option 1: identify key words --------------------------
# library(stringr)
# 
# # Define keyword patterns for each class (all lowercase for case-insensitive matching)
# dm_keywords    <- c("metformin", "glipizide", "glyburide", "insulin", "glimepiride", "liraglutide", "semaglutide", "empagliflozin")
# chol_keywords  <- c("statin", "atorvastatin", "simvastatin", "pravastatin", "rosuvastatin", "lovastatin", "lipitor", "crestor", "zocor")
# bp_keywords    <- c("lisinopril", "amlodipine", "hydrochlorothiazide", "losartan", "metoprolol", "atenolol", "valsartan", "enalapril")
# dep_keywords   <- c("fluoxetine", "sertraline", "escitalopram", "citalopram", "paroxetine", "venlafaxine", "bupropion", "prozac", "zoloft")
# 
# # Create flags for each class
# meds_long_class <- meds_long %>%
#   mutate(
#     med_name_lower = tolower(medications),
#     med_dm_use    = as.integer(str_detect(med_name_lower, str_c(dm_keywords, collapse = "|"))),
#     med_chol_use  = as.integer(str_detect(med_name_lower, str_c(chol_keywords, collapse = "|"))),
#     med_bp_use    = as.integer(str_detect(med_name_lower, str_c(bp_keywords, collapse = "|"))),
#     med_dep_use   = as.integer(str_detect(med_name_lower, str_c(dep_keywords, collapse = "|")))
#   ) %>%
#   select(-med_name_lower) 

# Option 2: GPT classify ---------------------------------------------
meds_class_gpt <- read.csv("preprocessing/dpppre05_trial medication classification.csv")

meds_class <- meds_long %>% 
  left_join(meds_class_gpt %>% 
              select(-`Unnamed..0`) %>% 
              mutate(medications = toupper(medications)),
            by = "medications") %>% 
  pivot_wider(
    id_cols = c(study_id, visit, StudyDays,med_dm_use,med_chol_use,med_bp_use,med_dep_use),
    names_from = med_code,
    values_from = medications
  ) %>% 
  distinct(study_id, visit, StudyDays, .keep_all = TRUE)

saveRDS(meds_class,paste0(path_endotypes_folder,"/working/interim/dpppre05_medications.RDS"))
