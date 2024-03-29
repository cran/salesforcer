% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-xml.R
\name{make_soap_xml_skeleton}
\alias{make_soap_xml_skeleton}
\title{Make SOAP XML Request Skeleton}
\usage{
make_soap_xml_skeleton(soap_headers = list(), metadata_ns = FALSE)
}
\arguments{
\item{soap_headers}{\code{list}; any number of SOAP headers}

\item{metadata_ns}{\code{logical}; an indicator of whether to use the namespaces
required by the Metadata API or the default ones.}
}
\value{
\code{xmlNode}; an XML object containing just the header portion of the
request
}
\description{
Create XML in preparation for sending to the SOAP API
}
\note{
This function is meant to be used internally. Only use when debugging.
Any of the following SOAP headers are allowed:
\itemize{
\item AllOrNoneHeader
\item AllowFieldTruncationHeader
\item AssignmentRuleHeader
\item CallOptions
\item DisableFeedTrackingHeader
\item EmailHeader
\item LimitInfoHeader
\item LocaleOptions
\item LoginScopeHeader
\item MruHeader
\item OwnerChangeOptions
\item PackageVersionHeader
\item QueryOptions
\item UserTerritoryDeleteHeader
}
Additionally, Bulk API can't access or query compound address or compound geolocation fields.
}
\references{
\url{https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/soap_headers.htm}

\url{https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch}
}
\keyword{internal}
