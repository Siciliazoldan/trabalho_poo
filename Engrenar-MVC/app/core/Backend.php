<?php
declare(strict_types=1);

final class Backend {
    public static function executar(array $config, string $action, array $fields=[]): mixed {
        $root=dirname(__DIR__,2);
        $java=getenv('ENGRENAR_JAVA');
        if (!$java) throw new DomainException('Abra Engrenar.jar para iniciar o serviço Java.');
        $process=proc_open([$java,'-Dfile.encoding=UTF-8','-cp',$root.'/Engrenar.jar'.PATH_SEPARATOR.$root.'/lib/*','Controller.Requisicao'],
            [['pipe','r'],['pipe','w'],['file','NUL','a']],$pipes,$root,null,['bypass_shell'=>true]);
        if (!is_resource($process)) throw new DomainException('Não foi possível iniciar o Java.');
        fwrite($pipes[0],json_encode(['config'=>$config,'action'=>$action,'fields'=>(object)$fields],JSON_THROW_ON_ERROR));
        fclose($pipes[0]); $body=stream_get_contents($pipes[1]); fclose($pipes[1]);
        $exit=proc_close($process);
        $reply=json_decode($body,true);
        if ($exit || !is_array($reply)) throw new DomainException('O backend Java não respondeu. Confira a pasta lib e o arquivo Engrenar.jar.');
        if (isset($reply['erro'])) throw new DomainException($reply['erro']);
        return $reply['resultado'];
    }

    public static function config(): ?array {
        if (!isset($_SESSION['conexao'])) return null;
        $blob=base64_decode($_SESSION['conexao']);
        $raw=openssl_decrypt(substr($blob,28),'aes-256-gcm',base64_decode(getenv('ENGRENAR_KEY')),OPENSSL_RAW_DATA,substr($blob,0,12),substr($blob,12,16));
        return $raw===false ? null : json_decode($raw,true);
    }

    public static function guardar(array $config): void {
        $iv=random_bytes(12);
        $cipher=openssl_encrypt(json_encode($config,JSON_THROW_ON_ERROR),'aes-256-gcm',base64_decode(getenv('ENGRENAR_KEY')),OPENSSL_RAW_DATA,$iv,$tag);
        if ($cipher===false) throw new DomainException('Não foi possível guardar a configuração da sessão.');
        $_SESSION['conexao']=base64_encode($iv.$tag.$cipher);
    }

    public static function call(string $action,array $fields=[]): mixed {
        $cfg=self::config();
        if (!$cfg) {header('Location: config.php');exit;}
        $fields['usuario']=Auth::user()['id']??0;
        return self::executar($cfg,$action,$fields);
    }
}
