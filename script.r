install.packages("stringr")

setwd("~/Documents/Development/r-covid/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us")
temp <- list.files(pattern="*.csv")
for(i in 1:length(temp)){
  data <- read.csv(temp[i])
  new_date <- temp[i]
  str_replace(new_date, ".csv", "")
  data$main_date <- new_date
  if(i == 1){
    View(data)
  }
}
