workingDir <- "/home/owen/Desktop/CyberlyticChallenges/dataScience/"

# Install and load packages

packages <- c("urltools", "ggplot2", "igraph")
newPackages <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(newPackages) > 0) {
  install.packages(newPackages,
                   repos = "https://cloud.r-project.org/",
                   dependencies = TRUE)
}
lapply(packages, library, c = TRUE)

# Initiate SQL detection engine (libinjection)

dyn.load(paste0(workingDir, "libInjection/libinjection_sqli"),
         now = TRUE)

# Load up the traffic data

load(file = paste0(workingDir, "data/trafficData.rda"))

## Q1 : Present summary statistics
# Some graphs on traffic and IPs

trafficHist <- ggplot2::ggplot(trafficData,
                               aes(x = as.POSIXct(trafficData$timestamp))) +
  geom_histogram(binwidth = 10) +
  labs(title = "Traffic histogram",
       x = "Time",
       y = "Frequency")
sourceIPs <- as.data.frame(table(trafficData$sourceIP),
                           stringsAsFactors = TRUE)
trafficIPs <- ggplot2::ggplot(data = sourceIPs,
                              mapping = aes(x = sourceIPs$Var1,
                                            y = log(sourceIPs$Freq))) +
  geom_point(size = 4,
             shape = 19,
             aes(colour = sourceIPs$Var1)) +
  labs(title = "Quantity of traffic from each IP",
       x = "Source IPs",
       y = "log(Frequency)") +
  theme(axis.text.x = element_text(angle = 45),
        legend.position = 'none')
ggplot2::ggsave(filename = paste0(workingDir, "images/trafficHist.png"),
                plot = trafficHist)
ggplot2::ggsave(filename = paste0(workingDir, "images/trafficIPs.png"),
                plot = trafficIPs)

# Summary statistics

noIPs <- length(unique(trafficData$sourceIP))
statDesc <- c("No. of unique IPs", "Avg no. of requests", "Max no. of requests", "Max IP", "Min no. of requests", "Std Dev of requests")
stats <- c(noIPs, mean(sourceIPs$Freq), max(sourceIPs$Freq), as.character(sourceIPs$Var1[match(max(sourceIPs$Freq), sourceIPs$Freq)]), min(sourceIPs$Freq), sd(sourceIPs$Freq))
requestStats <- data.frame(Description = statDesc,
                           Stats = stats,
                           stringsAsFactors = FALSE)
print(requestStats)

## Q2 : Are there any malicious activities?
# Crude identification of maicious traffic

trafficData$parameter <- urltools::url_parse(url_decode(trafficData$requestURLPath))$parameter
isSQLi <- sapply(1:nrow(trafficData), function(x) {
  .C("libinjection_sqli",
     s = as.character(trafficData$parameter[x]),
     slen = as.integer(nchar(as.character(trafficData$parameter[x]))),
     b = as.integer(9),
     fin0 = as.character(""),
     fin1 = as.character(""),
     fin2 = as.character(""),
     fin3 = as.character(""),
     fin4 = as.character(""))$b})
maliciousTraffic <- subset(trafficData,
                           isSQLi == 1)

# Parse out malicious traffic that is interesting to us

SQLMapData <- trafficData[agrep(pattern = "sqlmap",
                                x = trafficData$`requestHeaders.User-Agent`), ]
wGetData <- trafficData[agrep(pattern = "wget",
                              x = trafficData$`requestHeaders.User-Agent`), ]
maliciousIPs <- unique(c(unique(SQLMapData$sourceIP),
                         unique(wGetData$sourceIP)))
noMaliciousIPs <- length(maliciousIPs)

## Q3 : Representing as a directed graph
# Graph mining

trafficData$URLs <- trafficData$requestURLPath
patterns <- c("/bhratach/", "/bhratach", "bhratach/", "\\?.*")
for (i in 1:length(patterns)) {
  trafficData$URLs <- gsub(pattern = patterns[i],
                           replacement = "",
                           x = trafficData$URLs)
}
nodes <- unique(trafficData$URLs) # Nodes in the graph are files in the website
for (i in 1:length(IPs)) {
  flow <- subset(trafficData$URLs,
                 trafficData$sourceIP == IPs[i])
  flowTime <- subset(trafficData$timestamp,
                     trafficData$sourceIP == IPs[i])
  from <- flow[1:(length(flow) - 1)]
  to <- flow[2:length(flow)]
  edgeList <- data.frame(from = from,
                         to = to,
                         stringsAsFactors = FALSE)
  if (i == 1) {
    edgeListFull <- edgeList
  } else {
    edgeListFull <- rbind(edgeListFull,
                          edgeList)
  }
  together <- paste0(edgeList$from, edgeList$to)
  for (j in 1:nrow(edgeList)) {
    if (j == 1) {
      weight <- sum(together == together[j])
    } else {
      weight[j] <- sum(together == together[j])
    }
  }
  edgeList$weight <- weight
  edgeList <- unique(edgeList[,])
  for (j in nrow(edgeList):1) {
    if (edgeList$from[j] == edgeList$to[j]) {
      edgeList <- edgeList[-c(j), ]
    }
  }
  net <- graph_from_data_frame(d = edgeList,
                               vertices = nodes,
                               directed = TRUE)
  jpeg(file = paste0(workingDir, "images/graphMining/images/graphPlots/graph-", i, ".jpeg"))
  plot(net,
       vertex.color = "#C5E1A5",
       vertex.frame.color = "#FFFFFF",
       vertex.label.color = "black",
       vertex.label.dist = 0.5,
       edge.arrow.size = 0.5,
       edge.width = edgeList$weight)
  title(main = paste0("Flow graph of IP ", IPs[i]),
        sub = paste0(length(flowTime), " transactions between ", flowTime[1], " and ", flowTime[length(flowTime)]))
  dev.off()
}
together <- paste0(edgeListFull$from, edgeListFull$to)
for (j in 1:nrow(edgeListFull)) {
  if (j == 1) {
    weight <- sum(together == together[j])
  } else {
    weight[j] <- sum(together == together[j])
  }
}
edgeListFull$weight <- weight
edgeListFull <- unique(edgeListFull[,])
for (j in nrow(edgeListFull):1) {
  if (edgeListFull$from[j] == edgeListFull$to[j]) {
    edgeListFull <- edgeListFull[-c(j), ]
  }
}
net <- graph_from_data_frame(d = edgeListFull,
                             vertices = nodes,
                             directed = TRUE)
