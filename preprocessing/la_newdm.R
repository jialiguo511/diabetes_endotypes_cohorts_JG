# the purpose of this R script is to create new DM cases for LA study
# LA recruited participants with T2D so all characteristics are extracted from baseline visit 
# created by Zhongyu Li on 29th Oct 2024 

rm(list=ls()); gc(); source(".Rprofile")


## Look Ahead [okay,no fasting insulin & glucose]
# cross-sectional ------------------------------
la_baseline<-readRDS(paste0(path_endotypes_folder,"/working/cleaned/la_baseline.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc, 
                uacr= uacr*1000)%>% 
  dplyr::select(study_id,female,race_eth,bsage,dmagediag,dmduration,
                alcohol,smoking,dmfamilyhistory,
                bmi,height,weight,sbp,dbp,
                hba1c,ldlc,hdlc,vldlc,tgl,ratio_th,glucosef,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr) 

la_newdm <- la_baseline[la_baseline$dmduration%in% c(0, 1), ] 
la_newdm$study = "look ahead" #N=877

# check 
la_newdm %>% 
  dplyr::filter((bsage-dmagediag) > 1) %>% 
  nrow()

la_newdm %>% 
  dplyr::filter((bsage-dmagediag) < 0) %>% 
  nrow()

saveRDS(la_newdm,paste0(path_endotypes_folder,"/working/cleaned/la_newdm.RDS"))


# longitudinal ------------------------------

la_dat_all <-readRDS(paste0(path_endotypes_folder,"/working/interim/la_dat_all.RDS")) %>% 
  dplyr::mutate(ratio_th=tgl/hdlc, 
                uacr= uacr*1000)%>% 
  dplyr::select(study_id,female,race_eth,bsage,dmagediag,dmduration,
                alcohol,smoking,dmfamilyhistory,
                bmi,height,weight,sbp,dbp,
                hba1c,ldlc,hdlc,vldlc,tgl,ratio_th,glucosef,
                serumcreatinine, urinealbumin, urinecreatinine,uacr,egfr) 

la_newdm_long <- la_dat_all[la_dat_all$dmduration%in% c(0, 1), ] 
la_newdm_long$study = "look ahead" #N=877

# check 
la_newdm_long %>% 
  dplyr::filter((bsage-dmagediag) > 1) %>% 
  nrow()

la_newdm_long %>% 
  dplyr::filter((bsage-dmagediag) < 0) %>% 
  nrow()

saveRDS(la_newdm_long,paste0(path_endotypes_folder,"/working/cleaned/la_newdm_long.RDS"))

