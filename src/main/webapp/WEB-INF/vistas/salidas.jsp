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
        <link rel="stylesheet" href="<c:url value='/assets/css/dashboard.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/modulos.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    </head>
    <body class="dx-body">

        <% pageContext.setAttribute("paginaActiva", "salidas"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="dx-contenedor">

            <!-- ===== Encabezado ===== -->
            <header class="dx-head">
                <div>
                    <p class="dx-head__fecha">Módulo 4 · Merma y ajustes</p>
                    <h1 class="dx-head__titulo">Salidas manuales</h1>
                    <p class="dx-head__sub">Merma, daño o ajuste sin factura: el stock baja al instante.</p>
                </div>
                <span class="dx-chip dx-chip--warn"><span class="dx-chip__punto"></span>Descuentos</span>
            </header>

            <c:if test="${not empty exito}">
                <div class="caja-msg caja-msg--ok"><c:out value="${exito}" /></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <!-- ===== Formulario en 3 pasos ===== -->
            <section class="dx-panel">
                <header class="dx-panel__head">
                    <div>
                        <h2 class="dx-panel__titulo">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                <path d="M12 12V3"/>
                                <path d="M8.5 6.5L12 3l3.5 3.5"/>
                                <path d="M4 15v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4"/>
                            </svg>
                            ¿Qué mercancía salió?
                        </h2>
                        <p class="dx-panel__sub">Merma, daño o ajuste sin factura: el stock baja al instante</p>
                    </div>
                </header>

                <form method="post" action="<c:url value='/salidas' />">
                    <input type="hidden" name="accion" value="registrar">

                    <p class="paso"><span class="paso__num">1</span> ¿Qué producto sale?</p>
                    <div class="caja-campo">
                        <select id="idProducto" name="idProducto" required>
                            <c:forEach items="${productos}" var="p">
                                <option value="${p.id}" data-stock="${p.stock}" data-minimo="${p.stockMinimo}">
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
                        <span id="avisoMinimo" hidden>· ⚠️ por debajo del mínimo</span>
                    </div>

                    <p class="paso"><span class="paso__num">2</span> ¿Cuántas unidades salen?</p>
                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="cantidad">Cantidad</label>
                            <input id="cantidad" type="number" name="cantidad" min="1" required placeholder="Ej: 3">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="cliente">Responsable / cliente</label>
                            <input id="cliente" type="text" name="cliente" maxlength="50" required placeholder="Ej: Bodega - ajuste de conteo">
                        </div>
                    </div>

                    <p class="paso"><span class="paso__num">3</span> ¿Por qué sale?</p>
                    <div class="caja-campo">
                        <label class="caja-campo__label" for="observaciones">Motivo (opcional)</label>
                        <input id="observaciones" type="text" name="observaciones" maxlength="100" placeholder="Ej: Unidades dañadas en el estante">
                    </div>

                    <button class="caja-btn" type="submit">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M8.4 12.3l2.5 2.5 4.7-5.2"/>
                        </svg>
                        Registrar salida
                    </button>
                </form>
            </section>

            <!-- ===== Historial ===== -->
            <section class="dx-panel">
                <header class="dx-panel__head">
                    <div>
                        <h2 class="dx-panel__titulo">Historial de salidas</h2>
                        <p class="dx-panel__sub">Ventas facturadas y salidas manuales del inventario</p>
                    </div>
                </header>

                <c:choose>
                    <c:when test="${not empty salidas}">
                        <div class="dx-tabla-wrap">
                            <table class="dx-tabla">
                                <thead>
                                    <tr>
                                        <th>Fecha</th>
                                        <th>Producto</th>
                                        <th class="dx-c">Cant.</th>
                                        <th class="dx-r">Precio unit.</th>
                                        <th>Cliente</th>
                                        <th>Motivo</th>
                                        <th>Origen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${salidas}" var="s">
                                        <tr>
                                            <td><c:out value="${s.fechaTexto}" /></td>
                                            <td><span class="dx-cli"><c:out value="${s.nombreProducto}" /></span></td>
                                            <td class="dx-c"><span class="dx-pill"><c:out value="${s.cantidad}" /></span></td>
                                            <td class="dx-r dx-total"><fmt:formatNumber value="${s.precioUnitario}" type="currency" currencyCode="COP" maxFractionDigits="0" /></td>
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
                        <p class="dx-vacio" style="padding:20px !important;">Aún no hay salidas registradas.</p>
                    </c:otherwise>
                </c:choose>
            </section>

        </main>

        <footer class="dx-pie">
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
                var aviso = document.getElementById('avisoMinimo');

                function actualizar() {
                    var opt = sel.options[sel.selectedIndex];
                    var stock = parseInt(opt.getAttribute('data-stock'), 10) || 0;
                    var minimo = parseInt(opt.getAttribute('data-minimo'), 10) || 0;
                    var n = parseInt(cant.value, 10) || 0;
                    var futuro = stock - n;

                    actual.textContent = stock;
                    quedara.textContent = futuro;

                    if (futuro <= minimo) {
                        caja.classList.add('stock-preview--bajo');
                        aviso.hidden = false;
                    } else {
                        caja.classList.remove('stock-preview--bajo');
                        aviso.hidden = true;
                    }
                }

                sel.addEventListener('change', actualizar);
                cant.addEventListener('input', actualizar);
                actualizar();
            })();
        </script>

    </body>
</html>
