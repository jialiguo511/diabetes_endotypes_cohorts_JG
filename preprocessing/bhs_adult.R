## the purpose of this R file is to extract variables in the BHS cohort 
rm(list=ls()); gc(); source(".Rprofile")

library(haven)
library(dplyr)

# Read the SAS file into an R dataframe
z510rev3 <- read_sas(paste0(path_bhs_folder,"/Adult exam/z510rev3.sas7bdat"))
z510rev3_reversed<- z510rev3[, ncol(z510rev3):1]
write.csv(z510rev3_reversed,paste0(path_bhs_folder,"/Adult exam/z510rev3_reversed.csv"), row.names = FALSE)

bhs_full <- read.csv(paste0(path_bhs_folder,"/Adult exam/z510rev3_reversed.csv"))

bhs_drop <- bhs_full[0:8, ] #very strange values(n=8), remove from dataset 

bhs_temp <- bhs_full[9:nrow(bhs_full), ]

bhs_temp <- bhs_temp %>% rename(NEWID = newid)
write.csv(bhs_temp,paste0(path_bhs_folder,"/Adult exam/z510rev3.csv"), row.names = FALSE)


data_path1<- paste0(path_bhs_folder,"/Adult exam")

z510rev3<- data_extract("BHS","z510rev3",data_path1)










#check one pediatric data to see how many adults with diabetes
b900<-read_sas(paste0(path_bhs_folder,"/Pediatric Data/b900.sas7bdat"))
b900_18<-(b900[b900$AGE>18,])
#view(b900_18)
nrow(b900_18[b900_18$SD==1,]) #n=63, but no information on new or existing cases of DM. 

b600<-read_sas(paste0(path_bhs_folder,"/Pediatric Data/b600.sas7bdat"))

b600_18<-(b600[b600$AGE>18,])
nrow(b600_18[b600_18$SD==1,]) #n=78, but no information on new or existing cases of DM. 



