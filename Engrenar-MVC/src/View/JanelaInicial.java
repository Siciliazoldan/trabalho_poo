package View;

import javax.swing.*;
import java.awt.*;
import java.net.URI;

public final class JanelaInicial {
    public static void mostrar(URI pagina, Process servidor) {
        SwingUtilities.invokeLater(() -> {
            JFrame janela = new JFrame("Engrenar");
            JButton abrir = new JButton("Abrir menu inicial");
            abrir.addActionListener(e -> {
                try { Desktop.getDesktop().browse(pagina); }
                catch (Exception erro) { JOptionPane.showMessageDialog(janela,pagina.toString()); }
            });
            JPanel painel = new JPanel(new BorderLayout(10,10));
            painel.setBorder(BorderFactory.createEmptyBorder(16,20,16,20));
            painel.add(new JLabel("Mantenha esta janela aberta enquanto usa o painel."),BorderLayout.NORTH);
            painel.add(abrir,BorderLayout.CENTER);
            painel.add(new JLabel(pagina.toString()),BorderLayout.SOUTH);
            janela.add(painel); janela.pack(); janela.setLocationRelativeTo(null);
            janela.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            janela.setVisible(true); abrir.doClick();
            servidor.onExit().thenRun(() -> SwingUtilities.invokeLater(() -> {
                abrir.setEnabled(false);
                janela.setTitle("Engrenar · servidor encerrado");
            }));
        });
    }
}
