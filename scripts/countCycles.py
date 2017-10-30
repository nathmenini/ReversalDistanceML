
import networkx as nx

# test permutatios
#permutations = [[[3, 1, 4, 5, 2],[5, 2, 1, 4, 3]],[[3, 1, 4, 5, 2, 6],[6, 5, 2, 1, 4, 3]], [[8, 5, 1, 4, 3, 2, 7, 6]]]
#permutations = [[[3, 1, 4, 5, 2],[5, 2, 1, 4, 3]],[[3, 1, 4, 5, 2, 6],[6, 5, 2, 1, 4, 3]], [[8, 5, 1, 4, 3, 2, 7, 6],[1, 2, 3, 4, 5, 6, 7, 8]]]


def countCycles(permutations):

	#cycles - for each permutation calculates total number of cycles and odd cycles 
	#cycles = [[total, odd], [total, odd], ...]
	cycles = []
	G=nx.DiGraph()

	for i in permutations:
		for j in i:
			G.clear()
			c_list=[]
			odd_cycles=0
			total=0
			
			# create first and last pseudo nodes + black edges
			G.add_edge(-1*j[0], 0, color='black')
			G.add_edge(-1*(len(j)+1), j[len(j)-1], color='black')
		
			# create black edges
			for b in range(0,len(j)-1):		
					G.add_edge(-1*(j[b+1]), j[b], color='black')
		
			# create gray edges
			for g in range(1,len(j)+2):
				G.add_edge((g-1), -1*g, color='gray')		
				
			c_list = list(nx.simple_cycles(G))
			total = len(c_list);

			# calculate number of odd cycles
			for c in range(0, len(c_list)):
				black_edges=0

				# verify if the edge among two elements in cycle is black
				for index in range(0, len(c_list[c])-1):
					#if(index!=len(c_list[c])-1):
					if(G[c_list[c][index]][c_list[c][index+1]]['color'] == 'black'):
						black_edges = black_edges + 1
					
				if(G[c_list[c][len(c_list[c])-1]][c_list[c][0]]['color'] == 'black'):
					black_edges = black_edges + 1

				# if number of black edges is odd, this is a odd cycle
				if(black_edges%2 != 0):
					odd_cycles = odd_cycles + 1

			cycles.append([total, odd_cycles])

	return cycles
			

	

