make_meta_table <- function(x,batch_id){
  file_name <- paste0("renders/",batch_id,"/meta_table_",batch_id,".csv")
  
  x <- stack(x)
  names(x) <- c("html_file","descriptor")
  write.csv(x, file_name,row.names = F)
  
  file_name
}