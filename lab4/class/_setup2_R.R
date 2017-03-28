#!/usr/bin/Rscript --vanilla
options(repos = "http://cran.cnr.berkeley.edu/")
install.packages("doParallel")
install.packages("ggplot2")
install.packages("itertools")
install.packages("devtools")
install.packages("data.table")
install.packages("igraph")
require(devtools)
install.packages("pryr")
install.packages("simcausal")
# to install an R package from github:
# devtools::install_github('osofr/simcausal', build_vignettes = FALSE)
install.packages("tmlenet")

# ------------------------------------------------------
# verify parallel is working
# ------------------------------------------------------
require(doParallel)
ncores <- 3
registerDoParallel(cores = ncores)

# returns the process ID of the corresponding child process:
xpid <- function(x) c(x=x, pid=Sys.getpid())

# When preschedule=FALSE is disabled, each parallel call gets its own job
mcoptions <- list(preschedule=FALSE, set.seed=FALSE)
foreach(i=1:6, .options.multicore=mcoptions) %dopar% xpid(i)

# When preschedule=TRUE, the parallel calls are first divided into at most ncores number of jobs (2 calls per job)
mcoptions <- list(preschedule=TRUE, set.seed=FALSE)
foreach(i=1:6, .options.multicore=mcoptions) %dopar% xpid(i)