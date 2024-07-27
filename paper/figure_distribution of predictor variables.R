rm(list=ls());gc();source(".Rprofile")

analytic_dataset_after_imputation = read_csv(paste0(path_endotypes_folder,"/working/processed/dec_an02_kmeans_5var_mi_knn_cluster.csv")) %>% 
  dplyr::select(study_id,study,cluster) %>% 
  left_join(read_csv(paste0(path_endotypes_folder,"/working/processed/final_dataset_6c_mi_imputed_homa2.csv")),
            by=c("study_id","study")) 

library(ggplot2)

fig_A = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=hba1c,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("HbA1c (%)") +
  scale_y_continuous(limits=c(0,20),breaks=seq(0,20,by=5)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_B = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=bmi,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab(bquote('BMI ( kg' /m^2~')')) +
  scale_y_continuous(limits=c(0,60),breaks=seq(0,60,by=10)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_C = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=dmagediag,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Age (years)") +
  scale_y_continuous(limits=c(0,100),breaks=seq(0,100,by=25)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_D = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=sbp,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Systolic BP (mmHg)") +
  scale_y_continuous(limits=c(0,300),breaks=seq(0,300,by=50)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_E = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=dbp,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Diastolic BP (mmHg)") +
  scale_y_continuous(limits=c(0,300),breaks=seq(0,300,by=50)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_F = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=ldlc,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("LDL cholesterol (mg/dL)") +
  scale_y_continuous(limits=c(0,600),breaks=seq(0,600,by=100)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_G = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=hdlc,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("HDL cholesterol (mg/dL)") +
  scale_y_continuous(limits=c(0,300),breaks=seq(0,300,by=50)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_H = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=tgl,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Triglycerides (mg/dL)") +
  scale_y_continuous(limits=c(0,600),breaks=seq(0,600,by=100)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

fig_I = analytic_dataset_after_imputation %>% 
  ggplot(data=.,aes(x=cluster,y=ratio_th,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Triglycerides-to-HDL") +
  scale_y_continuous(limits=c(0,10),breaks=seq(0,10,by=2)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors) +
  theme(axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 16))

library(ggpubr)

ggarrange(fig_A,
          fig_B,
          fig_C,
          fig_D,
          fig_E,
          fig_F,
          fig_G,
          fig_H,
          fig_I,
          nrow=3,
          ncol=3,
          common.legend = TRUE,legend = "none") %>% 
  ggsave(.,filename=paste0(path_endotypes_folder,"/figures/distribution of imputed predictor variables.jpg"),width=12,height = 8)
