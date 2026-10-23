package com.adso.ia.web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Módulo 2 (Asistente IA). Por ahora solo sirve la vista; la conversación
 * con la API de IA y el contexto del inventario se agregarán aquí.
 */
@WebServlet(name = "ConsultaIAServlet", urlPatterns = {"/consulta"})
public class ConsultaIAServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/vistas/consulta.jsp").forward(request, response);
    }
}
