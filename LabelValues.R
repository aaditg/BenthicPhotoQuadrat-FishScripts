###############################################################################
############## Ingesting legacy/Coralnet data into MERMAID ####################
############# Author: Amkieltiela & Sharla Gelfand & Aadit Golwala ############
###############################################################################

# The steps for importing (ingesting) legacy data are:
# 1. Download the benthic PQT MERMAID template
# 2. Reformat your data to match the template
#   a) Switch Rows and Columns
#   b) Format Date
#   c) Address Labels
#   d) Append Files
#   e) Final Formatting
# 3. Address errors and warnings
# 4. Import (ingest) data to MERMAID


# set working directory
setwd("/Downloads")

#### 1. Download the benthic MERMAID template

# install the mermaidr package
remotes::install_github("data-mermaid/mermaidr", force = TRUE)

# activate libraries
library(mermaidr)
library(tidyverse)
library(readxl)

reef_survey <- mermaid_search_my_projects("Burt_2015-2017_Qatar", include_test_projects = TRUE)
mermaid_auth()

pqt_template_and_options <- mermaid_import_get_template_and_options(
  reef_survey,
  "benthicpqt",
  "benthicpqt_mermaid_template.xlsx"
)


# preview the template in R
pqt_template_and_options[["Template"]]

# or investigate the column names in R
names(pqt_template_and_options)

# investigate all the availabe options for each column before adjusting the format
pqt_template_and_options[["Site *"]]

benthicpqt_data <- read.csv("B_Burt_2015-2017_Qatar (Cleaned) - B_Burt_2015-2017_Qatar(SemiClean).csv", sep=',')
sites_data <- read.csv("sites.csv", sep=';')

# look at the available columns in Site and benthicpqt datasets
sites_data

benthicpqt_data

# join the site and benthicpqt data based on SiteID
benthicpqt_data <- benthicpqt_data %>%
  left_join(sites_data, by = "SiteID")

# observe the options for the missing columns
pqt_template_and_options[["Depth *"]]
pqt_template_and_options[["Observer emails *"]]

# adjust the visibility column to match the MERMAID template
benthicpqt_data %>%
  distinct(visibility) # check the current data

pqt_template_and_options[["Visibility"]][["choices"]]  # check the options

benthicpqt_data <- benthicpqt_data %>%
  mutate(visibility = case_when(
    visibility == 1 ~ "<1m - bad",
    visibility == 5 ~ "1-5m - poor",
    visibility > 5 & visibility <= 10 ~ "5-10m",
    visibility >= 10 ~ ">10m - excellent"
  ))  # adjust the data

# rename the columns
names(pqt_template_and_options[["Template"]])  # check the column names in the MERMAID template



benthicpqt_data <- benthicpqt_data %>%
  select(
    `Site *` = SiteID,
    `Management *` = Zone,
    `Sample date: Year *` = Year,
    `Sample date: Month *` = Month,
    `Sample date: Day *` = Day,
    `Depth *` = Depth.x,
    `Transect number *` = Transect_number,
    `Transect length surveyed *` = Transect_length,
    `Number of quadrats *`,
    `Quadrat size *` = Quadrat_size,
    `Reef slope` = Reef_slope,
    `Visibility` = visibility,
    `Current` = current,
    `Observer emails *`,
    `Quadrat *`,
    `Benthic Attribute *` = `benthic.species`,
    `Number of porints *` = Number_of_points
  )  # reorder and rename the columns

colnames(benthicpqt_data)

#### a) Swap Rows and Columns
header_row <- colnames(benthicpqt_data)
modified_data <- data.frame(matrix(ncol = length(header_row)))
colnames(modified_data) <- header_row

# Iterate over each row in the data
for (i in 3:nrow(data)) {
  row <- as.character(data[i, ])
  
  # Count the number of nonzero values from column 9 onward
  nonzero_count <- sum(as.numeric(row[3:ncol(data)]) != 0) + 1
  
  if (nonzero_count > 0) {
    for (column_header in column_headers) {
      # Calculate the corresponding column index
      column_index <- match(column_header, colnames(data)) + 3
      
      value <- row[column_index]
      
      if (value != '0') {
        duplicated_row <- c(column_header, value, row[0:3])
        modified_data <- rbind(modified_data, duplicated_row)
      }
    
  }
}

# Write the modified data to the output CSV file
write_csv(modified_data, output_file)

cat("CSV file has been modified and saved as", output_file, "\n")
}


#### b) Date Formatting

output_columns <- c('Year', 'Month', 'Day')

input_file <- 'your_input_file.csv'
output_file <- 'your_output_file.csv'

csv_input <- read_csv(input_file)
header <- colnames(csv_input)

# Find the index of the 'Date' column
date_index <- match('Date', header)

