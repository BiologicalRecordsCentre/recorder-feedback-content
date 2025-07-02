email_format <- function (
    content_width = "600px", 
    toc = FALSE, 
    toc_depth = 3,
    toc_float = FALSE, 
    number_sections = FALSE, 
    section_divs = TRUE,
    fig_width = 5.35, 
    #fig_height = 5, 
    fig_retina = 2, 
    fig_caption = TRUE,
    dev = "png", 
    smart = TRUE, 
    self_contained = TRUE,
    includes = NULL, 
    keep_md = FALSE, 
    md_extensions = NULL,
    template_html,
    ...) 
{
  

  
  content_width <- htmltools::validateCssUnit(content_width)
  template <- template_html

  rmarkdown::html_document(toc = toc, toc_depth = toc_depth, 
                           toc_float = toc_float, number_sections = number_sections, 
                           section_divs = section_divs, 
                           fig_width = fig_width, 
                           #fig_height = fig_height, 
                           fig_retina = fig_retina, fig_caption = fig_caption, dev = dev, 
                           df_print = "default", code_folding = "none", 
                           code_download = FALSE, smart = smart, self_contained = self_contained, 
                           theme = "default", highlight = "default", 
                           mathjax = NULL, template = template, extra_dependencies = NULL, 
                           css = NULL, includes = includes, keep_md = keep_md, lib_dir = NULL, 
                           md_extensions = md_extensions,
                           ...)
}