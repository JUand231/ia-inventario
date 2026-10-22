package com.adso.ia.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    // Autenticacion de Windows (SSPI): sin usuario ni clave, igual que Integrated Security en C#
    private static final String URL = "jdbc:sqlserver://localhost;portNumber=1433;databaseName=dbIaInventario;integratedSecurity=true;encrypt=false;trustServerCertificate=true;";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver SQL Server no encontrado - revisa pom.xml", e);
        }
    }

    public static Connection getConexion() throws SQLException {
        return DriverManager.getConnection(URL);
    }
}
