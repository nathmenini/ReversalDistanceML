library(magrittr)
library(progress)

setwd("/Users/almeida/Downloads/data")

range <- seq(10,100,10)
range[1] <- range[1] + 1

for(i in range){
	perms <- NULL
	pb <- txtProgressBar(min = 0, max = 5000, style = 3)
	for(j in 1:10000){
		p <- sample(1:i)
		perms <- rbind(perms, p)
		setTxtProgressBar(pb, j)
	}
	close(pb)
	
	perms <- perms[!duplicated(perms), ][1:5000,]
	write.table(perms, paste0("perm_",i,".txt"), sep = " ", row.names = F, col.names = F)
}