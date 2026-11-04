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
        <link rel="stylesheet" href="<c:url value='/assets/css/dashboard.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <%-- Fuentes: Playfair para la marca, Poppins para todo lo demás --%>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    </head>
    <body class="dx-body">

        <% pageContext.setAttribute("paginaActiva", "inicio"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="dx-contenedor">

            <!-- ===== Encabezado ===== -->
            <header class="dx-head">
                <div>
                    <p class="dx-head__fecha"><c:out value="${fechaHoy}" /></p>
                    <h1 class="dx-head__titulo">Panel de control</h1>
                    <p class="dx-head__sub">Resumen en tiempo real de operaciones, facturación y niveles de stock.</p>
                </div>
                <c:choose>
                    <c:when test="${not empty errorBD}">
                        <span class="dx-chip dx-chip--warn"><span class="dx-chip__punto"></span>Sin conexión a la base de datos</span>
                    </c:when>
                    <c:otherwise>
                        <span class="dx-chip"><span class="dx-chip__punto"></span>Inventario sincronizado</span>
                    </c:otherwise>
                </c:choose>
            </header>

            <!-- ===== Banner Facturación ===== -->
            <section class="dx-hero">
                <div class="dx-hero__texto">
                    <h2 class="dx-hero__titulo">Facturación &amp; Terminal de Venta</h2>
                    <p class="dx-hero__desc">
                        Cobra los productos del inventario, registra la venta con múltiples métodos de pago
                        y emite la factura del cliente al instante en el mismo sistema.
                    </p>
                </div>
                <a class="dx-hero__btn" href="<c:url value='/facturacion' />">
                    Abrir caja y Vender
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
                </a>
            </section>

            <!-- ===== Indicadores ===== -->
            <div class="dx-seccion">
                <h2 class="dx-seccion__titulo">Resumen del inventario y ventas</h2>
            </div>

            <section class="dx-kpis" aria-label="Indicadores">
                <c:choose>
                    <c:when test="${not empty resumen}">

                        <article class="dx-kpi">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Productos</p>
                                <span class="dx-kpi__icono dx-kpi__icono--azul">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 8l-9-5-9 5 9 5 9-5z"/><path d="M3 8v8l9 5 9-5V8"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor"><fmt:formatNumber value="${resumen.totalProductos}" /></p>
                            <p class="dx-kpi__nota"><fmt:formatNumber value="${resumen.totalCategorias}" /> categorías activas</p>
                            <div class="dx-barra"><span style="width:100%"></span></div>
                        </article>

                        <article class="dx-kpi">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Unidades en stock</p>
                                <span class="dx-kpi__icono dx-kpi__icono--cian">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor"><fmt:formatNumber value="${resumen.unidadesEnStock}" /></p>
                            <p class="dx-kpi__nota">piezas totales en almacén</p>
                        </article>

                        <a class="dx-kpi dx-kpi--alerta" href="<c:url value='/alertas' />" style="display:block;text-decoration:none;">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Stock bajo</p>
                                <span class="dx-kpi__icono dx-kpi__icono--ambar">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor"><fmt:formatNumber value="${alertas.size()}" /></p>
                            <p class="dx-kpi__nota">productos por debajo del mínimo · toca para verlos</p>
                        </a>

                        <article class="dx-kpi">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Ventas de hoy</p>
                                <span class="dx-kpi__icono dx-kpi__icono--verde">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 17l6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasHoy}" type="currency" currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="dx-kpi__nota">acumulado del día</p>
                        </article>

                        <article class="dx-kpi">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Ventas de la semana</p>
                                <span class="dx-kpi__icono dx-kpi__icono--indigo">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 21V10M12 21V4M19 21v-7"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasSemana}" type="currency" currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="dx-kpi__nota">desde el lunes de esta semana</p>
                        </article>

                        <article class="dx-kpi">
                            <div class="dx-kpi__fila">
                                <p class="dx-kpi__etiqueta">Ventas del mes</p>
                                <span class="dx-kpi__icono dx-kpi__icono--violeta">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>
                                </span>
                            </div>
                            <p class="dx-kpi__valor">
                                <fmt:formatNumber value="${resumen.ventasMes}" type="currency" currencyCode="COP" maxFractionDigits="0" />
                            </p>
                            <p class="dx-kpi__nota">mes en curso</p>
                            <div class="dx-barra"><span style="width:70%"></span></div>
                        </article>

                    </c:when>
                    <c:otherwise>
                        <article class="dx-kpi dx-kpi--alerta dx-kpi--ancho">
                            <p class="dx-kpi__etiqueta">Sin datos</p>
                            <p class="dx-kpi__valor dx-kpi__valor--chico">No se pudieron cargar los indicadores</p>
                            <p class="dx-kpi__nota" style="word-break:break-word;"><c:out value="${errorBD}" /></p>
                            <p class="dx-kpi__nota">Revisa que SQL Server esté corriendo y que exista la base <strong>dbIaInventario</strong>.</p>
                        </article>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- ===== Últimas ventas + Alertas ===== -->
            <section class="dx-grid">

                <!-- Tabla de últimas ventas -->
                <article class="dx-panel">
                    <header class="dx-panel__head">
                        <div>
                            <h2 class="dx-panel__titulo">Últimas Transacciones y Ventas</h2>
                            <p class="dx-panel__sub">Facturas registradas, de más reciente a más antigua</p>
                        </div>
                        <a class="dx-btn-sec" href="<c:url value='/facturacion' />">Ir a la caja</a>
                    </header>

                    <div class="dx-tabla-wrap">
                        <table class="dx-tabla">
                            <thead>
                                <tr>
                                    <th>N° Factura / Hora</th>
                                    <th>Cliente</th>
                                    <th class="dx-c">Ítems</th>
                                    <th>Método pago</th>
                                    <th class="dx-r">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty ultimasVentas}">
                                        <c:forEach var="v" items="${ultimasVentas}">
                                            <tr>
                                                <td>
                                                    <span class="dx-tk">Factura #<c:out value="${v.id}" /></span>
                                                    <span class="dx-tk-sub"><c:out value="${v.fechaTexto}" /></span>
                                                </td>
                                                <td>
                                                    <span class="dx-cli"><c:out value="${empty v.cliente ? 'Cliente general' : v.cliente}" /></span>
                                                </td>
                                                <td class="dx-c"><span class="dx-pill"><c:out value="${v.items}" /> items</span></td>
                                                <td><c:out value="${v.metodoPago}" /></td>
                                                <td class="dx-r dx-total">
                                                    <fmt:formatNumber value="${v.total}" type="currency" currencyCode="COP" maxFractionDigits="0" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="5" class="dx-vacio">Aún no hay facturas registradas.</td></tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </article>

                <!-- Alertas de stock crítico -->
                <aside class="dx-panel dx-panel--alertas" aria-label="Alertas de stock">
                    <header class="dx-panel__head">
                        <h2 class="dx-panel__titulo">
                            <span class="dx-dot-alerta"></span>
                            Alertas de Stock Crítico (<c:out value="${empty alertas ? 0 : alertas.size()}" />)
                        </h2>
                        <span class="dx-badge">Acción requerida</span>
                    </header>

                    <ul class="dx-alertas">
                        <c:choose>
                            <c:when test="${not empty errorBD}">
                                <li class="dx-vacio">No se pudieron cargar las alertas: <c:out value="${errorBD}" /></li>
                                </c:when>
                                <c:when test="${not empty alertas}">
                                    <c:forEach var="a" items="${alertas}" end="4">
                                        <li class="dx-alerta">
                                            <div>
                                                <p class="dx-alerta__nombre"><c:out value="${a.nombre}" /></p>
                                                <p class="dx-alerta__meta"><c:out value="${empty a.ubicacion ? 'Sin ubicación' : a.ubicacion}" /> · Mínimo: <c:out value="${a.stockMinimo}" /></p>
                                            </div>
                                            <span class="dx-stock"><c:out value="${a.stock}" /> disp.</span>
                                        </li>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <li class="dx-vacio">Todo el inventario está sobre el mínimo.</li>
                                </c:otherwise>
                            </c:choose>
                    </ul>

                    <c:if test="${not empty alertas}">
                        <a class="dx-btn-sec" style="display:block;text-align:center;margin-top:14px;" href="<c:url value='/alertas' />">Ver todas las alertas</a>
                    </c:if>
                </aside>

            </section>
        </main>

        <footer class="dx-pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%-- Widget flotante del asistente IA (burbuja + ventana de chat) --%>
        <%@ include file="componentes/widget-ia.jspf" %>

    </body>
</html>
