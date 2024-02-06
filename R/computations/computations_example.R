compute_objects <- function(data){
  #mean number of species
  mean_n_species = data %>% 
    group_by(user_id) %>% 
    summarise(n_species = length(unique(species))) %>%
    pull(n_species) %>%
    mean()
  
  #mean number of records
  mean_n_records = data %>% 
    group_by(user_id) %>% 
    summarise(n_records = n()) %>%
    pull(n_records) %>%
    mean()
  
  #return the list of precalculated objects
  list(mean_n_species = mean_n_species,
       mean_n_records = mean_n_records)
  
}