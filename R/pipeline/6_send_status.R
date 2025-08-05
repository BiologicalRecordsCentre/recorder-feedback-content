status_lines <- apply(status_log, 1, function(row) {
  paste(
    "User ID:", row["user_id"], 
    "| Email:", row["email"], 
    "| Status:", row["status"], 
    "| Message:", row["message"]
  )
})

report_email <- compose_email(
  body = md(
    paste0(
      "### Email Send Summary",
      "
      Total attempted: ", nrow(status_log),
      "
      ✅ Success: ", sum(status_log$status == "Success"), 
      "
      ❌ Failed: ", sum(status_log$status == "Failed"),
      "
      Please check logs for more information"
    )
    ),
  footer = Sys.time()
  )

smtp_send(
  email = report_email,
  from = sender,
  to = config$mail_test_recipient,  # your email
  subject = paste("Email Batch Status Report -", Sys.Date()),
  credentials = creds,
  verbose = FALSE
)
