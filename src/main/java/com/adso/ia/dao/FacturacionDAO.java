package com.adso.ia.dao;

import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FacturacionDAO {

    public List<String[]> buscar(String texto) throws SQLException {
        String sql = "Select top 10 Id, nombre, precio_venta, stock from productos where nombre like ? and stock > 0 and estado = 1 order by nombre";

        List<String[]> lista = new ArrayList<>();

        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + texto + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{
                        rs.getString("Id"),
                        rs.getString("nombre"),
                        rs.getBigDecimal("precio_venta").toPlainString(),
                        rs.getString("stock")});
                }
            }
        }
        return lista;
    }

    public int crearFactura(String cliente, String metodo, Connection c) throws SQLException {
        String consulta = "Insert into facturas (fecha, cliente, metodo_pago, total) values (GETDATE(), ?, ?, 0)";

        try (PreparedStatement ps = c.prepareStatement(consulta, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, cliente);
            ps.setString(2, metodo);
            ps.executeUpdate();
            try (ResultSet k = ps.getGeneratedKeys()) {
                if (k.next()) {
                    return k.getInt(1);
                }
                throw new SQLException("No se pudo obtener el ID de la factura.");
            }
        }
    }

    public boolean actualizarTotal(int idFactura, BigDecimal total, Connection c) throws SQLException {
        String consulta = "Update facturas set total = ? where Id = ?";
        try (PreparedStatement ps = c.prepareStatement(consulta)) {
            ps.setBigDecimal(1, total);
            ps.setInt(2, idFactura);
            return ps.executeUpdate() > 0;
        }
    }
}
