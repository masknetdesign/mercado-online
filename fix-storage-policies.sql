-- Script para corrigir políticas RLS do Storage Supabase
-- ERRO: new row violates row-level security policy
-- SOLUÇÃO: Remover políticas restritivas e criar políticas públicas

-- ========================================
-- PASSO 1: VERIFICAR SE STORAGE EXISTE
-- ========================================

-- Execute primeiro para verificar se o Storage está habilitado:
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'storage' 
    AND table_name = 'buckets'
) as storage_enabled;

-- Se retornar false, siga as instruções em SOLUCAO-STORAGE-NAO-HABILITADO.md

-- ========================================
-- PASSO 2: VERIFICAR BUCKET EXISTENTE
-- ========================================

-- Verificar se o bucket produtos-images existe:
SELECT * FROM storage.buckets WHERE id = 'produtos-images';

-- Se não existir, criar o bucket:
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'produtos-images',
    'produtos-images',
    true,
    52428800, -- 50MB
    '{"image/*"}'
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 52428800,
    allowed_mime_types = '{"image/*"}';

-- ========================================
-- PASSO 3: REMOVER TODAS AS POLÍTICAS EXISTENTES
-- ========================================

-- Remover TODAS as políticas do bucket produtos-images:
DELETE FROM storage.policies WHERE bucket_id = 'produtos-images';

-- ========================================
-- PASSO 4: CRIAR POLÍTICAS COMPLETAMENTE PÚBLICAS
-- ========================================

-- Política 1: Leitura pública (SELECT)
INSERT INTO storage.policies (
    id, bucket_id, name, definition, check_definition, command, roles
) VALUES (
    'public-read-produtos-images-v2',
    'produtos-images',
    'Public read access v2',
    'true',
    NULL,
    'SELECT',
    '{public}'
);

-- Política 2: Upload público (INSERT)
INSERT INTO storage.policies (
    id, bucket_id, name, definition, check_definition, command, roles
) VALUES (
    'public-insert-produtos-images-v2',
    'produtos-images',
    'Public insert access v2',
    'true',
    'true',
    'INSERT',
    '{public}'
);

-- Política 3: Atualização pública (UPDATE)
INSERT INTO storage.policies (
    id, bucket_id, name, definition, check_definition, command, roles
) VALUES (
    'public-update-produtos-images-v2',
    'produtos-images',
    'Public update access v2',
    'true',
    'true',
    'UPDATE',
    '{public}'
);

-- Política 4: Exclusão pública (DELETE)
INSERT INTO storage.policies (
    id, bucket_id, name, definition, check_definition, command, roles
) VALUES (
    'public-delete-produtos-images-v2',
    'produtos-images',
    'Public delete access v2',
    'true',
    NULL,
    'DELETE',
    '{public}'
);

-- ========================================
-- PASSO 5: VERIFICAR CONFIGURAÇÃO FINAL
-- ========================================

-- Verificar bucket e políticas:
SELECT 
    b.id as bucket_id,
    b.name as bucket_name,
    b.public as is_public,
    COUNT(p.id) as policies_count
FROM storage.buckets b
LEFT JOIN storage.policies p ON b.id = p.bucket_id
WHERE b.id = 'produtos-images'
GROUP BY b.id, b.name, b.public;

-- Listar todas as políticas do bucket:
SELECT 
    id,
    name,
    command,
    definition,
    check_definition,
    roles
FROM storage.policies 
WHERE bucket_id = 'produtos-images'
ORDER BY command;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================

-- Bucket:
-- bucket_id: produtos-images
-- bucket_name: produtos-images
-- is_public: true
-- policies_count: 4

-- Políticas:
-- DELETE: public-delete-produtos-images-v2
-- INSERT: public-insert-produtos-images-v2
-- SELECT: public-read-produtos-images-v2
-- UPDATE: public-update-produtos-images-v2

-- ========================================
-- INSTRUÇÕES DE USO
-- ========================================

-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se não há erros
-- 3. Teste o upload em: http://localhost:8000/test-storage-rls-fix.html
-- 4. Se ainda houver erro, ative o modo demo no arquivo supabase.js

-- ========================================
-- MODO DEMO (ALTERNATIVA)
-- ========================================

-- Se o erro persistir, edite assets/js/supabase.js:
-- Linha ~27: Descomente: this.initDemoMode(); return;
-- Isso ativará o modo demo com URLs simuladas do Unsplash

-- ========================================
-- NOTAS IMPORTANTES
-- ========================================

-- 1. Estas políticas são COMPLETAMENTE PÚBLICAS
-- 2. Adequadas apenas para desenvolvimento/demonstração
-- 3. Em produção, implemente políticas mais restritivas
-- 4. O erro "new row violates row-level security policy" 
--    indica políticas muito restritivas no Storage
-- 5. Este script resolve o problema removendo todas as 
--    políticas restritivas e criando políticas públicas