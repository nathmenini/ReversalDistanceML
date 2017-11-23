library(keras)
library(magrittr)
library(data.table)
library(ggplot2)

# reprodutibilidade
set.seed(1)

# nao esquecer de mudar o path e fazer unzip nos arquivos necessarios

# -------------------------------------
# Leitura dos dados
# -------------------------------------
# define caminho para os dados
data_path <- "/Users/almeida/Downloads/data/"

# leitura das features
data <- read.table(paste0(data_path, "featuresFixed.txt"))

# leitura das distancias exatas
data$dist <- read.table(paste0(data_path, "distReversal.txt"))[,1]

# Greedy Reversal Sort
data$greedy <- read.table(paste0(data_path, "greedyReversalSort.txt"))[,1]

# simple Reversal Sort
data$simple <- read.table(paste0(data_path, "simpleReversalSort.txt"))[,1]

names(data) <- c("qtdBp",
				 "qtdStripUnit",
				 "menorStrip",
				 "maiorStrip",
				 "crescStrip",
				 "decrescStrip",
				 "totalCiclos",
				 "qtdCiclosImp",
				 "qtdCiclosPar",
				 "maiorCiclo",
				 "menorCiclo",
				 "orientadoCiclo",
				 "tamanhoPerm",
				 "dist",
				 "dGreedy",
				 "dSimple")

data <- data[which(data$dist >= data$qtdBp/2),]


# -------------------------------------
# Separacao em amostra treino (dTrain), validacao (dVal) e teste (dTeste)
# -------------------------------------
# Separando em amostre treino e teste
minP <- min(data$tamanhoPerm)
maxP <- max(data$tamanhoPerm)
indexTrain <- NULL
for(i in minP:maxP){
	index <- which(data$tamanhoPerm == i)
	indexTrain <- c(indexTrain, sample(index, (length(index)*0.8) %>% round(0)))
}
train <- data[indexTrain,]
dTest <- data[-indexTrain,]

# Separando em amostre treino e validacao
indexTrain <- NULL
for(i in minP:maxP){
	index <- which(train$tamanhoPerm == i)
	indexTrain <- c(indexTrain, sample(index, (length(index)*0.8) %>% round(0)))
}

dTrain <- train[indexTrain,]
dVal <- train[-indexTrain,]


# Modelagem e Analise de overfitting
# -------------------------------------
# Modelo de regressão linear multiplo
# -------------------------------------
fit <- lm(dist ~ ., data = dTrain[,1:14])
pred <- predict(fit, dVal[,-14])
dVal$pred <- pred
dTest$pred <- predict(fit, dTest[,1:13])

boxplot(pred~dVal$dist, xlab = "true distance", ylab = "predicted distance")
table(dVal$dist, pred %>% round(0))

# -------------------------------------
# Modelo Neural Networks
# -------------------------------------
p <- dim(head(dTrain[1:13]))[2]

model <- keras_model_sequential() 

model %>% 
	layer_dense(units = 30, activation = 'relu', input_shape = c(p)) %>% 
	layer_dropout(rate = 0.2) %>%
	layer_dense(units = 1, activation = 'relu')


model %>% compile(
	loss = 'mean_squared_error',
	optimizer = optimizer_rmsprop(),
	metrics = c('mse')
)

history <- model %>% fit(
	as.matrix(dTrain[,1:13]), dTrain$dist, 
	epochs = 10, batch_size = 128,
	validation_data = list(as.matrix(dVal[,1:13]), dVal$dist)
)

dVal$predNN <- model %>% predict_on_batch(as.matrix(dVal[,1:13]))
dTest$predNN <- model %>% predict_on_batch(as.matrix(dTest[,1:13]))


