# Description:
# This helper function is responsible for sending a POST request to a specified URL using the curl package. It adds an authentication header and sends the query in the POST body. The function processes the response by converting the returned content from JSON format.
# 
# Arguments:
# base_url (string): The base URL of the API endpoint to which the request will be sent.
# auth_header (string): A string containing the authentication details (client ID and shared secret) formatted for the API.
# query (string): A string representing the query to be sent in the POST request.
get_data_helper <- function(base_url,auth_header,query){
  h <- new_handle()
  
  #add the authentication header
  handle_setheaders(h,
                    "Content-Type" = "application/json",
                    "Authorization" = auth_header
  )
  
  # add the query
  handle_setopt(h,postfields = query)
  
  req <- curl_fetch_memory(url = base_url,handle = h)
  fromJSON(rawToChar(req$content))
}


# get_user_records_from_indicia
# Description:
# This function retrieves a specified number of biodiversity records submitted by a user from the Indicia warehouse. It constructs an Elasticsearch query to filter records based on the user’s warehouse ID and sorts them in descending order based on the creation date.
# 
# Arguments:
# base_url (string): The base URL of the Indicia warehouse API.
# client_id (string): The client ID for authenticating with the Indicia warehouse.
# shared_secret (string): The shared secret for authentication.
# user_warehouse_id (numeric): The ID of the user whose records are to be fetched.
# n_records (numeric): The number of records to fetch.
#
# Returns:
#   A list of user records retrieved from the Indicia warehouse.
get_user_records_from_indicia <- function(base_url,client_id,shared_secret,user_warehouse_id,n_records){
  #create the authentication header
  auth_header <- paste('USER', client_id, 'SECRET', shared_secret, sep = ':')
  
  #generate the elasticsearchquery
  query <- paste0('{"size": "',n_records,'","query":{"bool":{"must":[{"term":{"metadata.created_by_id":"',user_warehouse_id,'"}}]}},"sort":[{"metadata.created_on" : {"order" : "desc"}}]}')
  
  #make the request
  records <- get_data_helper(base_url = base_url, auth_header = auth_header,query = query)
  records
}



# Test example (wrapped in an if block to avoid execution unless enabled)
if(F){
  library(curl)
  config <- config::get()
  
  # Get subscribers and print the data frame
  data_df <- get_user_records_from_indicia(base_url = config$indicia_warehouse_base_url, 
                                           client_id = config$indicia_warehouse_client_id,
                                           shared_secret = config$indicia_warehouse_secret,
                                           user_warehouse_id = 1,
                                           n_records = 1)
  print(data_df)
}

