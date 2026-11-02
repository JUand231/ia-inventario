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
        <title>Saca Clavos · Entradas</title>
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
        </style>
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "entradas"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Entradas de mercancía</h1>
                        <span class="encabezado__fecha">Módulo 3 · Compras</span>
                    </div>
                    <span class="chip"><span class="chip__punto"></span>Almacén</span>
                </div>
            </section>

            <c:if test="${not empty exito}">
                <div class="caja-msg caja-msg--ok"><c:out value="${exito}" /></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <section class="caja-card">
                <h2>Registrar entrada</h2>
                <p class="caja-card__sub">La mercancía que ingresa suma stock al producto al instante</p>

                <form method="post" action="<c:url value='/entradas' />">
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
                            <input id="cantidad" type="number" name="cantidad" min="1" required placeholder="Ej: 10">
                        </div>
                    </div>

                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="precioUnitario">Precio unitario de compra</label>
                            <input id="precioUnitario" type="number" name="precioUnitario" min="0" step="0.01" required placeholder="Ej: 1500">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="proveedor">Proveedor</label>
                            <input id="proveedor" type="text" name="proveedor" maxlength="100" required placeholder="Ej: Distribuidora El Tornillo">
                        </div>
                    </div>

                    <div class="caja-campo">
                        <label class="caja-campo__label" for="observaciones">Observaciones (opcional)</label>
                        <input id="observaciones" type="text" name="observaciones" maxlength="100" placeholder="Ej: Pedido semanal">
                    </div>

                    <button class="caja-btn" type="submit">Registrar entrada</button>
                </form>
            </section>

            <section class="caja-card">
                <h2>Historial de entradas</h2>
                <p class="caja-card__sub">Últimas compras registradas en el almacén</p>

                <c:choose>
                    <c:when test="${not empty entradas}">
                        <div class="caja-tabla">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Fecha</th>
                                        <th>Producto</th>
                                        <th>Cant.</th>
                                        <th>Precio unit.</th>
                                        <th>Proveedor</th>
                                        <th>Observaciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${entradas}" var="e">
                                        <tr>
                                            <td><fmt:formatDate value="${e.fecha}" pattern="dd/MM/yyyy HH:mm" /></td>
                                            <td><c:out value="${e.nombreProducto}" /></td>
                                            <td>${e.cantidad}</td>
                                            <td><fmt:formatNumber value="${e.precioUnitario}" type="currency" currencyCode="COP" maxFractionDigits="0" /></td>
                                            <td><c:out value="${e.proveedor}" /></td>
                                            <td><c:out value="${empty e.observaciones ? '—' : e.observaciones}" /></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="caja-vacio">Aún no hay entradas registradas</p>
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
