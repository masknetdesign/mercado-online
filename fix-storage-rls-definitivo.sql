-- ========================================
-- SCRIPT DEFINITIVO PARA CORRIGIR RLS DO STORAGE
-- Resolve: StorageApiError: new row violates row-level security policy
-- ========================================

-- 1. VERIFICAR SE O STORAGE ESTÁ HABILITADO
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'buckets') 
        THEN '✅ Storage está habilitado' 
        ELSE '❌ Storage NÃO está habilitado - Habilite na aba Storage do Dashboard'
    END as status_storage;

-- 2. VERIFICAR BUCKETS EXISTENTES
SELECT name, public, created_at FROM storage.buckets WHERE name = 'produtos-images';

-- 3. REMOVER POLÍTICAS CONFLITANTES (se existirem)
DROP POLICY IF EXISTS "Permitir SELECT para todos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir INSERT para todos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir UPDATE para todos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir DELETE para todos" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow public insert" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_select" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_update" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_delete" ON storage.objects;

-- 4. RECRIAR O BUCKET (se necessário)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'produtos-images',
    'produtos-images',
    true,
    52428800, -- 50MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 5. CRIAR POLÍTICAS RLS ULTRA-PERMISSIVAS

-- Política SELECT (Visualizar imagens)
CREATE POLICY "produtos_images_select_all"
ON storage.objects
FOR SELECT
USING (bucket_id = 'produtos-images');

-- Política INSERT (Upload de imagens)
CREATE POLICY "produtos_images_insert_all"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'produtos-images');

-- Política UPDATE (Atualizar imagens)
CREATE POLICY "produtos_images_update_all"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'produtos-images')
WITH CHECK (bucket_id = 'produtos-images');

-- Política DELETE (Excluir imagens)
CREATE POLICY "produtos_images_delete_all"
ON storage.objects
FOR DELETE
USING (bucket_id = 'produtos-images');

-- 6. HABILITAR RLS (se não estiver habilitado)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 7. VERIFICAÇÃO FINAL
SELECT 
    '✅ Configuração concluída!' as status,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE 'produtos_images_%';

-- 8. LISTAR POLÍTICAS CRIADAS
SELECT 
    policyname as "Política",
    cmd as "Comando",
    CASE 
        WHEN qual IS NOT NULL THEN 'Com condições'
        ELSE 'Sem condições'
    END as "Status"
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE 'produtos_images_%'
ORDER BY policyname;

-- ========================================
-- INSTRUÇÕES DE USO:
-- ========================================
-- 1. Copie todo este script
-- 2. Vá para o Supabase Dashboard
-- 3. Acesse "SQL Editor"
-- 4. Cole e execute o script
-- 5. Verifique se todas as políticas foram criadas
-- 6. Teste o upload de imagens
-- ========================================

-- RESULTADO ESPERADO:
-- ✅ 4 políticas RLS criadas
-- ✅ Bucket 'produtos-images' configurado
-- ✅ Upload de imagens funcionando
-- ✅ Erro 400 e RLS resolvidos

-- EM CASO DE ERRO:
-- Se ainda houver erro, execute apenas as políticas:
/*
CREATE POLICY "allow_all_select" ON storage.objects FOR SELECT USING (true);
CREATE POLICY "allow_all_insert" ON storage.objects FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_all_update" ON storage.objects FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_delete" ON storage.objects FOR DELETE USING (true);
*/