package DAO;

import java.sql.*;
import java.util.*;

public final class PainelDAO extends DAO {
    public PainelDAO(Connection db) { super(db); }

    private Map<String,Object> contagens(String sql, long industria) throws SQLException {
        Map<String,Object> result = new LinkedHashMap<>();
        for (var row : rows(sql,industria)) result.put((String)row.get("status"),row.get("n"));
        return result;
    }

    public Map<String,Object> indicadores(long industria) throws SQLException {
        return Map.of("ativos", contagens("SELECT status,COUNT(*) n FROM maquina WHERE id_industria=? GROUP BY status",industria),
                "ordens", contagens("SELECT status,COUNT(*) n FROM ordem_servico WHERE id_industria=? GROUP BY status",industria),
                "tipos", rows("""
                    SELECT t.nome,COUNT(*) n FROM ordem_servico o JOIN tipo_manutencao t USING(id_tipo_manutencao)
                    WHERE o.id_industria=? GROUP BY t.id_tipo_manutencao,t.nome ORDER BY n DESC,t.nome
                    """,industria));
    }
}
