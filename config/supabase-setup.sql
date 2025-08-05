-- Configuração do banco de dados Supabase para o Mercado Online
-- Execute estes comandos no SQL Editor do Supabase

-- 1. Criar a tabela de produtos
CREATE TABLE IF NOT EXISTS produtos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    categoria VARCHAR(50) NOT NULL,
    url_imagem TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON produtos(categoria);
CREATE INDEX IF NOT EXISTS idx_produtos_nome ON produtos(nome);
CREATE INDEX IF NOT EXISTS idx_produtos_criado_em ON produtos(criado_em DESC);

-- 3. Criar função para atualizar o campo atualizado_em automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 4. Criar trigger para atualizar automaticamente o campo atualizado_em
DROP TRIGGER IF EXISTS update_produtos_updated_at ON produtos;
CREATE TRIGGER update_produtos_updated_at
    BEFORE UPDATE ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 5. Inserir dados de exemplo (opcional)
INSERT INTO produtos (nome, descricao, preco, categoria, url_imagem) VALUES
('Banana Prata', 'Banana prata fresca e doce, rica em potássio', 4.99, 'frutas', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop'),
('Coca-Cola 2L', 'Refrigerante Coca-Cola 2 litros gelado', 8.99, 'bebidas', 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=300&h=300&fit=crop'),
('Detergente Ypê', 'Detergente líquido neutro 500ml para louças', 2.49, 'limpeza', 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=300&h=300&fit=crop'),
('Pão Francês', 'Pão francês fresquinho assado no dia (kg)', 12.90, 'padaria', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop'),
('Picanha', 'Picanha bovina premium primeira qualidade (kg)', 89.90, 'carnes', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=300&fit=crop'),
('Maçã Gala', 'Maçã gala vermelha doce e crocante (kg)', 7.99, 'frutas', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&h=300&fit=crop'),
('Água Mineral 1.5L', 'Água mineral natural sem gás 1.5 litros', 3.50, 'bebidas', 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=300&h=300&fit=crop'),
('Sabão em Pó', 'Sabão em pó concentrado 1kg para roupas', 8.90, 'limpeza', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop'),
('Croissant', 'Croissant francês amanteigado (unidade)', 4.50, 'padaria', 'https://images.unsplash.com/photo-1555507036-ab794f4ade2a?w=300&h=300&fit=crop'),
('Frango Inteiro', 'Frango inteiro resfriado (kg)', 12.90, 'carnes', 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=300&h=300&fit=crop')
ON CONFLICT DO NOTHING;

-- 6. Configurar Row Level Security (RLS) - IMPORTANTE PARA SEGURANÇA

-- Habilitar RLS na tabela produtos
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura pública dos produtos (para a área do cliente)
CREATE POLICY "Produtos são visíveis publicamente" ON produtos
    FOR SELECT USING (true);

-- Política para permitir inserção apenas para usuários autenticados (administradores)
CREATE POLICY "Apenas usuários autenticados podem inserir produtos" ON produtos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para permitir atualização apenas para usuários autenticados (administradores)
CREATE POLICY "Apenas usuários autenticados podem atualizar produtos" ON produtos
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para permitir exclusão apenas para usuários autenticados (administradores)
CREATE POLICY "Apenas usuários autenticados podem excluir produtos" ON produtos
    FOR DELETE USING (auth.role() = 'authenticated');

-- 7. Criar bucket para armazenamento de imagens (execute no Storage)
-- Vá para Storage > Create Bucket
-- Nome: produtos-images
-- Público: true (para permitir acesso direto às imagens)

-- 8. Configurar política de storage para o bucket produtos-images
-- Vá para Storage > produtos-images > Policies
-- Crie as seguintes políticas:

-- Política para permitir leitura pública das imagens:
-- Nome: "Imagens são visíveis publicamente"
-- Operação: SELECT
-- Target roles: public
-- USING expression: true

-- Política para permitir upload apenas para usuários autenticados:
-- Nome: "Apenas usuários autenticados podem fazer upload"
-- Operação: INSERT
-- Target roles: authenticated
-- WITH CHECK expression: true

-- Política para permitir atualização apenas para usuários autenticados:
-- Nome: "Apenas usuários autenticados podem atualizar imagens"
-- Operação: UPDATE
-- Target roles: authenticated
-- USING expression: true

-- Política para permitir exclusão apenas para usuários autenticados:
-- Nome: "Apenas usuários autenticados podem excluir imagens"
-- Operação: DELETE
-- Target roles: authenticated
-- USING expression: true

