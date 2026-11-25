package Model;

import java.util.Set;

public record Maquina(String nome, String tag, long linha, String criticidade, String status) {
    public Maquina {
        if (nome.isBlank() || nome.length() > 120 || tag.isBlank() || tag.length() > 50 || linha <= 0
                || !Set.of("baixa","media","alta","critica").contains(criticidade)
                || !Set.of("operando","parada","em_manutencao","desativada").contains(status))
            throw new IllegalArgumentException("Confira o nome, a TAG, a linha, a criticidade e a condição do ativo.");
    }
}
