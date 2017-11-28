import networkx as nx
import numpy as np
import progressbar

# countCycles
# This function creates an alternate graph por a permutation without genes orientation.
# Returns a list were each element contains features for each permutation in the following form:
#
# [[total, odd_cycles, unit_cycles, largest_cycle, smallest_cycle, oriented_cycles], ..., ...]
#
# Features: Total cycles, Number of unitary cycles, Size of the largest cycle, Size of the smallest cycle,
# and Number of oriented cycles.
#
# Implemented by SERZA (Sergio Zumpano Arnosti)

# test: 
# permutations = [[[3, 1, 4, 5, 2],[5, 2, 1, 4, 3]],[[3, 1, 4, 5, 2, 6],[6, 5, 2, 1, 4, 3]], [[8, 5, 1, 4, 3, 2, 7, 6],[1, 2, 3, 4, 5, 6, 7, 8]]]


def countCycles(permutations):

	cycles = []
	G=nx.DiGraph()
	bar = progressbar.ProgressBar()

	for i in bar(permutations):
		for j in i:
			G.clear()
			c_list=[]
			odd_cycles=0
			unit_cycles=0
			largest_cycle=0
			smallest_cycle=len(j)+1;
			oriented_cycles=0
			total=0
			
			# create first and last pseudo nodes + black edges
			G.add_edge(-1*j[0], 0)
			G.add_edge(-1*(len(j)+1), j[len(j)-1])
			nx.set_edge_attributes(G, {(-1*j[0], 0): {'color': 'black', 'id': 1},
								  (-1*(len(j)+1), j[len(j)-1]):{'color': 'black', 'id': len(j)+1}})

			# create black edges
			for b in range(0,len(j)-1):		
				G.add_edge(-1*(j[b+1]), j[b])
				nx.set_edge_attributes(G, {(-1*(j[b+1]), j[b]): {'color': 'black', 'id': b+2}})
		
			# create gray edges
			for g in range(1,len(j)+2):
				G.add_edge((g-1), -1*g, color='gray')
				nx.set_edge_attributes(G, {((g-1), -1*g): {'color': 'gray', 'id': -1}})	
				
			c_list = list(nx.simple_cycles(G))
			total = len(c_list);

			# calculate number of odd cycles
			for c in range(0, len(c_list)):
				black_edges=0
				highest_id=0

				# verify if the edge between two elements in cycle is black
				for index in range(0, len(c_list[c])-1):
					if(G[c_list[c][index]][c_list[c][index+1]]['color'] == 'black'):
						black_edges = black_edges + 1

						# verify the highest black edge id to start the cycle
						if(int(G[c_list[c][index]][c_list[c][index+1]]['id']) > highest_id):
							highest_id = int(G[c_list[c][index]][c_list[c][index+1]]['id'])
							start_node = c_list[c][index]

				if(G[c_list[c][len(c_list[c])-1]][c_list[c][0]]['color'] == 'black'):
					black_edges = black_edges + 1
					if(int(G[c_list[c][len(c_list[c])-1]][c_list[c][0]]['id']) > highest_id):
						highest_id = int(G[c_list[c][len(c_list[c])-1]][c_list[c][0]]['id'])
						start_node = c_list[c][len(c_list[c])-1]

				# calculate number of oriented cycles
				edg_list = list(nx.find_cycle(G, start_node, orientation='original'))
				edg_ids = nx.get_edge_attributes(G, 'id')
				edg_colors = nx.get_edge_attributes(G, 'color')
				previous=edg_ids[edg_list[0]]

				# Find oriented cycles
				for e in edg_list:
					if(edg_colors[e] == 'black' and int(edg_ids[e]) < previous):
						previous = edg_ids[e]
					elif(edg_colors[e] == 'black' and int(edg_ids[e]) > previous): 
						oriented_cycles = oriented_cycles +1;
						break

				#print(oriented_cycles)
				#print(edg_list)

				# size of largest cycle disregarding unitary cycles
				if(largest_cycle < black_edges and black_edges != 1):
					largest_cycle = black_edges

				# size of smallest cycle disregarding unitary cycles
				if(smallest_cycle > black_edges and black_edges != 1):
					smallest_cycle = black_edges

				# if number of black edges is one, it is an unitary cicle
				if(black_edges == 1):
					unit_cycles = unit_cycles +1

				# if number of black edges is odd, this is a odd cycle
				if(black_edges%2 != 0):
					odd_cycles = odd_cycles + 1

			# if there is only unitary cycles, use the size 1 for largest and smallest
			if(unit_cycles == len(j)+1):
				largest_cycle=1
				smallest_cycle=1

			cycles.append([total, odd_cycles, unit_cycles, largest_cycle, smallest_cycle, oriented_cycles])

	
	list_to_array = np.asarray(cycles)

	return list_to_array
			

	

