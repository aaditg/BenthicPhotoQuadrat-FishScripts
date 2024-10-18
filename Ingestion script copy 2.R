###############################################################
############## Ingesting legacy data into MERMAID #############
############# Author: Amkieltiela & Sharla Gelfand ############
###############################################################

# The steps for importing (ingesting) legacy data are:
# 1. Download the fish belt MERMAID template
# 2. Reformat your data to match the template
# 3. Address errors and warnings
# 4. Import (ingest) data to MERMAID


# set working directory
setwd("/Downloads")

#### 1. Download the fish belt MERMAID template

# install the mermaidr package
remotes::install_github("data-mermaid/mermaidr", force = TRUE)

# activate libraries
library(mermaidr)
library(tidyverse)

reef_survey <- mermaid_search_my_projects("AbuDhabi_UAE_2018-2022", include_test_projects = TRUE)

mermaid_auth()

# get the fishbelt template
fish_template_and_options <- mermaid_import_get_template_and_options(
  reef_survey,
  "fishbelt",
  "fishbelt_mermaid_template.xlsx"
)


# preview the template in R
fish_template_and_options[["Template"]]

# or investigate the column names in R
names(fish_template_and_options)

# investigate all the availabe options for each column before adjusting the format
fish_template_and_options[["Site *"]]


#### 2. Reformat your data to match the template
# Fish belt method, predicting the fish size up to the closest cm
# 5 m width --> fish size 10-34 cm
# 20 m width --> fish size >=35 cm

# Load the data
fishbelt_data <- read.csv("F_Vaughan_UAE_2014-2016 (Cleaned) - F_Vaughan_UAE_2014-2016 - RAW data (SemiCleanV4).csv", sep=',')
sites_data <- read.csv("sites.csv", sep=';')

# look at the available columns in Site and fishbelt datasets
sites_data

fishbelt_data

# join the site and fishbelt data based on SiteID
fishbelt_data <- fishbelt_data %>%
  left_join(sites_data, by = "SiteID")

# observe the options for the missing columns
fish_template_and_options[["Width *"]]

fish_template_and_options[["Fish size bin *"]]

fish_template_and_options[["Observer emails *"]]

# adding missing mandatory columns (i.e. Width, Fish size bin, and Observer email)
fishbelt_data <- fishbelt_data %>%
  mutate(
    `Width *` = "Mixed: >10 cm & <35 cm @ 5 m, >=35 cm @ 20 m",
    `Fish size bin *` = 1,
    `Observer emails *` = "amkieltiela@gmail.com"
  )

# adjust the visibility column to match the MERMAID template
fishbelt_data %>%
  distinct(visibility) # check the current data

fish_template_and_options[["Visibility"]][["choices"]]  # check the options

fishbelt_data <- fishbelt_data %>%
  mutate(visibility = case_when(
    visibility == 1 ~ "<1m - bad",
    visibility == 5 ~ "1-5m - poor",
    visibility > 5 & visibility <= 10 ~ "5-10m",
    visibility >= 10 ~ ">10m - excellent"
  ))  # adjust the data

# rename the columns
names(fish_template_and_options[["Template"]])  # check the column names in the MERMAID template

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
names(fishbelt_data)[14] <- "Size *"
names(fishbelt_data)[13] <- "Count *"
fishbelt_data <- fishbelt_data %>%
  select(
    `Site *` = SiteID,
    `Management *` = Zone,
    `Sample date: Year *` = Year,
    `Sample date: Month *` = Month,
    `Sample date: Day *` = Day,
    `Depth *` = Depth.x,
    `Transect number *` = Transect_number,
    `Transect length surveyed *` = Transect_length,
    `Width *`,
    `Fish size bin *`,
    `Reef slope` = Reef_slope,
    `Visibility` = visibility,
    `Current` = current,
    `Observer emails *`,
    `Fish name *` = `Fish.species`,
    `Size *` = Size_cm,
    `Count *` = Abundance
  )  # reorder and rename the columns

colnames(fishbelt_data)

#### 3. Address errors and warnings
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

fishbelt_data <- fishbelt_data %>%
  mutate(`Site *` = case_when(
    `Site *` == 'Ras Ghanada' ~ 'RasGhanada',
    
    TRUE ~ `Site *`
  ))

fishbelt_data <- fishbelt_data %>%
  mutate(`Fish name *` = case_when(
    `Fish name *` == 'Pomacentrus trichourus' ~ 'Pomacentrus trichrourus',
    `Fish name *` == 'Pomacanthus maculosusentrus aquilus' ~ 'Pomacanthus maculosus',
    `Fish name *` == 'Scarus spp.' ~ 'Scarus iseri',
    `Fish name *` == 'Lethrinus spp.' ~ 'Lethrinus',
    `Fish name *` == 'Pseudochromis nigrovittatus' ~ 'Pseudochromis bitaeniatus',
    
    TRUE ~ `Fish name *`
  ))

fishbelt_data <- fishbelt_data %>% mutate(`Size *` = recode ( `Size *`,
                                                              "0-5" = "0-5", "6-10" = "5-10",
                                                              "11-15" = "10-15", "16-20" = "15-20",
                                                              "21-25" = "20-25", "26-30" = "25-30",
                                                              "31-35" = "30-35", "36-40" = "35-40",
                                                              "41-45" = "40-45", "46-50" = "45-50"))

fishbelt_data <- fishbelt_data %>% mutate(`Size *` = recode ( `Size *`,
                                                          "0-5" = "2.5", "5-10" = "7.5",
                                                          "10-15" = "12.5", "15-20" = "17.5",
                                                          "20-25" = "22.5", "25-30" = "27.5",
                                                          "30-35" = "32.5", "35-40" = "37.5",
                                                          "40-45" = "42.5", "45-50" = "47.5"))
fishbelt_data$`Size *` <- as.numeric(fishbelt_data$`Count *`)

fishbelt_data <- fishbelt_data %>%
  

  mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Fish name *")
  mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Size *")
  mermaid_import_check_options(fishbelt_data, fish_template_and_options, "Count *")
write_csv(fishbelt_data, "F_Vaughan_UAE_2014-2016 (Cleaned).csv")

fishbelt_data[fishbelt_data==""]<-NA
fishbelt_data<-fishbelt_data[complete.cases(fishbelt_data),]



#### 4. Import (ingest) data to MERMAID
mermaid_import_project_data(
  fishbelt_data,
  reef_survey,
  method = "fishbelt",
  dryrun = TRUE
)

mermaid_import_project_data(
  fishbelt_data,
  reef_survey,
  method = "fishbelt",
  dryrun = FALSE
)
