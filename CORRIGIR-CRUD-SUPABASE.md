# Como Corrigir o Problema do CRUD no Supabase

## 🔍 Problema Identificado

O CRUD (criar, editar, excluir) não está funcionando porque as **políticas RLS (Row Level Security)** do Supabase estão configuradas para permitir operações apenas para usuários **autenticados**, mas o sistema está usando usuários **anônimos**.

## ✅ Solução

Você precisa executar o script SQL no painel do Supabase para corrigir as políticas de segurança.

### Passo 1: Acessar o SQL Editor

1. Acesse seu projeto Supabase: https://supabase.com/dashboard
2. Vá para **SQL Editor** no menu lateral
3. Clique em **New Query**

### Passo 2: Executar o Script de Correção

Copie e cole o conteúdo do arquivo `fix-rls-policies.sql` no SQL Editor e execute:

```sql
-- Script para corrigir as políticas RLS do Supabase
-- Execute este script no SQL Editor do seu projeto Supabase

-- 1. Remover as políticas existentes que são muito restritivas
DROP POLICY IF EXISTS "Apenas usuários autenticados podem inserir produtos" ON produtos;
DROP POLICY IF EXISTS "Apenas usuários autenticados podem atualizar produtos" ON produtos;
DROP POLICY IF EXISTS "Apenas usuários autenticados podem excluir produtos" ON produtos;

-- 2. Criar novas políticas mais permissivas para desenvolvimento/demonstração
-- ATENÇÃO: Em produção, você deve usar autenticação adequada

-- Política para permitir inserção (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir inserção de produtos" ON produtos
    FOR INSERT WITH CHECK (true);

-- Política para permitir atualização (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir atualização de produtos" ON produtos
    FOR UPDATE USING (true);

-- Política para permitir exclusão (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir exclusão de produtos" ON produtos
    FOR DELETE USING (true);

-- 3. Recriar a política de leitura (remover se existir e criar novamente)
DROP POLICY IF EXISTS "Produtos são visíveis publicamente" ON produtos;
CREATE POLICY "Produtos são visíveis publicamente" ON produtos
    FOR SELECT USING (true);
```

### Passo 3: Verificar as Políticas

Após executar o script, execute esta consulta para verificar se as políticas foram aplicadas:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'produtos';
```

Você deve ver 4 políticas:
- `Produtos são visíveis publicamente` (SELECT)
- `Permitir inserção de produtos` (INSERT)
- `Permitir atualização de produtos` (UPDATE)
- `Permitir exclusão de produtos` (DELETE)

### Passo 4: Testar o CRUD

Após executar o script:

1. Acesse: http://localhost:8000/test-crud-permissions.html
2. Clique em **Testar Conexão**
3. Teste cada operação: **Testar Leitura**, **Testar Inserção**, **Testar Atualização**, **Testar Exclusão**
4. Acesse a área administrativa: http://localhost:8000/admin
5. Teste criar, editar e excluir produtos

## ⚠️ Importante para Produção

Essas políticas são **permissivas** e adequadas para desenvolvimento/demonstração. Em produção, você deve:

1. Implementar autenticação adequada
2. Criar políticas mais restritivas
3. Usar roles específicos (admin, user, etc.)

Exemplo de política mais segura para produção:
```sql
CREATE POLICY "Admin pode gerenciar produtos" ON produtos
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
```

## 🔧 Arquivos de Teste Criados

- `debug-supabase.html` - Testa conexão básica
- `test-crud-permissions.html` - Testa operações CRUD
- `test-supabase-connection.html` - Testa funcionalidades do cliente
- `fix-rls-policies.sql` - Script de correção das políticas

## 📞 Suporte

Se ainda houver problemas:
1. Verifique se as credenciais do Supabase estão corretas em `assets/js/supabase.js`
2. Confirme se o projeto Supabase está ativo
3. Verifique se a tabela `produtos` existe
4. Execute os arquivos de teste para diagnóstico detalhado