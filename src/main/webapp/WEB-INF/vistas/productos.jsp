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
        <title>Saca Clavos · Productos</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/dashboard.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/modulos.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    </head>
    <body class="dx-body">

        <% pageContext.setAttribute("paginaActiva", "productos"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="dx-contenedor">

            <!-- ===== Encabezado ===== -->
            <header class="dx-head">
                <div>
                    <p class="dx-head__fecha">Módulo 2 · Inventario</p>
                    <h1 class="dx-head__titulo">Productos</h1>
                    <p class="dx-head__sub">Administra el catálogo: precios, stock mínimo y ubicación de cada producto.</p>
                </div>
                <span class="dx-chip"><span class="dx-chip__punto"></span>Inventario activo</span>
            </header>

            <c:if test="${not empty exito}">
                <div class="caja-msg caja-msg--ok"><c:out value="${exito}" /></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <!-- ===== Formulario (nuevo / edición) ===== -->
            <section class="dx-panel${not empty editando ? ' dx-panel--editando' : ''}">
                <header class="dx-panel__head">
                    <div>
                        <h2 class="dx-panel__titulo">
                            <c:choose>
                                <c:when test="${not empty editando}">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <path d="M12 20h9"/>
                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5z"/>
                                    </svg>
                                    Editando producto
                                </c:when>
                                <c:otherwise>
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <path d="M12 5v14M5 12h14"/>
                                    </svg>
                                    Nuevo producto
                                </c:otherwise>
                            </c:choose>
                        </h2>
                        <p class="dx-panel__sub">
                            <c:choose>
                                <c:when test="${not empty editando}">Modifica los datos de <strong><c:out value="${editando.nombre}" /></strong> y guarda los cambios</c:when>
                                <c:otherwise>Completa los datos y guarda para agregarlo al inventario</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </header>

                <form method="post" action="<c:url value='/productos' />">
                    <input type="hidden" name="accion" value="${empty editando ? 'insertar' : 'actualizar'}">
                    <input type="hidden" name="id" value="${empty editando ? '' : editando.id}">

                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="nombre">Nombre</label>
                            <input id="nombre" type="text" name="nombre" maxlength="100" required
                                   value="${empty editando ? '' : editando.nombre}">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="idCategoria">Categoría</label>
                            <select id="idCategoria" name="idCategoria" required>
                                <c:forEach items="${categorias}" var="c">
                                    <option value="${c.id}" ${editando.idCategoria == c.id ? 'selected' : ''}>
                                        <c:out value="${c.nombre}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="caja-campo">
                        <label class="caja-campo__label" for="descripcion">Descripción</label>
                        <input id="descripcion" type="text" name="descripcion" maxlength="100"
                               value="${empty editando ? '' : editando.descripcion}">
                    </div>

                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="precioCompra">Precio de compra</label>
                            <input id="precioCompra" type="number" name="precioCompra" min="0" step="0.01" required
                                   value="${empty editando ? '' : editando.precioCompra}">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="precioVenta">Precio de venta</label>
                            <input id="precioVenta" type="number" name="precioVenta" min="0" step="0.01" required
                                   value="${empty editando ? '' : editando.precioVenta}">
                        </div>
                    </div>

                    <div class="caja-fila">
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="stock">Stock actual</label>
                            <input id="stock" type="number" name="stock" min="0" required
                                   value="${empty editando ? 0 : editando.stock}">
                        </div>
                        <div class="caja-campo">
                            <label class="caja-campo__label" for="stockMinimo">Stock mínimo</label>
                            <input id="stockMinimo" type="number" name="stockMinimo" min="0" required
                                   value="${empty editando ? 0 : editando.stockMinimo}">
                        </div>
                    </div>

                    <div class="caja-campo">
                        <label class="caja-campo__label" for="ubicacion">Ubicación (opcional)</label>
                        <input id="ubicacion" type="text" name="ubicacion" maxlength="80"
                               value="${empty editando ? '' : editando.ubicacion}">
                    </div>

                    <button class="caja-btn" type="submit">${empty editando ? 'Guardar producto' : 'Guardar cambios'}</button>

                    <c:if test="${not empty editando}">
                        <a class="editar-link" href="<c:url value='/productos' />">Cancelar edición</a>
                    </c:if>
                </form>
            </section>

            <!-- ===== Listado ===== -->
            <section class="dx-panel">
                <header class="dx-panel__head">
                    <div>
                        <h2 class="dx-panel__titulo">Productos registrados</h2>
                        <p class="dx-panel__sub">Edita o elimina los productos del inventario</p>
                    </div>
                </header>

                <c:choose>
                    <c:when test="${not empty productos}">
                        <div class="dx-tabla-wrap">
                            <table class="dx-tabla">
                                <thead>
                                    <tr>
                                        <th>Producto</th>
                                        <th class="dx-r">Precio venta</th>
                                        <th class="dx-c">Stock</th>
                                        <th class="dx-c">Mínimo</th>
                                        <th>Ubicación</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${productos}" var="p">
                                        <tr>
                                            <td><span class="dx-cli"><c:out value="${p.nombre}" /></span></td>
                                            <td class="dx-r dx-total"><fmt:formatNumber value="${p.precioVenta}" type="currency" currencyCode="COP" maxFractionDigits="0" /></td>
                                            <td class="dx-c">
                                                <c:choose>
                                                    <c:when test="${p.stock <= p.stockMinimo}">
                                                        <span class="dx-stock">${p.stock}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${p.stock}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="dx-c">${p.stockMinimo}</td>
                                            <td><c:out value="${empty p.ubicacion ? '—' : p.ubicacion}" /></td>
                                            <td>
                                                <div class="acciones">
                                                    <a class="btn-mini" href="<c:url value='/productos?accion=editar&id=' /><c:out value='${p.id}' />">Editar</a>
                                                    <form method="post" action="<c:url value='/productos' />"
                                                          onsubmit="return confirm('¿Eliminar el producto? Se ocultará del inventario.')">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="id" value="${p.id}">
                                                        <button class="btn-mini btn-mini--rojo" type="submit">Eliminar</button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="dx-vacio" style="padding:20px !important;">No hay productos registrados aún.</p>
                    </c:otherwise>
                </c:choose>
            </section>

        </main>

        <footer class="dx-pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%@ include file="componentes/widget-ia.jspf" %>

    </body>
</html>
