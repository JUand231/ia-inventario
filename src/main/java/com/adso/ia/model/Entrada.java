package com.adso.ia.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Entrada {

    /** Patron de texto para mostrar la fecha en las vistas (JSP). */
    private static final DateTimeFormatter TEXTO = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int id;
    private int idProducto;
    private int cantidad;
    private double precioUnitario;
    private String proveedor;
    private LocalDateTime fecha;
    private String observaciones;
    private String nombreProducto;

    public Entrada() {
    }

    public Entrada(int id, int idProducto, int cantidad, double precioUnitario, String proveedor, LocalDateTime fecha, String observaciones, String nombreProducto) {
        this.id = id;
        this.idProducto = idProducto;
        this.cantidad = cantidad;
        this.precioUnitario = precioUnitario;
        this.proveedor = proveedor;
        this.fecha = fecha;
        this.observaciones = observaciones;
        this.nombreProducto = nombreProducto;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(int idProducto) {
        this.idProducto = idProducto;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }

    public double getPrecioUnitario() {
        return precioUnitario;
    }

    public void setPrecioUnitario(double precioUnitario) {
        this.precioUnitario = precioUnitario;
    }

    public String getProveedor() {
        return proveedor;
    }

    public void setProveedor(String proveedor) {
        this.proveedor = proveedor;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    /**
     * Fecha ya en texto ("02/11/2026 15:30") para las vistas.
     * fmt:formatDate de JSTL solo entiende java.util.Date y no acepta
     * LocalDateTime, por eso la vista usa este getter y no esa etiqueta.
     */
    public String getFechaTexto() {
        return fecha == null ? "" : fecha.format(TEXTO);
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

}
