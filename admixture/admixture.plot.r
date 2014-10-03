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

## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
    require(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This does the summary. For each group's data frame, return a vector with
    # N, mean, and sd
    datac <- ddply(data, groupvars, .drop=.drop,
      .fun = function(xx, col) {
        c(N    = length2(xx[[col]], na.rm=na.rm),
          mean = mean   (xx[[col]], na.rm=na.rm),
          sd   = sd     (xx[[col]], na.rm=na.rm)
        )
      },
      measurevar
    )

    # Rename the "mean" column    
    datac <- rename(datac, c("mean" = measurevar))

    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult

    return(datac)
}


admixture.plot <- function(admixture, label = "", population_label = NULL, sort = T, sort.keys = c(), sort.descending = F, savefile = "", ext = c("pdf"), print = T) {
    require(reshape2)
    require(ggplot2)
  
    if (label != "" & savefile == TRUE) savefile <- label
    else if (savefile != "" & label == "") label <- savefile
  
    if (!is.null(population_label)) colnames(admixture) <- population_label
    else colnames(admixture) <- paste("Pop", seq(ncol(admixture)), sep = "")

    if (sort) {
        if (length(sort.keys) > 0 || sort.descending) {
            if (any(is.character(sort.keys))) sort.keys <- match(sort.keys, colnames(admixture))
            if (sort.descending) s <- order(-apply(admixture, 2, sum))
            else s <- seq(ncol(admixture))
            admixture.order <- c(sort.keys, setdiff(s, sort.keys))
            if (length(admixture.order) != ncol(admixture)) stop("sort.keys don't match existing columns.")
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

kcv.plot <- function(kcv, errorbar = F, label = "", savefile = "", ext = c("pdf"), print = T) {
    require(ggplot2)
  
    if (label != "" & savefile == TRUE) savefile <- label
    else if (savefile != "" & label == "") label <- savefile

    if (errorbar) kcv <- summarySE(kcv, measurevar = "CV", groupvars = c("K"))

    plt <- ggplot(kcv, aes(x = K, y = CV)) + geom_line() + geom_point()
    if (errorbar) plt <- plt + geom_errorbar(aes(ymin = CV-se, ymax = CV+se), width = .1)
    if (print) print(plt)
    if (savefile != "") cancritls.saveplot(file = savefile, ext = ext, plot = plt, width = 9.7, height = 6.4, dpi = 300)
}
