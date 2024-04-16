# The purpose of this file is to create a merged dictionary for CARDIA cohort 

source(url("https://raw.githubusercontent.com/jvargh7/functions/main/preprocessing/dictionary_file.R"))

library(haven)

#Vist 1 - Visit6 

ls_y0 <- list.files(paste0(path_cardia_folder,"/Y00/DATA"))
ls_y2 <- list.files(paste0(path_cardia_folder,"/Y02/DATA"))
ls_y5 <- list.files(paste0(path_cardia_folder,"/Y05/DATA"))
ls_y7 <- list.files(paste0(path_cardia_folder,"/Y07/DATA"))
ls_y10 <- list.files(paste0(path_cardia_folder,"/Y10/DATA"))
ls_y15 <- list.files(paste0(path_cardia_folder,"/Y15/DATA"))
ls_y20 <- list.files(paste0(path_cardia_folder,"/Y20/DATA"))
ls_y25 <- list.files(paste0(path_cardia_folder,"/Y25/DATA"))
ls_y30 <- list.files(paste0(path_cardia_folder,"/Y30/DATA"))

#regular expressions are used for text processing
ls_y0 <- ls_y0 [str_detect(ls_y0,"\\.sas7bdat")]
ls_y2 <- ls_y2[str_detect(ls_y2,"\\.sas7bdat")]
ls_y5 <- ls_y5[str_detect(ls_y5,"\\.sas7bdat")]
ls_y7 <- ls_y7[str_detect(ls_y7,"\\.sas7bdat")]
ls_y10 <- ls_y10[str_detect(ls_y10,"\\.sas7bdat")]
ls_y15 <- ls_y15[str_detect(ls_y15,"\\.sas7bdat")]
ls_y20 <- ls_y20[str_detect(ls_y20,"\\.sas7bdat")]
ls_y25 <- ls_y25[str_detect(ls_y25,"\\.sas7bdat")]
ls_y30 <- ls_y30[str_detect(ls_y30,"\\.sas7bdat")]


# map_dfr: Similar to lapply or apply
library(purrr)
library(dplyr)

y0_d <- map_dfr(ls_y0,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y00/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

y2_d <- map_dfr(ls_y2,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y02/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })


y5_d <- map_dfr(ls_y5,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y05/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

y7_d <- map_dfr(ls_y7,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y07/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })


y10_d <- map_dfr(ls_y10,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y10/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

y15_d <- map_dfr(ls_y15,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y15/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

y20_d <- map_dfr(ls_y20,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y20/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

y25_d <- map_dfr(ls_y25,
                function(l_w){
                  df = haven::read_sas(paste0(path_cardia_folder,"/Y25/DATA/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })


y30_d <- map_dfr(ls_y30,
                 function(l_w){
                   df = haven::read_sas(paste0(path_cardia_folder,"/Y30/DATA/",l_w))
                   dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                     mutate(dataset = l_w)
                 })

bind_rows(y0_d %>% mutate(wave = "Y0"),
          y2_d %>% mutate(wave = "Y2"),
          y5_d %>% mutate(wave = "Y5"),
          y7_d %>% mutate(wave = "Y7"),
          y10_d %>% mutate(wave = "Y10"),
          y15_d %>% mutate(wave = "Y15"),
          y20_d %>% mutate(wave = "Y20"),
          y25_d %>% mutate(wave = "Y25"),
          y30_d %>% mutate(wave = "Y30"),
          ) %>% 
  write_csv(.,paste0(path_cardia_folder,"/combined data dictionaries cardia.csv"))

view(y10_d)
view(y30_d)
