render_content <- function(template_file,user_params,user_id){

  # build a uniaue file name
  
  filename <- basename(template_file) # Use basename to get the filename with extension
  
  filename <- sub("\\.\\w+$", "", filename) # Use regex to extract filename without extension
  
  out_file <- paste0(filename,"_",user_id,"_",Sys.Date(),".html")
  
  render(template_file,
         output_file = out_file,
         output_dir = "renders",
         params = user_params,
         quiet=T)
  
  paste0("renders/",out_file)
}