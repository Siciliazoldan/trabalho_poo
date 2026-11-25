import Controller.PainelController;
import DAO.UsuarioDAO;
import Util.ConnectionFactory;
import com.google.gson.*;
import com.sun.net.httpserver.*;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.*;
import java.util.Map;
import java.util.concurrent.Executors;

public final class Principal {
    private static final Gson JSON = new GsonBuilder().serializeNulls().create();
    private final byte[] chave;

    private Principal(String chave) { this.chave = chave.getBytes(StandardCharsets.UTF_8); }

    public static void main(String[] args) throws Exception {
        if (args.length==2 && args[0].equals("--definir-senha")) {
            try (var db=ConnectionFactory.getConnection()) {
                String hash = new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8)).readLine();
                if (hash==null) throw new IllegalArgumentException("Informe o hash pela entrada padrão.");
                new UsuarioDAO(db).definirSenha(args[1],hash);
                System.out.println("Senha do painel definida.");
            }
            return;
        }
        String chave = System.getenv("ENGRENAR_API_TOKEN");
        if (chave==null || chave.length()<32) throw new IllegalStateException("Inicie o painel pelo script iniciar.");
        try (var db=ConnectionFactory.getConnection(); var st=db.prepareStatement(
                "SELECT u.id_usuario,m.id_maquina,o.id_os FROM usuario u,maquina m,ordem_servico o LIMIT 0")) {
            st.executeQuery().close();
        } catch (SQLException e) {
            System.err.println("Falha ao abrir o banco Engrenar. Confira host, porta, banco, usuário e senha. MySQL " + e.getErrorCode() + ".");
            System.exit(1);
        }
        int porta = Integer.parseInt(ConnectionFactory.setting("ENGRENAR_API_PORT","8781"));
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1",porta),32);
        server.createContext("/api/",new Principal(chave)::atender);
        server.setExecutor(Executors.newFixedThreadPool(8));
        server.start();
        String launcher = System.getenv("ENGRENAR_LAUNCHER_PID");
        if (launcher != null) ProcessHandle.of(Long.parseLong(launcher)).ifPresentOrElse(
                p -> p.onExit().thenRun(() -> System.exit(0)), () -> System.exit(0));
        System.out.println("Backend Java conectado ao MySQL.");
    }

    private void atender(HttpExchange http) throws IOException {
        try (http) {
            String token = http.getRequestHeaders().getFirst("X-Engrenar-Token");
            if (token==null || !MessageDigest.isEqual(chave,token.getBytes(StandardCharsets.UTF_8))) {
                resposta(http,403,Map.of("erro","Acesso interno negado.")); return;
            }
            if (!http.getRequestMethod().equals("POST")) {
                resposta(http,405,Map.of("erro","Método inválido.")); return;
            }
            String acao=http.getRequestURI().getPath().substring("/api/".length());
            if (acao.equals("pronto")) { resposta(http,200,true); return; }
            byte[] body=http.getRequestBody().readNBytes(1024*1024+1);
            if (body.length>1024*1024) { resposta(http,413,Map.of("erro","Formulário muito grande.")); return; }
            Object result;
            try (Connection db=ConnectionFactory.getConnection()) {
                db.setAutoCommit(false);
                try {
                    var form = JsonParser.parseString(new String(body,StandardCharsets.UTF_8)).getAsJsonObject();
                    result = new PainelController(db,form).atender(acao);
                    db.commit();
                } catch (RuntimeException | SQLException e) {
                    db.rollback();
                    throw e;
                }
            } catch (SecurityException e) {
                resposta(http,403,Map.of("erro",e.getMessage())); return;
            } catch (IllegalArgumentException | JsonParseException | IllegalStateException | UnsupportedOperationException e) {
                String msg = e.getClass()==IllegalArgumentException.class ? e.getMessage() : "Confira os campos do formulário.";
                resposta(http,422,Map.of("erro",msg)); return;
            } catch (SQLException e) {
                System.err.printf("Ação %s. MySQL %d, SQLState %s.%n",acao,e.getErrorCode(),e.getSQLState());
                String msg = switch (e.getErrorCode()) {
                    case 1062 -> "Já existe um cadastro com esta identificação.";
                    case 1451,1452 -> "Há um vínculo que impede a operação. Confira os dados vinculados.";
                    case 1205,1213 -> "Outro usuário está alterando estes dados. Atualize a página e tente novamente.";
                    default -> null;
                };
                resposta(http,msg==null?503:409,Map.of("erro",msg==null?"O banco não pôde concluir a operação.":msg)); return;
            } catch (RuntimeException e) {
                System.err.println("Falha interna em " + acao + ": " + e.getClass().getSimpleName());
                resposta(http,500,Map.of("erro","Falha ao processar a operação.")); return;
            }
            resposta(http,200,result);
        }
    }

    private static void resposta(HttpExchange http,int code,Object data) throws IOException {
        byte[] bytes=JSON.toJson(data).getBytes(StandardCharsets.UTF_8);
        http.getResponseHeaders().set("Content-Type","application/json; charset=utf-8");
        http.getResponseHeaders().set("Cache-Control","no-store");
        http.sendResponseHeaders(code,bytes.length);
        http.getResponseBody().write(bytes);
    }
}
