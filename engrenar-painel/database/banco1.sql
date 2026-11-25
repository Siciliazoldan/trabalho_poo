DROP DATABASE IF EXISTS engrenar;
CREATE DATABASE engrenar
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE engrenar;


-- segmento industrial
CREATE TABLE segmento_industrial (
  id_segmento         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                VARCHAR(100) NOT NULL,
  atividade_economica VARCHAR(150) NULL,
  descricao           TEXT NULL,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_segmento),
  UNIQUE KEY uq_segmento_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE industria (
  id_industria        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_segmento         BIGINT UNSIGNED NOT NULL,
  razao_social        VARCHAR(150) NOT NULL,
  cnpj                CHAR(14) NOT NULL,
  cnae                VARCHAR(10) NULL,
  inscricao_estadual  VARCHAR(20) NULL,
  ativo               TINYINT(1) NOT NULL DEFAULT 1,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_industria),
  UNIQUE KEY uq_industria_cnpj (cnpj),
  CONSTRAINT fk_industria_segmento FOREIGN KEY (id_segmento)
    REFERENCES segmento_industrial (id_segmento)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE unidade (
  id_unidade     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria   BIGINT UNSIGNED NOT NULL,
  nome           VARCHAR(100) NOT NULL,
  endereco       VARCHAR(255) NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_unidade),
  UNIQUE KEY uq_unidade_nome (id_industria, nome),
  CONSTRAINT fk_unidade_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE setor (
  id_setor     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_unidade   BIGINT UNSIGNED NOT NULL,
  nome         VARCHAR(100) NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_setor),
  UNIQUE KEY uq_setor_nome (id_unidade, nome),
  CONSTRAINT fk_setor_unidade FOREIGN KEY (id_unidade)
    REFERENCES unidade (id_unidade)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE linha_producao (
  id_linha     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_setor     BIGINT UNSIGNED NOT NULL,
  nome         VARCHAR(100) NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_linha),
  UNIQUE KEY uq_linha_nome (id_setor, nome),
  CONSTRAINT fk_linha_setor FOREIGN KEY (id_setor)
    REFERENCES setor (id_setor)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 2. ACESSO
