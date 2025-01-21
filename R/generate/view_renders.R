view_renders <- function(batch_id,sample_n=0){
  
  rendered <- list.files(paste0("renders/",batch_id),pattern="*.html",full.names = T)
  
  if(sample_n>0 & sample_n<length(rendered)){
    rendered <- sample(rendered,sample_n)
  }
  
  openHTML <- function(x) browseURL(paste0('file://', file.path(getwd(), x)))
  for(i in 1:length(rendered)){
    openHTML(rendered[i])
  }
  NA
}

