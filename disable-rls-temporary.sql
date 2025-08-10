-- SOLUÇÃO TEMPORÁRIA: Desabilitar RLS para permitir CRUD imediato
-- Execute este script no SQL Editor do Supabase se quiser uma solução rápida
-- ATENÇÃO: Isso remove toda a segurança da tabela - use apenas para desenvolvimento!

-- Desabilitar Row Level Security temporariamente
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

-- Verificar se foi desabilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'produtos';

-- Para reabilitar depois (quando implementar autenticação adequada):
-- ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- IMPORTANTE:
-- Esta é uma solução temporária para desenvolvimento
-- Em produção, SEMPRE use RLS com políticas adequadas
-- Reabilite o RLS quando implementar autenticação