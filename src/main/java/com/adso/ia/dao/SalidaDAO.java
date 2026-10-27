package com.adso.ia.dao;

import com.adso.ia.model.Salida;
import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SalidaDAO {

    public List<Salida> listar() throws SQLException {

        String consulta = "SELECT s.Id, s.Id_producto, s.Id_factura, "
                + "s.cantidad, s.precio_unitario, s.cliente, s.fecha, "
                + "s.observaciones, p.nombre AS nombreProducto "
                + "FROM salidas s "
                + "INNER JOIN productos p ON p.Id = s.Id_producto "
                + "ORDER BY s.fecha DESC";

        List<Salida> lista = new ArrayList<>();

        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Salida salida = new Salida(
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

                lista.add(salida);
            }
        }

        return lista;
    }
}
