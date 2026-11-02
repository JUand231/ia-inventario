package com.adso.ia.servlet;

import com.adso.ia.service.ProductoService;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/alertas")
public class AlertasServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ProductoService servicio = new ProductoService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setAttribute("alertas", servicio.listarStockBajo());
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las alertas: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/vistas/alertas.jsp").forward(request, response);
    }
}
