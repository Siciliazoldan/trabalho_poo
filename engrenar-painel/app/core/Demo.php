<?php
final class Demo {
    public const PASSWORD = 'Engrenar123';

    public static function users(): array {
        $roles=[2=>['Roberto','Gestor de manutenção'],3=>['Marcos','Mecânico'],4=>['Ana','Eletricista'],5=>['Laura','Engenheira'],6=>['Bruno','Analista']];
        $users=[];
        foreach ($roles as $id=>[$name,$role]) {
            $users[$id]=['id_usuario'=>$id,'nome'=>$name,'cargo'=>$role,'matricula'=>sprintf('MAT-%03d',$id),
                'email'=>strtolower($name).'@engrenar.invalid','id_industria'=>1,'id_segmento'=>1,
                // Edite aqui o nome da indústria exibido no menu lateral de todos os perfis.
                'razao_social'=>'Mars PetCare','segmento'=>'Alimentícia'];
        }
        return $users;
    }
    public static function segments(): array { return [1=>['id_segmento'=>1,'nome'=>'Metalurgia e Siderurgia'],2=>['id_segmento'=>2,'nome'=>'Automotivo']]; }
    public static function makers(): array { return [1=>['id_fabricante'=>1,'nome'=>'Siemag Demag'],2=>['id_fabricante'=>2,'nome'=>'Mazak']]; }
    public static function lines(): array { return [1=>['id_linha'=>1,'nome'=>'Laminação 01','setor'=>'Fundição'],2=>['id_linha'=>2,'nome'=>'Usinagem CNC 03','setor'=>'Usinagem']]; }
    public static function types(): array {
        $result=[];
        foreach (['Preventiva','Corretiva','Preditiva','Inspeção'] as $i=>$name) $result[$i+1]=['id_tipo_manutencao'=>$i+1,'nome'=>$name];
        return $result;
    }
    public static function init(): void {
        if (isset($_SESSION['demo'])) return;
        $_SESSION['demo']=['models'=>[], 'assets'=>[], 'orders'=>[]];
        $lib=new Library();
        $lib->create('Laminador Universal 4 High','BIB-LAM-01','Laminador de chapas de aço.',1,[1]);
        $lib->create('CNC Vertical Variaxis','BIB-CNC-02','Centro de usinagem multieixos.',2,[2]);
        $user=['segment'=>1];
        $lib->install($user,1,1,1,'MQ-LAM-01','Laminador Principal A','alta','operando');
        $lib->install(['segment'=>2],2,2,2,'MQ-CNC-05','Centro de Usinagem 05','critica','em_manutencao');
        $orders=new WorkOrder();
        foreach ([[1,1,3,'Lubrificação e inspeção preventiva','alta'],[2,2,4,'Revisão do painel elétrico','urgente']] as [$asset,$type,$owner,$title,$priority]) {
            $orders->create(['numero'=>sprintf('OS-%s-%04d',date('Y'),$asset),'maquina'=>$asset,'tipo'=>$type,'solicitante'=>2,
                'responsavel'=>$owner,'titulo'=>$title,'descricao'=>'Verificar o equipamento e registrar a conclusão da atividade.','prioridade'=>$priority]);
        }
        $_SESSION['demo']['orders'][1]['status']='em_andamento';
    }
    public static function matches(string $query, array $values): bool {
        return $query==='' || mb_stripos(implode(' ',$values),$query)!==false;
    }
}
