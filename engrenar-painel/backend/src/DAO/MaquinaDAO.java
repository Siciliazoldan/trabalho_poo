package DAO;

import Model.Maquina;
import java.sql.*;
import java.util.*;

public final class MaquinaDAO extends DAO {
    private static final String LOCAL = """
        FROM linha_producao l JOIN setor s USING (id_setor) JOIN unidade u USING (id_unidade)
        """;
    private static final String VERSAO = "SHA2(JSON_ARRAY(m.nome,m.tag,m.id_linha,m.criticidade,m.status),256)";
    public MaquinaDAO(Connection db) { super(db); }

    public List<Map<String,Object>> linhas(long industria) throws SQLException {
        return rows("SELECT l.id_linha,l.nome,s.nome AS setor " + LOCAL + " WHERE u.id_industria=? ORDER BY s.nome,l.nome",industria);
    }

    public List<Map<String,Object>> listar(long industria, String busca, String status, long id) throws SQLException {
        return rows("""
            SELECT m.id_maquina,m.nome,m.tag,m.id_linha,m.status,m.criticidade,s.nome AS setor,l.nome AS linha,
            (SELECT COUNT(*) FROM ordem_servico o WHERE o.id_industria=m.id_industria AND o.id_maquina=m.id_maquina
             AND o.status IN ('aberta','em_andamento','aguardando_peca')) AS pendentes,
            """ + VERSAO + """
             AS versao FROM maquina m JOIN linha_producao l USING (id_linha) JOIN setor s USING (id_setor)
             WHERE m.id_industria=? AND (?=0 OR m.id_maquina=?) AND (?='' OR m.status=?)
             AND (?='' OR LOCATE(?,m.nome)>0 OR LOCATE(?,m.tag)>0 OR LOCATE(?,l.nome)>0) ORDER BY m.tag
            """,industria,id,id,status,status,busca,busca,busca,busca);
    }

    private void validarLinha(long industria, long linha) throws SQLException {
        require(!rows("SELECT l.id_linha " + LOCAL + " WHERE l.id_linha=? AND u.id_industria=? FOR SHARE",linha,industria).isEmpty(),
                "Escolha uma linha desta indústria.");
    }

    public long inserir(long industria, Maquina m, Long modelo) throws SQLException {
        validarLinha(industria,m.linha());
        return insert("""
            INSERT INTO maquina(id_industria,id_linha,id_maquina_biblioteca,tag,nome,criticidade,status)
            VALUES(?,?,?,?,?,?,?)
            """,industria,m.linha(),modelo,m.tag(),m.nome(),m.criticidade(),m.status());
    }

    private void conferirVersao(long industria, long id, String versao) throws SQLException {
        var found = rows("SELECT "+VERSAO+" AS versao FROM maquina m WHERE id_industria=? AND id_maquina=? FOR UPDATE",industria,id);
        require(!found.isEmpty() && versao.equals(found.get(0).get("versao")), "O ativo mudou ou foi excluído. Abra-o novamente.");
    }

    public void atualizar(long industria, long id, String versao, Maquina m) throws SQLException {
        conferirVersao(industria,id,versao);
        validarLinha(industria,m.linha());
        execute("UPDATE maquina SET id_linha=?,tag=?,nome=?,criticidade=?,status=? WHERE id_maquina=? AND id_industria=?",
                m.linha(),m.tag(),m.nome(),m.criticidade(),m.status(),id,industria);
    }

    public void excluir(long industria, long id, String versao) throws SQLException {
        conferirVersao(industria,id,versao);
        require(rows("SELECT id_os FROM ordem_servico WHERE id_maquina=? LIMIT 1 FOR UPDATE",id).isEmpty(),
                "Este ativo tem ordens de serviço vinculadas. Ele pode ser desativado para preservar o histórico.");
        execute("DELETE FROM maquina WHERE id_maquina=? AND id_industria=?",id,industria);
    }
}
