# The purpose of this file is to create a merged dictionary for the MESA cohort 
rm(list=ls()); gc(); source(".Rprofile")
source(url("https://raw.githubusercontent.com/jvargh7/functions/main/preprocessing/dictionary_file.R"))

library(haven)

#Exam 1 - 5 
ls_e1 <- list.files(paste0(path_mesa_folder,"/Primary/Exam1/Data"))
ls_e2 <- list.files(paste0(path_mesa_folder,"/Primary/Exam2/Data"))
ls_e3 <- list.files(paste0(path_mesa_folder,"/Primary/Exam3/Data"))
ls_e4 <- list.files(paste0(path_mesa_folder,"/Primary/Exam4/Data"))
ls_e5 <- list.files(paste0(path_mesa_folder,"/Primary/Exam5/Data"))




#regular expressions are used for text processing
ls_e1 <- ls_e1 [str_detect(ls_e1,"\\.sas7bdat")]
ls_e2 <- ls_e2 [str_detect(ls_e2,"\\.sas7bdat")]
ls_e3 <- ls_e3 [str_detect(ls_e3,"\\.sas7bdat")]
ls_e4 <- ls_e4 [str_detect(ls_e4,"\\.sas7bdat")]
ls_e5 <- ls_e5 [str_detect(ls_e5,"\\.sas7bdat")]




# map_dfr: Similar to lapply or apply
library(purrr)
library(dplyr)

e1_d <- map_dfr(ls_e1,
                function(l_w){
                  df = haven::read_sas(paste0(path_mesa_folder,"/Primary/Exam1/Data/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

e2_d <- map_dfr(ls_e2,
                function(l_w){
                  df = haven::read_sas(paste0(path_mesa_folder,"/Primary/Exam2/Data/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

e3_d <- map_dfr(ls_e3,
                function(l_w){
                  df = haven::read_sas(paste0(path_mesa_folder,"/Primary/Exam3/Data/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

e4_d <- map_dfr(ls_e4,
                function(l_w){
                  df = haven::read_sas(paste0(path_mesa_folder,"/Primary/Exam4/Data/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

e5_d <- map_dfr(ls_e5,
                function(l_w){
                  df = haven::read_sas(paste0(path_mesa_folder,"/Primary/Exam5/Data/",l_w))
                  dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                    mutate(dataset = l_w)
                })

bind_rows(e1_d %>% mutate(wave = "E1"),
          e2_d %>% mutate(wave = "E2"),
          e3_d %>% mutate(wave = "E3"),
          e4_d %>% mutate(wave = "E4"),
          e5_d %>% mutate(wave = "E5")) %>% 
  write_csv(.,paste0(path_mesa_folder,"/Primary/combined data dictionaries mesa.csv"))

view(e3_d)
view(e2_d)
view(e5_d)