# Append the output column names to the existing header
output_header <- c(header, output_columns)

# Create a new data frame to store the output
output_data <- data.frame()

for (i in 1:nrow(csv_input)) {
  row <- csv_input[i, ]
  date <- row[date_index]
  date_parts <- strsplit(date, '-')[[1]]
  year <- date_parts[1]
  month <- sprintf('%02d', as.numeric(date_parts[2]))
  day <- sprintf('%02d', as.numeric(date_parts[3]))
  
  # Create a new row with the original data plus the year, month, and day
  new_row <- c(row, year, month, day)
  
  output_data <- rbind(output_data, new_row)
}

colnames(output_data) <- output_header
write_csv(output_data, output_file)

#### c) Edit Labels

# Read the Excel file
xlsx_file_path <- "LABELSET FILE PATH.xlsx"
xlsx_data <- read_excel(xlsx_file_path)

# Perform the replacement
for (index in 1:nrow(benthicpqt_data)) {
  label <- benthicpqt_data[index, "Benthic Attribute *"]
  match_row <- xlsx_data[xlsx_data$`Short Code` == label, ]
  if (!is_empty(match_row)) {
    replacement_value <- match_row$Name[1]
    benthicpqt_data[index, "Benthic Attribute *"] <- replacement_value
  } else {
    replacement_value <- "Other"
  }
}

# Save the modified data back to the CSV file
write.csv(benthicpqt_data, csv_file_path, row.names = FALSE)



#### d) If needed, combine files and remove duplicate rows

combine_csv_files <- function(input_files, output_file) {
  headers <- character(0)
  rows <- list()
  
  for (file in input_files) {
    data <- read_csv(file)
    file_headers <- colnames(data)
    if (length(headers) == 0) {
      headers <- file_headers
    } else {
      new_headers <- setdiff(file_headers, headers)
      headers <- c(headers, new_headers)
    }
    rows <- c(rows, data)
  }
  
  combined_data <- bind_rows(rows) %>% select(all_of(headers))
  write_csv(combined_data, output_file)
  
}

remove_duplicates <- function(input_file, output_file) {
  data <- read_csv(input_file)
  data <- data %>% mutate(Count = 1)  # Add a 'Count' column
  unique_data <- distinct(data)
  
  write_csv(unique_data, output_file)
  
}

combine_csv_files(input_files, output_file)
remove_duplicates(input_file, output_file)

#### e) Add other columns

# Function to add a new column to a dataset
add_column_to_dataset <- function(dataset_file, new_column_name, new_column_values) {
  # Read the existing dataset
  dataset <- read_csv(dataset_file)
  
  # Add the new column with provided values
  dataset[[new_column_name]] <- new_column_values
  
  # Save the modified dataset as a new CSV file
  output_file <- sub(".csv", paste0("_with_", new_column_name, ".csv"), dataset_file)
  write_csv(dataset, output_file)

}



#### 4. Address errors and warnings
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Site *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Management *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Sample date: Year *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Sample date: Month *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Sample date: Day *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Depth *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Transect number *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Transect length surveyed *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Number of quadrats *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Quadrat size *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Number of points per quadrat *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Reef slope")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Visibility")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Current")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Observer emails *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Quadrat *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Benthic attribute *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Number of points *")

benthicpqt_data <- benthicpqt_data %>%

  mutate(`Observer emails *` = case_when(
    `Observer emails *` == 'John.Burt@nyu.edu' ~ '24agolwala@gmail.com',
    TRUE ~ `Observer emails *`
    
  
))
benthicpqt_data <- benthicpqt_data %>%
  
  mutate(`Observer emails *` = case_when(
    `Benthic attribute *` == 'Dipsastraea' ~ 'Dipsastrea',
    `Benthic attribute *` == 'hydrozoan' ~ 'Other',
    `Benthic attribute *` == 'Shadow' ~ 'Other',
    `Benthic attribute *` == 'rubble ' ~ 'Rubble',
    
    TRUE ~ `Observer emails *`
    
    
    
  ))

benthicpqt_data <- benthicpqt_data %>%
  
  
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Benthic Attribute *")
mermaid_import_check_options(benthicpqt_data, pqt_template_and_options, "Number of points *")
write_csv(benthicpqt_data, "CLEANED.csv")

benthicpqt_data[benthicpqt_data==""]<-NA
benthicpqt_data<-benthicpqt_data[complete.cases(benthicpqt_data),]



#### 5. Import (ingest) data to MERMAID

mermaid_import_project_data(
  benthicpqt_data,
  reef_survey,
  method = "benthicpqt",
  dryrun = TRUE
)

mermaid_import_project_data(
  benthicpqt_data,
  reef_survey,
  method = "benthicpqt",
  dryrun = FALSE,
)



