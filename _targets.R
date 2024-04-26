library(targets)
library(tarchetypes)
library(assertr)

#distributed computing set up
library(crew)
tar_option_set(
  controller = crew_controller_local(workers = 4)
)

tar_option_set(packages = c("dplyr", "ggplot2","rmarkdown"))

#load functions needed
source("R/render_content.R")
source("R/do_computations.R")
source("R/make_meta_table.R")
source("R/look_for_computed_objects.R")
source("R/email_format.R")

#read in data files
#get configuration from config.yml
config <- config::get()
Sys.setenv(RSTUDIO_PANDOC=config$pandoc_path) #pandoc path
users <- read.csv(config$participant_data_file) #user data
data_file <- read.csv(config$data_file) #raw species data

#assertions to ensure the data is all there
#users |> verify(has_all_names("user_id", "name", "email"))
#data_file |> verify(has_all_names("latitude","longitude","species","date"))

#set up static branching by user
names(users) <- paste0(names(users),"_") #apply an underscore to after the name to differentiate it
values <- users #values for static branching

#batch identifier
batch_id <- format(Sys.time(),"%s")
batch_id <- "test_001"

# mapping for static branching
mapping <- tar_map(
  values = values,
  names = user_id_,
  
  tar_target(user_data, filter(raw_data,user_id == user_id_)), #generate a df for the user's recording activity
  
  #do any computations on the user data
  tar_target(user_computed_objects,do_computations(computation = computation_file_user, records_data=user_data)),
  
  #render the content
  tar_target(data_story_content, 
             render_content(
               template_file = template_file,
               user_params = list(user_name = name_,
                                  user_email = email_,
                                  user_data = user_data,
                                  user_computed_objects = user_computed_objects,
                                  bg_data = raw_data,
                                  bg_computed_objects = bg_computed_objects
                                  ),
               user_id = user_id_,
               batch_id = batch_id,
               template_html = template_html_file
               ),
             format="file"), # create the content as html
  
  tar_target(meta_data,list(user_id = user_id_,file = data_story_content))
)

# construct pipeline
list(
  #this links to the full (all records) data file
  tar_target(raw_data_file, config$data_file, format = "file"),
  
  #this links to the email template file, an R markdown file
  tar_target(template_file,paste0(getwd(),"/",config$default_template_file), format = "file"),
  
  #this links to the html template file
  tar_target(template_html_file,paste0(getwd(),"/",config$template_html_file), format = "file"),
  
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
              mapping$meta_data,
              command = make_meta_table(list(!!!.x),batch_id),
              use_names = T,
              format="file"
              )
)


