
# final_dataset_6c_mi_homa2.csv is from ?
# decan_kmeans01_data_6c_imputed with cluster labels.csv is from analysis/kmeans/decan_kmeans01_kmeans clustering.py



analytic_dataset_before_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_mi_homa2.csv"))
analytic_dataset_after_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_mi_imputed_homa2.csv"))
dec_an02 = read_csv(paste0(path_endotypes_folder,"/working/processed/dec_an02_kmeans_5var_mi_knn_cluster.csv")) %>% 
  dplyr::select(study_id,study,cluster)

analytic_dataset_cluster = dec_an02 %>% 
  left_join(analytic_dataset_before_imputation,
            by=c("study_id","study")) 
