<?php
final class Auth {
    public static function user(): ?array { return $_SESSION['user'] ?? null; }
    public static function check(): bool { return self::user() !== null; }

    public static function requireLogin(): void {
        if (!self::check()) { header('Location: index.php?route=login'); exit; }
    }

    public static function profile(string $cargo): ?string {
        $cargo = mb_strtolower(trim($cargo), 'UTF-8');
        if (preg_match('/^(administrador[a]?|gestor[a]?|engenheir[oa]|analista)\b/u', $cargo)) return 'gestao';
        if (preg_match('/^(t[ée]cnic[oa]|mec[âa]nic[oa]|eletricista|almoxarife)\b/u', $cargo)) return 'operacao';
        return null;
    }

    public static function canManage(): bool { return (self::user()['perfil'] ?? null) === 'gestao'; }
}
