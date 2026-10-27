package com.adso.ia.service;

import com.adso.ia.dao.EntradaDAO;
import com.adso.ia.dao.ProductoDAO;
import com.adso.ia.model.Entrada;
import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class EntradaService {

    private EntradaDAO entrada = new EntradaDAO();
    private ProductoDAO producto = new ProductoDAO();

    public List<Entrada> listar() throws SQLException {
        return entrada.listar();
    }

    public boolean registrar(Entrada e) throws SQLException, NegocioException {
        if (e == null) {
            throw new NegocioException("La entrada no puede ser nula.");
        }
        if (e.getIdProducto() <= 0) {
            throw new NegocioException("El producto debe ser valido");
        }
        if (!producto.existeProducto(e.getIdProducto())) {
            throw new NegocioException("El producto no existe o está inactivo.");
        }
        if (e.getCantidad() <= 0) {
            throw new NegocioException("La cantidad debe ser mayor a cero.");
        }
        if (e.getPrecioUnitario() <= 0) {
            throw new NegocioException("El precio debe ser mayor a cero.");
        }
        if (e.getProveedor() == null || e.getProveedor().isBlank() || e.getProveedor().length() > 100) {
            throw new NegocioException("El proveedor es obligatorio y no debe superar los 100 caracteres.");
        }
        if (e.getFecha() == null) {
            throw new NegocioException("la fecha es obligtoria.");
        }
        if (e.getObservaciones() != null && e.getObservaciones().length() > 100) {
            throw new NegocioException("Las observaciones no deben superar los 100 caracteres.");
        }

        try (Connection con = ConexionDB.getConexion()) {
            con.setAutoCommit(false);

            try {
                if (!entrada.registrar(e, con)) {
                    con.rollback();
                    return false;
                }
                if (!producto.sumarStock(e.getIdProducto(), e.getCantidad(), con)) {
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
