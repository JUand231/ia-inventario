<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="theme-color" content="#0A2E58">
        <title>Saca Clavos · Consulta IA</title>
        <link rel="stylesheet" href="<c:url value='/assets/css/inventario.css' />">
        <style>
            .chat-card {
                background:#fff;
                border:1px solid #E5E7EB;
                border-radius:14px;
                padding:20px;
                box-shadow:0 1px 3px rgba(10,46,88,.06);
            }
            .chat-sugerencias {
                display:flex;
                flex-wrap:wrap;
                gap:8px;
                margin-bottom:14px;
            }
            .chat-chip {
                border:1px solid #D1D5DB;
                background:#F8FAFC;
                color:#0A2E58;
                padding:7px 14px;
                border-radius:999px;
                font-size:.85rem;
                cursor:pointer;
                font-family:inherit;
            }
            .chat-chip:hover {
                background:#E8F0FA;
                border-color:#0A2E58;
            }
            .chat-mensajes {
                display:flex;
                flex-direction:column;
                gap:10px;
                height:50vh;
                min-height:280px;
                overflow-y:auto;
                padding:6px 2px 10px;
            }
            .chat-burbuja {
                max-width:80%;
                padding:11px 15px;
                border-radius:14px;
                font-size:.95rem;
                line-height:1.45;
                white-space:pre-wrap;
                word-wrap:break-word;
            }
            .chat-burbuja--yo {
                align-self:flex-end;
                background:#0A2E58;
                color:#fff;
                border-bottom-right-radius:4px;
            }
            .chat-burbuja--ia {
                align-self:flex-start;
                background:#F1F5F9;
                color:#1F2937;
                border-bottom-left-radius:4px;
            }
            .chat-burbuja--espera {
                color:#6B7280;
                font-style:italic;
            }
            .chat-burbuja--error {
                align-self:flex-start;
                background:#FEE2E2;
                color:#B91C1C;
            }
            .chat-meta {
                display:block;
                margin-top:6px;
                font-size:.72rem;
                color:#9CA3AF;
            }
            .chat-form {
                display:flex;
                gap:10px;
                margin-top:14px;
            }
            .chat-form input {
                flex:1;
                padding:12px 14px;
                border:1px solid #D1D5DB;
                border-radius:12px;
                font-size:.95rem;
                font-family:inherit;
            }
            .chat-form input:focus {
                outline:2px solid #0A2E58;
                border-color:transparent;
            }
            .chat-form button {
                padding:0 22px;
                border:none;
                border-radius:12px;
                background:#0A2E58;
                color:#fff;
                font-weight:600;
                cursor:pointer;
                font-family:inherit;
            }
            .chat-form button:hover {
                background:#0D3B73;
            }
            .chat-form button:disabled {
                background:#CBD5E1;
                cursor:not-allowed;
            }
        </style>
    </head>
    <body>

        <% pageContext.setAttribute("paginaActiva", "consulta");%>
        <%@ include file="componentes/topbar.jspf" %>

        <main class="contenedor">

            <section class="encabezado">
                <div class="encabezado__fila">
                    <div>
                        <h1 class="encabezado__titulo">Consulta con IA</h1>
                        <span class="encabezado__fecha">Módulo 2 · Asistente de inventario</span>
                    </div>
                </div>
            </section>

            <section class="chat-card">
                <div class="chat-sugerencias">
                    <button type="button" class="chat-chip">¿Dónde están los tornillos?</button>
                    <button type="button" class="chat-chip">¿Cuánto cemento queda?</button>
                    <button type="button" class="chat-chip">¿Cómo van las ventas de hoy?</button>
                    <button type="button" class="chat-chip">¿Qué productos tienen stock bajo?</button>
                    <button type="button" class="chat-chip">¿Qué se ha vendido más este mes?</button>
                </div>

                <div class="chat-mensajes" id="mensajes">
                    <div class="chat-burbuja chat-burbuja--ia">Hola. Pregúntame por productos, stock, ubicaciones o ventas de la ferretería.</div>
                </div>

                <form class="chat-form" id="formChat">
                    <input id="pregunta" type="text" maxlength="500" placeholder="Escribe tu pregunta..." autocomplete="off" autofocus>
                    <button type="submit" id="enviar">Enviar</button>
                </form>
            </section>

        </main>

        <footer class="pie">
            <p><strong>Saca Clavos</strong> · Sistema de inventario, facturación y asistente con inteligencia artificial</p>
        </footer>

        <script>
            var URL_CONSULTA = '<c:url value="/consulta" />';
            var cont = document.getElementById('mensajes');
            var input = document.getElementById('pregunta');
            var boton = document.getElementById('enviar');

            function escapar(t) {
                return String(t).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            }
            function formato(t) {
                return escapar(t).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
            }
            function agregar(clases, html) {
                var d = document.createElement('div');
                d.className = 'chat-burbuja ' + clases;
                d.innerHTML = html;
                cont.appendChild(d);
                cont.scrollTop = cont.scrollHeight;
                return d;
            }

            function enviar(texto) {
                texto = texto.trim();
                if (!texto)
                    return;
                agregar('chat-burbuja--yo', escapar(texto));
                var espera = agregar('chat-burbuja--ia chat-burbuja--espera', 'Consultando el inventario...');
                boton.disabled = true;
                input.value = '';

                fetch(URL_CONSULTA, {method: 'POST', body: new URLSearchParams({pregunta: texto})})
                        .then(function (r) {
                            return r.json();
                        })
                        .then(function (m) {
                            espera.remove();
                            if (m.tipo === 'exito') {
                                agregar('chat-burbuja--ia', formato(m.respuesta.texto)
                                        + '<small class="chat-meta">' + m.respuesta.tokensTotal + ' tokens</small>');
                            } else {
                                agregar('chat-burbuja--error', escapar(m.error));
                            }
                        })
                        .catch(function () {
                            espera.remove();
                            agregar('chat-burbuja--error', 'No se pudo conectar con el servidor.');
                        })
                        .then(function () {
                            boton.disabled = false;
                            input.focus();
                        });
            }

            document.getElementById('formChat').addEventListener('submit', function (e) {
                e.preventDefault();
                enviar(input.value);
            });
            Array.prototype.forEach.call(document.querySelectorAll('.chat-chip'), function (b) {
                b.addEventListener('click', function () {
                    enviar(b.textContent);
                });
            });
        </script>
    </body>
</html>