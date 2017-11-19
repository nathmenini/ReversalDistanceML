library(stringr)

# pasta em que tiver os arquivos txt no formato do zanoni
setwd("/Users/almeida/Downloads/RevelsalDistance")

# nome dos arquivos no formato do zanoni
files = c("8.out",
		  "9.out",
		  "10.out")

# salva um txt para cada arquivo, em que as colunas estao separadas com espaco em branco
for(i in 1:length(files)){
	p <- read.table(files[i], sep = ",")
	dat <- data.frame(p[,1:dim(p)[2]-1], apply(str_split_fixed(p[,dim(p)[2]], " ", 2), 2, as.numeric))
	write.table(dat, paste0("perm_",i+7,".txt"), sep = " ", row.names = F, col.names = F)	
}
