# Sequência de Passos para Adicionar um Projeto como Branch no Repositório Alpha

## Cenário:
- Repositório principal: `alfa` (já criado no GitHub)
- Projeto a ser adicionado: `proj01` (em uma pasta local)
- Branch destino: `proj01` (mesmo nome do projeto)

## Pré-requisitos:
- Git instalado
- Acesso ao repositório `alfa` no GitHub
- Projeto `proj01` em uma pasta local (pode estar dentro ou fora da pasta `alfa`)

---

## Método 1: Projeto **FORA** da pasta alfa (recomendado)

```bash
# 1. Navegue até a pasta do projeto
cd caminho/para/proj01

# 2. Inicialize o repositório Git (se não estiver)
git init

# 3. Adicione o repositório alfa como remote
git remote add origin https://github.com/rjhalmeman/alfa.git

# 4. Crie e mude para a nova branch
git checkout -b proj01

# 5. Adicione os arquivos
git add .

# 6. Commit inicial
git commit -m "Initial commit for proj01"

# 7. Envie para o GitHub
git push -u origin proj01
