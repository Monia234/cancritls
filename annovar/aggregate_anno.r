args <- commandArgs(trailingOnly = T)
input <- args[1]
output <- args[2]

bim <- read.table(input, as.is = T, na.strings = "-9")
agg <- aggregate(V2 ~ V7, data = bim, function(x) {paste(x, collapse = " ")})
write.table(data.frame(agg), file = args[2], row.names = F, col.names = F, quote = F, sep = "\t")

