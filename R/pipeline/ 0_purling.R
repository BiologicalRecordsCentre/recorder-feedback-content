#run this line 
knitr::purl(input = "run_pipeline.Rmd", output = "run_pipeline.R",documentation = 0)
source("R/util/split_chunks_to_files.R")
split_chunks_to_files("run_pipeline.Rmd", "R/pipeline") # each chunk as separate file if needed for step by step orchestration
