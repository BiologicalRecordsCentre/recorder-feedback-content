# get their records using this script which will save data to config$data_file
source(config$gather_bio_script)

# check that records have been updated
if(difftime(file.info(config$data_file)$mtime,Sys.time(),units = "secs") < 30){
  print("Biodiversity data file has been updated")
} else {
  stop("Biodiversity data file has not been updated, check for issue in gather script")
}

