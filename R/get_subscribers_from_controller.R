# Function to get subscribers from a specific email list
get_subscribers_from_controller <- function(api_url, email_list_id, api_token) {
  # Construct the full URL for the API endpoint
  full_url <- paste0(api_url, "lists/", email_list_id)
  
  # Make the GET request with authentication (if required)
  response <- GET(full_url, add_headers(Authorization = paste("Bearer", api_token)))
  
  # Check if the request was successful
  if (status_code(response) != 200) {
    stop("Failed to fetch data: ", status_code(response))
  }
  
  # Parse the JSON response
  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  
  # Convert the list of subscribers to a data frame
  subscribers_df <- as.data.frame(data$subscribers)
  subscribers_df <- subscribers_df[, c(2,4,1)] 
  names(subscribers_df)[1] <- "user_id"
  
  return(subscribers_df)
}

#test example
if(F){
  library(httr)
  library(jsonlite)
  library(config)
  config <- config::get()
  # Example usage
  api_url <- config$controller_app_base_url   # Replace with your API base URL
  email_list_id <- "1"            # Replace with your email list ID
  api_token <- config$controller_app_api_key  # Replace with your actual API token
  
  # Get subscribers and print the data frame
  subscribers_df <- get_subscribers_from_controller(api_url, email_list_id, api_token)
  print(subscribers_df)
}