package com.adso.ia.model;

import java.math.BigDecimal;

/**
 * Resumen del panel de inicio: inventario + ventas por rango de tiempo.
 */
public class ResumenPanel {

    private final int totalProductos;
    private final int totalCategorias;
    private final int unidadesEnStock;
    private final int productosStockBajo;
    private final BigDecimal ventasHoy;
    private final BigDecimal ventasSemana;
    private final BigDecimal ventasMes;

    public ResumenPanel(int totalProductos, int totalCategorias, int unidadesEnStock,
            int productosStockBajo, BigDecimal ventasHoy, BigDecimal ventasSemana, BigDecimal ventasMes) {
        this.totalProductos = totalProductos;
        this.totalCategorias = totalCategorias;
        this.unidadesEnStock = unidadesEnStock;
        this.productosStockBajo = productosStockBajo;
        this.ventasHoy = ventasHoy;
        this.ventasSemana = ventasSemana;
        this.ventasMes = ventasMes;
    }

    public int getTotalProductos() {
        return totalProductos;
    }

    public int getTotalCategorias() {
        return totalCategorias;
    }

    public int getUnidadesEnStock() {
        return unidadesEnStock;
    }

    public int getProductosStockBajo() {
        return productosStockBajo;
    }

    public BigDecimal getVentasHoy() {
        return ventasHoy;
    }

    public BigDecimal getVentasSemana() {
        return ventasSemana;
    }

    public BigDecimal getVentasMes() {
        return ventasMes;
    }
}
