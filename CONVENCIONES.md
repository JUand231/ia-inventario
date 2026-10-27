# CONVENCIONES — Ia-Inventario (Ferretería Sacaclavos)

> Guía de estilo OBLIGATORIA para humanos e IAs que trabajen en este proyecto.
> Cualquier IA debe leer este archivo ANTES de generar código.
> ⚠️ ESTE ARCHIVO SE ELIMINA ANTES DE ENTREGAR EL PROYECTO TERMINADO.

## Stack y contexto
- Java (release 17) · Tomcat 9 con paquetes **javax.*** (NUNCA jakarta.*) · Maven embebido
- SQL Server con autenticación de Windows: **sin usuarios ni contraseñas en el código**
- Vistas JSP con JSTL. Librerías por CDN: Bootstrap 5.3, Bootstrap Icons, SweetAlert2, Chart.js
- Patrón: MVC en capas `servlet → service → dao → model`

## Arquitectura por capas

| Capa | Paquete | Qué hace | Qué NUNCA hace |
|---|---|---|---|
| Servlet | `com.adso.ia.servlet` | Recibe parámetros, llama al service, hace `forward` al JSP | SQL, HTML, lógica |
| Service | `com.adso.ia.service` | Validaciones (`NegocioException`) y **transacciones** (abre conexión, `commit`/`rollback`) | HTML ni SQL armado |
| DAO | `com.adso.ia.dao` | SQL puro con `PreparedStatement`. Si participa en una transacción del service, **recibe la `Connection`** | Commit/rollback propio, validaciones de negocio |
| Model | `com.adso.ia.model` | POJOs (un objeto por tabla), sin lógica | Nada que no sea getters/setters/constructores |
| Util | `com.adso.ia.util` | `ConexionDB` y utilidades | — |

## Reglas de código (inquebrantables)

1. **`PreparedStatement` SIEMPRE** — nunca `Statement`, nunca concatenar datos en el SQL (`?` + `ps.setXxx`).
2. **`try-with-resources` SIEMPRE** para `Connection`, `PreparedStatement` y `ResultSet`.
3. **Cuenta `?` del SQL = cuenta `ps.setXxx` del código** antes de dar un método por bueno.
4. **La transacción vive en el service:** `cn.setAutoCommit(false)` → los DAOs usan la misma `cn` → `commit()` si todo salió, `rollback()` si algo falla.
5. **Errores de negocio:** `throw new NegocioException("mensaje claro en español")` — nunca `printStackTrace` ni `System.out`.
6. **Nombres:** POJOs en camelCase (`precioVenta`), columnas de la BD en snake_case (`precio_venta`). Verificar contra la BD real, **nunca adivinar**.
7. **Métodos de DAO:** `listar()`, `buscarPorId(int)`, `insertar(x)`, `actualizar(x)`, `eliminar(...)`, `registrar(x)`.
8. **Cero credenciales en el repo** — la API key de Groq vive en `config.properties` (está en `.gitignore`).
9. **Nada de archivos temporales en el repo** — lo que se crea para probar se borra al terminar de usarlo.
10. **Nadie altera la BD sin actualizar el script SQL** en el mismo commit.

## Git
- Antes de empezar a trabajar: `git pull`. Al terminar: `commit` + `push`.
- Trabajo en parejas: lo que no esté commiteado NO existe para la otra persona.

## Checklist de revisión (2 minutos, antes de aceptar cambios de la pareja)
1. ¿Respeta las capas (sin saltos)?
2. ¿Paquetes correctos (`servlet`/`service`/`dao`/`model`)?
3. ¿SQL con `PreparedStatement` y `?` = sets?
4. ¿Compila?
5. ¿Sin archivos muertos ni temporales?

## URLs de servlets

| URL | Módulo |
|---|---|
| `/inicio` | Dashboard (KPIs) |
| `/facturacion` | Facturación |
| `/consulta` | Chat IA |
| `/productos` | Productos CRUD *(pendiente)* |
| `/entradas` | Entradas *(pendiente)* |
| `/salidas` | Salidas manuales *(pendiente)* |
| `/alertas` | Alertas de stock bajo *(pendiente)* |
