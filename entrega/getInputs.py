import numpy as np
import progressbar
from createPermutations import makePermutations
from featureBpStrip import featureBpStrip
from countCycles import countCycles
from simpleReversalSort import SimpleReversalSort
from greedySortingByReversal import improvedBreakpointReversalSort

# If function=1: Get permutations features
# If function=2: Get reversal distance using Simple Reversal Sort
# If function=3: Get reversal distance using Greedy Reversal Sort

def getInputs(p, function, inputs):
	
	# vetor para armazenar as caracteristicas
	if(function == 2 or function == 3):
		features = np.zeros((1,1))	
	else:
		features = np.zeros((1,6))
	
	# vetor para identificar o tamanho de cada permutacao
	labels = np.zeros((1,1))

	if(inputs == 1):
		lengths = range(5,11)
	elif(inputs == 2):
		lengths = [11, 20, 30, 40, 50, 60, 70, 80, 90, 100]

	bar = progressbar.ProgressBar()
	for i in bar(range(len(p))):
		pi = p[i]
		
		if(function == 1):
			features = np.vstack((features, np.apply_along_axis(featureBpStrip, 1,  pi))) # linhas da matriz com as features
		
		elif(function == 2):
			features = np.vstack((features, np.apply_along_axis(SimpleReversalSort, 1, pi))) # linhas da matriz com as features
		
		elif(function == 3):
			features = np.vstack((features, np.apply_along_axis(improvedBreakpointReversalSort, 1, pi)))


		labels = np.vstack((labels, np.reshape(np.repeat(lengths[i], pi.shape[0]),(pi.shape[0],1)))) # linhas com o tamanho da permutacao
	
	features = np.delete(features, 0, 0)
	labels = np.delete(labels, 0, 0)

	if(function == 2 or function == 3):
		features = np.hstack((features, labels))
	else:
		cycles_total_odd = countCycles(p)
		features = np.hstack((features, cycles_total_odd, labels))
		

	# junta as colunas
	

	return features
