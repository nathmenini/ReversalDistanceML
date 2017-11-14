import numpy as np
import progressbar

# Executar o algoritmo na pasta prepared-data descompactada
fileNames = ['perm_5.txt', 'perm_6.txt', 'perm_7.txt', 'perm_8.txt', 'perm_9.txt', 'perm_10.txt']

perms = []

bar = progressbar.ProgressBar()
for i in bar(range(len(fileNames))):
	p = np.loadtxt(fileNames[i], delimiter = " ")
	perms.append(p)

# Executar o getInputs para o perms
