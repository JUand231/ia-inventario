package com.adso.ia.dao;

import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Consultas de solo lectura que el asistente puede pedir. Devuelven JSON para
 * pasárselo a la IA.
 */
public class AsistenteDAO {

    // Solo recibe "hoy", "semana" o "mes" (el servicio lo valida): no hay riesgo de inyección.
    private static String desde(String periodo) {
        switch (periodo) {
            case "semana":
                return "DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0)";
            case "mes":
                return "DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)";
            default:
                return "CAST(GETDATE() AS DATE)";
        }
    }

    public JSONArray buscarProducto(String texto) throws SQLException {
        String sql = "SELECT TOP 5 p.nombre, p.stock, p.stock_minimo, p.precio_venta, p.ubicacion, c.nombre AS categoria "
                + "FROM productos p LEFT JOIN categorias c ON c.Id = p.Id_categoria "
                + "WHERE p.estado = 1 AND (p.nombre LIKE ? OR p.descripcion LIKE ?) ORDER BY p.nombre";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            String patron = "%" + texto + "%";
            ps.setString(1, patron);
            ps.setString(2, patron);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String ubicacion = rs.getString("ubicacion");
                    lista.put(new JSONObject()
                            .put("nombre", rs.getString("nombre"))
                            .put("categoria", rs.getString("categoria") == null ? "sin categoría" : rs.getString("categoria"))
                            .put("stock", rs.getInt("stock"))
                            .put("stock_minimo", rs.getInt("stock_minimo"))
                            .put("precio_venta_cop", rs.getBigDecimal("precio_venta"))
                            .put("ubicacion", ubicacion == null ? "sin ubicación registrada" : ubicacion));
                }
            }
        }
        return lista;
    }

    public JSONObject ventas(String periodo) throws SQLException {
        String sql = "SELECT ISNULL(SUM(cantidad * precio_unitario), 0) AS total, "
                + "ISNULL(SUM(cantidad), 0) AS unidades, COUNT(*) AS lineas "
                + "FROM salidas WHERE fecha >= " + desde(periodo);
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new JSONObject()
                    .put("periodo", periodo)
                    .put("total_vendido_cop", rs.getBigDecimal("total"))
                    .put("unidades_vendidas", rs.getInt("unidades"))
                    .put("lineas_de_venta", rs.getInt("lineas"));
        }
    }

    public JSONArray stockBajo() throws SQLException {
        String sql = "SELECT TOP 20 nombre, stock, stock_minimo, ubicacion FROM productos "
                + "WHERE estado = 1 AND stock <= stock_minimo ORDER BY stock";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String ubicacion = rs.getString("ubicacion");
                lista.put(new JSONObject()
                        .put("nombre", rs.getString("nombre"))
                        .put("stock", rs.getInt("stock"))
                        .put("stock_minimo", rs.getInt("stock_minimo"))
                        .put("ubicacion", ubicacion == null ? "sin ubicación registrada" : ubicacion));
            }
        }
        return lista;
    }

    public JSONArray masVendidos(String periodo) throws SQLException {
        String sql = "SELECT TOP 5 p.nombre, SUM(s.cantidad) AS unidades, SUM(s.cantidad * s.precio_unitario) AS total "
                + "FROM salidas s JOIN productos p ON p.Id = s.Id_producto "
                + "WHERE s.fecha >= " + desde(periodo) + " GROUP BY p.nombre ORDER BY unidades DESC";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.put(new JSONObject()
                        .put("nombre", rs.getString("nombre"))
                        .put("unidades_vendidas", rs.getInt("unidades"))
                        .put("total_cop", rs.getBigDecimal("total")));
            }
        }
        return lista;
    }
}
