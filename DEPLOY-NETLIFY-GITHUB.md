# 🚀 Deploy Completo: Netlify + GitHub - Mercado Online

Guia passo a passo para fazer o deploy do projeto Mercado Online no Netlify usando GitHub.

## 📋 Pré-requisitos

- Conta no GitHub
- Conta no Netlify
- Projeto Mercado Online baixado localmente
- Git instalado no computador

## 🔧 Passo 1: Preparar o Projeto

### 1.1 Verificar Arquivos de Configuração

O projeto já possui os arquivos necessários:
- ✅ `netlify.toml` - Configuração do Netlify
- ✅ `.gitignore` - Arquivos a serem ignorados
- ✅ Estrutura de pastas organizada

### 1.2 Configurar Supabase (Opcional)

Se quiser usar o banco de dados em produção:
1. Siga o guia em `config/supabase-config.md`
2. Substitua as credenciais em `assets/js/supabase.js`

**Nota**: O projeto funciona em modo demo sem configuração do Supabase.

## 📁 Passo 2: Criar Repositório no GitHub

### 2.1 Criar Novo Repositório

1. Acesse [github.com](https://github.com)
2. Clique em **"New repository"** (botão verde)
3. Configure o repositório:
   - **Repository name**: `mercado-online`
   - **Description**: `Aplicativo web completo para mercados e mercearias`
   - **Visibility**: Public (recomendado para Netlify gratuito)
   - ❌ **NÃO** marque "Add a README file"
   - ❌ **NÃO** adicione .gitignore (já existe)
   - ❌ **NÃO** escolha license
4. Clique em **"Create repository"**

### 2.2 Conectar Projeto Local ao GitHub

Abra o terminal na pasta do projeto e execute:

```bash
# Inicializar repositório Git
git init

# Adicionar todos os arquivos
git add .

# Fazer primeiro commit
git commit -m "Initial commit: Mercado Online - Aplicativo completo"

# Se o remote já existir (erro "remote origin already exists"), atualize a URL:
git remote set-url origin https://github.com/SEU_USUARIO/mercado-online.git

# Se for a primeira vez, adicione o remote:
git remote add origin https://github.com/SEU_USUARIO/mercado-online.git

# Verificar se a URL está correta
git remote -v

# Enviar para GitHub
git branch -M main
git push -u origin main
```

**Importante**: Substitua `SEU_USUARIO` pelo seu username do GitHub.

## 🌐 Passo 3: Deploy no Netlify

### 3.1 Conectar GitHub ao Netlify

1. Acesse [netlify.com](https://netlify.com)
2. Faça login ou crie uma conta
3. No dashboard, clique em **"Add new site"**
4. Selecione **"Import an existing project"**
5. Clique em **"Deploy with GitHub"**
6. Autorize o Netlify a acessar sua conta GitHub
7. Selecione o repositório `mercado-online`

### 3.2 Configurar Deploy

**Configurações automáticas** (o Netlify detectará):
- **Branch to deploy**: `main`
- **Build command**: (vazio - não precisa)
- **Publish directory**: `.` (raiz do projeto)
- **Build settings**: Detectadas automaticamente pelo `netlify.toml`

### 3.3 Finalizar Deploy

1. Clique em **"Deploy site"**
2. Aguarde o processo de build (1-3 minutos)
3. Seu site estará disponível em uma URL como: `https://random-name-123456.netlify.app`

## ⚙️ Passo 4: Configurações Pós-Deploy

### 4.1 Personalizar Domínio (Opcional)

1. No dashboard do Netlify, vá em **"Site settings"**
2. Clique em **"Change site name"**
3. Digite um nome personalizado: `mercado-online-seunome`
4. Seu site ficará: `https://mercado-online-seunome.netlify.app`

### 4.2 Configurar Domínio Próprio (Opcional)

Se você tem um domínio próprio:
1. Vá em **"Domain settings"**
2. Clique em **"Add custom domain"**
3. Digite seu domínio: `www.seudominio.com`
4. Configure os DNS conforme instruções do Netlify

### 4.3 Configurar HTTPS

✅ **Automático**: O Netlify configura HTTPS automaticamente
- Certificado SSL gratuito via Let's Encrypt
- Redirecionamento HTTP → HTTPS automático

## 🔄 Passo 5: Atualizações Automáticas

### 5.1 Como Funciona

Após o setup inicial:
- ✅ Qualquer push para a branch `main` dispara deploy automático
- ✅ Build e deploy em 1-3 minutos
- ✅ Notificações por email sobre status do deploy

### 5.2 Fazer Atualizações

```bash
# Fazer alterações no código
# Depois:

git add .
git commit -m "Descrição da alteração"
git push origin main

# Deploy automático será iniciado
```

## 📱 Passo 6: Testar o Deploy

### 6.1 URLs de Acesso

Após o deploy, teste as seguintes URLs:

- **Cliente**: `https://seu-site.netlify.app/`
- **Admin**: `https://seu-site.netlify.app/admin`
- **Direto Cliente**: `https://seu-site.netlify.app/client`

### 6.2 Funcionalidades a Testar

**Área do Cliente**:
- ✅ Carregamento da página inicial
- ✅ Visualização de produtos
- ✅ Adicionar itens ao carrinho
- ✅ Processo de checkout
- ✅ Integração WhatsApp

**Área Administrativa**:
- ✅ Login (qualquer email/senha em modo demo)
- ✅ Dashboard com estatísticas
- ✅ Gerenciamento de produtos
- ✅ Upload de imagens
- ✅ Configurações

## 🛠️ Passo 7: Configurações Avançadas

### 7.1 Variáveis de Ambiente (Se usar Supabase)

1. No Netlify, vá em **"Site settings" → "Environment variables"**
2. Adicione as variáveis:
   ```
   SUPABASE_URL=https://seu-projeto.supabase.co
   SUPABASE_ANON_KEY=sua-chave-anonima
   ```
3. Redeploy o site

### 7.2 Configurar Formulários Netlify (Opcional)

Para capturar contatos:
1. Adicione `netlify` ao formulário HTML
2. Configure notificações no dashboard

### 7.3 Analytics (Opcional)

1. Ative **Netlify Analytics** (pago)
2. Ou integre Google Analytics no código

## 🚨 Solução de Problemas

### Erro: "Build failed"

**Causa**: Problema no código ou configuração
**Solução**:
1. Verifique os logs de build no Netlify
2. Teste o projeto localmente
3. Corrija erros e faça novo push

### Erro: "Page not found"

**Causa**: Problema nas rotas
**Solução**:
1. Verifique se o `netlify.toml` está na raiz
2. Confirme as configurações de redirect

### Erro: "Supabase connection failed"

**Causa**: Credenciais incorretas
**Solução**:
1. Verifique as credenciais em `assets/js/supabase.js`
2. Ou use o modo demo (funciona sem Supabase)

## ✅ Checklist Final

- [ ] Repositório criado no GitHub
- [ ] Código enviado para GitHub
- [ ] Site conectado ao Netlify
- [ ] Deploy realizado com sucesso
- [ ] URLs funcionando corretamente
- [ ] Área do cliente testada
- [ ] Área administrativa testada
- [ ] HTTPS configurado
- [ ] Domínio personalizado (opcional)
- [ ] Supabase configurado (opcional)

## 🎉 Parabéns!

Seu **Mercado Online** está agora disponível na internet!

### URLs Finais:
- **Site Principal**: `https://seu-site.netlify.app`
- **Painel Admin**: `https://seu-site.netlify.app/admin`
- **Repositório**: `https://github.com/seu-usuario/mercado-online`

### Próximos Passos:
1. Compartilhe o link com clientes
2. Configure o WhatsApp no painel admin
3. Adicione produtos reais
4. Personalize cores e textos
5. Configure domínio próprio

---

**Suporte**: Se encontrar problemas, consulte a documentação do Netlify ou abra uma issue no GitHub.

**Tempo total estimado**: 15-30 minutos