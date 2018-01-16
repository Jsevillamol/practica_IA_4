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
    (slot n-aseos           (type INTEGER))
    (slot accesible         (type SYMBOL)   (allowed-symbols no si))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (multislot extras       (type SYMBOL)   (allowed-symbols garaje parque-infantil)))

;IO para leer información de pisos aquí

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

;IO para leer información de clientes aquí

(defmodule PREFERENCIAS (import CLIENTES))

(deftemplate PREFERENCIAS::preferencias-precio "Información con las preferencias económicas de un cliente"
    (slot cliente       (type STRING))
    (slot precio-max    (type INTEGER)))

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

(defrule MATCH::match-precio
    (preferencias-precio
        (cliente            ?nombre)
        (precio-max         ?precio-max))
    (piso
        (direccion  ?dir)
        (precio     ?precio))
    (=< ?precio ?precio-max)
    =>
    (assert (compatible
        (cliente    ?nombre)
        (piso       ?dir)
        (puntuacion (/ (- ?precio-max ?precio) 10)))))

; La idea es hacer mas reglas como match-precio que actualicen la puntuacion de la compatibilidad (revertiendola y assertandola de nuevo)
; para hacer esto a lo mejor hace falta añadir algún slot más a compatible para saber que comprobaciones se han hecho ya

(defmodule RESULTADOS (import ?ALL))

; IO para mostrar resultados


;; DATABASE:
(deffacts MAIN::inmuebles-database 
    (inmueble (direccion "C/Colón") (zona "centro") (precio 100.0) (n-habitaciones 3) (tipo piso)))

(deffacts MAIN::clientes-database
    (cliente (nombre "Jose") (ingresos-anuales 12000) (n-residentes 3) (tipo-residentes familia) (zona-trabajo "centro") (coche si)))
