# ⚡ Deploy Rápido - Mercado Online

## 🚀 Opção 1: Script Automático (Recomendado)

### Windows (PowerShell)
```powershell
# Execute na pasta do projeto:
.\deploy-setup.ps1
```

### Depois:
1. Acesse [netlify.com](https://netlify.com)
2. "Add new site" → "Import from GitHub"
3. Selecione seu repositório
4. "Deploy site"

---

## 🛠️ Opção 2: Manual

### 1. GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/SEU_USUARIO/mercado-online.git
git push -u origin main
```

### 2. Netlify
1. [netlify.com](https://netlify.com) → Login
2. "Add new site" → "Import from GitHub"
3. Autorizar GitHub
4. Selecionar repositório
5. "Deploy site"

---

## 📱 URLs Finais

- **Cliente**: `https://seu-site.netlify.app/`
- **Admin**: `https://seu-site.netlify.app/admin`

---

## ⚙️ Configurações Pós-Deploy

### WhatsApp
1. Admin → Configurações
2. Inserir número: `5511999999999`
3. Salvar

### Domínio Personalizado
1. Netlify → Site settings
2. "Change site name"
3. Digite: `mercado-seunome`

---

## 🆘 Problemas?

- **Build failed**: Verifique logs no Netlify
- **Page not found**: Confirme `netlify.toml` na raiz
- **Git error**: Crie repositório em github.com/new

---

**📖 Guia completo**: `DEPLOY-NETLIFY-GITHUB.md`

**⏱️ Tempo**: 10-15 minutos