package com.adso.ia.service;

import com.adso.ia.dao.CategoriaDAO;
import com.adso.ia.dao.ProductoDAO;
import com.adso.ia.model.Producto;
import java.sql.SQLException;
import java.util.List;

public class ProductoService {

    private ProductoDAO producto = new ProductoDAO();
    private CategoriaDAO categoria = new CategoriaDAO();

    public List<Producto> listarProductos() throws SQLException {
        return producto.listarProductos();
    }

    public Producto buscarPorId(int id) throws SQLException, NegocioException {
        if (id < 1) {
            throw new NegocioException("El Id del producto debe ser valido.");
        }
        return producto.buscarPorId(id);
    }

    public boolean insertarProducto(Producto p) throws SQLException, NegocioException {
        if (p == null) {
            throw new NegocioException("El producto no puede ser nulo.");
        }
        if (p.getNombre() == null || p.getNombre().isBlank() || p.getNombre().length() > 100) {
            throw new NegocioException("El nombre es obligatorio y no debe superar los 100 caracteres.");
        }
        if (p.getDescripcion() == null || p.getDescripcion().isBlank() || p.getDescripcion().length() > 100) {
            throw new NegocioException("La descripcion del producto es obligatoria y no debe superar los 100 caracteres.");
        }
        if (p.getPrecioCompra() <= 0) {
            throw new NegocioException("El precio de la compra debe ser mayor a cero.");
        }
        if (p.getPrecioVenta() <= 0) {
            throw new NegocioException("El precio de venta debe ser mayor a cero.");
        }
        if (p.getPrecioVenta() < p.getPrecioCompra()) {
            throw new NegocioException("El precio de venta no puede ser inferior al precio de compra.");
        }
        if (p.getStock() < 0) {
            throw new NegocioException("El stock debe ser igual o mayor a cero.");
        }
        if (p.getStockMinimo() < 0) {
            throw new NegocioException("El stock minimo debe ser igual o mayor a cero.");
        }
        if (p.getIdCategoria() < 1) {
            throw new NegocioException("Debe seleccionar una categoría válida.");
        }
        if (!categoria.existeCategoria(p.getIdCategoria())) {
            throw new NegocioException("La categoria seleccionada no existe.");
        }
        return producto.insertarProducto(p);
    }

    public boolean actualizarProducto(Producto p) throws SQLException, NegocioException {
        if (p == null) {
            throw new NegocioException("El producto no puede ser nulo.");
        }
        if (p.getId() < 1) {
            throw new NegocioException("El Id del producto debe ser válido");
        }
        if (!producto.existeProducto(p.getId())) {
            throw new NegocioException("El producto no existe o está inactivo.");
        }
        if (p.getNombre() == null || p.getNombre().isBlank() || p.getNombre().length() > 100) {
            throw new NegocioException("El nombre es obligatorio y no debe superar los 100 caracteres.");
        }
        if (p.getDescripcion() == null || p.getDescripcion().isBlank() || p.getDescripcion().length() > 100) {
            throw new NegocioException("La descripción es obligatoria y no debe superar los 100 caracteres.");
        }
        if (p.getPrecioCompra() <= 0) {
            throw new NegocioException("El precio de compra debe ser mayor que cero.");
        }
        if (p.getPrecioVenta() <= 0) {
            throw new NegocioException("El precio de venta debe ser mayor que cero.");
        }
        if (p.getPrecioVenta() < p.getPrecioCompra()) {
            throw new NegocioException("El precio de venta no puede ser inferior al precio de compra.");
        }
        if (p.getStock() < 0) {
            throw new NegocioException("El stock debe ser igual o mayor a cero.");
        }
        if (p.getStockMinimo() < 0) {
            throw new NegocioException("El stock mínimo debe ser igual o mayor a cero.");
        }
        if (p.getIdCategoria() < 1) {
            throw new NegocioException("Debe seleccionar una categoría válida.");
        }
        if (!categoria.existeCategoria(p.getIdCategoria())) {
            throw new NegocioException("La categoría seleccionada no existe.");
        }
        return producto.actualizarProducto(p);
    }

    public boolean eliminarProducto(int id) throws SQLException, NegocioException {
        if (id < 1) {
            throw new NegocioException("El Id del producto debe ser valido.");
        }
        if (!producto.existeProducto(id)) {
            throw new NegocioException("El producto no existe o esta inactivo.");
        }
        return producto.eliminarProducto(id);
    }

    public List<Producto> listarStockBajo() throws SQLException {
        return producto.listarStockBajo();
    }
}
