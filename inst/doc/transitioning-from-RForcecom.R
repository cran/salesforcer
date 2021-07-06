## ---- echo = FALSE------------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)
options(tibble.print_min = 5L, tibble.print_max = 5L)

## ----auth, eval=FALSE---------------------------------------------------------
#  library(dplyr, warn.conflicts = FALSE)
#  library(salesforcer)

## ----auth-background, include = FALSE-----------------------------------------
library(dplyr, warn.conflicts = FALSE)
library(salesforcer)

username <- Sys.getenv("SALESFORCER_USERNAME")
password <- Sys.getenv("SALESFORCER_PASSWORD")
security_token <- Sys.getenv("SALESFORCER_SECURITY_TOKEN")

sf_auth(username = username,
        password = password,
        security_token = security_token)

## ---- warning=FALSE-----------------------------------------------------------
# the RForcecom way
# RForcecom::rforcecom.login(username, paste0(password, security_token), 
#                            apiVersion=getOption("salesforcer.api_version"))
# replicated in salesforcer package
session <- salesforcer::rforcecom.login(username, 
                                         paste0(password, security_token), 
                                         apiVersion = getOption("salesforcer.api_version"))
session['sessionID'] <- "{MASKED}"
session

## ---- include=FALSE-----------------------------------------------------------
# keep using the session, just rename it to "session"
session <- salesforcer::rforcecom.login(username, 
                                        paste0(password, security_token), 
                                        apiVersion = getOption("salesforcer.api_version"))

## ---- warning=FALSE-----------------------------------------------------------
object <- "Contact"
fields <- c(FirstName="Test", LastName="Contact-Create-Compatibility")

# the RForcecom way
# RForcecom::rforcecom.create(session, objectName=object, fields)

# replicated in salesforcer package
result <- salesforcer::rforcecom.create(session, objectName=object, fields)
result

## ---- warning=FALSE-----------------------------------------------------------
n <- 2
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n))

# the RForcecom way (requires a loop)
# rforcecom_results <- NULL
# for(i in 1:nrow(new_contacts)){
#   temp <- RForcecom::rforcecom.create(session, 
#                                       objectName = "Contact", 
#                                       fields = unlist(slice(new_contacts,i)))
#   rforcecom_results <- bind_rows(rforcecom_results, temp)
# }

# the better way in salesforcer to do multiple records
salesforcer_results <- sf_create(new_contacts, object_name="Contact")
salesforcer_results

## ---- warning=FALSE-----------------------------------------------------------
this_soql <- "SELECT Id, Email FROM Contact LIMIT 5"

# the RForcecom way
# RForcecom::rforcecom.query(session, soqlQuery = this_soql)

# replicated in salesforcer package
result <- salesforcer::rforcecom.query(session, soqlQuery = this_soql)
result

# the better way in salesforcer to query
salesforcer_results <- sf_query(this_soql)
salesforcer_results

## ---- warning=FALSE-----------------------------------------------------------
# the RForcecom way
# RForcecom::rforcecom.getObjectDescription(session, objectName='Account')

# backwards compatible in the salesforcer package
result <- salesforcer::rforcecom.getObjectDescription(session, objectName='Account')

# the better way in salesforcer to get object fields
result2 <- salesforcer::sf_describe_object_fields('Account')
result2

