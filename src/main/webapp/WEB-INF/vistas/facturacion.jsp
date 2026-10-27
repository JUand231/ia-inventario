<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        <title>Saca Clavos · Facturación</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <link rel="stylesheet" href="<c:url value='/assets/css/widget-ia.css' />">
        <%-- Fuente elegante para la marca "SacaClavos" (con respaldo serif si no hay internet) --%>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
        <style>
            /* ==========================================================
               FACTURACIÓN · estilos de esta vista
               Basados en los tokens de inventario.css (sin duplicarlos)
               ========================================================== */

            /* ---------- Rejilla de las dos tarjetas ---------- */
            .caja {
                display: grid;
                grid-template-columns: .92fr 1.08fr;
                gap: 24px;
                align-items: start;
                padding-bottom: 30px;
            }

            /* ---------- Tarjetas ---------- */
            .caja-card {
                position: relative;
                background: var(--tarjeta);
                border: 1px solid var(--borde);
                border-radius: var(--radio);
                padding: 22px;
                overflow: hidden;
                box-shadow: var(--sombra-sm);
                transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease;
                animation: caja-entra .45s cubic-bezier(.2, .8, .3, 1) both;
            }

            .caja-card:nth-child(2) {
                animation-delay: .09s;
            }

            .caja-card::before {
                content: "";
                position: absolute;
                inset: 0 0 auto 0;
                height: 4px;
                background: linear-gradient(90deg, var(--azul-600), var(--cielo-400));
            }

            .caja-card--factura::before {
                background: linear-gradient(90deg, var(--azul-950), var(--azul-600));
            }

            @media (hover: hover) {
                .caja-card:hover {
                    transform: translateY(-3px);
                    box-shadow: var(--sombra-md);
                    border-color: #BBD6F3;
                }
            }

            .caja-card__cabecera {
                display: flex;
                align-items: center;
                gap: 13px;
                margin-bottom: 16px;
            }

            .caja-card__icono {
                width: 44px;
                height: 44px;
                flex: 0 0 auto;
                border-radius: 13px;
                display: grid;
                place-items: center;
                color: #FFFFFF;
                background: linear-gradient(140deg, var(--cielo-400), var(--azul-600));
                box-shadow: 0 8px 18px rgba(11, 60, 125, .26);
            }

            .caja-card--factura .caja-card__icono {
                background: linear-gradient(140deg, var(--azul-800), var(--azul-600));
            }

            .caja-card h2 {
                margin: 0;
                font-size: 1.04rem;
                font-weight: 700;
                letter-spacing: -.2px;
                color: var(--azul-900);
            }

            .caja-card__sub {
                margin-top: 2px;
                font-size: .78rem;
                color: var(--texto-suave);
            }

            /* ---------- Campos de texto ---------- */
            .caja-buscador {
                position: relative;
            }

            .caja-buscador__lupa {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--texto-suave);
                pointer-events: none;
            }

            .caja-buscador input,
            .caja-campo input,
            .caja-campo select {
                width: 100%;
                padding: 12px 14px;
                border: 1px solid var(--borde);
                border-radius: 12px;
                background: var(--fondo);
                color: var(--texto);
                font-size: .93rem;
                font-family: inherit;
                transition: background .15s ease, border-color .15s ease, box-shadow .15s ease;
            }

            .caja-buscador input {
                padding-left: 42px;
            }

            .caja input::placeholder {
                color: #94A9C6;
            }

            .caja input:focus,
            .caja select:focus {
                outline: none;
                background: #FFFFFF;
                border-color: var(--azul-600);
                box-shadow: 0 0 0 4px rgba(21, 101, 192, .14);
            }

            .caja-campo__label {
                display: block;
                margin-bottom: 6px;
                font-size: .7rem;
                font-weight: 700;
                letter-spacing: .8px;
                text-transform: uppercase;
                color: var(--texto-suave);
            }

            .caja-campo select {
                appearance: none;
                -webkit-appearance: none;
                padding-right: 38px;
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%235C769B' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
                background-repeat: no-repeat;
                background-position: right 13px center;
                background-size: 15px;
                cursor: pointer;
            }

            /* ---------- Resultados de búsqueda ---------- */
            #resultados {
                display: flex;
                flex-direction: column;
                gap: 8px;
                margin-top: 12px;
                max-height: 390px;
                overflow-y: auto;
                padding-right: 2px;
            }

            #resultados::-webkit-scrollbar {
                width: 8px;
            }

            #resultados::-webkit-scrollbar-thumb {
                background: #C9DBF0;
                border-radius: 99px;
            }

            #resultados::-webkit-scrollbar-track {
                background: transparent;
            }

            .caja-item {
                display: flex;
                align-items: center;
                gap: 11px;
                padding: 11px 13px;
                background: var(--tarjeta);
                border: 1px solid var(--borde);
                border-radius: 12px;
                cursor: pointer;
                transition: background .16s ease, border-color .16s ease, transform .16s ease, box-shadow .16s ease;
            }

            .caja-item:hover {
                background: var(--cielo-100);
                border-color: #9CC9F0;
                transform: translateY(-1px);
                box-shadow: var(--sombra-sm);
            }

            .caja-item > div {
                flex: 1;
                min-width: 0;
            }

            .caja-item strong {
                display: block;
                font-size: .9rem;
                font-weight: 600;
                color: var(--texto);
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .caja-item small {
                display: inline-block;
                margin-top: 4px;
                padding: 2px 8px;
                font-size: .72rem;
                color: var(--texto-suave);
                background: var(--fondo);
                border: 1px solid var(--borde);
                border-radius: 999px;
            }

            .caja-item b {
                flex: 0 0 auto;
                font-size: .86rem;
                font-weight: 700;
                color: #FFFFFF;
                background: linear-gradient(135deg, var(--azul-700), var(--azul-800));
                padding: 6px 12px;
                border-radius: 999px;
                white-space: nowrap;
                box-shadow: 0 4px 10px rgba(11, 60, 125, .22);
            }

            .caja-item::after {
                content: "+";
                flex: 0 0 auto;
                width: 26px;
                height: 26px;
                display: grid;
                place-items: center;
                font-size: 1.05rem;
                font-weight: 700;
                line-height: 1;
                color: var(--azul-700);
                background: var(--cielo-100);
                border: 1px solid #CBE4F8;
                border-radius: 50%;
                transition: background .16s ease, color .16s ease, transform .16s ease, border-color .16s ease;
            }

            .caja-item:hover::after {
                background: var(--azul-600);
                border-color: var(--azul-600);
                color: #FFFFFF;
                transform: scale(1.12);
            }

            /* ---------- Tabla de la factura ---------- */
            .caja-tabla {
                overflow-x: auto;
            }

            .caja table {
                width: 100%;
                border-collapse: collapse;
                font-size: .9rem;
            }

            .caja thead th {
                padding: 0 8px 9px;
                font-size: .7rem;
                font-weight: 700;
                letter-spacing: .9px;
                text-transform: uppercase;
                color: var(--texto-suave);
                text-align: left;
                border-bottom: 1px solid var(--borde);
            }

            .caja thead th:nth-child(2),
            .caja thead th:nth-child(3) {
                text-align: center;
            }

            .caja thead th:last-child {
                width: 44px;
                text-align: right;
            }

            .caja tbody td {
                padding: 11px 8px;
                border-bottom: 1px solid #EDF3FA;
                vertical-align: middle;
            }

            .caja tbody tr:last-child td {
                border-bottom: none;
            }

            .caja tbody tr {
                transition: background .15s ease;
            }

            .caja tbody tr:hover {
                background: #F7FBFF;
            }

            .caja tbody td:first-child {
                font-weight: 600;
                color: var(--azul-900);
                max-width: 180px;
            }

            .caja tbody td:nth-child(2) {
                text-align: center;
            }

            .caja tbody td:nth-child(3) {
                text-align: center;
                font-weight: 700;
                color: var(--azul-700);
                font-variant-numeric: tabular-nums;
                white-space: nowrap;
            }

            .caja tbody td:last-child {
                text-align: right;
                white-space: nowrap;
            }

            .caja td input[type="number"] {
                width: 70px;
                padding: 7px 6px;
                text-align: center;
                font-size: .88rem;
                font-weight: 700;
                font-family: inherit;
                color: var(--azul-900);
                background: var(--fondo);
                border: 1px solid var(--borde);
                border-radius: 10px;
                transition: background .15s ease, border-color .15s ease, box-shadow .15s ease;
            }

            .caja td input[type="number"]:focus {
                outline: none;
                background: #FFFFFF;
                border-color: var(--azul-600);
                box-shadow: 0 0 0 4px rgba(21, 101, 192, .14);
            }

            .caja td input[type="number"]::-webkit-inner-spin-button {
                opacity: .45;
            }

            .caja-x {
                width: 30px;
                height: 30px;
                display: inline-grid;
                place-items: center;
                font-size: 1.05rem;
                line-height: 1;
                color: #DC2626;
                background: #FFF5F5;
                border: 1px solid #F5D2D2;
                border-radius: 50%;
                cursor: pointer;
                transition: background .15s ease, color .15s ease, transform .15s ease, border-color .15s ease;
            }

            .caja-x:hover {
                background: #DC2626;
                border-color: #DC2626;
                color: #FFFFFF;
                transform: scale(1.1);
            }

            .caja-x:focus-visible {
                outline: 2px solid var(--azul-600);
                outline-offset: 2px;
            }

            /* ---------- Total ---------- */
            .caja-total {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 14px;
                margin: 18px 0 16px;
                padding: 15px 18px;
                border-radius: 14px;
                background: linear-gradient(135deg, var(--azul-950) 0%, var(--azul-800) 75%, var(--azul-700) 100%);
                box-shadow: 0 12px 26px rgba(6, 37, 70, .28);
            }

            .caja-total span:first-child {
                font-size: .74rem;
                font-weight: 700;
                letter-spacing: 1.3px;
                text-transform: uppercase;
                color: #BFE3F8;
            }

            .caja-total span:last-child {
                font-size: 1.65rem;
                font-weight: 800;
                letter-spacing: -.6px;
                color: #FFFFFF;
                font-variant-numeric: tabular-nums;
            }

            /* ---------- Cliente / método de pago ---------- */
            .caja-fila {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
                margin-bottom: 14px;
            }

            /* ---------- Botón cobrar ---------- */
            .caja-btn {
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 9px;
                padding: 15px;
                border: none;
                border-radius: 13px;
                font-size: 1rem;
                font-weight: 700;
                letter-spacing: .3px;
                font-family: inherit;
                color: #FFFFFF;
                background: linear-gradient(135deg, var(--azul-700), var(--azul-800));
                box-shadow: 0 10px 22px rgba(11, 60, 125, .30);
                cursor: pointer;
                transition: filter .16s ease, transform .16s ease, box-shadow .16s ease;
            }

            .caja-btn::before {
                content: "";
                width: 18px;
                height: 18px;
                flex: 0 0 auto;
                background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23FFFFFF' stroke-width='1.9' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 2h12v20l-3-2-3 2-3-2-3 2V2z'/%3E%3Cpath d='M9.5 7.5h5M9.5 11.5h5M9.5 15.5h3'/%3E%3C/svg%3E") center / contain no-repeat;
            }

            @media (hover: hover) {
                .caja-btn:hover:not(:disabled) {
                    filter: brightness(1.1);
                    transform: translateY(-2px);
                    box-shadow: 0 14px 28px rgba(11, 60, 125, .36);
                }
            }

            .caja-btn:active:not(:disabled) {
                transform: translateY(0);
            }

            .caja-btn:disabled {
                background: #CBD9EC;
                color: #7C93B5;
                box-shadow: none;
                cursor: not-allowed;
            }

            .caja-btn:disabled::before {
                opacity: .6;
            }

            /* ---------- Estados vacíos ---------- */
            .caja-vacio {
                margin-top: 14px;
                padding: 26px 14px;
                text-align: center;
                font-size: .87rem;
                line-height: 1.45;
                color: var(--texto-suave);
                background: #F8FBFF;
                border: 1.5px dashed var(--borde);
                border-radius: 13px;
            }

            .caja-vacio::before {
                content: "";
                display: block;
                width: 44px;
                height: 44px;
                margin: 0 auto 10px;
                border-radius: 50%;
                background-color: var(--cielo-100);
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%231565C0' stroke-width='1.7' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M3 7l9-4 9 4-9 4-9-4z'/%3E%3Cpath d='M3 12l9 4 9-4'/%3E%3Cpath d='M3 17l9 4 9-4'/%3E%3C/svg%3E");
                background-repeat: no-repeat;
                background-position: center;
                background-size: 21px;
            }

            #carritoVacio::before {
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%231565C0' stroke-width='1.7' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M3 4h2l2.4 10.4a2 2 0 0 0 2 1.6h7.7a2 2 0 0 0 2-1.5L21 8H6'/%3E%3Ccircle cx='10' cy='20' r='1.3'/%3E%3Ccircle cx='17.5' cy='20' r='1.3'/%3E%3C/svg%3E");
            }

            #resultados .caja-vacio {
                margin-top: 0;
            }

            /* ---------- Mensajes de éxito / error ---------- */
            .caja-msg {
                position: relative;
                margin-bottom: 18px;
                padding: 13px 16px 13px 46px;
                border-radius: 12px;
                font-size: .9rem;
                font-weight: 600;
                box-shadow: var(--sombra-sm);
                animation: caja-msg-entra .35s ease both;
            }

            .caja-msg::before {
                content: "";
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                width: 20px;
                height: 20px;
                background-repeat: no-repeat;
                background-position: center;
                background-size: contain;
            }

            .caja-msg--ok {
                color: #15803D;
                background: #ECFDF3;
                border: 1px solid #BBE7CD;
            }

            .caja-msg--ok::before {
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2316A34A' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M8.4 12.3l2.5 2.5 4.7-5.2'/%3E%3C/svg%3E");
            }

            .caja-msg--err {
                color: #B91C1C;
                background: #FEF2F2;
                border: 1px solid #F6CBCB;
            }

            .caja-msg--err::before {
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23DC2626' stroke-width='2.2' stroke-linecap='round'%3E%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M9 9l6 6M15 9l-6 6'/%3E%3C/svg%3E");
            }

            /* ---------- Animaciones ---------- */
            @keyframes caja-entra {
                from {
                    opacity: 0;
                    transform: translateY(16px);
                }
                to {
                    opacity: 1;
                    transform: none;
                }
            }

            @keyframes caja-msg-entra {
                from {
                    opacity: 0;
                    transform: translateY(-8px);
                }
                to {
                    opacity: 1;
                    transform: none;
                }
            }

            /* ---------- Responsive ---------- */
            @media (max-width: 900px) {
                .caja {
                    grid-template-columns: 1fr;
                }

                #resultados {
                    max-height: none;
                }
            }

            @media (max-width: 560px) {
                .caja-card {
                    padding: 18px;
                }

                .caja-fila {
                    grid-template-columns: 1fr;
                }

                .caja-total {
                    padding: 13px 15px;
                }

                .caja-total span:last-child {
                    font-size: 1.4rem;
                }

                .caja tbody td:first-child {
                    max-width: 120px;
                }
            }
        </style>
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "facturacion");%>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Facturación</h1>
                        <span class="encabezado__fecha">Módulo 1 · Caja</span>
                    </div>
                    <span class="chip"><span class="chip__punto"></span>Caja abierta</span>
                </div>
            </section>

            <c:if test="${not empty exito}">
                <div class="caja-msg caja-msg--ok"><c:out value="${exito}" /></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="caja-msg caja-msg--err"><c:out value="${error}" /></div>
            </c:if>

            <div class="caja">

                <!-- Buscador -->
                <section class="caja-card caja-card--buscador">
                    <div class="caja-card__cabecera">
                        <span class="caja-card__icono" aria-hidden="true">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="M20 20l-3.6-3.6"/>
                            </svg>
                        </span>
                        <div>
                            <h2>Buscar producto</h2>
                            <p class="caja-card__sub">Escribe y toca un producto para agregarlo</p>
                        </div>
                    </div>
                    <div class="caja-buscador">
                        <svg class="caja-buscador__lupa" width="18" height="18" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
                            <circle cx="11" cy="11" r="7"/>
                            <path d="M20 20l-3.6-3.6"/>
                        </svg>
                        <input id="buscador" type="text" placeholder="Ej: martillo, tornillo, cemento..." autocomplete="off" autofocus>
                    </div>
                    <div id="resultados"><p class="caja-vacio">Escribe para buscar productos</p></div>
                </section>

                <!-- Factura -->
                <section class="caja-card caja-card--factura">
                    <div class="caja-card__cabecera">
                        <span class="caja-card__icono" aria-hidden="true">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M6 2h12v20l-3-2-3 2-3-2-3 2V2z"/>
                                <path d="M9.5 7.5h5"/>
                                <path d="M9.5 11.5h5"/>
                                <path d="M9.5 15.5h3"/>
                            </svg>
                        </span>
                        <div>
                            <h2>Factura actual</h2>
                            <p class="caja-card__sub">Revisa cantidades y cobra al cliente</p>
                        </div>
                    </div>
                    <form id="formFactura" method="post" action="<c:url value='/facturacion' />">
                        <div class="caja-tabla">
                            <table>
                                <thead><tr><th>Producto</th><th>Cant.</th><th>Subtotal</th><th></th></tr></thead>
                                <tbody id="carrito"></tbody>
                            </table>
                        </div>
                        <p id="carritoVacio" class="caja-vacio">Aún no hay productos</p>

                        <div class="caja-total"><span>Total a cobrar</span><span id="total">$0</span></div>

                        <div class="caja-fila">
                            <div class="caja-campo">
                                <label class="caja-campo__label" for="cliente">Cliente (opcional)</label>
                                <input id="cliente" type="text" name="cliente" placeholder="Nombre del cliente">
                            </div>
                            <div class="caja-campo">
                                <label class="caja-campo__label" for="metodoPago">Método de pago</label>
                                <select id="metodoPago" name="metodoPago">
                                    <option value="EFECTIVO">Efectivo</option>
                                    <option value="TARJETA">Tarjeta</option>
                                    <option value="TRANSFERENCIA">Transferencia</option>
                                </select>
                            </div>
                        </div>
                        <button class="caja-btn" id="btnCobrar" type="submit" disabled>Cobrar</button>
                    </form>
                </section>

            </div>
        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <%-- Widget flotante del asistente IA (burbuja + ventana de chat) --%>
        <%@ include file="componentes/widget-ia.jspf" %>

        <script>
            var BASE = '<c:url value="/facturacion" />';
            var cop = function (n) {
                return '$' + Number(n).toLocaleString('es-CO');
            };
            var carrito = {};
            var timer;

            document.getElementById('buscador').addEventListener('input', function (e) {
                clearTimeout(timer);
                var q = e.target.value.trim();
                if (!q) {
                    document.getElementById('resultados').innerHTML = '<p class="caja-vacio">Escribe para buscar productos</p>';
                    return;
                }
                timer = setTimeout(function () {
                    buscar(q);
                }, 250);
            });

            function buscar(q) {
                fetch(BASE + '?accion=buscar&q=' + encodeURIComponent(q))
                        .then(function (r) {
                            return r.json();
                        })
                        .then(function (lista) {
                            var cont = document.getElementById('resultados');
                            cont.innerHTML = '';
                            if (!lista.length) {
                                cont.innerHTML = '<p class="caja-vacio">Sin resultados</p>';
                                return;
                            }
                            lista.forEach(function (p) {
                                var d = document.createElement('div');
                                d.className = 'caja-item';
                                d.innerHTML = '<div><strong></strong><small>Stock: ' + p.stock + '</small></div><b>' + cop(p.precio) + '</b>';
                                d.querySelector('strong').textContent = p.nombre;
                                d.onclick = function () {
                                    agregar(p);
                                };
                                cont.appendChild(d);
                            });
                        });
            }

            function agregar(p) {
                if (carrito[p.id]) {
                    if (carrito[p.id].cant < p.stock)
                        carrito[p.id].cant++;
                } else {
                    carrito[p.id] = {id: p.id, nombre: p.nombre, precio: p.precio, stock: p.stock, cant: 1};
                }
                pintar();
            }

            function pintar() {
                var tb = document.getElementById('carrito');
                tb.innerHTML = '';
                var total = 0;
                Object.keys(carrito).forEach(function (k) {
                    var p = carrito[k];
                    var sub = p.precio * p.cant;
                    total += sub;
                    var tr = document.createElement('tr');
                    tr.innerHTML =
                            '<td></td>' +
                            '<td><input type="number" min="1" max="' + p.stock + '" value="' + p.cant + '"></td>' +
                            '<td>' + cop(sub) + '</td>' +
                            '<td><button type="button" class="caja-x">×</button></td>';
                    tr.children[0].textContent = p.nombre;

                    // Campos ocultos que se envían al servlet
                    var h1 = document.createElement('input');
                    h1.type = 'hidden';
                    h1.name = 'idProducto';
                    h1.value = p.id;
                    var h2 = document.createElement('input');
                    h2.type = 'hidden';
                    h2.name = 'cantidad';
                    h2.value = p.cant;
                    tr.children[3].appendChild(h1);
                    tr.children[3].appendChild(h2);

                    tr.querySelector('input[type=number]').onchange = function (e) {
                        p.cant = Math.min(p.stock, Math.max(1, parseInt(e.target.value, 10) || 1));
                        pintar();
                    };
                    tr.querySelector('.caja-x').onclick = function () {
                        delete carrito[p.id];
                        pintar();
                    };
                    tb.appendChild(tr);
                });
                document.getElementById('total').textContent = cop(total);
                var hay = Object.keys(carrito).length > 0;
                document.getElementById('carritoVacio').style.display = hay ? 'none' : 'block';
                document.getElementById('btnCobrar').disabled = !hay;
            }
            pintar();
        </script>
    </body>
</html>