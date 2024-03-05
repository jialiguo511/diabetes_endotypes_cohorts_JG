## the purpose of this R file is to extract variables from visits 1-6 in the ARIC cohort 

# Visit 1 

data_path_v1 <-  paste0(path_aric_folder,"/Main_study/v1/CSV")

vl_column <-c("anta","derive13","chma","sbpa02","hom","lipa","hmta")
for (vl in vl_column) {
  new_data<-data_extract("ARIC",vl,data_path_v1)
  assign(vl, new_data)
  rm(new_data)
}


# Visit 2 

data_path_v2 <-  paste0(path_aric_folder,"/Main_study/v2/CSV")
vl_column2 <-c("derive2_10","hhxb","antb","sbpb02","chmb","lipb","hmtb")
for (vl in vl_column2) {
  new_data<-data_extract("ARIC",vl,data_path_v2)
  assign(vl, new_data)
  rm(new_data)
}


# Visit 3

data_path_v3 <-  paste0(path_aric_folder,"/Main_study/v3/CSV")
vl_column3 <-c("amha02","derive37","lipc04","hemc31","msrc04","phxa04","antc04","sbpc04_02","hmtcv301")
for (vl in vl_column3) {
  new_data<-data_extract("ARIC",vl,data_path_v3)
  assign(vl, new_data)
  rm(new_data)
}

# Visit 4 

data_path_v4 <-  paste0(path_aric_folder,"/Main_study/v4/CSV")
vl_column4 <-c("derive47","phxb04","antd05","sbpd04_02","hmtcv401","lipd04","gtsa04","msrd04")
for (vl in vl_column4) {
  new_data<-data_extract("ARIC",vl,data_path_v4)
  assign(vl, new_data)
  rm(new_data)
}


# Visit 5 

data_path_v5 <-  paste0(path_aric_folder,"/Main_study/v5/CSV")
vl_column5 <-c("derive_ncs51","status51","rex","ant","sbp","cbc","lip","chm")
for (vl in vl_column5) {
  new_data<-data_extract("ARIC",vl,data_path_v5)
  assign(vl, new_data)
  rm(new_data)
}


rex <- read_csv(paste0(path_aric_folder,"/Main_study/v5/CSV/rex.csv")) 
ant <- read_csv(paste0(path_aric_folder,"/Main_study/v5/CSV/ant.csv")) 


# Visit 6 
data_path_v6 <-  paste0(path_aric_folder,"/Main_study/V6/CSV")
vl_column6 <-c("derive61","status61","chem2","lipf")
for (vl in vl_column6) {
  new_data<-data_extract("ARIC",vl,data_path_v6)
  assign(vl, new_data)
  rm(new_data)
}

## these two need to be extracted and renamed: "ant" and "sbp" for V6 


