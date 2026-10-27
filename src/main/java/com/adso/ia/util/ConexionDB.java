package com.adso.ia.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    private static final String URL = "jdbc:sqlserver://localhost;portNumber=1433;databaseName=dbIaInventario;encrypt=false;trustServerCertificate=true;";
    private static final String USUARIO = "ia_app";
    private static final String CLAVE = "12345";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver SQL Server no encontrado - revisa pom.xml", e);
        }
    }

    public static Connection getConexion() throws SQLException {
        return DriverManager.getConnection(URL, USUARIO, CLAVE);
    }
}
