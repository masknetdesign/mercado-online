# 🔧 Solução: Storage Não Habilitado no Supabase

## ❌ Erro Identificado
```
ERROR: 42P01: relation "storage.policies" does not exist
```

**Causa:** O Storage não está habilitado no seu projeto Supabase ou o bucket não foi criado.

---

## 🎯 Soluções Disponíveis

### 🚀 SOLUÇÃO 1: Configuração Manual (RECOMENDADA)

#### Passo 1: Verificar se Storage está disponível
1. Acesse seu projeto no [Supabase](https://supabase.com)
2. Faça login e selecione seu projeto
3. Verifique se **"Storage"** aparece no menu lateral esquerdo

**Se Storage NÃO aparecer:**
- Seu plano pode não incluir Storage
- Considere fazer upgrade ou usar a Solução 3 (Modo Demo)

#### Passo 2: Criar o Bucket
1. Clique em **"Storage"** no menu lateral
2. Clique em **"Create bucket"**
3. Configure:
   - **Name:** `produtos-images`
   - **Public bucket:** ✅ **MARQUE COMO PÚBLICO**
   - **File size limit:** 50MB (opcional)
   - **Allowed MIME types:** `image/*` (opcional)
4. Clique em **"Create bucket"**

#### Passo 3: Configurar Políticas de Acesso
1. Clique no bucket **"produtos-images"** que você criou
2. Vá para a aba **"Policies"**
3. Clique em **"Add policy"**
4. Crie as seguintes 4 políticas:

##### Política 1: Leitura Pública
- **Name:** `Public read access`
- **Allowed operation:** `SELECT`
- **Target roles:** `public`
- **USING expression:** `true`
- Clique em **"Save policy"**

##### Política 2: Upload Público
- **Name:** `Public upload access`
- **Allowed operation:** `INSERT`
- **Target roles:** `public`
- **WITH CHECK expression:** `true`
- Clique em **"Save policy"**

##### Política 3: Atualização Pública
- **Name:** `Public update access`
- **Allowed operation:** `UPDATE`
- **Target roles:** `public`
- **USING expression:** `true`
- **WITH CHECK expression:** `true`
- Clique em **"Save policy"**

##### Política 4: Exclusão Pública
- **Name:** `Public delete access`
- **Allowed operation:** `DELETE`
- **Target roles:** `public`
- **USING expression:** `true`
- Clique em **"Save policy"**

---

### 🔍 SOLUÇÃO 2: Verificação via SQL

#### Execute no SQL Editor do Supabase:

```sql
-- Verificar se Storage está habilitado
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'storage' 
    AND table_name = 'buckets'
) as storage_enabled;
```

**Se retornar `storage_enabled: true`:**
```sql
-- Verificar se o bucket existe
SELECT * FROM storage.buckets WHERE id = 'produtos-images';
```

**Se retornar `storage_enabled: false`:**
- Storage não está habilitado no seu projeto
- Use a Solução 1 (configuração manual) ou Solução 3 (modo demo)

---

### 🎮 SOLUÇÃO 3: Modo Demo (ALTERNATIVA RÁPIDA)

Se você não conseguir configurar o Storage, pode usar o modo demo:

#### Passo 1: Ativar Modo Demo
1. Abra o arquivo `assets/js/supabase.js`
2. Localize a linha com `isDemoMode`
3. Altere para `isDemoMode: true`

```javascript
const SUPABASE_CONFIG = {
    url: 'sua-url-aqui',
    anonKey: 'sua-chave-aqui',
    bucketName: 'produtos-images',
    isDemoMode: true  // ← Altere para true
};
```

#### Passo 2: Testar
1. Acesse `http://localhost:8000/admin/`
2. Teste adicionar um produto com imagem
3. O upload será simulado com URLs do Unsplash

**Limitações do Modo Demo:**
- Upload é simulado (não salva arquivos reais)
- Imagens vêm do Unsplash (aleatórias)
- Dados são perdidos ao recarregar a página

---

## ✅ Verificação Final

### Teste 1: Ferramenta de Diagnóstico
1. Acesse: `http://localhost:8000/test-storage-rls-fix.html`
2. Clique em "Verificar Configuração"
3. Teste o upload de uma imagem
4. Verifique se não há mais erros

### Teste 2: Área Administrativa
1. Acesse: `http://localhost:8000/admin/`
2. Clique em "Adicionar Produto"
3. Preencha os dados e selecione uma imagem
4. Clique em "Salvar Produto"
5. Verifique se o produto foi salvo com a imagem

---

## 🆘 Solução de Problemas

### Problema: "Storage não aparece no menu"
**Solução:** Seu plano não inclui Storage. Use o Modo Demo ou faça upgrade.

### Problema: "Bucket criado mas upload ainda falha"
**Solução:** Verifique se:
1. Bucket está marcado como **público**
2. Todas as 4 políticas foram criadas
3. Target roles incluem **public**

### Problema: "Políticas criadas mas ainda há erro"
**Solução:** 
1. Delete todas as políticas do bucket
2. Recrie uma por uma seguindo exatamente os passos
3. Certifique-se de usar `true` nas expressões

### Problema: "Nada funciona"
**Solução:** Use o Modo Demo (Solução 3) - é 100% funcional para desenvolvimento.

---

## 📞 Suporte Adicional

Se ainda houver problemas:
1. Verifique se sua conta Supabase tem Storage habilitado
2. Considere criar um novo projeto Supabase
3. Use o Modo Demo como alternativa temporária
4. Consulte a [documentação oficial do Supabase Storage](https://supabase.com/docs/guides/storage)

---

## 🎯 Resumo das Opções

| Solução | Dificuldade | Tempo | Funcionalidade |
|---------|-------------|-------|----------------|
| **Manual (Recomendada)** | Média | 10-15 min | 100% completa |
| **SQL** | Alta | 5-10 min | 100% completa |
| **Modo Demo** | Baixa | 2 min | 90% funcional |

**Recomendação:** Tente a Solução 1 primeiro. Se não funcionar, use a Solução 3 para continuar desenvolvendo.