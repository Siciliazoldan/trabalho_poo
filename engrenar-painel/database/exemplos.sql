-- Opcional. Execute em uma base recém-criada.
START TRANSACTION;
-- 1. CARGOS (Necessário antes de cadastrar usuários)
INSERT INTO cargo (id_cargo, nome, descricao) VALUES
  (1, 'Administrador', 'Acesso total à indústria'),
  (2, 'Gestor de manutenção', 'Gerencia OS, equipe e planejamento'),
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
  (1, 1, 1, 1, 'Carlos Administrador', 'MAT-001', 'carlos@engrenar.invalid', 'HASH_SEGUR1', 1),
  (2, 1, 2, 1, 'Roberto Gestor', 'MAT-002', 'roberto@engrenar.invalid', 'HASH_SEGUR2', 1),
  (3, 1, 3, 2, 'Marcos Técnico', 'MAT-003', 'marcos@engrenar.invalid', 'HASH_SEGUR3', 1),
  (4, 1, 4, 1, 'Ana Almoxarife', 'MAT-004', 'ana.almox@engrenar.invalid', 'HASH_SEGUR4', 1);

-- 9. MANUTENÇÃO (Ordens de Serviço)
INSERT INTO ordem_servico (id_os, id_industria, numero, id_maquina, id_peca_maq, id_tipo_manutencao, id_solicitante, id_responsavel, titulo, descricao, status, prioridade, data_abertura) VALUES
  (1, 1, 'OS-2026-0001', 1, 1, 1, 2, 3, 'Lubrificação e Inspeção Preventiva', 'Verificar folgas no cilindro de laminação', 'em_andamento', 'alta', '2026-11-17 08:00:00');

-- 10. MOVIMENTAÇÃO DE ESTOQUE
INSERT INTO mov_estoque (id_mov_estoque, id_item_estoque, id_usuario, id_os, tipo_movim, quantidade, motivo, data_hora) VALUES
  (1, 1, 4, 1, 'saida', 1, 'Substituição preventiva em OS-2026-0001', '2026-11-17 09:30:00');
COMMIT;