package DAO;

import java.sql.*;
import java.util.*;

public abstract class DAO {
    protected final Connection db;

    protected DAO(Connection db) { this.db = db; }

    private void bind(PreparedStatement statement, Object... values) throws SQLException {
        for (int i = 0; i < values.length; i++) statement.setObject(i + 1, values[i]);
    }

    protected List<Map<String,Object>> rows(String sql, Object... values) throws SQLException {
        try (PreparedStatement st = db.prepareStatement(sql)) {
            bind(st, values);
            try (ResultSet rs = st.executeQuery()) {
                List<Map<String,Object>> result = new ArrayList<>();
                ResultSetMetaData columns = rs.getMetaData();
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    for (int n = 1; n <= columns.getColumnCount(); n++) {
                        Object value = rs.getObject(n);
                        if (value instanceof java.time.temporal.TemporalAccessor || value instanceof java.util.Date)
                            value = rs.getString(n);
                        row.put(columns.getColumnLabel(n), value);
                    }
                    result.add(row);
                }
                return result;
            }
        }
    }

    protected int execute(String sql, Object... values) throws SQLException {
        try (PreparedStatement st = db.prepareStatement(sql)) {
            bind(st, values);
            return st.executeUpdate();
        }
    }

    protected long insert(String sql, Object... values) throws SQLException {
        try (PreparedStatement st = db.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(st, values);
            st.executeUpdate();
            try (ResultSet keys = st.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Chave não retornada.");
                return keys.getLong(1);
            }
        }
    }

    protected void require(boolean valid, String message) {
        if (!valid) throw new IllegalArgumentException(message);
    }
}
