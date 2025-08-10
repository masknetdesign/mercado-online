-- ========================================
-- SCRIPT PARA USUÁRIOS SEM PRIVILÉGIOS DE ADMIN
-- Resolve: ERROR: 42501: must be owner of table objects
-- ========================================

-- IMPORTANTE: Este script funciona apenas com operações básicas
-- Se você não tem privilégios de admin, use o MODO DEMO

-- 1. VERIFICAR SEU NÍVEL DE ACESSO
SELECT 
    current_user as seu_usuario,
    CASE 
        WHEN current_user = 'postgres' THEN '🔑 ADMIN - Pode executar tudo'
        WHEN current_user LIKE '%service_role%' THEN '⚙️ SERVICE - Pode executar a maioria'
        WHEN current_user = 'authenticated' THEN '👤 USER - Acesso limitado'
        WHEN current_user = 'anon' THEN '🔒 ANÔNIMO - Acesso muito limitado'
        ELSE '❓ DESCONHECIDO - Teste necessário'
    END as nivel_acesso,
    now() as verificado_em;

-- 2. VERIFICAR STORAGE (FUNCIONA PARA TODOS)
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'storage' AND table_name = 'buckets'
        ) 
        THEN '✅ Storage disponível' 
        ELSE '❌ Storage não disponível'
    END as status_storage;

-- 3. VERIFICAR BUCKET PRODUTOS-IMAGES
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN '✅ Bucket existe'
        ELSE '❌ Bucket não existe'
    END as status_bucket;

-- 4. TENTAR CRIAR BUCKET (PODE FALHAR SEM PRIVILÉGIOS)
DO $$
BEGIN
    -- Tenta criar o bucket
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
    
    RAISE NOTICE '✅ Bucket criado/atualizado com sucesso!';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '❌ SEM PRIVILÉGIOS: Não é possível criar/modificar bucket';
        RAISE NOTICE '💡 SOLUÇÃO: Use o MODO DEMO ou peça ajuda ao administrador';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ ERRO: %', SQLERRM;
END $$;

-- 5. VERIFICAR POLÍTICAS RLS (APENAS VISUALIZAÇÃO)
SELECT 
    '📋 POLÍTICAS ATUAIS:' as titulo,
    COUNT(*) as total_politicas
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects';

-- 6. LISTAR POLÍTICAS EXISTENTES
SELECT 
    policyname as politica,
    cmd as tipo,
    permissive as modo
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
ORDER BY policyname;

-- 7. RESULTADO FINAL
SELECT 
    '🎯 DIAGNÓSTICO COMPLETO!' as status,
    CASE 
        WHEN current_user = 'postgres' THEN 'Você tem privilégios de admin - Execute o script completo'
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') THEN 'Bucket existe - Tente o upload'
        ELSE 'SEM PRIVILÉGIOS - Use o MODO DEMO'
    END as recomendacao;

-- 8. INSTRUÇÕES BASEADAS NO SEU NÍVEL DE ACESSO
SELECT '
🔧 SOLUÇÕES BASEADAS NO SEU ACESSO:

👑 SE VOCÊ É ADMIN (postgres):
   → Execute o script completo de RLS
   → Todas as políticas serão criadas

⚙️ SE VOCÊ TEM ACESSO LIMITADO:
   → Use o MODO DEMO temporariamente
   → Peça ao administrador para executar o script

🎮 ATIVAR MODO DEMO:
   1. Abra: assets/js/supabase.js
   2. Encontre: isDemoMode: false
   3. Mude para: isDemoMode: true
   4. Salve e recarregue a página
   5. Teste o upload (funcionará offline)

📞 PEDIR AJUDA AO ADMIN:
   → Envie este script para o administrador
   → Peça para executar o "Script Completo de RLS"
   → Aguarde a configuração das políticas

💡 VERIFICAR PLANO SUPABASE:
   → Acesse: https://supabase.com/dashboard
   → Verifique se Storage está habilitado
   → Planos gratuitos têm limitações
' as instrucoes_detalhadas;