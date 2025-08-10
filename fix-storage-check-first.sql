-- Script para verificar e configurar Storage do Supabase
-- PROBLEMA: ERROR: 42P01: relation "storage.policies" does not exist
-- SOLUÇÃO: Verificar se Storage está habilitado antes de executar comandos

-- ========================================
-- PASSO 1: VERIFICAR SE STORAGE ESTÁ HABILITADO
-- ========================================

-- Esta query verifica se o Storage está disponível no seu projeto
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'storage' 
            AND table_name = 'buckets'
        ) THEN 'STORAGE HABILITADO ✅'
        ELSE 'STORAGE NÃO HABILITADO ❌'
    END as status_storage;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================

-- Se retornar "STORAGE HABILITADO ✅":
--   → Você pode executar o script fix-storage-rls-final.sql
--   → Continue com a configuração das políticas RLS

-- Se retornar "STORAGE NÃO HABILITADO ❌":
--   → O Storage não está disponível no seu projeto
--   → Você precisa habilitar o Storage manualmente
--   → Ou usar o modo demo como alternativa

-- ========================================
-- PRÓXIMOS PASSOS BASEADOS NO RESULTADO
-- ========================================

-- CASO 1: Storage Habilitado
-- Execute o script: fix-storage-rls-final.sql
-- Esse script criará o bucket e as políticas necessárias

-- CASO 2: Storage Não Habilitado
-- OPÇÃO A: Habilitar Storage manualmente
--   1. Vá ao Dashboard do Supabase
--   2. Clique em "Storage" no menu lateral
--   3. Se não aparecer, seu plano pode não incluir Storage
--   4. Considere fazer upgrade do plano

-- OPÇÃO B: Usar Modo Demo
--   1. Abra o arquivo assets/js/supabase.js
--   2. Altere isDemoMode para true
--   3. O sistema funcionará com imagens simuladas

-- ========================================
-- VERIFICAÇÃO ADICIONAL (apenas se Storage habilitado)
-- ========================================

-- Verificar se o bucket produtos-images já existe
-- (Execute apenas se a query acima retornou "STORAGE HABILITADO")
/*
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM storage.buckets 
            WHERE id = 'produtos-images'
        ) THEN 'BUCKET EXISTE ✅'
        ELSE 'BUCKET NÃO EXISTE ❌'
    END as status_bucket;
*/

-- Verificar políticas existentes
-- (Execute apenas se Storage e bucket existirem)
/*
SELECT 
    command,
    COUNT(*) as total_policies
FROM storage.policies 
WHERE bucket_id = 'produtos-images'
GROUP BY command
ORDER BY command;
*/

-- ========================================
-- INSTRUÇÕES FINAIS
-- ========================================

-- 1. Execute APENAS a primeira query (verificação do Storage)
-- 2. Baseado no resultado, siga as instruções correspondentes
-- 3. NÃO execute as queries comentadas se Storage não estiver habilitado
-- 4. Para mais detalhes, consulte: SOLUCAO-STORAGE-NAO-HABILITADO.md

-- IMPORTANTE:
-- Este erro é comum e indica que você precisa configurar o Storage
-- no Dashboard do Supabase antes de executar scripts de políticas RLS.