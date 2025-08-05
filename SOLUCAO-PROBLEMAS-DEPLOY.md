# 🔧 Solução de Problemas - Deploy

## Problemas Comuns e Soluções

### 1. Erro: "remote origin already exists"

**Problema:** Ao tentar adicionar o remote do GitHub
```bash
fatal: remote origin already exists.
```

**Solução:**
```bash
# Verificar remote atual
git remote -v

# Atualizar URL do remote existente
git remote set-url origin https://github.com/SEU_USUARIO/NOME_REPOSITORIO.git

# Verificar se foi atualizado
git remote -v

# Fazer push
git push -u origin main
```

### 2. Erro: "Repository not found"

**Problema:** GitHub não encontra o repositório
```bash
remote: Repository not found.
```

**Soluções:**
1. Verificar se o repositório foi criado no GitHub
2. Verificar se o nome está correto
3. Verificar se você tem permissões
4. Verificar se está logado no Git:
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### 3. Erro: "Permission denied (publickey)"

**Problema:** Erro de autenticação SSH

**Solução:** Use HTTPS em vez de SSH:
```bash
git remote set-url origin https://github.com/SEU_USUARIO/NOME_REPOSITORIO.git
```

### 4. Erro: "Updates were rejected"

**Problema:** Conflitos no repositório

**Solução:**
```bash
# Fazer pull primeiro
git pull origin main --allow-unrelated-histories

# Resolver conflitos se houver
# Depois fazer push
git push origin main
```

### 5. Netlify: "Build failed"

**Problema:** Erro durante o build no Netlify

**Soluções:**
1. Verificar se o arquivo `netlify.toml` está presente
2. Verificar se o diretório de publicação está correto
3. Verificar logs de build no Netlify
4. Configurações recomendadas:
   - **Build command:** (deixar vazio)
   - **Publish directory:** `./`
   - **Functions directory:** (deixar vazio)

### 6. Netlify: "Page not found"

**Problema:** 404 ao acessar o site

**Soluções:**
1. Verificar se os arquivos estão na raiz do repositório
2. Verificar se `index.html` existe
3. Verificar configurações de redirecionamento no `netlify.toml`

### 7. Supabase: "Invalid API key"

**Problema:** Erro de conexão com Supabase

**Solução:**
1. Verificar credenciais em `assets/js/supabase.js`
2. Verificar se o projeto Supabase está ativo
3. Verificar se as políticas RLS estão configuradas

## 🚀 Comandos de Verificação Rápida

```bash
# Verificar status do Git
git status

# Verificar remote
git remote -v

# Verificar último commit
git log --oneline -5

# Verificar arquivos importantes
ls -la netlify.toml
ls -la index.html
ls -la admin/index.html
ls -la client/index.html
```

## 📞 Suporte

Se o problema persistir:
1. Verifique os logs detalhados no Netlify
2. Consulte a documentação oficial do Netlify
3. Verifique se todos os arquivos estão commitados:
   ```bash
   git add .
   git commit -m "Fix: Correções para deploy"
   git push origin main
   ```

## ✅ Checklist Final

- [ ] Repositório criado no GitHub
- [ ] Remote origin configurado corretamente
- [ ] Todos os arquivos commitados
- [ ] Push realizado com sucesso
- [ ] Site conectado no Netlify
- [ ] Deploy realizado com sucesso
- [ ] URLs funcionando:
  - [ ] Site principal
  - [ ] `/admin` (painel administrativo)
  - [ ] `/client` (área do cliente)

---

**Dica:** Mantenha sempre uma cópia local do projeto antes de fazer alterações importantes!