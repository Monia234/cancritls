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

admixture.plot <- function(admixture, label = "", population_label = NULL, savefile = "", ext = c("pdf"), print = T) {
    require(reshape2)
    require(ggplot2)
  
    if (label != "" & savefile == TRUE) savefile <- label
    else if (savefile != "" & label == "") label <- savefile
  
    if (!is.null(population_label)) colnames(admixture) <- population_label
    sorted <- admixture[do.call(order, -admixture),]
    sorted <- cbind(index = seq(nrow(sorted)), sorted)
    melted <- melt(sorted, id = "index", variable.name = "population", variable_name = "population") # variable_name for backward compatibility
      
    plt <- ggplot(melted, aes(x = index, y = value, fill = population)) + geom_bar(stat = "identity", width = 1) +
               theme(axis.title.x = element_blank(), axis.text.x = element_blank())
    if (print) print(plt)
    if (savefile != "") cancritls.saveplot(file = savefile, ext = ext, plot = plt, width = 9.7, height = 6.4, dpi = 300)
}

