# ==== INICIO · Avisos para actuaria.com (pantalla de carga y medición) ==========================
# Copiar este bloque tal cual en la ui de cada calculadora. No hay que tocar el server.
# Le avisa a la página de actuaria.com que contiene la calculadora:
#   'actuaria-listo'    una sola vez, cuando la app terminó de dibujarse. La web quita su pantalla de carga.
#   'actuaria-calculo'  cada vez que la persona calcula y el resultado sale sin error. Se cuenta en GA4.
#                       Con botón: cada clic en Calcular. Sin botón (la app recalcula sola al cambiar
#                       un dato): una vez por cada tanda de cambios, cuando pasan 2 segundos sin cambios.
# No envía ningún dato del usuario (ni sueldos, ni fechas, ni montos). Si la app se abre sola, fuera de
# la web, no hace nada. Sirve con submitButton, con actionButton y con apps sin botón. Si la app tiene
# botones que no calculan (por ejemplo «Limpiar»), cambiar el selector por el del botón que calcula,
# por ejemplo '#calcular'. Termina con coma porque va antes de otros elementos de la ui; si quedara
# de último dentro de fluidPage(), quitarle esa coma.
tags$script(HTML("
  (function () {
    if (window.parent === window) return;
    function notify(kind) { window.parent.postMessage({ tipo: kind }, '*'); }
    var ready = false, acted = false, clicked = false, updated = false, failed = false, touched = 0, timer = null;
    document.addEventListener('pointerdown', function () { touched = Date.now(); }, true);
    document.addEventListener('keydown', function () { touched = Date.now(); }, true);
    $(document).on('click', 'button[type=submit], .action-button', function () { acted = true; clicked = true; });
    $(document).on('shiny:inputchanged', function (e) {
      if (ready && e.name && e.name.charAt(0) !== '.' && Date.now() - touched < 3000) acted = true;
    });
    $(document).on('shiny:value', function () { updated = true; });
    $(document).on('shiny:error', function () { failed = true; });
    $(document).on('shiny:busy', function () { clearTimeout(timer); });
    $(document).on('shiny:idle', function () {
      clearTimeout(timer);
      timer = setTimeout(function () {
        if (!ready) { ready = true; notify('actuaria-listo'); }
        else if (acted && updated && !failed) { notify('actuaria-calculo'); }
        acted = clicked = updated = failed = false;
      }, ready && !clicked ? 2000 : 250);
    });
  })();
")),
# ==== FIN · Avisos para actuaria.com =============================================================
