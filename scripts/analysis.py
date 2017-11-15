import numpy as np
import progressbar
from getInputs import getInputs

# Executar o algoritmo na pasta prepared-data descompactada
fileNames = ['perm_5.txt', 'perm_6.txt', 'perm_7.txt', 'perm_8.txt', 'perm_9.txt', 'perm_10.txt']

perms = []
dist = []

bar = progressbar.ProgressBar()
for i in bar(range(len(fileNames))):
	p = np.loadtxt(fileNames[i], delimiter = " ")
	perms.append(p[:,:-1])
	dist = np.hstack((dist, p[:,p.shape[1]-1]))

features = getInputs(perms)

# salva as features
np.savetxt('/home/serza/features.txt', features, fmt='%d')

# salva as distancias exatas
np.savetxt('dist.txt', dist, fmt='%d')