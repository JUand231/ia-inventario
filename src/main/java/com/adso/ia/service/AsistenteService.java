package com.adso.ia.service;

import com.adso.ia.dao.AsistenteDAO;
import com.adso.ia.model.RespuestaIA;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Properties;
import org.json.JSONArray;
import org.json.JSONObject;

public class AsistenteService {

    private static final String URL_API = "https://api.groq.com/openai/v1/chat/completions";
    /** Archivo de configuración: src/main/resources/config.properties (no va al repositorio). */
    private static final String ARCHIVO_CONFIG = "/config.properties";
    private static final String MODELO_POR_DEFECTO = "llama-3.3-70b-versatile";
    private static final int MAX_VUELTAS = 4;

    private static final String SISTEMA
            = "Eres el asistente de la ferretería Saca Clavos. Respondes en español, de forma breve y clara, "
            + "en texto plano (sin markdown ni tablas). "
            + "Para cualquier dato de productos, stock, precios, ubicaciones o ventas DEBES usar las herramientas; "
            + "nunca inventes cifras. Si una búsqueda no devuelve resultados, dilo y sugiere otro nombre. "
            + "Los montos están en pesos colombianos (COP). Si preguntan algo que no sea del inventario o de las "
            + "ventas, responde amablemente que solo puedes ayudar con eso.";

    private final AsistenteDAO dao = new AsistenteDAO();

    public RespuestaIA preguntar(String pregunta) throws IOException, SQLException {
        Properties cfg = cargarConfig();

        // Primero el .properties; si está vacío o no existe, la variable de entorno (respaldo)
        String key = obtener(cfg, "groq.api.key", "GROQ_API_KEY");
        if (key.isEmpty()) {
            throw new IOException("Falta la API key de Groq: copia config.properties.example a "
                    + "config.properties (en src/main/resources) y pega la clave en 'groq.api.key', "
                    + "o define la variable de entorno GROQ_API_KEY.");
        }
        String modelo = obtener(cfg, "groq.model", "GROQ_MODEL");
        if (modelo.isEmpty()) {
            modelo = MODELO_POR_DEFECTO;
        }

        JSONArray mensajes = new JSONArray()
                .put(new JSONObject().put("role", "system").put("content", SISTEMA))
                .put(new JSONObject().put("role", "user").put("content", pregunta));
        JSONArray herramientas = herramientas();
        int tokensEntrada = 0, tokensSalida = 0;

        for (int vuelta = 0; vuelta < MAX_VUELTAS; vuelta++) {
            JSONObject cuerpo = new JSONObject()
                    .put("model", modelo.trim())
                    .put("temperature", 0.2)
                    .put("messages", mensajes)
                    .put("tools", herramientas)
                    .put("tool_choice", "auto");

            JSONObject resp = llamar(cuerpo, key.trim());
            JSONObject uso = resp.optJSONObject("usage");
            if (uso != null) {
                tokensEntrada += uso.optInt("prompt_tokens");
                tokensSalida += uso.optInt("completion_tokens");
            }

            JSONObject msg = resp.getJSONArray("choices").getJSONObject(0).getJSONObject("message");
            JSONArray llamadas = msg.optJSONArray("tool_calls");

            if (llamadas == null || llamadas.length() == 0) {
                return new RespuestaIA(msg.optString("content", "").trim(),
                        tokensEntrada, tokensSalida, tokensEntrada + tokensSalida);
            }

            mensajes.put(msg);   // la IA pidió herramientas: se las ejecutamos y le devolvemos el resultado
            for (int i = 0; i < llamadas.length(); i++) {
                JSONObject llamada = llamadas.getJSONObject(i);
                JSONObject f = llamada.getJSONObject("function");
                String resultado = ejecutar(f.getString("name"), f.optString("arguments", "{}"));
                mensajes.put(new JSONObject()
                        .put("role", "tool")
                        .put("tool_call_id", llamada.getString("id"))
                        .put("content", resultado));
            }
        }
        throw new IOException("El asistente no logró responder. Intenta reformular la pregunta.");
    }

