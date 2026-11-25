<?php
require_once __DIR__.'/../core/Controller.php';

final class DashboardController extends Controller {
    public function index(): void {
        $this->view(Auth::canManage() ? 'dashboard' : 'field', Backend::call('painel'));
    }
}
