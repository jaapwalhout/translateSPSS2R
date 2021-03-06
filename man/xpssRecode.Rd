% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/xpssRecode.R
\name{xpssRecode}
\alias{xpssRecode}
\title{Recodes variables}
\usage{
xpssRecode(x, variables, rec = NULL, varout = NULL)
}
\arguments{
\item{x}{a (non-empty) data.frame or input data of class "xpssFrame".}

\item{variables}{atomic character or character vector with the names of the variabless to recode.}

\item{rec}{character string with recoding specifications: for more informations see details.}

\item{varout}{atomic character or character vector with the names of new variables.}
}
\value{
A xpssFrame with the recoded variables.
}
\description{
R implementation of the SPSS \code{RECODE} Function. xpssRecode recodes atomics or vectors of the format numeric, character or factor under the terms of recode specifications.
}
\details{
The input of the recoding is a character string with the recoding procedure seperated with a semicolon and a optional else statement.
\describe{
   \item{\code{single data transformation}:}{ \code{rec = "1 = 99; else = test"}}
   \item{\code{For a numeric vector transformation}:}{\code{rec = "c(1,2,3) = 1; else = 11"}}
   \item{\code{For a character vector transformation}:}{\code{rec = "c('A','B') = 'AB'; c('C','D') = 'CD'; else = 'ZZ'"}}
   \item{\code{For a range of values}:}{\code{rec = "lo:10 = 1; 11:22 = 2; 23:hi = 3; else = 'copy'"}.}
 }
 \strong{NOTE:} \code{lo} and  \code{hi} are special values and determine the lowest and highest value of a numeric variable. \cr
The \code{":"}-Operator differs in this context from the sequence operator. In xpssRecode it specifies the range from A to B.
F.e. 1:10 defines the range from 1 till 10, all values which are within this range get recoded. \cr \cr

The \code{else} statement indicates the handling of the values which are not selected by the recoding statement, this statement matches all unspecified values, including missing values. \cr
System default, if no else statement is given, is \code{else='copy'}.

\tabular{rlll}{

\tab \code{else='copy'} \tab overwrites all unmatched values with the original value. \cr
\tab \code{else='NA'} \tab overwrites all unmatched values in the new dataset with \code{NA}.\cr
\tab \code{else='Other'} \tab overwrites all unmatched values with Other, \strong{only} possible for character values. \cr
\tab \code{else=99} \tab overwrites all unmatched values with 99, \strong{only} possible for numeric values.}

\code{varout} determines whether a new variable with the recoded values should appended at the end of the dataset.
}
\examples{
# load data
data(fromXPSS)
# recode in variable V1 Audi to Porsche, copy all unmatches values
fromXPSS <- xpssRecode(fromXPSS,
           variables ="V1",
           rec="'Audi' = 'Porsche'; else= copy",
           varout = NULL)

# recode variable V5 and V7_2 in 3 clases.
# Lowest value until 50 as 1, 51 until 200 as 2, 201 until as 3, other values get copied.
# save the recoded variables in V5_new and V7_new
fromXPSS <- xpssRecode(fromXPSS,
                   variables = c("V5","V7_2"),
                   rec = "lo:50 =1; 51:200=2; 201:hi=3; else = copy",
                   varout =c("V5_new","V7_new"))

# recode all systemmissings in variable V6_kl3 and V7_2 as -99
fromXPSS <- xpssRecode(fromXPSS,
                   variables = c("V6_kl3","V7_2"),
                   rec = "sysmis = 99",
                   varout =c("V6_new","V7_new"))
}
\author{
Andreas Wygrabek
}

