
source("C:/code/external/functions/preprocessing/dictionary_file.R")

aric_w1_abi04 <- haven::read_sas(paste0(path_endotypes_folder,"/working/aric/Main_Study/v1/abi04.sas7bdat"))


ls_w1 <- list.files(paste0(path_endotypes_folder,"/working/aric/Main_Study/v1"))
#regular expressions are used for text processing
ls_w1 <- ls_w1[str_detect(ls_w1,"\\.sas7bdat")]

# map_dfr: Similar to lapply or apply
w1_dictionaries <- map_dfr(ls_w1,
                           function(l_w){
                             df = haven::read_sas(paste0(path_endotypes_folder,"/working/aric/Main_Study/v1/",l_w))
                             
                             dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                               mutate(dataset = l_w)
                             
                             
                           })



ls_w2 <- list.files(paste0(path_endotypes_folder,"/working/aric/Main_Study/v2"))
#regular expressions are used for text processing
ls_w2 <- ls_w2[str_detect(ls_w2,"\\.sas7bdat")]

# map_dfr: Similar to lapply or apply
w2_dictionaries <- map_dfr(ls_w2,
                           function(l_w){
                             df = haven::read_sas(paste0(path_endotypes_folder,"/working/aric/Main_Study/v2/",l_w))
                             
                             dictionary_file(df,type = "sas7bdat",name = l_w,return_dictionary = TRUE) %>% 
                               mutate(dataset = l_w)
                             
                             
                           })


bind_rows(w1_dictionaries %>% mutate(wave = "V1"),
          w2_dictionaries %>% mutate(wave = "V2"),
          ...) %>% 
  write_csv(.,paste0(path_endotypes_folder,"/working/aric/combined data dictionaries.csv"))