
vl_column = "LA2_BASELINEVARIABLES"

data_path <-  paste0(path_endotypes_folder,"/working/look ahead/Data/Intervention/Data/Key Data")

baseline <- data_extract(study_name,vl_column,data_path) %>% 
  # mutate(race = case_when(str_detect(race,"Black") ~ "black",
  #                         str_detect(race,"White") ~ "white",
  #                         TRUE ~ "other"),
  #        ethnicity = case_when(ethnicity == "Hispanic" ~ "hispanic",
  #                              TRUE ~ "non-hispanic"),
  #        race_eth = case_when(ethnicity == "hispanic" ~ "Hispanic",
  #                            race == "black" ~ "NH Black",
  #                            race == "white" ~ "NH White",
  #                             TRUE ~ "NH Other")) %>% 
  mutate(race_eth = case_when(
    ethnicity == "African American / Black (not Hispanic)" ~ "NH Black", # 804
    ethnicity == "White" & race == "White" ~ "NH White", # 3,247
    ethnicity == "Hispanic" & race == "African American / Black" ~ "Hispanic Black", # 7
    ethnicity == "Hispanic" & race == "White" ~ "Hispanic White", # 230
    ethnicity == "Hispanic" & race == " Other/Mixed" ~ "Hispanic Other", # 439
    TRUE ~ "Other/Mixed" # 174
  )) %>% 
  rename(bsage = age) %>% 
  mutate_at(vars(dmfamilyhistory,Hypertension,CVDhis,Dyslipidemia,
                 one_of(paste0("Met_Syn_",c(1:5))),
                 Metabolic_Syndrome),function(x) case_when(x == "Yes" ~ 1,
                                                           x == "No" ~ 0,
                                                           TRUE ~ NA_real_))

