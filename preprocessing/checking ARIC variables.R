## The purpose of this file is to check variables in the ARIC dataset
## Decisions should be documented 
## created by Zhongyu, March 2024 


###### V1 
#CHMA09, not sure if serum or urine creatinine, use for serum for now 


##### V2 
#CHMB08, not sure if serum or urine creatinine, use for serum for now 


###### V4
## Check LDL in V4 
derive47 <- read_csv(paste0(path_aric_folder, "/Main_Study/v4/CSV/derive47.csv")) 
summary(derive47$LDL41)
lipd04 <- read_csv(paste0(path_aric_folder, "/Main_Study/v4/CSV/lipd04.csv")) 
summary(lipd04$LIPD8) # similar, use LIPD8

#LIPD6A, not sure if serum or urine creatinine, use for serum for now 

####### V5 
#Weight in V5: ANT4 from ant is in kg, not lb

#unit of HbA1c in V5 = g/DL, other might be % 

####### V6 
#Weight in V6, ANT4 from ant is in kg, not lb 

#unit of HbA1c in V5 = g/DL, other might be % 

###### OTHER 

