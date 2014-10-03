args <- commandArgs(trailingOnly = T)
maxn <- 50

input <- args[1]
SetID <- read.table(args[1], as.is = T)

index <- which(nchar(SetID[,1]) > maxn)
if (length(index) > 0) {
    require(digest)
    SetID.digest <- SetID
    for (i in index) {
        SetID.digest[i, 1] <- digest(SetID[i, 1])
    }
    SetID.tbl <- unique(data.frame(SetID.digest[index, 1], SetID[index, 1]))

    write.table(SetID.digest, file = args[2], row.names = F, col.names = F, quote = F, sep = "\t")
    write.table(SetID.tbl, file = args[3], row.names = F, col.names = F, quote = F, sep = "\t")
} else write.table(SetID, file = args[2], row.names = F, col.names = F, quote = F, sep = "\t")
