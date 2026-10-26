package com.adso.ia.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Facturas {

    private int id;
    private LocalDateTime fecha;
    private String cliente;
    private String metodoPago;
    private BigDecimal total;

    public Facturas() {
    }

    public Facturas(int id, LocalDateTime fecha, String cliente, String metodoPago, BigDecimal total) {
        this.id = id;
        this.fecha = fecha;
        this.cliente = cliente;
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

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
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