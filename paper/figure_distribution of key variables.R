rm(list=ls());gc();source(".Rprofile")

source("analysis/decan_analytic sample.R")

library(ggplot2)

fig_A = analytic_dataset_cluster %>% 
  ggplot(data=.,aes(x=cluster,y=hba1c,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("HbA1c (%)") +
  scale_y_continuous(limits=c(0,20),breaks=seq(0,20,by=5)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors)

fig_B = analytic_dataset_cluster %>% 
  ggplot(data=.,aes(x=cluster,y=bmi,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab(bquote('BMI ( kg' /m^2~')')) +
  scale_y_continuous(limits=c(0,60),breaks=seq(0,60,by=10)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors)

fig_C = analytic_dataset_cluster %>% 
  ggplot(data=.,aes(x=cluster,y=dmagediag,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("Age (years)") +
  scale_y_continuous(limits=c(0,100),breaks=seq(0,100,by=25)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors)


fig_D = analytic_dataset_cluster %>% 
  ggplot(data=.,aes(x=cluster,y=homa2b,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("HOMA2-B (%)") +
  scale_y_continuous(limits=c(0,1000),breaks=seq(0,1000,by=100)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors)
fig_E = analytic_dataset_cluster %>% 
  ggplot(data=.,aes(x=cluster,y=homa2ir,fill=cluster)) +
  geom_boxplot(position = position_dodge(width=0.9)) +
  xlab("") +
  ylab("HOMA2-IR") +
  scale_y_continuous(limits=c(0,30),breaks=seq(0,30,by=10)) +
  theme_bw() +
  scale_fill_manual(name="",values=cluster_colors)

library(ggpubr)

ggarrange(fig_A,
          fig_B,
          fig_C,
          fig_D,
          fig_E,
          nrow=1,
          ncol=5,
          common.legend = TRUE,legend = "none") %>% 
  ggsave(.,filename=paste0(path_endotypes_folder,"/figures/distribution of key variables.jpg"),width=12,height = 5)
