#PREP
#generating batch_id
batch_id <- paste0(Sys.Date(),"-",paste(sample(letters,10),collapse = ""))

#load packages
library(httr)
library(jsonlite)
library(curl)

#load configuration from config.yml using config package
config <- config::get()
