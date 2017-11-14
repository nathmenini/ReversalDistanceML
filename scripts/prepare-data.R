library(stringr)

setwd("/Users/almeida/Documents/GitHub/ReversalDistanceML/data/")

files = c("s_perms_size5.txt",
		  "s_perms_size6.txt",
		  "s_perms_size7.txt",
		  "s_perms_size8.txt",
		  "s_perms_size9.txt",
		  "s_perms_size10.txt")

for(i in 1:length(files)){
	p <- read.table(files[i], sep = ",")	
	dat <- data.frame(p[,1:dim(p)[2]-1], apply(str_split_fixed(p[,dim(p)[2]], " ", 2), 2, as.numeric))
	write.table(dat, paste0("perm_",i+4,".txt"), sep = " ", quote = F)	
}
