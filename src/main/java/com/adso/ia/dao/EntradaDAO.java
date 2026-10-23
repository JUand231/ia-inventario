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
        String consulta = "Insert into entradas (Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) select p.Id, ?, ?, ?, ?, ? from productos p where p.Id = ? and p.estado = 1";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, e.getCantidad());
            ps.setDouble(2, e.getPrecioUnitario());
            ps.setString(3, e.getProveedor());
            ps.setTimestamp(4, Timestamp.valueOf(e.getFecha()));
            ps.setString(5, e.getObservaciones());
            ps.setInt(6, e.getIdProducto());

            return ps.executeUpdate() > 0;
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
