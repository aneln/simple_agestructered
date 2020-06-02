library(tidyverse)
library(glue)
library(data.table)

args <- commandArgs(trailingOnly = T)
run.output.dir <- args[[1]]
output.name <- args[[2]]

individual.files <- list.files(path = run.output.dir,  pattern = ".*individual.*", full.names = T)
individual.data <- map(individual.files, function(filename){
  t <- as.numeric(str_match(filename, ".*_t([0-9]+)\\.csv")[,2])
  read_csv(filename, comment = "#") %>%
    group_by(quarantined, app_user) %>%
    summarise(n.quarantine.app = n()) %>%
    add_column(time = t) 
}) %>% bind_rows()

write_csv(individual.data, output.name)