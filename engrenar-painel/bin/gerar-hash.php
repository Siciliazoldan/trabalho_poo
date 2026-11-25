<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$senha = rtrim((string)fgets(STDIN), "\r\n");
if (strlen($senha)<8 || strlen($senha)>72) exit(1);
echo password_hash($senha, PASSWORD_BCRYPT), PHP_EOL;
