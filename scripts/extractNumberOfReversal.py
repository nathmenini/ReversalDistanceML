from selenium import webdriver
import createPermutations
import re

def execute():

    #Obtem ref ao Firefox
    driver = webdriver.Firefox()
    driver.get("http://mirza.ic.unicamp.br:8080/bioinfo/index.jsf") #configura url destino
    assert "Bioinfo" in driver.title #certifica que esta na pagina correta
    assert "No results found." not in driver.page_source #valida acesso a pagina
    
    #s_perms = [[[3, 1, 4, 5, 2],[5, 2, 1, 4, 3]],[[3, 1, 4, 5, 2, 6],[6, 5, 2, 1, 4, 3]], [[8, 5, 1, 4, 3, 2, 7, 6]]]
    s_perms = createPermutations.makePermutations()
    
    #HashMap com o resultado no formato -> [permutacao(key), numero de reversoes(valor)]
    resultHash = {}
    
    for i in s_perms:
        for j in i:
            for k in j:
                
                #Configura permutacao
                permutacao = ' '.join(str(e) for e in k)
                
                #Obtem referencia ao campo texto para entrada da permutacao
                elem_text_field = driver.find_element_by_name("search_distance_form:permutation_input")
                #Limpa o campo para nova entrada
                elem_text_field.clear()
                #Insere a nova permutacao obtida de s_perms
                elem_text_field.send_keys(permutacao)
                
                #Efetua click no botao 'search' da pagina
                elem_search_button = driver.find_element_by_id("search_distance_form:j_id38").click()
                
                #Obtem referencia ao elemento da pagina que contem o texto com o numero de reversoes para a permutacao
                elem_search_button = driver.find_element_by_class_name("generalStyle")
                
                #Faz um parser do texto para obter o numero de reversoes
                value = re.search("is (\d+)", elem_search_button.text, re.IGNORECASE).group(1);
                
                #salva no hash resultante
                resultHash[permutacao] = value
                
    return resultHash;