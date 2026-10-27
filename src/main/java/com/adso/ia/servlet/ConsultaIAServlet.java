package com.adso.ia.servlet;

import com.adso.ia.model.MensajeChat;
import com.adso.ia.service.AsistenteService;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Módulo 2 (Asistente IA): GET muestra el chat, POST responde una pregunta en
 * JSON.
 */
@WebServlet(name = "ConsultaIAServlet", urlPatterns = {"/consulta"})
public class ConsultaIAServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int MAX_PREGUNTA = 500;
    private final AsistenteService servicio = new AsistenteService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/vistas/consulta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String pregunta = request.getParameter("pregunta");
        pregunta = pregunta == null ? "" : pregunta.trim();

        MensajeChat mensaje;
        if (pregunta.isEmpty()) {
            mensaje = new MensajeChat("", "Escribe una pregunta.");
        } else if (pregunta.length() > MAX_PREGUNTA) {
            mensaje = new MensajeChat(pregunta.substring(0, 40) + "...", "La pregunta es muy larga (máximo " + MAX_PREGUNTA + " caracteres).");
        } else {
            try {
                mensaje = new MensajeChat(pregunta, servicio.preguntar(pregunta));
            } catch (Exception e) {
                getServletContext().log("Error en el asistente", e);
                mensaje = new MensajeChat(pregunta, "No se pudo obtener la respuesta: " + e.getMessage());
            }
        }
        response.getWriter().write(mensaje.toJSON().toString());
    }
}
