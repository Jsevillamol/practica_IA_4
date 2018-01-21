;El programa se divide en los modulos:
;   MAIN: Tiene 2 funciones auxiliares para la entrada de datos.
;   PISOS: define el template inmueble y lee los datos de los pisos
;   CLIENTES: define el template cliente y lee los datos del clientes
;   PREFERENCIAS: deduce las preferencias del cliente y las guarda en templates de preferencias
;   MATCH: filtra los pisos que le puedan interesar al cliente y los puntua
;   RESULTADOS: muestra ordenadamente los pisos encontrados


(defmodule MAIN (export ?ALL))

(deffunction MAIN::is-of-type (?answer ?type)
    "Check that the answer has the right form"
    (if      (eq ?type yes-no)          then (or (eq ?answer si) (eq ?answer no))
    else (if (eq ?type number)          then (numberp ?answer)
    else (if (eq ?type string)          then (stringp ?answer)
    else (if (eq ?type t-residentes)    then (or (eq ?answer familia) (eq ?answer pareja) (eq ?answer amigos))
    else (if (eq ?type t-transaccion)   then (or (eq ?answer compra)  (eq ?answer alquiler))
    else TRUE))))))

(deffunction MAIN::ask-user (?question ?type)
    "Ask a question, and return the answer"
    (printout t ?question " ")
    (if (eq ?type yes-no) then (printout t "(si / no) "))
    (bind ?answer (read))
    (while (not (is-of-type ?answer ?type)) do
        (printout t ?question " ")
        (if (eq ?type yes-no) then (printout t "(si / no) "))
        (if (eq ?type string) then (printout t "(pon tu respuesta entre comillas) "))
        (bind ?answer (read)))
    ?answer)


(defrule MAIN::inicio
    =>
    (printout t "Cambiando modulo: MAIN a PISOS" crlf)
    (focus PISOS));El programa empieza pidiendo los pisos



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule PISOS (export ?ALL) (import MAIN ?ALL))

(deftemplate PISOS::inmueble "Caracteristicas de un piso"
    (slot direccion         (type STRING))
    (slot zona              (type SYMBOL))
    (slot precio            (type INTEGER))
    (slot metros-cuadrados  (type INTEGER))
    (slot n-habitaciones    (type INTEGER))
    (slot accesible         (type SYMBOL)   (allowed-symbols no si))
    (slot garaje            (type SYMBOL)   (allowed-symbols no si))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler)))

;IO para leer información de pisos:

(defrule PISOS::preguntas
    =>
    (load-facts pisos-database.clp)
    (bind ?mas (ask-user "Ya hay algunos pisos en el sistema. Quiere introducir más pisos?" yes-no))

    (while (eq si ?mas) do
        (bind ?dir          (ask-user "En que direccion se encuentra?" string))
        (bind ?zona         (ask-user "En que zona se encuentra?" symbol))
        (bind ?transaccion  (ask-user "Quiere alquilar o ponerlo a la venta? (compra/alquiler)" t-transaccion))
        (bind ?precio       (ask-user "¿A que precio?" number))
        (bind ?metros       (ask-user "¿Cuantos metros cuadrados tiene el piso?" number))
        (bind ?hab          (ask-user "¿Cuantas habitaciones tiene el piso?" number))
        (bind ?accesible    (ask-user "¿Tiene facilidades para minusvalidos?" yes-no))
        (bind ?garaje       (ask-user "¿Tiene garaje?" yes-no))

        (assert(inmueble
            (direccion          ?dir)
            (precio             ?precio)
            (zona               ?zona)
            (metros-cuadrados   ?metros)
            (n-habitaciones     ?hab)
            (accesible          ?accesible)
            (garaje             ?garaje)
            (transaccion        ?transaccion)))
            
        (bind ?mas (ask-user "Quiere introducir más pisos?" yes-no)))

    (bind ?mas (ask-user "Quiere modificar la informacion de algun piso?" yes-no))
    (while (eq si ?mas) do
        (bind ?dir (ask-user "Introduzca la direccion del piso a modificar" string))
        (assert(modificacion-pendiente ?dir))
        (printout t "Modificacion pendiente registrada. Mas adelante accedera al menu de modificacion" crlf)
        (bind ?mas (ask-user "Quiere modificar más pisos?" yes-no)))

    (bind ?mas (ask-user "Quiere eliminar la informacion de algun piso?" yes-no))
    (while (eq si ?mas) do
        (bind ?dir (ask-user "Introduzca la direccion del piso a eliminar" string))
        (assert(eliminacion-pendiente ?dir))
        (printout t "Eliminacion pendiente registrada. Mas adelante la informacion se eliminara automaticamente." crlf)
        (bind ?mas (ask-user "Quiere eliminar más pisos?" yes-no)))) 

