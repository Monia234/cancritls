args <- commandArgs(trailingOnly = T)
input <- args[1]
output <- args[2]

bim <- read.table(input, as.is = T, na.strings = "-9")
agg <- aggregate(V2 ~ V7, data = bim, function(x) {paste(x, collapse = " ")})
agg.pos <- aggregate(V4 ~ V7, data = bim, function(x) {paste(min(x), max(x), sep = "\t")})
agg.chr <- aggregate(V1 ~ V7, data = bim, unique)
df <- data.frame(agg[,1], agg.chr[,2], agg.pos[,2], agg[,2])
write.table(df, file = args[2], row.names = F, col.names = F, quote = F, sep = "\t")

