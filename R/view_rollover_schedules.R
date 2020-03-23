
#' View rollover GPS schedules
#'
#' Before creating schedules, ensure that Lotek PinPoint tags will record data at the proper times
#' by viewing fix schedule in a ggplot calendar or timeline
#'
#' @param tag_lifespan number of days tag is expected to last (provided by Lotek PinPoint Host software)
#' @param time_zone time zone where tags will be deployed
#' @param location_cycle time between fixes (in days)
#' @param first_deployment_date datetime when tags will first be deployed
#' @param last_deployment_date datetime last tags will be deployed
#'
#' @importFrom lubridate "days"
#' @importFrom lubridate "ymd"
#' @importFrom lubridate "ymd_hms"
#' @importFrom lubridate "year"
#' @importFrom lubridate "tz"
#' @import dplyr
#' @import stringr
#' @import tidyr
#' @import ggplot2
#' @importFrom glue "glue"
#'
#' @examples
#' view_rollover_schedules(
#' tag_lifespan = 250,
#' time_zone = 'UTC',
#' location_cycle = 2,
#' first_deployment_date = '2020-04-20 18:00:00',
#' last_deployment_date = '2020-05-15 18:00:00',
#' type = 'calendar'
#' )

view_rollover_schedules <- function(
  tag_lifespan,
  time_zone,
  location_cycle,
  first_deployment_date,
  last_deployment_date,
  type
) {

  rollover_interval <- str_c(location_cycle, ' days', ' ', '00:00') # take a location every X days, hours, minutes

  if (type == 'calendar') {

    first_year <- year(first_deployment_date)

    df <- tibble(
      date = seq(ymd(str_c(first_year, '-01-01')), as.Date(first_deployment_date) + days(tag_lifespan), by = '1 days'),
      year = format(date, "%Y"),
      week = as.integer(format(date, "%W")) + 1,  # Week starts at 1
      day = factor(weekdays(date, T),
                   levels = rev(c("Mon", "Tue", "Wed", "Thu",
                                  "Fri", "Sat", "Sun")))
    )

    fixes <- tibble(
      date = as.Date(seq(ymd_hms(first_deployment_date), ymd_hms(first_deployment_date) + days(tag_lifespan), by = str_c(location_cycle, ' days'))),
      fix = TRUE
    )

    df <- df %>%
      left_join(., fixes, by = 'date')

    ggplot(df, aes(x = week, y = day, fill = fix)) +
      scale_fill_manual(name="",
                        na.value = 'grey93',
                        values = c('salmon')) +
      geom_tile(color = "white", size = 0.4) +
      facet_wrap("year", ncol = 1) +
      scale_x_continuous(
        expand = c(0, 0),
        breaks = seq(1, 52, length = 12),
        labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
      theme_bw() +
      theme(axis.title = element_blank(),
            axis.ticks = element_blank(),
            panel.grid = element_blank(),
            panel.border = element_blank(),
            strip.background = element_blank(),
            legend.position = "bottom",
            legend.key.width = unit(1, "cm"),
            strip.text = element_text(hjust = 0.01, face = "bold", size = 12)) +
      guides(fill = FALSE) +
      ggtitle(glue('Schedule for tag deployed on first day;\nGPS fixes taken every {rollover_interval}.'))

  } else if (type == 'timeline') {

    # create a sequence of datetimes starting January 1
    days_df <- seq(ymd_hms(first_deployment_date), ymd_hms(last_deployment_date), by = '1 days')

    # set time zone
    lubridate::tz(days_df) <- time_zone

    # turn into a data frame
    days_df <- as.data.frame(days_df)

    # create one where each vector is named by the start date
    rollover_output <- mapply(function(x, y) seq(y, y + days(tag_lifespan), by = str_c(tag_lifespan, ' ', 'days')),
                              as.character(days_df$days_df), days_df$days_df, SIMPLIFY = FALSE, USE.NAMES = TRUE)

    # return(rollover_output)
    rollover_output_start <- rollover_output %>%
      as_tibble() %>%
      gather(variable, value) %>%
      group_by(variable) %>%
      slice(1) %>%
      rename(start = value)

    rollover_output_end <- rollover_output %>%
      as_tibble() %>%
      gather(variable, value) %>%
      group_by(variable) %>%
      slice(2) %>%
      rename(end = value)

    rollover_output_df <- rollover_output_start %>%
      left_join(., rollover_output_end, by = 'variable') %>%
      ungroup()

    rollover_output_df %>%
      ggplot() +
      geom_segment(aes(y = variable, yend = variable, x = start, xend = end)) +
      geom_point(aes(y = variable, x = start), color = 'blue') +
      geom_point(aes(y = variable, x = end), color = 'red') +
      labs(
        x = 'Date',
        y = 'GPS schedule'
      ) +
      ggtitle(glue('GPS fixes taken every {rollover_interval}.')) +
      scale_x_datetime(date_labels = "%d %b %Y") +
      theme_bw() +
      theme(axis.text.y = element_blank())

  }

}
