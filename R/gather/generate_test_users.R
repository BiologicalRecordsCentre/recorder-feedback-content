library(dplyr)

simulated_participants <- data.frame(user_id= c("42523","75437","54642"),
                                     name = c("Robert H","Grace S","Alice Johnson"),
                                     email = rep(config::get()$mail_test_recipient,3)
)

write.csv(simulated_participants,"data/simulated_participants.csv",row.names = F)

