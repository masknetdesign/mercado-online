-- ========================================
-- SCRIPT ALTERNATIVO PARA CORRIGIR RLS SEM PRIVILÉGIOS DE ADMIN
-- Para quando você recebe: ERROR: 42501: must be owner of table objects
-- ========================================

-- IMPORTANTE: Este script deve ser executado por um SUPER ADMIN do projeto Supabase
-- Se você não é o owner do projeto, peça para o administrador executar

-- 1. VERIFICAR PERMISSÕES ATUAIS
SELECT 
    current_user as usuario_atual,
    session_user as sessao_usuario,
    CASE 
        WHEN current_user = 'postgres' THEN '✅ Super Admin (postgres)'
        WHEN current_user LIKE '%service_role%' THEN '✅ Service Role'
        WHEN current_user LIKE '%anon%' THEN '❌ Usuário anônimo - Sem privilégios'
        WHEN current_user LIKE '%authenticated%' THEN '⚠️ Usuário autenticado - Privilégios limitados'
        ELSE '❓ Usuário: ' || current_user
    END as nivel_permissao;

-- 2. VERIFICAR SE O STORAGE ESTÁ HABILITADO
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'buckets') 
        THEN '✅ Storage está habilitado' 
        ELSE '❌ Storage NÃO está habilitado'
    END as status_storage;

-- 3. VERIFICAR BUCKET EXISTENTE
SELECT 
    name as bucket_name,
    public as publico,
    created_at as criado_em
FROM storage.buckets 
WHERE name = 'produtos-images';

-- 4. CRIAR BUCKET SE NÃO EXISTIR (sem conflito)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'produtos-images',
            'produtos-images',
            true,
            52428800, -- 50MB
            ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
        );
        RAISE NOTICE '✅ Bucket produtos-images criado com sucesso';
    ELSE
        RAISE NOTICE '✅ Bucket produtos-images já existe';
    END IF;
END $$;

-- 5. VERIFICAR POLÍTICAS EXISTENTES
SELECT 
    policyname as politica,
    cmd as comando,
    CASE 
        WHEN qual IS NOT NULL THEN 'Com condições'
        ELSE 'Sem condições'
    END as status
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
ORDER BY policyname;

-- 6. SCRIPT PARA SUPER ADMIN EXECUTAR
-- (Copie este bloco e peça para o administrador do projeto executar)

/*
-- ===== INÍCIO DO SCRIPT PARA SUPER ADMIN =====

-- Remover políticas conflitantes
DROP POLICY IF EXISTS "produtos_images_select_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_insert_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_update_all" ON storage.objects;
DROP POLICY IF EXISTS "produtos_images_delete_all" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow public insert" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete" ON storage.objects;

-- Criar políticas permissivas para produtos-images
CREATE POLICY "produtos_images_select_all"
ON storage.objects
FOR SELECT
USING (bucket_id = 'produtos-images');

CREATE POLICY "produtos_images_insert_all"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'produtos-images');

CREATE POLICY "produtos_images_update_all"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'produtos-images')
WITH CHECK (bucket_id = 'produtos-images');

CREATE POLICY "produtos_images_delete_all"
ON storage.objects
FOR DELETE
USING (bucket_id = 'produtos-images');

-- Habilitar RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ===== FIM DO SCRIPT PARA SUPER ADMIN =====
*/

-- 7. VERIFICAÇÃO FINAL (você pode executar)
SELECT 
    '✅ Verificação concluída' as status,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE '%produtos_images%';

-- 8. INSTRUÇÕES ALTERNATIVAS
SELECT '
🔧 SOLUÇÕES ALTERNATIVAS:

1. PEDIR PARA O ADMIN DO PROJETO:
   - Copie o bloco "SCRIPT PARA SUPER ADMIN" acima
   - Envie para quem criou o projeto Supabase
   - Peça para executar no SQL Editor

2. USAR MODO DEMO TEMPORÁRIO:
   - Abra: assets/js/supabase.js
   - Mude: isDemoMode: true
   - Teste o upload (funcionará offline)

3. RECRIAR PROJETO SUPABASE:
   - Crie um novo projeto onde você seja o owner
   - Configure as credenciais no supabase.js
   - Execute o script de correção

4. VERIFICAR PLANO SUPABASE:
   - Alguns planos não incluem Storage
   - Verifique em: Settings > Billing
' as instrucoes;

-- 9. TESTE DE CONEXÃO BÁSICA
SELECT 
    current_timestamp as horario_teste,
    version() as versao_postgresql,
    current_database() as banco_atual;