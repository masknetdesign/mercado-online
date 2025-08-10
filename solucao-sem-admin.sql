-- ========================================
-- SOLUÇÃO PARA USUÁRIOS SEM PRIVILÉGIOS DE ADMIN
-- Resolve: ERROR: 42501: must be owner of table objects
-- ========================================

-- IMPORTANTE: Este script é para usuários SEM privilégios de administrador
-- Se você recebeu o erro "must be owner of table objects", use este script

-- 1. VERIFICAR SEU NÍVEL DE ACESSO
SELECT 
    'VERIFICAÇÃO DE PRIVILÉGIOS' as etapa,
    current_user as seu_usuario,
    session_user as usuario_sessao,
    CASE 
        WHEN current_user = 'postgres' THEN '🔑 ADMINISTRADOR - Pode executar tudo'
        WHEN current_user LIKE '%service_role%' THEN '⚙️ SERVICE ROLE - Pode executar a maioria das operações'
        WHEN current_user = 'authenticated' THEN '👤 USUÁRIO AUTENTICADO - Acesso limitado'
        WHEN current_user = 'anon' THEN '🔒 USUÁRIO ANÔNIMO - Acesso muito limitado'
        ELSE '❓ USUÁRIO DESCONHECIDO - Privilégios incertos'
    END as nivel_privilegios,
    now() as verificado_em;

-- 2. VERIFICAR DISPONIBILIDADE DO STORAGE
SELECT 
    'VERIFICAÇÃO DO STORAGE' as etapa,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'storage' AND table_name = 'buckets'
        ) 
        THEN '✅ Storage está disponível'
        ELSE '❌ Storage não está disponível - Verifique seu plano Supabase'
    END as status_storage;

-- 3. VERIFICAR BUCKETS EXISTENTES (OPERAÇÃO SEGURA)
SELECT 
    'BUCKETS EXISTENTES' as etapa,
    id as bucket_id,
    name as bucket_name,
    public as eh_publico,
    file_size_limit as limite_tamanho,
    created_at as criado_em
FROM storage.buckets 
WHERE id = 'produtos-images'
ORDER BY created_at DESC;

-- 4. VERIFICAR SE O BUCKET PRODUTOS-IMAGES EXISTE
SELECT 
    'STATUS DO BUCKET' as etapa,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN '✅ Bucket produtos-images existe'
        ELSE '❌ Bucket produtos-images NÃO existe'
    END as status_bucket;

-- 5. VERIFICAR POLÍTICAS RLS ATUAIS (APENAS VISUALIZAÇÃO)
SELECT 
    'POLÍTICAS RLS ATUAIS' as etapa,
    COUNT(*) as total_politicas,
    string_agg(policyname, ', ') as nomes_politicas
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects';

-- 6. LISTAR POLÍTICAS DETALHADAS (SE EXISTIREM)
SELECT 
    'DETALHES DAS POLÍTICAS' as etapa,
    policyname as nome_politica,
    cmd as tipo_operacao,
    permissive as modo,
    roles as usuarios_permitidos
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- 7. TENTAR OPERAÇÕES BÁSICAS (SEM MODIFICAR RLS)
DO $$
BEGIN
    -- Verificar se consegue acessar informações básicas
    PERFORM 1 FROM storage.buckets WHERE id = 'produtos-images';
    RAISE NOTICE '✅ Acesso de leitura aos buckets: OK';
    
    -- Verificar se consegue ver objetos
    PERFORM 1 FROM storage.objects WHERE bucket_id = 'produtos-images' LIMIT 1;
    RAISE NOTICE '✅ Acesso de leitura aos objetos: OK';
    
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '❌ PRIVILÉGIOS INSUFICIENTES: Você não pode modificar configurações de Storage';
        RAISE NOTICE '💡 SOLUÇÕES DISPONÍVEIS:';
        RAISE NOTICE '   1. Peça ao ADMINISTRADOR do projeto para executar o script completo';
        RAISE NOTICE '   2. Use o MODO DEMO temporariamente para testes';
        RAISE NOTICE '   3. Crie um NOVO PROJETO Supabase (você será o admin)';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ ERRO INESPERADO: %', SQLERRM;
END $$;

