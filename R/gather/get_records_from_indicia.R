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
  #https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/docs/occurrences-document-structure.md
  
  query <-build_query(size = n_records,query_terms = list(metadata.created_by_id=user_warehouse_id),sort_terms = list(event.date_start = list(order = "desc")))
  
  #make the request
  records <- get_data_helper(base_url = base_url, auth_header = auth_header,query = query)
  records
}



# Test example (wrapped in an if block to avoid execution unless enabled)
if(F){
  library(curl)
  config <- config::get()
  
  indicia_warehouse_base_url <- Sys.getenv("INDICIA_WAREHOUSE_BASE_URL")
  indicia_warehouse_client_id <- Sys.getenv("INDICIA_WAREHOUSE_CLIENT_ID")
  indicia_warehouse_secret <- Sys.getenv("INDICIA_WAREHOUSE_SECRET")
  
  # Get subscribers and print the data frame
  data_df <- get_user_records_from_indicia(base_url = indicia_warehouse_base_url, 
                                           client_id = indicia_warehouse_client_id,
                                           shared_secret = indicia_warehouse_secret,
                                           user_warehouse_id = 50,
                                           n_records = 100)
  print(data_df)
  
  data_df$hits$hits$`_source`$identification$auto_checks$output
}



#' Build an Elasticsearch Query in R
#' 
#' This function constructs a JSON query for Elasticsearch, supporting must and should queries,
#' as well as aggregations and sorting.
#' 
#' @param size Integer. The number of results to return (default is 0).
#' @param query_terms List. Named list of terms for must queries (mandatory conditions).
#' @param query_terms_s List. Named list of terms for should queries (optional conditions).
#' @param agg_terms List. Named list of fields for aggregations.
#' @param agg_size Integer. The number of aggregation buckets to return (default is 0).
#' @param sort_terms List. Named list of sorting fields and order (e.g., list(field1 = "asc")).
#' @param print_json Logical. Whether to print the generated JSON query (default is FALSE).
#' 
#' @return A JSON-formatted query string.
#' @export
#' 
#' @examples
#' query <- build_query(size = 10, query_terms = list(field1 = "value1"), agg_terms = list(field2 = "field2"), sort_terms = list(field1 = "asc"))
#' cat(query)
#' 
build_query <- function(size = 0,
                        query_terms = list(),
                        query_terms_s = list(),
                        agg_terms = list(),
                        agg_size = 0,
                        sort_terms = list(),
                        print_json= F) {
  
  # Create the basic query structure
  q_r <- list(size = as.character(size))  # Convert size to character)
  
  # Add must queries (mandatory conditions for matching documents)
  if (length(query_terms) > 0) {
    for (i in 1:length(query_terms)){
      q_r$query$bool$must[[i]] <-
        list(term = list(temp_name = query_terms[[i]]))
      names(q_r$query$bool$must[[i]]$term) <- names(query_terms)[i]  # Assign field names correctly
    }
  }
  
  # Add should queries (optional conditions that boost relevance)
  if (length(query_terms_s) > 0) {
    for (i in 1:length(query_terms_s)){
      q_r$query$bool$should[[i]] <-
        list(term = list(temp_name = query_terms_s[[i]]))
      names(q_r$query$bool$should[[i]]$term) <- names(query_terms_s)[i]  # Assign field names correctly
    }
    
    # Ensure at least one "should" condition is met if present
    # Reference: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html#bool-min-should-match
    q_r$query$bool$minimum_should_match  <- 1  
  }
  
  # Add aggregations (grouping results based on field values)
  if (length(agg_terms) > 0) {
    for (i in 1:length(agg_terms)){
      if (!is.null(names(agg_terms)[i]) && !is.null(agg_terms[[i]])) {
        q_r$aggs[[names(agg_terms)[i]]] = list(terms = list(field = agg_terms[[i]], size = agg_size))
      }
    }
  }
  
  # Add sorting (ensure correct structure without extra brackets)
  if (length(sort_terms) > 0) {
    q_r$sort <- lapply(names(sort_terms), function(field) {
      setNames(list(order = sort_terms[[field]]), field)
    })
  }
  
  # Convert the query structure to a JSON string
  q <- toJSON(q_r, pretty = TRUE, auto_unbox = T) 
  
  # Print JSON output if print_json is TRUE
  if (print_json){
    print(q)
  }
  
  # Return the JSON query string
  q
}


#tests
if(F){
  query <- build_query(size = 10,query_terms = list(metadata.created_by_id="123953"),sort_terms = list(event.date_start = list(order = "desc")))
  #query <- paste0('{"size": "50","query":{"bool":{"must":[{"term":{"metadata.created_by_id":"1"}}]}},"sort":[{"event.date_start" : {"order" : "desc"}}]}')
  
  config <- config::get()
  auth_header <- paste('USER', config$indicia_warehouse_client_id, 'SECRET', config$indicia_warehouse_secret, sep = ':')
  get_data_helper(base_url = config$indicia_warehouse_base_url, auth_header = auth_header,query = query)
  
  
  
  query <- build_query(size = 1,query_terms = list(id="41050498"))
  #query <- paste0('{"size": "50","query":{"bool":{"must":[{"term":{"metadata.created_by_id":"1"}}]}},"sort":[{"event.date_start" : {"order" : "desc"}}]}')
  
  config <- config::get()
  auth_header <- paste('USER', config$indicia_warehouse_client_id, 'SECRET', config$indicia_warehouse_secret, sep = ':')
  test_data <- get_data_helper(base_url = config$indicia_warehouse_base_url, auth_header = auth_header,query = query)
  test_data$hits$hits$`_source`$metadata$created_by_id  
  
}
