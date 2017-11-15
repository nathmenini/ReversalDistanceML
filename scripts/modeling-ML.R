library(magrittr)
library(data.table)

# nao esquecer de mudar o path e fazer unzip nos arquivos necessarios

# -------------------------------------
# Leitura dos daddos
# -------------------------------------
# define caminho para os dados
data_path <- "/Users/almeida/Documents/GitHub/ReversalDistanceML/features/"

# leitura das features
data <- fread(paste0(data_path, "features.txt"))
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
				 "tamanhoPerm")

# leitura das distancias exatas
y <- fread(paste0(data_path, "dist.txt"))
names(y) <- "dist"



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
train <- data.frame(data[indexTrain,], y[indexTrain])
dTest <- data.frame(data[-indexTrain,], y[-indexTrain])

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
fit <- lm(dist ~ ., data = dTrain)
pred <- predict(fit, dVal[,-14])
dVal$ pred <- pred

boxplot(pred~dVal$dist, xlab = "true distance", ylab = "predicted distance")
table(dVal$dist, pred %>% round(0))

meanDistBp <- aggregate(dVal$pred, list(dVal$qtdBp), mean)
plot(meanDistBp$Group.1, meanDistBp$x, type = "l", ylim = c(min(meanDistBp$Group.1), max(meanDistBp$Group.1)), xlab = "breakpoint", ylab = "Media da distancia", lwd = 1.5)
lines(meanDistBp$Group.1, meanDistBp$Group.1, col = "red", lwd = 1.5)
lines(meanDistBp$Group.1, meanDistBp$Group.1/2, col="red", lwd = 1.5)
