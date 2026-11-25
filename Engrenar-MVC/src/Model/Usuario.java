package Model;

import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

public record Usuario(long id, long industria, long segmento, boolean gestao) {
    private static final Pattern GESTAO = Pattern.compile("^(administrador[a]?|gestor[a]?|engenheir[oa]|analista)\\b");
    private static final Pattern OPERACAO = Pattern.compile("^(t[ée]cnic[oa]|mec[âa]nic[oa]|eletricista|almoxarife)\\b");

    public static Usuario de(Map<String,Object> row) {
        String cargo = row.get("cargo").toString().strip().toLowerCase(Locale.ROOT);
        boolean gestor = GESTAO.matcher(cargo).find();
        if (!gestor && !OPERACAO.matcher(cargo).find()) throw new SecurityException("Cargo sem acesso ao painel.");
        return new Usuario(((Number)row.get("id_usuario")).longValue(), ((Number)row.get("id_industria")).longValue(),
                ((Number)row.get("id_segmento")).longValue(), gestor);
    }

    public void exigirGestao() {
        if (!gestao) throw new SecurityException("Esta ação exige um perfil de gestão.");
    }
}
