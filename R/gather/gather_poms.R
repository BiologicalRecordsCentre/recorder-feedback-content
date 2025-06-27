# Implementation notes
#
# PoMS data is gathered from the indica warehouse. This uses a JDBC connection to the replica warehouse running on a UKCEH scicom virtual machine
#
# You need to create poms.sql in the sql folder, you can get a copy of this from the private repo here (you need to request access from Robin): https://github.com/robin-hutchinson/indicia_reporting/blob/main/survey/ukpoms/fit_counts/sql/2023_data
#
# You will need to download a postgresql java driver from here: https://jdbc.postgresql.org/download/ and save it in the java folder, then provide an environment variable in .Renviron e.g. JAVA_PATH="java/your_java_driver.jar"
#
# You will also need to set environment variables for the connection (DB_CONNECTION, DB_USERNAME, DB_PASSWORD)
# The connection will be in a format like jdbc:postgresql://virtualmachine.scicom.ceh.ac.uk:5432/databasename
#
# You also need to install R package RJDBC
#
# Cross you fingers and hope it works!


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