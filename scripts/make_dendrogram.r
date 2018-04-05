#!/usr/bin/env Rscript

library("optparse")
library("ggdendro")
library("ggplot2")
library("vegan")
library("R.utils")

# set arguments
option_list = list (
  make_option(c("-m", "--matrix"), 
              type = "character", 
              default = "",
              help = "Matrix file", 
              metavar="character"
  ),
  make_option(c("-o", "--outdir"), 
              type = "character", 
              default = '',
              help = "set work directory (--file dir)"
  ),
  make_option(c("-n", "--nreads"), 
              type = "integer", 
              default = 0,
              help = "Number of reads for normalization"
  )
);

opt_parser  = OptionParser(option_list = option_list)
opt         = parse_args(opt_parser)
out_dir     = opt$outdir
matrix_file = opt$matrix
nreads      = opt$nreads

# check arguments
if (nreads <= 0) {
  stop("--nreads must be a postive integer")
}

if (nchar(matrix_file) == 0) {
  stop("Missing --matrix")
}

if (!file.exists(matrix_file)) {
  stop(paste("Bad matrix file", matrix_file))
}

if (nchar(out_dir) == 0) {
  out_dir = dirname(matrix_file)
}

if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

# nreads = 500000
# matrix_file = "~/work/fizkin-paper/sna/ecoli_sap/matrix_log_avg.txt"
# out_dir = dirname(matrix_file)

df = read.table(matrix_file, header = TRUE)
dist.matrix = as.dist(1 - df/max(df))
#dist.matrix = as.dist(1 - df/nreads)
fit = hclust(dist.matrix, method = "ward.D2") 
out.file = file.path(out_dir, "distance-norm.png")
ggsave(out.file, 
       width=5, 
       height=5,
       plot=ggdendro::ggdendrogram(fit, rotate=T) + ggtitle("Distance Norm"))

# PCOA plot
# fiz_pcoa = rda(df)
# p1 = round(fiz_pcoa$CA$eig[1]/sum(fiz_pcoa$CA$eig)*100, digits = 2)
# p2 = round(fiz_pcoa$CA$eig[2]/sum(fiz_pcoa$CA$eig)*100, digits = 2)
# xlabel = paste0("PCoA1 (", p1, "%)")
# ylabel = paste0("PCoA2 (", p2, "%)")
# 
# # plot PCoA
# pdf(file.path(out_dir, paste0("pcoa-", dmethod, ".pdf")), width = 6, height = 6)
# 
# biplot(fiz_pcoa,
#        display = "sites",
#        col     = "black",
#        cex     = 2,
#        xlab    = paste(xlabel),
#        ylab    = paste(ylabel)
# )
# 
# points(fiz_pcoa,
#        display = "sites",
#        col     = "black",
#        cex     = .5,
#        pch     = 20
# )
# title(main = dmethod)
# dev.off()


printf("Done, see output in '%s'\n", out_dir)