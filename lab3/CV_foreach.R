# ===============================================================================================
# Load and clean data
# ===============================================================================================
set.seed(290)
library(dplyr)
library(data.table)

AirlineDataAll <- fread("~/Desktop/Big data course/6_parallel_practice/data/AirlineDataAll.csv")
# Slow! don't run
# AirlineDataAll <- read.csv("~/Desktop/Big data course/6_parallel_practice/data/AirlineDataAll.csv")

# Choose only records for US carrier
AirlineDataAll <- subset(AirlineDataAll, UniqueCarrier == "US")

# Turn variables into factor before fitting model
AirlineDataAll <- as.data.frame(AirlineDataAll)
AirlineDataAll$Cancelled <- AirlineDataAll$Cancelled %>% as.factor()
AirlineDataAll$Dest <- AirlineDataAll$Dest %>% as.factor()
AirlineDataAll <- subset(AirlineDataAll, !is.na(ArrDelay))
AirlineDataAll <- subset(AirlineDataAll, !is.na(DepDelay))

# Explore the variables of interest
plot(ArrDelay~ DepDelay, data = AirlineDataAll, main = "Arrival Delay v.s. Departure Delay")
# ===============================================================================================
# prepare for CV
# ===============================================================================================
n.fold <- 10
# determine no of samples per fold
sample.each.fold <- ceiling(nrow(AirlineDataAll) / n.fold)
airline.chunk <- split(AirlineDataAll, 
                       sample(head(rep(1:n.fold, each = sample.each.fold), n = nrow(AirlineDataAll))))

# take a look at a fold
airline.chunk[[10]]

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
svm.fit
# count time
system.time(svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = 0.5))
# ===============================================================================================
# prediction on test set
# ===============================================================================================
delay.hat <- predict(svm.fit, airline.test)
delay.true <- airline.test$ArrDelay

rmse <- sqrt(mean((delay.true - delay.hat)^2))

# ===============================================================================================
# 10-fold CV
# ===============================================================================================
do.cv <- function(C) {
  total.rmse <- rep(0, n.fold)
  for (it in 1:n.fold) {
    chunk.left.out <- it
    chunk.as.train <- setdiff(1:n.fold, it)
    # ===============================================================================================
    # create training and test set
    # ===============================================================================================
    airline.train <- plyr::ldply(airline.chunk[chunk.as.train])
    airline.test <- plyr::ldply(airline.chunk[chunk.left.out])
    # ===============================================================================================
    # fit svm on training set
    # ===============================================================================================
    library(kernlab)
    svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = C)
    svm.fit
    # count time
    system.time(svm.fit <- ksvm(ArrDelay ~ DepDelay + Dest, data = airline.train, kernel = 'vanilladot', C = C))
    # ===============================================================================================
    # prediction on test set
    # ===============================================================================================
    delay.hat <- predict(svm.fit, airline.test)
    delay.true <- airline.test$ArrDelay

    rmse <- sqrt(mean((delay.true - delay.hat)^2))
    total.rmse[it] <- rmse
  }

  return(total.rmse)
}

# ===============================================================================================
# CV for tuning parameters
# ===============================================================================================
library(foreach)
library(doParallel)
registerDoParallel(detectCores())

C.grid <- seq(1, 5)
# rmse.vs.C <- rep(0, length(C.grid))

rmse.vs.C <- foreach(it2 = 1:length(C.grid), .combine = c) %dopar% {
	rmse.cv <- do.cv(C.grid[it2])
	mean.rmse <- mean(rmse.cv)

	mean.rmse
}


system.time(
  rmse.vs.C <- foreach(it2 = 1:length(C.grid), .combine = c) %dopar% {
    rmse.cv <- do.cv(C.grid[it2])
    mean.rmse <- mean(rmse.cv)
    
    mean.rmse
  }
)
## user   system  elapsed 
## 1952.119   21.142 1343.310 

C.optim <- C.grid[which.min(rmse.vs.C)]
print(paste("optimal tuning parameter is", C.optim))
## [1] "optimal tuning parameter is 1"