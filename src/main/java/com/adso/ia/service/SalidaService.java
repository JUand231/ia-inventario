package com.adso.ia.service;

import com.adso.ia.dao.ProductoDAO;
import com.adso.ia.dao.SalidaDAO;
import com.adso.ia.model.Producto;
import com.adso.ia.model.Salida;
import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class SalidaService {

    private final SalidaDAO salida = new SalidaDAO();
    private final ProductoDAO producto = new ProductoDAO();

    public List<Salida> listar() throws SQLException {
        return salida.listar();
    }

    public boolean registrar(Salida s) throws SQLException, NegocioException {
        if (s == null) {
            throw new NegocioException("La salida no puede ser nula.");
        }
        if (s.getIdProducto() <= 0) {
            throw new NegocioException("El producto debe ser valido.");
        }
        if (!producto.existeProducto(s.getIdProducto())) {
            throw new NegocioException("El producto no existe o está inactivo.");
        }
        if (s.getCantidad() <= 0) {
            throw new NegocioException("La cantidad debe ser mayor a cero.");
        }
        if (s.getCliente() == null || s.getCliente().isBlank() || s.getCliente().length() > 50) {
            throw new NegocioException("El cliente es obligatorio y no debe superar los 50 caracteres.");
        }
        if (s.getObservaciones() != null && s.getObservaciones().length() > 100) {
            throw new NegocioException("Las observaciones no deben superar los 100 caracteres.");
        }

        Producto p = producto.buscarPorId(s.getIdProducto());
        if (p == null) {
            throw new NegocioException("El producto no existe o está inactivo.");
        }
        if (p.getStock() < s.getCantidad()) {
            throw new NegocioException("No hay stock suficiente: solo quedan " + p.getStock() + " unidades.");
        }

        try (Connection con = ConexionDB.getConexion()) {
            con.setAutoCommit(false);

            try {
                BigDecimal precio = producto.precioDeVenta(s.getIdProducto(), con);
                if (precio == null) {
                    throw new SQLException("No se encontró el producto con ID " + s.getIdProducto() + ".");
                }
                s.setPrecioUnitario(precio.doubleValue());

                if (!salida.registrar(s, con)) {
                    con.rollback();
                    return false;
                }
                if (!producto.descontarStock(s.getIdProducto(), s.getCantidad(), con)) {
                    con.rollback();
                    return false;
                }
                con.commit();
                return true;

            } catch (SQLException ex) {
                try {
                    con.rollback();
                } catch (SQLException errorRollback) {
                    ex.addSuppressed(errorRollback);
                }
                throw ex;
            }
        }
    }
}
