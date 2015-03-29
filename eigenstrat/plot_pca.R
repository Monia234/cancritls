library(ggplot2)
library(gridExtra)

width = 16
height = 9
dpi = 300

args <- commandArgs(trailingOnly = T)

input <- args[1]

df <- read.table(input)
if (length(args) > 1) {
    pop <- read.table(args[2], header = T, sep = "\t")[,c(1:2, 7)]
    df <- merge(df, pop, by.x = c("V1", "V2"), by.y = c("Family.ID", "Individual.ID"))
} else {
    df$Population <- NULL
}


nevec <- ncol(df) - 2
plts <- lapply(1:(nevec/2), function(i) {
    ii <- i*2 + 1
    qplot(x = df[, ii], y = df[, ii+1], color = df$Population) + xlab(paste("eigenvector", ii-2)) + ylab(paste("eigenvector", ii-1)) + labs(color = "population") + theme(legend.position = "bottom")
})

arrangeGrob.args <- c(plts, list(nrow = 2))
for (ext in c("png")) {
    ggsave(paste(input, ext, sep = "."), do.call(arrangeGrob, arrangeGrob.args), width = width, height = height, dpi = dpi)
}

