% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/xpssComputeStrings.R
\name{computeConcat}
\alias{computeConcat}
\title{computeConcat (x, sep = "")}
\usage{
computeConcat (x, sep = "")
}
\arguments{
\item{x}{input data.}

\item{sep}{atomic character element which splits the input data. Default is "".}
}
\value{
String. Returns a string that is the concatenation of all its arguments.
}
\description{
Helper Function for xpssCompute. R Implementation of the SPSS \code{CONCAT} Function.
}
\examples{
data(fromXPSS)
xpssCompute(x = fromXPSS, variables = c("V1","V2"), fun="computeConcat")
}
\author{
Bastian Wiessner
}
\seealso{
\code{\link{paste0}}
}
\keyword{internal}