# -------------------------------------
# Resultados e Graficos
# Se quiser ver os resultados para o teste, tem que mudar dVal para dTest
# -------------------------------------
# nro breaks vs media da distancia
#dVal <- dTest
meanDistBp <- aggregate(dVal$pred, list(dVal$qtdBp), mean)
meanDistBpNN <- aggregate(dVal$predNN, list(dVal$qtdBp), mean)
meanGreedy <- aggregate(dVal$dGreedy, list(dVal$qtdBp), mean)
meanSimple <- aggregate(dVal$dSimple, list(dVal$qtdBp), mean)
meanReal <- aggregate(dVal$dist, list(dVal$qtdBp), mean)

dif1 <- data.frame(dist = c(abs(meanGreedy[,2]-meanReal[,2]),
							abs(meanSimple[,2]-meanReal[,2]),
							abs(meanDistBp[,2]-meanReal[,2]),
							abs(meanDistBpNN[,2]-meanReal[,2])),
				   xValue = rep(meanDistBp$Group.1, 4),
				   Abordagem = c(rep("Greedy Sort", meanDistBp$Group.1 %>% length()),
				   			  rep("Simple Sort", meanDistBp$Group.1 %>% length()),
				   			  rep("RL", meanDistBp$Group.1 %>% length()),
				   			  rep("NN", meanDistBp$Group.1 %>% length())),
				   flag = rep("# Breakpoint", (meanDistBp$Group.1 %>% length())*4)
)

plot1 <- data.frame(Abordagem = c(rep("RL", meanDistBp$Group.1 %>% length()),
								  rep("NN", meanDistBp$Group.1 %>% length()),
								  rep("Greedy Sort", meanDistBp$Group.1 %>% length()),
								  rep("Simple Sort", meanDistBp$Group.1 %>% length()),
								  rep("Real", meanDistBp$Group.1 %>% length()),
								  rep("Lim. Inf.", meanDistBp$Group.1 %>% length()),
								  rep("Lim. Sup.", meanDistBp$Group.1 %>% length())),
					yValue = c(meanDistBp[,2],
							   meanDistBpNN[,2],
							   meanGreedy[,2],
							   meanSimple[,2],
							   meanReal[,2],
							   meanDistBp[,1]/2,
							   meanDistBp[,1]),
					xValue = rep(meanDistBp$Group.1, 7),
					line = c(rep("1", meanDistBp$Group.1 %>% length()),
							 rep("1", meanDistBp$Group.1 %>% length()),
							 rep("1", meanDistBp$Group.1 %>% length()),
							 rep("1", meanDistBp$Group.1 %>% length()),
							 rep("1", meanDistBp$Group.1 %>% length()),
							 rep("2", meanDistBp$Group.1 %>% length()),
							 rep("2", meanDistBp$Group.1 %>% length())),
					flag = rep("# Breakpoint", (meanDistBp$Group.1 %>% length())*7)
)

# Tamanho de p vs media da distancia
meanDistTam <- aggregate(dVal$pred, list(dVal$tamanhoPerm), mean)
meanDistTamNN <- aggregate(dVal$predNN, list(dVal$tamanhoPerm), mean)
meanGreedy <- aggregate(dVal$dGreedy, list(dVal$tamanhoPerm), mean)
meanSimple <- aggregate(dVal$dSimple, list(dVal$tamanhoPerm), mean)
meanReal <- aggregate(dVal$dist, list(dVal$tamanhoPerm), mean)
lim <- aggregate(dVal$qtdBp, list(dVal$tamanhoPerm), mean)

dif2 <- data.frame(dist = c(abs(meanGreedy[,2]-meanReal[,2]),
							abs(meanSimple[,2]-meanReal[,2]),
							abs(meanDistTam[,2]-meanReal[,2]),
							abs(meanDistTamNN[,2]-meanReal[,2])),
				   xValue = rep(meanDistTam$Group.1, 4),
				   Abordagem = c(rep("Greedy Sort", meanDistTam$Group.1 %>% length()),
				   			  rep("Simple Sort", meanDistTam$Group.1 %>% length()),
				   			  rep("RL", meanDistTam$Group.1 %>% length()),
				   			  rep("NN", meanDistTam$Group.1 %>% length())),
				   flag = rep("Tamanho da permutação", (meanDistTam$Group.1 %>% length())*4)
)

