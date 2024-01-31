library(targets)
library(tarchetypes)

tar_option_set(packages = c("dplyr", "ggplot2","rmarkdown","blastula"))

#load functions needed
source("R/render_content.R")
source("R/do_computations.R")

#set up static banching by user
raw_data_pre <- read.csv("data/simulated_data_raw.csv") #read data
users <- unique(raw_data_pre$recorder) #identify users
values <- data.frame(recorder_name = users) #values for static branching

# mapping for static branching
mapping <- tar_map(
  values = values,
  tar_target(user_data, filter(raw_data,recorder == recorder_name)), #generate a df for the user's recording activity
  
  #do any computations on the user data
  tar_target(user_computed_objects,do_computations(computation = computation_file_user, bg_data=user_data)),
  
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
               user_id = recorder_name
               ),
             format="file") # create the content as html
)

# construct pipeline
list(
  #this links to the full (all records) data file
  tar_target(raw_data_file, "data/simulated_data_raw.csv", format = "file"),
  
  #this links to the email template file, an R markdown file
  tar_target(template_file,"templates/example.Rmd", format = "file"),
  
  #this links to the computation file
  tar_target(computation_file,"R/computations/computations_example.R", format = "file"),
  
  #this links to the computation script that is applied to the user (this might be the same as the script above)
  tar_target(computation_file_user,"R/computations/computations_example.R", format = "file"),
  
  #reading in the raw data to R object
  tar_target(raw_data, read.csv(raw_data_file)),
  
  #carry out the computations on the whole dataset
  tar_target(bg_computed_objects,do_computations(computation = computation_file, bg_data=raw_data)),
  
  #do jobs across all users
  mapping
)

