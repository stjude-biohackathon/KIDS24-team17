library(ggplot2)
library(ape)
library(ggtree)

test_path <- "/Users/kgibney/Documents/fNIRS_Data"


test_dir <- dir(test_path,recursive=TRUE)

test_tree <- fs::dir_tree(test_path)

sink(file = "test_tree.log")
res_fs_tree <- fs::dir_tree(path = test_path, recurse = TRUE)
sink()
res_fs_tree[[1]]
