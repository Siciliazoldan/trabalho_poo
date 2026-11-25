<?php
$asset = $detail ?? [];
$values = $error && $action !== 'delete' ? $_POST + $asset : $asset;
?>
<dialog id="asset-form" aria-labelledby="asset-title" <?= $detail || $error || ($_GET['novo'] ?? '')==='1' ? 'data-reopen' : '' ?>>
<div class="dialog-head"><h2 id="asset-title"><?= $detail ? 'Editar ativo' : 'Novo ativo' ?></h2><button type="button" class="icon-button" data-close aria-label="Fechar"><?= ico('close') ?></button></div>
<?php if ($error): ?><p class="alert" role="alert"><?= h($error) ?></p><?php endif; ?>
<form class="dialog-form" method="post" action="<?= h(url('ativos',$detail?['id'=>$detail['id_maquina']]:[])) ?>">
<?= csrfField() ?><input type="hidden" name="action" value="<?= $detail?'edit':'create' ?>">
<?php if ($detail): ?><input type="hidden" name="versao" value="<?= h($detail['versao']) ?>"><?php endif; ?>
<label>Nome do ativo<input required name="nome" maxlength="120" value="<?= h($values['nome']??'') ?>"></label>
<label>TAG<input required name="tag" maxlength="50" value="<?= h($values['tag']??'') ?>"></label>
<label>Linha de produção<select required name="linha"><option value="">Selecione a linha</option>
<?php foreach ($lines as $line): ?><option value="<?= (int)$line['id_linha'] ?>" <?= $line['id_linha']==($_POST['linha']??$asset['id_linha']??0)?'selected':'' ?>><?= h($line['setor'].' · '.$line['nome']) ?></option><?php endforeach; ?></select></label>
<div class="two-fields"><label>Criticidade<select name="criticidade"><?php foreach (['baixa','media','alta','critica'] as $v): ?><option value="<?= $v ?>" <?= $v===($values['criticidade']??'media')?'selected':'' ?>><?= h(labelOf($v)) ?></option><?php endforeach; ?></select></label>
<label>Condição<select name="status"><?php foreach (['operando','parada','em_manutencao','desativada'] as $v): ?><option value="<?= $v ?>" <?= $v===($values['status']??'operando')?'selected':'' ?>><?= h(labelOf($v)) ?></option><?php endforeach; ?></select></label></div>
<div class="dialog-actions"><button type="button" class="button secondary" data-close>Cancelar</button><button class="button">Salvar ativo</button></div></form>
<?php if ($detail): ?>
<hr><details><summary>Excluir ativo</summary><p>Excluir <?= h($detail['tag']) ?> e seus componentes instalados? A exclusão é definitiva.</p>
<form method="post" action="<?= h(url('ativos',['id'=>$detail['id_maquina']])) ?>"><?= csrfField() ?>
<input type="hidden" name="action" value="delete"><input type="hidden" name="versao" value="<?= h($detail['versao']) ?>"><button class="button secondary">Confirmar exclusão do ativo</button></form></details>
<?php endif; ?></dialog>
