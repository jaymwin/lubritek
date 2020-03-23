
# lubritek

<!-- badges: start -->
<!-- badges: end -->

Functions to write GPS schedules (ASF files) for Lotek PinPoint tags in R with 'lubridate' functions as an alternative to manually creating schedules using Lotek's PinPoint Host software. Currently, functions allow users to write batches of schedules for 1) testing tags (using guidance from Alan at Lotek), and 2) `rollover` schedules where fixes are taken X days apart. The latter function allows you to write a schedule for each day in a period when you plan to deploy tags. I borrow heavily from code written here (https://github.com/adamdsmith/pinpoint) by Adam Smith, USFWS biometrician, which does the bulk of creating schedules. 

Planning to include other functions to allow for `discrete` schedules and other flexibility in creating schedules. However, there's a limit to ASF file size where more complicated schedules won't be possible.

## Installation

``` r
# If devtools package is not installed
install.packages("devtools", dependencies = TRUE)

# Now install and load lubritek
devtools::install_github("jaymwin/lubritek")
library(lubritek)
```

## Main functions

1. **create_rollover_schedules.R** - Write 'Rolling Interval' or 'Rollover' rule schedules that start every day between the start and end date of your study period. Schedules take one GPS fix at the same time every day, 2 days, 5 days, etc., and .ASF files are named by the time zone where an animal is initially tagged, rollover interval, and date when the first GPS fix will be taken.

1. **create_testing_schedules.R** - This will create a schedule for each tag, with the start time between schedules staggered 5 minutes apart from each other for testing purposes (i.e., making sure tags transmit data to Argos system before deployment). Schedules will take a point once every hour for 12 hours, which is the testing scheduled recommended by Alan at Lotek.

1. **view_time_zones.R** - View a list of potential time zones in the region where you plan to deploy tags (e.g., America, Canada, UTC...).

1. **view_rollover_schedules.R** - Before creating schedules, ensure that Lotek PinPoint tags will record data at the proper times by viewing fix schedule in a ggplot calendar or timeline.

1. **parse_asf_schedule.R** - Read a Lotek PinPoint Host software-made schedule (or a schedule made with this package) so you can see the structure needed to write different rules in R (I haven't tried the Cyclic rule yet). 

## Using lubritek

### Create testing schedules

Find the time zone that you're going to be deploying tags in:

``` r
view_time_zones(region = 'America')
```

Create schedules for the tags you'd like to test:

``` r
create_testing_schedules(
  test_period = 12, # number of hours to have the tags on
  time_zone = 'America/Boise', # time zone where tags will be deployed
  stagger_time = '5 min', # minutes to stagger fix times between tags
  fix_interval = '1 hour', # how often each tag should attempt to take a GPS fux
  start_datetime = '2020-04-20 12:00:00', # when to start testing the tags
  transmitter_list = c('1745021', '1745026'), # list of Lotek transmitter IDs
  output_location = '/Users/Jay/Desktop' # path to save ASF schedules
  )
```

### Create rollover schedules

First, create a ggplot object (calendar or timeline view) to see when the planned schedules will take fixes:

``` r
# calendar view

view_rollover_schedules(
  tag_lifespan = 400, # how long is this schedule expected to last (this is provided by Host software)?
  time_zone = 'America/Boise', # deployment time zone
  location_cycle = 2, # time between fixes (in days)
  first_deployment_date = '2020-03-23 15:00:00', # what's the first datetime you will deploy tags?
  last_deployment_date = '2020-04-15 15:00:00', # what's the last datetime you will deploy tags?
  type = 'calendar'
)
```

``` r
# timeline view

view_rollover_schedules(
  tag_lifespan = 400,
  time_zone = 'UTC',
  location_cycle = 2,
  first_deployment_date = '2020-03-23 15:00:00',
  last_deployment_date = '2020-04-15 15:00:00',
  type = 'timeline'
)
```

Once you're satisfied with the schedules, create them:

``` r
create_rollover_schedules(
  tag_lifespan = 400,
  time_zone = 'America/Boise',
  location_cycle = 2,
  first_deployment_date = '2020-03-23 15:00:00',
  last_deployment_date = '2020-04-15 15:00:00',
  output_location = '/Users/Jay/Desktop'
)
```

### Parse ASF XML schedules to get an idea of what the structure looks like for different schedule types

``` r
parse_asf_schedule('/Users/Jay/Desktop/R_schedules/America-Boise_2-day_rollover/2020-03-23_America-Boise_2-day_rollover.ASF')
```