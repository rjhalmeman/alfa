# Tutorial: Acessar Servidor FTP Diretamente no VS Code

Este tutorial ensina como configurar o VS Code para editar arquivos do seu servidor FTP sem precisar do FileZilla.

---

## 📦 1. Instalar a Extensão

1. Abra o VS Code
2. Pressione `Ctrl+Shift+X` para abrir a aba de extensões
3. Pesquise por **"Remote File System"**
4. Clique em **Install**

---

## ⚙️ 2. Configurar o Servidor

### Abrir as Configurações

- **Atalho:** `Ctrl + ,` (vírgula)
- Ou pelo menu: **Arquivo > Preferências > Configurações**

### Editar o settings.json

1. Clique no ícone de **papel com seta** no canto superior direito (Open Settings JSON)
2. Adicione a configuração abaixo dentro do objeto `{}` existente:

```json
{
  "remotefs.remote": {
    "meu-site": {
      "scheme": "ftp",
      "host": "sol.pro.br",
      "username": "radhal",
      "password": "minhaSenha",
      "rootPath": "/sol.pro.br/orientacoes/",
      "port": 21
    }
  }
}
```

3. Pressione `Ctrl+S` para salvar

---

## 🔗 3. Conectar ao Servidor

1. Pressione `Ctrl+Shift+P` para abrir a Paleta de Comandos
2. Digite: **`Remote FS: Add Folder to Workspace`**
3. Selecione **`meu-site`**
4. A pasta do servidor aparecerá no Explorer do VS Code

---

## 💻 4. Abrir Diretamente pelo Terminal (opcional)

Se preferir abrir o VS Code já conectado ao servidor:

```bash
code --folder-uri ftp://meu-site/
```

---

## 🚀 5. Trabalhar com os Arquivos

- **Navegue** pelos arquivos no Explorer
- **Abra** qualquer arquivo clicando nele
- **Edite** normalmente
- **Salve** (`Ctrl+S`) e as alterações vão direto para o servidor

---

## 🔧 Solução de Problemas

| Problema | Solução |
|----------|---------|
| **Caminho incorreto** | Verifique no FileZilla o caminho exato da pasta do site e ajuste o `rootPath` |
| **Não conecta** | Confirme se `host`, `username`, `password` e `port` estão corretos |
| **Erro de permissão** | Verifique se o usuário tem permissão de escrita na pasta |

---

## 📝 Configuração Completa (referência)

```json
{
  "remotefs.remote": {
    "meu-site": {
      "scheme": "ftp",                    // ou "sftp" para conexões seguras
      "host": "sol.pro.br",               // Endereço do servidor
      "username": "radhal",               // Seu usuário
      "password": "minhaSenha",           // Sua senha
      "rootPath": "/sol.pro.br/orientacoes/", // Pasta do site
      "port": 21                          // 21 para FTP, 22 para SFTP
    }
  }
}
```

---

**Pronto!** Agora você edita os arquivos do seu site diretamente no VS Code, sem precisar do FileZilla. 🎉
