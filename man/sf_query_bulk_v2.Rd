% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bulk-query.R
\name{sf_query_bulk_v2}
\alias{sf_query_bulk_v2}
\title{Run Bulk 2.0 query}
\usage{
sf_query_bulk_v2(
  soql,
  object_name = NULL,
  queryall = FALSE,
  guess_types = TRUE,
  bind_using_character_cols = deprecated(),
  interval_seconds = 3,
  max_attempts = 200,
  control = list(...),
  ...,
  api_type = "Bulk 2.0",
  verbose = FALSE
)
}
\arguments{
\item{soql}{\code{character}; a string defining a SOQL query
(e.g. "SELECT Id, Name FROM Account").}

\item{object_name}{\code{character}; the name of the Salesforce object that the
function is operating against (e.g. "Account", "Contact", "CustomObject__c").}

\item{queryall}{\code{logical}; indicating if the query recordset should include records
that have been deleted because of a merge or delete. Setting this argument to
\code{TRUE} will also return information about archived Task and Event records.
It is available in API versions 29.0 and later.}

\item{guess_types}{\code{logical}; indicating whether or not to use \code{col_guess()}
to try and cast the data returned in the recordset. If \code{TRUE} then
\code{col_guess()} is used, if \code{FALSE} then all fields will be returned
as character. This is helpful when \code{col_guess()} will mangle field values
in Salesforce that you'd like to preserve during translation into a \code{tbl_df},
like numeric looking values that must be preserved as strings ("48.0").}

\item{bind_using_character_cols}{\code{logical}; an indicator of whether to
cast the data to all character columns to ensure that \code{\link[dplyr:bind]{bind_rows}}
does not fail because two paginated recordsets have differing datatypes for the
same column. Set this to \code{TRUE} rarely, typically only when having this
set to \code{FALSE} returns an error or you want all columns in the data to be
character.}

\item{interval_seconds}{\code{integer}; defines the seconds between attempts to check
for job completion.}

\item{max_attempts}{\code{integer}; defines then max number attempts to check for job
completion before stopping.}

\item{control}{\code{list}; a list of parameters for controlling the behavior of
the API call being used. For more information of what parameters are available
look at the documentation for \code{\link{sf_control}}.}

\item{...}{other arguments passed on to \code{\link{sf_control}} or \code{\link{sf_create_job_bulk}}
to specify the \code{content_type}, \code{concurrency_mode}, and/or \code{column_delimiter}.}

\item{api_type}{\code{character}; one of \code{"REST"}, \code{"SOAP"},
\code{"Bulk 1.0"}, or \code{"Bulk 2.0"} indicating which API to use when
making the request.}

\item{verbose}{\code{logical}; an indicator of whether to print additional
detail for each API call, which is useful for debugging. More specifically, when
set to \code{TRUE} the URL, header, and body will be printed for each request,
along with additional diagnostic information where available.}
}
\value{
A \code{tbl_df} of the recordset returned by the query
}
\description{
This function is a convenience wrapper for submitting and retrieving
query API jobs from the Bulk 2.0 API.
}
\examples{
\dontrun{
# select all Ids from Account object (up to 1000)
ids <- sf_query_bulk_v2(soql = 'SELECT Id FROM Account LIMIT 1000', 
                        object_name = 'Account')
# alternatively you can specify as 
ids <- sf_query(soql = 'SELECT Id FROM Account LIMIT 1000', 
                object_name = 'Account', 
                api_type="Bulk 2.0")
}
}
\references{
\href{https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/queries.htm}{Bulk 2.0 documentation}
}
