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
query <- readLines("sql/poms_query.sql") |> paste(collapse = "\n")
query <- gsub("FIND_REPLACE_USER_IDS",paste0(subscribers_df$user_id,collapse = ","),query)

print("Querying database...")
result <- dbGetQuery(con, query)
result$user_id <- result$digitised_by
result$target_flower <- sub("-.*", "", result$target_flower)

print(result)

print("Saving data...")
write.csv(result,config$data_file,row.names = F)#save the data