(defrule PISOS:modificar-piso
	?modificacion <- (modificacion-pendiente ?dir)
	?inmueble <- (inmueble
        (direccion          ?dir)
        (precio             ?precio)
        (zona               ?zona)
        (metros-cuadrados   ?metros)
        (n-habitaciones     ?hab)
        (accesible          ?accesible)
        (garaje             ?garaje)
        (transaccion        ?transaccion))
	=>
	(printout t "Modificando el piso " ?dir crlf)
	(bind ?dir-nueva          (ask-user "¿Nueva direccion?" string))
    (printout t "La zona anterior era: " ?zona crlf)
    (bind ?zona-nueva         (ask-user "¿Nueva zona?" symbol))
	(printout t "El tipo de transaccion anterior era: " ?transaccion crlf)
    (bind ?transaccion-nuevo  (ask-user "Quiere alquilar o ponerlo a la venta? (compra/alquiler)" t-transaccion))
    (printout t "El precio anterior era: " ?precio crlf)
    (bind ?precio-nuevo       (ask-user "¿Nuevo precio?" number))
    (printout t "El numero de metros cuadrados anterior era: " ?metros crlf)
    (bind ?metros-nuevo       (ask-user "¿Cuantos metros cuadrados tiene el piso ahora?" number))
    (printout t "El numero de habitaciones anterior era: " ?hab crlf)
    (bind ?hab-nuevo          (ask-user "¿Cuantas habitaciones tiene el piso ahora?" number))
    (printout t "Antes el piso " (if (eq ?accesible no) then "NO " else "") "tenia facilidades para minusvalidos." crlf)
    (bind ?accesible-nuevo    (ask-user "¿Tiene ahora facilidades para minusvalidos?" yes-no))
    (printout t "Antes el piso " (if (eq ?garaje no) then "NO " else "") "tenia garaje." crlf)
    (bind ?garaje-nuevo       (ask-user "¿Tiene ahora garaje?" yes-no))

    (retract ?inmueble)
	(assert(inmueble
            (direccion          ?dir-nueva)
            (precio             ?precio-nuevo)
            (zona               ?zona-nueva)
            (metros-cuadrados   ?metros-nuevo)
            (n-habitaciones     ?hab-nuevo)
            (accesible          ?accesible-nuevo)
            (garaje             ?garaje-nuevo)
            (transaccion        ?transaccion-nuevo)))
    (retract ?modificacion))

(defrule PISOS::modificar-piso-error
	?modificacion-pendiente<-(modificacion-pendiente ?dir)
	(not (inmueble (direccion ?dir)))
	=>
	(printout t "Error al intentar modificar el piso " ?dir "." crlf)
	(printout t "No existe ningun piso registrado con esa direccion" crlf)
	(retract ?modificacion-pendiente))

(defrule PISOS::eliminar-piso
	?eliminacion <- (eliminacion-pendiente ?dir)
	?inmueble <- (inmueble (direccion ?dir))
	=>
	(retract ?inmueble)
	(printout t "Piso " ?dir " eliminado." crlf)
	(retract ?eliminacion))

(defrule PISOS::eliminar-piso-error
	?eliminacion<-(eliminacion-pendiente ?dir)
	(not (inmueble (direccion ?dir)))
	=>
	(printout t "Error al intentar eliminar el piso " ?dir "." crlf)
	(printout t "No existe ningun piso registrado con esa direccion" crlf)
	(retract ?eliminacion))

(defrule PISOS::change-module
	(declare (salience -10))
	=>
	(save-facts pisos-database.clp local inmueble) ; Guarda los inmuebles anyadidos

    (printout t "Cambiando modulo: PISOS a CLIENTES" crlf)
    (focus CLIENTES)) ; A continuacion preguntamos a los clientes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defmodule CLIENTES (export ?ALL) (import MAIN ?ALL) (import PISOS ?ALL))

