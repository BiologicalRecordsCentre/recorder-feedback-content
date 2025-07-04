#see R/gather/gather_poms for more information on the database connection.

print("Loading R packages...")
library(RJDBC)
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
subscribers_df <- read.csv(config$participant_data_file)

print("Building query...")
query <- readLines("sql/warehouse_id_from_email_address.sql") |> paste(collapse = "\n")

user_data <- read.csv("data/users_no_key.csv")
email_list <- paste(sprintf("'%s'", user_data$email), collapse = ", ") # Collapse into a single string with properly quoted values

query <- gsub("FIND_REPLACE_EMAILS",paste0(subscribers_df$user_id,collapse = ","),query)

print("Querying database...")
result <- dbGetQuery(con, query)

print(result)

print("Saving data...")