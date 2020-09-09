#install.packages("stringr")
#install.packages("dplyr")
#install.packages("ggplot2")

library(stringr)
library(dplyr)
library(ggplot2)
setwd("~/Documents/Development/r-covid/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us")
temp <- list.files(pattern="*.csv")
fullset <- matrix(, nrow = 0, ncol = 20)
for(i in 1:length(temp)){
  data <- read.csv(temp[i])
  new_date <- temp[i]
  new_date <- str_replace(new_date, ".csv", "")
  new_final_date <- as.Date(new_date, "%m-%d-%Y")
  data$main_date <- new_final_date
  fullset <- rbind(fullset, data)
}

setwd("~/Documents/Development/r-covid")
state_pop_data <- read.csv("state_populations.csv")

state_rate <- function(state_pop_data, data_set, state_names, min_date, max_date) {
  full_data_set <- matrix(, nrow = 0, ncol = 20)
  for(i in 1:length(state_names)) {
    state_name <- state_names[i]
    state_row <- filter(state_pop_data, State == state_name)
    state_population <- state_row$Population[1]
    new_data_set <- filter(data_set, Province_State == state_name)
    new_data_set <- mutate(new_data_set, difference = Confirmed - lag(Confirmed, default = 0))
    new_data_set$difference[1] <- 0
    state_pop_per_100_factor <- state_population / 100000
    new_data_set <- mutate(new_data_set, per_100K = round(difference / state_pop_per_100_factor, digits = 1))
    full_data_set <- rbind(full_data_set, new_data_set)
  }
  full_data_set <- filter(full_data_set, main_date >= as.Date(min_date, "%m-%d-%Y"))
  full_data_set <- filter(full_data_set, main_date <= as.Date(max_date, "%m-%d-%Y"))
  return(full_data_set)
}

minimum_date <- "08-09-2020"
maximum_date <- "09-09-2020"
states <- c("Oklahoma", "New York")

statesets <- state_rate(state_pop_data, fullset, states, minimum_date, maximum_date)

statesets %>% ggplot(aes(x=main_date, y=per_100K, color=Province_State, label=per_100K)) + labs(x = "Date", y = "Cases per 100K") + geom_line() + geom_point() + geom_text(aes(label=per_100K), hjust = 0.5, vjust = -1)

