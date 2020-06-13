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
library(here)
library(salesforcer)
token_path <- here::here("tests", "testthat", "salesforcer_token.rds")
suppressMessages(sf_auth(token = token_path, verbose = FALSE))

## ----load-package, eval=FALSE-------------------------------------------------
#  library(dplyr)
#  library(here)
#  library(salesforcer)
#  sf_auth()

## -----------------------------------------------------------------------------
# define the ParentIds where the attachments will be shown in Salesforce
parent_record_id1 <- "0016A0000035mJ4"
parent_record_id2 <- "0016A0000035mJ5"

# provide the file paths of where the attachments exist locally on your machine
# in this case we are referencing images included within the salesforcer package, 
# but any absolute or relative path locally will work
file_path1 <- system.file("extdata", "cloud.png", package="salesforcer")
file_path2 <- system.file("extdata", "logo.png", package="salesforcer")
file_path3 <- system.file("extdata", "old-logo.png", package="salesforcer")

# create a data.frame or tbl_df out of this information
attachment_details <- tibble(Body = rep(c(file_path1, 
                                          file_path2, 
                                          file_path3), 
                                        times=2),
                             ParentId = rep(c(parent_record_id1, 
                                              parent_record_id2), 
                                            each=3))

# create the attachments!
result <- sf_create_attachment(attachment_details)
result

## -----------------------------------------------------------------------------
# pull down all attachments associated with a particular record
queried_attachments <- sf_query(sprintf("SELECT Id, Body, Name, ParentId
                                         FROM Attachment
                                         WHERE ParentId IN ('%s', '%s')", 
                                         parent_record_id1, parent_record_id2))
queried_attachments

## -----------------------------------------------------------------------------
# create a new folder for each ParentId in the dataset
temp_dir <- tempdir()
for (pid in unique(queried_attachments$ParentId)){
  dir.create(file.path(temp_dir, pid), showWarnings = FALSE) # ignore if already exists
}

# create a new columns in the queried data so that we can pass this information 
# on to the function `sf_download_attachment()` that will actually perform the download
queried_attachments <- queried_attachments %>% 
  # Strategy 1: Unique file names (ununsed here, but shown as an example)
  mutate(unique_name = paste(Id, Name, sep='___')) %>% 
  # Strategy 2: Separate folders per parent
  mutate(Path = file.path(temp_dir, ParentId))

# download all of the attachments for a single ParentId record to their own folder
download_result <- mapply(sf_download_attachment, 
                          queried_attachments$Body, 
                          queried_attachments$Name, 
                          queried_attachments$Path)
download_result

## ----cleanup-1, include = FALSE-----------------------------------------------
sf_delete(queried_attachments$Id)

## -----------------------------------------------------------------------------
# create the attachment metadata required (Name, Body, ParentId)
attachment_details <- queried_attachments %>% 
  mutate(Body = file.path(Path, Name)) %>% 
  select(Name, Body, ParentId) 

## -----------------------------------------------------------------------------
result <- sf_create_attachment(attachment_details, api_type="Bulk 1.0")
result

## ----cleanup-2, include = FALSE-----------------------------------------------
for (pid in unique(queried_attachments$ParentId)){
  unlink(file.path(temp_dir, pid), recursive=TRUE) # remove directories...
}
sf_delete(result$Id) #... and records in Salesforce

## -----------------------------------------------------------------------------
# the function supports inserting all types of blob content, just update the 
# object_name argument to add the PDF as a Document instead of an Attachment
document_details <- tibble(Name = "Data Wrangling Cheatsheet - Test 1",
                           Description = "RStudio cheatsheet covering dplyr and tidyr.",
                           Body = system.file("extdata", 
                                              "data-wrangling-cheatsheet.pdf",
                                              package="salesforcer"),
                           FolderId = "00l6A000001EgIwQAK",
                           Keywords = "test,cheatsheet,document")
result <- sf_create_attachment(document_details, object_name = "Document")
result

## ----cleanup-3, include = FALSE-----------------------------------------------
sf_delete(result$id)

## -----------------------------------------------------------------------------
cheatsheet_url <- "https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf"
document_details <- tibble(Name = "Data Wrangling Cheatsheet - Test 2",
                           Description = "RStudio cheatsheet covering dplyr and tidyr.",
                           Url = cheatsheet_url,  
                           FolderId = "00l6A000001EgIwQAK",
                           Keywords = "test,cheatsheet,document")
result <- sf_create_attachment(document_details, object_name = "Document")
result

## ----cleanup-4, include = FALSE-----------------------------------------------
sf_delete(result$id)

