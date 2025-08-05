# 🛒 Mercado Online - Aplicativo de Mercearia

Um aplicativo web completo para mercados e mercearias, com área do cliente, painel administrativo e integração com WhatsApp para pedidos.

![Mercado Online](https://img.shields.io/badge/Status-Concluído-brightgreen)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white)

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Instalação e Configuração](#instalação-e-configuração)
- [Como Usar](#como-usar)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração do Supabase](#configuração-do-supabase)
- [Configuração do WhatsApp](#configuração-do-whatsapp)
- [Screenshots](#screenshots)
- [Contribuição](#contribuição)
- [Licença](#licença)

## 🎯 Sobre o Projeto

O **Mercado Online** é uma solução completa para pequenos mercados e mercearias que desejam vender online. O sistema permite que clientes naveguem pelos produtos, adicionem itens ao carrinho e enviem pedidos diretamente via WhatsApp para o dono do estabelecimento.

### ✨ Principais Características

- 🛍️ **Interface do Cliente**: Navegação intuitiva, carrinho de compras e checkout simplificado
- 👨‍💼 **Painel Administrativo**: Gerenciamento completo de produtos com upload de imagens
- 📱 **Integração WhatsApp**: Pedidos enviados automaticamente via WhatsApp
- 🗄️ **Banco de Dados**: Integração com Supabase para armazenamento seguro
- 📱 **Responsivo**: Funciona perfeitamente em desktop, tablet e mobile
- 🚀 **Modo Demo**: Teste imediato sem necessidade de configuração

## 🚀 Funcionalidades

### Área do Cliente
- ✅ Catálogo de produtos com imagens e preços
- ✅ Busca e filtros por categoria
- ✅ Carrinho de compras com cálculo automático
- ✅ Checkout com formulário completo
- ✅ Envio de pedidos via WhatsApp
- ✅ Interface responsiva e moderna

### Painel Administrativo
- ✅ Login seguro com autenticação
- ✅ Dashboard com estatísticas
- ✅ CRUD completo de produtos
- ✅ Upload de imagens
- ✅ Gerenciamento de categorias
- ✅ Configurações do WhatsApp
- ✅ Exportação de dados

### Integrações
- ✅ Supabase (Banco de dados e Storage)
- ✅ WhatsApp (Envio de pedidos)
- ✅ Unsplash (Imagens de demonstração)

## 🛠️ Tecnologias Utilizadas

### Frontend
- **HTML5** - Estrutura das páginas
- **CSS3** - Estilização e responsividade
- **JavaScript (ES6+)** - Lógica e interatividade
- **Font Awesome** - Ícones

### Backend/Serviços
- **Supabase** - Banco de dados PostgreSQL
- **Supabase Storage** - Armazenamento de imagens
- **Supabase Auth** - Autenticação de usuários

### Ferramentas
- **Python HTTP Server** - Servidor local para desenvolvimento
- **Git** - Controle de versão

## 📦 Instalação e Configuração

### Pré-requisitos
- Navegador web moderno
- Python 3.x (para servidor local)
- Conta no Supabase (opcional, para produção)

### Instalação Rápida

1. **Clone ou baixe o projeto**
```bash
git clone [url-do-repositorio]
cd mercado-app
```

2. **Inicie o servidor local**
```bash
python3 -m http.server 8000
```

3. **Acesse o aplicativo**
- Cliente: http://localhost:8000/client/
- Admin: http://localhost:8000/admin/

### Modo de Demonstração

O aplicativo funciona imediatamente em **modo de demonstração** com:
- ✅ Dados de exemplo pré-carregados
- ✅ Simulação de todas as funcionalidades
- ✅ Armazenamento local no navegador
- ✅ Login administrativo com qualquer email/senha

## 🎮 Como Usar

### Para Clientes

1. **Navegue pelos produtos** na página inicial
2. **Use a busca** ou **filtros por categoria** para encontrar produtos
3. **Adicione produtos ao carrinho** clicando em "Adicionar"
4. **Acesse o carrinho** e revise seus itens
5. **Clique em "Finalizar Pedido"** e preencha seus dados
6. **Envie o pedido via WhatsApp** - você será redirecionado automaticamente

### Para Administradores

1. **Acesse** `/admin/` e faça login
2. **Gerencie produtos** na seção "Produtos"
3. **Adicione novos produtos** com imagens
4. **Configure o WhatsApp** na seção "Configurações"
5. **Monitore estatísticas** no Dashboard

## 📁 Estrutura do Projeto

```
mercado-app/
├── client/                 # Área do cliente
│   └── index.html         # Página principal do cliente
├── admin/                 # Área administrativa
│   └── index.html         # Painel administrativo
├── assets/                # Recursos compartilhados
│   ├── css/              # Arquivos de estilo
│   │   ├── client.css    # Estilos do cliente
│   │   └── admin.css     # Estilos do admin
│   └── js/               # Arquivos JavaScript
│       ├── client.js     # Lógica do cliente
│       ├── admin.js      # Lógica do admin
│       └── supabase.js   # Configuração do Supabase
├── config/               # Configurações e documentação
│   ├── supabase-setup.sql      # Script SQL para Supabase
│   ├── supabase-config.md      # Guia de configuração
│   └── whatsapp-config.md      # Guia do WhatsApp
├── README.md             # Este arquivo
└── teste-resultados.md   # Relatório de testes
```

## ⚙️ Configuração do Supabase

Para usar em produção com banco de dados real:

1. **Crie uma conta** no [Supabase](https://supabase.com)
2. **Crie um novo projeto**
3. **Execute o script SQL** em `config/supabase-setup.sql`
4. **Configure as credenciais** em `assets/js/supabase.js`
5. **Configure o Storage** para upload de imagens

📖 **Guia completo**: `config/supabase-config.md`

## 📱 Configuração do WhatsApp

Para receber pedidos reais via WhatsApp:

1. **Acesse o painel administrativo**
2. **Vá para "Configurações"**
3. **Insira seu número** no formato internacional
4. **Teste com um pedido** de demonstração

📖 **Guia completo**: `config/whatsapp-config.md`

## 📸 Screenshots

### Área do Cliente
![Cliente - Página Inicial](screenshots/cliente-home.png)
![Cliente - Carrinho](screenshots/cliente-carrinho.png)

### Painel Administrativo
![Admin - Dashboard](screenshots/admin-dashboard.png)
![Admin - Produtos](screenshots/admin-produtos.png)

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para dúvidas ou suporte:

- 📧 Email: suporte@mercadoonline.com
- 💬 WhatsApp: +55 11 99999-9999
- 🐛 Issues: [GitHub Issues](link-para-issues)

## 🎉 Agradecimentos

- [Font Awesome](https://fontawesome.com) pelos ícones
- [Unsplash](https://unsplash.com) pelas imagens de demonstração
- [Supabase](https://supabase.com) pela infraestrutura de backend
- Comunidade open source pelas inspirações

---

**Desenvolvido com ❤️ para pequenos negócios**

*Versão 1.0.0 - Agosto 2025*

