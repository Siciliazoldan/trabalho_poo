import View.JanelaInicial;
import javax.swing.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.security.SecureRandom;
import java.util.*;

public class Principal {
    public static void main(String[] args) {
        try {
            Path raiz = Path.of(Principal.class.getProtectionDomain().getCodeSource().getLocation().toURI()).getParent();
            Path php = Path.of("C:/xampp/php/php.exe");
            if (!Files.isRegularFile(php)) {
                JFileChooser janela = new JFileChooser();
                janela.setDialogTitle("Selecione o php.exe do PHP 8.1+ ou do XAMPP");
                if (janela.showOpenDialog(null) != JFileChooser.APPROVE_OPTION) return;
                php = janela.getSelectedFile().toPath();
            }
            int porta;
            try (var socket = new ServerSocket(0,1,InetAddress.getByName("127.0.0.1"))) { porta=socket.getLocalPort(); }
            URI pagina = URI.create("http://127.0.0.1:"+porta+"/index.html");
            var pb = new ProcessBuilder(php.toString(), "-S","127.0.0.1:"+porta,"-t",raiz.resolve("site").toString());
            pb.directory(raiz.toFile());
            pb.environment().put("ENGRENAR_JAVA",Path.of(System.getProperty("java.home"),"bin","java.exe").toString());
            pb.environment().put("ENGRENAR_HOST","127.0.0.1:"+porta);
            pb.environment().put("ENGRENAR_KEY",Base64.getEncoder().encodeToString(new SecureRandom().generateSeed(32)));
            pb.redirectOutput(ProcessBuilder.Redirect.DISCARD); pb.redirectError(ProcessBuilder.Redirect.DISCARD);
            Process server=pb.start();
            Runtime.getRuntime().addShutdownHook(new Thread(server::destroy));
            boolean pronto=false;
            for(int i=0;i<40 && server.isAlive();i++){
                try(var socket=new Socket("127.0.0.1",porta)){ pronto=true; break; }
                catch(IOException e){Thread.sleep(100);}
            }
            if(!pronto) throw new IOException("O PHP não iniciou. Confira a instalação do XAMPP.");
            JanelaInicial.mostrar(pagina,server);
        } catch(Exception e) { JOptionPane.showMessageDialog(null,e.getMessage(),"Engrenar",JOptionPane.ERROR_MESSAGE); }
    }
}
