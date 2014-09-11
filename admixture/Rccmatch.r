require(proxy)
require(Rcpp)
sourceCpp("Rccmatch.cpp")

args <- commandArgs(trailingOnly = T)
admixture <- read.table(args[1], header = F, as.is = T, na.string = "-9")
fam <- read.table(args[2], header = F, as.is = T)

case.string <- "2"
if (length(args) == 4) case.string = args[4]

admixture.case <- admixture[fam$V6 == case.string, ]
admixture.control <- admixture[fam$V6 != case.string, ]
admixture.dist <- dist(admixture.control, admixture.case)

admixture.ccmatch <- ccmatch(admixture.dist, as.numeric(args[3]))

write.table(admixture.ccmatch, file = paste(args[1], "ccmatch", sep = "."), row.names = F, col.names = F, quote = F, sep = "\t")