    /**
     * Lee config.properties desde el classpath (Maven lo copia a
     * target/classes). Si el archivo no existe o falla la lectura, devuelve
     * un Properties vacío para que se use el respaldo de variables de entorno.
     */
    private static Properties cargarConfig() {
        Properties cfg = new Properties();
        try (InputStream in = AsistenteService.class.getResourceAsStream(ARCHIVO_CONFIG)) {
            if (in != null) {
                cfg.load(new InputStreamReader(in, StandardCharsets.UTF_8));
            }
        } catch (IOException e) {
            // Archivo ilegible: se ignora y se intenta con la variable de entorno.
        }
        return cfg;
    }

    /** Devuelve el valor del .properties; si está vacío, el de la variable de entorno. */
    private static String obtener(Properties cfg, String propiedad, String variableEntorno) {
        String v = cfg.getProperty(propiedad);
        if (v == null || v.trim().isEmpty()) {
            v = System.getenv(variableEntorno);
        }
        return v == null ? "" : v.trim();
    }

    private String ejecutar(String nombre, String argsJson) throws SQLException {
        JSONObject args = new JSONObject(argsJson == null || argsJson.trim().isEmpty() ? "{}" : argsJson);
        String p = args.optString("periodo", "hoy");
        String periodo = ("semana".equals(p) || "mes".equals(p)) ? p : "hoy";

        switch (nombre) {
            case "buscar_producto":
                String texto = args.optString("texto", "").trim();
                return texto.isEmpty() ? "{\"error\":\"falta el texto a buscar\"}"
                        : dao.buscarProducto(texto).toString();
            case "ventas_periodo":
                return dao.ventas(periodo).toString();
            case "productos_stock_bajo":
                return dao.stockBajo().toString();
            case "mas_vendidos":
                return dao.masVendidos(periodo).toString();
            default:
                return "{\"error\":\"herramienta desconocida\"}";
        }
    }

    private static JSONArray herramientas() {
        JSONObject periodo = new JSONObject()
                .put("type", "string")
                .put("enum", new JSONArray().put("hoy").put("semana").put("mes"))
                .put("description", "hoy, semana (desde el lunes) o mes (desde el día 1)");

        return new JSONArray()
                .put(tool("buscar_producto",
                        "Busca productos por nombre. Devuelve stock, precio de venta y ubicación en la ferretería.",
                        new JSONObject().put("texto", new JSONObject()
                                .put("type", "string")
                                .put("description", "Palabra clave del producto en singular, ej: tornillo, cemento, martillo")),
                        "texto"))
                .put(tool("ventas_periodo",
                        "Total vendido en pesos y unidades vendidas en un periodo.",
                        new JSONObject().put("periodo", periodo), "periodo"))
                .put(tool("productos_stock_bajo",
                        "Lista los productos con stock igual o menor al mínimo.",
                        new JSONObject()))
                .put(tool("mas_vendidos",
                        "Los 5 productos más vendidos en un periodo.",
                        new JSONObject().put("periodo", periodo), "periodo"));
    }

    private static JSONObject tool(String nombre, String descripcion, JSONObject propiedades, String... requeridos) {
        JSONObject parametros = new JSONObject()
                .put("type", "object")
                .put("properties", propiedades)
                .put("required", new JSONArray(Arrays.asList(requeridos)));
        return new JSONObject()
                .put("type", "function")
                .put("function", new JSONObject()
                        .put("name", nombre)
                        .put("description", descripcion)
                        .put("parameters", parametros));
    }

    private JSONObject llamar(JSONObject cuerpo, String key) throws IOException {
        HttpURLConnection con = (HttpURLConnection) new URL(URL_API).openConnection();
        con.setRequestMethod("POST");
        con.setConnectTimeout(10000);
        con.setReadTimeout(30000);
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Authorization", "Bearer " + key);
        con.setRequestProperty("User-Agent", "SacaClavos-Inventario/1.0");

        try (OutputStream os = con.getOutputStream()) {
            os.write(cuerpo.toString().getBytes(StandardCharsets.UTF_8));
        }

        int codigo = con.getResponseCode();
        InputStream is = codigo >= 400 ? con.getErrorStream() : con.getInputStream();
        StringBuilder sb = new StringBuilder();
        if (is != null) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String linea;
                while ((linea = br.readLine()) != null) {
                    sb.append(linea);
                }
            }
        }
        if (codigo >= 400) {
            throw new IOException("Groq respondió " + codigo + ": " + sb);
        }
        return new JSONObject(sb.toString());
    }
}
