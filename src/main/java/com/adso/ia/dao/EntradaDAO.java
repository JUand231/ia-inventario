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

    public boolean registrar(Entrada e, Connection c) throws SQLException {
        String insertar = "Insert into entradas (Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) values (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = c.prepareStatement(insertar)) {

            ps.setInt(1, e.getIdProducto());
            ps.setInt(2, e.getCantidad());
            ps.setDouble(3, e.getPrecioUnitario());
            ps.setString(4, e.getProveedor());
            ps.setTimestamp(5, Timestamp.valueOf(e.getFecha()));
            ps.setString(6, e.getObservaciones());

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
