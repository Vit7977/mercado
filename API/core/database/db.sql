-- Criação do banco de dados para o sistema de Mercado
CREATE DATABASE IF NOT EXISTS mercado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mercado;

-- Remoção de tabelas caso já existam (ordem reversa de dependência)
DROP TABLE IF EXISTS movimentacao_estoque;
DROP TABLE IF EXISTS item_venda;
DROP TABLE IF EXISTS venda;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS usuario;

-- 1. Tabela de Usuários (Administradores, Gerentes, Caixas, Estoquistas)
CREATE TABLE IF NOT EXISTS usuario (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    cargo ENUM('admin', 'gerente', 'caixa', 'estoquista') NOT NULL DEFAULT 'caixa',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Tabela de Categorias de Produtos
CREATE TABLE IF NOT EXISTS categoria (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255) NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela de Produtos do Mercado
CREATE TABLE IF NOT EXISTS produto (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT UNSIGNED NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    estoque DECIMAL(10, 3) NOT NULL DEFAULT 0.000,
    unidade_medida ENUM('UN', 'KG', 'L', 'CX', 'PCT') NOT NULL DEFAULT 'UN',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id) 
        REFERENCES categoria (id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
);

-- 4. Tabela de Clientes
CREATE TABLE IF NOT EXISTS cliente (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NULL,
    telefone VARCHAR(20) NULL,
    email VARCHAR(200) NULL,
    endereco VARCHAR(255) NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabela de Vendas
CREATE TABLE IF NOT EXISTS venda (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT UNSIGNED NOT NULL,
    cliente_id INT UNSIGNED NULL,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    forma_pagamento ENUM('dinheiro', 'cartao_credito', 'cartao_debito', 'pix', 'outro') NOT NULL DEFAULT 'dinheiro',
    status ENUM('concluida', 'pendente', 'cancelada') NOT NULL DEFAULT 'concluida',
    observacao VARCHAR(255) NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_venda_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuario (id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_venda_cliente FOREIGN KEY (cliente_id) 
        REFERENCES cliente (id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
);

-- 6. Tabela de Itens da Venda
CREATE TABLE IF NOT EXISTS item_venda (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    venda_id INT UNSIGNED NOT NULL,
    produto_id INT UNSIGNED NOT NULL,
    quantidade DECIMAL(10, 3) NOT NULL DEFAULT 1.000,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_item_venda FOREIGN KEY (venda_id) 
        REFERENCES venda (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (produto_id) 
        REFERENCES produto (id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
);

-- 7. Tabela de Movimentação de Estoque
CREATE TABLE IF NOT EXISTS movimentacao_estoque (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    produto_id INT UNSIGNED NOT NULL,
    usuario_id INT UNSIGNED NULL,
    tipo ENUM('entrada', 'saida', 'perda', 'ajuste') NOT NULL,
    quantidade DECIMAL(10, 3) NOT NULL,
    motivo VARCHAR(255) NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mov_produto FOREIGN KEY (produto_id) 
        REFERENCES produto (id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_mov_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuario (id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
);

-- =============================================
-- DADOS INICIAIS (SEED)
-- =============================================

-- Categorias padrão do mercado
INSERT INTO categoria (nome, descricao) VALUES
('Mercearia', 'Alimentos não perecíveis como arroz, feijão, óleo e massas'),
('Bebidas', 'Refrigerantes, sucos, águas e bebidas em geral'),
('Hortifrúti', 'Frutas, verduras e legumes frescos'),
('Laticínios e Frios', 'Leites, queijos, iogurtes, manteigas e embutidos'),
('Padaria', 'Pães, bolos, tortas e salgados'),
('Açougue', 'Carnes bovinas, suínas, frangos e cortes nobres'),
('Limpeza', 'Produtos para limpeza da casa e lavanderia'),
('Higiene Pessoal', 'Sabonetes, cremes dentais, shampoos e desodorantes');

-- Usuário Administrador de exemplo
-- Senha padrão argon2 para teste inicial: 'admin123'
INSERT INTO usuario (nome, email, senha, cargo, ativo) VALUES
('Administrador', 'admin@mercado.com', '$argon2id$v=19$m=65536,t=3,p=4$Nzk2YTBkYzg2NjM5$T26gY4k0sL8/9fXjGvK38w/m9sQyZ9B4vU+qD6L9aA', 'admin', 1),
('Operador de Caixa', 'caixa@mercado.com', '$argon2id$v=19$m=65536,t=3,p=4$Nzk2YTBkYzg2NjM5$T26gY4k0sL8/9fXjGvK38w/m9sQyZ9B4vU+qD6L9aA', 'caixa', 1);

-- Produtos de exemplo
INSERT INTO produto (categoria_id, codigo_barras, nome, descricao, preco, estoque, unidade_medida) VALUES
(1, '7891000100011', 'Arroz Branco Tipo 1 5kg', 'Pacote de arroz branco agulhinha 5kg', 29.90, 50.000, 'PCT'),
(1, '7891000100028', 'Feijão Carioca 1kg', 'Feijão tipo 1 selecionado', 8.50, 80.000, 'PCT'),
(1, '7891000100035', 'Óleo de Soja 900ml', 'Óleo vegetal de soja refinado', 6.75, 100.000, 'UN'),
(2, '7891000200018', 'Refrigerante Guaraná 2L', 'Refrigerante sabor guaraná garrafa 2 litros', 8.99, 60.000, 'UN'),
(2, '7891000200025', 'Suco de Laranja 1L', 'Suco de laranja pasteurizado integral', 10.50, 30.000, 'UN'),
(3, '7891000300015', 'Banana Prata', 'Banana prata selecionada (preço por kg)', 6.99, 45.500, 'KG'),
(3, '7891000300022', 'Tomate Italiano', 'Tomate italiano fresco (preço por kg)', 7.89, 32.000, 'KG'),
(4, '7891000400012', 'Leite Integral UHT 1L', 'Leite integral longa vida 1L', 4.89, 120.000, 'UN'),
(4, '7891000400029', 'Queijo Mussarela Fatiado', 'Mussarela fatiada especial (preço por kg)', 49.90, 15.000, 'KG'),
(5, '7891000500019', 'Pão Francês', 'Pão francês fresco (preço por kg)', 16.90, 20.000, 'KG'),
(6, '7891000600016', 'Contrafilé Bovino', 'Corte bovino de primeira contrafilé por kg', 45.90, 25.000, 'KG'),
(7, '7891000700013', 'Detergente Líquido Neutro 500ml', 'Detergente para lavar louças', 2.39, 150.000, 'UN'),
(8, '7891000800010', 'Sabonete em Barra 90g', 'Sabonete hidratante suave', 2.80, 90.000, 'UN');

-- Clientes de exemplo
INSERT INTO cliente (nome, cpf, telefone, email, endereco) VALUES
('Consumidor Padrão', NULL, NULL, NULL, NULL),
('Maria da Silva', '12345678901', '11987654321', 'maria.silva@email.com', 'Rua das Flores, 123 - Centro');