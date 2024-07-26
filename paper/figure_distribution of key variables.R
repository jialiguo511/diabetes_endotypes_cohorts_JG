rm(list=ls());gc();source(".Rprofile")

source("analysis/decan_analytic sample.R")

fig_A = analytic_dataset_cluster %>% 

  ggplot(data=.,aes(x=cluster_label,y=dmagediag,fill=cluster_label)) +
  geom_boxplot(position = position_dodge(width=0.9)) 

fig_A