CREATE TABLE cargo (
  id_cargo     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(80) NOT NULL,
  descricao    VARCHAR(255) NULL,
  PRIMARY KEY (id_cargo),
  UNIQUE KEY uq_cargo_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE usuario (
  id_usuario     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria   BIGINT UNSIGNED NOT NULL,
  id_cargo       BIGINT UNSIGNED NOT NULL,
  id_setor       BIGINT UNSIGNED NULL,
  nome           VARCHAR(120) NOT NULL,
  matricula      VARCHAR(30) NOT NULL,
  email          VARCHAR(150) NOT NULL,
  senha_hash     VARCHAR(255) NOT NULL,
  ativo          TINYINT(1) NOT NULL DEFAULT 1,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuario_email (email),
  UNIQUE KEY uq_usuario_matricula (id_industria, matricula),
  CONSTRAINT fk_usuario_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_cargo FOREIGN KEY (id_cargo)
    REFERENCES cargo (id_cargo)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_setor FOREIGN KEY (id_setor)
    REFERENCES setor (id_setor)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 3. BIBLIOTECA DE MÁQUINAS
CREATE TABLE fabricante (
  id_fabricante  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  PRIMARY KEY (id_fabricante),
  UNIQUE KEY uq_fabricante_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE maquina_biblioteca (
  id_maquina_biblioteca  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_fabricante          BIGINT UNSIGNED NULL,
  modelo                 VARCHAR(120) NOT NULL,
  tag                    VARCHAR(50) NULL,
  descricao              TEXT NULL,
  created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_maquina_biblioteca),
  UNIQUE KEY uq_maqbib_modelo (id_fabricante, modelo),
  CONSTRAINT fk_maqbib_fabricante FOREIGN KEY (id_fabricante)
    REFERENCES fabricante (id_fabricante)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- tabela associativa(vincula maquina x ao segmento y) 
CREATE TABLE segmento_maquina_biblioteca (
  id_segmento            BIGINT UNSIGNED NOT NULL,
  id_maquina_biblioteca  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_segmento, id_maquina_biblioteca),
  CONSTRAINT fk_smb_segmento FOREIGN KEY (id_segmento)
    REFERENCES segmento_industrial (id_segmento)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_smb_maquina FOREIGN KEY (id_maquina_biblioteca)
    REFERENCES maquina_biblioteca (id_maquina_biblioteca)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE template_maquina (
  id_template            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_maquina_biblioteca  BIGINT UNSIGNED NOT NULL,
  nome                   VARCHAR(120) NOT NULL,
  descricao              TEXT NULL,
  created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_template),
  UNIQUE KEY uq_template_nome (id_maquina_biblioteca, nome),
  CONSTRAINT fk_template_maqbib FOREIGN KEY (id_maquina_biblioteca)
    REFERENCES maquina_biblioteca (id_maquina_biblioteca)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE peca_pai_biblioteca (
  id_componente  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_template    BIGINT UNSIGNED NOT NULL,
  nome           VARCHAR(120) NOT NULL,
  descricao      TEXT NULL,
  quantidade     INT UNSIGNED NOT NULL DEFAULT 1,
  criticidade    ENUM('baixa','media','alta','critica') NOT NULL DEFAULT 'media',
  vida_util      INT UNSIGNED NULL COMMENT 'em horas de operação',
  PRIMARY KEY (id_componente),
  CONSTRAINT ck_ppb_quantidade CHECK (quantidade > 0),
  CONSTRAINT fk_ppb_template FOREIGN KEY (id_template)
    REFERENCES template_maquina (id_template)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

   
-- 4. ESTOQUE
CREATE TABLE peca (
  id_peca        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria   BIGINT UNSIGNED NOT NULL,
  codigo         VARCHAR(50) NOT NULL,
  nome           VARCHAR(120) NOT NULL,
  descricao      TEXT NULL,
  unidade_medida VARCHAR(10) NOT NULL DEFAULT 'un',
  valor_unitario DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_peca),
  UNIQUE KEY uq_peca_codigo (id_industria, codigo),
  CONSTRAINT ck_peca_valor CHECK (valor_unitario >= 0),
  CONSTRAINT fk_peca_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE estoque (
  id_estoque     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria   BIGINT UNSIGNED NOT NULL,
  nome           VARCHAR(100) NOT NULL,
  localizacao    VARCHAR(150) NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_estoque),
  UNIQUE KEY uq_estoque_nome (id_industria, nome),
  CONSTRAINT fk_estoque_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE item_estoque (
  id_item_estoque  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_peca          BIGINT UNSIGNED NOT NULL,
  id_estoque       BIGINT UNSIGNED NOT NULL,
  quantidade       INT NOT NULL DEFAULT 0,
  estoque_minimo   INT NOT NULL DEFAULT 0,
  estoque_maximo   INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id_item_estoque),
  UNIQUE KEY uq_item_peca_estoque (id_peca, id_estoque),
  CONSTRAINT ck_item_quantidade CHECK (quantidade >= 0),
  CONSTRAINT ck_item_minmax CHECK (estoque_minimo >= 0 AND estoque_minimo <= estoque_maximo),
  CONSTRAINT fk_item_peca FOREIGN KEY (id_peca)
    REFERENCES peca (id_peca)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_item_estoque FOREIGN KEY (id_estoque)
    REFERENCES estoque (id_estoque)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 5. ATIVOS REAIS
CREATE TABLE maquina (
  id_maquina             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria           BIGINT UNSIGNED NOT NULL,
  id_linha               BIGINT UNSIGNED NOT NULL,
  id_maquina_biblioteca  BIGINT UNSIGNED NULL,
  tag                    VARCHAR(50) NOT NULL,
  nome                   VARCHAR(120) NOT NULL,
  qr_code                VARCHAR(100) NULL,
  criticidade            ENUM('baixa','media','alta','critica') NOT NULL DEFAULT 'media', 
  status                 ENUM('operando','parada','em_manutencao','desativada') NOT NULL DEFAULT 'operando',
  created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_maquina),
  UNIQUE KEY uq_maquina_tag (id_industria, tag),
  UNIQUE KEY uq_maquina_qr (qr_code),
  CONSTRAINT fk_maquina_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_maquina_linha FOREIGN KEY (id_linha)
    REFERENCES linha_producao (id_linha)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_maquina_maqbib FOREIGN KEY (id_maquina_biblioteca)
    REFERENCES maquina_biblioteca (id_maquina_biblioteca)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE peca_maq (
  id_peca_maq              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_maquina               BIGINT UNSIGNED NOT NULL,
  id_peca_pai_biblioteca   BIGINT UNSIGNED NULL,
  id_peca                  BIGINT UNSIGNED NULL,
  nome                     VARCHAR(120) NOT NULL,
  numero_serie             VARCHAR(80) NULL,
  created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_peca_maq),
  CONSTRAINT fk_pm_maquina FOREIGN KEY (id_maquina)
    REFERENCES maquina (id_maquina)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pm_ppb FOREIGN KEY (id_peca_pai_biblioteca)
    REFERENCES peca_pai_biblioteca (id_componente)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pm_peca FOREIGN KEY (id_peca)
    REFERENCES peca (id_peca)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. MANUTENÇÃO
CREATE TABLE tipo_manutencao (
  id_tipo_manutencao  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome                VARCHAR(80) NOT NULL,
  descricao           VARCHAR(255) NULL,
  PRIMARY KEY (id_tipo_manutencao),
  UNIQUE KEY uq_tipo_manut_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE ordem_servico (
  id_os               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria        BIGINT UNSIGNED NOT NULL,
  numero              VARCHAR(30) NOT NULL,
  id_maquina          BIGINT UNSIGNED NOT NULL,
  id_peca_maq         BIGINT UNSIGNED NULL,
  id_tipo_manutencao  BIGINT UNSIGNED NOT NULL,
  id_solicitante      BIGINT UNSIGNED NOT NULL,
  id_responsavel      BIGINT UNSIGNED NULL,
  titulo              VARCHAR(150) NOT NULL,
  descricao           TEXT NULL,
  status              ENUM('aberta','em_andamento','aguardando_peca','concluida','cancelada') NOT NULL DEFAULT 'aberta',
  prioridade          ENUM('baixa','media','alta','urgente') NOT NULL DEFAULT 'media',
  data_abertura       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_fechamento     DATETIME NULL,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_os),
  UNIQUE KEY uq_os_numero (id_industria, numero),
  KEY idx_os_status (status, prioridade),
  CONSTRAINT ck_os_datas CHECK (data_fechamento IS NULL OR data_fechamento >= data_abertura),
  CONSTRAINT fk_os_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_os_maquina FOREIGN KEY (id_maquina)
    REFERENCES maquina (id_maquina)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_os_peca_maq FOREIGN KEY (id_peca_maq)
    REFERENCES peca_maq (id_peca_maq)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_os_tipo FOREIGN KEY (id_tipo_manutencao)
    REFERENCES tipo_manutencao (id_tipo_manutencao)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_os_solicitante FOREIGN KEY (id_solicitante)
    REFERENCES usuario (id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_os_responsavel FOREIGN KEY (id_responsavel)
    REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 7. MOVIMENTAÇÃO DE ESTOQUE
CREATE TABLE mov_estoque (
  id_mov_estoque   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_item_estoque  BIGINT UNSIGNED NOT NULL,
  id_usuario       BIGINT UNSIGNED NOT NULL,
  id_os            BIGINT UNSIGNED NULL,
  tipo_movim       ENUM('entrada','saida','ajuste') NOT NULL,
  quantidade       INT NOT NULL,
  motivo           VARCHAR(255) NULL,
  data_hora        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_mov_estoque),
  KEY idx_mov_data (data_hora),
  CONSTRAINT ck_mov_quantidade CHECK (quantidade > 0),
  CONSTRAINT fk_mov_item FOREIGN KEY (id_item_estoque)
    REFERENCES item_estoque (id_item_estoque)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mov_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mov_os FOREIGN KEY (id_os)
    REFERENCES ordem_servico (id_os)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 8. AUDITORIA
CREATE TABLE historico_geral (
  id_historico      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_industria      BIGINT UNSIGNED NOT NULL,
  id_usuario        BIGINT UNSIGNED NOT NULL,
  entidade          VARCHAR(50) NOT NULL,
  id_entidade       BIGINT UNSIGNED NOT NULL,
  acao              ENUM('criacao','alteracao','exclusao','status') NOT NULL,
  valores_antes     JSON NULL,
  valores_depois    JSON NULL,
  observacao        VARCHAR(255) NULL,
  data_hora         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_historico),
  KEY idx_hist_entidade (entidade, id_entidade),
  KEY idx_hist_data (id_industria, data_hora),
  CONSTRAINT fk_hist_industria FOREIGN KEY (id_industria)
    REFERENCES industria (id_industria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_hist_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =====================================================================
-- SCRIPT DE POVOAMENTO COMPLETO - STARTUP ENGRENAR
-- =====================================================================

USE engrenar;

-- 1. CARGOS (Necessário antes de cadastrar usuários)
INSERT INTO cargo (id_cargo, nome, descricao) VALUES
  (1, 'Gestor', 'Acesso total à indústria'),
  (2, 'Engenheiro de manutenção', 'Gerencia OS, equipe e planejamento'),
  (3, 'Técnico de manutenção', 'Executa ordens de serviço'),
  (4, 'Almoxarife', 'Controla estoque e movimentações');

-- 2. TIPOS DE MANUTENÇÃO
INSERT INTO tipo_manutencao (id_tipo_manutencao, nome, descricao) VALUES
  (1, 'Preventiva', 'Programada para evitar falhas'),
  (2, 'Corretiva', 'Executada após a falha'),
  (3, 'Preditiva', 'Baseada em monitoramento de condição'),
  (4, 'Inspeção', 'Verificação periódica sem intervenção');

-- 3. SEGMENTOS INDUSTRIAIS E INDÚSTRIA
INSERT INTO segmento_industrial (id_segmento, nome, atividade_economica, descricao) VALUES
  (1, 'Metalurgia e Siderurgia', 'Fabricação de produtos de metal', 'Indústrias de transformação de metais pesados'),
  (2, 'Automotivo', 'Fabricação de veículos automotores', 'Montadoras e autopeças');

INSERT INTO industria (id_industria, id_segmento, razao_social, cnpj, cnae, inscricao_estadual, ativo) VALUES
  (1, 1, 'Engrenar Aços Especiais S.A.', '12345678000199', '2411-3/00', '123456789', 1);

-- 4. ESTRUTURA FÍSICA (Unidade, Setor, Linha de Produção)
INSERT INTO unidade (id_unidade, id_industria, nome, endereco) VALUES
  (1, 1, 'Planta Ponta Grossa - Matriz', 'Rodovia do Mate, km 100');

INSERT INTO setor (id_setor, id_unidade, nome) VALUES
  (1, 1, 'Fundição e Laminação'),
  (2, 1, 'Usinagem de Precisão');

INSERT INTO linha_producao (id_linha, id_setor, nome) VALUES
  (1, 1, 'Linha de Laminação a Quente 01'),
  (2, 2, 'Centro de Usinagem CNC 03');

-- 5. BIBLIOTECA DE MÁQUINAS (Diferencial do Engrenar)
INSERT INTO fabricante (id_fabricante, nome) VALUES
  (1, 'Siemag Demag'),
  (2, 'Mazak Corporation');

INSERT INTO maquina_biblioteca (id_maquina_biblioteca, id_fabricante, modelo, tag, descricao) VALUES
  (1, 1, 'Laminador Universal 4 High', 'BIB-LAM-01', 'Template padrão para laminadores de chapas'),
  (2, 2, 'CNC Vertical Variaxis', 'BIB-CNC-02', 'Template para centros de usinagem multieixos');

INSERT INTO segmento_maquina_biblioteca (id_segmento, id_maquina_biblioteca) VALUES
  (1, 1),
  (2, 2);

INSERT INTO template_maquina (id_template, id_maquina_biblioteca, nome, descricao) VALUES
  (1, 1, 'Template Laminador Principal', 'Estrutura mecânica base do laminador'),
  (2, 2, 'Template CNC Padrão', 'Estrutura base do centro de usinagem');

INSERT INTO peca_pai_biblioteca (id_componente, id_template, nome, descricao, quantidade, criticidade, vida_util) VALUES
  (1, 1, 'Cilindro de Laminação', 'Cilindro de trabalho principal', 2, 'alta', 5000),
  (2, 2, 'Eixo Árvore (Spindle)', 'Eixo principal de rotação do CNC', 1, 'critica', 8000);

-- 6. ESTOQUE E PEÇAS
INSERT INTO peca (id_peca, id_industria, codigo, nome, descricao, unidade_medida, valor_unitario) VALUES
  (1, 1, 'PEC-001', 'Rolamento de Rolos Cilíndricos', 'Rolamento industrial blindado', 'un', 1500.00),
  (2, 1, 'PEC-002', 'Correia de Transmissão V', 'Correia de alta resistência', 'un', 120.50);

INSERT INTO estoque (id_estoque, id_industria, nome, localizacao) VALUES
  (1, 1, 'Almoxarifado Central', 'Galpão 01 - Corredor B');

INSERT INTO item_estoque (id_item_estoque, id_peca, id_estoque, quantidade, estoque_minimo, estoque_maximo) VALUES
  (1, 1, 1, 10, 2, 20),
  (2, 2, 1, 25, 5, 50);

-- 7. ATIVOS REAIS (Máquinas instaladas na fábrica)
INSERT INTO maquina (id_maquina, id_industria, id_linha, id_maquina_biblioteca, tag, nome, qr_code, criticidade, status) VALUES
  (1, 1, 1, 1, 'MQ-LAM-01', 'Laminador Principal A', 'QR-ENG-99881', 'alta', 'operando'),
  (2, 1, 2, 2, 'MQ-CNC-05', 'Centro de Usinagem 05', 'QR-ENG-99882', 'critica', 'operando');

INSERT INTO peca_maq (id_peca_maq, id_maquina, id_peca_pai_biblioteca, id_peca, nome, numero_serie) VALUES
  (1, 1, 1, 1, 'Cilindro Setor A', 'SN-9981-A'),
  (2, 2, 2, 2, 'Spindle CNC 05', 'SN-5542-X');

-- 8. USUÁRIOS (Equipe da Indústria)
INSERT INTO usuario (id_usuario, id_industria, id_cargo, id_setor, nome, matricula, email, senha_hash, ativo) VALUES
  (1, 1, 1, 1, 'Carlos Roberto', '1001', 'carlos.gestor@engrenar.invalid', 'HASH_SEGUR1', 1),
  (2, 1, 2, 1, 'Roberto Gomes', '1002', 'roberto.engenheiro@engrenar.invalid', 'HASH_SEGUR2', 1),
  (3, 1, 3, 2, 'Marcos Aurelio', '1003', 'marcos.mecanico@engrenar.invalid', 'HASH_SEGUR3', 1),
  (4, 1, 4, 1, 'Ana Silva', '1004', 'ana.analista@engrenar.invalid', 'HASH_SEGUR4', 1);

-- 9. MANUTENÇÃO (Ordens de Serviço)
INSERT INTO ordem_servico (id_os, id_industria, numero, id_maquina, id_peca_maq, id_tipo_manutencao, id_solicitante, id_responsavel, titulo, descricao, status, prioridade, data_abertura) VALUES
  (1, 1, 'OS-2026-0001', 1, 1, 1, 2, 3, 'Lubrificação e Inspeção Preventiva', 'Verificar folgas no cilindro de laminação', 'em_andamento', 'alta', '2026-11-17 08:00:00');

-- 10. MOVIMENTAÇÃO DE ESTOQUE
INSERT INTO mov_estoque (id_mov_estoque, id_item_estoque, id_usuario, id_os, tipo_movim, quantidade, motivo, data_hora) VALUES
  (1, 1, 4, 1, 'saida', 1, 'Substituição preventiva em OS-2026-0001', '2026-11-17 09:30:00');


-- TESTES-------------

-- TESTE DE ESTRUTURA:
USE engrenar;
DESCRIBE peca;
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'engrenar' 
  AND TABLE_NAME = 'industria' 
  AND CONSTRAINT_NAME LIKE '%uq%';
  

-- TESTE DE RESTRIÇÕES
USE engrenar;
START TRANSACTION;
-- Tentativa inválida: preço negativo (Deve falhar com Erro 3819)
INSERT INTO peca (id_industria, codigo, nome, unidade_medida, valor_unitario) 
VALUES (1, 'ERR-01', 'Peça com Erro', 'un', -10.00);
ROLLBACK;

-- TESTE DE TRIGGERS
USE engrenar;
START TRANSACTION;
SELECT id_item_estoque, quantidade FROM item_estoque WHERE id_item_estoque = 1;
INSERT INTO mov_estoque (id_item_estoque, id_usuario, id_os, tipo_movim, quantidade, motivo) 
VALUES (1, 4, 1, 'saida', 2, 'Teste de integridade de movimentação');
SELECT 'Movimentação aplicada com sucesso' AS status_teste;
ROLLBACK;


-- TESTE DE TRANSAÇÕES:
USE engrenar;
START TRANSACTION;
UPDATE maquina SET status = 'em_manutencao' WHERE id_maquina = 1;
INSERT INTO ordem_servico (id_industria, numero, id_maquina, id_tipo_manutencao, id_solicitante, titulo, status, prioridade) 
VALUES (1, 'OS-TEST-99', 1, 1, 2, 'Manutenção Corretiva Urgente', 'aberta', 'alta');
ROLLBACK;
SELECT id_maquina, status FROM maquina WHERE id_maquina = 1;


-- TESTE DE QUALIDADE DE DADOS: PFV N DEVE RETORNAR NADAAAA
USE engrenar;
SELECT id_os, numero, data_abertura, data_fechamento 
FROM ordem_servico 
WHERE data_fechamento IS NOT NULL 
  AND data_fechamento < data_abertura;
  

-- TESTE DE DESEMPENHO:  
USE engrenar;
EXPLAIN 
SELECT p.codigo, p.nome, ie.quantidade, ie.estoque_minimo
FROM item_estoque ie
JOIN peca p ON p.id_peca = ie.id_peca
WHERE ie.quantidade <= ie.estoque_minimo;

USE engrenar;


-- Segmento ind. cadastrar: 
INSERT INTO segmento_industrial (nome, atividade_economica, descricao)
VALUES ('Alimentício', 'Fabricação de produtos alimentícios', 'Segmento industrial');


INSERT INTO industria (id_segmento, razao_social, cnpj, ativo)
VALUES (1, 'Mars Petcare', '12345678000199', 1);

-- Cadastro do cargo do usuario:
INSERT INTO cargo (nome, descricao) VALUES
('Gestor de Manutenção', 'Acesso completo, KPIs, gráficos e 21 tabelas'),
('Mecânico Industrial', 'Visão de campo: OS, ativos com QR Code e estoque');

-- Teste do crud
SELECT id_maquina, tag, nome, criticidade, status
FROM engrenar.maquina
WHERE tag = 'VIDEOTESTE-001';

-- join das tabelas
SELECT
    m.id_maquina,
    m.tag AS tag_maquina,
    m.nome AS maquina,
    o.numero AS numero_os,
    o.titulo AS servico,
    o.status AS status_os
FROM engrenar.maquina AS m
JOIN engrenar.ordem_servico AS o
    ON o.id_maquina = m.id_maquina
   AND o.id_industria = m.id_industria
WHERE m.tag = 'VIDEOTESTE-001';

