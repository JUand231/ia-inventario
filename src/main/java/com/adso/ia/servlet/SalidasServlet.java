package com.adso.ia.servlet;

import com.adso.ia.model.Salida;
import com.adso.ia.service.NegocioException;
import com.adso.ia.service.ProductoService;
import com.adso.ia.service.SalidaService;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/salidas")
public class SalidasServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final SalidaService servicio = new SalidaService();
    private final ProductoService productos = new ProductoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/salidas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            Salida salida = construir(request);
            servicio.registrar(salida);
            request.setAttribute("exito", "Salida registrada correctamente.");
        } catch (SQLException | IllegalArgumentException | NegocioException e) {
            request.setAttribute("error", e.getMessage());
        }

        cargarListas(request);

        request.getRequestDispatcher("/WEB-INF/vistas/salidas.jsp").forward(request, response);
    }

    private Salida construir(HttpServletRequest request) {
        Salida s = new Salida();

        s.setIdProducto(Integer.parseInt(request.getParameter("idProducto")));
        s.setCantidad(Integer.parseInt(request.getParameter("cantidad")));
        s.setCliente(request.getParameter("cliente"));

        String observaciones = request.getParameter("observaciones");
        s.setObservaciones(observaciones == null || observaciones.trim().isEmpty() ? null : observaciones.trim());

        s.setIdFactura(0);

        return s;
    }

    private void cargarListas(HttpServletRequest request) {
        try {
            request.setAttribute("salidas", servicio.listar());
            request.setAttribute("productos", productos.listarProductos());
        } catch (SQLException e) {
            if (request.getAttribute("error") == null) {
                request.setAttribute("error", "No se pudo cargar la lista: " + e.getMessage());
            }
        }
    }
}
