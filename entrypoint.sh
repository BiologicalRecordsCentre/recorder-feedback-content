#!/bin/bash

# Define base directory (change this to where your script actually lives)
BASE_DIR="/home/simrol/recorder-feedback-content"

# Navigate to the working directory
cd "$BASE_DIR" || exit

# Generate datetime string in format YYYY-MM-DD_HH-MM-SS
datetime_str=$(date +"%Y-%m-%d_%H-%M-%S")

# Run the R script and pass the datetime string as an argument
Rscript run_pipeline.R "$datetime_str"