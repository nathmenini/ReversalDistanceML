from selenium import webdriver
import createPermutations
import re
import time
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException

def execute():

    #Obtem ref ao Firefox
    driver = webdriver.Firefox()
    driver.get("http://mirza.ic.unicamp.br:8080/bioinfo/index.jsf") #configura url destino
    assert "Bioinfo" in driver.title #certifica que esta na pagina correta
    assert "No results found." not in driver.page_source #valida acesso a pagina
    
    perm, s_perms = createPermutations.makePermutations()
    
    #HashMap com o resultado no formato -> [permutacao(key), numero de reversoes(valor)]
    resultHash = {}
    
    for i in s_perms:
        for j in i:
                
                time.sleep(0.6)
                
                #Configura permutacao
                permutacao = ' '.join(str(e) for e in j)

                #Obtem referencia ao campo texto para entrada da permutacao
                elem_text_field = WebDriverWait(driver, 2).until(EC.presence_of_element_located((By.NAME, "search_distance_form:permutation_input")))
                #elem_text_field = driver.find_element_by_name("search_distance_form:permutation_input")
                #Limpa o campo para nova entrada
                elem_text_field.clear()
                #Insere a nova permutacao obtida de s_perms
                elem_text_field.send_keys(permutacao)
                
                time.sleep(0.6)
                
                #Efetua click no botao 'search' da pagina
                elem_search_button = WebDriverWait(driver, 2).until(EC.presence_of_element_located((By.ID, "search_distance_form:j_id38")))
                elem_search_button.click()
                #elem_search_button = driver.find_element_by_id("search_distance_form:j_id38").click()
                
                time.sleep(0.6)
                #driver.implicitly_wait(10) # seconds 
                #driver.refresh();
                #Obtem referencia ao elemento da pagina que contem o texto com o numero de reversoes para a permutacao
                elem_result = WebDriverWait(driver, 2).until(EC.presence_of_element_located((By.CLASS_NAME, "generalStyle")))
                #elem_search_button = driver.find_element_by_class_name("generalStyle")
                
                #Faz um parser do texto para obter o numero de reversoes
                value = re.search("is (\d+)", elem_result.text, re.IGNORECASE).group(1);
                
                #salva no hash resultante
                resultHash[permutacao] = value
                
    return resultHash;
