param([switch]$DefinirSenha, [switch]$Apache)
$ErrorActionPreference = 'Stop'
$OutputEncoding = New-Object System.Text.UTF8Encoding($false)
Set-Location -LiteralPath $PSScriptRoot
function Ler-Segredo([string]$mensagem) {
    $valor = Read-Host $mensagem -AsSecureString
    return [System.Net.NetworkCredential]::new('', $valor).Password
}
function Padrao([string]$nome, [string]$padrao) {
    $valor = [Environment]::GetEnvironmentVariable($nome)
    if ([string]::IsNullOrEmpty($valor)) { return $padrao }
    return $valor
}
$servidor = $null
try {
    $php = (Get-Command php.exe -ErrorAction SilentlyContinue).Source
    if (!$php -and (Test-Path 'C:\xampp\php\php.exe')) { $php = 'C:\xampp\php\php.exe' }
    if (!$php) { throw 'Instale o PHP 8.1+ com curl e mbstring ou o XAMPP.' }
    & $php -r "exit(PHP_VERSION_ID >= 80100 && extension_loaded('curl') && extension_loaded('mbstring') ? 0 : 1);"
    if ($LASTEXITCODE -ne 0) { throw 'O PHP precisa da versão 8.1+ e das extensões curl e mbstring.' }
    $java = (Get-Command java.exe).Source
    $javac = (Get-Command javac.exe).Source
    $build = Join-Path $PSScriptRoot 'backend\build'
    New-Item -ItemType Directory -Force -Path $build | Out-Null
    $libs = Join-Path $PSScriptRoot 'backend\lib\*'
    $sources = @(Get-ChildItem backend/src -Recurse -Filter '*.java' | ForEach-Object { $_.FullName })
    & $javac --release 17 -encoding UTF-8 -cp $libs -d $build @sources
    if ($LASTEXITCODE -ne 0) { throw 'Falha na compilação. Confira se o JDK 17 ou superior está instalado.' }
    $classpath = "$build;$libs"
    $env:ENGRENAR_DB_HOST = Padrao ENGRENAR_DB_HOST '127.0.0.1'
    $env:ENGRENAR_DB_PORT = Padrao ENGRENAR_DB_PORT '3306'
    $env:ENGRENAR_DB_NAME = Padrao ENGRENAR_DB_NAME 'engrenar'
    Write-Host ("Conexão com {0}:{1} / {2}" -f $env:ENGRENAR_DB_HOST,$env:ENGRENAR_DB_PORT,$env:ENGRENAR_DB_NAME)
    if ($Apache -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'config/mysql.local.xml'))) {
        $acesso = Import-Clixml -LiteralPath (Join-Path $PSScriptRoot 'config/mysql.local.xml')
        $env:ENGRENAR_DB_USER = $acesso.UserName
        $env:ENGRENAR_DB_PASSWORD = $acesso.GetNetworkCredential().Password
    }
    if (!$env:ENGRENAR_DB_USER) {
        $nome = Read-Host 'Usuário do MySQL (Enter para root)'
        $env:ENGRENAR_DB_USER = if ($nome) { $nome } else { 'root' }
    }
    if (!(Test-Path Env:ENGRENAR_DB_PASSWORD)) {
        $env:ENGRENAR_DB_PASSWORD = Ler-Segredo 'Senha do MySQL (entrada oculta)'
    }
    if ($DefinirSenha) {
        $email = (Read-Host 'E-mail já cadastrado no Engrenar').Trim()
        $nova = Ler-Segredo 'Nova senha do painel (8 a 72 bytes)'
        $repetida = Ler-Segredo 'Confirme a nova senha do painel'
        if (!$nova -or $nova -cne $repetida) { throw 'As senhas não coincidem.' }
        $hash = $nova | & $php (Join-Path $PSScriptRoot 'bin\gerar-hash.php')
        if ($LASTEXITCODE -ne 0) { throw 'A senha deve ter de 8 a 72 bytes.' }
        $hash | & $java -cp $classpath Principal --definir-senha $email
        if ($LASTEXITCODE -ne 0) { throw 'Confira a conexão e o e-mail informado.' }
    } else {
        $env:ENGRENAR_API_PORT = Padrao ENGRENAR_API_PORT '8781'
        $web = Padrao ENGRENAR_WEB_PORT '8780'
        $bytes = New-Object byte[] 32
        $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
        try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
        $env:ENGRENAR_API_TOKEN = [Convert]::ToBase64String($bytes)
        if ($Apache) {
            $env:ENGRENAR_API_TOKEN = & $php -r "echo require 'config/api.local.php';"
            if (!$env:ENGRENAR_API_TOKEN) { throw 'A configuração local do painel está ausente.' }
        }
        $env:ENGRENAR_LAUNCHER_PID = [string]$PID
        $log = Join-Path $build ("backend-" + $PID + ".log")
        $servidor = Start-Process -FilePath $java -ArgumentList @('-cp', ('"'+$classpath+'"'), 'Principal') -WindowStyle Hidden -RedirectStandardError $log -PassThru
        $pronto = $false
        for ($tentativa=0; $tentativa -lt 45; $tentativa++) {
            if ($servidor.HasExited) {
                if (Test-Path $log) { Get-Content -LiteralPath $log -Tail 5 | Out-Host }
                throw 'O backend encerrou. Confira os dados da conexão e a porta do serviço.'
            }
            try {
                $pronto = Invoke-RestMethod -Method Post -Uri ("http://127.0.0.1:"+$env:ENGRENAR_API_PORT+"/api/pronto") -Headers @{'X-Engrenar-Token'=$env:ENGRENAR_API_TOKEN} -TimeoutSec 2
            } catch {}
            if ($pronto) { break }
            Start-Sleep -Milliseconds 250
        }
        if (!$pronto) { throw 'O backend não respondeu na porta configurada.' }
        Remove-Item Env:ENGRENAR_DB_PASSWORD -ErrorAction SilentlyContinue
        if ($Apache) {
            Write-Host 'Conectado. Abra http://localhost/engrenar-painel/ no navegador.'
            Write-Host 'Mantenha esta janela aberta enquanto usa o painel.'
            $servidor.WaitForExit()
            return
        }
        Write-Host "Abra http://127.0.0.1:$web/ no navegador. Para encerrar, pressione Ctrl+C nesta janela."
        & $php -S "127.0.0.1:$web" -t (Join-Path $PSScriptRoot 'public')
        if ($LASTEXITCODE -ne 0) { throw 'O PHP encerrou. Confira se a porta do painel está disponível.' }
    }
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} finally {
    if ($servidor -and !$servidor.HasExited) { $servidor.Kill(); $servidor.WaitForExit() }
}
