package com.adso.ia.dao;

import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
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
        // Desglose: separa lo que salió con factura de lo que salió como
        // salida manual (merma/ajuste, Id_factura NULL).
        String sql = "SELECT ISNULL(SUM(cantidad * precio_unitario), 0) AS total, "
                + "ISNULL(SUM(cantidad), 0) AS unidades, COUNT(*) AS lineas, "
                + "ISNULL(SUM(CASE WHEN Id_factura IS NULL THEN cantidad ELSE 0 END), 0) AS uni_manuales, "
                + "ISNULL(SUM(CASE WHEN Id_factura IS NULL THEN cantidad * precio_unitario ELSE 0 END), 0) AS total_manuales, "
                + "ISNULL(SUM(CASE WHEN Id_factura IS NULL THEN 1 ELSE 0 END), 0) AS lineas_manuales "
                + "FROM salidas WHERE fecha >= " + desde(periodo);
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            BigDecimal total = rs.getBigDecimal("total");
            BigDecimal totalManuales = rs.getBigDecimal("total_manuales");
            int unidades = rs.getInt("unidades");
            int uniManuales = rs.getInt("uni_manuales");
            int lineas = rs.getInt("lineas");
            int lineasManuales = rs.getInt("lineas_manuales");
            return new JSONObject()
                    .put("periodo", periodo)
                    .put("total_vendido_cop", total)
                    .put("unidades_vendidas", unidades)
                    .put("lineas_de_venta", lineas)
                    .put("salidas_manuales", new JSONObject()
                            .put("unidades", uniManuales)
                            .put("lineas", lineasManuales)
                            .put("total_cop", totalManuales))
                    .put("ventas_con_factura", new JSONObject()
                            .put("unidades", unidades - uniManuales)
                            .put("lineas", lineas - lineasManuales)
                            .put("total_cop", total.subtract(totalManuales)));
        }
    }

    /** Últimas entradas de mercancía a la bodega (compras a proveedores). */
    public JSONArray entradasRecientes() throws SQLException {
        String sql = "SELECT TOP 5 e.fecha, e.cantidad, e.precio_unitario, e.proveedor, p.nombre AS producto "
                + "FROM entradas e JOIN productos p ON p.Id = e.Id_producto ORDER BY e.fecha DESC";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.put(new JSONObject()
                        .put("fecha", rs.getTimestamp("fecha").toLocalDateTime().toString())
                        .put("producto", rs.getString("producto"))
                        .put("cantidad", rs.getInt("cantidad"))
                        .put("precio_unitario_cop", rs.getBigDecimal("precio_unitario"))
                        .put("proveedor", rs.getString("proveedor")));
            }
        }
        return lista;
    }

    /** Cuentas globales del inventario: productos, unidades, valor y avisos. */
    public JSONObject resumenInventario() throws SQLException {
        String sql = "SELECT COUNT(*) AS productos, ISNULL(SUM(stock), 0) AS unidades, "
                + "ISNULL(SUM(stock * precio_compra), 0) AS valor_costo, "
                + "ISNULL(SUM(CASE WHEN stock = 0 THEN 1 ELSE 0 END), 0) AS agotados, "
                + "ISNULL(SUM(CASE WHEN stock <= stock_minimo THEN 1 ELSE 0 END), 0) AS bajo_minimo, "
                + "(SELECT COUNT(*) FROM categorias) AS categorias "
                + "FROM productos WHERE estado = 1";
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new JSONObject()
                    .put("productos_activos", rs.getInt("productos"))
                    .put("categorias", rs.getInt("categorias"))
                    .put("unidades_en_stock", rs.getInt("unidades"))
                    .put("valor_inventario_cop", rs.getBigDecimal("valor_costo"))
                    .put("productos_agotados", rs.getInt("agotados"))
                    .put("productos_bajo_minimo", rs.getInt("bajo_minimo"));
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

    /** Últimas 5 facturas emitidas, de la más reciente a la más antigua. */
    public JSONArray ultimasFacturas() throws SQLException {
        String sql = "SELECT TOP 5 Id, fecha, cliente, metodo_pago, total FROM facturas ORDER BY Id DESC";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cliente = rs.getString("cliente");
                lista.put(new JSONObject()
                        .put("numero", rs.getInt("Id"))
                        .put("fecha", rs.getTimestamp("fecha").toLocalDateTime().toString())
                        .put("cliente", cliente == null || cliente.trim().isEmpty() ? "Cliente general" : cliente)
                        .put("metodo_pago", rs.getString("metodo_pago"))
                        .put("total_cop", rs.getBigDecimal("total")));
            }
        }
        return lista;
    }

    /** Productos que se compraron en una factura (usa la vista vw_detalle_factura). */
    public JSONArray detalleFactura(int numero) throws SQLException {
        String sql = "SELECT producto, cantidad, precio_unitario, subtotal FROM vw_detalle_factura "
                + "WHERE id_factura = ? ORDER BY producto";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, numero);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.put(new JSONObject()
                            .put("producto", rs.getString("producto"))
                            .put("cantidad", rs.getInt("cantidad"))
                            .put("precio_unitario_cop", rs.getBigDecimal("precio_unitario"))
                            .put("subtotal_cop", rs.getBigDecimal("subtotal")));
                }
            }
        }
        return lista;
    }

    /** Facturas de un cliente (búsqueda por nombre parcial), más recientes primero. */
    public JSONArray facturasPorCliente(String nombre) throws SQLException {
        // COLLATE ... CI_AI: la comparación ignora acentos y mayúsculas, así
        // "Andrés" encuentra a "Andres" (los datos se guardan sin tildes).
        String sql = "SELECT TOP 10 Id, fecha, metodo_pago, total FROM facturas "
                + "WHERE cliente LIKE ? COLLATE Latin1_General_CI_AI ORDER BY Id DESC";
        JSONArray lista = new JSONArray();
        try (Connection cn = ConexionDB.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, "%" + nombre + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.put(new JSONObject()
                            .put("numero", rs.getInt("Id"))
                            .put("fecha", rs.getTimestamp("fecha").toLocalDateTime().toString())
                            .put("metodo_pago", rs.getString("metodo_pago"))
                            .put("total_cop", rs.getBigDecimal("total")));
                }
            }
        }
        return lista;
    }
}
