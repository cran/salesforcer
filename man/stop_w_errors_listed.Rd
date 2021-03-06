% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-input-validation.R
\name{stop_w_errors_listed}
\alias{stop_w_errors_listed}
\title{List a vector of errors and stop execution}
\usage{
stop_w_errors_listed(main_text = NULL, errors = NULL)
}
\arguments{
\item{main_text}{\code{character}; The text used to introduce the list of
errors, typically ending with a colon. For example: \code{"Please fix the 
following issue(s) before proceeding:"}.}

\item{errors}{\code{errors}; a vector of errors that will be formatted into
a bulleted list for the user to review with each error listed on a new line.}
}
\value{
\code{simpleError}
}
\description{
List a vector of errors and stop execution
}
\note{
This function is meant to be used internally. Only use when debugging.
}
\keyword{internal}
