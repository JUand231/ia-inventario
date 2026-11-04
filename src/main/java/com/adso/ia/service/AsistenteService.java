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
    private static final String MODELO_POR_DEFECTO = "openai/gpt-oss-120b";
    private static final int MAX_VUELTAS = 4;

    private static final String SISTEMA
            = "Eres el asistente de la ferretería Saca Clavos. Respondes en español, de forma breve y clara, "
            + "en texto plano (sin markdown ni tablas). "
            + "Puedes ayudar con todo lo de la ferretería: productos, stock, precios, ubicaciones, ventas, "
            + "facturas emitidas, clientes, compras a proveedores y ganancias. Para cualquier dato DEBES "
            + "usar las herramientas; nunca inventes cifras. Si una búsqueda no devuelve resultados, dilo y "
            + "sugiere otro nombre. Los montos están en pesos colombianos (COP). Si preguntan algo que no "
            + "tenga relación con la ferretería, responde amablemente que solo puedes ayudar con información "
            + "de la ferretería.";

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
            case "entradas_recientes":
                return dao.entradasRecientes().toString();
            case "resumen_inventario":
                return dao.resumenInventario().toString();
            case "ultimas_facturas":
                return dao.ultimasFacturas().toString();
            case "detalle_factura":
                int numero = args.optInt("numero", 0);
                return numero <= 0 ? "{\"error\":\"falta el número de factura\"}"
                        : dao.detalleFactura(numero).toString();
            case "facturas_por_cliente":
                String cliente = args.optString("cliente", "").trim();
                return cliente.isEmpty() ? "{\"error\":\"falta el nombre del cliente\"}"
                        : dao.facturasPorCliente(cliente).toString();
            case "ventas_producto":
                String producto = args.optString("texto", "").trim();
                return producto.isEmpty() ? "{\"error\":\"falta el texto a buscar\"}"
                        : dao.ventasProducto(producto).toString();
            case "clientes_top":
                String periodoClientes = args.optString("periodo", "todo");
                return dao.clientesTop(periodoClientes).toString();
            case "ganancia_periodo":
                return dao.ganancia(periodo).toString();
            case "productos_destacados":
                return dao.productosDestacados().toString();
            case "entradas_por_producto":
                String productoEntradas = args.optString("texto", "").trim();
                return productoEntradas.isEmpty() ? "{\"error\":\"falta el texto a buscar\"}"
                        : dao.entradasPorProducto(productoEntradas).toString();
            default:
                return "{\"error\":\"herramienta desconocida\"}";
        }
    }

    private static JSONArray herramientas() {
        JSONObject periodo = new JSONObject()
                .put("type", "string")
                .put("enum", new JSONArray().put("hoy").put("semana").put("mes"))
                .put("description", "hoy, semana (desde el lunes) o mes (desde el día 1)");

        JSONObject periodoTodo = new JSONObject()
                .put("type", "string")
                .put("enum", new JSONArray().put("hoy").put("semana").put("mes").put("todo"))
                .put("description", "hoy, semana (desde el lunes), mes (desde el día 1) o todo (histórico completo)");

        return new JSONArray()
                .put(tool("buscar_producto",
                        "Busca productos por nombre. Devuelve stock, precio de venta y ubicación en la ferretería.",
                        new JSONObject().put("texto", new JSONObject()
                                .put("type", "string")
                                .put("description", "Palabra clave del producto en singular, ej: tornillo, cemento, martillo")),
                        "texto"))
                .put(tool("ventas_periodo",
                        "Unidades y dinero que salieron en un periodo, separando las ventas con factura "
                        + "de las salidas manuales (merma o ajuste sin factura).",
                        new JSONObject().put("periodo", periodo), "periodo"))
                .put(tool("entradas_recientes",
                        "Las últimas 5 entradas de mercancía a la bodega: producto, cantidad, precio, "
                        + "proveedor y fecha. Úsalo cuando pregunten qué mercancía entró o quién la trajo.",
                        new JSONObject()))
                .put(tool("resumen_inventario",
                        "Cuentas globales del inventario: productos activos, categorías, unidades en stock, "
                        + "valor del inventario, productos agotados y productos bajo mínimo.",
                        new JSONObject()))
                .put(tool("productos_stock_bajo",
                        "Lista los productos con stock igual o menor al mínimo.",
                        new JSONObject()))
                .put(tool("mas_vendidos",
                        "Los 5 productos más vendidos en un periodo.",
                        new JSONObject().put("periodo", periodo), "periodo"))
                .put(tool("ventas_producto",
                        "Cuánto se vendió de un producto en todos los tiempos: unidades, dinero generado, "
                        + "stock actual y precio. Úsalo para preguntas como '¿cuántos martillos se vendieron?'.",
                        new JSONObject().put("texto", new JSONObject()
                                .put("type", "string")
                                .put("description", "Nombre del producto, ej: martillo, cemento, clavo")),
                        "texto"))
                .put(tool("clientes_top",
                        "Los 5 clientes que más dinero han comprado: número de facturas y total comprado.",
                        new JSONObject().put("periodo", periodoTodo), "periodo"))
                .put(tool("ganancia_periodo",
                        "Ganancia bruta de un periodo: ingreso menos costo de lo vendido.",
                        new JSONObject().put("periodo", periodo), "periodo"))
                .put(tool("productos_destacados",
                        "Productos extremos de la ferretería: el más caro, el más barato, "
                        + "el que más stock tiene y el que menos.",
                        new JSONObject()))
                .put(tool("entradas_por_producto",
                        "Historial de compras a proveedores de un producto: fecha, cantidad, precio y proveedor.",
                        new JSONObject().put("texto", new JSONObject()
                                .put("type", "string")
                                .put("description", "Nombre del producto, ej: cemento, silicona")),
                        "texto"))
                .put(tool("ultimas_facturas",
                        "Las últimas 5 facturas emitidas, ordenadas de la más reciente a la más antigua. "
                        + "La primera de la lista es la última factura emitida, la segunda es la penúltima "
                        + "y la tercera es la antepenúltima. Devuelve número, fecha, cliente, "
                        + "método de pago y total de cada una.",
                        new JSONObject()))
                .put(tool("detalle_factura",
                        "Lo que se compró en una factura: productos, cantidad y subtotal. "
                        + "Úsalo cuando pregunten qué compraron en una factura.",
                        new JSONObject().put("numero", new JSONObject()
                                .put("type", "integer")
                                .put("description", "Número de la factura, ej: 9")),
                        "numero"))
                .put(tool("facturas_por_cliente",
                        "Facturas de un cliente (búsqueda por nombre parcial): número, fecha y total. "
                        + "Úsalo cuando pregunten qué compró o cuánto facturó una persona.",
                        new JSONObject().put("cliente", new JSONObject()
                                .put("type", "string")
                                .put("description", "Nombre del cliente o parte de él, ej: Carmen")),
                        "cliente"));
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
