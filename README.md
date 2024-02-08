# Recorder Feedback

Scripts for generating feedback and "data stories" for biological recorders

## Overview

Biological recorders contribute valuable biodiversity data; and extensive infrastructure exists to support dataflows from recorders submitting records to databases. However, we lack infrastructure dedicated to providing informative feedback to recorders in response to the data they have contributed. By developing this infrastructure, we can create a feedback loop leading to better data and more engaged data providers.

We might want to provide feedback to recorders, or other interested parties such as land managers or groups, for a variety of reasons:

 * Get more data by boosting engagement: acknowledge and incentivise recorders for making valuable contributions
 * Improvements in data quality through skill improvement
 * Deliver persuasive messaging to support adaptive sampling approaches, for example ‘nudging’ users to visit places where there is the greatest need for data

The code in this repository is developed to programmatically generating effective digital engagements (‘data stories’) from biodiversity species data.

We use R markdown as a flexible templating system to provide extensible scripts that allow the development of different digital engagements. This templating system can then be used by data managers to design digital engagements to send to their participants. Attention should be given to ensuring that this software is computationally efficient to ensure that it has the potential to be scaled.

This code provides tools for turning species recording data into data stories in HTML format. Separate scripts will be used to dispatch the HTML content to recipients.

Developed as part of NCEA (Natural Capital and Ecosystem Assessment) and is follow-on work to the MyDECIDE campaign delivered under the DECIDE project. The code and scripts from MyDECIDE are available here: https://github.com/simonrolph/DECIDE-WP3-newsletter/tree/main

## How it works

The email generation process is managed by R package targets. The targets package is a Make-like pipeline tool for statistics and data science in R. The package skips costly runtime for tasks that are already up to date and orchestrates the necessary computation. The pipeline is described in `_targets.R`and triggered using `targets::tar_make()`. You can visualise the dependency graph using `targets::tar_visnetwork()`.

The input data is made available in the `/data` folder. It must be in a certain format in order to work correctly. During the pipeline the data is split into the `user_data` which only includes the species records of the target user and the `bg_data` (background) which is the data for everyone.

The email rendering is done using R markdown. R markdown is used as a very flexible templating system to allow developers to documents in html (and other formats). It combines markdown with code chunks. We use parameterised R markdown to render the email with user-specific data and computed data-derived objects.

Content in the emails can be generated using frequently R packages such as dplyr for data manipulation and ggplot2 for creating data visualisations. There are various R packages available for generating maps but there are example scripts that use ggspatial.

The emails are rendered in an email-ready format borrowed from the R package blastula. They are rendered as 'self contained' html files so there are no external local image files.

It is not recommended to carry out computationally heavy calculations within the R markdown template, therefore a computation step can be done before rendering. These computations should be coded in scripts located in `R/computations`. The computations are applied separately for the `user_data` and `bg_data`, but this can be the same or different computation scripts.

A configuration file (`config.yml`), which is loaded in using `config::get()`, is where you define the data file, the computation scripts and the template file.

The rendered html items are saved in a folder `renders/[batch_id]` where you have set a batch identifier. The folder contains html files for each recipient and a `.csv` with columns for each file name and the identifier.

## Development Process
The development process for creating informative feedback for biological recorders involves several key stages to ensure the effectiveness and relevance of the generated feedback. Follow these steps to streamline the development process:

### 1. Define Feedback Objectives
Begin by clearly defining the objectives and motivations behind providing feedback to biological recorders. Consider the following questions:

 * What specific goals do you aim to achieve with the feedback?
 * Who are the target recipients of the feedback, and what are their needs and preferences?
 * How will the feedback contribute to improving data quality and engagement?

Ensure that every design and coding decision aligns with the core motivations identified in this stage.

### 2. Conceptualization
Before diving into coding, take the time to conceptualize the feedback content and format. Consider the following aspects:

 * What types of feedback will be most impactful for the target audience?
 * What visual and textual content will be included in the feedback?
 * How can you effectively communicate the value of the feedback to the recorders?

Brainstorm ideas and outline the structure of the feedback to guide the development process.

### 3. Determine Computational Requirements
Identify the computational tasks required to generate the feedback items. This may involve:

 * Calculating metrics or statistics from the background data for comparison.
 * Processing and formatting the input data to generate user-specific feedback.
 * Developing scripts for data manipulation, visualization, and analysis.

Create scripts for these computations and organize them in the designated R/computations folder.

### 4. Design Email Template
Develop the email template using R Markdown to present the feedback in a visually appealing and informative manner. Consider the following elements:

 * Incorporate user-specific data and computed metrics using parameterized R Markdown.
 * Use R packages such as dplyr for data manipulation and ggplot2 for data visualization.
 * Ensure that the template adheres to best practices for email rendering and readability.
   
Adapt the provided example.Rmd and basic_template.html as needed to customize the look and feel of the emails.

### 5. Testing and Iteration
Generate test emails using simulated or real data to evaluate the effectiveness of the feedback generation process. Consider the following aspects during testing:

 * Verify the accuracy and relevance of the generated feedback.
 * Assess the visual appeal and readability of the email template.
 * Solicit feedback from stakeholders or test users for further improvements.

Iterate on the design and content of the feedback based on testing results and user feedback to ensure that it meets the desired objectives.

By following these structured steps, you can systematically develop informative feedback for biological recorders, ultimately improving data quality and engagement within the community.

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
