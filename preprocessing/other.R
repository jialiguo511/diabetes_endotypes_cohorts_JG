## NOT working!! ###### NEED to KNOW WHY (?)
selected_ids <- aric_new[aric_new$visit == 1 & aric_new$age_diff >= 0 & aric_new$age_diff <= 1, "study_id"]

selected_ids <- aric_new %>%
  filter(between(age_diff, 0, 1)) %>%
  select(study_id)

selected_ids <- aric_new %>%
  dplyr::filter(between(totalc, 0, 200)) %>%
  select(study_id) %>% 
  pull()

selected_ids <- aric_new %>%
  filter(age_diff >= 0 & age_diff <= 1) %>%
  select(study_id)

selected_ids <- aric_new %>%
  dplyr::filter(totalc >= 0, totalc<=200) %>%
  select(study_id)

sum(is.na(aric_new$study_id))