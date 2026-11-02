package com.adso.ia.servlet;

import com.adso.ia.model.Entrada;
import com.adso.ia.service.EntradaService;
import com.adso.ia.service.NegocioException;
import com.adso.ia.service.ProductoService;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/entradas")
public class EntradasServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final EntradaService servicio = new EntradaService();
    private final ProductoService productos = new ProductoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/entradas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            Entrada entrada = construir(request);
            servicio.registrar(entrada);
            request.setAttribute("exito", "Entrada registrada correctamente.");
        } catch (SQLException | IllegalArgumentException | NegocioException e) {
            request.setAttribute("error", e.getMessage());
        }

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/entradas.jsp").forward(request, response);
    }

    private Entrada construir(HttpServletRequest request) {
        Entrada e = new Entrada();

        e.setIdProducto(Integer.parseInt(request.getParameter("idProducto")));
        e.setCantidad(Integer.parseInt(request.getParameter("cantidad")));
        e.setPrecioUnitario(Double.parseDouble(request.getParameter("precioUnitario")));
        e.setProveedor(request.getParameter("proveedor"));

        String observaciones = request.getParameter("observaciones");
        e.setObservaciones(observaciones == null || observaciones.trim().isEmpty() ? null : observaciones.trim());

        e.setFecha(LocalDateTime.now());

        return e;
    }

    private void cargarListas(HttpServletRequest request) {
        try {
            request.setAttribute("entradas", servicio.listar());
            request.setAttribute("productos", productos.listarProductos());
        } catch (SQLException e) {
            if (request.getAttribute("error") == null) {
                request.setAttribute("error", "No se pudo cargar la lista: " + e.getMessage());
            }
        }
    }
}
