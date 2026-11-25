<?php
// Projeção axonométrica de um rolamento desmontado, desenhada em código.
$point = static function (float $axis, float $r, float $angle): array {
    return [155 + .88*$axis + .64*$r*cos($angle), 173 - .275*$axis + .32*$r*cos($angle) - .92*$r*sin($angle)];
};
$arc = static function (float $axis, float $r, float $from=0, float $to=2*M_PI) use ($point): array {
    $points=[];
    for ($n=0;$n<=64;$n++) $points[]=$point($axis,$r,$from+($to-$from)*$n/64);
    return $points;
};
$path = static function(array $points): string {
    return 'M'.implode(' L',array_map(static fn($p)=>sprintf('%.2f %.2f',$p[0],$p[1]),$points));
};
$ring = static function (float $back, float $length, float $outer, float $inner) use ($point,$arc,$path): void {
    $front=$back+$length;
    $edge=atan2(-.595,.133);
    $side=array_merge($arc($back,$outer,$edge,$edge+M_PI),$arc($front,$outer,$edge+M_PI,$edge));
    echo '<path fill="url(#metal)" d="'.$path($side).'Z"/>';
    for($i=0;$i<30;$i++) {
        $a=$edge+M_PI*$i/30;
        echo '<path class="engrave" d="'.$path([$point($back,$outer,$a),$point($front,$outer,$a)]).'"/>';
    }
    echo '<path fill="url(#metal)" d="'.$path($arc($front,$inner)).'Z"/>';
    echo '<path fill="#0e2944" d="'.$path($arc($back,$inner*.89)).'Z"/>';
    echo '<path fill="url(#face)" fill-rule="evenodd" d="'.$path($arc($front,$outer)).'Z '.$path($arc($front,$inner)).'Z"/>';
    foreach([$outer-3,$outer-6,$inner+3] as $r) echo '<path class="engrave" d="'.$path($arc($front,$r)).'Z"/>';
    for($i=0;$i<100;$i++) {
        $a=$i*2*M_PI/100;
        echo '<path class="engrave" d="'.$path([$point($front,$outer-1,$a),$point($front,$outer-5,$a+.008)]).'"/>';
    }
};
?>
<svg viewBox="0 0 600 290" class="bearing" role="img" aria-label="Desenho técnico de um rolamento em vista explodida" xmlns="http://www.w3.org/2000/svg">
<defs><linearGradient id="metal" x1="0" y1="1" x2="1" y2="0" gradientUnits="objectBoundingBox"><stop stop-color="#112e4d"/><stop offset=".53" stop-color="#476d94"/><stop offset="1" stop-color="#1b3a5a"/></linearGradient><linearGradient id="face" x2="1" y2=".75"><stop stop-color="#7090b0"/><stop offset=".45" stop-color="#385b7e"/><stop offset="1" stop-color="#173450"/></linearGradient></defs>
<g fill="none" stroke="#82aaca" stroke-width=".75" opacity=".65" stroke-dasharray="10 4 2 4"><path d="M48 207 547 51"/></g>
<g fill="none" stroke="#b5cde3" stroke-linejoin="round" stroke-width="1.05">
<?php $ring(0,40,92,65); ?>
<?php
// Desenha primeiro os rolos do fundo para preservar a sobreposição das peças.
$angles=[];for($i=0;$i<13;$i++) $angles[]=2*M_PI*$i/13;
usort($angles,static fn($a,$b)=>cos($a)<=>cos($b));
$roller = static function(float $angle) use ($point,$arc,$path):void {
    [$cx,$cy]=$point(0,59,$angle);
    echo '<g transform="translate('.($cx-155).' '.($cy-173).')">';
    $ringEdge=-1.35;
    $body=array_merge($arc(145,11.4,$ringEdge,$ringEdge+M_PI),$arc(184,11.4,$ringEdge+M_PI,$ringEdge));
    echo '<path fill="url(#metal)" d="'.$path($body).'Z"/><path fill="url(#face)" d="'.$path($arc(184,11.4)).'Z"/>';
    echo '<path class="engrave" d="'.$path($arc(184,8.8)).'Z"/>';
    foreach([.3,.4,.47] as $t) echo '<path class="engrave" d="'.$path([$point(145,11.4,$t),$point(184,11.4,$t)]).'"/>';
    echo '</g>';
};
foreach($angles as $angle) $roller($angle);
$ring(270,35,59,36);
?>
</g>
<g fill="none" stroke="#82aaca" stroke-width=".85"><path d="m113 118 -21-24H49m255 77 23 28h61m53-100 24-33h59"/><circle cx="113" cy="118" r="2" fill="#b8d5ed"/><circle cx="304" cy="171" r="2" fill="#b8d5ed"/><circle cx="441" cy="99" r="2" fill="#b8d5ed"/></g>
<g fill="#b5cde2" font-family="Consolas,monospace" font-size="12" letter-spacing="1"><text x="49" y="87">01</text><text x="366" y="214">02</text><text x="505" y="60">03</text></g>
</svg>
