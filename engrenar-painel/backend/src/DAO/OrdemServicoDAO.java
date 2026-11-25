package DAO;

import Model.OrdemServico;
import Model.Usuario;
import java.sql.*;
import java.time.Year;
import java.util.*;

public final class OrdemServicoDAO extends DAO {
    private static final String VERSAO = "SHA2(JSON_ARRAY(o.titulo,o.descricao,o.id_maquina,o.id_tipo_manutencao,o.id_responsavel,o.prioridade,o.status,o.id_peca_maq),256)";
    public OrdemServicoDAO(Connection db) { super(db); }

    public List<Map<String,Object>> tipos() throws SQLException {
        return rows("SELECT id_tipo_manutencao,nome FROM tipo_manutencao ORDER BY nome");
    }
    public List<Map<String,Object>> equipe(long industria) throws SQLException {
        return rows("SELECT id_usuario,nome FROM usuario WHERE id_industria=? AND ativo=1 ORDER BY nome", industria);
    }

    public List<Map<String,Object>> listar(long industria, long id, long responsavel, long maquina,
                                            String status, String busca, boolean pendentes, boolean recentes) throws SQLException {
        String sql = """
            SELECT o.id_os,o.numero,o.titulo,o.descricao,o.status,o.prioridade,o.id_maquina,o.id_tipo_manutencao,
                o.id_responsavel,o.data_abertura,o.data_fechamento,m.tag,m.nome AS maquina,t.nome AS tipo,
                r.nome AS responsavel,u.nome AS solicitante,
            """ + VERSAO + """
             AS versao FROM ordem_servico o JOIN maquina m ON m.id_maquina=o.id_maquina AND m.id_industria=o.id_industria
             JOIN tipo_manutencao t USING (id_tipo_manutencao) JOIN usuario u ON u.id_usuario=o.id_solicitante
             LEFT JOIN usuario r ON r.id_usuario=o.id_responsavel
             WHERE o.id_industria=? AND (?=0 OR o.id_os=?) AND (?=0 OR o.id_responsavel=?)
               AND (?=0 OR o.id_maquina=?) AND (?='' OR o.status=?)
               AND (?='' OR LOCATE(?,o.numero)>0 OR LOCATE(?,o.titulo)>0 OR LOCATE(?,m.tag)>0 OR LOCATE(?,m.nome)>0)
            """;
        if (pendentes) sql += " AND o.status IN ('aberta','em_andamento','aguardando_peca')";
        sql += " ORDER BY o.data_abertura DESC,o.id_os DESC";
        if (recentes) sql += " LIMIT 5";
        return rows(sql,industria,id,id,responsavel,responsavel,maquina,maquina,status,status,busca,busca,busca,busca,busca);
    }

    private void validar(Usuario u, OrdemServico o) throws SQLException {
        require(!rows("SELECT id_maquina FROM maquina WHERE id_industria=? AND id_maquina=? FOR SHARE",u.industria(),o.maquina()).isEmpty(),
                "Escolha um ativo desta indústria.");
        require(!rows("SELECT id_tipo_manutencao FROM tipo_manutencao WHERE id_tipo_manutencao=? FOR SHARE",o.tipo()).isEmpty(),
                "Tipo de manutenção inválido.");
        if (o.responsavel()!=null) require(!rows("SELECT id_usuario FROM usuario WHERE id_industria=? AND id_usuario=? AND ativo=1 FOR SHARE",
                u.industria(),o.responsavel()).isEmpty(), "Escolha um responsável ativo desta indústria.");
    }

    public String inserir(Usuario u, OrdemServico o) throws SQLException {
        validar(u,o);
        String numero = "OS-" + Year.now() + "-" + UUID.randomUUID().toString().replace("-","").substring(0,16).toUpperCase(Locale.ROOT);
        insert("""
            INSERT INTO ordem_servico(id_industria,numero,id_maquina,id_tipo_manutencao,id_solicitante,id_responsavel,titulo,descricao,prioridade)
            VALUES(?,?,?,?,?,?,?,?,?)
            """,u.industria(),numero,o.maquina(),o.tipo(),u.id(),o.responsavel(),o.titulo(),o.descricao(),o.prioridade());
        return numero;
    }

    private Map<String,Object> conferirVersao(Usuario u, long id, String versao) throws SQLException {
        var hit = rows("SELECT o.id_maquina,o.id_peca_maq,o.id_responsavel,o.status," + VERSAO +
                " AS versao FROM ordem_servico o WHERE o.id_industria=? AND o.id_os=? FOR UPDATE",u.industria(),id);
        require(!hit.isEmpty() && versao.equals(hit.get(0).get("versao")), "A ordem mudou ou foi excluída. Abra-a novamente.");
        return hit.get(0);
    }

    public void atualizar(Usuario u, long id, String versao, OrdemServico o) throws SQLException {
        var antes = conferirVersao(u,id,versao);
        require(antes.get("id_peca_maq")==null || ((Number)antes.get("id_maquina")).longValue()==o.maquina(),
                "Esta OS tem um componente vinculado. Mantenha o ativo original.");
        validar(u,o);
        execute("""
            UPDATE ordem_servico SET titulo=?,descricao=?,id_maquina=?,id_tipo_manutencao=?,id_responsavel=?,prioridade=?
            WHERE id_os=? AND id_industria=?
            """,o.titulo(),o.descricao(),o.maquina(),o.tipo(),o.responsavel(),o.prioridade(),id,u.industria());
    }

    public void atualizarStatus(Usuario u, long id, String versao, String novo) throws SQLException {
        var antes = conferirVersao(u,id,versao);
        Number dono = (Number)antes.get("id_responsavel");
        if (!u.gestao() && (dono==null || dono.longValue()!=u.id()))
            throw new SecurityException("Esta ordem está atribuída a outro responsável.");
        require(OrdemServico.STATUS.contains(novo),"Status inválido.");
        if (novo.equals(antes.get("status"))) return;
        execute("""
            UPDATE ordem_servico SET status=?,
              data_fechamento=CASE WHEN ? IN ('concluida','cancelada') THEN COALESCE(data_fechamento,NOW()) ELSE NULL END
            WHERE id_os=? AND id_industria=?
            """,novo,novo,id,u.industria());
    }

    public void excluir(Usuario u, long id, String versao) throws SQLException {
        conferirVersao(u,id,versao);
        require(rows("SELECT id_mov_estoque FROM mov_estoque WHERE id_os=? LIMIT 1 FOR UPDATE",id).isEmpty(),
                "Esta OS tem movimentação de estoque vinculada. Use o status Cancelada para preservar o histórico.");
        execute("DELETE FROM ordem_servico WHERE id_os=? AND id_industria=?",id,u.industria());
    }
}
