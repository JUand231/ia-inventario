package com.adso.ia.dao;

import com.adso.ia.model.Categoria;
import com.adso.ia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoriaDAO {

    public List<Categoria> listarCategoria() throws SQLException {
        String consulta = "Select * from categorias";
        List<Categoria> lista = new ArrayList<>();

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(map(rs));
            }
        }
        return lista;

    }

    private Categoria map(ResultSet rs) throws SQLException {
        return new Categoria(
                rs.getInt("Id"),
                rs.getString("nombre")
        );
    }
}
