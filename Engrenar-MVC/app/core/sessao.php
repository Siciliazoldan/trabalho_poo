<?php
declare(strict_types=1);
if (!getenv('ENGRENAR_HOST') || ($_SERVER['HTTP_HOST']??'') !== getenv('ENGRENAR_HOST')) {
    http_response_code(403); exit('Abra Engrenar.jar para usar a conexão local.');
}
session_name('engrenar_'.(int)$_SERVER['SERVER_PORT']);
ini_set('session.use_strict_mode','1');
session_set_cookie_params(['path'=>'/','httponly'=>true,'samesite'=>'Strict']);
session_start();
$_SESSION['csrf'] ??= bin2hex(random_bytes(32));
header('Cache-Control: no-store');
