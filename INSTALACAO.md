# 🚀 Guia de Instalação - Mercado Online

Este guia fornece instruções detalhadas para instalar e configurar o aplicativo Mercado Online.

## 📋 Índice

1. [Instalação Básica](#instalação-básica)
2. [Configuração para Produção](#configuração-para-produção)
3. [Configuração do Supabase](#configuração-do-supabase)
4. [Configuração do WhatsApp](#configuração-do-whatsapp)
5. [Personalização](#personalização)
6. [Solução de Problemas](#solução-de-problemas)

## 🎯 Instalação Básica

### Opção 1: Teste Imediato (Modo Demo)

Para testar o aplicativo imediatamente:

1. **Baixe os arquivos** do projeto
2. **Abra um terminal** na pasta do projeto
3. **Execute o servidor local**:
   ```bash
   python3 -m http.server 8000
   ```
4. **Acesse no navegador**:
   - Cliente: http://localhost:8000/client/
   - Admin: http://localhost:8000/admin/

**Login Admin (modo demo)**: Qualquer email e senha

### Opção 2: Servidor Web

Para usar com Apache, Nginx ou outro servidor web:

1. **Copie os arquivos** para o diretório do servidor
2. **Configure o servidor** para servir arquivos estáticos
3. **Acesse via domínio** ou IP do servidor

## 🏭 Configuração para Produção

### 1. Configuração do Supabase

#### Passo 1: Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Clique em "Start your project"
3. Crie uma nova organização (se necessário)
4. Clique em "New Project"
5. Preencha:
   - **Name**: Mercado Online
   - **Database Password**: Crie uma senha forte
   - **Region**: Escolha a mais próxima
6. Clique em "Create new project"

#### Passo 2: Configurar Banco de Dados

1. No painel do Supabase, vá para **SQL Editor**
2. Clique em "New query"
3. **Copie e cole** o conteúdo do arquivo `config/supabase-setup.sql`
4. Clique em "Run" para executar

#### Passo 3: Configurar Storage

1. Vá para **Storage** no painel lateral
2. Clique em "Create a new bucket"
3. Nome: `produtos-imagens`
4. Marque como **Public bucket**
5. Clique em "Create bucket"

#### Passo 4: Configurar Credenciais

1. Vá para **Settings** > **API**
2. Copie:
   - **Project URL**
   - **anon public key**
3. Edite o arquivo `assets/js/supabase.js`:

```javascript
// Substitua pelas suas credenciais reais
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'sua-chave-anonima-aqui';

// Mude para false para usar Supabase real
const DEMO_MODE = false;
```

### 2. Configuração do WhatsApp

#### Método 1: Configuração via Painel Admin

1. **Acesse o painel administrativo**
2. **Faça login** com suas credenciais
3. **Vá para "Configurações"**
4. **Insira seu número** no formato: `5511999999999`
   - 55 = código do Brasil
   - 11 = código da área
   - 999999999 = seu número
5. **Salve as configurações**

#### Método 2: Configuração Manual

Edite o arquivo `assets/js/client.js` e localize:

```javascript
// Configuração do WhatsApp
const WHATSAPP_CONFIG = {
    numero: '5511999999999', // Substitua pelo seu número
    mensagem_padrao: 'Olá! Gostaria de fazer um pedido:'
};
```

### 3. Configuração de Autenticação

#### Criar Usuário Administrador

1. No Supabase, vá para **Authentication** > **Users**
2. Clique em "Add user"
3. Preencha:
   - **Email**: seu-email@dominio.com
   - **Password**: senha-segura
   - **Email Confirm**: true
4. Clique em "Create user"

#### Configurar Políticas de Segurança (RLS)

As políticas já estão configuradas no script SQL, mas você pode ajustar:

1. Vá para **Authentication** > **Policies**
2. Revise as políticas das tabelas:
   - `produtos`: Leitura pública, escrita apenas autenticados
   - `categorias`: Leitura pública, escrita apenas autenticados

## 🎨 Personalização

### 1. Cores e Branding

Edite os arquivos CSS para personalizar:

#### Cliente (`assets/css/client.css`)
```css
:root {
    --primary-color: #3498db;    /* Azul principal */
    --secondary-color: #2ecc71;  /* Verde secundário */
    --accent-color: #e74c3c;     /* Vermelho de destaque */
    --dark-color: #2c3e50;       /* Azul escuro */
    --light-color: #ecf0f1;      /* Cinza claro */
}
```

#### Admin (`assets/css/admin.css`)
```css
:root {
    --admin-primary: #34495e;    /* Azul escuro */
    --admin-secondary: #3498db;  /* Azul claro */
    --admin-success: #27ae60;    /* Verde */
    --admin-warning: #f39c12;    /* Laranja */
    --admin-danger: #e74c3c;     /* Vermelho */
}
```

### 2. Logo e Imagens

1. **Substitua o logo** no header:
   - Edite `client/index.html` e `admin/index.html`
   - Procure por `🛒 Mercado Online`
   - Substitua por `<img src="seu-logo.png" alt="Seu Logo">`

2. **Adicione favicon**:
   ```html
   <link rel="icon" type="image/png" href="assets/images/favicon.png">
   ```

### 3. Informações da Empresa

Edite os arquivos HTML para personalizar:

- **Nome da empresa**
- **Endereço**
- **Telefone**
- **Redes sociais**

## 🔧 Solução de Problemas

### Problema: Produtos não carregam

**Possíveis causas:**
- Supabase não configurado corretamente
- Credenciais incorretas
- Problemas de CORS

**Solução:**
1. Verifique as credenciais em `supabase.js`
2. Confirme que o script SQL foi executado
3. Verifique o console do navegador para erros

### Problema: Upload de imagens falha

**Possíveis causas:**
- Bucket não criado
- Políticas de storage incorretas
- Arquivo muito grande

**Solução:**
1. Verifique se o bucket `produtos-imagens` existe
2. Confirme que está marcado como público
3. Limite o tamanho dos arquivos (máx. 5MB)

### Problema: WhatsApp não abre

**Possíveis causas:**
- Número formatado incorretamente
- WhatsApp não instalado
- Bloqueio de pop-ups

**Solução:**
1. Verifique o formato do número: `5511999999999`
2. Teste em dispositivo com WhatsApp
3. Permita pop-ups no navegador

### Problema: Login admin não funciona

**Possíveis causas:**
- Usuário não criado no Supabase
- Modo demo desabilitado
- Credenciais incorretas

**Solução:**
1. Crie usuário no painel do Supabase
2. Verifique `DEMO_MODE` em `supabase.js`
3. Use credenciais corretas

## 📞 Suporte Técnico

### Logs e Debug

Para debugar problemas:

1. **Abra o console** do navegador (F12)
2. **Verifique a aba Console** para erros JavaScript
3. **Verifique a aba Network** para problemas de API
4. **Verifique o Local Storage** para dados salvos

### Contato

Se precisar de ajuda adicional:

- 📧 **Email**: suporte@mercadoonline.com
- 💬 **WhatsApp**: +55 11 99999-9999
- 🐛 **Issues**: GitHub Issues

## ✅ Checklist de Instalação

- [ ] Projeto baixado e extraído
- [ ] Servidor local funcionando
- [ ] Teste em modo demo realizado
- [ ] Projeto criado no Supabase
- [ ] Script SQL executado
- [ ] Storage configurado
- [ ] Credenciais atualizadas
- [ ] Usuário admin criado
- [ ] Número do WhatsApp configurado
- [ ] Teste completo realizado
- [ ] Personalização aplicada

## 🎉 Próximos Passos

Após a instalação:

1. **Adicione produtos reais** via painel admin
2. **Teste o fluxo completo** de pedidos
3. **Configure backup** dos dados
4. **Monitore o uso** e performance
5. **Colete feedback** dos usuários

---

**Instalação concluída com sucesso!** 🚀

*Para dúvidas específicas, consulte os arquivos de configuração em `/config/`*

