import networkx as nx
import numpy as np
import progressbar

# algoritmo ingenuo

def SimpleReversalSort(pi):

	count=0
	pi = pi.tolist()

	for i in range(len(pi)):
		j=pi.index(min(pi[i:]))
		if(j != i):
			pi = pi[:i] + [v for v in reversed(pi[i:j+1])] + pi[j+1:]
			count=count+1
			#print("rho(%d,%d) = %s" % (i, j, pi))

	return count,