(deftemplate CLIENTES::cliente "Datos del cliente"
    (slot nombre            (type STRING))
    (slot zona-trabajo      (type SYMBOL))
    (slot discapacidad      (type SYMBOL)   (allowed-symbols no si))
    (slot coche             (type SYMBOL)   (allowed-symbols no si))
    (slot mascota           (type SYMBOL)   (allowed-symbols no si))
    (slot tipo-residentes   (type SYMBOL)   (allowed-symbols familia pareja amigos))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (slot ingresos-anuales  (type INTEGER)  (range 0 ?VARIABLE))
    (slot n-residentes      (type INTEGER)  (range 0 ?VARIABLE)))

(defrule CLIENTES::borrar-cliente-anterior
    ?cliente <- (cliente)
    =>
    (retract ?cliente))

;IO para leer información de clientes:

(defrule CLIENTES::preguntas
    (not (cliente))
    =>
    (printout t "Escribe tu nombre y pulsa Enter> ")
    (bind ?name (read))
    (printout t crlf "*************************************************" crlf)
    (printout t " Hola, " ?name "." crlf)
    (printout t " Bienvenido al sistema de recomendación de casas." crlf)
    (printout t " Por favor, responda a las preguntas y le diremos" crlf)
    (printout t " que casas son más adecuadas para usted." crlf)
    (printout t "*************************************************" crlf crlf)

    (bind ?trabajo      (ask-user "¿Donde trabajas?" symbol))
    (bind ?discapacidad (ask-user "¿Vas a vivir con alguien con discapacidades físicas?" yes-no))
    (bind ?coche        (ask-user "¿Tienes coche?" yes-no))
    (bind ?mascota      (ask-user "¿Tienes mascota?" yes-no))
    (bind ?tipo         (ask-user "Elige tipo de residentes (familia / pareja / amigos)" t-residentes))
    (bind ?transaccion  (ask-user "¿Quieres compra o alquiler?" t-transaccion))
    (bind ?salario      (ask-user "Introduce tu salario anual en euros: " number))
    (bind ?n-residentes (ask-user "Introduce el número de personas que vais a convivir: " number))

    (assert(cliente
        (nombre             ?name)
        (zona-trabajo       ?trabajo)
        (discapacidad       ?discapacidad)
        (mascota            ?mascota)
        (coche              ?coche)
        (tipo-residentes    ?tipo)
        (transaccion        ?transaccion)
        (ingresos-anuales   ?salario)
        (n-residentes       ?n-residentes)))
    (printout t "Introduce alquiler o compra y luego los ingresos: ")
;    (assert(cliente;TODO
;        (nombre             "Anon")
;        (zona-trabajo       madrid)
;       (discapacidad       no)
;        (mascota            no)
;        (coche              no)
;        (tipo-residentes    amigos)
;        (transaccion        (read))
;        (ingresos-anuales   (read))
;        (n-residentes       2)))

    (printout t "Cambiando modulo: CLIENTES a PREFERENCIAS" crlf);TODO
    (focus PREFERENCIAS MATCH RESULTADOS));; Ya tenemos los datos de usuario, podemos deducir sus preferencias

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule PREFERENCIAS (import CLIENTES ?ALL) (export ?ALL))

(deftemplate PREFERENCIAS::preferencias-precio
    "Información con las preferencias económicas de un cliente"
    (slot cliente       (type STRING))
    (slot precio-max    (type INTEGER))
    (slot transaccion   (type SYMBOL)   (allowed-symbols alquiler compra)))

;La idea es puntuar mejor a las casas con el nº de habitaciones en el rango
(deftemplate PREFERENCIAS::preferencias-tamanyo
    "Información con las preferencias de espacio de un cliente"
    (slot cliente           (type STRING))
    (slot habitaciones-min  (type INTEGER))
    (slot habitaciones-max  (type INTEGER))
    (slot metros-min        (type INTEGER)))

(deftemplate PREFERENCIAS::preferencias-zona
    "Información con las preferencias de zona de un cliente"
    (slot cliente    (type STRING))
    (slot zona       (type SYMBOL)))

(deftemplate PREFERENCIAS::preferencias-extras
    "Información con las preferencias de extras de un cliente"
    (slot cliente   (type STRING))
    (slot accesible (type SYMBOL) (allowed-symbols no si))
    (slot garaje    (type SYMBOL) (allowed-symbols no si)))


