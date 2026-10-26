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

    public List<Categoria> listarCategorias() throws SQLException {
        String consulta = "Select * from categorias";
        List<Categoria> lista = new ArrayList<>();

        try (Connection c = ConexionDB.getConexion(); PreparedStatement ps = c.prepareStatement(consulta); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(map(rs));
            }
        }
        return lista;

    }
    public boolean existeCategoria(int idCategoria) throws SQLException {
        String consulta = "Select COUNT(*) from categorias where Id = ?";

        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(consulta)) {

            ps.setInt(1, idCategoria);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private Categoria map(ResultSet rs) throws SQLException {
        return new Categoria(
                rs.getInt("Id"),
                rs.getString("nombre")
        );
    }
}
