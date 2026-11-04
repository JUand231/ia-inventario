/* ============================================================
   avisos.js · Avisos del sistema con SweetAlert2
   Sustituye los alert() y confirm() del navegador.

   - avisos.exito(texto)        toast verde (se cierra solo)
   - avisos.error(texto)        toast rojo (se cierra solo)
   - avisos.ventanaExito(texto) ventana modal de éxito
   - avisos.ventanaError(texto) ventana modal de error
   - avisos.confirmar(datos)    ventana de confirmación (devuelve promesa)

   Los formularios con la clase "aviso-confirmar" piden confirmación
   antes de enviarse. El texto se toma de:
     data-titulo  → título de la ventana
     data-texto   → mensaje fijo
     data-texto-fn → nombre de una función propia de la página
                     que devuelve el mensaje (para textos dinámicos)
   ============================================================ */

var avisos = {

    /* Toast verde: para "guardado/registrado correctamente". */
    exito: function (texto) {
        Swal.fire({
            icon: 'success',
            title: texto,
            toast: true,
            position: 'top',
            showConfirmButton: false,
            timer: 3200,
            timerProgressBar: true
        });
    },

    /* Toast rojo: para errores de base de datos o de carga. */
    error: function (texto) {
        Swal.fire({
            icon: 'error',
            title: texto,
            toast: true,
            position: 'top',
            showConfirmButton: false,
            timer: 4200,
            timerProgressBar: true
        });
    },

    /* Ventana modal de éxito: para momentos importantes (ej: cobrar). */
    ventanaExito: function (texto) {
        Swal.fire({
            icon: 'success',
            title: texto,
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#0A2E58',
            showClass: { popup: 'swal2-show' },
            hideClass: { popup: 'swal2-hide' }
        });
    },

    /* Ventana modal de error. */
    ventanaError: function (texto) {
        Swal.fire({
            icon: 'error',
            title: texto,
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#B91C1C'
        });
    },

    /* Confirmación genérica. Devuelve una promesa con true/false. */
    confirmar: function (datos) {
        var texto = datos.texto;
        if (typeof texto === 'function') {
            texto = texto();
        }
        return Swal.fire({
            icon: datos.icono || 'warning',
            title: datos.titulo,
            text: texto,
            showCancelButton: true,
            confirmButtonText: datos.confirmar || 'Sí, continuar',
            cancelButtonText: datos.cancelar || 'Cancelar',
            confirmButtonColor: datos.color || '#0A2E58',
            reverseButtons: true
        }).then(function (resultado) {
            return resultado.isConfirmed;
        });
    },

    /* Pide confirmación antes de enviar un formulario. */
    confirmarEnvio: function (formulario, datos) {
        formulario.addEventListener('submit', function (evento) {
            // Si ya se confirmó, se deja pasar el envío normal.
            if (formulario.getAttribute('data-confirmado') === 'si') {
                return;
            }
            evento.preventDefault();
            avisos.confirmar(datos).then(function (aceptado) {
                if (aceptado) {
                    formulario.setAttribute('data-confirmado', 'si');
                    // submit() envía sin volver a disparar este evento,
                    // así no queda en un bucle de confirmaciones.
                    formulario.submit();
                }
            });
        });
    },

    /* Une todos los formularios marcados con .aviso-confirmar. */
    prepararFormularios: function () {
        var formularios = document.querySelectorAll('form.aviso-confirmar');
        Array.prototype.forEach.call(formularios, function (formulario) {
            var datos = {
                titulo: formulario.getAttribute('data-titulo'),
                confirmar: formulario.getAttribute('data-boton'),
                color: formulario.getAttribute('data-color'),
                texto: formulario.getAttribute('data-texto')
            };
            var funcion = formulario.getAttribute('data-texto-fn');
            if (funcion && typeof window[funcion] === 'function') {
                datos.texto = window[funcion];
            }
            avisos.confirmarEnvio(formulario, datos);
        });
    },

    /* Muestra el aviso que mandó el servidor (producto guardado, error...). */
    mostrarAvisoDelServidor: function () {
        var datos = document.getElementById('datos-aviso');
        if (!datos) {
            return;
        }
        var exito = datos.getAttribute('data-exito');
        var error = datos.getAttribute('data-error');
        // data-modo="ventana" → modal en el centro (facturación);
        // sin modo → toast arriba (demás páginas).
        var enVentana = datos.getAttribute('data-modo') === 'ventana';

        if (exito) {
            if (enVentana) {
                avisos.ventanaExito(exito);
            } else {
                avisos.exito(exito);
            }
        } else if (error) {
            if (enVentana) {
                avisos.ventanaError(error);
            } else {
                avisos.error(error);
            }
        }
    }
};

document.addEventListener('DOMContentLoaded', function () {
    avisos.prepararFormularios();
    avisos.mostrarAvisoDelServidor();
});
