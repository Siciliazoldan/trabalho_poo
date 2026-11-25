<?php
declare(strict_types=1);

final class Backend {
    public static function call(string $action, array $fields = []): mixed {
        $port = (int)(getenv('ENGRENAR_API_PORT') ?: 8781);
        $token = getenv('ENGRENAR_API_TOKEN');
        if (!$token && is_file(__DIR__.'/../../config/api.local.php')) {
            $token = require __DIR__.'/../../config/api.local.php';
        }
        if (!$token) messagePage(503, 'Inicie o Engrenar pelo arquivo iniciar.cmd.');
        $fields['usuario'] = Auth::user()['id'] ?? 0;
        $client = curl_init("http://127.0.0.1:$port/api/$action");
        curl_setopt_array($client, [
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json','X-Engrenar-Token: '.$token],
            CURLOPT_POSTFIELDS => json_encode($fields, JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE),
            CURLOPT_RETURNTRANSFER => true, CURLOPT_CONNECTTIMEOUT => 3, CURLOPT_TIMEOUT => 18,
            CURLOPT_NOPROXY => '*',
        ]);
        $body = curl_exec($client);
        $code = curl_getinfo($client, CURLINFO_RESPONSE_CODE);
        curl_close($client);
        if ($body === false || $code >= 500 || !$code)
            messagePage(503, 'O serviço do Engrenar está indisponível. Confira a janela de inicialização e a conexão com o MySQL.');
        $result = json_decode($body, true, 512, JSON_THROW_ON_ERROR);
        if ($code === 403) messagePage(403, $result['erro']);
        if ($code !== 200) throw new DomainException($result['erro'] ?? 'O formulário não pôde ser salvo.');
        return $result;
    }
}
