<?php
abstract class Controller {
    protected function view(string $name, array $data = []): void {
        extract($data);
        require __DIR__ . '/../../views/' . $name . '.php';
    }

    protected function redirect(string $url): never {
        header('Location: ' . $url);
        exit;
    }

    protected function input(string $key, string $default = ''): string {
        return trim((string)($_POST[$key] ?? $default));
    }
}