plot2 <- data.frame(Abordagem = c(rep("RL", meanDistTam$Group.1 %>% length()),
								  rep("NN", meanDistTam$Group.1 %>% length()),
								  rep("Greedy Sort", meanDistTam$Group.1 %>% length()),
								  rep("Simple Sort", meanDistTam$Group.1 %>% length()),
								  rep("Real", meanDistTam$Group.1 %>% length()),
								  rep("Lim. Inf.", meanDistTam$Group.1 %>% length()),
								  rep("Lim. Sup.", meanDistTam$Group.1 %>% length())),
					yValue = c(meanDistTam[,2],
							   meanDistTamNN[,2],
							   meanGreedy[,2],
							   meanSimple[,2],
							   meanReal[,2],
							   lim[,2]/2,
							   lim[,2]),
					xValue = rep(meanDistTam$Group.1, 7),
					line = c(rep("1", meanDistTam$Group.1 %>% length()),
							 rep("1", meanDistTam$Group.1 %>% length()),
							 rep("1", meanDistTam$Group.1 %>% length()),
							 rep("1", meanDistTam$Group.1 %>% length()),
							 rep("1", meanDistTam$Group.1 %>% length()),
							 rep("2", meanDistTam$Group.1 %>% length()),
							 rep("2", meanDistTam$Group.1 %>% length())),
					flag = rep("Tamanho da permutação", (meanDistTam$Group.1 %>% length())*7)
)

plot <- rbind(plot1, plot2)
dif <- rbind(dif1, dif2)

gg <- ggplot(plot, aes(xValue, yValue, colour = Abordagem)) +
	geom_line(aes(linetype=line), lwd = .7) +
	facet_grid(.~flag, scales = "free") +
	guides(linetype=FALSE) +
	theme_light() +
	labs(x="", y="Média da distância") + 
	scale_color_manual(values=c("#6a5acd","#b4b4b4","#b4b4b4","#ff9900","#54ccfb","#24633e","#ff3300"),
					   labels=c("GRS", "Lim. Inf.", "Lim. Sup.", "RN", "Real", "RL", "SSUR")) +
	scale_y_continuous(breaks=seq(0,10,2))
gg
ggsave("bp.pdf", plot = gg,
	   scale = 1, width = NA, height = NA)

gg <- ggplot(dif, aes(xValue, dist, colour = Abordagem)) +
	geom_line(lwd = .7) +
	facet_grid(.~flag, scales = "free") +
	theme_light() +
	labs(x="", y="Diferença absoluta") + 
	scale_color_manual(values=c("#6a5acd","#ff9900","#24633e","#ff3300"),
					   labels=c("GRS", "RN", "RL", "SSUR"))+
	scale_y_continuous(breaks=seq(0,2.5,0.25))
gg
ggsave("dist.pdf", plot = gg,
	   scale = 1, width = NA, height = NA)

RMSE_val <- (((dVal$pred - dVal$dist)^2 %>% sum)/(dVal$pred %>% length)) %>% sqrt
RMSE_val_NN <- (((dVal$predNN - dVal$dist)^2 %>% sum)/(dVal$pred %>% length)) %>% sqrt

RMSE_Test <- (((dTest$pred - dTest$dist)^2 %>% sum)/(dTest$pred %>% length)) %>% sqrt
RMSE_Test_NN <- (((dTest$predNN - dTest$dist)^2 %>% sum)/(dTest$pred %>% length)) %>% sqrt

