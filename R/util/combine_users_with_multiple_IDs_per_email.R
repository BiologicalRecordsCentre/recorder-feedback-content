#this is a script to run if for each email there are multiple user_ids

config <- config::get()

users <- read.csv(config$participant_data_file)
records <- read.csv(config$data_file)

library(dplyr)

#hotfix
users %>% 
  group_by(email) %>% 
  summarise(user_id = first(user_id)) %>%
  write.csv(config$participant_data_file,row.names = F)



#create user_id child to user_id parent look up table



#apply lookup to data



#remove user_id child rows


