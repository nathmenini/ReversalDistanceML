import numpy as np
import progressbar
from simpleReversalSort import SimpleReversalSort
from greedySortingByReversal import improvedBreakpointReversalSort

# Modificado para calcular para outros algoritmos
# 1- SimpleReversalSort - algoritmo ingenuo de reversao

# retorno [numero de reversoes, tamanho da permutacao]

def getInputsModified(p):
	# vetor para armazenar as caracteristicas
	features = np.zeros((1,1))
	
	# vetor para identificar o tamanho de cada permutacao
	labels = np.zeros((1,1))
	lengths = range(5,11)

	bar = progressbar.ProgressBar()
	for i in bar(range(len(p))):
		pi = p[i]
		#features = np.vstack((features, np.apply_along_axis(SimpleReversalSort, 1, pi))) # linhas da matriz com as features
		features = np.vstack((features, np.apply_along_axis(improvedBreakpointReversalSort, 1, pi)))
		labels = np.vstack((labels, np.reshape(np.repeat(lengths[i], pi.shape[0]),(pi.shape[0],1)))) # linhas com o tamanho da permutacao
	
	features = np.delete(features, 0, 0)
	labels = np.delete(labels, 0, 0)

	features = np.hstack((features, labels)) # junta as colunas

	return features