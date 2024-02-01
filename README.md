# Recorder Feedback

Scripts for generating informative feedback for biological recorders

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

The emails are rendered in an email-ready format specified from the R package blastula. The blastula package makes it easy to produce and send HTML email from R.

It is not recommended to carry out computationally heavy calculations within the R markdown template, therefore a computation step can be done before rendering. These computations should be coded in scripts located in `R/computations`. The computations are applied separately for the `user_data` and `bg_data`, but this can be the same or different computation scripts.

A configuration file (`config.yml`), which is loaded in using `config::get()`, is where you define the data file, the computation scripts and the template file.

## Development process

### Identify need for recorder feedback and allignement with recorder motivations

First, it is important to determine why do we need to send recorder feedback. Some example motivations include:

 * To encourage more recording
 * To encourage a specific type of recording

### Conceptualisation

Come up with some ideas

### Computational requirements

What computations do you need to do in order to produce the feedback items. For example do you need to calculate metrics (e.g. averages) from the background data to compare the user data to?

### Design email template

Produce your R markdown in the `templates` folder.

### Test it out

Generate some emails
