Rccmatch <- function(x, fam, n, case.string = "2") {
    require(proxy)
    require(Rcpp)
    sourceCpp("Rccmatch.cpp")

    x.case <- x[fam[,6] == case.string,]
    if (nrow(x.case) == 0) stop("no case found.")
    x.control <- x[fam[,6] != case.string & !is.na(fam[,6]),]
    if (nrow(x.control) == 0) stop("no control found")
    if (n < nrow(x.control) / nrow(x.case)) stop("ratio of case:control is less than n")
    x.dist <- dist(x.control, x.case)

    ret <- ccmatch(x.dist, n)
    return (force(ret))
}

Rccmatch.naive <- function(x, fam, n, case.string = "2") {
    x.case <- x[fam[,6] == case.string,]
    if (nrow(x.case) == 0) stop("no case found.")
    x.control <- x[fam[,6] != case.string & !is.na(fam[,6]),]
    if (nrow(x.control) == 0) stop("no control found")
    if (n < nrow(x.control) / nrow(x.case)) stop("ratio of case:control is less than n")
    x.dist <- dist(x.control, x.case)

    df <- cbind(index = seq(ncol(x.dist)), t(x.dist))
    matched <- rep(FALSE, ncol(x.dist))
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
                if (length(pair) == n + 1) {
                    pair <- c(pair, sum)
                    break
                }
            }
        }
        ret <- rbind(ret, pair)
    }
    colnames(ret) <- c("Case", paste("Control", seq(n), sep = ""), "Distance")
    rownames(ret) <- seq(nrow(ret))
    return (data.frame(ret))
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

