package com.adso.ia.util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

public class prueba {

    public static void main(String[] args) {

        System.out.println("=== PRUEBA DE CONEXION ===");

        try (Connection conexion = ConexionDB.getConexion()) {

            if (conexion != null && !conexion.isClosed()) {
                System.out.println("OK: Conexion establecida.");

                DatabaseMetaData meta = conexion.getMetaData();

                System.out.println("Base de datos: "
                        + conexion.getCatalog());

                System.out.println("SQL Server: "
                        + meta.getDatabaseProductVersion());

                try (Statement st = conexion.createStatement();
                     ResultSet rs = st.executeQuery(
                             "SELECT COUNT(*) AS total FROM productos")) {

                    if (rs.next()) {
                        System.out.println("Productos encontrados: "
                                + rs.getInt("total"));
                    }
                }

                System.out.println("OK: Consulta de productos ejecutada.");

            } else {
                System.out.println("ERROR: La conexion esta cerrada.");
            }

        } catch (Exception e) {
            System.out.println("ERROR AL PROBAR LA BASE DE DATOS:");
            e.printStackTrace();
        }
    }
}