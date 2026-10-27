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

        String consulta = "Select s.Id, s.Id_producto, s.Id_factura, s.cantidad, s.precio_unitario, s.cliente, s.fecha, s.observaciones, p.nombre AS nombreProducto from salidas s join productos p ON p.Id = s.Id_producto Order by s.fecha desc";

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

    public boolean registrar(Salida s, Connection c) throws SQLException {
        String consulta = "Insert into salidas (Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) values (?, ?, ?, ?, GETDATE(), ?, ?)";

        try (PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, s.getIdProducto());
            ps.setInt(2, s.getCantidad());
            ps.setDouble(3, s.getPrecioUnitario());
            ps.setString(4, s.getCliente());
            ps.setString(5, s.getObservaciones());
            ps.setInt(6, s.getIdFactura());

            return ps.executeUpdate() > 0;
        }
    }
}
