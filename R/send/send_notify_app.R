
send_notify_app <- function(content_key, user_external_key, batch_id = NULL) {
  url <- paste0(config$controller_app_base_url,"items")
  
  body <- list(
    content_key = as.character(content_key),
    user_external_key = user_external_key,
    list_id = config$controller_app_list_id,
    batch_id = batch_id
  )
  
  response <- POST(url, body = body, encode = "json", add_headers(`x-access-token` = config$controller_app_api_key))
  
  if (status_code(response) == 201) {
    return(content(response))
  } else {
    stop("Failed to create item: ", content(response)$error)
  }
}

#test
if(F){
  library(httr)
  result <- send_notify_app(123, "42523", "batch_001")
  result
}