jpeg(file = paste0(workingDir, "images/graphPlots/aggregateGraph.jpeg"))
plot(net,
     vertex.color = "#EF9A9A",
     vertex.frame.color = "#FFFFFF",
     vertex.label.color = "black",
     vertex.label.dist = 0.5,
     edge.arrow.size = 0.5,
     edge.width = log(edgeListFull$weight))
title(main = paste0("Aggregate flow graph (weights are logged)"))
dev.off()

## Q4 : Methods for looking at anomalous requests
# Two methods used to identify anomalous requests: (i) The length of query values; and (ii) The character distribution of query values

# (i) Query character length

parameters <- na.omit(urltools::url_parse(as.character(trafficData$requestURLPath))$parameter)
noParameters <- length(parameters)
noUniqueParameters <- length(unique(parameters))
for (i in 1:length(parameters)) {
  paramSplit <- as.data.frame.list(strsplit(parameters[i],
                                            split = "&",
                                            fixed = TRUE))
  if (!is.na(paramSplit[1, 1])) {
    for (j in 1:nrow(paramSplit)) {
      arg <- as.data.frame(strsplit(as.character(paramSplit[j, 1]),
                                    split = "=",
                                    fixed = TRUE))
      if (i == 1 && j == 1) {
        argNames <- as.character(arg[1, 1])
        args <- as.character(arg[2, 1])
        argLength <- nchar(as.character(arg[2, 1]))
      } else {
        argNames[length(argNames) + 1] <- as.character(arg[1, 1])
        args[length(args) + 1] <- as.character(arg[2, 1])
        argLength[length(argLength) + 1] <- nchar(as.character(arg[2, 1]))
      }
    }
  }
}
args <- urltools::url_decode(args)
arguments <- data.frame(name = argNames,
                        argument = args,
                        length = argLength)
argumentDensity <- ggplot2::ggplot(data = arguments,
                                   mapping = aes(x = length,
                                                 fill = name,
                                                 colour = name)) +
  geom_density(alpha = 0.1) +
  labs(title = "Density of character length for each parameter",
       x = "Character length",
       y = "Density")
ggplot2::ggsave(filename = paste0(workingDir, "images/argumentDensity.png"),
                plot = argumentDensity)
uniArgNames <- unique(argNames)
for (i in 1:length(uniArgNames)) {
  argSubset <- subset(arguments,
                      arguments$name == uniArgNames[i])
  if (i == 1) {
    avgLength <- mean(na.omit(argSubset$length))
    sdLength <- sd(na.omit(argSubset$length))
  } else {
    avgLength[i] <- mean(na.omit(argSubset$length))
    sdLength[i] <- sd(na.omit(argSubset$length))
  }
}
argumentStats <- data.frame(name = uniArgNames,
                            avgLength = avgLength,
                            sdLength = sdLength,
                            varLength = sdLength ^ 2)

# (ii) Query character distribution (Create a Idealised Character Distribution [ICD])

df <- sapply(1:nrow(arguments), function(x) {
  b <- sort(as.data.frame(table(strsplit(as.character(arguments$argument[x]), "")[[1]]))$Freq,
            decreasing = TRUE)
  c(as.character(arguments$name[x]), b, rep(0, (256 - length(b))))
})
df <- as.data.frame(t(df),
                    stringsAsFactors = FALSE)
bins <- c(1, 4, 7, 12, 16, 256)
for (k in 1:length(uniArgNames)) {
  s <- data.matrix(subset(df[, 2:ncol(df)],
                          df[, 1] == uniArgNames[k]))
  dist <- as.vector(round(colSums(s)/nrow(s),
                          digits = 0))
  for (l in 1:length(bins)) {
    if (l == 1) {
      binDist <- dist[1]
    } else {
      binDist[l] <- sum(dist[(bins[l - 1] + 1):bins[l]])
    }
  }
  if (k == 1) {
    ICD <- c(binDist, nrow(s))
  } else {
    ICD <- rbind(ICD,
                 c(binDist, nrow(s)))
  }
}
if (length(uniArgNames) == 1) {
  ICD <- as.data.frame(ICD)
  ICD <- cbind(uniArgNames, t(ICD))
} else {
  ICD <- as.data.frame(ICD,
                       row.names = FALSE)
  ICD <- cbind(uniArgNames, ICD)
}
colnames(ICD) <- c("argName", paste0("bin", seq(1:6)), "count")
print(ICD)
