
#' Create 'rollover' GPS fix schedules for Lotek PinPoint transmitters
#'
#' Create a batch of 'rollover' GPS fix schedules that span many dates (say an entire field season).
#'
#' @param tag_lifespan number of days tag is expected to last according to PinPoint Host software (this depends on fix schedule)
#' @param time_zone time zone where tags will be deployed
#' @param location_cycle time (in days) between GPS fixes
#' @param first_deployment_date first datetime that tags will be used
#' @param last_deployment_date last datetime that tags will be used
#'
#' @importFrom lubridate "days"
#' @importFrom lubridate "ymd"
#' @importFrom lubridate "ymd_hms"
#' @importFrom lubridate "tz"
#' @import dplyr
#' @import stringr
#' @export
#'
#' @examples
#' create_rollover_schedule(
#' tag_lifespan = 250,
#' time_zone = 'UTC',
#' location_cycle = 2,
#' first_deployment_date = '2019-01-20 18:00:00',
#' last_deployment_date = '2019-02-15 18:00:00',
#' output_location = '/Users/Jay/Desktop'
#' )

create_rollover_schedules <- function(
  tag_lifespan,
  time_zone,
  location_cycle,
  first_deployment_date,
  last_deployment_date,
  output_location
) {

  # stop if you are living in the past
  if (first_deployment_date < Sys.Date()) stop('deployment date does not make sense!')

  rollover_interval <- str_c(location_cycle, ' days', ' ', '00:00') # take a location every X days, hours, minutes

  # create a sequence of datetimes starting January 1
  days_df <- seq(ymd_hms(first_deployment_date), ymd_hms(last_deployment_date), by = '1 days')

  # set time zone
  lubridate::tz(days_df) <- time_zone

  # turn into a data frame
  days_df <- as.data.frame(days_df)

  # create one where each vector is named by the start date
  rollover_output <- mapply(function(x, y) seq(y, y + days(tag_lifespan), by = str_c(tag_lifespan, ' ', 'days')),
                            as.character(days_df$days_df), days_df$days_df, SIMPLIFY = FALSE, USE.NAMES = TRUE)

  # Finally, name output folder (this folder must be created first for code to work properly)
  time_zone_name <- str_replace(time_zone, "/", "-")
  location_cycle_name <- str_c(location_cycle, "-day")
  rollover_output_folder <- str_c(output_location, '/R_schedules/', time_zone_name, '_', location_cycle_name, "_", "rollover", "/")
  dir.create(rollover_output_folder, recursive = TRUE)

  # First, need to strip out date only, as times mess up file naming
  names(rollover_output) <- str_sub(names(rollover_output), start = 1, end = 10)

  # Now write the file for each list and name it by start date
  for (i in names(rollover_output)) {
    sched_gps_rollover_fixes(
      rollover_interval = rollover_interval,
      date_times = rollover_output[[i]],
      tz = time_zone,
      out_file = str_c(
        rollover_output_folder,
        names(rollover_output[i]), "_", time_zone_name, "_", location_cycle_name, "_", "rollover")
    )

  }

  message("PinPoint GPS-Argos tag schedules written to:\n",
          rollover_output_folder)

}
