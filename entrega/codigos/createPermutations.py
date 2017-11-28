# bibliotecas
import itertools
import numpy as np

def makePermutations():
	# armazena todas as permutacoes possiveis de tamanho 5,6,...,10.
	perms = []

	# para cada tamanho possivel de permutacao, obtem todas as possibilidades
	for size in range(5,11):
		pi = range(1, size + 1)
		perms.append(np.array(list(itertools.permutations(pi))))

	# Amostra 30 porcento do total de permutacoes possivel de cada tamanho de permutacao
	# Se ficar muito pesado calcular o exato pelo site, podemos diminuir a quantidade
	# Tamanho 	#Total Perm 	#Amostra
	#	5			5!				36		
	#	6			6!				216
	#	7			7!				1512
	#	8			8!				12096
	#	9			9!				108864
	#	10			10!				1088640
	#
	s_perms = [] # armazena as amostras
	p = 0.3

	np.random.seed(1) # seed para reprodutibilidade do random abaixo
	for i in range(len(perms)):
		index = np.random.choice(range(perms[i].shape[0]), size=int(perms[i].shape[0]*p), replace=False)
		s_perms.append(perms[i][index,:])

	return perms, s_perms