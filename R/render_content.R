render_content <- function(template_file,user_params,user_id,batch_id,template_html){

  # build a uniaue file name
  filename <- basename(template_file) # Use basename to get the filename with extension
  filename <- sub("\\.\\w+$", "", filename) # Use regex to extract filename without extension
  out_file <- paste0(filename,"_",user_id,"_",Sys.Date(),".html")
  
  #check that all required computed objects are provided within user_params
  required_objects <- look_for_computed_objects(template_file)
  #background
  if(!is.null(required_objects$bg_computed_objects) & any(!(required_objects$bg_computed_objects %in% (names(user_params$bg_computed_objects))))){
    stop(
      paste0(
        "You have specified background precomputed objects in ",
        template_file,
        " but not all required prcomputed objects have been provided in user_params$bg_computed_objects. You have provided: \n",
        paste0(names(user_params$bg_computed_objects),collapse=", "),
        "\nbut the template requires: \n",
        paste0(required_objects$bg_computed_objects,collapse=", ")
        )
      )
  }
  
  #user
  if(!is.null(required_objects$user_computed_objects) & any(!(required_objects$user_computed_objects %in% (names(user_params$user_computed_objects))))){
    stop(
      paste0(
        "You have specified user precomputed objects in ",
        template_file,
        " but not all required prcomputed objects have been provided in user_params$user_computed_objects. You have provided: \n",
        paste0(names(user_params$user_computed_objects),collapse=", "),
        "\nbut the template requires: \n",
        paste0(required_objects$user_computed_objects,collapse=", ")
      )
    )
  }
  
  #set a temp directory for intermediate files in rendering
  temporary_directory <- tempdir() #per session temp directory
  
  #render the content
  render(template_file,
         output_file = out_file,
         output_dir = paste0("renders/",batch_id),
         output_format = email_format(template_html=template_html),
         params = user_params,
         quiet=T,
         intermediates_dir = temporary_directory,
         knit_root_dir = temporary_directory,
         envir = new.env()
         )
  
  #delete the temporary director
  unlink(temporary_directory, recursive = TRUE)
  
  #return the file name as in targets we're using format="file"
  paste0("renders/",batch_id,"/",out_file)
}