package DAO;

import Model.Maquina;
import Model.Usuario;
import java.sql.*;
import java.util.*;

public final class BibliotecaDAO extends DAO {
    public BibliotecaDAO(Connection db) { super(db); }

    public List<Map<String,Object>> segmentos() throws SQLException {
        return rows("SELECT id_segmento,nome FROM segmento_industrial ORDER BY nome");
    }
    public List<Map<String,Object>> fabricantes() throws SQLException {
        return rows("SELECT id_fabricante,nome FROM fabricante ORDER BY nome");
    }

    public List<Map<String,Object>> modelos(long segmento, String busca, long id) throws SQLException {
        return rows("""
            SELECT b.id_maquina_biblioteca,b.modelo,b.tag,b.descricao,f.nome AS fabricante,
               (SELECT GROUP_CONCAT(s.nome ORDER BY s.nome SEPARATOR ' · ')
                FROM segmento_maquina_biblioteca sm JOIN segmento_industrial s USING(id_segmento)
                WHERE sm.id_maquina_biblioteca=b.id_maquina_biblioteca) AS segmentos
            FROM maquina_biblioteca b LEFT JOIN fabricante f USING(id_fabricante)
            WHERE (?=0 OR b.id_maquina_biblioteca=?) AND (?=0 OR EXISTS(SELECT 1 FROM segmento_maquina_biblioteca sm
              WHERE sm.id_maquina_biblioteca=b.id_maquina_biblioteca AND sm.id_segmento=?))
              AND (?='' OR LOCATE(?,b.modelo)>0 OR LOCATE(?,b.tag)>0 OR LOCATE(?,f.nome)>0)
            ORDER BY b.modelo
            """,id,id,segmento,segmento,busca,busca,busca,busca);
    }

    public boolean compativel(long modelo, long segmento) throws SQLException {
        return !rows("SELECT id_segmento FROM segmento_maquina_biblioteca WHERE id_maquina_biblioteca=? AND id_segmento=? LOCK IN SHARE MODE",
                modelo,segmento).isEmpty();
    }

    public List<Map<String,Object>> estruturas(long modelo) throws SQLException {
        return rows("""
            SELECT t.id_template,t.nome,p.nome AS componente,p.quantidade,p.vida_util FROM template_maquina t
            LEFT JOIN peca_pai_biblioteca p USING(id_template) WHERE t.id_maquina_biblioteca=?
            ORDER BY t.nome,p.nome
            """,modelo);
    }

    public void criar(String modelo, String tag, String descricao, Long fabricante, Set<Long> segmentos) throws SQLException {
        require(!modelo.isBlank() && modelo.length()<=120 && tag.length()<=50 && !segmentos.isEmpty()
                && descricao.getBytes(java.nio.charset.StandardCharsets.UTF_8).length<=65535,
                "Informe o modelo, uma descrição válida e pelo menos um segmento.");
        require(rows("SELECT id_maquina_biblioteca FROM maquina_biblioteca WHERE id_fabricante <=> ? AND modelo=? FOR UPDATE",
                fabricante,modelo).isEmpty(), "Este modelo já está cadastrado.");
        long id = insert("INSERT INTO maquina_biblioteca(modelo,tag,descricao,id_fabricante) VALUES(?,?,?,?)",modelo,tag,descricao,fabricante);
        for (long segmento : segmentos) execute("INSERT INTO segmento_maquina_biblioteca(id_segmento,id_maquina_biblioteca) VALUES(?,?)",segmento,id);
    }

    public void instalar(Usuario u, long modelo, long estrutura, Maquina m) throws SQLException {
        require(compativel(modelo,u.segmento()),"O modelo pertence a outro segmento industrial.");
        long ativo = new MaquinaDAO(db).inserir(u.industria(),m,modelo);
        if (estrutura==0) return;
        require(!rows("SELECT id_template FROM template_maquina WHERE id_template=? AND id_maquina_biblioteca=? LOCK IN SHARE MODE",
                estrutura,modelo).isEmpty(),"A estrutura não pertence ao modelo.");
        var componentes = rows("SELECT id_componente,nome,quantidade FROM peca_pai_biblioteca WHERE id_template=? LOCK IN SHARE MODE",estrutura);
        try (PreparedStatement st = db.prepareStatement("INSERT INTO peca_maq(id_maquina,id_peca_pai_biblioteca,nome) VALUES(?,?,?)")) {
            for (var c : componentes) {
                st.setLong(1,ativo);
                st.setObject(2,c.get("id_componente"));
                st.setObject(3,c.get("nome"));
                for (long i=0; i<((Number)c.get("quantidade")).longValue(); i++) st.executeUpdate();
            }
        }
    }
}

