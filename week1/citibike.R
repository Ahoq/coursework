library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv')

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips))

# convert dates strings to dates
# trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))


########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
nrow(trips)

# find the earliest and latest birth years (see help for max and min to deal with NAs)
trips %>%
	mutate(birth_year=as.numeric(birth_year)) %>%
	select(birth_year) %>%
	summarise_each(funs(earliest_birth_year = min(., na.rm = TRUE),
	                    latest_birth_year = max(., na.rm = TRUE))) 
# use filter and grepl to find all trips that either start or end on broadway
trips %>%
  filter(grepl('Broadway', start_station_name)
       | grepl('Broadway', end_station_name))
# do the same, but find all trips that both start and end on broadway
trips %>%
  filter(grepl('Broadway', start_station_name)
         & grepl('Broadway', end_station_name))
# find all unique station names
union(trips$start_station_name, trips$end_station_name)
# count the number of trips by gender, the average trip time by gender, and the standard deviation in trip time by gender
# do this all at once, by using summarize() with multiple arguments
trips %>%
  group_by(gender) %>%
  summarise(number_of_trips = n(),
            avg_trip_time = mean(tripduration),
            std_dev = sd(tripduration))
# find the 10 most frequent station-to-station trips
trips %>%
  group_by(start_station_name, end_station_name) %>%
  summarise(trips_count = n()) %>%
  arrange(desc(trips_count)) %>%
  head(10) %>% view()
# find the top 3 end stations for trips starting from each start station
trips %>%
  group_by(start_station_id,end_station_id) %>%
  summarise(trips_count = n()) %>%
  group_by(start_station_id) %>%
  filter(rank(desc(trips_count))<= 3)
 
  
# find the top 3 most common station-to-station trips by gender
trips %>%
  group_by(start_station_id,end_station_id,gender) %>%
  summarise(trips_count = n()) %>%
  group_by(gender) %>%
  filter(rank(desc(trips_count))<= 3) %>%
  arrange(gender, desc(trips_count))
# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)
trips %>%
  mutate(date=as.Date(starttime)) %>%
  group_by(date) %>%
  summarize(trips_count = n()) %>%
  arrange(trips_count) %>%
  tail(1)
# compute the average number of trips taken during each of the 24 hours of the day across the entire month
# what time(s) of day tend to be peak hour(s)?
trips %>%
  mutate(day = as.Date(starttime), hour = hour(starttime)) %>%
  group_by(day,hour) %>%
  summarise(trips_count = n()) %>%
  group_by(hour) %>%
  summarise(avg = mean(trips_count)) %>%
  arrange(desc(avg)) %>% view()
