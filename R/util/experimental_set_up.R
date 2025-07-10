# This is a script for setting up a control/treatement experimental set up


set.seed(42)
library(readxl)
library(dplyr)

# Download the sign-up data from MS forms (as .xlsx)
# save it as data/ms_form_export.xlsx

#load it in
ms_form_export <- read_excel("data/ms_form_export.xlsx",
                             col_types = c("numeric", "skip", "skip","skip", "skip", "skip", "text","text", "text", "text"))

#clean the data
data_clean <-ms_form_export %>%
  select("id"="ID",
         "name" = "Name (to whom should your emails be addressed?)",
         "email" = "Email",
         "taxon" = "Taxonomic group that you'd like to receive your feedback about") %>%
  mutate(name = if_else(is.na(name),email,name)) 

#TODO: remove specific users if need be

treatment_groups <- c("control","group 1","group 2")

#clean taxon names
recorders <- data_clean %>% mutate(taxon = if_else(taxon=="Butterflies","butterflies","dragonflies"))

butterfly_recorders <- recorders %>%
  filter(taxon=="butterflies") %>%
  mutate(treatment = rep(treatment_groups,length.out =  nrow(filter(recorders,taxon=="butterflies"))))
  
dragonfly_recorders <- recorders %>%
  filter(taxon=="dragonflies") %>%
  mutate(treatment = rep(treatment_groups,length.out =  nrow(filter(recorders,taxon=="dragonflies"))))

all_recorders <- bind_rows(butterfly_recorders,dragonfly_recorders)

#check groupings
all_recorders %>% 
  group_by(taxon,treatment) %>% summarise(n())

#exclude controls
all_recorders <- filter(all_recorders, treatment != "control")

#get warehouse ID script (and save to config$participant_data_file)
write.csv(recorders,"data/users_no_key.csv")
source("R/util/get_warehouse_id_from_email.R")




