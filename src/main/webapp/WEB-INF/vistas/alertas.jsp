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
        <link rel="stylesheet" href="<c:url value='/assets/css/modulos.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "alertas"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Alertas de stock</h1>
                        <span class="encabezado__fecha">Módulo 5 · Monitoreo</span>
                    </div>
                    <span class="chip"><span class="chip__punto"></span>Reponer pronto</span>
                </div>
            </section>

            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <section class="caja-card caja-card--alerta">
                <div class="caja-card__cabecera">
                    <span class="caja-card__icono" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>
                            <path d="M12 9v4"/>
                            <path d="M12 17h.01"/>
                        </svg>
                    </span>
                    <div>
                        <h2>Productos por debajo del mínimo</h2>
                        <p class="caja-card__sub">Registra una entrada para reponer estos productos</p>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not empty alertas}">
                        <div class="caja-tabla">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Producto</th>
                                        <th>Stock actual</th>
                                        <th>Stock mínimo</th>
                                        <th>Ubicación</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${alertas}" var="a">
                                        <tr>
                                            <td><c:out value="${a.nombre}" /></td>
                                            <td class="stock-critico">${a.stock}</td>
                                            <td>${a.stockMinimo}</td>
                                            <td><c:out value="${empty a.ubicacion ? '—' : a.ubicacion}" /></td>
                                            <td><span class="alerta-etiqueta">Stock bajo</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="sin-alertas">Todo en orden: ningún producto está por debajo del mínimo</p>
                    </c:otherwise>
                </c:choose>
            </section>

        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%@ include file="componentes/widget-ia.jspf" %>

    </body>
</html>
