#' Splits the data.frame into pieces by a factor
#'
#' R implementation of the SPSS \code{SPLIT FILE} argument
#'
#' @usage xpssSplitFile(x, by = NULL, type = "layered", attachSplit = FALSE)
#' @param x a (non-empty) data.frame or input data of class \code{"xpssFrame"}. 
#' @param by factor variable which splits the data frame.
#' @param type character vector containing, either seperated or layered. Specifies the results from an analysis function applied on a splitted data frame. Default is \code{"layered"} design.
#' @param attachSplit logical. Indicating if the splitted data should get attached to the object as an attribute. Default is \code{"FALSE"}.
#' @return The function return the input data with modified attributes.
#' @author Bastian Wiessner
#' @seealso \code{\link{xpssDoIf}} \code{\link{xpssFilter}} \code{\link{xpssSelectIf}} \code{\link{xpssSplitFileOff}}
#' \code{\link{xpssTemporary}} 
#' @export
xpssSplitFile <- function(x, by = NULL, type = "layered", attachSplit = FALSE){
  
  ###################################################################
  ####################### Meta - Checks ##############################
  ####################################################################
  
  functiontype <- "DM"
  x <- applyMetaCheck(x)
  
  ####################################################################
  ####################################################################
  ####################################################################
    
    # Exception
    if(!is.element(type, c("seperated", "layered"))){
        stop("type has to be 'seperated' or 'layered'")
    }
    
    # The attribute is changed
    # attributes(substitute(x))$SPLIT_FILE <<- paste(type, "by", by)
    # eval(parse(text = paste0("attributes(", substitute(x),")$SPLIT_FILE <- ", paste("'",type, 'by', by,"'"))), envir = .GlobalEnv)
  
  # create by by filter
    attributes(x)$SPLIT_FILE <- c(by, type)
  
      
    # attachSplit: If TRUE, an attribute is created with the splitted data. 
    if(attachSplit == TRUE){
    attr(x,"splitted_data") <<- split(x, as.factor(eval(parse(text = paste0(as.character(substitute(x)),"$",by)))))
    # Label the elements of splitted_data-List
    names(attributes(x)$splitted_data) <- names(sort(attributes(eval(parse(text = paste0(as.character(substitute(x)),"$",by))))$value.labels))
    }
    
    print("Data split is activated")
  return(x)
}



