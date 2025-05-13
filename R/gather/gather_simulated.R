#load in subscribers
subscribers_df <- read.csv(config$participant_data_file)

# Load necessary library
library(dplyr)

# Function to generate simulated wildlife recording data with scientific names
generate_wildlife_data <- function(start_date, end_date, num_records, participants) {
  # Define species mapping (vernacular to scientific names)
  species_lookup <- data.frame(
    species_vernacular = c("Common Blue", "Comma", "Red Admiral", "Painted Lady", "Peacock",
                           "Meadow brown", "Large white", "Holly Blue"),
    species_scientific = c("Polyommatus icarus", "Polygonia c-album", "Vanessa atalanta",
                           "Vanessa cardui", "Aglais io", "Maniola jurtina",
                           "Pieris brassicae", "Celastrina argiolus"),
    stringsAsFactors = FALSE
  )
  
  # Generate random latitude and longitude for the recording area
  latitude <- runif(num_records, min = 51, max = 52)
  longitude <- runif(num_records, min = -1.5, max = 0)
  
  # Generate random species
  species_vernacular <- sample(species_lookup$species_vernacular, num_records, replace = TRUE)
  
  # Get corresponding scientific names
  species_data <- data.frame(species_vernacular = species_vernacular) %>%
    left_join(species_lookup, by = "species_vernacular")
  
  # Generate random recorder names
  recorders <- sample_n(participants, num_records, replace = TRUE)
  
  # Generate random dates
  dates <- seq.Date(start_date, end_date, by = "day")
  recording_dates <- sample(dates, num_records, replace = TRUE)
  
  # Create the final data frame
  wildlife_data <- data.frame(
    latitude = latitude,
    longitude = longitude,
    date = recording_dates
  ) %>%
    cbind(species_data, recorders)
  
  return(wildlife_data)
}

# Set start and end dates
start_date <- Sys.Date()-30
end_date <- Sys.Date()-1

# Generate simulated wildlife recording data
simulated_data <- generate_wildlife_data(start_date, end_date, num_records = 1000,subscribers_df)
#plot(simulated_data$latitude,simulated_data$longitude)

#save the data
write.csv(simulated_data,config$data_file,row.names = F)#save the data