-- 8. DIAGNÓSTICO FINAL E RECOMENDAÇÕES
SELECT 
    'DIAGNÓSTICO FINAL' as etapa,
    CASE 
        WHEN current_user = 'postgres' THEN 'EXECUTE O SCRIPT COMPLETO DE RLS'
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images' AND public = true) 
        THEN 'BUCKET EXISTE E É PÚBLICO - PROBLEMA PODE SER NAS POLÍTICAS RLS'
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'produtos-images') 
        THEN 'BUCKET EXISTE MAS PODE NÃO SER PÚBLICO'
        ELSE 'BUCKET NÃO EXISTE - PRECISA SER CRIADO'
    END as situacao_atual,
    
    CASE 
        WHEN current_user = 'postgres' THEN 'Você tem privilégios de admin - execute solucao-rls-definitiva.sql'
        ELSE 'Você NÃO tem privilégios de admin - veja as soluções abaixo'
    END as recomendacao;

-- 9. INSTRUÇÕES ESPECÍFICAS BASEADAS NO SEU CASO
SELECT '
🎯 SOLUÇÕES PARA SEU CASO ESPECÍFICO:

❌ PROBLEMA IDENTIFICADO:
→ Erro: "must be owner of table objects"
→ Causa: Você não tem privilégios de administrador no Supabase
→ Resultado: Não pode modificar políticas RLS diretamente

✅ SOLUÇÕES DISPONÍVEIS:

1️⃣ PEDIR AJUDA AO ADMINISTRADOR (RECOMENDADO):
   → Envie o arquivo "solucao-rls-definitiva.sql" para o administrador
   → Peça para ele executar no SQL Editor do Supabase
   → Aguarde a confirmação de que foi executado
   → Teste o upload após a execução

2️⃣ USAR MODO DEMO TEMPORÁRIO:
   → Abra o Console do navegador (F12)
   → Copie o conteúdo de "ativar-modo-demo-completo.js"
   → Cole no Console e pressione Enter
   → O upload funcionará offline para testes

3️⃣ CRIAR NOVO PROJETO SUPABASE:
   → Acesse: https://supabase.com/dashboard
   → Crie um novo projeto (você será o administrador)
   → Configure as credenciais no arquivo supabase.js
   → Execute o script completo de RLS

4️⃣ SOLICITAR PRIVILÉGIOS DE ADMIN:
   → Peça ao proprietário do projeto atual
   → Para adicionar você como administrador
   → Depois execute o script completo

💡 VERIFICAÇÕES ADICIONAIS:
→ Confirme que o Storage está habilitado no seu plano
→ Verifique se você está logado com a conta correta
→ Certifique-se de estar no projeto correto do Supabase

🔧 PRÓXIMOS PASSOS IMEDIATOS:
1. Identifique quem é o administrador do projeto
2. Envie este diagnóstico para ele
3. Peça para executar "solucao-rls-definitiva.sql"
4. Ou use o modo demo para continuar desenvolvendo

⚠️ IMPORTANTE:
→ Este erro é comum em projetos compartilhados
→ A solução definitiva requer privilégios de admin
→ O modo demo é uma alternativa válida para desenvolvimento
' as instrucoes_detalhadas;

-- 10. INFORMAÇÕES PARA O ADMINISTRADOR
SELECT '
📧 MENSAGEM PARA ENVIAR AO ADMINISTRADOR:

"Olá! Estou com um erro de upload de imagens no projeto Supabase.

ERRO: StorageApiError: new row violates row-level security policy
CÓDIGO: ERROR: 42501: must be owner of table objects

Preciso que você execute um script SQL para corrigir as políticas RLS.

ARQUIVO: solucao-rls-definitiva.sql
LOCAL: SQL Editor do Supabase Dashboard

O script vai:
✅ Remover políticas RLS conflitantes
✅ Reconfigurar o bucket produtos-images
✅ Criar políticas permissivas para upload
✅ Resolver o erro definitivamente

Por favor, execute quando possível. Obrigado!"

📋 CHECKLIST PARA O ADMINISTRADOR:
□ Fazer backup das configurações atuais (opcional)
□ Acessar Supabase Dashboard como admin
□ Ir para SQL Editor
□ Copiar e colar o script "solucao-rls-definitiva.sql"
□ Executar o script completo
□ Verificar se não houve erros
□ Confirmar que as políticas foram criadas
□ Informar que foi concluído
' as mensagem_admin;

-- 11. LOG FINAL
SELECT 
    '📊 RESUMO DA VERIFICAÇÃO' as titulo,
    current_user as usuario_atual,
    CASE WHEN current_user = 'postgres' THEN 'ADMIN' ELSE 'NÃO-ADMIN' END as tipo_usuario,
    (SELECT COUNT(*) FROM storage.buckets WHERE id = 'produtos-images') as bucket_existe,
    (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects') as politicas_rls,
    now() as diagnostico_em;