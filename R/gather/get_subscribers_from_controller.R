# get_subscribers_from_controller
# Description:
# This function retrieves a list of subscribers from a specific email list by making an authenticated GET request to an API endpoint. It fetches the data, parses the JSON response, and converts it into a data frame for further use.
# 
# Arguments:
# api_url (string): The base URL of the API for the email controller service.
# email_list_id (string): The unique identifier for the email list from which to fetch subscribers.
# api_token (string): The API token for authenticating the GET request.
#
# Returns:
# A data.frame containing the list of subscribers. The returned columns include:
#   user_id: Unique identifier for each subscriber.
#   Other relevant fields from the JSON response, typically including email addresses or subscriber metadata.
#
# Error Handling:
# If the API request fails (i.e., the status code is not 200), the function stops execution and returns an error message showing the status code of the failed request.
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