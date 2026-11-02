<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="es_CO" />
<%
    // Evita que el navegador muestre versiones guardadas de esta página
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="theme-color" content="#0A2E58">
        <title>Saca Clavos · Panel de control</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <%-- Fuente elegante para la marca "SacaClavos" (con respaldo serif si no hay internet) --%>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "inicio"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Panel de control</h1>
                        <span class="encabezado__fecha"><c:out value="${fechaHoy}" /></span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty errorBD}">
                            <span class="chip" style="color:#A9660A;border-color:#F6DFB4;background:#FEF6E7;">
                                <span class="chip__punto" style="background:#F59E0B;box-shadow:0 0 0 3px rgba(245,158,11,.2);"></span>
                                Sin conexión a la base de datos
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="chip">
                                <span class="chip__punto"></span>
                                Inventario sincronizado
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <!-- ============ Módulo del sistema ============ -->
            <section class="modulos" aria-label="Módulos">

                <a class="modulo modulo--cobro" href="<c:url value='/facturacion' />">
                    <div class="modulo__superior">
                        <span class="modulo__icono" aria-hidden="true">
                            <svg width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M6 2h12v20l-3-2-3 2-3-2-3 2V2z"/>
                                <path d="M9.5 7.5h5"/>
                                <path d="M9.5 11.5h5"/>
                                <path d="M9.5 15.5h3"/>
                            </svg>
                        </span>
                        <div>
                            <p class="modulo__etiqueta">Módulo 1 · Caja</p>
                            <h2 class="modulo__titulo">Facturación</h2>
                        </div>
                    </div>
                    <p class="modulo__desc">
                        Cobra los productos del inventario, registra la venta y emite la factura
                        del cliente en el mismo sistema.
                    </p>
                    <ul class="modulo__lista">
                        <li>Venta rápida</li>
                        <li>Cliente y factura</li>
                        <li>Descuenta stock solo</li>
                    </ul>
                    <span class="modulo__accion">
                        Abrir caja
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12h14M13 6l6 6-6 6"/>
                        </svg>
                    </span>
                </a>

                <a class="modulo" href="<c:url value='/productos' />">
                    <div class="modulo__superior">
                        <span class="modulo__icono" aria-hidden="true">
                            <svg width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 8l-9-5-9 5v8l9 5 9-5V8z"/>
                                <path d="M3 8l9 5 9-5"/>
                                <path d="M12 13v8"/>
                            </svg>
                        </span>
                        <div>
                            <p class="modulo__etiqueta">Módulo 2 · Inventario</p>
                            <h2 class="modulo__titulo">Productos</h2>
                        </div>
                    </div>
                    <p class="modulo__desc">
                        Administra el catálogo: precios, stock mínimo y ubicación
                        de cada producto en almacén.
                    </p>
                    <ul class="modulo__lista">
                        <li>Alta y edición</li>
                        <li>Stock mínimo</li>
                        <li>Borrado lógico</li>
                    </ul>
                    <span class="modulo__accion">
                        Ver productos
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12h14M13 6l6 6-6 6"/>
                        </svg>
                    </span>
                </a>

                <a class="modulo" href="<c:url value='/entradas' />">
                    <div class="modulo__superior">
                        <span class="modulo__icono" aria-hidden="true">
                            <svg width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 3v9"/>
                                <path d="M8.5 8.5L12 12l3.5-3.5"/>
                                <path d="M4 15v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4"/>
                            </svg>
                        </span>
                        <div>
                            <p class="modulo__etiqueta">Módulo 3 · Compras</p>
                            <h2 class="modulo__titulo">Entradas</h2>
                        </div>
                    </div>
                    <p class="modulo__desc">
                        Registra la mercancía que ingresa al almacén:
                        suma el stock del producto al instante.
                    </p>
                    <ul class="modulo__lista">
                        <li>Proveedor</li>
                        <li>Precio de compra</li>
                        <li>Transacción segura</li>
                    </ul>
                    <span class="modulo__accion">
                        Ver entradas
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12h14M13 6l6 6-6 6"/>
                        </svg>
                    </span>
                </a>

                <a class="modulo" href="<c:url value='/salidas' />">
                    <div class="modulo__superior">
                        <span class="modulo__icono" aria-hidden="true">
                            <svg width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 12V3"/>
                                <path d="M8.5 6.5L12 3l3.5 3.5"/>
                                <path d="M4 15v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4"/>
                            </svg>
                        </span>
                        <div>
                            <p class="modulo__etiqueta">Módulo 4 · Merma y ajustes</p>
                            <h2 class="modulo__titulo">Salidas manuales</h2>
                        </div>
                    </div>
                    <p class="modulo__desc">
                        Merma, daños o ajustes de inventario sin factura asociada:
                        descuenta stock con control.
                    </p>
                    <ul class="modulo__lista">
                        <li>Descuenta stock</li>
                        <li>Sin factura</li>
                        <li>Historial</li>
                    </ul>
                    <span class="modulo__accion">
                        Ver salidas
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12h14M13 6l6 6-6 6"/>
                        </svg>
                    </span>
                </a>

                <a class="modulo" href="<c:url value='/alertas' />">
                    <div class="modulo__superior">
                        <span class="modulo__icono" aria-hidden="true">
                            <svg width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 3L2.5 20h19L12 3z"/>
                                <path d="M12 9v5"/>
                                <path d="M12 17.5h.01"/>
                            </svg>
                        </span>
                        <div>
                            <p class="modulo__etiqueta">Módulo 5 · Monitoreo</p>
                            <h2 class="modulo__titulo">Alertas</h2>
                        </div>
                    </div>
                    <p class="modulo__desc">
                        Productos que llegaron al stock mínimo: repón a tiempo
                        y evita quedarte sin mercancía.
                    </p>
                    <ul class="modulo__lista">
                        <li>Stock bajo</li>
                        <li>Ubicación</li>
                        <li>Lista para reponer</li>
                    </ul>
                    <span class="modulo__accion">
                        Ver alertas
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12h14M13 6l6 6-6 6"/>
                        </svg>
                    </span>
                </a>

            </section>

            <!-- ============ Indicadores ============ -->
            <h2 class="seccion-titulo">Resumen del inventario y ventas</h2>

            <section class="kpis" aria-label="Indicadores">
                <c:choose>
                    <c:when test="${not empty resumen}">

                        <article class="kpi">
                            <p class="kpi__etiqueta">Productos</p>
                            <p class="kpi__valor"><fmt:formatNumber value="${resumen.totalProductos}" /></p>
                            <p class="kpi__nota">
                                <fmt:formatNumber value="${resumen.totalCategorias}" /> categorías activas
                            </p>
                        </article>

                        <article class="kpi">
                            <p class="kpi__etiqueta">Unidades en stock</p>
                            <p class="kpi__valor"><fmt:formatNumber value="${resumen.unidadesEnStock}" /></p>
                            <p class="kpi__nota">piezas totales en almacén</p>
                        </article>

                        <a class="kpi kpi--alerta" href="<c:url value='/alertas' />" style="display:block;text-decoration:none;">
                            <p class="kpi__etiqueta">Stock bajo</p>
                            <p class="kpi__valor"><fmt:formatNumber value="${alertas}" /></p>
                            <p class="kpi__nota">productos en o por debajo del mínimo · toca para ver las alertas</p>
                        </a>

                        <article class="kpi kpi--venta">
                            <p class="kpi__etiqueta">Ventas de hoy</p>
                            <p class="kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasHoy}" type="currency"
                                                  currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="kpi__nota">acumulado del día</p>
                        </article>

                        <article class="kpi kpi--venta">
                            <p class="kpi__etiqueta">Ventas de la semana</p>
                            <p class="kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasSemana}" type="currency"
                                                  currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="kpi__nota">desde el lunes de esta semana</p>
                        </article>

                        <article class="kpi kpi--venta">
                            <p class="kpi__etiqueta">Ventas del mes</p>
                            <p class="kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasMes}" type="currency"
                                                  currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="kpi__nota">mes en curso</p>
                        </article>

                    </c:when>
                    <c:otherwise>
                        <article class="kpi kpi--alerta" style="grid-column: 1 / -1;">
                            <p class="kpi__etiqueta">Sin datos</p>
                            <p class="kpi__valor" style="font-size:1.1rem;">No se pudieron cargar los indicadores</p>
                            <p class="kpi__nota" style="word-break:break-word;">
                                <c:out value="${errorBD}" />
                            </p>
                            <p class="kpi__nota">
                                Revisa que SQL Server esté corriendo y que exista la base
                                <strong>dbIaInventario</strong>.
                            </p>
                        </article>
                    </c:otherwise>
                </c:choose>
            </section>

        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%-- Widget flotante del asistente IA (burbuja + ventana de chat) --%>
        <%@ include file="componentes/widget-ia.jspf" %>

    </body>
</html>
