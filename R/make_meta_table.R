make_meta_table <- function(x,batch_id,user_data){
  file_name <- paste0("renders/",batch_id,"/meta_table_",batch_id,".csv")
  
  x <- dplyr::bind_rows(x)
  x <- left_join(x,user_data)
  write.csv(x, file_name,row.names = F)
  
  file_name
}