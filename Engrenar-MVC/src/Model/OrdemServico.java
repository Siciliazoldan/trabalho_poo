package Model;

import java.util.Set;

public record OrdemServico(String titulo, String descricao, long maquina, long tipo, Long responsavel, String prioridade) {
    public static final Set<String> STATUS = Set.of("aberta","em_andamento","aguardando_peca","concluida","cancelada");
    public OrdemServico {
        if (titulo.isBlank() || titulo.length() > 150 || maquina <= 0 || tipo <= 0
                || !Set.of("baixa","media","alta","urgente").contains(prioridade))
            throw new IllegalArgumentException("Revise o título, o ativo, o tipo e a prioridade da ordem.");
        if (descricao.getBytes(java.nio.charset.StandardCharsets.UTF_8).length > 65535)
            throw new IllegalArgumentException("Reduza o tamanho da descrição.");
    }
}