(defrule PREFERENCIAS::deducir-preferencias-economicas-alquiler
    "Deduce, a partir de los datos del cliente, que tipo de piso prefiere"
    (cliente
        (nombre             ?nombre)
        (ingresos-anuales   ?ingresos)
        (transaccion        alquiler))
    =>
    (printout t "Preferencias deducidas para alquiler: precio maximo= " (integer (* (/ ?ingresos 12) 0.4)) crlf);TODO
    (assert (preferencias-precio
        (cliente        ?nombre)
        (precio-max     (integer (* (/ ?ingresos 12) 0.4))) ;EL gasto en alquiler no debe superar el 40% del sueldo
        (transaccion    alquiler))))

(defrule PREFERENCIAS::deducir-preferencias-economicas-compra
    (cliente
        (nombre             ?nombre)
        (ingresos-anuales   ?ingresos)
        (transaccion        compra))
    =>
    (assert (preferencias-precio
        (cliente        ?nombre)
        (precio-max     (* ?ingresos 9)) ;El precio de la casa no debe superar el salario de 9 años
        (transaccion    compra)))
    (printout t "Preferencias deducidas para compra: precio maximo= " (* ?ingresos 9) crlf));TODO

;Esta función calcula los metros cuadrados minimos que van a necesitar los residentes
;ESta implementación es extremadamente sencilla.
(deffunction metros-necesarios (?n-residentes ?mascota ?tipo-residentes)
    (if (eq si ?mascota) then (* ?n-residentes 20) else (* ?n-residentes 15)))

(defrule PREFERENCIAS::deducir-preferencias-tamanyo-familia
    (cliente
        (nombre             ?nombre)
        (mascota            ?mascota)
        (tipo-residentes    familia)
        (n-residentes       ?n-residentes))
    =>
    (assert (preferencias-tamanyo
        (cliente            ?nombre)
        (habitaciones-max   (- ?n-residentes 1))            ;Normalmente en las familias los padres o hermanos comparten habitación
        (habitaciones-min   (div (+ 1 ?n-residentes) 2))    ;Como mucho compartir habitaciones de dos en dos
        (metros-min         (metros-necesarios ?n-residentes ?mascota familia))))
    (printout t "Familia. ";TODO
        " habitaciones maximas: "       (- ?n-residentes 1)
        " habitaciones minimas: "       (div (+ 1 ?n-residentes) 2)
        " metros cuadrados minimos: "   (metros-necesarios ?n-residentes ?mascota familia)))

(defrule PREFERENCIAS::deducir-preferencias-tamanyo-amigos
    (cliente
        (nombre             ?nombre)
        (mascota            ?mascota)
        (tipo-residentes    amigos)
        (n-residentes       ?n-residentes))
    =>
    (assert (preferencias-tamanyo
        (cliente            ?nombre)
        (habitaciones-max   ?n-residentes)  ;No hacen falta más habitaciones de los amigos que hay
        (habitaciones-min   ?n-residentes)  ;Los amigos no suelen compartir habitación
        (metros-min         (metros-necesarios ?n-residentes ?mascota amigos))))
    (printout t "Amigos.";TODO
        " habitaciones maximas: "       (- ?n-residentes 1)
        "; habitaciones minimas: "       (div (+ 1 ?n-residentes) 2)
        "; metros cuadrados minimos: "   (metros-necesarios ?n-residentes ?mascota amigos) crlf))

;Con una base de datos de las zonas y su disposición se podria crear preferencias de las zonas cercanas al trabajo.
(defrule PREFERENCIAS::deducir-preferencias-zona
    (cliente
        (nombre         ?nombre)
        (zona-trabajo   ?zona))
    =>
    (assert (preferencias-zona
        (cliente    ?nombre)
        (zona       ?zona)))
    (printout t "Zona preferida: " ?zona crlf));TODO

