# the purpose of this R file is to identify new DM cases and extract variables within one year after the diagnosis in the ARIC cohort
# final dataset should be named as aric_newdm.rds

#### workflow for cohorts: ARIC, JHS, MESA and CARDIA ### 
# key variables: age at study visit [age]; age at diagnosis [dmagediag];self reported DM; lab measurements
# step 0: if age at diagnosis [dmagediag] is known, we will use the minimal dmagediag as the dmagediag for ALL participants for all visits
# step 1: Identify baseline DM cases in VISIT #1: These participants will be categorized as existing DM and will be removed from the dataset.
## 1) [dmduration] = [age]-[dmagediag] >=2 --> baseline DM = 1 
## 2) self report DM = 1 & [dmduration] !=0 or 1 --> baseline DM = 1 
## 3) other conditions --> baseline DM = 0 
# step 2: in VISIT#1 to last VISIT: identify new DMs by [dmduration], self-reported DM, and lab cutoffs
## 1) [dmduration] = [age]-[dmagediag] >=2 --> new_dm = 0 
## 2) [dmduration] = [age]-[dmagediag] = 1 --> new_dm = 1 
## 3) self reported DM = 1 --> new_dm =1 
## 4) meeting lab cutoffs --> new_dm = 1 



