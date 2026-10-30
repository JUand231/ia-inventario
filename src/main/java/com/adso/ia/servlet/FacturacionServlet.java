package com.adso.ia.servlet;

import com.adso.ia.model.Producto;
import com.adso.ia.service.FacturacionService;
import com.adso.ia.service.NegocioException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/facturacion")
public class FacturacionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FacturacionService servicio = new FacturacionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if ("buscar".equals(request.getParameter("accion"))) {
            String q = request.getParameter("q") == null
                    ? ""
                    : request.getParameter("q").trim();

            response.setContentType("application/json;charset=UTF-8");

            try {
                List<Producto> resultados = servicio.buscar(q);
                JSONArray json = new JSONArray();

                for (Producto p : resultados) {
                    JSONObject producto = new JSONObject();
                    producto.put("id", p.getId());
                    producto.put("nombre", p.getNombre());
                    producto.put("precio", p.getPrecioVenta());
                    producto.put("stock", p.getStock());

                    json.put(producto);
                }

                response.getWriter().write(json.toString());

            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("[]");
            }

            return;
        }

        request.getRequestDispatcher("/WEB-INF/vistas/facturacion.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String[] idsStr = request.getParameterValues("idProducto");
            String[] cantStr = request.getParameterValues("cantidad");

            if (idsStr == null || cantStr == null
                    || idsStr.length == 0
                    || idsStr.length != cantStr.length) {

                throw new IllegalArgumentException(
                        "La factura debe contener al menos un producto."
                );
            }

            int[] ids = new int[idsStr.length];
            int[] cantidades = new int[cantStr.length];

            for (int i = 0; i < ids.length; i++) {
                ids[i] = Integer.parseInt(idsStr[i]);
                cantidades[i] = Integer.parseInt(cantStr[i]);
            }

            String cliente = request.getParameter("cliente");
            String metodo = request.getParameter("metodoPago");

            int idFactura = servicio.cobrar(
                    cliente,
                    metodo,
                    ids,
                    cantidades
            );

            request.setAttribute(
                    "exito",
                    "Factura #" + idFactura + " registrada correctamente."
            );

        } catch (SQLException | IllegalArgumentException | NegocioException e) {
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/vistas/facturacion.jsp")
                .forward(request, response);
    }
}
