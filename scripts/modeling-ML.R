library(keras)
library(magrittr)
library(data.table)
library(ggplot2)

set.seed(1)
# nao esquecer de mudar o path e fazer unzip nos arquivos necessarios

# -------------------------------------
# Leitura dos daddos
# -------------------------------------
# define caminho para os dados
data_path <- "/Users/almeida/Downloads/data/"

# leitura das features
data <- read.table(paste0(data_path, "features.txt"))

# leitura das distancias exatas
data$dist <- read.table(paste0(data_path, "dist.txt"))[,1]

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



# -------------------------------------
# Modelo de regressão linear multiplo
# -------------------------------------
fit <- lm(dist ~ ., data = dTrain[,1:14])
pred <- predict(fit, dVal[,-14])
dVal$ pred <- pred

boxplot(pred~dVal$dist, xlab = "true distance", ylab = "predicted distance")
table(dVal$dist, pred %>% round(0))



# -------------------------------------
# Modelo Neural Networks
# -------------------------------------
p <- dim(head(dTrain[1:13]))[2]

model <- keras_model_sequential() 
model %>% 
	layer_dense(units = 256, activation = 'relu', input_shape = c(p)) %>% 
	layer_dropout(rate = 0.4) %>% 
	layer_dense(units = 128, activation = 'relu') %>%
	layer_dropout(rate = 0.3) %>%
	layer_dense(units = 1, activation = 'relu')

model %>% compile(
	loss = 'mean_squared_error',
	optimizer = optimizer_rmsprop(),
	metrics = c('mae')
)

history <- model %>% fit(
	as.matrix(dTrain[,1:13]), dTrain$dist, 
	epochs = 10, batch_size = 128,
	validation_split = 0.2
)

dVal$predNN <- model %>% predict_on_batch(as.matrix(dVal[,1:13]))



# -------------------------------------
# Resultados e Graficos
# -------------------------------------
# nro breaks vs media da distancia
meanDistBp <- aggregate(dVal$pred, list(dVal$qtdBp), mean)
meanDistBpNN <- aggregate(dVal$predNN, list(dVal$qtdBp), mean)
meanGreedy <- aggregate(dVal$dGreedy, list(dVal$qtdBp), mean)
meanSimple <- aggregate(dVal$dSimple, list(dVal$qtdBp), mean)
meanReal <- aggregate(dVal$dist, list(dVal$qtdBp), mean)

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

ggplot(plot, aes(xValue, yValue, colour = Abordagem)) +
	geom_line(aes(linetype=line), lwd = .7, position = position_jitter(w=0.02, h=0)) +
	facet_grid(.~flag, scales = "free") +
	guides(linetype=FALSE) +
	theme_light() +
	labs(x="", y="Média da distância") + 
	scale_color_manual(values=c("#6a5acd","#b4b4b4","#b4b4b4","#ff9900","#54ccfb","#24633e","#ff3300"))
