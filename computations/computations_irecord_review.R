compute_objects <- function(data){
  #data <- targets::tar_read(raw_data) #for testing
  library(sf)
  
  # Get the current date
  current_date <- Sys.Date()
  current_month <- format(current_date,"%B")
  
  data <- data %>%
    filter(species_group %in% c("insect - dragonfly (Odonata)","insect - butterfly"),
           date>=as.Date("2025-01-01")) %>%
    mutate(species_group = case_when(
      species_group == "insect - butterfly" ~ "butterflies",
      species_group == "insect - dragonfly (Odonata)" ~ "dragonflies",
      TRUE ~ species_group
    ))
  
  
  
  #get sites
  sites <- st_as_sf(data,coords =c("longitude","latitude"),crs = 4326) %>% 
    st_transform(27700) %>% 
    st_coordinates() %>% #extract the coordinages
    signif(3) %>%  #to 1km, use digits = -2 for 100m
    data.frame() %>%
    mutate(site_name = paste0(X,Y))
  data <- cbind(data,sites)
  
  
  visits <- data %>% 
    group_by(species_group,date,user_id,site_name,.drop = FALSE) %>% 
    summarise(n_records=n(),
              n_species = length(unique(species))
              ) %>%
    mutate(longer_list = n_species>3)
  
  key_stats <- visits %>% 
    group_by(user_id,species_group,.drop = FALSE) %>% 
    summarise(n_visits= n(),
              n_sites = length(unique(site_name)),
              n_records = sum(n_records),
              n_longer_lists = sum(longer_list),
              .groups = "drop") %>%
    group_by(species_group) %>%
    summarise(avg_visits = round(median(n_visits)),
              avg_records = round(median(n_records)),
              avg_sites = round(median(n_sites)),
              avg_longer_lists = round(median(n_longer_lists)))
  
  #unique species
  n_species <- data %>% 
    group_by(species_group,user_id,.drop = FALSE) %>%
    summarise(n_species = length(unique(species))) %>%
    group_by(species_group) %>%
    summarise(avg_species_count = round(median(n_species)))
  
  #median first date 
  median_first_date <-
    data %>% 
    group_by(user_id,species_group) %>%
    arrange(date) %>%
    summarise(first_date = first(date)) %>%
    mutate(first_date = as.Date(first_date))%>%
    group_by(species_group) %>%
    summarise(first_date= median(first_date))
  
  key_stats <- left_join(key_stats,n_species) %>%
    left_join(median_first_date)%>% 
    arrange(species_group)
  
  
  #return the list of precalculated objects
  list(key_stats = key_stats,
       daily_visits = visits)
  
}


