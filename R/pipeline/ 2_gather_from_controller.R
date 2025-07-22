# Get users
if(config$gather_from_controller_app){
  # GATHER
  source("R/gather/get_subscribers_from_controller.R")
  # Get subscribers for the list and write the data frame
  subscribers_df <- get_subscribers_from_controller(api_url = config$controller_app_base_url, 
                                                    email_list_id = config$controller_app_list_id, 
                                                    api_token = config$controller_app_api_key) 
  write.csv(subscribers_df,config$participant_data_file,row.names = F)
}

