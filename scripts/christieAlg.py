import networkx as nx
import numpy as np
import progressbar

def cycleGraph(G, j):

	D = nx.Graph()
	black_edges = 0

	for b in range(0, len(j)-1):
		if(abs(j[b]-j[b+1]) != 1):
			G.add_edge(j[b], j[b+1])
			nx.set_edge_attributes(G, {(j[b], j[b+1]): {'color': 'black'}})
			black_edges = black_edges + 1;
		else:
			G.add_edge(j[b], j[b+1])
			nx.set_edge_attributes(G, {(j[b], j[b+1]): {'color': 'none'}})

	for g in range(0,len(j)-1):
		if(G.has_edge(g, g+1) == False):
			G.add_edge(g, g+1)
			nx.set_edge_attributes(G, {(g, g+1): {'color': 'gray'}})
		elif((G.has_edge(g, g+1) == True) and (G[g][g+1]['color'] == 'none')):
			G.remove_edge(g,g+1)

	#c_list = list(nx.find_cycle(G))
	

	return black_edges


def christieAlg(permutations):

	G = nx.Graph()
	R = nx.Graph()
	#bar=progressbar.ProgressBar()

	
	for perms in permutations:
		for p in perms:

			black_edges = 0

			# building a cycle graph
			black_edges = cycleGraph(G, p)

			# building a reversal graph
			for e in G.edges():
				attr = G.get_edge_data(*e) 
				if(attr['color'] == 'gray'):
					R.add_node(e[0])

	
						#temp = [:] + reversed()



	#print(R.nodes(data=True))
	#print(G.edges(5))
	#print(G.edges(6))
	#print(G.edges(3))
	#print(G.edges(2))








