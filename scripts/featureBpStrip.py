

import numpy as np


def featureBpStrip(p):
	
	adj = 1
	sCresc = 0
	sDecresc = 0
	size_strip = []
	bp = 0
	
	# introduz os elementos 0 e n+1 na permutacao
	p = [0,] + p + [len(p)+1]
	
	# percorre a permutadao extendida procurando pelos bps
	for i in range(0,len(p)-1):


		# strips crescentes
		if(p[i+1] - p[i] == 1):
			adj = adj + 1

			# Conta quantas strips crescentes tem
			if(adj == 2):
				sCresc = sCresc + 1

			# Se for a ultima iteracao, armazena o tamanho da strip
			if(i == len(p) - 2):
				size_strip.append(adj)

		# strips decrescentes
		elif(p[i+1] - p[i] == -1):
			adj = adj + 1

			# Conta quantas strips decrescentes tem
			if(adj == 2):
				sDecresc = sDecresc + 1

			# Se for a ultima iteracao, armazena o tamanho da strip
			if(i == len(p) - 2):
				size_strip.append(adj)

		# se nao for adjacente
		else:
			# incrementamos o numero de breakpoints
			bp = bp + 1

			# se passou por alguma strip, armazena o tamanho dela
			if(adj != 1):
				size_strip.append(adj)
				adj = 1
	
	# armazena a quantidade de strips unitarias (que sao decrescentes)
	for j in range(len(p)-np.sum(size_strip)):
		size_strip.append(1)
		sDecresc = sDecresc + 1

	return bp, size_strip, sCresc, sDecresc



# exemplos para teste

#print featureBpStrip([1, 2, 3, 5, 6, 4])
# 0, 1, 2, 3, 5, 6, 4, 7
# bp = 3
# Tamanhos = 4, 2
# strips = 4
# Crescentes = 2
# Decrescentes = 2

#print featureBpStrip([2, 3, 1, 5, 6, 4])
# 0, 2, 3, 1, 5, 6, 4, 7
# bp = 5
# Tamanhos = 2, 2, 1, 1, 1, 1
# strips = 6
# Crescentes = 2
# Decrescentes = 4

#print featureBpStrip([1, 2, 3, 4, 5, 7, 6, 8, 9, 11 ,13, 10, 12])
# 0, 1, 2, 3, 4, 5, 7, 6, 8, 9, 11 ,13, 10, 12, 13
# bp = 7
# Tamanhos = 6, 2, 2, 1, 1, 1, 1, 1
# strips = 8
# Crescentes = 2
# Decrescentes = 6







