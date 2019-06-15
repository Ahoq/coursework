########################################

# load libraries

########################################



# load some packages that we'll need

library(tidyverse)

library(scales)



# be picky about white backgrounds on our plots

theme_set(theme_bw())



# load RData file output by load_trips.R

load('trips.RData')





########################################

# plot trip data

########################################



# plot the distribution of trip times across all rides

trips %>%
  
  filter(tripduration/60 < 1000) %>%
  
  ggplot() + 
  
  geom_histogram(aes(x = tripduration/60)) + 
  
  scale_x_log10(label = comma) +
  
  scale_y_continuous(label = comma) +
  
  xlab("Trip Duration") +
  
  ylab("Number of Trips")

# plot the distribution of trip times by rider type

ggplot(trips, aes(x = tripduration/60, color = usertype, fill = usertype)) +
  
  geom_histogram(alpha = 0.25, position="identity", bins = 50) +
  
  scale_x_log10(labels = comma) +
  
  xlab('Trip duration (in mins)') +
  
  ylab('Number of trips') 

# plot the total number of trips over each day
trips %>%
  
  group_by(ymd) %>%
  
  summarise(trips_count = n()) %>%
  
  ggplot() +
  
  geom_line(aes(x = ymd, y = trips_count)) +
  
  xlab("Day") +
  
  ylab("Total Number of trips")


# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)

trips %>%
  mutate(age = year(ymd) - birth_year) %>%
  group_by(gender, age) %>%
  summarise(trips_count = n()) %>%
  ggplot()+
  geom_point(aes(x= age, y = trips_count, color = gender))+
  scale_y_continuous(labels = comma, limits = c(0,300000))+
  scale_color_brewer(palette ="Set1", direction = -1)

# plot the ratio of male to female trips (on the y axis) by age (on the x axis)

# hint: use the spread() function to reshape things to make it easier to compute this ratio
trips %>%
  mutate(age = year(ymd) - birth_year) %>%
  group_by(gender, age) %>%
  summarise(trips_count = n()) %>%
  spread(gender, trips_count) %>%
  ggplot()+
  geom_point(aes(x = age , y = Male/Female), color ="blue")+
  scale_y_continuous(labels = comma)



########################################

# plot weather data

########################################

# plot the minimum temperature (on the y axis) over each day (on the x axis)

weather %>%
  ggplot()+
  geom_line(aes(x= ymd , y = tmin), color = "purple")

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)

# hint: try using the gather() function for this to reshape things before plotting

weather %>%
  gather("temp","value", "tmin", "tmax") %>%
  ggplot() + geom_line(aes(x = ymd, y= value, color = temp ))+
  xlab("Day") +
  ylab("Temperature")

########################################

# plot trip and weather data

########################################



# join trips and weather

trips_with_weather <- inner_join(trips, weather, by="ymd")



# plot the number of trips as a function of the minimum temperature, where each point represents a day

# you'll need to summarize the trips and join to the weather data to do this

trips_with_weather %>%
  
  group_by(ymd, tmin) %>%
  
  summarize(trips_count = n()) %>%
  
  ggplot() +
  
  geom_point(mapping = aes(x = tmin, y = trips_count), color="purple")+
  
  labs(x="Min. Temp.", y = "Number of Trips")

# repeat this, splitting results by whether there was substantial precipitation or not

# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this

trips_with_weather %>%
  group_by(ymd, tmin, prcp) %>%
  summarise(trips_count = n()) %>%
  ungroup %>%
  mutate(subs_prcp = ifelse(prcp >= 0.7, 'True', 'False')) %>%
  ggplot(aes(x = tmin, y = trips_count, color = subs_prcp)) +
  geom_line()+
  labs(x="Min. Temp.", y = "Number of Trips")


# add a smoothed fit on top of the previous plot, using geom_smooth
trips_with_weather %>%
  group_by(ymd, tmin, prcp) %>%
  summarise(trips_count = n()) %>%
  ungroup %>%
  mutate(subs_prcp = ifelse(prcp >= 0.7, 'T', 'F')) %>%
  ggplot(aes(x = tmin, y = trips_count, color = subs_prcp)) +
  geom_point()+
  geom_smooth(alpha =0.8)+
  labs(x="Min. Temp.", y = "Number of Trips")


# compute the average number of trips and standard deviation in number of trips by hour of the day

# hint: use the hour() function from the lubridate package

trips %>%
  mutate(hour = hour(starttime)) %>%
  group_by(hour, ymd) %>%
  summarise(trips_count = n()) %>% 
  group_by(hour) %>%
  summarise(avg = mean(trips_count), sd = sd(trips_count)) %>%
  ggplot()+
  geom_line(aes(x = hour, y = avg), color ="blue") +
  geom_ribbon(aes(x = hour, ymin = avg-sd , ymax = avg+sd),alpha =0.5) +
  labs(x="Hour", y = " Avg. Number of Trips")



# plot the above



# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days

# hint: use the wday() function from the lubridate package

trips %>%
  mutate(hour = hour(starttime), wkday = wday(ymd, label = TRUE)) %>%
  group_by(hour, ymd, wkday) %>%
  summarise(trips_count = n()) %>%
  group_by(hour, wkday) %>%
  summarise(avg = mean(trips_count), sd = sd(trips_count)) %>%
  ggplot()+
  geom_line(aes(x = hour, y = avg), color ="blue") +
  geom_ribbon(aes(x = hour, ymin = avg-sd , ymax = avg+sd),alpha =0.5) +
  facet_wrap(~wkday) +
  labs(x="Hour", y = " Avg. Number of Trips")

