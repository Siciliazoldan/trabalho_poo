package Controller;

import Util.ConnectionFactory;
import com.google.gson.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

public final class Requisicao {
    public static void main(String[] args) {
        var saida = new PrintStream(System.out, true, StandardCharsets.UTF_8);
        var json = new GsonBuilder().serializeNulls().create();
        try {
            var in = JsonParser.parseReader(new InputStreamReader(System.in, StandardCharsets.UTF_8)).getAsJsonObject();
            var cfg = in.getAsJsonObject("config");
            try (var db = ConnectionFactory.getConnection(cfg.get("host").getAsString(), cfg.get("port").getAsInt(),
                    cfg.get("database").getAsString(),cfg.get("user").getAsString(),cfg.get("password").getAsString())) {
                db.setAutoCommit(false);
                try {
                    var action = in.get("action").getAsString();
                    var fields = in.getAsJsonObject("fields");
                    Object result = switch (action) {
                        case "conexao" -> new DAO.ConfiguracaoDAO(db).verificar();
                        case "primeiro" -> new DAO.ConfiguracaoDAO(db).primeiroAcesso(
                                fields.get("email").getAsString(), fields.get("hash").getAsString());
                        default -> new PainelController(db, fields).atender(action);
                    };
                    db.commit();
                    saida.print(json.toJson(Collections.singletonMap("resultado",result)));
                } catch (Exception e) { db.rollback(); throw e; }
            }
        } catch (Exception e) {
            String msg = "Não foi possível concluir a operação.";
            if (e instanceof SQLException sql) msg = switch (sql.getErrorCode()) {
                case 1045,1044 -> "O MySQL recusou as credenciais ou o acesso ao banco.";
                case 1049 -> "O banco informado não existe neste servidor.";
                case 1146,1054 -> "O esquema do banco não corresponde às tabelas do Engrenar. Consulte script/engrenar.sql.";
                case 1062 -> "Já existe um cadastro com essa identificação.";
                case 1451,1452 -> "Confira os registros vinculados antes de continuar.";
                default -> "Falha na conexão ou operação MySQL (código " + sql.getErrorCode() + "). Confira o serviço e a porta.";
            };
            else if (e instanceof IllegalArgumentException || e instanceof SecurityException) msg=e.getMessage();
            saida.print(json.toJson(Map.of("erro",msg)));
        }
    }
}


