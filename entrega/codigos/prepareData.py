import numpy as np
import progressbar
from getInputs import getInputs

print("\nQuais arquivos deseja usar como entrada ?\n")
print("1: Permutacoes de (5,6,7,8,9,10)\n")
print("2: Permutacoes de (11, 20, 30, ..., 100)\n")
entrada = int(input("Opcao: "))

while(entrada!=1 and entrada!=2):
	print("Opcao invalida... :( \n")
	funcao = int(input("Opcao: "))

if(entrada == 1):
	fileNames = ['perm_5.txt', 'perm_6.txt', 'perm_7.txt', 'perm_8.txt', 'perm_9.txt', 'perm_10.txt']
elif(entrada == 2):
	fileNames = ['perm_11.txt', 'perm_20.txt', 'perm_30.txt', 'perm_40.txt', 'perm_50.txt', 'perm_60.txt', 'perm_70.txt', 'perm_80.txt', 'perm_90.txt', 'perm_100.txt']

perms = []
dist = []

# get de permutation in the files
print("\nReading Files...")
bar = progressbar.ProgressBar()
for i in bar(range(len(fileNames))):
	p = np.loadtxt(fileNames[i], delimiter = " ")
	if(entrada == 1):
		perms.append(p[:,:-1])
		dist = np.hstack((dist, p[:,p.shape[1]-1]))
	elif(entrada == 2):
		perms.append(p)

print("\nQual funcao deseja executar ?\n")
print("1: Pegar features para permutacoes\n")
print("2: Pegar distancias de reversao usando Simple Reversal Sort\n")
print("3: Pegar distancias de reversao usando Greedy Reversal Sort\n")
funcao = int(input("Opcao: "))

while(funcao!=1 and funcao!=2 and funcao!=3):
	print("Opcao invalida... :( \n")
	funcao = int(input("Opcao: "))

# salva as features para as permutacoes
if(funcao == 1):
	print("\nCalculating features...")
	features = getInputs(perms, funcao, entrada)
	arquivo = open('features.txt', 'w+')
	np.savetxt('./features.txt', features, fmt='%d')
	arquivo.close()

elif(funcao == 2):
	print("\nCalculating distances using SRS...")
	features = getInputs(perms, funcao, entrada)
	arquivo = open('SRS.txt', 'w+')
	np.savetxt('./SRS.txt', features, fmt='%d')
	arquivo.close()

elif(funcao == 3):
	print("\nCalculating distances using GRS...")
	features = getInputs(perms, funcao, entrada)
	arquivo = open('GRS.txt', 'w+')
	np.savetxt('./GRS.txt', features, fmt='%d')
	arquivo.close()

# salva as distancias exatas
#np.savetxt('dist.txt', dist, fmt='%d')