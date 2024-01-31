do_computations <- function(computation,records_data){
  
  source(computation)
  computed_objects <- compute_objects(records_data)
  
  computed_objects
}

