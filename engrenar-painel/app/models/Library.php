<?php
final class Library {
    public function all(int $segment,string $query): array {
        return array_filter($_SESSION['demo']['models'],static fn($m)=>
            (!$segment || in_array($segment,$m['segment_ids'])) && Demo::matches($query,[$m['modelo'],$m['tag'],$m['fabricante']]));
    }
    public function create(string $model,string $tag,string $description,?int $maker,array $segments): void {
        $models=&$_SESSION['demo']['models'];
        foreach ($models as $existing) {
            if ($existing['maker']===$maker && mb_strtolower($existing['modelo'])===mb_strtolower($model)) throw new DomainException('Este modelo já está cadastrado.');
        }
        $id=count($models)+1;
        $names=array_map(static fn($i)=>Demo::segments()[$i]['nome'],$segments);
        $models[$id]=['id_maquina_biblioteca'=>$id,'modelo'=>$model,'tag'=>$tag,'descricao'=>$description,
            'maker'=>$maker,'fabricante'=>Demo::makers()[$maker]['nome']??'','segment_ids'=>$segments,'segmentos'=>implode(' · ',$names)];
    }
    public function templates(int $model): array {
        $parts=[1=>['Estrutura do laminador','Cilindro de laminação',2,5000],2=>['Estrutura CNC','Eixo principal',1,8000]];
        if (!isset($parts[$model])) return [];
        [$name,$component,$qty,$hours]=$parts[$model];
        return [['id_template'=>$model,'nome'=>$name,'componente'=>$component,'quantidade'=>$qty,'vida_util'=>$hours]];
    }
    public function install(array $user,int $model,int $line,int $template,string $tag,string $name,string $criticality,string $state): void {
        $m=$_SESSION['demo']['models'][$model]??null;
        $location=Demo::lines()[$line]??null;
        if (!$m || !$location || !in_array($user['segment'],$m['segment_ids'])) throw new DomainException('Confira o segmento e a linha selecionada.');
        $assets=&$_SESSION['demo']['assets'];
        foreach ($assets as $a) if (strcasecmp($a['tag'],$tag)===0) throw new DomainException('Essa TAG já pertence a outro ativo.');
        $parts=$template?$this->templates($model):[];
        if ($template && !in_array($template,array_column($parts,'id_template'))) throw new DomainException('Estrutura inválida.');
        $id=count($assets)+1;
        $assets[$id]=['id_maquina'=>$id,'nome'=>$name,'tag'=>$tag,'linha'=>$location['nome'],'setor'=>$location['setor'],
            'modelo'=>$m['modelo'],'status'=>$state,'criticidade'=>$criticality,'componentes'=>$parts];
    }
}
