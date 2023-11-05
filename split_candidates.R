# Script to identify non-movers and potential movers 
# Separates individual between years in to movers and non-movers to help reduce pool of candidate individuals
# James Todd - '23

library(dplyr)

# Format input strings


current_input <- commandArgs(trailingOnly = TRUE)[1]
next_input <- commandArgs(trailingOnly = TRUE)[2]

path <- dirname(current_input)
prefecture <- sub('.*/\\d{4}_(\\d{2}).*', '\\1', current_input)
current_year <- sub('.*/(\\d{4})_.*', '\\1', current_input)
next_year <- sub('.*/(\\d{4})_.*', '\\1', next_input)

pref_current <- read.csv(current_input)
pref_next <- read.csv(next_input)


# Count number of individuals by address
pref_current_count <- pref_current %>%
  group_by(name, Prefecture, City, Town, Address) %>%
  summarise(row_count = n()) %>%
  ungroup() %>% 
  mutate(year = current_year)

pref_next_count <- pref_next %>%
  group_by(name, Prefecture, City, Town, Address) %>%
  summarise(row_count = n()) %>%
  ungroup() %>% 
  mutate(year = next_year)

# Combine counts from consecutive years by name and address
pref_combined <- merge(pref_current_count, pref_next_count, by = c("name", "Prefecture", "City", "Town", "Address"), all = TRUE, suffixes = c("_current", "_next"))

# Filter - NON MOVER 
no_move <- pref_combined %>% 
  filter(row_count_current == 1 & row_count_next == 1)
fname_no_move <- paste0(path, "/Split/", current_year, "_", prefecture, "_nomove.csv")
write.csv(no_move, fname_no_move, row.names = F)

# Filter - MOVE OUT in current year
move_out <- pref_combined %>% 
  filter(row_count_current >= 1 & is.na(row_count_next))
fname_move_out <- paste0(path, "/Split/", current_year, "_", prefecture, "_moveout.csv")
write.csv(move_out, fname_move_out, row.names = F)

# Filter - MOVE IN in next year
move_in <- pref_combined %>% 
  filter(is.na(row_count_current) & row_count_next >= 1) 
fname_move_in <- paste0(path, "/Split/", current_year, "_", prefecture, "_movein.csv")
write.csv(move_in, fname_move_in, row.names = F)

# Filter - Unknowns
other <- pref_combined %>%
  filter(!(is.na(row_count_current) & row_count_next >= 1) &
           !(row_count_current >= 1 & is.na(row_count_next)) &
           !(row_count_current == 1 & row_count_next == 1))
fname_other <- paste0(path, "/Split/", current_year, "_", prefecture, "_other.csv")
write.csv(other, fname_other, row.names = F)  
