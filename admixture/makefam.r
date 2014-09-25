args <- commandArgs(trailingOnly = T)
fam <- read.table(args[1], as.is = T)
matched <- read.table(args[2])

fam <- fam[matched[,1],1:2]
fam[,2] <- sprintf("%04d", fam[,2])

write.table(fam, file = args[3], row.names = F, col.names = F, quote = F, sep = "\t")
