-- Script para criar usuário administrador no Supabase
-- Execute este script no SQL Editor do seu projeto Supabase

-- 1. Primeiro, vamos verificar se a tabela auth.users existe
-- (Este comando é apenas informativo, pode dar erro se não tiver permissão)
-- SELECT * FROM auth.users LIMIT 1;

-- 2. Criar usuário administrador
-- IMPORTANTE: Substitua 'seu-email@exemplo.com' pelo seu email real
-- IMPORTANTE: Substitua 'sua-senha-segura' por uma senha forte

INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@mercado.com',  -- MUDE ESTE EMAIL
    crypt('admin123', gen_salt('bf')),  -- MUDE ESTA SENHA
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NULL,
    '',
    '',
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
);

-- 3. Verificar se o usuário foi criado
SELECT id, email, created_at, email_confirmed_at 
FROM auth.users 
WHERE email = 'admin@mercado.com';  -- Use o mesmo email que você colocou acima

-- 4. Alternativa mais simples (se o método acima não funcionar)
-- Você pode criar o usuário diretamente no painel do Supabase:
-- 1. Vá para Authentication > Users
-- 2. Clique em "Add user"
-- 3. Preencha:
--    - Email: admin@mercado.com (ou seu email)
--    - Password: admin123 (ou sua senha)
--    - Email Confirm: true
-- 4. Clique em "Create user"

/*
INSTRUÇÕES DE USO:

1. ABRA o painel do Supabase (https://supabase.com/dashboard)
2. SELECIONE seu projeto
3. VÁ para "SQL Editor"
4. CLIQUE em "New query"
5. COLE este script
6. MODIFIQUE o email e senha nas linhas marcadas
7. CLIQUE em "Run" para executar

OU

1. VÁ para "Authentication" > "Users"
2. CLIQUE em "Add user"
3. PREENCHA os dados:
   - Email: admin@mercado.com
   - Password: admin123
   - Email Confirm: ✓ (marcado)
4. CLIQUE em "Create user"

DEPOIS DE CRIAR O USUÁRIO:

1. Teste o login em: http://localhost:8000/admin/
2. Use as credenciais que você criou
3. Se funcionar, o erro 400 deve desaparecer

SE AINDA HOUVER ERRO 400:

1. Verifique se as políticas RLS estão corretas
2. Execute o script fix-rls-policies.sql
3. Ou use o modo demo temporariamente
*/