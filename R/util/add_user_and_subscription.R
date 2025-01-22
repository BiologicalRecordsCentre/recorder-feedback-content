# Load required package
library(httr)

# Function to add a user
add_user <- function(api_url, external_key, name, email, auth_token) {
  response <- POST(
    url = paste0(api_url, "/users"),
    add_headers(Authorization = paste("Bearer", auth_token)),
    body = list(
      external_key = external_key,
      name = name,
      email = email
    ),
    encode = "json"
  )
  
  if (status_code(response) == 201) {
    message("User added successfully")
  } else {
    message("Failed to add user: ", content(response, "text"))
  }
}

# Function to subscribe a user to a list
subscribe_user <- function(api_url, external_key, list_id, auth_token) {
  response <- POST(
    url = paste0(api_url, "/users/", external_key, "/subscriptions"),
    add_headers(Authorization = paste("Bearer", auth_token)),
    body = list(
      list_id = list_id
    ),
    encode = "json"
  )
  
  if (status_code(response) == 201) {
    message("User subscribed successfully")
  } else {
    message("Failed to subscribe user: ", content(response, "text"))
  }
}

# Example usage
Sys.setenv(R_CONFIG_ACTIVE = "rsconnect")
config <- config::get()
api_url <- config$controller_app_base_url
auth_token <- config$controller_app_api_key

# who you want to add
external_key <- ""
name <- ""
email <- ""
list_id <- "1"


# Add user
add_user(api_url, external_key, name, email, auth_token)

# Subscribe user to list
subscribe_user(api_url, external_key, list_id, auth_token)
