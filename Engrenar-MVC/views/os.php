<?php $pageTitle='Ordens de serviço';require __DIR__.'/partials/header.php'; ?>
<div class="page-heading"><div><p class="overline"><i></i> Manutenção</p><h1>Ordens de serviço</h1><p>Acompanhe as atividades, os responsáveis e a execução de cada OS.</p></div><button class="button" data-open="new-order"><?= ico('plus',18) ?> Nova OS</button></div>
<form method="get" class="filters"><input type="hidden" name="route" value="os">
<label>Buscar ordem<input name="q" value="<?= h($q) ?>" placeholder="Número, atividade ou TAG"></label>
<label>Status<select name="status"><option value="">Todos os status</option><?php foreach(WorkOrder::STATUSES as $s): ?><option value="<?= $s ?>" <?= $s===$status?'selected':'' ?>><?= h(labelOf($s)) ?></option><?php endforeach; ?></select></label>
<label>Responsável<select name="mine"><option value="">Toda a equipe</option><option value="1" <?= $mine?'selected':'' ?>>Minhas ordens</option></select></label>
<?php if($machine!==''): ?><label>Ativo<select name="machine"><option value="">Todos</option><?php foreach($machines as $m): ?><option value="<?= $m['id_maquina'] ?>" <?= (int)$machine===(int)$m['id_maquina']?'selected':'' ?>><?= h($m['tag']) ?></option><?php endforeach; ?></select></label><?php endif; ?>
<button class="button secondary">Filtrar</button><?php if($q!==''||$status!==''||$mine||$machine!==''): ?><a class="link" href="<?= url('os') ?>">Limpar</a><?php endif; ?></form>
<section class="paper flush"><div class="panel-title"><h2>Ordens encontradas <span class="count"><?= count($orders) ?></span></h2></div><?php require __DIR__.'/partials/order-table.php'; ?></section>
<?php if($detail): $d=$detail; ?><dialog id="order-details" aria-labelledby="detail-title" data-reopen><div class="dialog-head"><span class="ref"><?= h($d['numero']) ?></span><button class="icon-button" data-close aria-label="Fechar"><?= ico('close') ?></button></div><h2 id="detail-title"><?= h($d['titulo']) ?></h2><p class="preserve"><?= h($d['descricao'] ?: 'Sem descrição registrada.') ?></p>
<dl class="facts detail-facts"><?php foreach(['Ativo'=>$d['tag'].' · '.$d['maquina'],'Manutenção'=>$d['tipo'],'Prioridade'=>labelOf($d['prioridade']),'Status'=>labelOf($d['status']),'Solicitante'=>$d['solicitante'],'Responsável'=>$d['responsavel'] ?: 'A definir','Abertura'=>date('d/m/Y H:i',strtotime($d['data_abertura'])),'Fechamento'=>$d['data_fechamento']?date('d/m/Y H:i',strtotime($d['data_fechamento'])):'—'] as $k=>$v): ?><div><dt><?= h($k) ?></dt><dd><?= h($v) ?></dd></div><?php endforeach; ?></dl>
<?php if(Auth::canManage()||(int)$d['id_responsavel']===$who['id']): ?><form method="post" action="<?= h(url('os',['id'=>$d['id_os']])) ?>" class="dialog-form"><?= csrfField() ?><input type="hidden" name="action" value="status"><input type="hidden" name="versao" value="<?= h($d['versao']) ?>"><label>Atualizar status<select name="status"><?php foreach(WorkOrder::STATUSES as $s): ?><option value="<?= $s ?>" <?= $s===$d['status']?'selected':'' ?>><?= h(labelOf($s)) ?></option><?php endforeach; ?></select></label><?php if($error && $action==='status'): ?><p class="alert" role="alert"><?= h($error) ?></p><?php endif; ?><button class="button">Salvar status</button></form><?php endif; ?>
<?php if(Auth::canManage()): ?><hr><details <?= $error && $action==='edit' ? 'open' : '' ?>><summary>Editar ordem</summary>
<form class="dialog-form" method="post" action="<?= h(url('os',['id'=>$d['id_os']])) ?>"><?= csrfField() ?>
<input type="hidden" name="action" value="edit"><input type="hidden" name="versao" value="<?= h($d['versao']) ?>">
<?php if($error && $action==='edit'): ?><p class="alert" role="alert"><?= h($error) ?></p><?php endif; ?>
<?php $values=$error && $action==='edit' ? $_POST + $d : $d; require __DIR__.'/partials/order-fields.php'; ?>
<button class="button">Salvar alterações</button></form></details>
<details <?= $error && $action==='delete' ? 'open' : '' ?>><summary>Excluir ordem</summary>
<p>Excluir definitivamente a ordem <?= h($d['numero']) ?>?</p>
<?php if($error && $action==='delete'): ?><p class="alert" role="alert"><?= h($error) ?></p><?php endif; ?>
<form method="post" action="<?= h(url('os',['id'=>$d['id_os']])) ?>"><?= csrfField() ?><input type="hidden" name="action" value="delete">
<input type="hidden" name="versao" value="<?= h($d['versao']) ?>"><button class="button secondary">Confirmar exclusão da OS</button></form></details>
<?php endif; ?></dialog><?php endif; ?>
<dialog id="new-order" aria-labelledby="new-title" <?= $error&&!$detail?'data-reopen':'' ?>><div class="dialog-head"><h2 id="new-title">Nova ordem de serviço</h2><button class="icon-button" data-close aria-label="Fechar"><?= ico('close') ?></button></div>
<?php if($error&&!$detail): ?><p role="alert" class="alert"><?= h($error) ?></p><?php endif; ?>
<form method="post" action="<?= url('os') ?>" class="dialog-form"><?= csrfField() ?>
<input type="hidden" name="action" value="create">
<?php $values=$error && !$detail ? $_POST : []; require __DIR__.'/partials/order-fields.php'; ?>
<div class="dialog-actions"><button type="button" class="button secondary" data-close>Cancelar</button><button class="button">Criar OS</button></div></form></dialog>
<?php require __DIR__.'/partials/footer.php'; ?>
