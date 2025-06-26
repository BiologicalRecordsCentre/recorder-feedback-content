library(RJDBC)

drv <- JDBC(driverClass = "org.postgresql.Driver",classPath = Sys.getenv("JAVA_PATH"))

con <- dbConnect(
  drv,
  Sys.getenv("DB_CONNECTION"),
  Sys.getenv("DB_USERNAME"),
  Sys.getenv("DB_PASSWORD")
  )

query <- readLines("sql/poms_query.sql") |> paste(collapse = "\n")

result <- dbGetQuery(con, query)
print(result)


