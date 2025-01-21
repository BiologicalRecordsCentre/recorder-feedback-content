#' Look in the R Markdown template and identify computed objects required in the code to render the template.
#'
#' This function reads an R Markdown template file and identifies computed objects used in the code. It specifically looks for background computed objects (`params$bg_computed_objects$`) and user computed objects (`params$user_computed_objects$`).
#'
#' @param file_path_to_template The file path to the R Markdown template.
#'
#' @return A list containing two elements:
#' \itemize{
#'   \item \code{bg_computed_objects}: A character vector representing unique computed objects following "params$bg_computed_objects$".
#'   \item \code{user_computed_objects}: A character vector representing unique computed objects following "params$user_computed_objects$".
#' }
#'
#' @export
look_for_computed_objects <- function(file_path_to_template){
  lines_read <- readLines(file_path_to_template)
  
  # find background computed objects
  input_vector <- lines_read[lines_read %>% lapply(FUN=grepl,pattern= "params\\$bg_computed_objects")  %>% unlist()]
  
  # Function to extract occurrences following "params$bg_computed_objects$"
  extract_occurrences <- function(input_string) {
    matches <- regmatches(input_string, gregexpr("(?<=params\\$bg_computed_objects\\$)\\w+", input_string, perl=TRUE))[[1]]
    return(matches)
  }
  
  # Apply the function to each string in the vector
  result_list_bg <- lapply(input_vector, extract_occurrences) %>% unlist() %>% unique()
  
  
  # find user computed objects
  input_vector <- lines_read[lines_read %>% lapply(FUN=grepl,pattern= "params\\$user_computed_objects")  %>% unlist()]
  # Function to extract occurrences following "params$user_computed_objects$"
  extract_occurrences <- function(input_string) {
    matches <- regmatches(input_string, gregexpr("(?<=params\\$user_computed_objects\\$)\\w+", input_string, perl=TRUE))[[1]]
    return(matches)
  }
  # Apply the function to each string in the vector
  result_list_user <- lapply(input_vector, extract_occurrences) %>% unlist() %>% unique()

  list(bg_computed_objects = result_list_bg,user_computed_objects = result_list_user)
}
