<?php
function h(mixed $value): string { return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function url(string $route, array $params=[]): string { return 'index.php?' . http_build_query(['route'=>$route]+$params); }
function csrfField(): string { return '<input type="hidden" name="csrf" value="'.h($_SESSION['csrf']).'">'; }
function notice(): void {
    if (isset($_SESSION['success'])) {
        echo '<div role="status" class="notice">'.ico('check').h($_SESSION['success']).'</div>';
        unset($_SESSION['success']);
    }
}
function labelOf(string $value): string {
    return ['em_andamento'=>'Em andamento','aguardando_peca'=>'Aguardando peça','concluida'=>'Concluída','media'=>'Média',
        'critica'=>'Crítica','em_manutencao'=>'Em manutenção','desativada'=>'Desativada'][$value] ?? ucfirst(str_replace('_',' ',$value));
}
function badge(string $value): string { return '<span class="badge b-'.h($value).'">'.h(labelOf($value)).'</span>'; }
function refTag(?string $tag): string { return '<span class="ref">'.h($tag ?: 'Sem TAG').'</span>'; }
function brand(): string { return '<span class="brand">'.ico('logo').'<span>engrenar</span></span>'; }
function ico(string $name, int $size=20): string {
    static $paths = [
        'logo'=>'<path fill="currentColor" stroke="none" fill-rule="evenodd" d="M10 1h4l.75 2.6 2 .9 2.45-1.3 2.65 3.2-1.65 2.1.55 2.2 2.4 1.15-.7 4.1-2.7.35-1.45 1.7.2 2.7-3.85 1.55-1.8-2.05-2.3-.05-1.8 2-3.8-1.7.25-2.65-1.4-1.8-2.65-.45-.6-4.05 2.45-1.05.65-2.25-1.6-2.15 2.7-3.1 2.4 1.3 2-.8z M12 6.7a5.3 5.3 0 1 0 0 10.6 5.3 5.3 0 0 0 0-10.6z"/><path d="M10.2 12h3.6"/>',
        'grid'=>'<rect x="3" y="3" width="7" height="7" rx="1.3"/><rect x="14" y="3" width="7" height="7" rx="1.3"/><rect x="3" y="14" width="7" height="7" rx="1.3"/><rect x="14" y="14" width="7" height="7" rx="1.3"/>',
        'orders'=>'<rect x="5" y="4" width="14" height="17" rx="2"/><rect x="9" y="2" width="6" height="4" rx="1"/><path d="M9 11h6m-6 4h6"/>',
        'assets'=>'<path d="m12 2 9 5-9 5-9-5zM3 7v10l9 5 9-5V7m-9 5v10"/>',
        'book'=>'<path d="M3 4c3-1 6-1 9 1 3-2 6-2 9-1v15c-3-1-6-1-9 1-3-2-6-2-9-1zM12 5v15"/>',
        'logout'=>'<path d="M10 4H4v16h6m-1-8h12m-4-4 4 4-4 4"/>',
        'factory'=>'<path d="M3 21V9l6 3V8l7 4 1-9h3l1 18zM7 16h1m4 0h1m4 0h1"/>',
        'user'=>'<circle cx="12" cy="8" r="3.5"/><path d="M5 20v-2a7 6 0 0 1 14 0v2"/>',
        'lock'=>'<rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3"/>',
        'eye'=>'<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/>',
        'help'=>'<circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.6 2.6 0 1 1 4 2.3c-1.2.8-1.5 1-1.5 2.3m0 2.9v.1"/>',
        'menu'=>'<path d="M3 6h18M3 12h18M3 18h18"/>','close'=>'<path d="m6 6 12 12M18 6 6 18"/>',
        'activity'=>'<path d="M2 12h5l3-8 4 16 3-8h5"/>','plus'=>'<path d="M12 5v14M5 12h14"/>',
        'calendar'=>'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 10h18"/>',
        'search'=>'<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>','chevron'=>'<path d="m9 5 7 7-7 7"/>',
        'check'=>'<path d="m4 12 5 5L20 6"/>','bolt'=>'<path d="m13 2-9 12h7l-1 8 10-13h-7z"/>',
        'wrench'=>'<path d="M14 6a5 5 0 0 0-6 6l-5 5a2.2 2.2 0 0 0 3 3l5-5a5 5 0 0 0 6-7l-3 3-3-3 3-3z"/>',
        'layers'=>'<path d="m2 8 10-5 10 5-10 5zM2 12l10 5 10-5M2 16l10 5 10-5"/>',
        'clock'=>'<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
        'shield'=>'<path d="m12 3 8 3v6c0 4-4 7-8 9-4-2-8-5-8-9V6z"/><path d="m8.5 11.5 2.3 2.3 4.8-5"/>'
    ];
    return '<svg aria-hidden="true" width="'.$size.'" height="'.$size.'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round">'.($paths[$name] ?? '').'</svg>';
}
