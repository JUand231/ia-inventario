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
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <style>
            .caja-card { background: var(--tarjeta); border: 1px solid var(--borde); border-radius: var(--radio); padding: 22px; box-shadow: var(--sombra-sm); margin-bottom: 24px; }
            .caja-card h2 { margin: 0 0 4px; font-size: 1.04rem; font-weight: 700; color: var(--azul-900); }
            .caja-card__sub { margin: 0 0 16px; font-size: .84rem; color: var(--texto-suave); }
            .caja-tabla { overflow-x: auto; }
            .caja-tabla table { width: 100%; border-collapse: collapse; font-size: .9rem; }
            .caja-tabla th { padding: 0 8px 9px; font-size: .7rem; font-weight: 700; letter-spacing: .9px; text-transform: uppercase; color: var(--texto-suave); text-align: left; border-bottom: 1px solid var(--borde); }
            .caja-tabla td { padding: 11px 8px; border-bottom: 1px solid #EDF3FA; vertical-align: middle; }
            .caja-tabla tbody tr:last-child td { border-bottom: none; }
            .caja-tabla tbody tr { transition: background .15s ease; }
            .caja-tabla tbody tr:hover { background: #FFF7F7; }
            .caja-vacio { margin-top: 14px; padding: 26px 14px; text-align: center; font-size: .87rem; color: var(--texto-suave); background: #F8FBFF; border: 1.5px dashed var(--borde); border-radius: 13px; }
            .caja-msg { position: relative; margin-bottom: 18px; padding: 13px 16px 13px 46px; border-radius: 12px; font-size: .9rem; font-weight: 600; }
            .caja-msg::before { content: ""; position: absolute; left: 15px; top: 50%; transform: translateY(-50%); width: 20px; height: 20px; background-repeat: no-repeat; background-position: center; background-size: contain; }
            .caja-msg--err { color: #B91C1C; background: #FEF2F2; border: 1px solid #F6CBCB; }
            .caja-msg--err::before { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23DC2626' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M9 9l6 6M15 9l-6 6'/%3E%3C/svg%3E"); }
            .stock-critico { color: #B91C1C; font-weight: 700; }
            .alerta-etiqueta { display: inline-block; padding: 4px 10px; border-radius: 999px; font-size: .72rem; font-weight: 700; letter-spacing: .5px; text-transform: uppercase; color: #B91C1C; background: #FEF2F2; border: 1px solid #F6CBCB; }
            .sin-alertas { padding: 30px 14px; text-align: center; font-size: .95rem; color: #15803D; background: #ECFDF3; border: 1px solid #BBE7CD; border-radius: 13px; font-weight: 600; }
        </style>
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

            <section class="caja-card">
                <h2>Productos por debajo del mínimo</h2>
                <p class="caja-card__sub">Registra una entrada para reponer estos productos</p>

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
