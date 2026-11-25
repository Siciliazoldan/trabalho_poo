package DAO;

import java.sql.*;
import java.util.*;

public final class UsuarioDAO extends DAO {
    private static final String PERFIL = """
        FROM usuario u JOIN cargo c USING (id_cargo) JOIN industria i USING (id_industria)
        JOIN segmento_industrial s USING (id_segmento)
        WHERE u.ativo=1 AND i.ativo=1
        """;
    private static final String CAMPOS = """
        SELECT u.id_usuario,u.id_industria,u.nome,i.razao_social,i.id_segmento,s.nome AS segmento,c.nome AS cargo
        """;
    public UsuarioDAO(Connection db) { super(db); }

    public Map<String,Object> identificar(String login) throws SQLException {
        var matches = rows(CAMPOS + ",u.senha_hash " + PERFIL + " AND (u.email=? OR u.matricula=?) LIMIT 2",login,login);
        if (matches.size() > 1) throw new IllegalArgumentException("Use seu e-mail para identificar a indústria.");
        return matches.isEmpty() ? null : matches.get(0);
    }

    public Map<String,Object> perfil(long id) throws SQLException {
        var matches = rows(CAMPOS + PERFIL + " AND u.id_usuario=?",id);
        return matches.isEmpty() ? null : matches.get(0);
    }

    public void definirSenha(String email, String hash) throws SQLException {
        require(hash.matches("\\$2[aby]\\$[0-9]{2}\\$[./A-Za-z0-9]{53}"), "Hash inválido.");
        require(execute("UPDATE usuario SET senha_hash=? WHERE email=? AND ativo=1",hash,email)==1,
                "E-mail de usuário ativo não encontrado.");
    }
}
