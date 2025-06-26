compute_objects <- function(data){
  
  # pivoted longer
  long_data <- data %>%
    pivot_longer(c(bumblebees,honeybees,solitary_bees,wasps,hoverflies,other_flies,butterflies_moths,beetles,insects_small,insects_other),names_to = "group",values_to = "count")
  
  
  
  #mean number of species
  mean_n_fit_counts = data %>% 
    group_by(user_id) %>% 
    summarise(n_counts = n()) %>%
    pull(n_counts) %>%
    mean()
  
  #mean number of records
  mean_n_insects = data %>% 
    rowwise() %>%
    mutate(n_insects = sum(c(bumblebees,honeybees,solitary_bees,wasps,hoverflies,other_flies,butterflies_moths,beetles,insects_small,insects_other), na.rm=T)) %>%
    group_by(user_id) %>% 
    summarise(total_insects = sum(n_insects, na.rm=T)) %>%
    pull(total_insects) %>%
    mean()
  
  
  
  # Bingo
  flower_types_recorded <- data %>% 
    group_by(target_flower) %>%
    summarise(n= n())
  
  flower_types <- 
    data.frame(x = c("Ivy",
                     "Other", 
                      "Lavender (English)",
                      "Dandelion",
                      "Buttercup",
                      "Buddleja",
                      "Ragwort", 
                      "Heathers", 
                      "Knapweeds (Common or Greater)", 
                      "White Clover", 
                      "Thistle", 
                      "Bramble (Blackberry)", 
                      "Hogweed", 
                      "Hawthorn", 
                      "White Dead",
                      "Red Clover" 
  ))
  
  
  
  
  if(nrow(flower_types_recorded)<16){
    flower_types_missing <- data.frame(target_flower = flower_types$x[!(flower_types$x %in% flower_types_recorded$target_flower)],n = 0)
    flower_types_recorded <- rbind(flower_types_recorded,flower_types_missing)
  } 
  
  # count patterns
  daily_counts <- data %>% 
    mutate(day = lubridate::floor_date(as.POSIXct(date_from), "day")) %>%
    group_by(day) %>%
    summarize(n = n())
  
  
  #return the list of precalculated objects
  list(mean_n_fit_counts = mean_n_fit_counts,
       mean_n_insects = mean_n_insects,
       flower_types_recorded = flower_types_recorded,
       daily_counts = daily_counts)
  
}