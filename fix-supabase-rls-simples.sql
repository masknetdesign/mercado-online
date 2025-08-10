-- ========================================
-- SCRIPT SIMPLIFICADO PARA SUPABASE
-- Resolve: ERROR: 42704: role "rds_superuser" does not exist
-- ========================================

-- IMPORTANTE: Execute este script no SQL Editor do Supabase Dashboard
-- Funciona com qualquer usuário que tenha acesso ao projeto

-- 1. VERIFICAR STATUS ATUAL
SELECT 
    current_user as usuario_conectado,
    current_database() as banco_atual,
    now() as horario_execucao;

-- 2. VERIFICAR SE O STORAGE ESTÁ DISPONÍVEL
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'storage' AND table_name = 'buckets'
        ) 
        THEN '✅ Storage disponível' 
        ELSE '❌ Storage não disponível - Verifique seu plano Supabase'
    END as status_storage;

-- 3. LISTAR BUCKETS EXISTENTES
SELECT 
    id,
    name,
    public,
    file_size_limit,
    created_at
FROM storage.buckets 
ORDER BY created_at DESC;

-- 4. VERIFICAR BUCKET PRODUTOS-IMAGES
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN '✅ Bucket produtos-images existe'
        ELSE '❌ Bucket produtos-images não existe'
    END as status_bucket;

-- 5. CRIAR/ATUALIZAR BUCKET (FUNCIONA SEM PRIVILÉGIOS ESPECIAIS)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'produtos-images',
    'produtos-images', 
    true,
    52428800, -- 50MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/jpg']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 6. VERIFICAR POLÍTICAS RLS EXISTENTES
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- 7. REMOVER POLÍTICAS ANTIGAS (SE EXISTIREM)
DROP POLICY IF EXISTS "produtos_images_select_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_insert_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_update_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_delete_all" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow public insert" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder" ON storage.objects;

-- 8. CRIAR POLÍTICAS ULTRA-PERMISSIVAS
-- Estas políticas permitem acesso total ao bucket produtos-images

-- Política para SELECT (visualizar)
CREATE POLICY "produtos_select_public"
ON storage.objects
FOR SELECT
USING (bucket_id = 'produtos-images');

-- Política para INSERT (upload)
CREATE POLICY "produtos_insert_public"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'produtos-images');

-- Política para UPDATE (atualizar)
CREATE POLICY "produtos_update_public"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'produtos-images')
WITH CHECK (bucket_id = 'produtos-images');

-- Política para DELETE (excluir)
CREATE POLICY "produtos_delete_public"
ON storage.objects
FOR DELETE
USING (bucket_id = 'produtos-images');

-- 9. GARANTIR QUE RLS ESTÁ HABILITADO
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 10. VERIFICAÇÃO FINAL
SELECT 
    '🎉 CONFIGURAÇÃO CONCLUÍDA!' as resultado,
    COUNT(*) as politicas_criadas
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE 'produtos_%';

-- 11. LISTAR POLÍTICAS FINAIS
SELECT 
    '📋 POLÍTICAS ATIVAS:' as titulo,
    policyname as politica,
    cmd as tipo,
    CASE 
        WHEN permissive = 'PERMISSIVE' THEN '✅ Permissiva'
        ELSE '⚠️ Restritiva'
    END as modo
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE 'produtos_%'
ORDER BY policyname;

-- 12. TESTE DE CONECTIVIDADE
SELECT 
    '✅ Script executado com sucesso!' as status,
    'Agora teste o upload de imagens na área admin' as proxima_acao,
    current_timestamp as executado_em;

-- 13. INSTRUÇÕES FINAIS
SELECT '
🎯 PRÓXIMOS PASSOS:

1. ✅ Script executado - Políticas RLS configuradas
2. 🔄 Volte para a área administrativa
3. 📸 Teste o upload de uma imagem
4. 🎉 O erro "new row violates row-level security policy" deve estar resolvido!

💡 DICAS:
- Se ainda houver erro, aguarde 30 segundos e tente novamente
- Verifique se o Storage está habilitado no seu plano Supabase
- Em caso de dúvidas, use o modo demo temporário

🔧 MODO DEMO (se necessário):
- Abra: assets/js/supabase.js
- Mude: isDemoMode: true
- Salve e recarregue a página
' as instrucoes_finais;