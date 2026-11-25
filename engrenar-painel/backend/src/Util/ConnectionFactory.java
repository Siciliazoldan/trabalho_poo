package Util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class ConnectionFactory {
    private ConnectionFactory() {}

    public static String setting(String name, String fallback) {
        return System.getenv().getOrDefault(name, fallback);
    }

    public static Connection getConnection() throws SQLException {
        String host = setting("ENGRENAR_DB_HOST", "127.0.0.1");
        int port = Integer.parseInt(setting("ENGRENAR_DB_PORT", "3306"));
        String database = setting("ENGRENAR_DB_NAME", "engrenar");
        if (!host.matches("[A-Za-z0-9.-]+") || !database.matches("[A-Za-z0-9_]+"))
            throw new IllegalArgumentException("Host ou nome do banco inválido.");
        Properties settings = new Properties();
        settings.setProperty("user", setting("ENGRENAR_DB_USER", "root"));
        settings.setProperty("password", setting("ENGRENAR_DB_PASSWORD", ""));
        settings.setProperty("connectionTimeZone", "LOCAL");
        settings.setProperty("connectTimeout", "4000");
        settings.setProperty("socketTimeout", "12000");
        return DriverManager.getConnection("jdbc:mysql://" + host + ":" + port + "/" + database, settings);
    }
}
