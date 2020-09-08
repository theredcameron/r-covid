#install.packages("stringr")
#install.packages("dplyr")
#install.packages("ggplot2")

library(stringr)
library(dplyr)
library(ggplot2)
setwd("~/Documents/Development/r-covid/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us")
temp <- list.files(pattern="*.csv")
fullset <- matrix(, nrow = 0, ncol = 20)
statesets <- matrix(, nrow = 0, ncol = 20)
for(i in 1:length(temp)){
  data <- read.csv(temp[i])
  new_date <- temp[i]
  new_date <- str_replace(new_date, ".csv", "")
  new_final_date <- as.Date(new_date, "%m-%d-%Y")
  data$main_date <- new_final_date
  fullset <- rbind(fullset, data)
}

state_rate <- function(total_data_set, data_set, state_name, state_population) {
  setwd("~/Documents/Development/r-covid")
  state_pop_data <- read.csv("state_populations.csv")
  new_data_set <- filter(data_set, Province_State == state_name)
  new_data_set <- mutate(new_data_set, difference = Confirmed - lag(Confirmed, default = 0))
  new_data_set$difference[1] <- 0
  state_pop_per_100_factor <- state_population / 100000
  new_data_set <- mutate(new_data_set, per_100K = difference / state_pop_per_100_factor)
  total_data_set <- rbind(total_data_set, new_data_set)
  return(total_data_set)
}

statesets <- state_rate(statesets, fullset, "Colorado", 5845530)

statesets <- state_rate(statesets, fullset, "Oklahoma", 3954820)

#statesets <- state_rate(statesets, fullset, "California", 39937500)

#statesets <- state_rate(statesets, fullset, "New York", 19440500)

#statesets <- state_rate(statesets, fullset, "Texas", 29472300)

statesets %>% ggplot(aes(x=main_date, y=per_100K, color=Province_State)) + geom_line()