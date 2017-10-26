

import numpy as np


def numberBp(p):
	
	adj = 0
	index = []
	count_strip = 0
	i_count = 0
	size_strip = []
	
	# introduz os elementos 0 e n+1 na permutacao
	p = [0,] + p + [len(p)+1]
	
	# percorre a permutadao extendida procurando pelos bps
	for i in range(0,len(p)-1):

		# elementos que sao adjacentes
		if(np.abs(p[i+1] - p[i]) == 1):

			# numero de elementos totais que sao adjacentes
			adj = adj + 1

			# conta a quantidade de elementos na strip
			i_count = i_count + 1

			# caso seja o primeiro elemento da strip, armazena a posicao
			if(i_count == 1):
				index.append(i)

		# se nao for adjacente
		else:
			# se tiver passado por alguma strip, contabiliza o seu tamanho
			if(i_count != 0):
				# armazena aonde termina a strip
				index.append(i)

				# o tamanho final da strip
				size_strip.append(i_count+1)

				# zera o tamanho da strip, para utilizar em uma outra
				i_count = 0

		# se for a ultima iteracao e estivermos em uma strip
		if((i == len(p) - 2) & (i_count != 0)):
			index.append(i)
			size_strip.append(i_count)

		# conta a quantidade de breakpoints
		bp = len(p) - 1 - adj
	
	return bp, np.min(size_strip), np.max(size_strip)



# exemplos para teste

#print numberBp([1, 2, 3, 5, 6, 4])

#print numberBp([2, 3, 1, 5, 6, 4])

#print numberBp([1,2,3,4,5,7,6,8,9,11,13,10,12])







