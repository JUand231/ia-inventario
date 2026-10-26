package com.adso.ia.dao;

import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FacturacionDAO {

    public List<String[]> buscar(String texto) throws SQLException {
        String sql = "SELECT TOP 10 Id, nombre, precio_venta, stock FROM productos "
                   + "WHERE nombre LIKE ? AND stock > 0 AND estado = 1 ORDER BY nombre";
        List<String[]> lista = new ArrayList<>();
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + texto + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{
                        rs.getString("Id"), rs.getString("nombre"),
                        rs.getBigDecimal("precio_venta").toPlainString(), rs.getString("stock")});
                }
            }
        }
        return lista;
    }

    /** Crea la factura, registra una salida por producto y descuenta stock. Devuelve el Id de la factura. */
    public int cobrar(String cliente, String metodo, int[] ids, int[] cantidades) throws SQLException {
        String nombreCliente = (cliente == null || cliente.trim().isEmpty()) ? "Mostrador" : cliente.trim();

        try (Connection con = ConexionDB.getConexion()) {
            con.setAutoCommit(false);
            try {
                int idFactura;
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO facturas (cliente, metodo_pago, total) VALUES (?, ?, 0)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, nombreCliente);
                    ps.setString(2, metodo);
                    ps.executeUpdate();
                    try (ResultSet k = ps.getGeneratedKeys()) {
                        k.next();
                        idFactura = k.getInt(1);
                    }
                }

                BigDecimal total = BigDecimal.ZERO;
                for (int i = 0; i < ids.length; i++) {
                    // 1) Descontar stock (falla si no alcanza o el producto está inactivo)
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE productos SET stock = stock - ? WHERE Id = ? AND stock >= ? AND estado = 1")) {
                        ps.setInt(1, cantidades[i]);
                        ps.setInt(2, ids[i]);
                        ps.setInt(3, cantidades[i]);
                        if (ps.executeUpdate() == 0) {
                            throw new SQLException("Stock insuficiente o producto inactivo (Id " + ids[i] + ").");
                        }
                    }

                    // 2) Precio real desde la BD
                    BigDecimal precio;
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT precio_venta FROM productos WHERE Id = ?")) {
                        ps.setInt(1, ids[i]);
                        try (ResultSet rs = ps.executeQuery()) {
                            rs.next();
                            precio = rs.getBigDecimal("precio_venta");
                        }
                    }
                    total = total.add(precio.multiply(BigDecimal.valueOf(cantidades[i])));

                    // 3) Salida ligada a la factura
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO salidas (Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) "
                          + "VALUES (?, ?, ?, ?, GETDATE(), ?, ?)")) {
                        ps.setInt(1, ids[i]);
                        ps.setInt(2, cantidades[i]);
                        ps.setBigDecimal(3, precio);
                        ps.setString(4, nombreCliente);
                        ps.setString(5, "Venta factura #" + idFactura);
                        ps.setInt(6, idFactura);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE facturas SET total = ? WHERE Id = ?")) {
                    ps.setBigDecimal(1, total);
                    ps.setInt(2, idFactura);
                    ps.executeUpdate();
                }

                con.commit();
                return idFactura;
            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            }
        }
    }
}