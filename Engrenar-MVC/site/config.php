<?php
require __DIR__.'/../app/core/sessao.php';
require __DIR__.'/../app/core/Backend.php';
require __DIR__.'/../app/core/format.php';
$cfg=Backend::config() ?? ['host'=>'127.0.0.1','port'=>3306,'database'=>'engrenar','user'=>'root','password'=>''];
$error=''; $connected=Backend::config()!==null;
if ($_SERVER['REQUEST_METHOD']==='POST') {
    if (!hash_equals($_SESSION['csrf'],(string)($_POST['csrf']??''))) {http_response_code(403);exit('Atualize o formulário.');}
    try {
        if (($_POST['acao']??'')==='primeiro') {
            $email=trim($_POST['email']??''); $pass=$_POST['senha']??'';
            if (!filter_var($email,FILTER_VALIDATE_EMAIL) || strlen($pass)<8 || strlen($pass)>72 || $pass!==($_POST['confirma']??null)) throw new DomainException('Confira o e-mail e as duas senhas (8 a 72 bytes).');
            if (!$connected) throw new DomainException('Conecte o banco primeiro.');
            Backend::executar($cfg,'primeiro',['email'=>$email,'hash'=>password_hash($pass,PASSWORD_BCRYPT)]);
            $_SESSION['precisaConta']=false;
            header('Location: index.php'); exit;
        }
        $cfg=['host'=>trim($_POST['host']),'port'=>(int)$_POST['port'],'database'=>trim($_POST['database']),'user'=>trim($_POST['user']),'password'=>$_POST['password']??''];
        unset($_SESSION['conexao'],$_SESSION['user'],$_SESSION['precisaConta']); $connected=false;
        $result=Backend::executar($cfg,'conexao');
        session_regenerate_id(true); Backend::guardar($cfg); $connected=true;
        $_SESSION['precisaConta']=!(int)$result['tem_conta'];
    } catch (DomainException $e) { $error=$e->getMessage(); }
}
?><!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Configuração · Engrenar</title><link rel="stylesheet" href="style.css"></head><body class="page"><main class="paper" style="max-width:620px;margin:4vh auto"><a class="link" href="index.html">← Menu inicial</a><h1>Configuração do banco</h1><p>Use os dados de conexão do seu MySQL. A senha fica disponível durante esta sessão.</p>
<?php if($error): ?><p class="alert" role="alert"><?=h($error)?></p><?php endif; ?>
<?php if($connected): ?><p class="notice">Conectado ao banco <?=h($cfg['database'])?>.</p><?php if(empty($_SESSION['precisaConta'])): ?><a class="button" href="index.php">Entrar no painel MySQL</a><?php endif; endif; ?>
<?php if($connected && !empty($_SESSION['precisaConta'])): ?>
<h2>Primeiro administrador</h2><p>Este banco ainda não tem usuários. Em uma instalação vazia, o cadastro também cria a indústria de demonstração e a primeira linha de produção.</p>
<form method="post" class="dialog-form"><?=csrfField()?><input type="hidden" name="acao" value="primeiro"><label>E-mail do painel<input required type="email" name="email"></label><label>Nova senha do painel<input required type="password" name="senha" minlength="8" autocomplete="new-password"></label><label>Confirme a senha<input required type="password" name="confirma" autocomplete="new-password"></label><button class="button">Criar primeiro administrador</button></form>
<?php endif; ?>
<h2>Conexão MySQL</h2><form class="dialog-form" method="post"><?=csrfField()?>
<label>Servidor<input name="host" required value="<?=h($cfg['host'])?>"></label><label>Porta<input name="port" type="number" min="1" max="65535" required value="<?=h($cfg['port'])?>"></label><label>Banco<input name="database" required value="<?=h($cfg['database'])?>"></label><label>Usuário MySQL<input name="user" required value="<?=h($cfg['user'])?>"></label><label>Senha MySQL<input name="password" type="password" autocomplete="off" placeholder="Deixe vazio se sua conta não tiver senha"></label><button class="button">Testar e usar conexão</button></form></main></body></html>
