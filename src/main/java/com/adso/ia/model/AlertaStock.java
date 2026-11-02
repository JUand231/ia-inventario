package com.adso.ia.model;

public class AlertaStock {

    private String nombre;
    private String sku;
    private int minimo;
    private int stock;

    public AlertaStock() {
    }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getMinimo() { return minimo; }
    public void setMinimo(int minimo) { this.minimo = minimo; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
}