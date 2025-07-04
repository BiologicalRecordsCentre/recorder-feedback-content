#see R/gather/gather_poms for more information on the database connection.

print("Loading R packages...")
library(RJDBC)
library(dplyr)
config <- config::get()

print("Loading JDBC driver...")
drv <- JDBC(driverClass = "org.postgresql.Driver",classPath = Sys.getenv("JAVA_PATH"))

print("Connecting to database...")
con <- dbConnect(
  drv,
  Sys.getenv("DB_CONNECTION"),
  Sys.getenv("DB_USERNAME"),
  Sys.getenv("DB_PASSWORD")
)

print("Loading subscribers...")
user_data <- read.csv("data/users_no_key.csv") %>% mutate(email = tolower(email))
email_list <- paste(sprintf("'%s'", user_data$email), collapse = ", ") # Collapse into a single string with properly quoted values

print("Building query...")
query <- readLines("sql/warehouse_id_from_email_address.sql") |> paste(collapse = "\n")



query <- gsub("FIND_REPLACE_EMAILS",paste0(email_list,collapse = ","),query)

print("Querying database...")
result <- dbGetQuery(con, query)



result <- result %>% rename("email"="email_address") %>% mutate(email =tolower(email))
complete_data <- left_join(user_data,result,by = "email")
print(complete_data)



print("Saving data...")
write.csv(complete_data,config$participant_data_file ,row.names = FALSE)
print("Data saved")