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

Rccmatch.naive <- function(x, N) {
    df <- cbind(index = seq(ncol(x)), t(x))
    matched <- rep(FALSE, ncol(x))
    ret <- c()
    for (i in 2:ncol(df)) {
        sorted <- df[order(df[,i]),]    
        pair <- c(i - 1)
        sum = 0
        for (j in 1:nrow(df)) {
            if (!matched[sorted[j, 1]]) {
                pair <- c(pair, sorted[j, 1])
                matched[sorted[j, 1]] = TRUE
                sum = sum + sorted[j, i]
                if (length(pair) == N + 1) {
                    pair <- c(pair, sum)
                    break
                }          
            }      
        }
        ret <- rbind(ret, pair)
    }
    ret <- data.frame(ret)
    colnames(ret) <- c("Case", paste("Control", seq(N), sep = ""), "Distance")
    rownames(ret) <- seq(nrow(ret))
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

