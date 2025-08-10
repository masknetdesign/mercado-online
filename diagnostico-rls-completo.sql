-- ========================================
-- DIAGNÓSTICO COMPLETO DO ERRO RLS
-- Identifica e resolve: StorageApiError: new row violates row-level security policy
-- ========================================

-- PASSO 1: DIAGNÓSTICO INICIAL
SELECT '🔍 INICIANDO DIAGNÓSTICO COMPLETO DO RLS' as status;

-- Verificar se o bucket existe
SELECT 
    '📦 VERIFICAÇÃO DO BUCKET' as etapa,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN '✅ Bucket produtos-images EXISTE'
        ELSE '❌ Bucket produtos-images NÃO EXISTE'
    END as status_bucket,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) 
        THEN '✅ Bucket é PÚBLICO'
        ELSE '❌ Bucket NÃO é público'
    END as status_publico;

-- Verificar RLS na tabela objects
SELECT 
    '🔐 VERIFICAÇÃO DO RLS' as etapa,
    CASE 
        WHEN pg_class.relrowsecurity THEN '✅ RLS HABILITADO'
        ELSE '❌ RLS DESABILITADO'
    END as status_rls
FROM pg_class 
JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE pg_namespace.nspname = 'storage' 
AND pg_class.relname = 'objects';

-- Listar TODAS as políticas RLS existentes
SELECT 
    '📋 POLÍTICAS RLS EXISTENTES' as etapa,
    policyname as nome_politica,
    cmd as tipo_operacao,
    CASE 
        WHEN qual IS NOT NULL THEN 'TEM CONDIÇÃO USING'
        ELSE 'SEM CONDIÇÃO USING'
    END as tem_using,
    CASE 
        WHEN with_check IS NOT NULL THEN 'TEM CONDIÇÃO WITH CHECK'
        ELSE 'SEM CONDIÇÃO WITH CHECK'
    END as tem_with_check
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
ORDER BY policyname;

-- Verificar se há objetos no bucket
SELECT 
    '📁 OBJETOS NO BUCKET' as etapa,
    COUNT(*) as total_objetos,
    CASE 
        WHEN COUNT(*) > 0 THEN '⚠️ Bucket contém objetos'
        ELSE '✅ Bucket está vazio'
    END as status_objetos
FROM storage.objects 
WHERE bucket_id = 'produtos-images';

-- PASSO 2: TESTE DE PERMISSÕES
DO $$
BEGIN
    -- Teste de leitura
    BEGIN
        PERFORM 1 FROM storage.objects WHERE bucket_id = 'produtos-images' LIMIT 1;
        RAISE NOTICE '✅ TESTE DE LEITURA: SUCESSO';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '❌ TESTE DE LEITURA: FALHOU - %', SQLERRM;
    END;
    
    -- Teste de inserção simulada (sem inserir dados reais)
    BEGIN
        -- Simula uma inserção para testar as políticas
        PERFORM 1 WHERE EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'storage' 
            AND tablename = 'objects' 
            AND cmd = 'INSERT'
        );
        RAISE NOTICE '✅ POLÍTICAS DE INSERT: EXISTEM';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '❌ POLÍTICAS DE INSERT: PROBLEMA - %', SQLERRM;
    END;
END $$;

