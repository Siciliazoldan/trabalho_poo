<?php
final class Dashboard {
    public function metrics(int $industry): array {
        $orders=$_SESSION['demo']['orders'];
        $types=array_count_values(array_column($orders,'tipo'));
        arsort($types);
        $rows=[];
        foreach ($types as $name=>$count) $rows[]=['nome'=>$name,'n'=>$count];
        return ['ativos'=>array_count_values(array_column($_SESSION['demo']['assets'],'status')),
            'ordens'=>array_count_values(array_column($orders,'status')),'tipos'=>$rows,'estoque_baixo'=>0];
    }
}