(defrule PREFERENCIAS::deducir-preferencias-extras
    (cliente
        (nombre         ?nombre)
        (discapacidad   ?discapacidad)
        (coche          ?coche))
    =>
    (assert (preferencias-extras
        (cliente    ?nombre)
        (accesible  ?discapacidad)
        (garaje     ?coche))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule MATCH (import PREFERENCIAS ?ALL) (import PISOS ?ALL) (export ?ALL))


(deftemplate MATCH::compatible
    (slot cliente    (type STRING))
    (slot piso       (type STRING))
    (slot puntuacion (type FLOAT)))

;TODO: al parecer salen puntuaciones negativas
;Puntua como de bajo es el precio, como de grande es y que el nº de habitaciones se acerque al nº maximo.
(deffunction MATCH::puntua (?precio-max ?precio ?metros-min ?metros ?hab ?hab-max )
    (+ (/ (- ?precio-max ?precio) 10) (- ?metros ?metros-min) (* (abs (- ?hab ?hab-max)) 10)))

(defrule MATCH::match
    (declare (salience 30)) ;Prioridad alta
    (preferencias-precio
        (cliente        ?nombre)
        (precio-max     ?precio-max)
        (transaccion    ?transaccion))
    (preferencias-tamanyo
        (cliente            ?nombre)
        (habitaciones-max   ?hab-max)
        (habitaciones-min   ?hab-min)
        (metros-min         ?metros-min))
    (preferencias-zona
        (cliente    ?nombre)
        (zona       ?zona))
    (preferencias-extras
        (cliente    ?nombre)
        (accesible  ?necesita-accesibilidad)
        (garaje     ?necesita-garaje))
    (inmueble
        (direccion          ?dir)
        (precio             ?precio)        ;restrictivo con el máximo, puntua
        (zona               ?zona)          ;restrictivo
        (metros-cuadrados   ?metros)        ;restrictivo con el minimo, puntua
        (n-habitaciones     ?hab)           ;restrictivo con el minimo, puntuable con el maximo
        (accesible          ?accesible)     ;solo restrictivo si el cliente necesita accesibilidad
        (garaje             ?garaje)        ;solo restrictivo si el cliente necesita garaje
        (transaccion        ?transaccion))  ;restrictivo

    (test (or (eq no ?necesita-accesibilidad) (eq si ?accesible)))
    (test (or (eq no ?necesita-garaje)        (eq si ?garaje)))
    (test (<= ?precio   ?precio-max))
    (test (>= ?hab      ?hab-min))              ;El minimo de habitaciones es restrictivo, el maximo se considera en la puntuacion
    (test (>= ?metros   ?metros-min))
    =>
    (printout t "piso= " ?dir " transaccion= " ?transaccion crlf)
    (assert (compatible
        (cliente    ?nombre)
        (piso       ?dir)
        (puntuacion (puntua ?precio-max ?precio ?metros-min ?metros ?hab ?hab-max)))))

(defrule MATCH::ningun-matching
    "Si no se ha encontrado ningún piso se vuelven a pedir datos al usuario."
    (declare (salience -10));Prioridad baja
    (not (compatible))
    =>
    (printout t "Lo sentimos, no se ha encontrado ningún piso para usted." crlf))



(defrule MATCH::limpiar-preferencias-precio
    (declare (salience -20))
    ?pref<-(preferencias-precio)
    =>
    ;(facts)
    ;(printout t "Eliminando preferencias-precio" crlf)
    (retract ?pref))

(defrule MATCH::limpiar-preferencias-tamanyo
    (declare (salience -21))
    ?pref<-(preferencias-tamanyo)
    =>
    ;(printout t "Eliminando preferencias-tamanyo" crlf)
    (retract ?pref))

(defrule MATCH::limpiar-preferencias-zona
    (declare (salience -22))
    ?pref<-(preferencias-zona)
    =>
    ;(printout t "Eliminando preferencias-zona" crlf)
    (retract ?pref))

(defrule MATCH::limpiar-preferencias-extras
    (declare (salience -23))
    ?pref<-(preferencias-extras)
    =>
    ;(printout t "Eliminando preferencias-extras" crlf)
    ;(facts)
    (retract ?pref))





(defmodule RESULTADOS (import MATCH ?ALL))

; IO para mostrar resultados:

(defrule RESULTADOS::init-counter
	(declare (salience +10))
	=>
	(assert(resultados-mostrados 0)))

(defrule RESULTADOS::mostrar-recomendaciones-ordenadas
    ?compatible <-(compatible (cliente ?nombre) (puntuacion ?puntuacion)  (piso ?dir))
    (not          (compatible (cliente ?nombre) (puntuacion ?puntuacion2&:(< ?puntuacion ?puntuacion2))))
    ?counter <- (resultados-mostrados ?x)
    (test(< ?x 5))
    =>
    (printout t "Recomendamos el piso " ?dir ". Puntuacion asociada " ?puntuacion "." crlf)
    (retract ?compatible)
    (retract ?counter)
    (assert(resultados-mostrados (+ ?x 1))))

(defrule RESULTADOS::clean-matches
	?compatible <- (compatible)
	(resultados-mostrados ?x)
    (test(>= ?x 5))
	=>
	(retract ?compatible))