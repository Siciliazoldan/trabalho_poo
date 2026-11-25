<!doctype html>
<html lang="pt-BR"><head><?php $pageTitle='Entrar';require __DIR__.'/partials/head.php'; ?></head>
<body class="login-page">
<main class="login-layout">
<section class="identity" aria-label="Engrenar, gestão de manutenção industrial">
<header class="identity-brand"><?= brand() ?></header>
<div class="identity-body">
<div class="overline light"><i></i> Plataforma industrial</div>
<h1>Gestão de<br>manutenção<span>.</span></h1>
<div class="drawing">
  <div class="drawing-top"><span>VISTA EXPLODIDA</span><span>CONJ. 01</span></div>
  <?php require __DIR__.'/partials/bearing.php'; ?>
  <div class="drawing-meta"><span>Rolamento de rolos cilíndricos</span><span>PEC-001</span></div>
</div>
</div>
<footer class="identity-foot"><span class="little-stripes" aria-hidden="true"></span> Engrenar <span class="foot-separator">/</span> Manutenção industrial</footer>
</section>
<section class="access">
<header class="access-top"><button class="link help" type="button" data-open="help"><?= ico('help',17) ?> Ajuda com o acesso</button></header>
<div class="form-wrap">
<div class="access-icon"><?= ico('lock',25) ?></div>
<p class="overline"><i></i> Portal de acesso</p>
<h2>Acesse sua conta</h2>
<p class="lede">Entre com suas credenciais para acessar o Engrenar.</p>
<?php if ($error): ?><p class="alert" role="alert"><?= h($error) ?></p><?php endif; ?>
<form method="post" action="<?= url('login') ?>" id="login-form">
<?= csrfField() ?>
<label for="login">Matrícula ou e-mail</label>
<div class="input-icon"><?= ico('user',18) ?><input id="login" name="login" autocomplete="username" maxlength="150" placeholder="Digite sua matrícula ou e-mail" value="<?= h($login) ?>" required></div>
<label for="password">Senha</label>
<div class="input-icon"><?= ico('lock',18) ?><input id="password" name="password" type="password" autocomplete="current-password" placeholder="Digite sua senha" required><button type="button" class="eye" id="eye" aria-label="Mostrar senha" aria-pressed="false"><?= ico('eye',18) ?></button></div>
<label class="checkbox"><input type="checkbox" id="remember"> Lembrar minha identificação</label>
<button class="button submit" type="submit">Entrar</button>
</form>
</div>
<footer class="access-foot">© <?= date('Y') ?> Engrenar</footer>
</section></main>
<dialog id="help" aria-labelledby="help-title"><div class="dialog-head"><h2 id="help-title">Ajuda com o acesso</h2><button class="icon-button" data-close aria-label="Fechar"><?= ico('close') ?></button></div><p>Use a matrícula ou o e-mail cadastrado na sua indústria. Se sua conta ainda não tem senha, peça a quem administra o painel para definir a primeira senha.</p><button class="button" data-close>Entendi</button></dialog>
</body></html>
