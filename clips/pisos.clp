;Dividir el programa en modulos:
;   Se introduce la información sobre los pisos
;   El cliente nos da su información
;   Deducimos que tipo de inmueble busca
;   Buscamos entre nuestros inmuebles los que se ajustan
;   Los mostramos ordenados
;
; Mirar Diapositivas Control Ejecucion


(defmodule PISOS (export ?ALL))

;;; El garaje mejor en un slot
(deftemplate PISOS::inmueble "Caracteristicas de un piso"
    (slot direccion         (type STRING))
    (slot zona              (type STRING))
    (slot precio            (type FLOAT))
    (slot metros-cuadrados  (type INTEGER))
    (slot n-habitaciones    (type INTEGER))
    (slot accesible         (type SYMBOL)   (allowed-symbols no si))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (multislot extras       (type SYMBOL)   (allowed-symbols garaje parque-infantil)))

;TODO: IO para leer información de pisos aquí

(defmodule CLIENTES (export ?ALL))

(deftemplate CLIENTES::cliente "Datos del cliente"
    (slot nombre            (type STRING))
    (slot zona-trabajo      (type STRING))
    (slot discapacidad      (type SYMBOL)   (allowed-symbols no si))
    (slot coche             (type SYMBOL)   (allowed-symbols no si))
    (slot mascota           (type SYMBOL)   (allowed-symbols no si))
    (slot tipo-residentes   (type SYMBOL)   (allowed-symbols familia pareja amigos))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (slot ingresos-anuales  (type INTEGER)  (range 0 ?VARIABLE))
    (slot n-residentes      (type INTEGER)  (range 0 ?VARIABLE)))

;IO para leer información de clientes:

(defrule CLIENTES::preguntas
    ;Seguramente esta regla ser ejecute constantemente.
	=>
	(printout t "Escribe tu nombre y pulsa Enter> ")
	(bind ?name (read))
	(printout t crlf "**********************************" crlf)
	(printout t " Hola, " ?name "." crlf)
	(printout t " Bienvenido al sistema de recomendación de casas" crlf)
	(printout t " Por favor, responda a las preguntas y le diremos que casas son más adecuadas para usted." crlf)
	(printout t "**********************************" crlf crlf)

	(bind ?trabajo      (ask-user "¿Donde trabajas?" string))

	(bind ?discapacidad (ask-user "¿Vas a vivir con alguien con discapacidades físicas?" yes-no))

	(bind ?coche        (ask-user "¿Tienes coche?" yes-no))

	(bind ?mascota      (ask-user "¿Tienes mascota?" yes-no))

	(bind ?tipo         (ask-user "Elige tipo de residentes (familia / pareja / amigos)" t-residentes))

	(bind ?transaccion  (ask-user "¿Quieres comprar o alquilar?" t-transaccion))

	(bind ?salario      (ask-user "Introduce tu salario anual en euros: " number))

	(bind ?n-residentes (ask-user "Introduce el numero de personas con las que vas a convivir: " number))

	(assert(cliente
		(nombre ?name)
		(trabajo ?trabajo)
		(discapacidad ?discapacidad)
		(mascota ?mascota)
		(coche ?coche)
		(tipo-residentes ?tipo)
		(transaccion ?transaccion)
		(ingresos-anuales ?salario)
		(n-residentes ?n-residentes)))
        ;cambiar modulo
        )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module ask

;(defmodule ask)
(defmodule QUESTIONS (import MAIN ?ALL))

(deffunction QUESTIONS::is-of-type (?answer ?type)
  "Check that the answer has the right form"
  (if (eq ?type yes-no) then
         (or (eq ?answer yes) (eq ?answer no))
   else	(if (eq ?type number) then (numberp ?answer)
   else (if (eq ?type t-residentes)  then (or (eq ?answer familia) (eq ?answer pareja) (eq ?answer amigos))
   else (if (eq ?type t-transaccion) then (or (eq ?answer compra)  (eq ?answer alquiler))
   else (> (str-length ?answer) 0))))))


