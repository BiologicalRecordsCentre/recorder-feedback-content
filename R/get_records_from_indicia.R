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



get_user_records_from_indicia <- function(base_url,client_id,shared_secret,user_warehouse_id,n_records){
  #create the authentication header
  auth_header <- paste('USER', client_id, 'SECRET', shared_secret, sep = ':')
  
  #generate the elasticsearchquery
  query <- paste0('{"size": "',n_records,'","query":{"bool":{"must":[{"term":{"metadata.created_by_id":"',user_warehouse_id,'"}}]}},"sort":[{"metadata.created_on" : {"order" : "desc"}}]}')
  
  #make the request
  records <- get_data_helper(base_url = base_url, auth_header = auth_header,query = query)
  records
}



#test example
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

