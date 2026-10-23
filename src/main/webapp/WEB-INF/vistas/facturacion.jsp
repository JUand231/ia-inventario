<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="theme-color" content="#0A2E58">
        <title>Saca Clavos · Facturación</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "facturacion"); %>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Facturación</h1>
                        <span class="encabezado__fecha">Módulo 1 · Caja</span>
                    </div>
                    <span class="chip" style="color:#A9660A;border-color:#F6DFB4;background:#FEF6E7;">
                        <span class="chip__punto" style="background:#F59E0B;box-shadow:0 0 0 3px rgba(245,158,11,.2);"></span>
                        En construcción
                    </span>
                </div>
            </section>

            <section class="kpis">
                <article class="kpi" style="grid-column: 1 / -1;">
                    <p class="kpi__etiqueta">Próximamente</p>
                    <p class="kpi__valor" style="font-size:1.15rem;">Aquí se cobrarán los productos</p>
                    <p class="kpi__nota">
                        Buscar producto, cantidad, cliente, total a pagar, descuento de stock y
                        generación de la factura. Esta vista reutiliza <strong>inventario.css</strong>
                        y <strong>topbar.jspf</strong>, así que nunca se duplica el diseño.
                    </p>
                    <p style="margin-top:18px;">
                        <a class="modulo__accion" style="display:inline-flex;" href="<c:url value='/inicio' />">
                            Volver al panel
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M5 12h14M13 6l6 6-6 6"/>
                            </svg>
                        </a>
                    </p>
                </article>
            </section>

        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

    </body>
</html>
