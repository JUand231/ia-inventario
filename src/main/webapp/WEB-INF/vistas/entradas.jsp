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
        <link rel="stylesheet" href="<c:url value='/assets/css/modulos.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
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
                <div class="caja-card__cabecera">
                    <span class="caja-card__icono" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 3v9"/>
                            <path d="M8.5 8.5L12 12l3.5-3.5"/>
                            <path d="M4 15v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4"/>
                        </svg>
                    </span>
                    <div>
                        <h2>¿Qué mercancía llegó?</h2>
                        <p class="caja-card__sub">Elige el producto, indica cuántas unidades llegaron y de quién</p>
                    </div>
                </div>

                <form method="post" action="<c:url value='/entradas' />">
                    <input type="hidden" name="accion" value="registrar">

                    <p class="paso"><span class="paso__num">1</span> ¿Qué producto llegó?</p>
                    <div class="caja-campo">
                        <select id="idProducto" name="idProducto" required>
                            <c:forEach items="${productos}" var="p">
                                <option value="${p.id}" data-stock="${p.stock}">
                                    <c:out value="${p.nombre}" /> (stock actual: ${p.stock})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="stock-preview" id="stockPreview">
                        <span aria-hidden="true">📦</span>
                        Stock actual: <strong id="stockActual">0</strong>
                        <span aria-hidden="true">→</span>
                        quedará en <strong id="stockQuedara">0</strong>
                    </div>

                    <p class="paso"><span class="paso__num">2</span> ¿Cuántas unidades llegaron?</p>
                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="cantidad">Cantidad</label>
                            <input id="cantidad" type="number" name="cantidad" min="1" required placeholder="Ej: 10">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="precioUnitario">Precio unitario de compra</label>
                            <input id="precioUnitario" type="number" name="precioUnitario" min="0" step="0.01" required placeholder="Ej: 1500">
                        </div>
                    </div>

                    <p class="paso"><span class="paso__num">3</span> ¿De quién la compraste?</p>
                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="proveedor">Proveedor</label>
                            <input id="proveedor" type="text" name="proveedor" maxlength="100" required placeholder="Ej: Distribuidora El Tornillo">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="observaciones">Observaciones (opcional)</label>
                            <input id="observaciones" type="text" name="observaciones" maxlength="100" placeholder="Ej: Pedido semanal">
                        </div>
                    </div>

                    <button class="caja-btn" type="submit">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M8.4 12.3l2.5 2.5 4.7-5.2"/>
                        </svg>
                        Registrar entrada de mercancía
                    </button>
                </form>
            </section>

            <section class="caja-card">
                <div class="caja-card__cabecera">
                    <span class="caja-card__icono" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M4 6h16M4 12h16M4 18h10"/>
                        </svg>
                    </span>
                    <div>
                        <h2>Historial de entradas</h2>
                        <p class="caja-card__sub">Últimas compras registradas en el almacén</p>
                    </div>
                </div>

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

        <script>
            (function () {
                var sel = document.getElementById('idProducto');
                var cant = document.getElementById('cantidad');
                var caja = document.getElementById('stockPreview');
                var actual = document.getElementById('stockActual');
                var quedara = document.getElementById('stockQuedara');

                function actualizar() {
                    var opt = sel.options[sel.selectedIndex];
                    var stock = parseInt(opt.getAttribute('data-stock'), 10) || 0;
                    var n = parseInt(cant.value, 10) || 0;
                    actual.textContent = stock;
                    quedara.textContent = stock + n;
                }

                sel.addEventListener('change', actualizar);
                cant.addEventListener('input', actualizar);
                actualizar();
            })();
        </script>

    </body>
</html>
