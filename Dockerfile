# Use the official R base image
FROM rocker/r-ver:4.5.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    pandoc \
    && apt-get clean

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install R package dependencies using renv
RUN R -e "install.packages('renv', repos='http://cran.r-project.org')"
RUN R -e "renv::restore()"

# Set environment variables
ENV R_CONFIG_ACTIVE=default

# Copy the entrypoint script into the container
COPY entrypoint.sh /app/entrypoint.sh

# Make the script executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/app/entrypoint.sh"]