(deffunction QUESTIONS::ask-user (?question ?type)
  "Ask a question, and return the answer"
  (printout t ?question " ")
  (if (eq ?type yes-no) then
           (printout t "(si / no) "))
  (bind ?answer (read))
  (while (not (is-of-type ?answer ?type)) do
         (printout t ?question " ")
         (if (eq ?type yes-no) then
           (printout t "(si / no) "))
         (bind ?answer (read)))
  ?answer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule PREFERENCIAS (import CLIENTES))

(deftemplate PREFERENCIAS::preferencias-precio "Información con las preferencias económicas de un cliente"
    (slot cliente       (type STRING))
    (slot precio-max    (type INTEGER))
    (slot transaccion   (type SYMBOL)   (allowed-symbols compra alquiler)))

;La idea es puntuar mejor a las casas con el nº de habitciones en el rango
(deftemplate PREFERENCIAS::preferencias-tamaño "Información con las preferencias de espacio de un cliente"
    (slot cliente           (type STRING))
    (slot habitaciones-min  (type INTEGER))
    (slot habitaciones-max  (type INTEGER))
    (slot espacioso         (type SYMBOL)   (allowed-symbols no si)))

(deftemplate PREFERENCIAS::preferencias-zona
    (slot cliente    (type STRING))
    (slot zona       (type STRING)))

(deftemplate PREFERENCIAS::preferencias-extras
    (slot cliente   (type STRING))
    (slot accesible (type SYMBOL) (allowed-symbols no si))
    (slot garaje    (type SYMBOL) (allowed-symbols no si)))


(defrule PREFERENCIAS::deducir-preferencias-economicas-alquiler "Deduce, a partir de los datos del cliente, que tipo de piso prefiere"
    (clientes
        (nombre             ?nombre)
        (ingresos-anuales   ?ingresos)
        (transaccion        alquiler))
    =>
    (assert (preferencias-precio
        (cliente        ?nombre)
        (precio-max     (integer (* (/ ?ingresos 12) 0.4)))))) ;EL gasto en alquiler no debe superar el 40% del sueldo

(defrule PREFERENCIAS::deducir-preferencias-economicas-compra
    (clientes
        (nombre             ?nombre)
        (ingresos-anuales   ?ingresos)
        (transaccion        compra))
    =>
    (assert (preferencias-precio
        (cliente        ?nombre)
        (precio-max     (* ?ingresos 9))))) ;El precio de la casa no debe superar el salario de 9 años

(defrule PREFERENCIAS::deducir-preferencias-tamaño-familia
    (clientes
        (nombre             ?nombre)
        (mascota            ?mascota)
        (tipo-residentes    familia)
        (n-residentes       ?n-residentes))
    =>
    (assert (preferencias-tamaño
        (cliente            ?nombre)
        (habitaciones-max   (- ?n-residentes 1))            ;Normalmente en las familias los padres o hermanos comparten habitación
        (habitaciones-min   (div (+ 1 ?n-residentes) 2))))  ;Como mucho compartir habitaciones de 2 en dos
        (espaciosa          ?mascota))))                    ;Si tienen mascota van a necesitar más espacio (los metros^2 puntuarán más)

(defrule PREFERENCIAS::deducir-preferencias-tamaño-amigos
    (clientes
        (nombre             ?nombre)
        (mascota            ?mascota)
        (tipo-residentes    amigos)
        (n-residentes       ?n-residentes))
    =>
    (assert (preferencias-tamaño
        (cliente            ?nombre)
        (habitaciones-max   ?n-residentes)  ;No hacen falta más habitaciones de los amigos que hay
        (habitaciones-min   ?n-residentes)  ;Los amigos no suelen compartir habitación
        (espaciosa          ?mascota))))    ;Si tienen mascota van a necesitar más espacio (los metros^2 puntuarán más)


;Con una base de datos de las zonas y su disposición se podria crear preferencias de las zonas cercanas al trabajo.
(defrule PREFERENCIAS::deducir-preferencias-zona
    (cliente
        (nombre         ?nombre)
        (zona-trabajo   ?zona))
    =>
    (assert (preferencias-zona
        (cliente    ?nombre)
        (zona       ?zona))))


(defrule PREFERENCIAS::deducir-preferencias-extras
    (cliete
        (nombre         ?nombre)
        (discapacidad   ?discapacidad)
        (coche          ?coche))
    =>
    (assert (preferencias-extras
        (cliente    ?nombre)
        (accesible  ?discapacidad)
        (garaje     ?coche))))

