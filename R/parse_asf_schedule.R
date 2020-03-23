
#' Read GPS schedule and parse ASF XML file structure
#'
#' Examine the structure of an ASF file used to program GPS fix schedules for Lotek PinPoint tags
#'
#' @param file path to ASF file generated using PinPoint Host software or this package
#'
#' @importFrom XML "xmlParse"
#' @export
#'
#' @examples
#' parse_as_schedule('.../2019-01-20_UTC_2-day_rollover.ASF')

parse_asf_schedule <- function(file) {

  xmlParse(file)

}
