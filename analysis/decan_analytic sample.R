
# final_dataset_6c_mi_homa2.csv is from ?
# decan_kmeans01_data_6c_imputed with cluster labels.csv is from analysis/kmeans/decan_kmeans01_kmeans clustering.py


analytic_dataset_before_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_mi_homa2.csv"))
analytic_dataset_after_imputation <- read_csv(paste0(path_endotypes_folder,"/working/processed/decan_kmeans01_data_6c_imputed with cluster labels.csv"))

analytic_dataset_cluster = analytic_dataset_after_imputation %>% 
  dplyr::select(study_id,study,cluster) %>% 
  left_join(analytic_dataset_before_imputation,
            by=c("study_id","study")) %>% 
  mutate(cluster_label = factor(cluster,levels=c(0:3),labels=cluster_labels))