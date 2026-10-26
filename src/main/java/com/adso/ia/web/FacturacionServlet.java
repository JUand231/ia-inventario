package com.adso.ia.web;

import com.adso.ia.dao.FacturacionDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "FacturacionServlet", urlPatterns = {"/facturacion"})
public class FacturacionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final FacturacionDAO dao = new FacturacionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if ("buscar".equals(request.getParameter("accion"))) {
            String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
            response.setContentType("application/json;charset=UTF-8");
            try {
                List<String[]> r = dao.buscar(q);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < r.size(); i++) {
                    String[] p = r.get(i);
                    if (i > 0) {
                        sb.append(',');
                    }
                    sb.append("{\"id\":").append(p[0])
                            .append(",\"nombre\":\"").append(p[1].replace("\\", "\\\\").replace("\"", "\\\"")).append('"')
                            .append(",\"precio\":").append(p[2])
                            .append(",\"stock\":").append(p[3]).append('}');
                }
                response.getWriter().write(sb.append(']').toString());
            } catch (SQLException e) {
                response.setStatus(500);
                response.getWriter().write("[]");
            }
            return;
        }
        request.getRequestDispatcher("/WEB-INF/vistas/facturacion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            String[] idsStr = request.getParameterValues("idProducto");
            String[] cantStr = request.getParameterValues("cantidad");
            if (idsStr == null || idsStr.length == 0 || cantStr == null || idsStr.length != cantStr.length) {
                throw new IllegalArgumentException("La factura no tiene productos.");
            }
            int[] ids = new int[idsStr.length];
            int[] cants = new int[idsStr.length];
            for (int i = 0; i < ids.length; i++) {
                ids[i] = Integer.parseInt(idsStr[i]);
                cants[i] = Integer.parseInt(cantStr[i]);
                if (cants[i] <= 0) {
                    throw new IllegalArgumentException("Cantidad inválida.");
                }
            }
            String cliente = request.getParameter("cliente");
            String metodo = request.getParameter("metodoPago");
            int idFactura = dao.cobrar(cliente, metodo == null ? "EFECTIVO" : metodo, ids, cants);
            request.setAttribute("exito", "Factura #" + idFactura + " registrada correctamente.");
        } catch (SQLException | IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/vistas/facturacion.jsp").forward(request, response);
    }
}
