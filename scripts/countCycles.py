
import networkx as nx

# test permutatios
#permutations = [[[3, 1, 4, 5, 2],[5, 2, 1, 4, 3]],[[3, 1, 4, 5, 2, 6],[6, 5, 2, 1, 4, 3]], [[8, 5, 1, 4, 3, 2, 7, 6]]]

def countCycles(permutations):

	#cycles - for each permutation calculates total number of cycles and odd cycles 
	#cycles = [[total, odd], [total, odd], ...]
	c_list = []
	cycles = []


	for i in permutations:
		G=nx.DiGraph()
		total_cycles=0


		for j in i:
			odd_cycles=0
			# create first and last pseudo nodes + black edges
			G.add_edge(-1*j[0], 0, color='black')
			G.add_edge(-1*(len(j)+1), j[len(j)-1], color='black')
		
			# create black edges
			for b in range(0,len(j)):
				if(b!=len(j)-1):		
					G.add_edge(-1*(j[b+1]), j[b], color='black')
		
			# create gray edges
			for g in range(1,len(j)+2):
				G.add_edge((g-1), -1*g, color='gray')		
				
			c_list = list(nx.simple_cycles(G))
			total = len(c_list);
			#print(total)

			# calculate number of odd cycles
			for c in range(0, len(c_list)):
				black_edges=0

				# verify if the edge among two elements in cycle is black
				for index in range(0, len(c_list[c])):
					if(index!=len(c_list[c])-1):
						if(G[c_list[c][index]][c_list[c][index+1]]['color'] == 'black'):
							black_edges = black_edges + 1
					else:
						if(G[c_list[c][index]][c_list[c][0]]['color'] == 'black'):
							black_edges = black_edges + 1

				# if number of black edges is odd, this is a odd cycle
				if(black_edges%2 != 0):
					odd_cycles = odd_cycles + 1

			cycles.append([total, odd_cycles])

	return cycles
			

	

