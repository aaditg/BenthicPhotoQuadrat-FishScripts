library(tidyverse)
library(remotes)
library(mermaidr)
library(tibble)

reef_survey <- mermaid_search_my_projects("B_Bauman_2008_UAE_Oman", include_test_projects =  TRUE)



fish_template_and_options <- mermaid_import_get_template_and_options(
  reef_survey,
  "fishbelt",
  "fishbelt.xlsx"
)
options_and_template <- mermaid_get_my_projects(include_test_projects = TRUE) %>%
  
  head(1) %>%
  mermaid_import_get_template_and_options("benthicpqt", "benthicpqt_mermaid_template.xls")
  
  names(options_and_template)
  
  options_and_template[["Observation length *"]]

data <- tibble(Visibility = c("<1m - bad", ">10m - excellent"))
data %>%
  mermaid_import_check_options(options_and_template, "Visibility")
