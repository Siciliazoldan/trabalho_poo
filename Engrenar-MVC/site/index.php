<?php
declare(strict_types=1);
if (!defined('ENGRENAR_ASSETS')) define('ENGRENAR_ASSETS', 'assets/');
date_default_timezone_set('America/Sao_Paulo');
require __DIR__.'/../app/core/sessao.php';
header('Cache-Control: no-store');
header('X-Content-Type-Options: nosniff');

require_once __DIR__ . '/../app/core/format.php';
require_once __DIR__ . '/../app/core/Backend.php';
require_once __DIR__ . '/../app/core/Auth.php';
if (!Backend::config()) { header("Location: config.php"); exit; }
foreach (['Auth','Dashboard','WorkOrder','Asset','Library'] as $name) {
    require_once __DIR__ . '/../app/controllers/' . $name . 'Controller.php';
}

$_SESSION['csrf'] ??= bin2hex(random_bytes(32));
$route = (string)($_GET['route'] ?? (Auth::check() ? 'dashboard' : 'login'));
$routes = [
    'login'=>[AuthController::class,'login'], 'logout'=>[AuthController::class,'logout'],
    'dashboard'=>[DashboardController::class,'index'], 'os'=>[WorkOrderController::class,'index'],
    'ativos'=>[AssetController::class,'index'], 'biblioteca'=>[LibraryController::class,'index']
];
function messagePage(int $code, string $message): never {
    http_response_code($code);
    require __DIR__ . '/../views/message.php';
    exit;
}
if (!isset($routes[$route])) messagePage(404,'Esta página não foi encontrada.');
if ($route !== 'login') Auth::requireLogin();
if ($route === 'logout' && $_SERVER['REQUEST_METHOD'] !== 'POST') messagePage(405,'Use a opção Sair do menu.');
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !hash_equals($_SESSION['csrf'], (string)($_POST['csrf'] ?? ''))) {
    messagePage(403,'A sessão do formulário expirou. Volte e tente novamente.');
}

if (Auth::check() && $route !== 'logout') {
    $model = new User();
    $user = $model->current();
    if (!$user || !Auth::profile($user['cargo'])) {
        $_SESSION = []; session_destroy(); header('Location: index.php?route=login'); exit;
    }
    $_SESSION['user'] = $model->sessionUser($user);
}
[$class,$method] = $routes[$route];
try {
    (new $class())->$method();
} catch (DomainException $e) {
    messagePage(422, $e->getMessage());
}

