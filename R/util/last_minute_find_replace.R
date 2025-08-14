# find and replace

files <- list.files("renders/poms-dispatch1",full.names = T)

for (i in 2:length(files)){
  lines <- readLines(files[i])
  
  for(ii in 1:length(lines)){
    lines[ii] <- gsub("Fit Count","FIT Count",lines[ii])
    lines[ii] <- gsub("1 insects","1 insect",lines[ii])
  }
  
  writeLines(lines,files[i])
  
  print(i/length(files))
  
}

