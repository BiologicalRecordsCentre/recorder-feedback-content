id <- 405017
target_id <- paste0("user_objects_",id)
user_objects <- targets::tar_read_raw(target_id)

raw_data <- targets::tar_read_raw("raw_data")
bg_computed_objects <- targets::tar_read_raw("bg_computed_objects")
users_target <- targets::tar_read_raw("users_target")

email_ <- "test@test.com"
name_ <- "Test"

config <- config::get(config="poms")
library(dplyr)

params <- list(user_name = name_,
                             user_email = email_,
                             user_data = user_objects$user_data,
                             user_computed_objects = user_objects$user_computed_objects,
                             bg_data = raw_data,
                             bg_computed_objects = bg_computed_objects,
                             content_key = user_objects$content_key,
                             config = config,
                             extra_params = users_target %>% filter(user_id == id) %>% select(-name,-email))
