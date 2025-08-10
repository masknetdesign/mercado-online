-- ========================================
-- CORREÇÃO ESPECÍFICA PARA ERRO RLS LINHA 497
-- StorageApiError: new row violates row-level security policy
-- ========================================

-- Este script resolve especificamente o erro que ocorre na linha 497 do admin.js
-- durante o upload de imagem para o bucket 'produtos-images'

BEGIN;

-- 1. VERIFICAR SE O BUCKET EXISTE
DO $$
BEGIN
    -- Verificar se o bucket produtos-images existe
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') THEN
        RAISE NOTICE 'Bucket produtos-images não existe. Criando...';
        
        -- Criar o bucket
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'produtos-images',
            'produtos-images', 
            true,
            104857600, -- 100MB
            ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
        );
        
        RAISE NOTICE 'Bucket produtos-images criado com sucesso!';
    ELSE
        RAISE NOTICE 'Bucket produtos-images já existe.';
        
        -- Garantir que o bucket seja público
        UPDATE storage.buckets 
        SET public = true,
            file_size_limit = 104857600,
            allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
        WHERE id = 'produtos-images';
        
        RAISE NOTICE 'Configurações do bucket atualizadas.';
    END IF;
END
$$;

-- 2. REMOVER TODAS AS POLÍTICAS RLS EXISTENTES PARA O BUCKET
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    -- Listar e remover todas as políticas RLS para storage.objects relacionadas ao bucket produtos-images
    FOR policy_record IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'storage' 
        AND tablename = 'objects'
        AND policyname LIKE '%produtos%' OR policyname LIKE '%images%' OR policyname LIKE '%upload%'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
                      policy_record.policyname, 
                      policy_record.schemaname, 
                      policy_record.tablename);
        RAISE NOTICE 'Política removida: %', policy_record.policyname;
    END LOOP;
END
$$;

-- 3. CRIAR POLÍTICA RLS ULTRA-PERMISSIVA PARA UPLOAD
DO $$
BEGIN
    -- Política para permitir INSERT (upload) - ULTRA PERMISSIVA
    CREATE POLICY "produtos_images_upload_policy" ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'produtos-images'
    );
    
    RAISE NOTICE 'Política de upload criada: produtos_images_upload_policy';
    
    -- Política para permitir SELECT (visualização) - ULTRA PERMISSIVA
    CREATE POLICY "produtos_images_select_policy" ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'produtos-images'
    );
    
    RAISE NOTICE 'Política de visualização criada: produtos_images_select_policy';
    
    -- Política para permitir UPDATE - ULTRA PERMISSIVA
    CREATE POLICY "produtos_images_update_policy" ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'produtos-images'
    )
    WITH CHECK (
        bucket_id = 'produtos-images'
    );
    
    RAISE NOTICE 'Política de atualização criada: produtos_images_update_policy';
    
    -- Política para permitir DELETE - ULTRA PERMISSIVA
    CREATE POLICY "produtos_images_delete_policy" ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'produtos-images'
    );
    
    RAISE NOTICE 'Política de exclusão criada: produtos_images_delete_policy';
    
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Algumas políticas já existem, continuando...';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao criar políticas: %', SQLERRM;
END
$$;

-- 4. VERIFICAR SE RLS ESTÁ HABILITADO
DO $$
BEGIN
    -- Verificar se RLS está habilitado na tabela storage.objects
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c 
        JOIN pg_namespace n ON n.oid = c.relnamespace 
        WHERE n.nspname = 'storage' 
        AND c.relname = 'objects' 
        AND c.relrowsecurity = true
    ) THEN
        -- Habilitar RLS se não estiver habilitado
        ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'RLS habilitado na tabela storage.objects';
    ELSE
        RAISE NOTICE 'RLS já está habilitado na tabela storage.objects';
    END IF;
END
$$;

-- 5. TESTE DE VERIFICAÇÃO
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICAÇÃO FINAL:';
    RAISE NOTICE '========================================';
    
    -- Verificar bucket
    IF EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) THEN
        RAISE NOTICE '✅ Bucket produtos-images existe e é público';
    ELSE
        RAISE NOTICE '❌ Problema com o bucket produtos-images';
    END IF;
    
    -- Verificar políticas
    IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'produtos_images_upload_policy') THEN
        RAISE NOTICE '✅ Política de upload existe';
    ELSE
        RAISE NOTICE '❌ Política de upload não encontrada';
    END IF;
    
    -- Verificar RLS
    IF EXISTS (
        SELECT 1 FROM pg_class c 
        JOIN pg_namespace n ON n.oid = c.relnamespace 
        WHERE n.nspname = 'storage' 
        AND c.relname = 'objects' 
        AND c.relrowsecurity = true
    ) THEN
        RAISE NOTICE '✅ RLS está habilitado';
    ELSE
        RAISE NOTICE '❌ RLS não está habilitado';
    END IF;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CORREÇÃO CONCLUÍDA!';
    RAISE NOTICE 'Agora teste o upload de imagem na linha 497';
    RAISE NOTICE '========================================';
END
$$;

COMMIT;

-- ========================================
-- INSTRUÇÕES DE USO:
-- ========================================
-- 1. Copie este script completo
-- 2. Abra o Supabase Dashboard > SQL Editor
-- 3. Cole o script e execute
-- 4. Verifique as mensagens de sucesso
-- 5. Teste o upload de imagem no admin
-- ========================================