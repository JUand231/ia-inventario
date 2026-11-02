package com.adso.ia.model;

import java.math.BigDecimal;
import java.util.Date;

public class VentaResumen {

    private String numeroTicket;
    private Date fecha;
    private String cliente;
    private String documento;
    private int items;
    private String metodoPago;
    private BigDecimal total;

    public VentaResumen() {
    }

    public String getNumeroTicket() { return numeroTicket; }
    public void setNumeroTicket(String numeroTicket) { this.numeroTicket = numeroTicket; }

    public Date getFecha() { return fecha; }
    public void setFecha(Date fecha) { this.fecha = fecha; }

    public String getCliente() { return cliente; }
    public void setCliente(String cliente) { this.cliente = cliente; }

    public String getDocumento() { return documento; }
    public void setDocumento(String documento) { this.documento = documento; }

    public int getItems() { return items; }
    public void setItems(int items) { this.items = items; }

    public String getMetodoPago() { return metodoPago; }
    public void setMetodoPago(String metodoPago) { this.metodoPago = metodoPago; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
}