
library(dplyr)

# simulate participants
generate_participants <- function(n_participants){
  # Hypothetical list of first names
  first_names <- c("John", "Alice", "David", "Emily", "Michael", "Sophia", "Brian", "Olivia", "Robert", "Emma", "Christopher", "Ava", "Daniel", "Mia", "Matthew", "Ella", "William", "Grace", "Andrew", "Liam","Jessica", "Benjamin", "Chloe", "Jonathan", "Sophie", "Nicholas", "Charlotte", "Anthony", "Daniel", "Ashley","Tyler", "Ethan", "Zoe", "Alexander", "Emma", "Ryan", "Madison", "Samuel", "Abigail", "Nathan", "Hannah","Christopher", "Isabella", "Joseph", "Aiden", "Emily", "Grace", "David", "Daniel", "Olivia", "Liam","Michael", "Ella", "Joshua", "Ava", "James", "Mia", "Andrew", "Sophia", "Brandon", "Lily", "Nicholas","Amelia", "Evan", "Natalie", "William", "Charlotte", "Logan", "Grace", "Matthew", "Avery", "Justin","Addison", "Aaron", "Scarlett", "Kyle", "Aria", "Jason", "Bella", "Alex", "Samantha", "Eric", "Lillian","Timothy", "Victoria", "Mark", "Leah", "Brian", "Audrey", "Cameron", "Claire", "Peter", "Stella")
  
  surnames <- c("Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor","Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson","Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King","Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter","Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins","Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey","Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez","James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross","Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington")
  
  names <- paste(sample(first_names,n_participants),sample(surnames,n_participants))
  
  data.frame(user_id= 1:n_participants,name = names,email = paste0(gsub(" ",".",names),"@email.com"))
}

simulated_participants <- generate_participants(5)
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
start_date <- as.Date("2024-01-01")
end_date <- as.Date("2024-01-31")

# Generate simulated wildlife recording data
simulated_data <- generate_wildlife_data(start_date, end_date, num_records = 1000,simulated_participants)


simulated_data

#plot(simulated_data$latitude,simulated_data$longitude)

write.csv(simulated_data,"data/simulated_data_raw.csv",row.names = F)
