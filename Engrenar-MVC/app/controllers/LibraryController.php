<?php
require_once __DIR__.'/../core/Controller.php';

final class LibraryController extends Controller {
    public function index(): void {
        if (!Auth::canManage()) messagePage(403,'A biblioteca é exclusiva da equipe de gestão.');
        $segment = (int)($_GET['segment'] ?? Auth::user()['segment']);
        $q = trim((string)($_GET['q'] ?? ''));
        $id = (int)($_GET['id'] ?? 0);
        $action = $this->input('action');
        $error = null;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                if ($action === 'install') {
                    Backend::call('modelo.instalar',['id'=>$id] + $_POST);
                    $_SESSION['success'] = 'Ativo cadastrado a partir da biblioteca.';
                    $this->redirect(url('ativos',['q'=>$this->input('tag')]));
                }
                if ($action !== 'create') throw new DomainException('Ação da biblioteca inválida.');
                Backend::call('modelo.criar',$_POST);
                $_SESSION['success'] = 'Modelo pré-cadastrado na biblioteca.';
                $this->redirect(url('biblioteca',['segment'=>0,'q'=>$this->input('modelo')]));
            } catch (DomainException $e) { $error=$e->getMessage(); }
        }
        $data = Backend::call('biblioteca',compact('segment','q','id'));
        if ($id && !$data['selected']) messagePage(404, 'Este modelo não foi encontrado.');
        $this->view('library',$data + compact('segment','q','error','action'));
    }
}
