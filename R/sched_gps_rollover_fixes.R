
#' Schedule rollover GPS fixes
#'
#' This function generates a **rollover** GPS fix schedule for Lotek PinPoint
#' tags in the appropriate .ASF XML format.  The resulting file can then be loaded
#' to the tag via the PinPoint Host software (see that manual for details on
#' scheduling).
#'
#' @param date_times either character or POSIXct vector of date times for which
#' to schedule an attempted GPS fix
#' @param tz character string indicating the \code{\link[base]{timezone}} of *input*
#' datetimes. These will be converted to GMT as required by the PinPoint tags.
#' @param out_file character path to output XML file containing the discrete rule
#' schedule. The .ASF extension need not be specified.
#' @return writes an XML file (*.ASF extension) that can be loaded to a PinPoint tag
#' via the PinPoint Hose software from Lotek
#'
#' @import tools
#' @importFrom lubridate "with_tz"
#' @import stringr
#' @export
#'

sched_gps_rollover_fixes <- function(
  rollover_interval,
  date_times,
  tz = "GMT",
  out_file = NULL) {

  if (tz != "GMT") {

    with_tz(date_times, 'GMT') # convert schedules to GMT here

  }

  date_times <- sort(date_times)
  uniq_dates <- str_sub(date_times, start = 1, end = 19) %>% unique()

  rules <-

    c("\t<rule>",
      "\t\t<type>Rollover</type>",
      str_c("\t\t<firstdatetime>", uniq_dates[1], "</firstdatetime>"),
      str_c("\t\t<lastdatetime>", uniq_dates[2], "</lastdatetime>"),
      str_c("\t\t<frequency>", rollover_interval, "</frequency>"),
      "\t</rule>"
    )

  schedule_st <- c(str_c("<?xml version=\"1.0\" encoding=\"utf-8\"?>"),
                   "<schedule>")
  schedule_end <- "</schedule>"

  out <- c(schedule_st, unlist(rules), schedule_end)

  if (file_ext(out_file) != "ASF") out_file <- str_c(out_file, ".ASF")

  conn <- file(out_file)
  writeLines(out, conn)
  close(conn)
  invisible()

}
