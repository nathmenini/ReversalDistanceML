import createPermutation
import featureBpStrip
import time
import progressbar

def getInputs(p):
	
	# vator para armazenar as caracteristicas
	features = np.zeros((1,5))

	# vetor para identificar o tamanho de cada permutacao
	labels = np.zeros((1,1))
	lengths = range(5,11)
	
	bar = progressbar.ProgressBar()
	for i in bar(range(len(p))):
		pi = p[i]
		features = np.vstack((features, np.apply_along_axis(featureBpStrip, 1,  sPerms[i])))
		labels = np.vstack((labels, np.reshape(np.repeat(lengths[i], pi.shape[0]),(pi.shape[0],1))))

	features = np.delete(features, 0, 0)
	labels = np.delete(labels, 0, 0)
	features = np.hstack((features, labels))
	
	return features


