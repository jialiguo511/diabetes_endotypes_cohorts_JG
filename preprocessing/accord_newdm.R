# The purpose of this file is to filter new DM cases from the ACCORD trial. 
# ACCORD trial recruited DM patients, therefore all patients' characteristics are extracted from baseline visit 
# created by Zhongyu Li, 10.29.24 

## ACCORD [okay,no fasting insulin]
# cross-sectional --------------------------
accord_baseline<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/accord_baseline.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                bmi = weight/((height/100)^2)
  )%>% 
  dplyr::select(study_id,female,race_eth,bsage,dmagediag,dmduration,
                alcohol,smoking,weight,height,bmi,wc,sbp,dbp,
                hba1c,glucosef,totalc,ldlc,hdlc,vldlc,tgl,ratio_th,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr,alt) # no fasting insulin; fasting glucose in mg/gl 

accord_newdm <-accord_baseline[accord_baseline$dmduration%in% c(0, 1), ] 
accord_newdm$study = "accord" #N=601 

# check 
accord_newdm %>% 
  dplyr::filter((bsage-dmagediag) > 1) %>% # note that dmagediag is created by bsage - dmduration
  nrow()

accord_newdm %>% 
  dplyr::filter((bsage-dmagediag) < 0) %>% 
  nrow()

saveRDS(accord_newdm,paste0(path_endotypes_folder,"/working/cleaned/accord_newdm.RDS"))

# longitudinal --------------------------
accord_dat_all<-readRDS(paste0(path_endotypes_folder,"/working/interim/accord_dat_all.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc,
                bmi = weight/((height/100)^2)
  )%>% 
  dplyr::select(study_id,female,race_eth,bsage,dmagediag,dmduration,
                alcohol,smoking,weight,height,bmi,wc,sbp,dbp,
                hba1c,glucosef,totalc,ldlc,hdlc,vldlc,tgl,ratio_th,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr,alt) # no fasting insulin; fasting glucose in mg/gl 

accord_newdm_long <-accord_dat_all[accord_dat_all$dmduration%in% c(0, 1), ] 
accord_newdm_long$study = "accord" #N=601 

saveRDS(accord_newdm_long,paste0(path_endotypes_folder,"/working/cleaned/accord_newdm_long.RDS"))

