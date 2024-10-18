library(mermaidr)
library(tidyverse)

fishbelt_data <- read.csv("F_BurtJohansen_2019_UAE_Musandam (Cleaned).csv", sep=',')
reef_survey <- mermaid_search_my_projects("F_BurtJohansen_2019_UAE_Musandam", include_test_projects = TRUE)

fish_template_and_options <- mermaid_import_get_template_and_options(
  reef_survey,
  "fishbelt",
  "fishbelt_mermaid_template.xlsx"
)

names(fishbelt_data)[1] <- "Site *"
names(fishbelt_data)[2] <- "Management *"
names(fishbelt_data)[3] <- "Sample date: Year *"
names(fishbelt_data)[4] <- "Sample date: Month *"
names(fishbelt_data)[5] <- "Sample date: Day *"
names(fishbelt_data)[6] <- "Depth *"
names(fishbelt_data)[7] <- "Transect number *"
names(fishbelt_data)[8] <- "Transect length surveyed *"
names(fishbelt_data)[9] <- "Width *"
names(fishbelt_data)[10] <- "Fish size bin *"
names(fishbelt_data)[11] <- "Observer emails *"
names(fishbelt_data)[12] <- "Fish name *"
names(fishbelt_data)[13] <- "Size *"
names(fishbelt_data)[14] <- "Count *"

mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Site *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Management *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Sample date: Year *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Sample date: Month *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Sample date: Day *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Depth *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Transect number *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Transect length surveyed *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Width *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Fish size bin *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Reef slope")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Visibility")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Current")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Observer emails *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Fish name *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Size *")
mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Count *")

mermaid_import_project_data(
  fishbelt_data,
  reef_survey,
  method = "fishbelt",
  dryrun = TRUE
)
