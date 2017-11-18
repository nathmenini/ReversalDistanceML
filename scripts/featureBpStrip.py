import numpy as np

def featureBpStrip(p):	
	p = list(p)
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
	for j in range(int(len(p)-np.sum(size_strip))):
		size_strip.append(1)
		sDecresc = sDecresc + 1

	# encontra o tamanho da menor strip que nao seja a strip unitaria
	sortedStrip = sorted(set(size_strip))
	minStrip = sortedStrip[0]

	# se a menor for a unitaria, substitui pela segunda menor
	if(minStrip == 1 & len(sortedStrip) > 1):
		minStrip = sortedStrip[1]

	# quantidade de strips unitarias
	unitStrip = (np.asarray(size_strip) == 1).sum()

	return bp, unitStrip, minStrip, np.max(size_strip), sCresc, sDecresc
