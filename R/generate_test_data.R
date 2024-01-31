# Function to generate simulated wildlife recording data
generate_wildlife_data <- function(start_date, end_date, num_records) {
  # Generate random latitude and longitude for the recording area
  latitude <- runif(num_records, min = 51, max = 52)
  longitude <- runif(num_records, min = -1.5, max = 0)
  
  # Generate random species
  species <- sample(c("Common Blue", "Comma", "Red Admiral", "Painted Lady", "Peacock", "Meadow brown","Large white","Holly Blue"), num_records, replace = TRUE)
  
  # Generate random recorder names
  recorders <- sample(c("Alice", "Bob", "Charlie", "David", "Michael"), num_records, replace = TRUE)
  
  # Generate random dates
  dates <- seq.Date(start_date, end_date, by = "day")
  recording_dates <- sample(dates, num_records, replace = TRUE)
  
  # Create a data frame
  wildlife_data <- data.frame(
    latitude = latitude,
    longitude = longitude,
    species = species,
    recorder = recorders,
    date = recording_dates
  )
  
  return(wildlife_data)
}

# Set start and end dates
start_date <- as.Date("2024-01-01")
end_date <- as.Date("2024-01-31")

# Generate simulated wildlife recording data
simulated_data <- generate_wildlife_data(start_date, end_date, num_records = 1000)


simulated_data

plot(simulated_data$latitude,simulated_data$longitude)
test <- simulated_data %>% group_by(recorder,species) %>% summarise(n())
test

write.csv(simulated_data,"data/simulated_data_raw.csv")
