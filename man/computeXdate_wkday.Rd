% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/xpssComputeDates.R
\name{computeXdate_wkday}
\alias{computeXdate_wkday}
\title{Calcualtes the day of week on basis of a given date}
\usage{
computeXdate_wkday(x=NULL)
}
\arguments{
\item{x}{atomic object of class \code{character, POSIXlt  or  POSIXt} holding date data.}
}
\value{
Returns a character string with the day of week.
}
\description{
R Implementation of the SPSS \code{XDATE.WEEK} Function. \code{computeXdate_wkday} is a helper function for xpssCompute.
}
\details{
computeXdate_wkday caluclates the calendar week on basis of the given date string. Result is a number between 0 and 6. 0 stands for Sunday, 6 for Saturday.
}
\examples{
# 0
xpssCompute(x="2015-02-15 20:11:20", fun="computeXdate_wkday")
# 4
xpssCompute(x="2022-10-20 21:22:12", fun="computeXdate_wkday")
}
\author{
Bastian Wiessner
}
\seealso{
\code{\link{computeXdate_date}} \code{\link{computeXdate_wkday}} \code{\link{computeXdate_year}}
}
\keyword{internal}

