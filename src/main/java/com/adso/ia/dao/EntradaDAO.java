package com.adso.ia.dao;

import com.adso.ia.model.Entrada;
import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class EntradaDAO {

    public List<Entrada> listar() throws SQLException {
        String consulta = "Select e.Id, e.Id_producto, e.cantidad, e.precio_unitario, e.proveedor, e.fecha, e.observaciones, p.nombre AS nombreProducto from entradas e inner join productos p on p.Id = e.Id_producto order by e.fecha desc";

        List<Entrada> lista = new ArrayList<>();

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(map(rs));
            }
        }

        return lista;
    }

    public boolean registrar(Entrada e) throws SQLException {
        String insertar = "Insert into entradas (Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) Select p.Id, ?, ?, ?, ?, ? from productos p WHERE p.Id = ? AND p.estado = 1";

        String actualizarStock = "Update productos set stock = stock + ? where Id = ? and estado = 1";

        try (Connection c = ConexionDB.getConexion()) {
            c.setAutoCommit(false);

            try {
                try (PreparedStatement ps = c.prepareStatement(insertar)) {
                    ps.setInt(1, e.getCantidad());
                    ps.setDouble(2, e.getPrecioUnitario());
                    ps.setString(3, e.getProveedor());
                    ps.setTimestamp(4, Timestamp.valueOf(e.getFecha()));
                    ps.setString(5, e.getObservaciones());
                    ps.setInt(6, e.getIdProducto());

                    if (ps.executeUpdate() == 0) {
                        c.rollback();
                        return false;
                    }
                }

                try (PreparedStatement ps = c.prepareStatement(actualizarStock)) {
                    ps.setInt(1, e.getCantidad());
                    ps.setInt(2, e.getIdProducto());

                    if (ps.executeUpdate() == 0) {
                        c.rollback();
                        return false;
                    }
                }

                c.commit();
                return true;

            } catch (SQLException | RuntimeException ex) {
                try {
                    c.rollback();
                } catch (SQLException errorRollback) {
                    ex.addSuppressed(errorRollback);
                }

                throw ex;
            }
        }
    }

    private Entrada map(ResultSet rs) throws SQLException {
        return new Entrada(
                rs.getInt("Id"),
                rs.getInt("Id_producto"),
                rs.getInt("cantidad"),
                rs.getDouble("precio_unitario"),
                rs.getString("proveedor"),
                rs.getTimestamp("fecha").toLocalDateTime(),
                rs.getString("observaciones"),
                rs.getString("nombreProducto")
        );
    }
}
