set.seed(290)
library(dplyr)
library(data.table)

# AirlineDataAll <- read.csv("~/Desktop/Big data course/6_parallel_practice/data/AirlineDataAll.csv")
AirlineDataAll <- fread("../data/AirlineDataAll.csv")
AirlineDataAll <- subset(AirlineDataAll, UniqueCarrier == "US")

AirlineDataAll <- as.data.frame(AirlineDataAll)
AirlineDataAll$Cancelled <- AirlineDataAll$Cancelled %>% as.factor()
AirlineDataAll$Dest <- AirlineDataAll$Dest %>% as.factor()
AirlineDataAll <- subset(AirlineDataAll, !is.na(ArrDelay))
AirlineDataAll <- subset(AirlineDataAll, !is.na(DepDelay))

plot(ArrDelay~ DepDelay, data = AirlineDataAll)
# ===============================================================================================
# prepare for CV
# ===============================================================================================
n.fold <- 10
# determine no of samples per fold
sample.each.fold <- ceiling(nrow(AirlineDataAll) / n.fold)
airline.chunk <- split(AirlineDataAll,
    sample(head(rep(1:n.fold, each = sample.each.fold), n = nrow(AirlineDataAll)))
    )

# take a look at a fold
# airline.chunk[[10]]

# number of observations in each fold
sapply(airline.chunk, nrow)
# ===============================================================================================
# create training and test set
# ===============================================================================================
airline.train <- plyr::ldply(airline.chunk[1:9])
airline.test <- plyr::ldply(airline.chunk[10])
# ===============================================================================================
# fit svm on training set
# ===============================================================================================
library(kernlab)
svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = 0.5)
# svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = 2, epsilon = 1)
svm.fit

# count time
system.time(svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = 0.5))