;Dividir el programa en modulos:
;   El cliente nos da su información
;   Deducimos que tipo de inmueble busca
;   Buscamos entre nuestros inmuebles los que se ajustan
;   Los mostramos ordenados
;
; Mirar Diapositivas Control Ejecucion

(defmodule PISOS (export ?ALL))

;;; EL garaje mejor en un slot
(deftemplate PISOS::inmueble "Caracteristicas de un piso"
    (slot direccion         (type STRING))
    (slot zona              (type STRING))
    (slot precio            (type FLOAT))
    (slot metros-cuadrados  (type INTEGER))
    (slot n-habitaciones    (type INTEGER))
    (slot n-aseos           (type INTEGER))
    (slot transaccion       (type SYMBOL)   (allowed-symbols compra alquiler))
    (multislot extras       (type SYMBOL)   (allowed-symbols garaje parque-infantil)))


(defrule PISOS::compraCaro
    (inmueble
        (direccion ?piso)
        (transaccion compra)
        (precio ?precio))

    (>= precio 1000000)
    =>
    (assert (caro ?piso)))

(defrule PISOS::alquilerCaro
    (inmueble 
        (direccion ?piso)
        (transaccion alquiler)
        (precio ?precio))

    (>= precio 5000)
    =>
    (assert (caro ?piso)))

(defrule PISOS::compraBarato
	(inmueble 
       (direccion ?piso)
       (transaccion compra)
       (precio ?precio))
    (<= precio 50000)
    =>
    (assert (barato ?piso)))

(defrule PISOS::alquilerBarato
    (inmueble 
       (direccion ?piso)
       (transaccion alquiler)
       (precio ?precio))
    (<= precio 400)
    =>
    (assert (barato ?piso)))

;;;Diria que esto es redundate
(defrule PISOS::asquible
    (not (caro ?piso))
    =>
    assert((asequible ?piso)))

(defrule PISOS::tamannoGrande
    (inmueble 
       (direccion ?piso)
       (metros-cuadrados ?metros-cuadrados)
       (n-habitaciones ?n-habitaciones)
       (n-aseos ?n-aseos))
    (>= metros-cuadrados 100)
    (>= n-habitaciones 6)
    (>= n-aseos 2)
    =>
    assert((espacioso ?piso)))

(defrule PISOS::acogedor
    (not (espacioso ?piso))
    =>
    assert((acogedor ?piso)))

(defmodule CLIENTES (export ?ALL))

(deftemplate CLIENTES::cliente "Datos del cliente"
    (slot nombre                (type STRING))
    (slot zona-trabajo          (type STRING))
    (slot coche                 (type SYMBOL)   (allowed-symbols no si))
    (slot mascota               (type SYMBOL)   (allowed-symbols no si))
    (slot tipo-residentes       (type SYMBOL)   (allowed-symbols familia pareja amigos))
    (slot transaccion-deseada   (type SYMBOL)   (allowed-symbols compra alquiler))
    (slot ingresos-anuales      (type INTEGER)  (range 0 ?VARIABLE))
    (slot n-residentes          (type INTEGER)  (range 0 ?VARIABLE)))

(defrule CLIENTES::numero_bajo
    (cliente
        (nombre ?cliente)
        (n-residentes ?n-residentes))

    (< ?n-residentes 4)
    =>
    assert((pocos ?cliente)))

(defrule CLIENTES::numero_alto
    (not (pocos ?cliente))
    =>
    assert((numerosos ?cliente)))

(defrule CLIENTES::poder_adquisitivo_alto
    (cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos))

    (>= ?ingresos 30000)
    =>
    assert((clase-alta ?cliente)))

(defrule CLIENTES::poder_adquisitivo_bajo
	(cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos))

    (<= ?ingresos 1000)
    =>
    (clase-baja ?cliente))

(defrule CLIENTES::poder_adquisitivo_medio
    (not (clase-alta ?cliente))
    (not (clase-baja ?cliente))
    =>
    (clase-media ?cliente))
 

(defmodule ENCONTRAR-PISO (import MAIN ?ALL))

(defrule ENCONTRAR-PISO::recomendar
   (inmueble 
       (direccion ?piso) 
       (zona ?zona)
       (transaccion ?transaccion)
       (extras $?extras))
    
   (cliente
        (nombre ?cliente)
        (tipo-residentes ?tipo-residentes)
        (zona-trabajo ?zona)
        (transaccion-deseada ?transaccion))
;;; Los ors y ands hay que evitarlos: or -> 2 reglas, and -> una condición detras de otra
    ; Restricciones usando las inferencias anteriores
    (or
        (and (clase-baja ?cliente) (barato ?piso))
        (and (clase-alta ?cliente) (caro ?piso))
        (and (clase-media) (asequible ?piso)))
    (or
        (and (pocos ?cliente) (acogedor ?piso))
        (and (numerosos ?cliente) (espacioso ?piso)))

   ; Restricciones cualitativas
   (test (or (neq ?coche si) (member garaje $?extras)))
   (test (or (neq ?tipo-residentes familia) (member parque-infantil $?extras)))

   =>
   (assert (recomendacion ?piso ?cliente)))


;; DATABASE


(deffacts MAIN::inmuebles-database 
    (inmueble (direccion "C/Colón") (zona "centro") (precio 100.0) (n-habitaciones 3) (tipo piso)))

(deffacts MAIN::clientes-database
    (cliente (nombre "Jose") (ingresos-anuales 12000) (n-residentes 3) (tipo-residentes familia) (zona-trabajo "centro") (coche si)))
