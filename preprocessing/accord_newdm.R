# The purpose of this file is to filter new DM cases from the ACCORD trial. 
# ACCORD trial recruited DM patients, therefore all patients' characteristics are extracted from baseline visit 
# created by Zhongyu Li, 10.29.24 

## ACCORD [okay,no fasting insulin]
accord<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/accord.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                bmi = weight/((height/100)^2)
  )%>% 
  dplyr::select(study_id,bmi,hba1c,glucosef,ldlc,hdlc,tgl,sbp,dbp,ratio_th,female,race_eth,bsage,dmagediag,dmduration,
                serumcreatinine, urinealbumin, urinecreatinine, uacr, egfr, alt,totalc) # no fasting insulin; fasting glucose in mg/gl 

accord_newdm <-accord[accord$dmduration%in% c(0, 1), ] 
accord_newdm$study = "accord" #N=601 

# check 
accord_newdm %>% 
  dplyr::filter((bsage-dmagediag) > 1) %>% # note that dmagediag is created by bsage - dmduration
  nrow()

accord_newdm %>% 
  dplyr::filter((bsage-dmagediag) < 0) %>% 
  nrow()

saveRDS(accord_newdm,paste0(path_endotypes_folder,"/working/cleaned/accord_newdm.RDS"))
