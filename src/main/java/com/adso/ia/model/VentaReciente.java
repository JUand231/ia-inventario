package com.adso.ia.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Una venta reciente del panel de inicio (ultima factura con su resumen).
 */
public class VentaReciente {

    /** Patron de texto para mostrar la fecha en las vistas (JSP). */
    private static final DateTimeFormatter TEXTO = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int id;
    private LocalDateTime fecha;
    private String cliente;
    private int items;
    private String metodoPago;
    private BigDecimal total;

    public VentaReciente() {
    }

    public VentaReciente(int id, LocalDateTime fecha, String cliente, int items, String metodoPago, BigDecimal total) {
        this.id = id;
        this.fecha = fecha;
        this.cliente = cliente;
        this.items = items;
        this.metodoPago = metodoPago;
        this.total = total;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    /** Fecha ya en texto para las vistas (fmt:formatDate no acepta LocalDateTime). */
    public String getFechaTexto() {
        return fecha == null ? "" : fecha.format(TEXTO);
    }

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public int getItems() {
        return items;
    }

    public void setItems(int items) {
        this.items = items;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }
}
