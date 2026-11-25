<?php
final class Asset {
    public function all(int $industry,string $query='',string $status=''): array {
        $rows=[];
        foreach ($_SESSION['demo']['assets'] as $a) {
            if (($status!=='' && $status!==$a['status']) || !Demo::matches($query,[$a['nome'],$a['tag'],$a['linha']])) continue;
            $a['pendentes']=count((new WorkOrder())->listing($industry,['machine'=>$a['id_maquina'],'active'=>true]));
            $rows[]=$a;
        }
        return $rows;
    }
}