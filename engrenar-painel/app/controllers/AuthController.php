<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../models/User.php';

final class AuthController extends Controller {
    public function login(): void {
        if (Auth::check()) $this->redirect('index.php?route=dashboard');
        $error = null;
        $login = '';
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $login = $this->input('login');
            try {
                $model = new User();
                $user = $model->findForLogin($login);
                if ($user && password_verify((string)($_POST['password'] ?? ''),$user['senha_hash']) && Auth::profile($user['cargo'])) {
                    session_regenerate_id(true);
                    $_SESSION = ['user'=>$model->sessionUser($user),'csrf'=>bin2hex(random_bytes(32))];
                    $this->redirect('index.php?route=dashboard');
                }
                $error = 'Confira a matrícula ou o e-mail e a senha e tente novamente.';
            } catch (DomainException $e) { $error = $e->getMessage(); }

        }
        $this->view('login', compact('error','login'));
    }

    public function logout(): void {
        unset($_SESSION['user'],$_SESSION['success']);
        session_regenerate_id(true);
        $_SESSION['csrf']=bin2hex(random_bytes(32));
        $this->redirect('index.php?route=login');
    }
}
