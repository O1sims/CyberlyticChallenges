#' Generate data required for traffic cluster graph
#' 
#' @title Generate Cluster Graph HTTP Traffic Data
#' 
#' @description A function that takes in a data frame or `.tsv` file containing 
#'  HTTP level traffic and generates time-series data with tuples indicating where 
#'  the visitor is and the number of seconds the user remains on the webpage.
#'  
#' @details The process of data generate is as follows:
#'  (1) Load the data from the `.tsv`;
#'  
#' @return A data frame containing a tuple for each visitor.


loadTrafficData <- function(pathToData, tsv = FALSE, RData = FALSE) {
  if (tsv == FALSE && RData == FALSE) {
    return("Oops! `tsv` or `RData` must be TRUE. What type of file do you want to load?")
  } else if (RData == TRUE) {
    load(file = paste0(pathToData, "trafficData.RData"))
  } else {
    # Could use the `readr` package here, but will try without packages
    trafficData <- read.csv(file = paste0(pathToData, "trafficData.tsv"),
                            header = TRUE,
                            sep = "\t",
                            quote = "")
  }
  return(trafficData)
}


cleanRequestURLPath <- function(requestURLPath) {
  cleanRequests <- gsub(pattern = "\\?.*", 
                        replacement = "", 
                        x = requestURLPath)
  
  return(cleanRequests)
}


truncateTrafficData <- function(trafficData, cleanRequests, numberOfNodes = 9) {
  trafficTable <- as.data.frame(table(cleanRequests),
                                stringsAsFactors = FALSE)
  
  trafficTable <- trafficTable[order(-trafficTable$Freq), ][1:numberOfNodes, ]
  
  subsettedTrafficData <- subset(trafficData,
                                 trafficData$cleanURLPath %in% trafficTable$cleanRequests)
  
  return(subsettedTrafficData)
}


getNodeList <- function(cleanRequests) {
  nodes <- c(unique(cleanRequests),
             "offline")
  
  nodeList <- data.frame(nodes = nodes,
                         numbers = seq(from = 1, 
                                       to = length(nodes)),
                         stringsAsFactors = FALSE)
  
  return(nodeList)
}


getEdgeList <- function(trafficData, nodeList) {
  trafficData <- trafficData[order(trafficData$timestamp), ]
  trafficData$time <- as.double(as.POSIXct(trafficData$timestamp))
  startOfDay <- as.integer(as.POSIXct(trunc(as.POSIXct(min(trafficData$time),
                                                       origin = '1970-01-01'),
                                            units = "days")))
  
  sourceIPs <- unique(trafficData$sourceIP)
  edgeList <- list()
  for (i in 1:length(sourceIPs)) {
    sourceIPTraffic <- subset(trafficData,
                              trafficData$sourceIP == sourceIPs[i])
    for (j in 1:nrow(sourceIPTraffic)) {
      if (j == 1) {
        day <- c(nrow(nodeList),
                 round((sourceIPTraffic$time[j] - startOfDay)/60))
      } else {
        day <- c(day,
                 nodeList$number[match(x = sourceIPTraffic$cleanURLPath[j],
                                       table = nodeList$nodes)],
                 round(max((sourceIPTraffic$time[j] - sourceIPTraffic$time[j - 1])/60, 2)))
      }
    }
    edgeList[[i]] <- data.frame(day = paste(day,
                                            collapse = ","))
  }
  return(edgeList)
}


generateClusterGraphData <- function(pathToData =  "/Users/owen/Documents/CyberlyticChallenges/visualisingTraffic/data/") {
  trafficData <- loadTrafficData(pathToData = pathToData,
                                 RData = TRUE)
  
  trafficData$cleanURLPath <- cleanRequestURLPath(requestURLPath = trafficData$requestURLPath)
  
  trafficData <- truncateTrafficData(trafficData = trafficData,
                                     cleanRequests = trafficData$cleanURLPath,
                                     numberOfNodes = 9)
  
  nodeList <- getNodeList(cleanRequests = trafficData$cleanURLPath)
  
  edgeList <- getEdgeList(trafficData = trafficData,
                          nodeList = nodeList)
}