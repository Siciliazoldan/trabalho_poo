<?php
final class User {
    public function findForLogin(string $login): ?array { return Backend::call('identificar',['login'=>$login]); }
    public function current(): ?array { return Backend::call('perfil'); }

    public function sessionUser(array $u): array {
        return ['id'=>(int)$u['id_usuario'],'nome'=>$u['nome'],'industry'=>(int)$u['id_industria'],
            'segment'=>(int)$u['id_segmento'],'empresa'=>$u['razao_social'],'segmento'=>$u['segmento'],
            'cargo'=>$u['cargo'],'perfil'=>Auth::profile($u['cargo'])];
    }
}
