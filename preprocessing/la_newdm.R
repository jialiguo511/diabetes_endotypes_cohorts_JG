# the purpose of this R script is to create new DM cases for LA study
# LA recruited participants with T2D so all characteristics are extracted from baseline visit 
# created by Zhongyu Li on 29th Oct 2024 


rm(list=ls()); gc(); source(".Rprofile")


## Look Ahead [okay,no fasting insulin & glucose]

la<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/look_ahead.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc, 
                uacr= uacr*1000)%>% 
  dplyr::select(study_id,bmi,race_eth,hba1c,ldlc,hdlc,tgl,sbp,dbp,ratio_th,bsage,dmagediag,dmduration,female,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr) 

la_newdm <- la[la$dmduration%in% c(0, 1), ] 
la_newdm$study = "la" #N=877

# check 
la_newdm %>% 
  dplyr::filter((bsage-dmagediag) > 1) %>% 
  nrow()

la_newdm %>% 
  dplyr::filter((bsage-dmagediag) < 0) %>% 
  nrow()

saveRDS(la_newdm,paste0(path_endotypes_folder,"/working/cleaned/la_newdm.RDS"))
