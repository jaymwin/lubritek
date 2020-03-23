
#' Look up time zones when creating GPS schedules
#'
#' View a list of time zones that can be used with `lubridate` functionality
#'
#' @param region area where Lotek PinPoint tags will be deployed (e.g., country or UTC zone)
#'
#' @return list of time zones for a particular region
#' @export
#'
#' @examples
#' view_time_zones(region = 'America')

view_time_zones <- function(region) {

  zones <- grep(region, OlsonNames(), value = T) # change for Canada or other countries
  return(zones)

}

