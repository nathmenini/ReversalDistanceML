import numpy as np
import progressbar
from createPermutations import makePermutations
from featureBpStrip import featureBpStrip
from countCycles import countCycles


def getInputs(p):
	# vetor para armazenar as caracteristicas
	features = np.zeros((1,5))
	
	# vetor para identificar o tamanho de cada permutacao
	labels = np.zeros((1,1))
	lengths = range(5,11)
	
	bar = progressbar.ProgressBar()
	for i in bar(range(len(p))):
		pi = p[i]
		features = np.vstack((features, np.apply_along_axis(featureBpStrip, 1,  pi))) # linhas da matriz com as features
		labels = np.vstack((labels, np.reshape(np.repeat(lengths[i], pi.shape[0]),(pi.shape[0],1)))) # linhas com o tamanho da permutacao
	
	features = np.delete(features, 0, 0)
	labels = np.delete(labels, 0, 0)


	#cycles_total_odd = countCycles(p)

	features = np.hstack((features, labels)) # junta as colunas

	return features

#
#_, s_perms = makePermutations()
#getInputs(s_perms)