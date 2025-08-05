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


print("Building query...")
query <- readLines("sql/poms_users.sql") |> paste(collapse = "\n")



print("Querying database...")
result <- dbGetQuery(con, query)

result <- result %>% rename("email"="email_address", "user_id" = "created_by_id","name" = "first_name") %>% mutate(email =tolower(email)) %>% mutate(name = if_else(name=="?",email,name))

print("Saving data...")
write.csv(result,"data/poms_partipants.csv" ,row.names = FALSE)
print("Data saved")