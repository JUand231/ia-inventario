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
        <style>
            .caja {
                display:grid;
                grid-template-columns:1fr 1.2fr;
                gap:20px;
                align-items:start;
            }
            .caja-card {
                background:#fff;
                border:1px solid #E5E7EB;
                border-radius:14px;
                padding:20px;
                box-shadow:0 1px 3px rgba(10,46,88,.06);
            }
            .caja-card h2 {
                margin:0 0 14px;
                font-size:.8rem;
                text-transform:uppercase;
                letter-spacing:.06em;
                color:#6B7280;
            }
            .caja input, .caja select {
                width:100%;
                padding:10px 12px;
                border:1px solid #D1D5DB;
                border-radius:10px;
                font-size:.95rem;
                font-family:inherit;
            }
            .caja input:focus, .caja select:focus {
                outline:2px solid #0A2E58;
                border-color:transparent;
            }
            .caja-item {
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:10px 6px;
                border-bottom:1px solid #EEF0F3;
                cursor:pointer;
                border-radius:8px;
            }
            .caja-item:hover {
                background:#F1F6FC;
            }
            .caja-item small {
                display:block;
                color:#6B7280;
            }
            .caja-item b {
                color:#0A2E58;
            }
            .caja table {
                width:100%;
                border-collapse:collapse;
                font-size:.9rem;
            }
            .caja th {
                text-align:left;
                color:#6B7280;
                font-weight:500;
                padding:6px 4px;
            }
            .caja td {
                padding:8px 4px;
                border-top:1px solid #EEF0F3;
            }
            .caja td input {
                width:66px;
                padding:6px;
            }
            .caja-x {
                background:none;
                border:none;
                color:#B91C1C;
                cursor:pointer;
                font-size:1.2rem;
            }
            .caja-total {
                display:flex;
                justify-content:space-between;
                font-size:1.5rem;
                font-weight:700;
                color:#0A2E58;
                margin:16px 0;
            }
            .caja-fila {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px;
                margin-bottom:12px;
            }
            .caja-btn {
                width:100%;
                padding:14px;
                border:none;
                border-radius:12px;
                background:#0A2E58;
                color:#fff;
                font-size:1rem;
                font-weight:600;
                cursor:pointer;
            }
            .caja-btn:hover {
                background:#0D3B73;
            }
            .caja-btn:disabled {
                background:#CBD5E1;
                cursor:not-allowed;
            }
            .caja-vacio {
                color:#6B7280;
                text-align:center;
                padding:22px 0;
                font-size:.9rem;
            }
            .caja-msg {
                padding:12px 16px;
                border-radius:10px;
                margin-bottom:14px;
                font-size:.9rem;
            }
            .caja-msg--ok {
                background:#DCFCE7;
                color:#15803D;
            }
            .caja-msg--err {
                background:#FEE2E2;
                color:#B91C1C;
            }
            @media (max-width:900px) {
                .caja {
                    grid-template-columns:1fr;
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
                <section class="caja-card">
                    <h2>Buscar producto</h2>
                    <input id="buscador" type="text" placeholder="Ej: martillo, tornillo, cemento..." autocomplete="off" autofocus>
                    <div id="resultados"><p class="caja-vacio">Escribe para buscar productos</p></div>
                </section>

                <!-- Factura -->
                <section class="caja-card">
                    <h2>Factura actual</h2>
                    <form id="formFactura" method="post" action="<c:url value='/facturacion' />">
                        <table>
                            <thead><tr><th>Producto</th><th>Cant.</th><th>Subtotal</th><th></th></tr></thead>
                            <tbody id="carrito"></tbody>
                        </table>
                        <p id="carritoVacio" class="caja-vacio">Aún no hay productos</p>

                        <div class="caja-total"><span>Total</span><span id="total">$0</span></div>

                        <div class="caja-fila">
                            <input type="text" name="cliente" placeholder="Cliente (opcional)">
                            <select name="metodoPago">
                                <option value="EFECTIVO">Efectivo</option>
                                <option value="TARJETA">Tarjeta</option>
                                <option value="TRANSFERENCIA">Transferencia</option>
                            </select>
                        </div>
                        <button class="caja-btn" id="btnCobrar" type="submit" disabled>Cobrar</button>
                    </form>
                </section>

            </div>
        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

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