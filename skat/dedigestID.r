args <- commandArgs(trailingOnly = T)
maxn <- 50

input <- read.table(args[1], as.is = T, header = T)
tbl <- read.table(args[2], as.is = T)

matched <- input[,1] %in% tbl[,1]
index <- match(input[,1], tbl[,1])
index <- index[!is.na(index)]

input[matched, 1] <- tbl[index, 2]
write.table(input, file = args[3], row.names = F, quote = F, sep = "\t")
