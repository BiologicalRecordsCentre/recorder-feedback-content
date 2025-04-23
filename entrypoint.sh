#!/bin/bash

# Generate datetime string in format YYYY-MM-DD_HH-MM-SS
datetime_str=$(date +"%Y-%m-%d_%H-%M-%S")

# Run the R script and pass the datetime string as an argument
Rscript run_pipeline.R "$datetime_str"