# Proporcao de elementos fora da banda
propInf <- data.frame(RL   = ((dVal$pred < dVal$qtdBp/2) %>% sum)/dim(dVal)[1],
					  RN   = ((dVal$predNN < dVal$qtdBp/2) %>% sum)/dim(dVal)[1],
					  GRS  = ((dVal$dGreedy < dVal$qtdBp/2) %>% sum)/dim(dVal)[1],
					  SSUR =  ((dVal$dSimple < dVal$qtdBp/2) %>% sum)/dim(dVal)[1])
propSup <- data.frame(RL   = ((dVal$pred > dVal$qtdBp) %>% sum)/dim(dVal)[1],
					  RN   = ((dVal$predNN > dVal$qtdBp) %>% sum)/dim(dVal)[1],
					  GRS  = ((dVal$dGreedy > dVal$qtdBp) %>% sum)/dim(dVal)[1],
					  SSUR =  ((dVal$dSimple > dVal$qtdBp) %>% sum)/dim(dVal)[1])


# -----------
# Analisando Big Perms

# Leitura das features
dataBigPerms <- read.table(paste0(data_path, "featuresFixedBig.txt"))

# Greedy Reversal Sort
dataBigPerms$greedy <- read.table(paste0(data_path, "greedyBigPerms.txt"))[,1]

# simple Reversal Sort
dataBigPerms$simple <- read.table(paste0(data_path, "simpleSortBigPerms.txt"))[,1]


names(dataBigPerms) <- c("qtdBp",
						 "qtdStripUnit",
						 "menorStrip",
						 "maiorStrip",
						 "crescStrip",
						 "decrescStrip",
						 "totalCiclos",
						 "qtdCiclosImp",
						 "qtdCiclosPar",
						 "maiorCiclo",
						 "menorCiclo",
						 "orientadoCiclo",
						 "tamanhoPerm",
						 "dGreedy",
						 "dSimple")

predBig <- predict(fit, dataBigPerms[,1:13])
dataBigPerms$predBig <- predBig
dataBigPerms$predBigNN <- model %>% predict_on_batch(as.matrix(dataBigPerms[,1:13]))

# nro breaks vs media da distancia
meanDistBp <- aggregate(dataBigPerms$predBig, list(dataBigPerms$qtdBp), mean)
meanDistBpNN <- aggregate(dataBigPerms$predBigNN, list(dataBigPerms$qtdBp), mean)
meanGreedy <- aggregate(dataBigPerms$dGreedy, list(dataBigPerms$qtdBp), mean)
meanSimple <- aggregate(dataBigPerms$dSimple, list(dataBigPerms$qtdBp), mean)

plotBig1 <- data.frame(Abordagem = c(rep("RL", meanDistBp$Group.1 %>% length()),
									 rep("NN", meanDistBp$Group.1 %>% length()),
									 rep("Greedy Sort", meanDistBp$Group.1 %>% length()),
									 rep("Simple Sort", meanDistBp$Group.1 %>% length()),
									 rep("Lim. Inf.", meanDistBp$Group.1 %>% length()),
									 rep("Lim. Sup.", meanDistBp$Group.1 %>% length())),
					   yValue = c(meanDistBp[,2],
					   		   meanDistBpNN[,2],
					   		   meanGreedy[,2],
					   		   meanSimple[,2],
					   		   meanDistBp[,1]/2,
					   		   meanDistBp[,1]),
					   xValue = rep(meanDistBp$Group.1, 6),
					   line = c(rep("1", meanDistBp$Group.1 %>% length()),
					   		 rep("1", meanDistBp$Group.1 %>% length()),
					   		 rep("1", meanDistBp$Group.1 %>% length()),
					   		 rep("1", meanDistBp$Group.1 %>% length()),
					   		 rep("2", meanDistBp$Group.1 %>% length()),
					   		 rep("2", meanDistBp$Group.1 %>% length())),
					   flag = rep("# Breakpoint", (meanDistBp$Group.1 %>% length())*6)
)

