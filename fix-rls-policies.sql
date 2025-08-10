-- Script para corrigir as políticas RLS do Supabase
-- Execute este script no SQL Editor do seu projeto Supabase

-- 1. Remover as políticas existentes que são muito restritivas
DROP POLICY IF EXISTS "Apenas usuários autenticados podem inserir produtos" ON produtos;
DROP POLICY IF EXISTS "Apenas usuários autenticados podem atualizar produtos" ON produtos;
DROP POLICY IF EXISTS "Apenas usuários autenticados podem excluir produtos" ON produtos;

-- 2. Criar novas políticas mais permissivas para desenvolvimento/demonstração
-- ATENÇÃO: Em produção, você deve usar autenticação adequada

-- Política para permitir inserção (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir inserção de produtos" ON produtos
    FOR INSERT WITH CHECK (true);

-- Política para permitir atualização (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir atualização de produtos" ON produtos
    FOR UPDATE USING (true);

-- Política para permitir exclusão (mais permissiva para desenvolvimento)
CREATE POLICY "Permitir exclusão de produtos" ON produtos
    FOR DELETE USING (true);

-- 3. Recriar a política de leitura (remover se existir e criar novamente)
DROP POLICY IF EXISTS "Produtos são visíveis publicamente" ON produtos;
CREATE POLICY "Produtos são visíveis publicamente" ON produtos
    FOR SELECT USING (true);

-- 4. Verificar o status das políticas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'produtos';

-- IMPORTANTE: 
-- Estas políticas são adequadas para desenvolvimento e demonstração.
-- Em produção, implemente autenticação adequada e políticas mais restritivas.
-- Por exemplo:
-- CREATE POLICY "Admin pode gerenciar produtos" ON produtos
--     FOR ALL USING (auth.jwt() ->> 'role' = 'admin');