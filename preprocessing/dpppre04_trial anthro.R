vl_column1 = "f01"
vl_column2 = "f02"

data_path <- paste0(path_endotypes_folder,"/working/dpp/Data/DPP_Data_2008/Form_Data/Data")


s03 <- data_extract(study_name,"s03",data_path) %>% 
  dplyr::select(-visit) %>% 
  mutate(height = rowMeans(.[,c("bshght1","bshght2","bshght3")],na.rm = TRUE))


anthro <- bind_rows(data_extract(study_name,vl_column1,data_path),
                    data_extract(study_name,vl_column2,data_path))  %>% 
  mutate(quarter = case_when(visit %in% c("SCR","BAS") ~ 0,
                             visit %in% c("INT","CON","POV","WOV","WCV") ~ NA_real_,
                             str_detect(visit,"M") ~ str_replace(visit,"M","") %>% as.numeric(.)/3,
                             str_detect(visit,"Y") ~ str_replace(visit, "Y","") %>% as.numeric(.)*4,
                             TRUE ~ NA_real_
  ),
  semi = quarter/2) %>% 
  mutate(sbp = rowMeans(.[,c("sbp1","sbp2")],na.rm = TRUE),
         dbp = rowMeans(.[,c("dbp1","dbp2")],na.rm = TRUE),
         weight = rowMeans(.[,c("wght1","wght2","wght3")],na.rm = TRUE),
         wc = rowMeans(.[,c("wstc1","wstc2","wstc3")],na.rm = TRUE),
         hc = rowMeans(.[,c("hip1","hip2","hip3")],na.rm = TRUE),
         # subscap = rowMeans(.[,c("sfb1","sfb2","sfb3")],na.rm = TRUE),
         triceps = rowMeans(.[,c("sftr1","sftr2","sftr3")],na.rm = TRUE),
         iliac = rowMeans(.[,c("sfsi1","sfsi2","sfsi3")],na.rm = TRUE),
         abdominal = rowMeans(.[,c("sfab1","sfab2","sfab3")],na.rm = TRUE),
         medial = rowMeans(.[,c("sfmc1","sfmc2","sfmc3")],na.rm = TRUE)
  )  %>% 
  left_join(s03 %>% dplyr::select(study_id,height),
            by = "study_id")  %>% 
  mutate(bmi = weight/(height/100)^2)


  
