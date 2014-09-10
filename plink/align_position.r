args <- commandArgs(trailingOnly = T)
# args[1] : bim file
# args[2] : ref file

align.position <- function(bim, ref) {
    require(data.table)

    bim.dt <- fread(bim, header = FALSE)
    ref.dt <- fread(ref, header = FALSE)
    setnames(bim.dt, c("chr", "rsID", "mrpos", "pos", "A1", "A2"))
    setnames(ref.dt, c("chr", "rsID", "mrpos", "pos", "A1", "A2"))
    setkey(ref.dt, rsID)

    exclude <- c()
    for (i in 1:nrow(bim.dt)) {
        b <- bim.dt[i]
        r <- ref.dt[b$rsID]
        if (b$chr != r$chr | length(unique(c(b$A1, b$A2, r$A1, r$A2))) != 2) {
            exclude <- c(exclude, b$rsID)
        } else bim.dt[i]$pos <- r$pos
    }

    return (list(bim = data.frame(bim.dt), exclude = data.frame(exclude)))
}

input_bim <- paste(args[1], "bim", "old", sep = ".")
input_ref <- paste(args[2], "bim", sep = ".")

output_bim <- paste(args[1], "bim", sep = ".")
output_exclude <- paste(args[1], "exclude", sep = ".")

result <- align.position(input_bim, input_ref)

write.table(result$bim, file = output_bim, sep='\t', quote = F, col.names = F, row.names = F)
write.table(result$exclude, file = output_exclude, quote = F, col.names = F, row.names = F)

