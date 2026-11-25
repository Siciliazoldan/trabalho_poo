<?php
require_once __DIR__.'/../core/Controller.php';
require_once __DIR__.'/../models/WorkOrder.php';

final class WorkOrderController extends Controller {
    public function index(): void {
        $q = trim((string)($_GET['q'] ?? ''));
        $status = (string)($_GET['status'] ?? '');
        $mine = ($_GET['mine'] ?? '') === '1';
        $machine = (string)($_GET['machine'] ?? '');
        $id = (int)($_GET['id'] ?? 0);
        $action = $this->input('action');
        $error = null;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $endpoint = match ($action) {
                    'create'=>'os.criar','edit'=>'os.editar','delete'=>'os.excluir','status'=>'os.status',
                    default=>throw new DomainException('Ação de ordem inválida.')
                };
                $result = Backend::call($endpoint, ['id'=>$id] + $_POST);
                $_SESSION['success'] = match ($action) {
                    'create'=>"Ordem $result criada.", 'edit'=>'Ordem atualizada.',
                    'delete'=>'Ordem excluída.', 'status'=>'Status da ordem salvo.'
                };
                $this->redirect(url('os', $id && $action!=='delete' ? ['id'=>$id] : []));
            } catch (DomainException $e) { $error = $e->getMessage(); }
        }
        $data = Backend::call('ordens', ['mine'=>$mine?'1':'0'] + compact('q','status','machine','id'));
        if ($id && !$data['detail']) messagePage(404, 'Esta ordem não foi encontrada.');
        $this->view('os',$data + compact('q','status','mine','machine','error','action'));
    }
}
