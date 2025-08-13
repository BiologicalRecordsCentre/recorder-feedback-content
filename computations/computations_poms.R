compute_objects <- function(data){
  current_year <- lubridate::year(Sys.Date())
  previous_year <- current_year -1
  
  # pivoted longer
  long_data <- data %>%
    filter(year == current_year) %>%
    pivot_longer(c(bumblebees,honeybees,solitary_bees,wasps,hoverflies,other_flies,butterflies_moths,beetles,insects_small,insects_other),names_to = "group",values_to = "count")
  
  
  
  #mean number of species
  mean_n_fit_counts = data %>% 
    filter(year == current_year) %>%
    group_by(user_id) %>% 
    summarise(n_counts = n()) %>%
    pull(n_counts) %>%
    mean()
  
  mean_n_fit_counts_prev = data %>% 
    filter(year == previous_year) %>%
    group_by(user_id) %>% 
    summarise(n_counts = n()) %>%
    pull(n_counts) %>%
    mean()
  
  if(is.nan(mean_n_fit_counts)){
    mean_n_fit_counts <- 0
  }
  
  if(is.nan(mean_n_fit_counts_prev)){
    mean_n_fit_counts_prev <- 0
  }
  
  #mean number of records
  mean_n_insects = data %>%
    filter(year == current_year) %>%
    rowwise() %>%
    mutate(n_insects = sum(c(bumblebees,honeybees,solitary_bees,wasps,hoverflies,other_flies,butterflies_moths,beetles,insects_small,insects_other), na.rm=T)) %>%
    group_by(user_id) %>% 
    summarise(total_insects = sum(n_insects, na.rm=T)) %>%
    pull(total_insects) %>%
    mean()
  
  mean_n_insects_prev = data %>%
    filter(year == previous_year) %>%
    rowwise() %>%
    mutate(n_insects = sum(c(bumblebees,honeybees,solitary_bees,wasps,hoverflies,other_flies,butterflies_moths,beetles,insects_small,insects_other), na.rm=T)) %>%
    group_by(user_id) %>% 
    summarise(total_insects = sum(n_insects, na.rm=T)) %>%
    pull(total_insects) %>%
    mean()
  
  if(is.nan(mean_n_insects)){
    mean_n_insects <- 0
  }
  
  # Bingo
  flower_types_recorded <- data %>%
    filter(year == current_year) %>%
    group_by(target_flower) %>%
    summarise(n= n())
  if(mean_n_fit_counts ==0){
    flower_types_recorded <- data %>%
      filter(year == previous_year) %>%
      group_by(target_flower) %>%
      summarise(n= n())
  }
  
  
  flower_types <- 
    data.frame(x = c("Ivy ",
                     "Other ", 
                      "Lavender (English) ",
                      "Dandelion ",
                      "Buttercup ",
                      "Buddleja",
                      "Ragwort ", 
                      "Heathers ", 
                      "Knapweeds (Common or Greater) ", 
                      "White Clover ", 
                      "Thistle ", 
                      "Bramble (Blackberry) ", 
                      "Hogweed ", 
                      "Hawthorn ", 
                      "White Dead",
                      "Red Clover " 
  ))
  
  
  
  
  
  
  if(nrow(flower_types_recorded)<16){
    flower_types_missing <- data.frame(target_flower = flower_types$x[!(flower_types$x %in% flower_types_recorded$target_flower)],n = 0)
    flower_types_recorded <- rbind(flower_types_recorded,flower_types_missing)
  } 
  
  flower_types_recorded <- flower_types_recorded %>% 
    mutate(target_flower = if_else(target_flower == "White Dead","White Dead-nettle",target_flower)) %>%
    filter(target_flower != "Red Clover ")
  
  # count patterns
  daily_counts_current_year <- data %>% 
    filter(year == current_year) %>%
    mutate(day = lubridate::floor_date(as.POSIXct(date_from), "day")) %>%
    group_by(day) %>%
    summarize(n = n())
  
  daily_counts_previous_year <- data %>%
    filter(year == previous_year) %>%
    mutate(day = lubridate::floor_date(as.POSIXct(date_from), "day")) %>%
    group_by(day) %>%
    summarize(n = n())
  
  
  #return the list of precalculated objects
  list(mean_n_fit_counts = mean_n_fit_counts,
       mean_n_insects = mean_n_insects,
       mean_n_fit_counts_prev = mean_n_fit_counts_prev,
       mean_n_insects_prev = mean_n_insects_prev,
       flower_types_recorded = flower_types_recorded,
       daily_counts_current_year = daily_counts_current_year,
       daily_counts_previous_year = daily_counts_previous_year)
  
}