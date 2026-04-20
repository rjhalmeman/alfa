# Guia Definitivo: Hospedando Arquivos HTML Estáticos em uma VPS

Quando trabalhamos com **aplicações backend** (como Node.js), elas próprias "levantam" um servidor que escuta uma porta específica. Porém, projetos simples baseados apenas em HTML, CSS e JavaScript (como o seu somador) são **arquivos estáticos**. Eles não têm um "motor" próprio e precisam de um **servidor web** para enviá-los ao navegador de quem acessa.

Além disso, ao executar um comando diretamente no terminal da VPS, o programa fica "amarrado" à sua **sessão do terminal**. Se você fechar a aba do navegador ou a conexão cair, o sistema operacional encerra a sessão e "mata" todos os processos associados. 

Para resolver isso e deixar seu projeto rodando em **segundo plano** (background) de forma contínua, utilizamos um **gerenciador de processos** chamado **PM2**.

Abaixo, o passo a passo completo de como configurar isso.

---

## Passo 1: Liberar a porta no Firewall

Antes de iniciar o servidor, precisamos garantir que a "porta" de comunicação esteja aberta na sua VPS para receber visitantes externos. Vamos utilizar a porta `3002`.

No seu terminal, execute o comando do firewall (UFW) do Linux:

```bash
sudo ufw allow 3002/tcp
```
*(Nota: Certifique-se também de que não há bloqueios de segurança adicionais no painel de controle da Hostinger).*

## Passo 2: Acessar a pasta do projeto

Navegue até o diretório exato onde o seu arquivo `index.html` está salvo:

```bash
cd /root/rdms/somar
```

## Passo 3: Instalar o Gerenciador de Processos (PM2)

O **PM2** é uma ferramenta robusta do ecossistema Node.js que mantém suas aplicações vivas para sempre. Você precisará instalá-lo globalmente na sua máquina (só é necessário fazer isso uma vez na VPS):

```bash
npm install -g pm2
```

## Passo 4: Iniciar o Servidor Estático com PM2

O PM2 possui uma função nativa excelente para servir diretórios estáticos, sem precisar de outras ferramentas. Certifique-se de estar dentro da pasta do projeto e execute:

```bash
pm2 serve . 3002 --name "somador"
```

**Entendendo o comando:**
* `serve`: Diz ao PM2 para atuar como um servidor web simples.
* `.`: Indica que a pasta a ser servida é o diretório em que você está no momento.
* `3002`: É a porta que definimos para este projeto (evitando conflito com a porta 3001).
* `--name "somador"`: Dá um nome amigável para você identificar facilmente o processo na lista.

**Pronto!** A partir deste momento, você verá uma tabela verde no terminal. Você já pode fechar a janela da Hostinger e o seu projeto continuará online e acessível.

---

## Passo 5: Gerenciando o PM2 no dia a dia

Como o PM2 fica invisível rodando em segundo plano, você precisará usar alguns comandos no terminal para administrar seus projetos:

* **Ver tudo que está rodando:** Lista todos os aplicativos gerenciados.
  ```bash
  pm2 status
  ```
* **Parar a aplicação:** Desliga temporariamente o seu site.
  ```bash
  pm2 stop somador
  ```
* **Reiniciar a aplicação:** Muito útil quando você faz alguma alteração ou atualização nos arquivos HTML.
  ```bash
  pm2 restart somador
  ```
* **Acompanhar erros (Logs):** Mostra o que está acontecendo por trás das cortinas.
  ```bash
  pm2 logs somador
  ```

## Passo 6: Garantir que o PM2 inicie com o sistema (Recomendado)

Se a sua VPS reiniciar por conta de uma manutenção da Hostinger ou queda de servidor, o PM2 voltará desligado. Para fazer com que ele ligue automaticamente junto com o Linux e restaure os seus sites, execute:

1. **Salvar a lista atual:** Grava na memória os projetos que estão rodando agora.
   ```bash
   pm2 save
   ```
2. **Configurar a inicialização automática:**
   ```bash
   pm2 startup
   ```
   *(Atenção: Ao rodar este último comando, o PM2 irá gerar uma linha de código na tela. Para concluir, você precisa copiar essa linha sugerida por ele e colar no terminal, apertando Enter).*
