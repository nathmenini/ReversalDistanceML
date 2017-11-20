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

			# incrementamos a quantidade de strips unitarias
			if(adj == 1 and i != 0):
				sDecresc = sDecresc + 1
				size_strip.append(1)
			
			# se passou por alguma strip, armazena o tamanho dela
			if(adj != 1):
				size_strip.append(adj)
				adj = 1
	
	# armazena a quantidade de strips unitarias (que sao decrescentes)
	for j in range(int(len(p)-np.sum(size_strip))):
		size_strip.append(1)

	# encontra o tamanho da menor strip que nao seja a strip unitaria
	sortedStrip = sorted(set(size_strip)) # o set remove valores iguais
	minStrip = sortedStrip[0]

	# se a menor for a unitaria, substitui pela segunda menor
	if(minStrip == 1 and len(sortedStrip) > 1):
		minStrip = sortedStrip[1]

	# quantidade de strips unitarias
	unitStrip = (np.asarray(size_strip) == 1).sum()

	# verifica se os elementos da extensao ja estao em uma strip
	if(p[1] - p[0] != 1):
		sCresc = sCresc + 1
	if(p[len(p)-1] - p[len(p)-2] != 1):
		sCresc = sCresc + 1

	# soma 2 na sCresc por causa das strip unitarias da ponta da permutacao extendida
	return bp, unitStrip, minStrip, np.max(size_strip), sCresc, sDecresc

# bp: nro de breakpoints
# unitStrip: nro de strips unitarias
# minStrip: tamanho da menor strip que nao eh uma strip unitaria (se existir alguma nao unitaria)
# np.max(size_strip): tamanho da maior strip
# sCresc + 2: quantidade de strips crescentes
# sDecresc: quantidade de strips decrescentes

# exemplos para teste
#print featureBpStrip([5,3,1,2,4])
#print featureBpStrip([5,4,3,1,2])
#print featureBpStrip([2,5,1,3,4])
#print featureBpStrip([1,2,3,5,6,4])
#print featureBpStrip([2,3,1,5,6,4])
#print featureBpStrip([1,2,3,4,5,7,6,8,9,11,13,10,12])
