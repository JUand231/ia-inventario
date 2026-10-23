package com.adso.ia.web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Módulo 1 (Caja). Por ahora solo sirve la vista; la lógica de cobro,
 * facturación y descuento de stock se agregará aquí.
 */
@WebServlet(name = "FacturacionServlet", urlPatterns = {"/facturacion"})
public class FacturacionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/vistas/facturacion.jsp").forward(request, response);
    }
}
