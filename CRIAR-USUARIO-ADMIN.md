# 👤 Como Criar Usuário Administrador no Supabase

## 🎯 Problema Identificado

Você trocou de projeto no Supabase e ainda não criou um usuário administrador no novo projeto. Isso causa o erro 400 porque o sistema tenta fazer login mas não encontra o usuário.

## ✅ Solução Rápida (Recomendada)

### Método 1: Pelo Painel do Supabase (Mais Fácil)

1. **Acesse o Supabase**: https://supabase.com/dashboard
2. **Selecione seu projeto** (o novo projeto que você está usando)
3. **Vá para Authentication** → **Users** (no menu lateral)
4. **Clique em "Add user"** (botão no canto superior direito)
5. **Preencha os dados**:
   - **Email**: `admin@mercado.com` (ou seu email preferido)
   - **Password**: `admin123` (ou uma senha forte)
   - **Email Confirm**: ✅ **Marque esta opção**
6. **Clique em "Create user"**

### Método 2: Por SQL (Alternativo)

1. **Vá para SQL Editor** no painel do Supabase
2. **Clique em "New query"**
3. **Cole e execute** o conteúdo do arquivo `criar-usuario-admin.sql`
4. **Modifique** o email e senha antes de executar

## 🧪 Como Testar

### Teste 1: Login no Admin

1. **Acesse**: `http://localhost:8000/admin/`
2. **Use as credenciais** que você criou:
   - Email: `admin@mercado.com`
   - Senha: `admin123`
3. **Deve funcionar** sem erro 400

### Teste 2: Verificar Conexão

1. **Acesse**: `http://localhost:8000/test-fix-400.html`
2. **Clique em "Testar Autenticação"**
3. **Verifique os logs** - não deve haver erro 400

## 🔧 Se Ainda Houver Problemas

### Problema: Erro 400 persiste

**Causa**: Políticas RLS muito restritivas

**Solução**:
1. Execute o script `fix-rls-policies.sql` no Supabase
2. Ou use temporariamente o `disable-rls-temporary.sql`

### Problema: "User not found"

**Causa**: Usuário não foi criado corretamente

**Solução**:
1. Verifique em **Authentication** → **Users** se o usuário aparece
2. Confirme que **Email Confirm** está marcado
3. Tente criar novamente

### Problema: "Invalid credentials"

**Causa**: Email ou senha incorretos

**Solução**:
1. Verifique se está usando o email/senha corretos
2. Tente resetar a senha do usuário no painel

## 🎯 Configuração Completa

### Passo a Passo Completo

1. ✅ **Criar usuário admin** (método acima)
2. ✅ **Executar script de tabelas**: `config/supabase-setup.sql`
3. ✅ **Corrigir políticas RLS**: `fix-rls-policies.sql`
4. ✅ **Testar login**: `http://localhost:8000/admin/`
5. ✅ **Testar CRUD**: Adicionar/editar/deletar produtos

### Credenciais Padrão Sugeridas

```
Email: admin@mercado.com
Senha: admin123
```

**⚠️ IMPORTANTE**: Mude essas credenciais em produção!

## 🚀 Modo Demo (Alternativa Temporária)

Se você quiser testar rapidamente sem configurar o Supabase:

1. **Acesse**: `http://localhost:8000/test-fix-400.html`
2. **Clique em "Forçar Modo Demo"**
3. **Use as credenciais demo**:
   - Email: `admin@demo.com`
   - Senha: `demo123`
4. **Teste todas as funcionalidades**

## 📋 Checklist de Verificação

- [ ] Projeto Supabase selecionado corretamente
- [ ] Usuário admin criado em **Authentication** → **Users**
- [ ] Email confirmado (✅ Email Confirm marcado)
- [ ] Tabelas criadas (`config/supabase-setup.sql` executado)
- [ ] Políticas RLS configuradas (`fix-rls-policies.sql` executado)
- [ ] Login funciona em `http://localhost:8000/admin/`
- [ ] CRUD funciona (adicionar/editar/deletar produtos)
- [ ] Sem erros 400 no console do navegador

## 🎉 Resultado Esperado

Após seguir estes passos:

- ✅ **Sem erros 400**
- ✅ **Login funciona** no painel admin
- ✅ **CRUD completo** funciona
- ✅ **Dados persistem** no Supabase
- ✅ **Sistema totalmente funcional**

---

**💡 Dica**: Se você está apenas testando, use o modo demo. Se está desenvolvendo para produção, configure o Supabase corretamente.