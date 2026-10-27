package com.adso.ia.dao;

import com.adso.ia.model.Producto;
import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public List<Producto> listarProductos() throws SQLException {
        String consulta = "Select * from productos where estado = 1";

        List<Producto> lista = new ArrayList<>();

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(map(rs));
            }
        }
        return lista;
    }

    public Producto buscarPorId(int id) throws SQLException {
        String consulta = "select * from productos p where p.id = ? and p.estado = 1";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    public boolean insertarProducto(Producto p) throws SQLException {
        String consulta = "Insert into productos(nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, ubicacion) values (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecioCompra());
            ps.setDouble(4, p.getPrecioVenta());
            ps.setInt(5, p.getStock());
            ps.setInt(6, p.getStockMinimo());
            ps.setInt(7, p.getIdCategoria());
            ps.setString(8, p.getUbicacion());

            return ps.executeUpdate() > 0;

        }
    }

    public boolean actualizarProducto(Producto p) throws SQLException {
        String consulta = "Update productos set nombre = ?, descripcion = ?, precio_compra = ?, precio_venta = ?, stock = ?, stock_minimo = ?, Id_categoria = ?, ubicacion = ? where Id = ? and estado = 1";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecioCompra());
            ps.setDouble(4, p.getPrecioVenta());
            ps.setInt(5, p.getStock());
            ps.setInt(6, p.getStockMinimo());
            ps.setInt(7, p.getIdCategoria());
            ps.setString(8, p.getUbicacion());
            ps.setInt(9, p.getId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminarProducto(int id) throws SQLException {
        String consulta = "Update productos set estado = 0 where Id = ? and estado = 1";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        }
    }

    public List<Producto> listarStockBajo() throws SQLException {
        String consulta = "Select * from productos where stock <= stock_minimo and estado = 1 order by stock asc";

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {

            List<Producto> lista = new ArrayList<>();
            while (rs.next()) {
                lista.add(map(rs));
            }
            return lista;

        }
    }

    public boolean existeProducto(int id) throws SQLException {
        String consulta = "Select COUNT(*) from productos where Id = ? and estado = 1";

        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(consulta)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    public boolean sumarStock(int idProducto, int cantidad, Connection c) throws SQLException {
        String consulta = "Update productos set stock = stock + ? where Id = ? and estado = 1";

        try (PreparedStatement ps = c.prepareStatement(consulta)) {
            ps.setInt(1, cantidad);
            ps.setInt(2, idProducto);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean descontarStock(int idProducto, int cantidad, Connection c) throws SQLException {
        String consulta = "Update productos set stock = stock - ? where Id = ? and stock >= ? and estado = 1";

        try (PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, cantidad);
            ps.setInt(2, idProducto);
            ps.setInt(3, cantidad);

            return ps.executeUpdate() > 0;
        }
    }

    public BigDecimal precioDeVenta(int idProducto, Connection c) throws SQLException {
        String consulta = "Select precio_venta from productos where Id = ? and estado = 1";

        try (PreparedStatement ps = c.prepareStatement(consulta)) {

            ps.setInt(1, idProducto);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal("precio_venta") : null;
            }
        }
    }

    private Producto map(ResultSet rs) throws SQLException {
        return new Producto(
                rs.getInt("Id"),
                rs.getString("nombre"),
                rs.getString("descripcion"),
                rs.getDouble("precio_compra"),
                rs.getDouble("precio_venta"),
                rs.getInt("stock"),
                rs.getInt("stock_minimo"),
                rs.getInt("Id_categoria"),
                rs.getBoolean("estado"),
                rs.getString("ubicacion")
        );
    }
}
