# Recorder Feedback via Effective Digital Engagements

Scripts for generating effective digital engagements and "data stories" for biological recorders.

This code is developed under the NCEA (Natural Capital and Ecosystem Assessment) program funded by DEFRA.

## Overview

Biological recorders contribute valuable biodiversity data; and extensive infrastructure exists to support dataflows from recorders submitting records to databases. However, we lack infrastructure dedicated to providing informative feedback to recorders in response to the data they have contributed. By developing this infrastructure, we can create a feedback loop leading to better data and more engaged data providers.

We might want to provide feedback to biological recorders, or other interested parties such as land managers or groups, for a variety of reasons:

 * Increase the volume of species data by improving user engagement
 * Improve data quality by supporting user skill improvement
 * Get data where it is needed most by delivering persuasive messaging to encourage species recording in places or taxonomic groups that we need data (adaptive sampling).

The code in this repository is developed to programmatically generating effective digital engagements (‘data stories’) from biodiversity species data. This code provides tools for turning species recording data into data stories in HTML format. Separate scripts will be used to dispatch the HTML content to recipients. We use R markdown as a flexible templating system to provide extensible scripts that allow the development of different digital engagements. This templating system can then be used by data managers to design digital engagements to send to their participants. Attention should be given to ensuring that this software is computationally efficient to ensure that it has the potential to be scaled.

This work inherits some ideas and concept from the MyDECIDE campaign delivered under the DECIDE project. The code and scripts from MyDECIDE are available here: https://github.com/simonrolph/DECIDE-WP3-newsletter/tree/main

## What types of effective digital engagements can be generated with this code

This code can be used to generate static feedback items containing retrospective and/or prospective content. This means the content is typically generated periodically, or triggered by specific criteria. Some examples of feedback items:

 - A periodic (weekly / monthly / yearly) item reporting recording activity on a past time period
 - A recording 'receipt' sent responsively to a recorder making a visit to a site and observing a perticular species
 - A recording 'forecast' highlighing species that might be able to be observed in a future time period

This code is not well suited for 'on-the-fly' feedback delivered to a recorder whilst they are 'in the field' engaging in recording activity. Those sorts of feedback are best delivered directly through recording apps.

## How it works

 * Email generation pipeline managed by R package {targets}
 * Email content and rendering managed using R markdown
 * You need to provide:
  * Input data as .csv
  * Functions for any computations you wish to do on this data before rendering the email (eg. calculating summary statistics)
  * An parametrised R markdown file which uses markdown and R code to transform the data and computed objects into effective digital engagements.
  * A HTML template used by the rendering process to format the final HTML output
  * a configuration file (`config.yml`) containing information about all of the above
 * Rendered items saved in `renders/[batch_id]` folder with recipient-specific HTML files and a .csv metadata file
  
A minimal example of all of these items is included and is demonstrated in the "getting started" part of the documentation.

## Getting started

### Fork the repository

Start by forking the Recorder Feedback repository on GitHub. This will create a copy of the project under your GitHub account, allowing you to make changes and contributions without affecting the original repository.

![image](https://github.com/BiologicalRecordsCentre/recorder-feedback/assets/17750766/dc4941bb-eff5-470e-8acd-cba16cddad4f)

### Clone the repo locally

Clone your forked repository to your local machine using Git. Open a terminal or command prompt and execute the following command:

```
git clone https://github.com/your-github-username/recorder-feedback.git`
```

Clone your forked repository to your local machine using Git. Open a terminal or command prompt and execute the following command:

### Install required packages using {renv}

Navigate to the project directory and install the necessary R packages using the renv package manager. Open R or RStudio and execute the following commands:

```
install.packages(c("renv"))
renv::restore()
```

This will ensure that you have all the required packages installed and ready to use for generating feedback.

### Generate test data

Run the provided script generate_test_data.R to generate test data for email rendering. Execute the following command in R or RStudio:

```
source("R/generate_test_data.R")
```

This script will create sample data that you can use to test the email generation process.

### Run the targets pipeline

Execute the targets pipeline to generate feedback emails based on the test data. Run the following command in R or RStudio:

```
targets::tar_make()
```

This will trigger the email generation process based on the specified computations and template.

### View generated emails

Once the targets pipeline has completed, you can view the generated email renders. Execute the following command in R or RStudio:

```
source("R/view_renders.R")
view_renders(batch_id="test_001",5)
```

Replace "test_001" with the batch identifier you set, and n with the number of renders you want to view.

### Customize Feedback Items

Now that you have the project set up and have generated test feedback, you can customize the email template and scripts to generate personalized feedback items according to your specific requirements. Edit the template (example.Rmd) and other scripts as needed to tailor the feedback content and format.

By following these steps, you can quickly set up the project environment and start generating informative feedback for biological recorders.
