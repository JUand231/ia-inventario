package com.adso.ia.service;

import com.adso.ia.dao.FacturacionDAO;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;

public class FacturacionService {

    private final FacturacionDAO facturacion = new FacturacionDAO();

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

        return facturacion.cobrar(cliente, metodo, ids, cantidades);
    }
}
