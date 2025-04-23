# Load required libraries
library(httr)
library(jsonlite)
library(curl)

# Load configuration
config <- config::get()

# Helper function to check HTTP connectivity
check_http_connection <- function(url, headers = list(), query = list()) {
  tryCatch({
    res <- httr::GET(url, add_headers(.headers = headers), query = query, timeout(10))
    if (res$status_code >= 200 && res$status_code < 300) {
      print(sprintf("✅ Successfully connected to %s", url))
      return(TRUE)
    } else {
      stop(sprintf("❌ Failed to connect to %s. Status code: %s", url, res$status_code))
      return(FALSE)
    }
  }, error = function(e) {
    stop(sprintf("❌ Error connecting to %s: %s", url, e$message))
    return(FALSE)
  })
}

# 1. Test connection to Controller App (if enabled)
if (isTRUE(config$gather_from_controller_app)) {
  print("🔎 Testing Controller App API connection...")
  test_url <- paste0(config$controller_app_base_url, "lists")
  check_http_connection(
    url = test_url,
    headers = c(
      "Authorization" = paste("Bearer", config$controller_app_api_key)
    ),
    query = list(list_id = config$controller_app_list_id)
  )
}

# 2. Test connection to Indicia Warehouse (if enabled)
source("R/gather/get_records_from_indicia.R")

test_indicia_elasticsearch_connection <- function(base_url, client_id, shared_secret) {
  print("🔎 Testing Indicia Warehouse Elasticsearch connection...")
  
  # Create header
  auth_header <- paste('USER', client_id, 'SECRET', shared_secret, sep = ':')
  
  # Minimal test query: fetch 1 record from any user
  test_query <- build_query(size = 1,query_terms = list(metadata.created_by_id="1"))
  
  # Use get_data_helper to make the test call
  tryCatch({
    result <- get_data_helper(base_url, auth_header, test_query)
    if (!is.null(result$hits$total$value) && result$hits$total$value >= 0) {
      print("✅ Indicia Elasticsearch API is reachable and returned results.")
    } else {
      stop("⚠️ Indicia Elasticsearch responded but did not return expected structure.")
    }
  }, error = function(e) {
    stop(sprintf("❌ Failed to connect to Indicia Elasticsearch: %s", e$message))
  })
}

if (isTRUE(config$gather_from_indicia)) {
  test_indicia_elasticsearch_connection(
    base_url = config$indicia_warehouse_base_url,
    client_id = config$indicia_warehouse_client_id,
    shared_secret = config$indicia_warehouse_secret
  )
}

#3. test email
library(blastula)
test_message <- prepare_test_message()

if(config$mail_creds == "envvar"){
  Sys.setenv(SMTP_PASSWORD = config$mail_password)
  creds <- creds_envvar(
    user = config$mail_username,
    pass_envvar = "SMTP_PASSWORD",
    host = config$mail_server,
    port = config$mail_port,
    use_ssl = config$mail_use_ssl)
}

if(config$mail_creds == "anonymous"){
  creds <- creds_anonymous(host = config$mail_server,port=config$mail_port,use_ssl = config$mail_use_ssl)
}

tryCatch({
  smtp_send(test_message,
            from = config$mail_default_sender,
            to = config$mail_test_recipient,
            subject = "Test Email",
            credentials = creds,
            verbose = TRUE)
  print("✅ SMTP test email successfully sent to: ", config$mail_test_recipient)
}, error = function(e) {
  stop("❌ Failed to send test email: ", e$message)
})

print("✅ All connection tests completed.")
