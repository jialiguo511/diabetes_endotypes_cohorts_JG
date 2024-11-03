
# final_dataset_6c_mi_homa2.csv is from ? --> before imputation, with HOMA2 added. 
# decan_kmeans01_data_6c_imputed with cluster labels.csv is from analysis/kmeans/decan_kmeans01_kmeans clustering.py



analytic_dataset_before_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_clean_mi.csv"))
analytic_dataset_after_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_clean_mi_imputed_homa2.csv"))
dec_an02 = read_csv(paste0(path_endotypes_folder,"/working/processed/dec_an01_kmeans_5var_cluster_cc_clean.csv")) %>% 
  dplyr::select(study_id,study,cluster)

analytic_dataset_cluster = dec_an02 %>% 
  left_join(analytic_dataset_before_imputation,
            by=c("study_id","study")) 
