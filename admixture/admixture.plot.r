cancritls.getfilename <- function(name, ext, nameAsBase = T) {
    if (!nameAsBase) {
        base <- unlist(strsplit(name, "\\."))
        base <- paste(base[1:length(base) - 1], collapse = ".")
    } else base <- name
    return (paste(base, ext, sep = "."))
}

cancritls.saveplot <- function(file, ext, plot, width, height, dpi = 300) {
    require(ggplot2)
    if (length(ext) == 0) ggsave(file = file, plot = plot, width = width, height = height, dpi = dpi)
    else {
        for (i in ext) {
            savefile <- cancritls.getfilename(file, i)
            ggsave(file = savefile, plot = plot, width = width, height = height, dpi = dpi)
        }
    }
}

admixture.plot <- function(admixture, label = "", population_label = NULL, sort = T, sort.keys = c(), savefile = "", ext = c("pdf"), print = T) {
    require(reshape2)
    require(ggplot2)
  
    if (label != "" & savefile == TRUE) savefile <- label
    else if (savefile != "" & label == "") label <- savefile
  
    if (!is.null(population_label)) colnames(admixture) <- population_label
    else colnames(admixture) <- paste("Pop", seq(ncol(admixture)), sep = "")

    if (sort) {
        if (length(sort.keys) > 0) {
            if (any(is.character(sort.keys))) sort.keys <- match(sort.keys, colnames(admixture))
            admixture.order <- c(sort.keys, setdiff(seq(ncol(admixture)), sort.keys))
            if (length(admixture.order) != ncol(admixture)) stop("sort.keys don't match existing columns")
            else admixture <- admixture[,admixture.order]
        }
        admixture <- admixture[do.call(order, -admixture),]
    }
    admixture <- cbind(index = seq(nrow(admixture)), admixture)
    admixture.melted <- melt(admixture, id = "index", variable.name = "population", variable_name = "population") # variable_name for backward compatibility
      
    plt <- ggplot(admixture.melted, aes(x = index, y = value, fill = population)) + geom_bar(stat = "identity", width = 1) +
               theme(axis.title.x = element_blank(), axis.text.x = element_blank())
    if (print) print(plt)
    if (savefile != "") cancritls.saveplot(file = savefile, ext = ext, plot = plt, width = 9.7, height = 6.4, dpi = 300)
}