# Tamanho de p vs media da distancia
meanDistTam <- aggregate(dataBigPerms$predBig, list(dataBigPerms$tamanhoPerm), mean)
meanDistTamNN <- aggregate(dataBigPerms$predBigNN, list(dataBigPerms$tamanhoPerm), mean)
meanGreedy <- aggregate(dataBigPerms$dGreedy, list(dataBigPerms$tamanhoPerm), mean)
meanSimple <- aggregate(dataBigPerms$dSimple, list(dataBigPerms$tamanhoPerm), mean)
lim <- aggregate(dataBigPerms$qtdBp, list(dataBigPerms$tamanhoPerm), mean)

plotBig2 <- data.frame(Abordagem = c(rep("RL", meanDistTam$Group.1 %>% length()),
									 rep("NN", meanDistTam$Group.1 %>% length()),
									 rep("Greedy Sort", meanDistTam$Group.1 %>% length()),
									 rep("Simple Sort", meanDistTam$Group.1 %>% length()),
									 rep("Lim. Inf.", meanDistTam$Group.1 %>% length()),
									 rep("Lim. Sup.", meanDistTam$Group.1 %>% length())),
					   yValue = c(meanDistTam[,2],
					   		   meanDistTamNN[,2],
					   		   meanGreedy[,2],
					   		   meanSimple[,2],
					   		   lim[,2]/2,
					   		   lim[,2]),
					   xValue = rep(meanDistTam$Group.1, 6),
					   line = c(rep("1", meanDistTam$Group.1 %>% length()),
					   		 rep("1", meanDistTam$Group.1 %>% length()),
					   		 rep("1", meanDistTam$Group.1 %>% length()),
					   		 rep("1", meanDistTam$Group.1 %>% length()),
					   		 rep("2", meanDistTam$Group.1 %>% length()),
					   		 rep("2", meanDistTam$Group.1 %>% length())),
					   flag = rep("Tamanho da permutação", (meanDistTam$Group.1 %>% length())*6)
)

plot2 <- rbind(plotBig1, plotBig2)

gg <- ggplot(plot2, aes(xValue, yValue, colour = Abordagem)) +
	geom_line(aes(linetype=line), lwd = .7) +
	facet_grid(.~flag, scales = "free") +
	guides(linetype=FALSE) +
	theme_light() +
	labs(x="", y="Média da distância") + 
	scale_color_manual(values=c("#6a5acd","#b4b4b4","#b4b4b4","#ff9900","#24633e","#ff3300"),
					   labels=c("GRS", "Lim. Inf.", "Lim. Sup.", "RN", "RL", "SSUR"))
gg
ggsave("big.pdf", plot = gg,
	   scale = 1, width = NA, height = NA)

propInf <- data.frame(RL   = ((dataBigPerms$predBig < dataBigPerms$qtdBp/2) %>% sum)/dim(dataBigPerms)[1],
					  RN   = ((dataBigPerms$predBigNN < dataBigPerms$qtdBp/2) %>% sum)/dim(dataBigPerms)[1],
					  GRS  = ((dataBigPerms$dGreedy < dataBigPerms$qtdBp/2) %>% sum)/dim(dataBigPerms)[1],
					  SSUR =  ((dataBigPerms$dSimple < dataBigPerms$qtdBp/2) %>% sum)/dim(dataBigPerms)[1])
propSup <- data.frame(RL   = ((dataBigPerms$predBig > dataBigPerms$qtdBp) %>% sum)/dim(dataBigPerms)[1],
					  RN   = ((dataBigPerms$predBigNN > dataBigPerms$qtdBp) %>% sum)/dim(dataBigPerms)[1],
					  GRS  = ((dataBigPerms$dGreedy > dataBigPerms$qtdBp) %>% sum)/dim(dataBigPerms)[1],
					  SSUR =  ((dataBigPerms$dSimple > dataBigPerms$qtdBp) %>% sum)/dim(dataBigPerms)[1])
