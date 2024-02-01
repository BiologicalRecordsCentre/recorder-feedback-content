library(targets)
library(tarchetypes)

tar_option_set(packages = c("dplyr", "ggplot2","rmarkdown","blastula"))

#load functions needed
source("R/render_content.R")
source("R/do_computations.R")
source("R/make_meta_table.R")

#get configuration from config.yml
config <- config::get()

#set up static branching by user
raw_data_pre <- read.csv(config$data_file) #read data
users <- unique(raw_data_pre$recorder) #identify users
values <- data.frame(recorder_name = users) #values for static branching

#batch identifier
batch_id <- format(Sys.time(),"%s")
batch_id <- "test_001"

# mapping for static branching
mapping <- tar_map(
  values = values,
  tar_target(user_data, filter(raw_data,recorder == recorder_name)), #generate a df for the user's recording activity
  
  #do any computations on the user data
  tar_target(user_computed_objects,do_computations(computation = computation_file_user, records_data=user_data)),
  
  #render the content
  tar_target(data_story_content, 
             render_content(
               template_file = template_file,
               user_params = list(user_name = recorder_name,
                                  user_data = user_data,
                                  user_computed_objects = user_computed_objects,
                                  bg_data = raw_data,
                                  bg_computed_objects = bg_computed_objects
                                  ),
               user_id = recorder_name,
               batch_id = batch_id
               ),
             format="file") # create the content as html
)

# construct pipeline
list(
  #this links to the full (all records) data file
  tar_target(raw_data_file, config$data_file, format = "file"),
  
  #this links to the email template file, an R markdown file
  tar_target(template_file,config$template_file, format = "file"),
  
  #this links to the computation file applied to all data
  tar_target(computation_file,config$computation_script_bg, format = "file"),
  
  #this links to the computation script that is applied to the user (this might be the same as the script above)
  tar_target(computation_file_user,config$computation_script_user, format = "file"),
  
  #reading in the raw data to R object
  tar_target(raw_data, read.csv(raw_data_file)),
  
  #carry out the computations on the whole dataset
  tar_target(bg_computed_objects,do_computations(computation = computation_file, records_data=raw_data)),
  
  #do jobs across all users
  mapping,
  
  #create a dataframe of users and their email files
  tar_combine(meta_table,
              mapping$data_story_content,
              command = make_meta_table(c(!!!.x),batch_id),
              use_names = T,
              format="file")
)

