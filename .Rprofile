
source("functions/data_extract.R")

require(tidyverse)

# Read about how .Rprofile is useful
# 
if(Sys.info()["user"] == "JVARGH7"){
  path_endotypes_folder <- "C:/Cloud/Emory University/li, zhongyu - Diabetes Endotypes Project (JV and ZL)"

}
if(Sys.info()["user"] == "ZLI854"){
  # This would need to be edited for ZL
  path_endotypes_folder <- "C:/Cloud/Emory University/li, zhongyu - Diabetes Endotypes Project (JV and ZL)"
}

duration_cutoff <- 1
lab_cutoff <- c(0:365)
# Example for Look AHEAD study on how to use relative paths
path_look_ahead_folder <- paste0(path_endotypes_folder,"/working/look ahead")
