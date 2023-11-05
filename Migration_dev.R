# Japanese Chocho-Level Migration Model 
# Developmental script
# James Todd - Oct '23

# Copy stuff from other script here

# Tidy Snakemake so it works 

# Update .gitignore to include all unecesasry data/scripts 

# Read through report and package up data, sign contract, send to Keiji and Sachie. 

# Load in libraries 
library(geosphere)
library(data.table)
library(ggplot2)

# Function to load in candidate separated data
read_files_into_dataframe <- function(dir, pat) {
  
  files <- list.files(path = dir, pattern = pat, full.names = TRUE)
  
  combined_data <- data.table()
  
  for (i in seq_along(files)) {
    file <- files[i]
    data <- fread(file)  # Use fread for faster file reading
    
    combined_data <- rbindlist(list(combined_data, data))
    
    cat("Done ", i, "/", length(files), "\n")
  }
  
  return(combined_data)
}

# Load in data

# Origin Candidates (Osaka 2009)
moveout_osaka_09 <- read.csv("/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split/2009_27_moveout.csv")
moveout_osaka_09 <- merge(moveout_kyoto_09, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)

# Destination Candidates
# Japan 2009
movein_9 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2009_.*_movein")
movein_9 <- merge(movein_9, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)

other_9 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2009_.*_other")
other_9 <- merge(other_9, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)
# Japan 2010
movein_10 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2010_.*_movein")
movein_10 <- merge(movein_10, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)

other_10 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2010_.*_other")
other_10 <- merge(other_10, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)
# Japan 2011
movein_11 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2011_.*_movein")
movein_11 <- merge(movein_11, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)

other_11 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2011_.*_other")
other_11 <- merge(other_11, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)
# Japan 2012
movein_12 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2012_.*_movein")
movein_12 <- merge(movein_12, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)

other_12 <- read_files_into_dataframe(dir = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/GeocodedAddresses/Split", pat = "2012_.*_other")
other_12 <- merge(other_12, chocho_coords, by = c("Prefecture", "City", "Town"), all.x = T)


# Selecting the most likely candidate

# Create emtpty output dataframe
results <- data.frame(matrix(ncol = 12, nrow = 0))
colnames(results) <- colnames(result2)

# Loop through each Origin candidate
for (i in 1:nrow(moveout_osaka_09)){
  
  candidates <- data.frame(matrix(ncol = 23, nrow = 0))
  colnames(candidates) <- c("name", "Prefecture_o", "City_o", "Town_o", "Address_o",        
                            "row_count_current_o", "year_current_o", "row_count_next_o", "year_next_o", "Latitude_o",       
                            "Longitude_o", "Prefecture_d", "City_d", "Town_d", "Address_d",    
                            "row_count_current_d", "year_current_d", "row_count_next_d", "year_next_d", "Latitude_d",   
                            "Longitude_d", "dist", "source")
  
  moveout_1 <- moveout_osaka_09[i,]
  
  for (year in 1:4) {
    movein_df <- get(paste0("movein_", year+8))
    other_df <- get(paste0("other_", year+8))
    
    # Merge movein and other dataframes for the current year
    candidates_in <- merge(moveout_1, movein_df, by = "name", all.x = TRUE, suffixes = c("_o", "_d"))
    candidates_in$dist <- distGeo(matrix(c(candidates_in$Longitude_o, candidates_in$Latitude_o), ncol = 2),
                                  matrix(c(candidates_in$Longitude_d, candidates_in$Latitude_d), ncol = 2)) / 1000
    candidates_in$source <- paste0(year,"_a")
    candidates_in <- candidates_in[!is.na(candidates_in$Prefecture_d),]
    
    
    if (nrow(candidates_in) > 0) {
      candidates <- rbind(candidates, candidates_in)
    }
    
    candidates_other <- merge(moveout_1, other_df, by = "name", all.x = TRUE, suffixes = c("_o", "_d"))
    candidates_other$dist <- distGeo(matrix(c(candidates_other$Longitude_o, candidates_other$Latitude_o), ncol = 2),
                                     matrix(c(candidates_other$Longitude_d, candidates_other$Latitude_d), ncol = 2)) / 1000
    candidates_other$source <- paste0(year,"_b")
    candidates_other <- candidates_other[!is.na(candidates_other$Prefecture_d),]
    
    if (nrow(candidates_other) > 0) {
      candidates <- rbind(candidates, candidates_other)
    }
    
  }
  
  best_candidate <- candidates %>%
    group_by(name, Prefecture_o, City_o, Town_o, Address_o, source) %>%
    arrange(dist, .by_group = TRUE) %>% 
    summarize(
      cands = n(),
      mindist = min(dist, na.rm = TRUE),
      d_Prefecture = Prefecture_d[which.min(dist)],
      d_City = City_d[which.min(dist)],
      d_Town = Town_d[which.min(dist)],
      maxdist = max(dist, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    group_by(name, Prefecture_o, City_o, Town_o, Address_o) %>%
    arrange(source) %>%
    slice(1) %>%
    summarize(
      cands = sum(cands),
      mindist = min(mindist),
      source = first(source),
      d_Prefecture = first(d_Prefecture),
      d_City = first(d_City),
      d_Town = first(d_Town),
      maxdist = max(maxdist),
      .groups = "drop"
    )
  
  results <- rbind(results, best_candidate)
}


# Plot preliminary results for report
ggplot(results, aes(x = cands)) + geom_histogram(bins = 50, stat = "bin", fill = "red", col = "red") + 
  scale_x_continuous(breaks = seq(0,32000,2500)) +
  scale_y_continuous(breaks = seq(0,22500,2500)) + 
  labs(x = "No. Candidates", y = "Frequency") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggplot(results, aes(x = dist)) + geom_histogram(bins = 50, stat = "bin", fill = "blue", col = "blue") + 
  scale_x_continuous(breaks = seq(0,1600,100)) +
  scale_y_continuous(breaks = seq(0,30000,1000)) + 
  labs(x = "Move Distance (km)", y = "Frequency") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggplot(results, aes(x = source)) + geom_histogram(stat = "count", fill = "green", col = "green") + 
  scale_x_discrete(labels = c("Move-in '09", "Other '09", "Move-in '10", "Other '10", "Move-in '11", "Other '11", "Move-in '12", "Other '12")) + 
  scale_y_continuous(breaks = seq(0,35000,2500)) + 
  labs(x = "Move Candidate Source", y = "Frequency") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))