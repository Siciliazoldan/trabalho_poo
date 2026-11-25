package Util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class ConnectionFactory {
    private ConnectionFactory() {}

    public static Connection getConnection(String host, int port, String database, String user, String password) throws SQLException {
        if (port < 1 || port > 65535) throw new IllegalArgumentException("Porta inválida.");
        if (!host.matches("[A-Za-z0-9.-]+") || !database.matches("[A-Za-z0-9_]+"))
            throw new IllegalArgumentException("Host ou nome do banco inválido.");
        Properties settings = new Properties();
        settings.setProperty("user", user);
        settings.setProperty("password", password);
        settings.setProperty("connectionTimeZone", "LOCAL");
        settings.setProperty("connectTimeout", "4000");
        settings.setProperty("socketTimeout", "12000");
        return DriverManager.getConnection("jdbc:mysql://" + host + ":" + port + "/" + database, settings);
    }
}


