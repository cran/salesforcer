% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analytics-report-folder.R
\name{sf_report_folder_share_recipients}
\alias{sf_report_folder_share_recipients}
\title{Get report folder share recipients}
\usage{
sf_report_folder_share_recipients(
  report_folder_id,
  share_type = c("User", "Group", "Role"),
  search_term = "",
  limit = 100
)
}
\arguments{
\item{report_folder_id}{\code{character}; the Salesforce Id assigned to a created
analytics folder (it will start with "00l").}

\item{share_type}{\code{character}; Return data for the recipients of the
specified type, such as "User", "Group", or "Role".}

\item{search_term}{\code{character}; Search to match share recipients' names.
Default is "" (no restriction).}

\item{limit}{\code{integer}; Limit to the number of search results. Default is 100.}
}
\value{
\code{list}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
