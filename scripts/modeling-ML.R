library(magrittr)
library(data.table)

set.seed(1)
# nao esquecer de mudar o path e fazer unzip nos arquivos necessarios

# -------------------------------------
# Leitura dos daddos
# -------------------------------------
# define caminho para os dados
data_path <- "/Users/almeida/Downloads/"

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

meanDistBp <- aggregate(dVal$pred, list(dVal$qtdBp), mean)
plot(meanDistBp$Group.1, meanDistBp$x, type = "l", ylim = c(min(meanDistBp$Group.1), max(meanDistBp$Group.1)), xlab = "breakpoint", ylab = "Media da distancia", lwd = 1.5)
lines(meanDistBp$Group.1, meanDistBp$Group.1, lty = 2, lwd = 1.5, col = "gray")
lines(meanDistBp$Group.1, meanDistBp$Group.1/2, lty = 2, lwd = 1.5, col = "gray")

meanGreedy <- aggregate(dVal$dGreedy, list(dVal$qtdBp), mean)
lines(meanGreedy$Group.1, meanGreedy$x, col = "blue", lwd = 1.5)
meanSimple <- aggregate(dVal$dSimple, list(dVal$qtdBp), mean)
lines(meanSimple$Group.1, meanSimple$x, col = "orange", lwd = 1.5)

meanReal <- aggregate(dVal$dist, list(dVal$qtdBp), mean)
lines(meanReal$Group.1, meanReal$x, col = rgb(1,0,0,0.7), lwd = 1.5)
