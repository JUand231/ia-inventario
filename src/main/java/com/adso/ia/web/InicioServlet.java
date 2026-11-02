package com.adso.ia.web;

import com.adso.ia.dao.DashboardDAO;
import com.adso.ia.model.AlertaStock;
import com.adso.ia.model.ResumenPanel;
import com.adso.ia.model.VentaResumen;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controlador del panel de inicio (patron MVC).
 *
 * Responsabilidad unica: pedir los datos, ponerlos en el request y reenviar a
 * la vista. Nada de HTML aqui: el HTML vive en WEB-INF/vistas/index.jsp.
 */
@WebServlet(name = "InicioServlet", urlPatterns = {"/inicio"})
public class InicioServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final ZoneId ZONA = ZoneId.of("America/Bogota");
    private static final DateTimeFormatter FECHA_LARGA
            = DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM 'de' yyyy", Locale.forLanguageTag("es-CO"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        DashboardDAO dao = new DashboardDAO();

        try {
            request.setAttribute("resumen", dao.obtenerResumen());
        } catch (SQLException e) {
            log("No se pudo cargar el resumen del panel", e);
            request.setAttribute("errorBD", mensajeCorto(e));
        }

        try {
            request.setAttribute("ultimasVentas", dao.ultimasVentas(5));
        } catch (SQLException e) {
            log("No se pudieron cargar las últimas ventas", e);
        }

        try {
            request.setAttribute("alertasStock", dao.stockCritico(5));
        } catch (SQLException e) {
            log("No se pudieron cargar las alertas de stock", e);
        }

        request.setAttribute("fechaHoy", fechaHoy());
        request.getRequestDispatcher("/WEB-INF/vistas/index.jsp").forward(request, response);
    }

    private String fechaHoy() {
        String texto = LocalDate.now(ZONA).format(FECHA_LARGA);
        return Character.toUpperCase(texto.charAt(0)) + texto.substring(1);
    }

    /**
     * Un mensaje corto y legible para mostrar en la vista (nada de stacktrace).
     */
    private String mensajeCorto(SQLException e) {
        String mensaje = e.getMessage();
        if (mensaje == null || mensaje.isBlank()) {
            mensaje = "Error de conexión con dbIaInventario";
        }
        return mensaje.length() > 170 ? mensaje.substring(0, 170) + "…" : mensaje;
    }
}
