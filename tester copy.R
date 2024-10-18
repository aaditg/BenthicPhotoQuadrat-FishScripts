# Specify the name of your original file
original_file <- "F_BurtJohansen_2019_UAE_Musandam (SemiClean) - SurveyData (1).csv"

# Load your data from the original file into the 'df' data frame
df <- read.csv(original_file)

# Define the column indices for the range columns
column_indices <- 14:25

# Create a new list to store the duplicated rows
duplicated_rows <- list()

# Iterate over each row in the original data frame
for (i in 1:nrow(df)) {
  row <- df[i, ]  # Get the current row
  
  # Extract the range column values and check for missing or invalid values
  range_values <- as.numeric(row[column_indices])
  if (any(is.na(range_values)) || any(range_values < 0)) {
    next  # Skip the row if there are missing or invalid values
  }
  
  # Duplicate the row based on the range column values
  duplicated <- lapply(range_values, function(value) rep(row, times = value))
  
  # Append the duplicated rows to the list
  duplicated_rows <- c(duplicated_rows, duplicated)
}

# Combine the original data frame with the duplicated rows
duplicated_df <- do.call(rbind, duplicated_rows)

# Specify the file name where you want to save the duplicated data
duplicated_file <- "duplicated_data.csv"

# Save the duplicated data to the specified CSV file
write.csv(duplicated_df, file = duplicated_file, row.names = FALSE)
