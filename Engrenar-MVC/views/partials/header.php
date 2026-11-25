<?php $who=Auth::user(); $current=$_GET['route'] ?? 'dashboard';
$nav=['dashboard'=>[Auth::canManage()?'Visão geral':'Meu trabalho','grid'],'os'=>['Ordens de serviço','orders'],'ativos'=>['Ativos e saúde','assets']];
?>
<!doctype html><html lang="pt-BR"><head><?php require __DIR__.'/head.php'; ?></head><body class="app">
<a class="skip" href="#content">Pular para o conteúdo</a>
<aside class="sidebar" id="sidebar"><div class="side-head"><a href="<?= url('dashboard') ?>" aria-label="Página inicial do Engrenar"><?= brand() ?></a><button class="icon-button menu-close" aria-label="Fechar menu"><?= ico('close') ?></button></div>
<div class="workspace"><?= ico('factory',22) ?><div><small>Indústria</small><strong><?= h($who['empresa']) ?></strong></div></div>
<nav aria-label="Menu principal"><p class="nav-title">Área de trabalho</p>
<?php foreach ($nav as $key=>[$name,$icon]): ?><a class="nav-link" <?= $key===$current?'aria-current="page"':'' ?> href="<?= url($key) ?>"><?= ico($icon,18) ?><?= h($name) ?></a><?php endforeach; ?>
<?php if (Auth::canManage()): ?><p class="nav-title">Planejamento</p><a class="nav-link" <?= $current==='biblioteca'?'aria-current="page"':'' ?> href="<?= url('biblioteca') ?>"><?= ico('book',18) ?>Biblioteca de máquinas</a><?php endif; ?>
</nav><div class="side-foot"><div class="profile"><span class="avatar"><?= h(mb_strtoupper(mb_substr($who['nome'],0,1))) ?></span><div><strong><?= h($who['nome']) ?></strong><small><?= h($who['cargo']) ?></small></div></div>
<form method="post" action="<?= url('logout') ?>"><?= csrfField() ?><button class="signout"><?= ico('logout',17) ?> Sair do sistema</button></form></div></aside>
<button class="nav-backdrop" aria-label="Fechar navegação" hidden></button>
<div class="main"><header class="topbar"><div><button class="icon-button hamburger" data-menu aria-label="Abrir menu" aria-controls="sidebar" aria-expanded="false"><?= ico('menu') ?></button><span class="crumb">Engrenar</span><span class="slash">/</span><strong><?= h($pageTitle) ?></strong></div><span class="profile-type"><?= ico(Auth::canManage()?'layers':'wrench',16) ?><?= Auth::canManage()?'Gestão':'Operação' ?></span></header><main id="content" class="page">
<?php notice(); ?>