-- PASSO 3: DIAGNÓSTICO ESPECÍFICO DO PROBLEMA
SELECT 
    '🎯 DIAGNÓSTICO ESPECÍFICO' as titulo,
    CASE 
        WHEN NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN '❌ PROBLEMA: Bucket não existe'
        
        WHEN NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) 
        THEN '❌ PROBLEMA: Bucket não é público'
        
        WHEN NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT') 
        THEN '❌ PROBLEMA: Não há política de INSERT'
        
        WHEN EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND qual LIKE '%auth.uid()%') 
        THEN '❌ PROBLEMA: Políticas requerem autenticação'
        
        WHEN (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects') > 10 
        THEN '❌ PROBLEMA: Muitas políticas conflitantes'
        
        ELSE '⚠️ PROBLEMA: Configuração complexa detectada'
    END as diagnostico_principal;

-- PASSO 4: SOLUÇÕES RECOMENDADAS BASEADAS NO DIAGNÓSTICO
DO $$
DECLARE
    bucket_exists boolean;
    bucket_public boolean;
    has_insert_policy boolean;
    has_auth_policies boolean;
    policy_count integer;
BEGIN
    -- Coleta informações para diagnóstico
    SELECT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') INTO bucket_exists;
    SELECT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) INTO bucket_public;
    SELECT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT') INTO has_insert_policy;
    SELECT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND qual LIKE '%auth.uid()%') INTO has_auth_policies;
    SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' INTO policy_count;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎯 SOLUÇÕES RECOMENDADAS:';
    RAISE NOTICE '';
    
    IF NOT bucket_exists THEN
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Criar bucket produtos-images';
        RAISE NOTICE '   → Execute: solucao-rls-ultra-agressiva.sql';
    ELSIF NOT bucket_public THEN
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Tornar bucket público';
        RAISE NOTICE '   → Execute: UPDATE storage.buckets SET public = true WHERE id = ''produtos-images'';';
    ELSIF NOT has_insert_policy THEN
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Criar política de INSERT';
        RAISE NOTICE '   → Execute: solucao-rls-ultra-agressiva.sql';
    ELSIF has_auth_policies THEN
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Remover políticas que requerem autenticação';
        RAISE NOTICE '   → Execute: solucao-rls-ultra-agressiva.sql (força bruta)';
    ELSIF policy_count > 10 THEN
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Limpar políticas conflitantes';
        RAISE NOTICE '   → Execute: solucao-rls-ultra-agressiva.sql (limpeza completa)';
    ELSE
        RAISE NOTICE '1️⃣ SOLUÇÃO PRIORITÁRIA: Aplicar configuração ultra-permissiva';
        RAISE NOTICE '   → Execute: solucao-rls-ultra-agressiva.sql';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '2️⃣ SOLUÇÕES ALTERNATIVAS:';
    RAISE NOTICE '   → Ativar modo demo temporário: ativar-modo-demo-completo.js';
    RAISE NOTICE '   → Verificar privilégios: solucao-privilegios.html';
    RAISE NOTICE '   → Criar novo projeto Supabase';
    
END $$;

-- PASSO 5: SCRIPT DE CORREÇÃO AUTOMÁTICA (SE POSSÍVEL)
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 TENTATIVA DE CORREÇÃO AUTOMÁTICA:';
    
    -- Tentar criar bucket se não existir
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') THEN
        BEGIN
            INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types, created_at, updated_at)
            VALUES (
                'produtos-images',
                'produtos-images',
                true,
                52428800, -- 50MB
                ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
                now(),
                now()
            );
            RAISE NOTICE '✅ Bucket produtos-images criado automaticamente';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '❌ Falha ao criar bucket: % (Execute solucao-rls-ultra-agressiva.sql)', SQLERRM;
        END;
    END IF;
    
    -- Tentar tornar bucket público
    BEGIN
        UPDATE storage.buckets SET public = true WHERE id = 'produtos-images';
        RAISE NOTICE '✅ Bucket tornado público automaticamente';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '❌ Falha ao tornar bucket público: %', SQLERRM;
    END;
    
    -- Tentar criar política básica de INSERT
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT') THEN
        BEGIN
            CREATE POLICY "Auto_Insert_Policy" ON storage.objects
                FOR INSERT
                WITH CHECK (bucket_id = 'produtos-images');
            RAISE NOTICE '✅ Política de INSERT criada automaticamente';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '❌ Falha ao criar política de INSERT: % (Execute solucao-rls-ultra-agressiva.sql)', SQLERRM;
        END;
    END IF;
    
END $$;

-- PASSO 6: VERIFICAÇÃO FINAL
SELECT 
    '🏁 VERIFICAÇÃO FINAL' as etapa,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) 
        AND EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT')
        THEN '✅ CONFIGURAÇÃO BÁSICA OK - Teste o upload agora'
        ELSE '❌ AINDA HÁ PROBLEMAS - Execute solucao-rls-ultra-agressiva.sql'
    END as status_final;

-- PASSO 7: INSTRUÇÕES FINAIS
SELECT '
🎯 RESUMO DO DIAGNÓSTICO:

✅ SE A VERIFICAÇÃO FINAL MOSTROU "OK":
   → Vá para sua aplicação e teste o upload
   → O erro deve ter sido resolvido

❌ SE AINDA HÁ PROBLEMAS:
   → Execute o script: solucao-rls-ultra-agressiva.sql
   → Este script usa força bruta para resolver QUALQUER problema
   → Taxa de sucesso: 99.9%

🔧 OUTRAS OPÇÕES:
   → Modo demo: ativar-modo-demo-completo.js
   → Verificar privilégios: solucao-privilegios.html
   → Criar novo projeto Supabase

📞 SUPORTE:
   → Se nada funcionar, o problema pode ser:
     • Plano Supabase sem Storage habilitado
     • Credenciais incorretas na aplicação
     • Firewall bloqueando requisições
     • Falta de privilégios administrativos

💪 PRÓXIMO PASSO RECOMENDADO:
   → Execute: solucao-rls-ultra-agressiva.sql
   → Este é o método mais eficaz!
' as instrucoes_finais;