Rccmatch <- function(admixture, fam, n, case.string = "2") {
    require(proxy)
    require(Rcpp)
    sourceCpp("Rccmatch.cpp")
   
    admixture.case <- admixture[fam[,6] == case.string,]
    admixture.control <- admixture[fam[,6] != case.string & !is.na(fam[,6]),]
    admixture.dist <- dist(admixture.control, admixture.case)

    ret <- ccmatch(admixture.dist, n)
    return (ret)
}

if (!interactive()) {
    args <- commandArgs(trailingOnly = T)
    if (length(args) >= 3) {
        admixture <- read.table(args[1], header = F, as.is = T)
        fam <- read.table(args[2], header = F, as.is = T, na.strings = "-9")
    
        case.string <- "2"
        if (length(args) == 4) case.string = args[4]

        admixture.ccmatch <- Rccmatch(admixture, fam, as.numeric(args[3]), case.string)
        write.table(admixture.ccmatch, file = paste(args[1], "ccmatch", sep = "."), row.names = F, col.names = F, quote = F, sep = "\t")
    }
}

