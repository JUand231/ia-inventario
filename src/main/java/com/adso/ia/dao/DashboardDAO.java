package com.adso.ia.dao;

import com.adso.ia.model.ResumenPanel;
import com.adso.ia.util.ConexionDB;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Consultas de estadisticas para el panel de inicio.
 *
 * Toda la logica de SQL vive aqui (capa DAO); el servlet solo la llama y el
 * JSP solo muestra. Si el dia de manana cambias una regla de negocio (por
 * ejemplo "semana" = desde el lunes), se cambia en UN solo lugar: este archivo.
 */
public class DashboardDAO {

    /**
     * Una unica consulta con subconsultas = UN solo viaje a la base de datos.
     *
     * Reglas de negocio contenidas aqui:
     *  - stock bajo   : stock <= stock_minimo
     *  - ventas hoy   : desde las 00:00 de hoy (GETDATE() en fecha local del servidor)
     *  - ventas semana: desde el lunes de la semana actual (semana calendario)
     *  - ventas mes   : desde el dia 1 del mes en curso
     */
    private static final String SQL_RESUMEN =
            "SELECT "
            + " (SELECT COUNT(*) FROM productos) AS totalProductos, "
            + " (SELECT COUNT(*) FROM categorias) AS totalCategorias, "
            + " (SELECT ISNULL(SUM(stock), 0) FROM productos) AS unidadesStock, "
            + " (SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo) AS stockBajo, "
            + " (SELECT ISNULL(SUM(cantidad * precio_unitario), 0) FROM salidas "
            + "   WHERE fecha >= CAST(GETDATE() AS DATE)) AS ventasHoy, "
            + " (SELECT ISNULL(SUM(cantidad * precio_unitario), 0) FROM salidas "
            + "   WHERE fecha >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0)) AS ventasSemana, "
            + " (SELECT ISNULL(SUM(cantidad * precio_unitario), 0) FROM salidas "
            + "   WHERE fecha >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AS ventasMes";

    public ResumenPanel obtenerResumen() throws SQLException {
        try (Connection cn = ConexionDB.getConexion();
                PreparedStatement ps = cn.prepareStatement(SQL_RESUMEN);
                ResultSet rs = ps.executeQuery()) {

            if (!rs.next()) {
                return new ResumenPanel(0, 0, 0, 0, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
            }

            return new ResumenPanel(
                    rs.getInt("totalProductos"),
                    rs.getInt("totalCategorias"),
                    rs.getInt("unidadesStock"),
                    rs.getInt("stockBajo"),
                    dinero(rs, "ventasHoy"),
                    dinero(rs, "ventasSemana"),
                    dinero(rs, "ventasMes"));
        }
    }

    private BigDecimal dinero(ResultSet rs, String columna) throws SQLException {
        BigDecimal valor = rs.getBigDecimal(columna);
        return valor == null ? BigDecimal.ZERO : valor;
    }
}
