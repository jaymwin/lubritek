
#' Create GPS fix schedules to test Lotek PinPoint transmitters
#'
#' Create a set of schedules to test Lotek PinPoint tags prior to deployment. By default, function
#' applies recommended fix schedules recommended by Lotek.
#'
#' @param test_period amount of time (hours) to test individual tags (12 is default as recommended by Lotek)
#' @param time_zone time zone where tags will be tested
#' @param stagger_time difference in time between tags for when they record fixes ('5 min' as recommended by Lotek)
#' @param fix_interval time between GPS fixes (default is '1 hour' as recommended by Lotek)
#' @param start_datetime datetime when tags will be first tested
#' @param transmitter_list list of transmitter IDs to be tested
#' @param output_location file path where GPS schedules will be saved
#'
#' @importFrom lubridate "days"
#' @importFrom lubridate "ymd"
#' @importFrom lubridate "ymd_hms"
#' @importFrom lubridate "minutes"
#' @importFrom lubridate "tz"
#' @importFrom lubridate "hours"
#' @import dplyr
#' @import stringr
#' @export
#'
#' @examples
#' create_testing_schedules(
#' test_period = 12,
#' time_zone = 'America/Boise',
#' stagger_time = '5 min',
#' fix_interval = '1 hour',
#' start_datetime = '2018-12-20 12:00:00',
#' transmitter_list = c('1745021', '1745026'),
#' output_location = '/Users/Jay/Desktop/'
#' )

create_testing_schedules <- function(
  test_period = 12, # how many hours will a transmitter be tested for (lotek recommends)
  time_zone, # time zone you want to test the tags in
  stagger_time = '5 min', # interval to stagger the starting time for different Lotek units
  fix_interval = '1 hour', # recommended fix interval from Lotek
  start_datetime, # what time you want to start testing
  transmitter_list, # tag IDs for units to be tested,
  output_location
) {

  if (start_datetime < Sys.Date()) stop('testing date does not make sense!')

  tags <- length(transmitter_list) + 1

  stagger_minutes <- as.numeric(str_sub(stagger_time, start = 1, end = 1))

  end_datetime <- ymd_hms(start_datetime) + minutes(tags*stagger_minutes)

  # create a sequence of datetimes starting on the test date, stagger them by 5 minutes
  days_df <- seq(
    ymd_hms(start_datetime), ymd_hms(end_datetime),
    by = stagger_time
  )

  # set time zone
  lubridate::tz(days_df) <- time_zone

  # turn into a data frame
  days_df <- as.data.frame(days_df)

  # create one where each vector is named by the start date
  test_output <- mapply(function(x, y) seq(y, y + hours(test_period), by = fix_interval), # 12 hours from start time every hour
                   as.character(days_df$days_df), days_df$days_df, SIMPLIFY = FALSE, USE.NAMES = TRUE)

  # how many tags are being tested?
  num_tags <- length(transmitter_list)

  # First, need to strip out date only, as times mess up file naming
  names(test_output) <- str_sub(names(test_output), start = 1, end = 10)
  names(test_output) <- str_c(names(test_output), "_", transmitter_list[1:num_tags])

  schedule_type <- "test_schedules" # for naming purposes later

  # Finally, name output folder
  time_zone_name <- str_replace(time_zone, "/", "-")
  test_output_folder = str_c(output_location, '/R_schedules/', time_zone_name, '_', schedule_type, '/')
  dir.create(test_output_folder, recursive = TRUE)

  # Now write the file for each list and name it by start date
  for (i in names(test_output)) {
    sched_gps_testing_fixes(
      date_times = test_output[[i]],
      tz = time_zone,
      out_file = str_c(test_output_folder, names(test_output[i]), "_", "test")
    )

  }

  message("PinPoint GPS-Argos tag schedules written to:\n",
          test_output_folder)

}
