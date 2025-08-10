-- Script DEFINITIVO para corrigir RLS do Storage Supabase
-- PROBLEMA: StorageApiError: new row violates row-level security policy
-- ERRO HTTP: POST 400 (Bad Request)
-- SOLUÇÃO: Políticas RLS completamente permissivas

-- ========================================
-- PASSO 1: VERIFICAR STATUS ATUAL
-- ========================================

-- Verificar se o bucket existe
SELECT 
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types,
    created_at
FROM storage.buckets 
WHERE id = 'produtos-images';

-- Verificar políticas atuais
SELECT 
    id,
    bucket_id,
    name,
    command,
    definition,
    check_definition,
    roles
FROM storage.policies 
WHERE bucket_id = 'produtos-images'
ORDER BY command;

-- ========================================
-- PASSO 2: LIMPAR CONFIGURAÇÃO ATUAL
-- ========================================

-- Remover TODAS as políticas existentes (podem estar conflitando)
DELETE FROM storage.policies WHERE bucket_id = 'produtos-images';

-- ========================================
-- PASSO 3: RECRIAR BUCKET COM CONFIGURAÇÃO CORRETA
-- ========================================

-- Atualizar/criar bucket com configurações otimizadas
INSERT INTO storage.buckets (
    id, 
    name, 
    public, 
    file_size_limit, 
    allowed_mime_types,
    avif_autodetection,
    created_at,
    updated_at
)
VALUES (
    'produtos-images',
    'produtos-images',
    true,                    -- PÚBLICO
    52428800,               -- 50MB
    '{"image/*"}',          -- Apenas imagens
    false,                  -- Sem autodetecção AVIF
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 52428800,
    allowed_mime_types = '{"image/*"}',
    avif_autodetection = false,
    updated_at = NOW();

-- ========================================
-- PASSO 4: CRIAR POLÍTICAS ULTRA-PERMISSIVAS
-- ========================================

-- Política SELECT: Permitir visualização para TODOS
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'ultra-permissive-select-produtos-images',
    'produtos-images',
    'Ultra permissive SELECT policy',
    'true',                 -- Sempre verdadeiro
    NULL,
    'SELECT',
    '{anon, authenticated}' -- Usuários anônimos e autenticados
);

-- Política INSERT: Permitir upload para TODOS
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'ultra-permissive-insert-produtos-images',
    'produtos-images',
    'Ultra permissive INSERT policy',
    'true',                 -- Sempre verdadeiro
    'true',                 -- Check também sempre verdadeiro
    'INSERT',
    '{anon, authenticated}' -- Usuários anônimos e autenticados
);

-- Política UPDATE: Permitir atualização para TODOS
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'ultra-permissive-update-produtos-images',
    'produtos-images',
    'Ultra permissive UPDATE policy',
    'true',                 -- Sempre verdadeiro
    'true',                 -- Check também sempre verdadeiro
    'UPDATE',
    '{anon, authenticated}' -- Usuários anônimos e autenticados
);

-- Política DELETE: Permitir exclusão para TODOS
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'ultra-permissive-delete-produtos-images',
    'produtos-images',
    'Ultra permissive DELETE policy',
    'true',                 -- Sempre verdadeiro
    NULL,
    'DELETE',
    '{anon, authenticated}' -- Usuários anônimos e autenticados
);

-- ========================================
-- PASSO 5: VERIFICAÇÃO FINAL
-- ========================================

-- Confirmar bucket configurado
SELECT 
    'BUCKET CONFIGURADO' as status,
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
FROM storage.buckets 
WHERE id = 'produtos-images';

-- Confirmar políticas criadas
SELECT 
    'POLÍTICAS CRIADAS' as status,
    command,
    COUNT(*) as total,
    string_agg(name, ', ') as policy_names
FROM storage.policies 
WHERE bucket_id = 'produtos-images'
GROUP BY command
ORDER BY command;

-- Verificar se temos as 4 políticas necessárias
SELECT 
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ TODAS AS POLÍTICAS CRIADAS'
        ELSE '❌ FALTAM POLÍTICAS: ' || (4 - COUNT(*))::text
    END as resultado_final
FROM storage.policies 
WHERE bucket_id = 'produtos-images';

-- ========================================
-- RESULTADO ESPERADO
-- ========================================

-- Bucket: produtos-images
-- - public: true
-- - file_size_limit: 52428800 (50MB)
-- - allowed_mime_types: {"image/*"}

-- Políticas: 4 total
-- - DELETE: 1 (ultra-permissive-delete-produtos-images)
-- - INSERT: 1 (ultra-permissive-insert-produtos-images)
-- - SELECT: 1 (ultra-permissive-select-produtos-images)
-- - UPDATE: 1 (ultra-permissive-update-produtos-images)

-- Resultado final: ✅ TODAS AS POLÍTICAS CRIADAS

-- ========================================
-- TESTE FINAL
-- ========================================

-- Após executar este script:
-- 1. Vá para: http://localhost:8000/admin/
-- 2. Tente adicionar um produto com imagem
-- 3. O erro "new row violates row-level security policy" deve estar resolvido
-- 4. O upload deve funcionar normalmente

-- IMPORTANTE:
-- - Este script cria políticas MUITO PERMISSIVAS
-- - Adequado para desenvolvimento e demonstração
-- - Em produção, considere políticas mais restritivas baseadas em auth.uid()
-- - Se ainda houver erro, verifique se está usando a chave anônima correta