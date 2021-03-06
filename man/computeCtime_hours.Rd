% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/xpssComputeDates.R
\name{computeCtime_hours}
\alias{computeCtime_hours}
\title{Calculates the difference between two dates in hours}
\usage{
computeCtime_hours(x,date)
}
\arguments{
\item{x}{atomic object of class \code{character, POSIXlt  or  POSIXt} holding date data}

\item{date}{atomic object of class \code{character, POSIXlt  or  POSIXt} holding date data}
}
\value{
Returns the difference between date and x in hours.
}
\description{
R Implementation of the SPSS \code{CTIME.HOURS} Function. \code{computeCtime_hours} is a helper function for xpssCompute.
}
\details{
The input format of date's with timeparameter's is YYYY-MM-DD HH:MM:SS. All parameters are necessary to calculate the hour difference!
}
\examples{
# Time difference of 2 hours
xpssCompute(x="2013-09-14 12:12:12", fun="computeCtime_hours", date="2013-09-14 10:10:10")
# Time difference of 182 hours
xpssCompute(x="2013-09-14 12:12:12", fun="computeCtime_hours", date="2013-09-06 22:10:10")
}
\author{
Bastian Wiessner
}
\seealso{
\code{\link{difftime}} \code{\link{DateTimeClasses}} \code{\link{as.POSIXlt}} \code{\link{strptime}}
}
\keyword{internal}

