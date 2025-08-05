# 🚀 Guia de Deploy Rápido - Mercado Online

## Opção 1: Deploy Direto no Netlify (Mais Fácil)

### Método 1: Drag & Drop
1. Acesse [netlify.com](https://netlify.com)
2. Faça login ou crie uma conta
3. Arraste toda a pasta do projeto para a área de deploy
4. Aguarde o upload e deploy automático
5. Seu site estará disponível em `https://random-name.netlify.app`

### Método 2: GitHub Integration
1. Faça upload do projeto para GitHub
2. No Netlify, clique em "New site from Git"
3. Conecte com GitHub e selecione o repositório
4. Configure:
   - Build command: (deixe vazio)
   - Publish directory: `.`
5. Clique em "Deploy site"

## Opção 2: Deploy no Vercel

1. Acesse [vercel.com](https://vercel.com)
2. Faça login com GitHub
3. Clique em "New Project"
4. Importe o repositório do GitHub
5. Clique em "Deploy"

## Opção 3: GitHub Pages

1. Faça upload para GitHub
2. Vá em Settings > Pages
3. Selecione "Deploy from a branch"
4. Escolha a branch `main`
5. Selecione pasta `/ (root)`
6. Clique em "Save"

## Configurações Importantes

### Antes do Deploy
1. Configure o Supabase (siga o guia em `config/supabase-config.md`)
2. Substitua as credenciais em `assets/js/supabase.js`
3. Configure o WhatsApp no painel admin

### Após o Deploy
1. Teste todas as funcionalidades
2. Configure domínio personalizado (opcional)
3. Configure HTTPS (automático no Netlify/Vercel)

## URLs de Acesso

Após o deploy, você terá acesso a:
- **Cliente**: `https://seu-site.netlify.app/client/`
- **Admin**: `https://seu-site.netlify.app/admin/`

## Solução de Problemas

### Erro 404
- Verifique se o arquivo `netlify.toml` está na raiz
- Confirme se todos os arquivos foram enviados

### Erro de CORS
- Configure o Supabase corretamente
- Verifique as credenciais no `supabase.js`

### Imagens não carregam
- Configure o bucket do Supabase Storage
- Verifique as políticas de acesso

## Suporte

Para dúvidas sobre deploy:
- [Documentação Netlify](https://docs.netlify.com)
- [Documentação Vercel](https://vercel.com/docs)
- [Documentação GitHub Pages](https://pages.github.com) 