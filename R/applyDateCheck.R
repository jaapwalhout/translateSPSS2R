#' Apply Date Checks
#'
#' Checks the date format for inputdata
#'
#' Helper Function for Merging Attributedatasets
#' 
#' @param x a (non-empty) date of class \code{"xpssDate"}. 
#' @return xpssDateformat
#' @author Bastian Wiessner
#' @keywords internal
#' @export

applyDateCheck <- function(x) {
  temp <- x
  # check if the class is supported
  if(("xpssDate" %in% class(x)) ==F) {
    # replace all irregular expressions
    x <- gsub(pattern="[.\\/]",replacement="-",x=x)
    # convert in a valid dateformat
    x <- as.Date(x,format="%d-%m-%Y")
    if(is.element(NA,x)){
      x <- temp
      stop("date string is not in an unambiguous format \n  use format(x, '%d-%b-%Y') or  format(x, '%d-%m-%Y')",call.=F)
    } else {
      # format to xpssDate
      x <- format(x, "%d-%b-%Y")
      message("actual data got coerced to a xpssDate Format")
      class(x) <- "xpssDate"  
    }
  }
  return(x)
}