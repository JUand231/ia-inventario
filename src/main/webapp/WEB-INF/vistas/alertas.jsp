<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
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
        <title>Saca Clavos · Alertas de stock</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/dashboard.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/modulos.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <%@ include file="componentes/avisos-css.jspf" %>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    </head>
    <body class="dx-body">

        <% pageContext.setAttribute("paginaActiva", "alertas"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="dx-contenedor">

            <!-- ===== Encabezado ===== -->
            <header class="dx-head">
                <div>
                    <p class="dx-head__fecha">Módulo 5 · Monitoreo</p>
                    <h1 class="dx-head__titulo">Alertas de stock</h1>
                    <p class="dx-head__sub">Productos por debajo del mínimo: repón a tiempo y evita quedarte sin mercancía.</p>
                </div>
                <span class="dx-chip dx-chip--warn"><span class="dx-chip__punto"></span>Reponer pronto</span>
            </header>

            <%-- El mensaje de error lo muestra SweetAlert2 (ver avisos.js) --%>

            <!-- ===== Panel de alertas ===== -->
            <section class="dx-panel dx-panel--alertas">
                <header class="dx-panel__head">
                    <div>
                        <h2 class="dx-panel__titulo">
                            <span class="dx-dot-alerta"></span>
                            Productos por debajo del mínimo
                        </h2>
                        <p class="dx-panel__sub">Registra una entrada para reponer estos productos</p>
                    </div>
                    <span class="dx-badge">Acción requerida</span>
                </header>

                <c:choose>
                    <c:when test="${not empty alertas}">
                        <div class="dx-tabla-wrap">
                            <table class="dx-tabla">
                                <thead>
                                    <tr>
                                        <th>Producto</th>
                                        <th class="dx-c">Stock actual</th>
                                        <th class="dx-c">Stock mínimo</th>
                                        <th>Ubicación</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${alertas}" var="a">
                                        <tr>
                                            <td><span class="dx-cli"><c:out value="${a.nombre}" /></span></td>
                                            <td class="dx-c"><span class="dx-stock"><c:out value="${a.stock}" /></span></td>
                                            <td class="dx-c"><c:out value="${a.stockMinimo}" /></td>
                                            <td><c:out value="${empty a.ubicacion ? '—' : a.ubicacion}" /></td>
                                            <td><span class="dx-badge">Stock bajo</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="dx-vacio" style="padding:20px !important;">Todo el inventario está sobre el mínimo: ninguna alerta pendiente.</p>
                    </c:otherwise>
                </c:choose>
            </section>

        </main>

        <footer class="dx-pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%@ include file="componentes/widget-ia.jspf" %>

        <%@ include file="componentes/avisos-js.jspf" %>

    </body>
</html>
