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
        <title>Saca Clavos · Salidas</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <style>
            .caja-card { background: var(--tarjeta); border: 1px solid var(--borde); border-radius: var(--radio); padding: 22px; box-shadow: var(--sombra-sm); margin-bottom: 24px; }
            .caja-card h2 { margin: 0 0 4px; font-size: 1.04rem; font-weight: 700; color: var(--azul-900); }
            .caja-card__sub { margin: 0 0 16px; font-size: .84rem; color: var(--texto-suave); }
            .caja-fila { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px; }
            .caja-campo { margin-bottom: 14px; }
            .caja-fila .caja-campo { margin-bottom: 0; }
            .caja-campo__label { display: block; margin-bottom: 6px; font-size: .7rem; font-weight: 700; letter-spacing: .8px; text-transform: uppercase; color: var(--texto-suave); }
            .caja-campo input, .caja-campo select { width: 100%; padding: 12px 14px; border: 1px solid var(--borde); border-radius: 12px; background: var(--fondo); color: var(--texto); font-size: .93rem; font-family: inherit; }
            .caja-campo input:focus, .caja-campo select:focus { outline: none; background: #FFFFFF; border-color: var(--azul-600); box-shadow: 0 0 0 4px rgba(21, 101, 192, .14); }
            .caja-btn { width: 100%; padding: 14px; border: none; border-radius: 13px; font-size: .97rem; font-weight: 700; font-family: inherit; color: #FFFFFF; background: linear-gradient(135deg, var(--azul-700), var(--azul-800)); box-shadow: 0 10px 22px rgba(11, 60, 125, .30); cursor: pointer; transition: filter .16s ease; }
            .caja-btn:hover { filter: brightness(1.1); }
            .caja-tabla { overflow-x: auto; }
            .caja-tabla table { width: 100%; border-collapse: collapse; font-size: .9rem; }
            .caja-tabla th { padding: 0 8px 9px; font-size: .7rem; font-weight: 700; letter-spacing: .9px; text-transform: uppercase; color: var(--texto-suave); text-align: left; border-bottom: 1px solid var(--borde); }
            .caja-tabla td { padding: 11px 8px; border-bottom: 1px solid #EDF3FA; vertical-align: middle; }
            .caja-tabla tbody tr:last-child td { border-bottom: none; }
            .caja-tabla tbody tr { transition: background .15s ease; }
            .caja-tabla tbody tr:hover { background: #F7FBFF; }
            .caja-vacio { margin-top: 14px; padding: 26px 14px; text-align: center; font-size: .87rem; color: var(--texto-suave); background: #F8FBFF; border: 1.5px dashed var(--borde); border-radius: 13px; }
            .caja-msg { position: relative; margin-bottom: 18px; padding: 13px 16px 13px 46px; border-radius: 12px; font-size: .9rem; font-weight: 600; }
            .caja-msg::before { content: ""; position: absolute; left: 15px; top: 50%; transform: translateY(-50%); width: 20px; height: 20px; background-repeat: no-repeat; background-position: center; background-size: contain; }
            .caja-msg--ok { color: #15803D; background: #ECFDF3; border: 1px solid #BBE7CD; }
            .caja-msg--ok::before { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2316A34A' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M8.4 12.3l2.5 2.5 4.7-5.2'/%3E%3C/svg%3E"); }
            .caja-msg--err { color: #B91C1C; background: #FEF2F2; border: 1px solid #F6CBCB; }
            .caja-msg--err::before { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23DC2626' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M9 9l6 6M15 9l-6 6'/%3E%3C/svg%3E"); }
            .origen-manual { color: #B45309; font-weight: 700; font-size: .78rem; }
            .origen-factura { color: var(--azul-700); font-weight: 700; font-size: .78rem; }
        </style>
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "salidas"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Salidas manuales</h1>
                        <span class="encabezado__fecha">Módulo 4 · Merma y ajustes</span>
                    </div>
                    <span class="chip"><span class="chip__punto"></span>Descuentos</span>
                </div>
            </section>

            <c:if test="${not empty exito}">
                <div class="caja-msg caja-msg--ok"><c:out value="${exito}" /></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <section class="caja-card">
                <h2>Registrar salida</h2>
                <p class="caja-card__sub">Merma, daño o ajuste manual: descuenta stock sin factura asociada</p>

                <form method="post" action="<c:url value='/salidas' />">
                    <input type="hidden" name="accion" value="registrar">

                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="idProducto">Producto</label>
                            <select id="idProducto" name="idProducto" required>
                                <c:forEach items="${productos}" var="p">
                                    <option value="${p.id}"><c:out value="${p.nombre}" /></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="cantidad">Cantidad</label>
                            <input id="cantidad" type="number" name="cantidad" min="1" required placeholder="Ej: 3">
                        </div>
                    </div>

                    <div class="caja-campo">
                        <label class="caja-campo__label" for="cliente">Responsable / cliente</label>
                        <input id="cliente" type="text" name="cliente" maxlength="50" required placeholder="Ej: Bodega - ajuste de conteo">
                    </div>

                    <div class="caja-campo">
                        <label class="caja-campo__label" for="observaciones">Motivo (opcional)</label>
                        <input id="observaciones" type="text" name="observaciones" maxlength="100" placeholder="Ej: Unidades dañadas en el estante">
                    </div>

                    <button class="caja-btn" type="submit">Registrar salida</button>
                </form>
            </section>

            <section class="caja-card">
                <h2>Historial de salidas</h2>
                <p class="caja-card__sub">Ventas facturadas y salidas manuales del inventario</p>

                <c:choose>
                    <c:when test="${not empty salidas}">
                        <div class="caja-tabla">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Fecha</th>
                                        <th>Producto</th>
                                        <th>Cant.</th>
                                        <th>Precio unit.</th>
                                        <th>Cliente</th>
                                        <th>Motivo</th>
                                        <th>Origen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${salidas}" var="s">
                                        <tr>
                                            <td><fmt:formatDate value="${s.fecha}" pattern="dd/MM/yyyy HH:mm" /></td>
                                            <td><c:out value="${s.nombreProducto}" /></td>
                                            <td>${s.cantidad}</td>
                                            <td><fmt:formatNumber value="${s.precioUnitario}" type="currency" currencyCode="COP" maxFractionDigits="0" /></td>
                                            <td><c:out value="${s.cliente}" /></td>
                                            <td><c:out value="${empty s.observaciones ? '—' : s.observaciones}" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.idFactura > 0}">
                                                        <span class="origen-factura">Factura #${s.idFactura}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="origen-manual">Manual</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="caja-vacio">Aún no hay salidas registradas</p>
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
