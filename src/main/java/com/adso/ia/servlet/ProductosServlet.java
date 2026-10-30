package com.adso.ia.servlet;

import com.adso.ia.model.Producto;
import com.adso.ia.service.NegocioException;
import com.adso.ia.service.ProductoService;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/productos")
public class ProductosServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ProductoService servicio = new ProductoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        if ("editar".equals(accion)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editando", servicio.buscarPorId(id));
            } catch (SQLException | IllegalArgumentException | NegocioException e) {
                request.setAttribute("error", e.getMessage());
            }
        }

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/productos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        try {
            if ("eliminar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                servicio.eliminarProducto(id);
                request.setAttribute("exito", "Producto eliminado correctamente.");

            } else {
                Producto p = construir(request);

                if ("actualizar".equals(accion)) {
                    servicio.actualizarProducto(p);
                    request.setAttribute("exito", "Producto actualizado correctamente.");
                } else {
                    servicio.insertarProducto(p);
                    request.setAttribute("exito", "Producto registrado correctamente.");
                }
            }
        } catch (SQLException | IllegalArgumentException | NegocioException e) {
            request.setAttribute("error", e.getMessage());
        }

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/productos.jsp").forward(request, response);
    }

    private Producto construir(HttpServletRequest request) {
        Producto p = new Producto();

        String id = request.getParameter("id");
        if (id != null && !id.isBlank()) {
            p.setId(Integer.parseInt(id));
        }

        p.setNombre(request.getParameter("nombre"));
        p.setDescripcion(request.getParameter("descripcion"));
        p.setPrecioCompra(Double.parseDouble(request.getParameter("precioCompra")));
        p.setPrecioVenta(Double.parseDouble(request.getParameter("precioVenta")));
        p.setStock(Integer.parseInt(request.getParameter("stock")));
        p.setStockMinimo(Integer.parseInt(request.getParameter("stockMinimo")));
        p.setIdCategoria(Integer.parseInt(request.getParameter("idCategoria")));

        String ubicacion = request.getParameter("ubicacion");
        p.setUbicacion(ubicacion == null || ubicacion.trim().isEmpty() ? null : ubicacion.trim());

        p.setEstado(true);

        return p;
    }

    private void cargarListas(HttpServletRequest request) {
        try {
            request.setAttribute("productos", servicio.listarProductos());
            request.setAttribute("categorias", servicio.listarCategorias());
        } catch (SQLException e) {
            if (request.getAttribute("error") == null) {
                request.setAttribute("error", "No se pudo cargar la lista: " + e.getMessage());
            }
        }
    }
}
