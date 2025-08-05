# Configuração do Supabase para o Mercado Online

Este guia explica como configurar o Supabase para o aplicativo de mercearia.

## 1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Faça login ou crie uma conta
3. Clique em "New Project"
4. Escolha sua organização
5. Preencha os dados do projeto:
   - **Name**: Mercado Online
   - **Database Password**: Crie uma senha forte
   - **Region**: Escolha a região mais próxima do Brasil
6. Clique em "Create new project"

## 2. Obter Credenciais do Projeto

Após criar o projeto, você precisará das seguintes informações:

1. Vá para **Settings** > **API**
2. Copie as seguintes informações:
   - **Project URL**: `https://[seu-projeto].supabase.co`
   - **anon public key**: Chave pública para acesso anônimo

## 3. Configurar o Código

Edite o arquivo `assets/js/supabase.js` e substitua as configurações:

```javascript
const SUPABASE_CONFIG = {
    url: 'https://[seu-projeto].supabase.co', // Substitua pela sua URL
    anonKey: 'sua-chave-anonima-aqui', // Substitua pela sua chave
    bucketName: 'produtos-images'
};
```

## 4. Configurar o Banco de Dados

1. Vá para **SQL Editor** no painel do Supabase
2. Copie e execute o conteúdo do arquivo `config/supabase-setup.sql`
3. Isso criará:
   - Tabela `produtos` com todos os campos necessários
   - Índices para melhor performance
   - Políticas de segurança (RLS)
   - Dados de exemplo

## 5. Configurar Storage para Imagens

### Criar Bucket

1. Vá para **Storage** no painel do Supabase
2. Clique em "Create bucket"
3. Configure:
   - **Name**: `produtos-images`
   - **Public bucket**: ✅ Marque como público
4. Clique em "Create bucket"

### Configurar Políticas de Storage

1. Clique no bucket `produtos-images`
2. Vá para a aba **Policies**
3. Crie as seguintes políticas:

#### Política de Leitura Pública
- **Name**: "Imagens são visíveis publicamente"
- **Allowed operation**: SELECT
- **Target roles**: public
- **USING expression**: `true`

#### Política de Upload para Autenticados
- **Name**: "Apenas usuários autenticados podem fazer upload"
- **Allowed operation**: INSERT
- **Target roles**: authenticated
- **WITH CHECK expression**: `true`

#### Política de Atualização para Autenticados
- **Name**: "Apenas usuários autenticados podem atualizar imagens"
- **Allowed operation**: UPDATE
- **Target roles**: authenticated
- **USING expression**: `true`

#### Política de Exclusão para Autenticados
- **Name**: "Apenas usuários autenticados podem excluir imagens"
- **Allowed operation**: DELETE
- **Target roles**: authenticated
- **USING expression**: `true`

## 6. Configurar Autenticação

### Criar Usuário Administrador

1. Vá para **Authentication** > **Users**
2. Clique em "Add user"
3. Configure:
   - **Email**: seu-email@exemplo.com
   - **Password**: Crie uma senha forte
   - **Email confirm**: ✅ Marque como confirmado
4. Clique em "Create user"

### Configurar Provedores de Autenticação (Opcional)

Se desejar, você pode configurar login social:

1. Vá para **Authentication** > **Providers**
2. Configure os provedores desejados (Google, GitHub, etc.)

## 7. Configurar Políticas de Segurança (RLS)

As políticas já são criadas pelo script SQL, mas você pode verificar:

1. Vá para **Authentication** > **Policies**
2. Verifique se as políticas da tabela `produtos` estão ativas:
   - Leitura pública para todos
   - Escrita apenas para usuários autenticados

## 8. Testar a Configuração

### Teste do Cliente (Área Pública)
1. Abra `client/index.html` no navegador
2. Verifique se os produtos são carregados
3. Teste as funcionalidades de busca e filtro

### Teste do Admin (Área Administrativa)
1. Abra `admin/index.html` no navegador
2. Faça login com o usuário criado
3. Teste o cadastro de produtos
4. Teste o upload de imagens

## 9. Modo de Demonstração

Se você não configurar o Supabase, o aplicativo funcionará em **modo de demonstração** com dados locais armazenados no localStorage do navegador. Este modo é útil para:

- Testar o aplicativo sem configurar o Supabase
- Demonstrações rápidas
- Desenvolvimento local

### Limitações do Modo Demo
- Dados são perdidos ao limpar o navegador
- Não há sincronização entre dispositivos
- Upload de imagens é simulado
- Não há autenticação real

## 10. Variáveis de Ambiente (Opcional)

Para maior segurança em produção, você pode usar variáveis de ambiente:

```javascript
const SUPABASE_CONFIG = {
    url: process.env.SUPABASE_URL || 'YOUR_SUPABASE_URL',
    anonKey: process.env.SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY',
    bucketName: 'produtos-images'
};
```

## 11. Monitoramento e Logs

1. Vá para **Logs** no painel do Supabase
2. Monitore:
   - **API Logs**: Requisições à API
   - **Database Logs**: Consultas SQL
   - **Auth Logs**: Tentativas de login

## 12. Backup e Manutenção

### Backup Automático
- O Supabase faz backup automático diário
- Backups são mantidos por 7 dias no plano gratuito

### Backup Manual
1. Vá para **Settings** > **Database**
2. Clique em "Download backup"

### Exportar Dados
Use o botão "Exportar Produtos" no painel administrativo para fazer backup dos produtos em formato CSV.

## Solução de Problemas

### Erro de CORS
- Verifique se a URL do Supabase está correta
- Certifique-se de que o bucket está público

### Erro de Autenticação
- Verifique se o usuário foi criado corretamente
- Confirme se o email foi verificado

### Erro de Upload de Imagem
- Verifique se o bucket existe e está público
- Confirme se as políticas de storage estão configuradas

### Produtos Não Carregam
- Verifique se a tabela foi criada corretamente
- Confirme se as políticas RLS estão ativas

## Suporte

Para mais informações, consulte:
- [Documentação do Supabase](https://supabase.com/docs)
- [Guia de Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Guia de Storage](https://supabase.com/docs/guides/storage)

