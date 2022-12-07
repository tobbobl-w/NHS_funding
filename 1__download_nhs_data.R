# Download data. 

library(tidyverse)
library(rvest)
library(readODS)
library(reticulate)


data_webpage <- "https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/rtt-data-2021-22/"

page <- read_html(data_webpage)

links_for_year <- page %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  grep("rtt", ., value = T)



base_url <- "https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/rtt-data-YEAR-SHORT_YEAR/"

DownloadData <- function(url_for_download){
  month_year <- str_extract(url_for_download, 
                            "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\d{2}")
  
  month <- str_extract(month_year, 
                       "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)")
  year <- str_extract(month_year, 
                      "\\d{2}")
  
  dir_to_create <- paste0("data/rtt_waiting_times/", as.numeric(year) + 2000)
  
  if (!dir.exists(dir_to_create)) dir.create(dir_to_create)

  filename <- basename(url_for_download)
  
  dir_filename <- paste0(dir_to_create, "/", filename)
  
  download.file(url = url_for_download,
                destfile = dir_filename,
                mode = "wb")
  }


GetDataForYear <- function(year){
  
  short_year <- year - 1999 # short year is two digits and one ahed of year
  
  url_for_year <- str_replace(base_url, 
                              "YEAR", 
                              as.character(year)) %>% 
    str_replace(., "SHORT_YEAR", as.character(short_year))
  
  print(url_for_year)
  page <- read_html("https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/rtt-data-2012-13/")
  
  links_for_year <- page %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    grep("Incomplete-Commissioner", ., value = T)

  if (length(links_for_year) == 0) {
    links_for_year <- page %>% 
      html_nodes("a") %>% 
      html_attr("href") %>% 
      grep("Incomplete_Commissioner", ., value = T)
    }
  
  lapply(links_for_year, 
         DownloadData)
  
  } 

if (!dir.exists("data/rtt_waiting_times")) dir.create("data/rtt_waiting_times", recursive = T)

lapply(c(2012:2022), 
       GetDataForYear)

# Manually download data from 2011 

