<?php $pageTitle='Visão geral';require __DIR__.'/partials/header.php';
$a=$data['ativos'];$os=$data['ordens'];$total=array_sum($a);$active=$total-($a['desativada']??0);$running=$a['operando']??0;
$pending=($os['aberta']??0)+($os['em_andamento']??0)+($os['aguardando_peca']??0);
?>
<div class="page-heading"><div><p class="overline"><i></i> Painel de gestão</p><h1>Visão geral</h1><p>Indicadores de manutenção da sua indústria.</p></div><span class="date"><?= ico('calendar',16) ?><?= date('d/m/Y') ?></span></div>
<div class="metrics">
<?php foreach ([
    ['activity','Ativos em operação',$active?number_format(100*$running/$active,0,',','.').'%':'—',"$running de $active ativos em serviço"],
    ['orders','OS pendentes',$pending,($os['em_andamento']??0).' em andamento'],
    ['wrench','Paradas e manutenção',($a['parada']??0)+($a['em_manutencao']??0),'Máquinas fora de operação'],
    ['check','OS concluídas',$os['concluida']??0,'Total de ordens finalizadas']
] as [$icon,$title,$value,$hint]): ?><article class="metric"><div class="metric-label"><?= ico($icon,19) ?><?= h($title) ?></div><strong><?= h($value) ?></strong><small><?= h($hint) ?></small></article><?php endforeach; ?></div>
<div class="analysis-grid"><section class="paper"><div class="panel-title"><h2>Condição dos ativos</h2><span class="ref"><?= $total ?> no total</span></div>
<div class="stack" aria-hidden="true"><?php foreach(['operando','em_manutencao','parada','desativada'] as $s): if(!empty($a[$s])): ?><i class="fill-<?= $s ?>" style="width:<?= 100*$a[$s]/$total ?>%"></i><?php endif;endforeach; ?></div>
<div class="legend"><?php foreach(['operando','em_manutencao','parada','desativada'] as $s): ?><div><span><i class="fill-<?= $s ?>"></i><?= h(labelOf($s)) ?></span><b><?= $a[$s]??0 ?></b></div><?php endforeach; ?></div></section>
<section class="paper"><div class="panel-title"><h2>Tipos de manutenção</h2><span class="muted">Ordens de serviço</span></div>
<?php if(!$data['tipos']): ?><p class="empty">A distribuição aparecerá ao cadastrar uma OS.</p><?php endif; ?>
<div class="bars"><?php foreach($data['tipos'] as $t): ?><div><div class="bar-label"><span><?= h($t['nome']) ?></span><b><?= (int)$t['n'] ?></b></div><div class="track"><i style="width:<?= 100*$t['n']/max(1,array_sum($os)) ?>%"></i></div></div><?php endforeach; ?></div></section></div>
<section class="paper flush"><div class="panel-title"><h2>Ordens recentes</h2><a class="link" href="<?= url('os') ?>">Ver todas</a></div><?php require __DIR__.'/partials/order-table.php'; ?></section>

<?php require __DIR__.'/partials/footer.php'; ?>

