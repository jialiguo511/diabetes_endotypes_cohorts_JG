
# The purpose of this file is to create a merged dictionary for ARIC cohort 

source(url("https://raw.githubusercontent.com/jvargh7/functions/main/preprocessing/dictionary_file.R"))

library(haven)

#Vist 1 - Visit6 

ls_v1 <- list.files(paste0(path_aric_folder,"/Main_Study/v1"))
ls_v2 <- list.files(paste0(path_aric_folder,"/Main_Study/v2"))
ls_v3 <- list.files(paste0(path_aric_folder,"/Main_Study/v3"))
ls_v4 <- list.files(paste0(path_aric_folder,"/Main_Study/v4"))
ls_v5 <- list.files(paste0(path_aric_folder,"/Main_Study/v5"))
ls_v6 <- list.files(paste0(path_aric_folder,"/Main_Study/v6"))

#regular expressions are used for text processing
ls_v1 <- ls_v1[str_detect(ls_v1,"\\.sas7bdat")]
ls_v2 <- ls_v2[str_detect(ls_v2,"\\.sas7bdat")]
ls_v3 <- ls_v3[str_detect(ls_v3,"\\.sas7bdat")]
ls_v4 <- ls_v4[str_detect(ls_v4,"\\.sas7bdat")]
ls_v5 <- ls_v5[str_detect(ls_v5,"\\.sas7bdat")]
ls_v6 <- ls_v6[str_detect(ls_v6,"\\.sas7bdat")]


# map_dfr: Similar to lapply or apply
library(purrr)
library(dplyr)

v1_d <- map_dfr(ls_v1,
                     function(l_w){
                      df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v1/",l_w))
                      dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                      mutate(dataset = l_w)
                           })


v2_d <- map_dfr(ls_v2,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v2/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })


v3_d <- map_dfr(ls_v3,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v3/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

v4_d <- map_dfr(ls_v4,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v4/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

v5_d <- map_dfr(ls_v5,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v5/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

v6_d <- map_dfr(ls_v6,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/v6/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })





#Longitudinal, three files, v1-v5 only  

ls_long <- list.files(paste0(path_aric_folder,"/Main_Study/Longitudinal"))
ls_long <- ls_long[str_detect(ls_long,"\\.sas7bdat")]

long_d <- map_dfr(ls_long,
                function(l_w){
                  df = haven::read_sas(paste0(path_aric_folder,"/Main_Study/Longitudinal/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })


bind_rows(v1_d %>% mutate(wave = "V1"),
          v2_d %>% mutate(wave = "V2"),
          v3_d %>% mutate(wave = "V3"),
          v4_d %>% mutate(wave = "V4"),
          v5_d %>% mutate(wave = "V5"),
          v6_d %>% mutate(wave = "V6"),
          long_d %>% mutate(wave = "V1-5")) %>% 
  write_csv(.,paste0(path_aric_folder,"/combined data dictionaries.csv"))

view(v1_d)
view(v2_d)
view(v4_d)
