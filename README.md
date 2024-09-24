# Recorder Feedback via Effective Digital Engagements

Extensible code for generating effective digital engagements for biological recorders. Developed in partnership with JNCC as part of the [Natural Capital and Ecosystem Assessment](https://www.gov.uk/government/publications/natural-capital-and-ecosystem-assessment-programme/natural-capital-and-ecosystem-assessment-programme) programme managed by Defra.

For further details about how to use this code please visit the documentation page: https://biologicalrecordscentre.github.io/recorder-feedback-content/

See https://github.com/BiologicalRecordsCentre/recorder-feedback for more details about recorder feedback.

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
 - A recording 'receipt' sent responsively to a recorder making a visit to a site and observing a particular species
 - A recording 'forecast' highlighting species that might be able to be observed in a future time period

This code is not well suited for 'on-the-fly' feedback delivered to a recorder whilst they are 'in the field' engaging in recording activity. Those sorts of feedback are best delivered directly through recording apps such as iRecord.

## How it works (in summary)

 * Email generation pipeline managed by R package {targets}
 * Email content and rendering managed using R markdown
 * You need to provide:
   * Input data as .csv
   * Functions for any computations you wish to do on this data before rendering the email (eg. calculating summary statistics)
   * An parametrised R markdown file which uses markdown and R code to transform the data and computed objects into effective digital engagements.
   * A HTML template used by the rendering process to format the final HTML output
   * a configuration file (`config.yml`) containing information about all of the above
 * Rendered items are saved in `renders/[batch_id]` folder with recipient-specific HTML files and a .csv metadata file
  
A minimal example of all of these items is included and is demonstrated in the "getting started" part of the documentation.

