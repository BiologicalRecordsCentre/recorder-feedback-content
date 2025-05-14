# get records data
source("R/gather/get_records_from_indicia.R")
indicia_warehouse_base_url <- Sys.getenv("INDICIA_WAREHOUSE_BASE_URL")
indicia_warehouse_client_id <- Sys.getenv("INDICIA_WAREHOUSE_CLIENT_ID")
indicia_warehouse_secret <- Sys.getenv("INDICIA_WAREHOUSE_SECRET")

#load in subscribers
subscribers_df <- read.csv(config$participant_data_file)
records_data <- data.frame()#create an empty data frame

#loop through subscribers and get their data
for (i in 1:nrow(subscribers_df)){
  data_out <- get_user_records_from_indicia(base_url = indicia_warehouse_base_url, 
                                            client_id = indicia_warehouse_client_id,
                                            shared_secret = indicia_warehouse_secret,
                                            user_warehouse_id = as.character(subscribers_df$user_id[i]),
                                            n_records = 100)
  
  if (data_out$hits$total$value >0){
    #any intermediate data processing
    latlong <- data_out$hits$hits$`_source`$location$point
    
    #extract all the columns you need
    vernacular_names <- data_out$hits$hits$`_source`$taxon$vernacular_name
    if(is.null(vernacular_names)){vernacular_names[is.null(vernacular_names)]<-""}
    
    user_records <- data.frame(latitude = sub(",.*", "", latlong),
                               longitude = sub(".*,", "", latlong),
                               location_name = data_out$hits$hits$`_source`$location$verbatim_locality,
                               species = data_out$hits$hits$`_source`$taxon$taxon_name,
                               species_vernacular = vernacular_names,
                               date = data_out$hits$hits$`_source`$event$date_start,
                               user_id = data_out$hits$hits$`_source`$metadata$created_by_id
    )
    
    records_data <- rbind(records_data,user_records)
  }
}

write.csv(records_data,config$data_file,row.names = F)#save the data