#' Read Object or Field Metadata from Salesforce
#' 
#' @description
#' `r lifecycle::badge("experimental")`
#' 
#' This function takes a request of named elements in Salesforce and 
#' returns their metadata
#'
#' @importFrom XML newXMLNode addChildren xmlParse xmlToList
#' @importFrom httr content 
#' @importFrom xml2 xml_ns_strip xml_find_all
#' @importFrom purrr map
#' @references \url{https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta}
#' @template metadata_type
#' @param object_names a character vector of names that we wish to read metadata for
#' @template verbose
#' @return A \code{list} containing a response for each requested object
#' @examples
#' \dontrun{
#' metadata_info <- sf_read_metadata(metadata_type='CustomObject', 
#'                                   object_names=c('Account'))
#' }
#' @export
sf_read_metadata <- function(metadata_type, object_names, verbose=FALSE){
    
  stopifnot(all(is.character(object_names)))
  stopifnot(metadata_type %in% names(valid_metadata_list()))

  # format names into list
  object_list <- as.list(object_names)
  names(object_list) <- rep('fullNames', length(object_list))

  which_operation <- "readMetadata"
  # define the operation
  operation_node <- newXMLNode(which_operation,
                               namespaceDefinitions=c('http://soap.sforce.com/2006/04/metadata'), 
                               suppressNamespaceWarning = TRUE)
  type_node <- newXMLNode("type", metadata_type, parent=operation_node)
  # and add the metadata to it
  xml_dat <- build_metadata_xml_from_list(input_data=object_list, metatype=NULL, root=operation_node)
  
  base_metadata_url <- make_base_metadata_url()
  root <- make_soap_xml_skeleton(metadata_ns=TRUE)
  body_node <- newXMLNode("soapenv:Body", parent=root)  
  body_node <- addChildren(body_node, xml_dat)
  
  request_body <- as(root, "character")
  httr_response <- rPOST(url = base_metadata_url,
                         headers = c("SOAPAction"=which_operation,
                                     "Content-Type"="text/xml"),
                         body = request_body)
  if(verbose){
    make_verbose_httr_message(httr_response$request$method, 
                              httr_response$request$url, 
                              httr_response$request$headers,
                              request_body)
  }
  catch_errors(httr_response)
  response_parsed <- content(httr_response, encoding="UTF-8")
  invisible(capture.output(
    # capture any xmlToList grumblings about Namespace prefix
    resultset <- response_parsed %>%
    xml_ns_strip() %>%
    xml_find_all('.//records') %>%
    # we must use XML because character elements are not automatically unboxed
    # see https://github.com/r-lib/xml2/issues/215
    map(.f=function(x){
      xmlToList(xmlParse(as(object=x, Class="character")))
    })
  ))
    
  return(resultset)
}

#' Describe Object Fields
#' 
#' @description
#' `r lifecycle::badge("stable")`
#' 
#' This function takes the name of an object in Salesforce and returns a description 
#' of the fields on that object by returning a tibble with one row per field.
#' 
#' @importFrom dplyr select
#' @importFrom purrr map modify_at
#' @template object_name
#' @note The tibble only contains the fields that the user can view, as defined by 
#' the user's field-level security settings.
#' @return A \code{tbl_df} containing one row per field for the requested object.
#' @examples
#' \dontrun{
#' acct_fields <- sf_describe_object_fields('Account')
#' }
#' @export
sf_describe_object_fields <- function(object_name){
  
  stopifnot(length(object_name) == 1)
  
  obj_dat <- sf_describe_objects(object_names = object_name, api_type = "SOAP")[[1]]
  obj_fields_dat <- obj_dat[names(obj_dat) == "fields"] %>% 
    # explicitly combine duplicated names because many tidyverse functions 
    # break whenever that occurs
    map(collapse_list_with_dupe_names) %>% 
    map(set_null_elements_to_na)
  
  # check if all values are the same class (excluding NA)
  obj_fields_dat_classes <- obj_fields_dat %>% 
    map(~map(.x, class)) %>% 
    safe_bind_rows()
  
  classes_summary <- obj_fields_dat_classes %>% map_lgl(~length(unique(na.omit(.x))) > 1)
  if(any(classes_summary)){
    cols_to_fix <- names(classes_summary)[which(classes_summary)]
    obj_fields_dat <- obj_fields_dat %>% 
      map(~modify_at(.x, cols_to_fix, list))
  }
  
  # check if all values are of length 1, if not then cast as list if not already a list
  obj_fields_dat_lengths <- obj_fields_dat %>% 
    map(~map(.x, length)) %>% 
    safe_bind_rows()
  
  lengths_summary <- obj_fields_dat_lengths %>% map_lgl(~any(.x > 1, na.rm=TRUE))
  if(any(lengths_summary)){
    cols_to_fix <- names(lengths_summary)[which(lengths_summary)]
    obj_fields_dat <- obj_fields_dat %>% 
      map(~modify_at(.x, cols_to_fix, list))
  }  
  
  obj_fields_dat <- obj_fields_dat %>% 
    safe_bind_rows() %>% 
    # sort column names as the API would return prior to the combining process above
    select(sort(names(.)))
  
  return(obj_fields_dat)
}

#' Collapse Elements in List with Same Name
#' 
#' This function looks for instances of elements in a list that have the same name 
#' and then combine them all into a single comma separated character string 
#' (referenceTo) or \code{tbl_df} (picklistValues).
#' 
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
#' @importFrom utils head tail
#' @param x list; a list, typically returned from the API that we would parse through
#' @note The tibble only contains the fields that the user can view, as defined by 
#' the user's field-level security settings.
#' @return A \code{list} containing one row per field for the requested object.
#' @examples \dontrun{
#' obj_dat <- sf_describe_objects(object_names = "Contact", api_type = "SOAP")[[1]]
#' obj_fields_list <- obj_dat[names(obj_dat) == "fields"] %>% 
#'   map(collapse_list_with_dupe_names)
#' }
#' @export
collapse_list_with_dupe_names <- function(x){
  dupes_exist <- any(duplicated(names(x)))
  if(dupes_exist){
    dupe_field_names <- unique(names(x)[duplicated(names(x))])
    for(f in dupe_field_names){
      target_idx <- which(names(x) == f)
      obj_field_dupes <- x[target_idx]
      if(all(sapply(obj_field_dupes, length) == 1)){
        collapsed <- list(unname(unlist(obj_field_dupes)))
      } else {
        collapsed <- obj_field_dupes %>% 
          map(set_null_elements_to_na) %>% 
          safe_bind_rows() %>%
          list()
      }
      # replace into first
      x[head(target_idx, 1)] <- collapsed
      # remove the rest
      x[tail(target_idx, -1)] <- NULL 
    }
  }
  return(x)
}
