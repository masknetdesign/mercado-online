-- Script SQL para Ativar Storage e Criar Bucket produtos-images
-- Execute este script no SQL Editor do Supabase

-- ========================================
-- PASSO 1: VERIFICAR SE STORAGE ESTÁ HABILITADO
-- ========================================

-- Verificar se as tabelas do Storage existem
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'storage' 
            AND table_name = 'buckets'
        ) THEN '✅ Storage está HABILITADO'
        ELSE '❌ Storage NÃO está habilitado - Habilite no Dashboard'
    END as status_storage;

-- ========================================
-- PASSO 2: HABILITAR EXTENSÃO STORAGE (se necessário)
-- ========================================

-- Habilitar extensão do Storage (pode dar erro se já estiver habilitada)
CREATE EXTENSION IF NOT EXISTS "storage" SCHEMA "storage";

-- ========================================
-- PASSO 3: CRIAR BUCKET produtos-images
-- ========================================

-- Criar o bucket produtos-images com configurações otimizadas
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
    'produtos-images',          -- ID do bucket
    'produtos-images',          -- Nome do bucket
    true,                       -- Público (permite acesso direto)
    52428800,                   -- 50MB de limite
    '{"image/*"}',              -- Apenas imagens
    false,                      -- Sem autodetecção AVIF
    NOW(),                      -- Data de criação
    NOW()                       -- Data de atualização
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 52428800,
    allowed_mime_types = '{"image/*"}',
    avif_autodetection = false,
    updated_at = NOW();

-- ========================================
-- PASSO 4: CRIAR POLÍTICAS RLS PERMISSIVAS
-- ========================================

-- Remover políticas existentes (se houver)
DELETE FROM storage.policies WHERE bucket_id = 'produtos-images';

-- Política SELECT: Permitir visualização para todos
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'public-select-produtos-images',
    'produtos-images',
    'Allow public SELECT access',
    'true',                     -- Sempre permitir
    NULL,
    'SELECT',
    '{anon, authenticated}'     -- Usuários anônimos e autenticados
);

-- Política INSERT: Permitir upload para todos
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'public-insert-produtos-images',
    'produtos-images',
    'Allow public INSERT access',
    'true',                     -- Sempre permitir
    'true',                     -- Check também sempre permitir
    'INSERT',
    '{anon, authenticated}'     -- Usuários anônimos e autenticados
);

-- Política UPDATE: Permitir atualização para todos
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'public-update-produtos-images',
    'produtos-images',
    'Allow public UPDATE access',
    'true',                     -- Sempre permitir
    'true',                     -- Check também sempre permitir
    'UPDATE',
    '{anon, authenticated}'     -- Usuários anônimos e autenticados
);

-- Política DELETE: Permitir exclusão para todos
INSERT INTO storage.policies (
    id,
    bucket_id,
    name,
    definition,
    check_definition,
    command,
    roles
) VALUES (
    'public-delete-produtos-images',
    'produtos-images',
    'Allow public DELETE access',
    'true',                     -- Sempre permitir
    NULL,
    'DELETE',
    '{anon, authenticated}'     -- Usuários anônimos e autenticados
);

-- ========================================
-- PASSO 5: VERIFICAÇÃO FINAL
-- ========================================

-- Verificar se o bucket foi criado
SELECT 
    '🪣 BUCKET CRIADO' as status,
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
FROM storage.buckets 
WHERE id = 'produtos-images';

-- Verificar se as políticas foram criadas
SELECT 
    '🔐 POLÍTICAS CRIADAS' as status,
    command,
    COUNT(*) as total,
    string_agg(name, ', ') as policy_names
FROM storage.policies 
WHERE bucket_id = 'produtos-images'
GROUP BY command
ORDER BY command;

-- Verificar se temos todas as 4 políticas
SELECT 
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ CONFIGURAÇÃO COMPLETA - 4 políticas criadas'
        WHEN COUNT(*) > 0 THEN '⚠️ CONFIGURAÇÃO PARCIAL - ' || COUNT(*) || ' políticas criadas'
        ELSE '❌ NENHUMA POLÍTICA CRIADA'
    END as resultado_final
FROM storage.policies 
WHERE bucket_id = 'produtos-images';

-- ========================================
-- INSTRUÇÕES FINAIS
-- ========================================

-- Após executar este script:
-- 1. Verifique se todas as queries executaram sem erro
-- 2. Confirme que o bucket 'produtos-images' foi criado
-- 3. Confirme que as 4 políticas foram criadas
-- 4. Desative o modo demo: isDemoMode: false
-- 5. Teste o upload em: http://localhost:8000/admin/

-- IMPORTANTE:
-- - Se der erro "relation storage.buckets does not exist"
--   significa que o Storage não está habilitado no seu plano
-- - Neste caso, use o modo demo ou faça upgrade do plano
-- - Este script cria políticas muito permissivas (adequado para desenvolvimento)

-- RESULTADO ESPERADO:
-- ✅ Storage habilitado
-- ✅ Bucket 'produtos-images' criado (público, 50MB, apenas imagens)
-- ✅ 4 políticas RLS criadas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Upload de imagens funcionando sem erros