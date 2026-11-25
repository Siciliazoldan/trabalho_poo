-- Execute em uma base vazia selecionada no cliente MySQL.
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