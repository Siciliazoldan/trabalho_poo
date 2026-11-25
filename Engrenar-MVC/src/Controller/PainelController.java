package Controller;

import DAO.*;
import Model.*;
import com.google.gson.*;
import java.sql.*;
import java.util.*;

public final class PainelController {
    private final JsonObject form;
    private final Connection db;
    private final MaquinaDAO maquinas;
    private final OrdemServicoDAO ordens;
    private final BibliotecaDAO biblioteca;

    public PainelController(Connection db, JsonObject form) {
        this.db = db;
        this.form = form;
        maquinas = new MaquinaDAO(db);
        ordens = new OrdemServicoDAO(db);
        biblioteca = new BibliotecaDAO(db);
    }

    private String campo(String key) {
        JsonElement value = form.get(key);
        return value == null || value.isJsonNull() ? "" : value.getAsString().strip();
    }
    private long id(String key) {
        String s = campo(key);
        if (s.isEmpty()) return 0;
        try {
            long value = Long.parseLong(s);
            if (value >= 0) return value;
        } catch (NumberFormatException ignored) {}
        throw new IllegalArgumentException("Identificador inválido.");
    }
    private Long opcional(String key) { long n=id(key); return n==0 ? null : n; }
    private Maquina maquina() {
        return new Maquina(campo("nome"),campo("tag"),id("linha"),campo("criticidade"),campo("status"));
    }
    private OrdemServico ordem(Usuario u) {
        Long responsavel = u.gestao() ? opcional("id_responsavel") : Long.valueOf(u.id());
        return new OrdemServico(campo("titulo"),campo("descricao"),id("id_maquina"),id("id_tipo_manutencao"),responsavel,campo("prioridade"));
    }
    private Object primeira(List<Map<String,Object>> linhas) {
        return linhas.isEmpty() ? null : linhas.get(0);
    }

    public Object atender(String acao) throws SQLException {
        UsuarioDAO usuarios = new UsuarioDAO(db);
        if (acao.equals("identificar")) return usuarios.identificar(campo("login"));
        var perfil = usuarios.perfil(id("usuario"));
        if (acao.equals("perfil")) return perfil;
        if (perfil==null) throw new SecurityException("Sua conta não está ativa.");
        Usuario u = Usuario.de(perfil);
        long id = id("id");
        long industria = u.industria();
        String versao = campo("versao");
        return switch (acao) {
            case "painel" -> {
                if (u.gestao()) yield Map.of("data",new PainelDAO(db).indicadores(industria),
                        "orders",ordens.listar(industria,0,0,0,"","",false,true));
                yield Map.of("orders",ordens.listar(industria,0,u.id(),0,"","",true,false),
                        "assets",maquinas.listar(industria,"","",0));
            }
            case "ativos" -> {
                var dados = new HashMap<String,Object>();
                dados.put("assets",maquinas.listar(industria,campo("q"),campo("status"),0));
                dados.put("lines",u.gestao()?maquinas.linhas(industria):List.of());
                dados.put("detail",id==0?null:primeira(maquinas.listar(industria,"","",id)));
                yield dados;
            }
            case "ativo.criar" -> { u.exigirGestao(); yield maquinas.inserir(industria,maquina(),null); }
            case "ativo.editar" -> { u.exigirGestao(); maquinas.atualizar(industria,id,versao,maquina()); yield true; }
            case "ativo.excluir" -> { u.exigirGestao(); maquinas.excluir(industria,id,versao); yield true; }
            case "ordens" -> {
                var dados = new HashMap<String,Object>();
                dados.put("orders",ordens.listar(industria,0,campo("mine").equals("1")?u.id():0,id("machine"),campo("status"),campo("q"),false,false));
                dados.put("machines",maquinas.listar(industria,"","",0));
                dados.put("types",ordens.tipos());
                dados.put("users",u.gestao()?ordens.equipe(industria):List.of());
                dados.put("detail",id==0?null:primeira(ordens.listar(industria,id,0,0,"","",false,false)));
                yield dados;
            }
            case "os.criar" -> ordens.inserir(u,ordem(u));
            case "os.editar" -> { u.exigirGestao(); ordens.atualizar(u,id,versao,ordem(u)); yield true; }
            case "os.status" -> { ordens.atualizarStatus(u,id,versao,campo("status")); yield true; }
            case "os.excluir" -> { u.exigirGestao(); ordens.excluir(u,id,versao); yield true; }
            case "biblioteca" -> {
                u.exigirGestao();
                var dados = new HashMap<String,Object>();
                dados.put("machines",biblioteca.modelos(id("segment"),campo("q"),0));
                dados.put("segments",biblioteca.segmentos());
                dados.put("makers",biblioteca.fabricantes());
                dados.put("lines",maquinas.linhas(industria));
                dados.put("selected",id==0?null:primeira(biblioteca.modelos(0,"",id)));
                dados.put("templates",id==0?List.of():biblioteca.estruturas(id));
                dados.put("compatible",id!=0 && biblioteca.compativel(id,u.segmento()));
                yield dados;
            }
            case "modelo.criar" -> {
                u.exigirGestao();
                Set<Long> segmentos = new LinkedHashSet<>();
                if (form.has("segmentos") && form.get("segmentos").isJsonArray())
                    for (JsonElement e : form.getAsJsonArray("segmentos")) segmentos.add(e.getAsLong());
                biblioteca.criar(campo("modelo"),campo("tag"),campo("descricao"),opcional("fabricante"),segmentos);
                yield true;
            }
            case "modelo.instalar" -> { u.exigirGestao(); biblioteca.instalar(u,id,id("template"),maquina()); yield true; }
            default -> throw new IllegalArgumentException("Ação desconhecida.");
        };
    }
}
