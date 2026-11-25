<?php
require_once __DIR__.'/../core/Controller.php';

final class AssetController extends Controller {
    public function index(): void {
        $q = trim((string)($_GET['q'] ?? ''));
        $status = (string)($_GET['status'] ?? '');
        $id = (int)($_GET['id'] ?? 0);
        $error = null;
        $action = $this->input('action');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!Auth::canManage()) messagePage(403, 'A gestão de ativos exige um perfil de gestão.');
            try {
                $endpoint = match ($action) {
                    'create' => 'ativo.criar', 'edit' => 'ativo.editar', 'delete' => 'ativo.excluir',
                    default => throw new DomainException('Ação de ativo inválida.')
                };
                Backend::call($endpoint, ['id'=>$id] + $_POST);
                $_SESSION['success'] = match ($action) {
                    'create'=>'Ativo cadastrado.', 'edit'=>'Ativo atualizado.', 'delete'=>'Ativo excluído.'
                };
                $this->redirect(url('ativos'));
            } catch (DomainException $e) { $error = $e->getMessage(); }
        }
        $data = Backend::call('ativos',compact('q','status','id'));
        if ($id && !$data['detail']) messagePage(404,'Este ativo não foi encontrado.');
        $this->view('assets', $data + compact('q','status','error','action'));
    }
}
