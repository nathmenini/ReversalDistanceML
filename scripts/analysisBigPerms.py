import numpy as np
import progressbar
from getInputs import getInputs
from getInputsModified import getInputsModified

# executar na pasta em que as perms grandes entao
# Executar o algoritmo na pasta prepared-data descompactada
fileNames = ['perm_11.txt', 'perm_20.txt', 'perm_30.txt', 'perm_40.txt', 'perm_50.txt', 'perm_60.txt', 'perm_70.txt', 'perm_80.txt', 'perm_90.txt', 'perm_100.txt']

perms = []

bar = progressbar.ProgressBar()
for i in bar(range(len(fileNames))):
	p = np.loadtxt(fileNames[i], delimiter = " ")
	perms.append(p)

#features2 = getInputs(perms)
features3 = getInputsModified(perms)

#np.savetxt('/home/serza/features2.txt', features2, fmt='%d')
np.savetxt('/home/serza/simpleSortBigPerms.txt', features3, fmt='%d')
