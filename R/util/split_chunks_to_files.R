library(knitr)

split_chunks_to_files <- function(rmd_file, output_dir = "chunks") {
  if (!dir.exists(output_dir)) dir.create(output_dir)
  
  # Delete existing .R files in the output directory
  old_files <- list.files(output_dir, pattern = "\\.R$", full.names = TRUE)
  file.remove(old_files)
  
  # Read the Rmd file
  lines <- readLines(rmd_file)
  
  in_chunk <- FALSE
  chunk_lines <- c()
  chunk_index <- 0
  chunk_name <- NULL
  
  for (line in lines) {
    if (grepl("^```\\{r.*\\}", line)) {
      in_chunk <- TRUE
      chunk_index <- chunk_index + 1
      
      # Extract chunk name if available
      chunk_name <- sub("^```\\{r\\s*([^,}]*)?.*", "\\1", line)
      if (chunk_name == line) chunk_name <- paste0("unnamed_chunk_", chunk_index)
      if (chunk_name == "") chunk_name <- paste0("chunk_", chunk_index)
      
      chunk_lines <- c()
      
    } else if (grepl("^```$", line) && in_chunk) {
      # End of a code chunk
      in_chunk <- FALSE
      file_path <- file.path(output_dir, paste0(chunk_name, ".R"))
      writeLines(chunk_lines, file_path)
      
    } else if (in_chunk) {
      chunk_lines <- c(chunk_lines, line)
    }
  }
}