package com.adso.ia.dao;

import com.adso.ia.model.Salida;
import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SalidaDAO {

    public List<Salida> listar() throws SQLException {
        String consulta = "Select s.Id, s.Id_producto, s.cantidad, s.precio_unitario, s.cliente, s.fecha, s.observaciones, p.nombre AS nombreProducto from salidas s inner join productos p ON p.Id = s.Id_producto order by s.fecha desc";

        List<Salida> lista = new ArrayList<>();

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(map(rs));
            }
        }

        return lista;
    }

    public boolean registrar(Salida s) throws SQLException {
        String consulta = "Insert into salidas (Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones) select p.Id, ?, ?, ?, ?, ? from productos p where p.Id = ? and p.estado = 1";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, s.getCantidad());
            ps.setDouble(2, s.getPrecioUnitario());
            ps.setString(3, s.getCliente());
            ps.setTimestamp(4, Timestamp.valueOf(s.getFecha()));
            ps.setString(5, s.getObservaciones());
            ps.setInt(6, s.getIdProducto());

            return ps.executeUpdate() > 0;
        }
    }

    private Salida map(ResultSet rs) throws SQLException {
        return new Salida(
                rs.getInt("Id"),
                rs.getInt("Id_producto"),
                rs.getInt("cantidad"),
                rs.getDouble("precio_unitario"),
                rs.getString("cliente"),
                rs.getTimestamp("fecha").toLocalDateTime(),
                rs.getString("observaciones"),
                rs.getString("nombreProducto"),
                rs.getInt("Id_factura")
        );
    }
}
