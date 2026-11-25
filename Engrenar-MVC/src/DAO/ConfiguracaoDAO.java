package DAO;

import java.sql.*;
import java.util.Map;

public final class ConfiguracaoDAO extends DAO {
    public ConfiguracaoDAO(Connection db) { super(db); }
    public Map<String,Object> verificar() throws SQLException {
        rows("SELECT m.id_maquina,o.id_os FROM maquina m JOIN ordem_servico o ON o.id_maquina=m.id_maquina LIMIT 0");
        return rows("SELECT DATABASE() AS banco, EXISTS(SELECT 1 FROM usuario) AS tem_conta").get(0);
    }
    public boolean primeiroAcesso(String email, String hash) throws SQLException {
        require(email.length()<=150 && email.matches("[^@ ]+@[^@ ]+"),"E-mail inválido.");
        require(hash.matches("\\$2[aby]\\$[0-9]{2}\\$[./A-Za-z0-9]{53}"),"Senha inválida.");
        // O primeiro cadastro é serializado pelo registro do cargo até o commit.
        var cargo=rows("SELECT id_cargo FROM cargo WHERE nome='Administrador' FOR UPDATE");
        require(!cargo.isEmpty(),"Cadastre o cargo Administrador antes de continuar.");
        require(rows("SELECT id_usuario FROM usuario LIMIT 1 FOR UPDATE").isEmpty(),"O banco já possui usuários.");
        var industrias=rows("SELECT id_industria FROM industria WHERE ativo=1 ORDER BY id_industria LIMIT 2 FOR UPDATE");
        require(industrias.size()<=1,"Há várias indústrias. Cadastre o primeiro administrador na indústria desejada usando a administração existente.");
        long industria;
        if (industrias.isEmpty()) {
            var segmentos=rows("SELECT id_segmento FROM segmento_industrial WHERE nome='Manutenção industrial'");
            long segmento=segmentos.isEmpty()?insert("INSERT INTO segmento_industrial(nome) VALUES (?)","Manutenção industrial"):
                ((Number)segmentos.get(0).get("id_segmento")).longValue();
            industria=insert("INSERT INTO industria(id_segmento,razao_social,cnpj) VALUES (?,?,?)",segmento,"Engrenar (protótipo)","00000000000000");
            long unidade=insert("INSERT INTO unidade(id_industria,nome) VALUES (?,?)",industria,"Unidade de demonstração");
            long setor=insert("INSERT INTO setor(id_unidade,nome) VALUES (?,?)",unidade,"Manutenção");
            insert("INSERT INTO linha_producao(id_setor,nome) VALUES (?,?)",setor,"Linha 01");
        } else industria=((Number)industrias.get(0).get("id_industria")).longValue();
        insert("INSERT INTO usuario(id_industria,id_cargo,nome,matricula,email,senha_hash) VALUES (?,?,?,?,?,?)",
            industria,cargo.get(0).get("id_cargo"),"Administrador","ADMIN",email,hash);
        return true;
    }
}
