
library(dplyr)


simulated_participants <- data.frame(user_id= c("42523","75437","54642"),
                                     name = c("Robert H","Grace S","Alice Johnson"),
                                     email = c("Alice Johnson","grace@example.com","alice@example.com")
)



write.csv(simulated_participants,"data/simulated_participants.csv",row.names = F)



# Function to generate simulated wildlife recording data
generate_wildlife_data <- function(start_date, end_date, num_records,participants) {
  # Generate random latitude and longitude for the recording area
  latitude <- runif(num_records, min = 51, max = 52)
  longitude <- runif(num_records, min = -1.5, max = 0)
  
  # Generate random species
  species <- sample(c("Common Blue", "Comma", "Red Admiral", "Painted Lady", "Peacock", "Meadow brown","Large white","Holly Blue"), num_records, replace = TRUE)
  
  # Generate random recorder names
  recorders <- sample_n(participants, num_records, replace = TRUE)
  
  # Generate random dates
  dates <- seq.Date(start_date, end_date, by = "day")
  recording_dates <- sample(dates, num_records, replace = TRUE)
  
  # Create a data frame
  wildlife_data <- data.frame(
    latitude = latitude,
    longitude = longitude,
    species = species,
    date = recording_dates
  ) %>% cbind(recorders)
  
  return(wildlife_data)
}

# Set start and end dates
start_date <- as.Date("2023-06-01")
end_date <- as.Date("2024-02-08")

# Generate simulated wildlife recording data
simulated_data <- generate_wildlife_data(start_date, end_date, num_records = 1000,simulated_participants)


simulated_data

#plot(simulated_data$latitude,simulated_data$longitude)

write.csv(simulated_data,"data/simulated_data_raw.csv",row.names = F)
