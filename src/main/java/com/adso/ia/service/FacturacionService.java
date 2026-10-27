package com.adso.ia.service;

import com.adso.ia.dao.FacturacionDAO;
import com.adso.ia.dao.ProductoDAO;
import com.adso.ia.dao.SalidaDAO;
import com.adso.ia.model.Salida;
import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;

public class FacturacionService {

    private final FacturacionDAO facturacion = new FacturacionDAO();
    private final ProductoDAO producto = new ProductoDAO();
    private final SalidaDAO salidaDAO = new SalidaDAO();

    public List<String[]> buscar(String texto) throws SQLException {
        if (texto == null) {
            texto = "";
        }
        return facturacion.buscar(texto.trim());
    }

    public int cobrar(String cliente, String metodo, int[] ids, int[] cantidades)
            throws SQLException, NegocioException {

        if (ids == null || cantidades == null || ids.length == 0 || ids.length != cantidades.length) {
            throw new NegocioException("La factura debe contener al menos un producto.");
        }

        for (int i = 0; i < ids.length; i++) {

            if (ids[i] <= 0) {
                throw new NegocioException("El ID de un producto no es válido.");
            }
            if (cantidades[i] <= 0) {
                throw new NegocioException("La cantidad de cada producto debe ser mayor a cero.");
            }
        }

        if (metodo == null || metodo.isBlank()) {
            throw new NegocioException("Debes seleccionar un método de pago.");
        }

        metodo = metodo.trim().toUpperCase(Locale.ROOT);

        if (!metodo.equals("EFECTIVO") && !metodo.equals("TARJETA") && !metodo.equals("TRANSFERENCIA")) {
            throw new NegocioException("El método de pago seleccionado no es válido.");
        }

        if (cliente != null) {
            cliente = cliente.trim();

            if (cliente.isEmpty()) {
                cliente = null;
            }

            if (cliente != null && cliente.length() > 50) {
                throw new NegocioException("El nombre del cliente no puede superar los 50 caracteres.");
            }
        }

        String nombreCliente = (cliente == null) ? "Mostrador" : cliente;

        try (Connection con = ConexionDB.getConexion()) {
            con.setAutoCommit(false);

            try {
                int idFactura = facturacion.crearFactura(nombreCliente, metodo, con);
                BigDecimal total = BigDecimal.ZERO;

                for (int i = 0; i < ids.length; i++) {

                    if (!producto.descontarStock(ids[i], cantidades[i], con)) {
                        throw new SQLException("Stock insuficiente o producto inactivo (Id " + ids[i] + ").");
                    }

                    BigDecimal precio = producto.precioDeVenta(ids[i], con);
                    if (precio == null) {
                        throw new SQLException("No se encontró el producto con ID " + ids[i] + ".");
                    }

                    total = total.add(precio.multiply(BigDecimal.valueOf(cantidades[i])));

                    Salida salida = new Salida();
                    salida.setIdProducto(ids[i]);
                    salida.setCantidad(cantidades[i]);
                    salida.setPrecioUnitario(precio.doubleValue());
                    salida.setCliente(nombreCliente);
                    salida.setObservaciones("Venta factura #" + idFactura);
                    salida.setIdFactura(idFactura);
                    salidaDAO.registrar(salida, con);
                }

                if (!facturacion.actualizarTotal(idFactura, total, con)) {
                    throw new SQLException("No se pudo actualizar el total de la factura.");
                }
                con.commit();
                return idFactura;

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
