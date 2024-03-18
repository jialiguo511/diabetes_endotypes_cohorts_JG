## The purpose of this file is to check variables in the ARIC dataset
## Decisions should be documented 
## created by Zhongyu, March 2024 


###### V1 
#CHMA09, not sure if serum or urine creatinine, use for serum for now 
#Change weight unit to kg from lb

##### V2 
#CHMB08, not sure if serum or urine creatinine, use for serum for now 
#Change weight unit to kg from lb
# NO insulin 


###### V4
## Check LDL in V4 
derive47 <- read_csv(paste0(path_aric_folder, "/Main_Study/v4/CSV/derive47.csv")) 
summary(derive47$LDL41)
lipd04 <- read_csv(paste0(path_aric_folder, "/Main_Study/v4/CSV/lipd04.csv")) 
summary(lipd04$LIPD8) # similar, use LIPD8

#LIPD6A, not sure if serum or urine creatinine, use for serum for now 
#insulin no unit, compared with V1, uu/mol most likely 

####### V5 
#Weight in V5: ANT4 from ant is in kg, not lb


####### V6 
#Weight in V6, ANT4 from ant is in kg, not lb 



###### OTHER 
# remove all hba1c variables for V1-V4,they are all HBG, not HbA1 (3.14.24)

