#!/bin/bash

# Script: juntar.sh
# Uso: ./juntar.sh extensao1 extensao2 extensao3 ...
# Exemplo: ./juntar.sh html css js

ARQUIVO_SAIDA="codigo.txt"
SEPARADOR_LINHAS=3

# Função para exibir ajuda
mostrar_ajuda() {
    echo "Uso: $0 extensao1 extensao2 extensao3 ..."
    echo "Exemplo: $0 html css js"
    echo "Exemplo: $0 txt md"
    echo ""
    echo "O script agrupa arquivos pelo nome base e adiciona 3 linhas de separação"
    exit 1
}

# Verifica se foram passados parâmetros
if [ $# -eq 0 ]; then
    mostrar_ajuda
fi

# Array com as extensões
EXTENSOES=("$@")

# Função para adicionar separador
adicionar_separador() {
    for i in $(seq 1 $SEPARADOR_LINHAS); do
        echo "" >> "$ARQUIVO_SAIDA"
    done
}

# Função para processar um grupo de arquivos (mesmo nome base)
processar_grupo() {
    local nome_base=$1
    local arquivos_processados=()
    
    
    printf "  ARQUIVO: %-56s \n" "$nome_base" >> "$ARQUIVO_SAIDA"
   
    # Processa cada extensão na ordem fornecida
    for extensao in "${EXTENSOES[@]}"; do
        arquivo="${nome_base}.${extensao}"
        
        if [ -f "$arquivo" ]; then
            arquivos_processados+=("$arquivo")
            
            # Cabeçalho do arquivo
            echo " Arquivo: $arquivo " >> "$ARQUIVO_SAIDA"
         
            
            # Conteúdo do arquivo
            cat "$arquivo" >> "$ARQUIVO_SAIDA"
            
            # Adiciona linha em branco após o conteúdo
            echo "" >> "$ARQUIVO_SAIDA"
            echo "" >> "$ARQUIVO_SAIDA"            
           
            echo "✓ Fim do arquivo: $arquivo" >> "$ARQUIVO_SAIDA"
            adicionar_separador
        fi
    done
    
    # Se nenhum arquivo do grupo foi encontrado
    if [ ${#arquivos_processados[@]} -eq 0 ]; then
        echo "⚠ Nenhum arquivo encontrado para o nome base: $nome_base com extensões ${EXTENSOES[*]}" >> "$ARQUIVO_SAIDA"
        adicionar_separador
    else
        echo "✓ Grupo $nome_base processado (${#arquivos_processados[@]} arquivos)" >> "$ARQUIVO_SAIDA"
        adicionar_separador
    fi
    
    echo "════════════════════════════════════════════════════════════════════" >> "$ARQUIVO_SAIDA"
    adicionar_separador
}

# Limpa o arquivo de saída
> "$ARQUIVO_SAIDA"


# Encontra todos os nomes base únicos
# Para cada extensão, extrai o nome base e cria um conjunto único
nomes_base=()

for extensao in "${EXTENSOES[@]}"; do
    for arquivo in *."$extensao"; do
        if [ -f "$arquivo" ]; then
            nome_base="${arquivo%.*}"
            # Adiciona ao array se ainda não existe
            if [[ ! " ${nomes_base[@]} " =~ " ${nome_base} " ]]; then
                nomes_base+=("$nome_base")
            fi
        fi
    done
done

# Ordena os nomes base
IFS=$'\n' sorted_nomes=($(sort <<<"${nomes_base[*]}"))
unset IFS

# Processa cada grupo pelo nome base
if [ ${#sorted_nomes[@]} -eq 0 ]; then
    echo "ERRO: Nenhum arquivo encontrado com as extensões especificadas!" >> "$ARQUIVO_SAIDA"
    echo "VERIFIQUE AS EXTENSÕES: ${EXTENSOES[*]}" >> "$ARQUIVO_SAIDA"
    echo ""
    echo "Arquivos encontrados no diretório atual:" >> "$ARQUIVO_SAIDA"
    ls -la >> "$ARQUIVO_SAIDA"
else
    for nome_base in "${sorted_nomes[@]}"; do
        processar_grupo "$nome_base"
    done
fi

echo "" >> "$ARQUIVO_SAIDA"
