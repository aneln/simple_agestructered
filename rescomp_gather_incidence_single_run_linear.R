library(tidyverse)
library(glue)

args <- commandArgs(trailingOnly = T)

# Full path to the folder containing files of the type individual_file_Run1_t*.csv
indiv.day.folder <- args[[1]] 

# List of individual_file_Run1_t*.csv files
time.files <- list.files(path = indiv.day.folder,  pattern = ".*individual.*_t.*", full.names = T)
# print(time.files)

# Set path of the output file to be the one that individual_file_Run1_t*.csv files were read from 
# and name the output file aggregated_individual_file.csv
#output.name <- glue("/well/covid/users/wpj711/full-simple_quarantine/output/space_conscious/{indiv.day.folder}/aggregated_individual_file.csv") 
# print(output.name)
output.name <- args[[2]]

# Calculate number of individuals by app user (yes=1, no=0) and been infected status (yes=1, no=0)
# for each time step and merge all the data from different timesteps into a single fil per run
individual.data <- map(time.files, function(filename){
  t <- as.numeric(str_match(filename, ".*_t([0-9]+)\\.csv")[,2])
  read_csv(filename, comment = "#") %>%
    group_by(app_user, infection_count) %>%
    summarise(n.individuals = n()) %>%
    add_column(time = t)
}) %>% bind_rows()


#print(individual.data)

write_csv(individual.data, output.name)