(defmodule MATCH (import ?ALL))

(deftemplate MATCH::compatible
    (cliente    (type STRING))
    (piso       (type STRING))
    (puntuacion (type FLOAT)))
;Puntua como de bajo es el precio, como de espaciosa es y que el nº de habitaciones se acerque al nº maximo.
(deffunction MATCH::puntua (?precio-max ?precio ?espaciosa ?metros ?hab ?hab-max )
    (if (eq ?espaciosa si) then (bind ?factor 3) else (bind ?factor 6))
    (+ (/ (- ?precio-max ?precio) 10) (/ ?metros ?factor) (* (abs (- ?hab ?hab-max)) 10)))
    
(defrule MATCH::match-precio
    (cliente
        (nombre         ?nombre)
        (n-residentes   ?n-residentes))
    (preferencias-precio
        (cliente        ?nombre)
        (precio-max     ?precio-max)
        (transaccion    ?transaccion))
    (preferencias-tamaño
        (cliente            ?nombre)
        (habitaciones-max   ?hab-max)
        (habitaciones-min   ?hab-min)
        (espaciosa          ?espaciosa))
    (preferencias-zona
        (cliente    ?nombre)
        (zona       ?zona))
    (preferencias-extras
        (clientes   ?nombre)
        (accesible  ?accesible)
        (garaje     ?garje))
    (piso
        (direccion          ?dir)
        (precio             ?precio)        ;restrictivo con el máximo, puntua
        (zona               ?zona)          ;restrictivo
        (metros-cuadrados   ?metros)        ;restrictivo si se pide espacioso, puntua
        (n-habitaciones     ?hab)           ;restrictivo con el minimo, puntuable con el maximo
        (accesible          ?accesible)     ;restrictivo
        (transaccion        ?transaccion))  ;restrictivo
    
    (test (>= ?precio   ?precio-max))
    (test (>= ?hab      ?hab-min))              ;El minimo de habitaciones es restrictivo, el maximo se considera en la puntuacion
    (test (>= ?metros   (* ?n-residentes 20)))  ;Un piso se puede considerar espacioso si tiene más de 20m^2 por residente (completamente inventado)
    =>
    (assert (compatible
        (cliente    ?nombre)
        (piso       ?dir)
        (puntuacion (puntua ?precio-max ?precio ?espaciosa ?metros ?hab ?hab-max))))) ;funcion que asigna puntuación

       (deftemplate PISOS::inmueble "Caracteristicas de un piso"
    (slot direccion         (type STRING))
    (slot zona              (type STRING))
    (slot precio            (type FLOAT))
    (slot metros-cuadrados  (type INTEGER))
    (slot n-habitaciones    (type INTEGER))
    (slot accesible         (type SYMBOL)   (allowed-symbols no si))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (multislot extras       (type SYMBOL)   (allowed-symbols garaje parque-infantil)))
        
; La idea es hacer mas reglas como match-precio que actualicen la puntuacion de la compatibilidad (revertiendola y assertandola de nuevo)
; para hacer esto a lo mejor hace falta añadir algún slot más a compatible para saber que comprobaciones se han hecho ya

(defmodule RESULTADOS (import ?ALL))

; IO para mostrar resultados

(defrule RESULTADOS::mostar-recomendaciones-ordenadas
    ?compatible <-(compatible (cliente ?nombre) (puntuacion ?puntuacion)  (piso ?dir))
    (not          (compatible (cliente ?nombre) (puntuacion ?puntuacion2&:(< ?puntuacion ?puntuacion2))))
    =>
    (printout t "Recomendamos el piso " ?dir ". Puntuacion asociada " ?puntuacion  clrf)
    (retract ?compatible))

;; DATABASE:
(deffacts MAIN::inmuebles-database 
    (inmueble (direccion "C/Colón") (zona "centro") (precio 100.0) (n-habitaciones 3) (tipo piso)))

(deffacts MAIN::clientes-database
    (cliente (nombre "Jose") (ingresos-anuales 12000) (n-residentes 3) (tipo-residentes familia) (zona-trabajo "centro") (coche si)))
