## ---- echo = FALSE------------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----auth, include = FALSE----------------------------------------------------
suppressWarnings(suppressMessages(library(dplyr)))
library(salesforcer)
token_path <- here::here("tests", "testthat", "salesforcer_token.rds")
suppressMessages(sf_auth(token = token_path, verbose = FALSE))

## ----load-package, eval=FALSE-------------------------------------------------
#  suppressWarnings(suppressMessages(library(dplyr)))
#  library(salesforcer)
#  sf_auth()

## -----------------------------------------------------------------------------
n <- 2
prefix <- paste0("Bulk-", as.integer(runif(1,1,100000)), "-")
new_contacts1 <- tibble(FirstName = rep("Test", n),
                        LastName = paste0("Contact-Create-", 1:n),
                        My_External_Id__c=paste0(prefix, letters[1:n]))
new_contacts2 <- tibble(FirstName = rep("Test", n),
                        LastName = paste0("Contact-Create-", 1:n),
                        My_External_Id__c=paste0(prefix, letters[1:n]))

## -----------------------------------------------------------------------------
# REST
rest_created_records <- sf_create(new_contacts1, object_name="Contact", api_type="REST")
rest_created_records

# Bulk
bulk_created_records <- sf_create(new_contacts2, object_name="Contact", api_type="Bulk 1.0")
bulk_created_records

## ---- include=FALSE-----------------------------------------------------------
n <- 2
prefix <- paste0("Bulk-", as.integer(runif(1,1,100000)), "-")
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n),
                       My_External_Id__c=paste0(prefix, letters[1:n]))

## -----------------------------------------------------------------------------
object <- "Contact"
created_records <- sf_create(new_contacts, object_name=object, api_type="Bulk 1.0")
created_records

# query bulk
my_soql <- sprintf("SELECT Id,
                           FirstName, 
                           LastName
                    FROM Contact 
                    WHERE Id in ('%s')", 
                   paste0(created_records$Id , collapse="','"))

queried_records <- sf_query(my_soql, object_name=object, api_type="Bulk 1.0")
queried_records

# delete bulk
deleted_records <- sf_delete(queried_records$Id, object_name=object, api_type="Bulk 1.0")
deleted_records

## ---- include=FALSE-----------------------------------------------------------
n <- 10
prefix <- paste0("Bulk-", as.integer(runif(1,1,100000)), "-")
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n),
                       test_number__c = 1:10,
                       My_External_Id__c=paste0(prefix, letters[1:n]))

## ---- eval=FALSE--------------------------------------------------------------
#  n <- 10
#  new_contacts <- tibble(FirstName = rep("Test", n),
#                         LastName = paste0("Contact-Create-", 1:n),
#                         test_number__c = 1:10)

## -----------------------------------------------------------------------------
created_records_v1 <- sf_create(new_contacts, "Contact", api_type="Bulk 1.0", batch_size=2)
created_records_v1

# query the records so we can compare the ordering of the Id field to the 
# original dataset
my_soql <- sprintf("SELECT Id,
                           test_number__c
                    FROM Contact 
                    WHERE Id in ('%s')", 
                   paste0(created_records_v1$Id , collapse="','"))
queried_records <- sf_query(my_soql)
queried_records <- queried_records %>% 
  arrange(test_number__c)

# same ordering of rows!
cbind(created_records_v1 %>% select(Id), queried_records)

## ---- include=FALSE-----------------------------------------------------------
n <- 10
prefix <- paste0("Bulk-", as.integer(runif(1,1,100000)), "-")
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n),
                       test_number__c = 1:10,
                       My_External_Id__c=paste0(prefix, letters[1:n]))
created_records_v2 <- sf_create(new_contacts, "Contact", api_type="Bulk 2.0")
created_records_v2 <- created_records_v2 %>% 
  select(-My_External_Id__c)

## ---- eval=FALSE--------------------------------------------------------------
#  created_records_v2 <- sf_create(new_contacts, "Contact", api_type="Bulk 2.0", batch_size=2)

## -----------------------------------------------------------------------------
created_records_v2

## -----------------------------------------------------------------------------
sf_delete(c(created_records_v1$Id, created_records_v2$sf__Id), 
          object_name = "Contact", api_type="Bulk 2.0")

