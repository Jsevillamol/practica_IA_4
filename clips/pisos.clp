;Dividir el programa en modulos:
;   El cliente nos da su información
;   Deducimos que tipo de inmueble busca
;   Buscamos entre nuestros inmuebles los que se ajustan
;   Los mostramos ordenados
;
; Mirar Diapositivas Control Ejecucion

(defmodule PISOS (export ?ALL))

(deftemplate PISOS::inmueble "Caracteristicas de un piso"
   (slot direccion
       (type STRING)
   ) 
   (slot zona
       (type STRING)
   )
   (slot tipo-transaccion
       (type SYMBOL)
       (allowed-symbols compra alquiler)
   ) 
   (slot precio
       (type FLOAT)
   )  
   (slot metros-cuadrados
       (type INTEGER)
   )
   (slot n-habitaciones 
        (type INTEGER)
   ) 
   (slot n-aseos
        (type INTEGER)
   )
   (multislot extras
        (type SYMBOL)
        (allowed-symbols garaje parque-infantil)
   )
)

(defrule PISOS::inmuebleCaro
	(inmueble 
       (direccion ?piso) 
       (zona ?zona)
       (tipo-transaccion ?tipo-transaccion)
       (precio ?precio)
       (metros-cuadrados ?metros-cuadrados)
       (n-habitaciones ?n-habitaciones)
       (n-aseos ?n-aseos)
       (extras $?extras)
    )
    (or 
    	(and (>= precio 1000000) (eq ?tipo-transaccion compra))
    	(and (>= precio 5000) (eq ?tipo-transaccion alquiler))
    )
    =>
    assert((caro ?piso))
)

(defrule PISOS::inmuebleBarato
	(inmueble 
       (direccion ?piso) 
       (zona ?zona)
       (tipo-transaccion ?tipo-transaccion)
       (precio ?precio)
       (metros-cuadrados ?metros-cuadrados)
       (n-habitaciones ?n-habitaciones)
       (n-aseos ?n-aseos)
       (extras $?extras)
    )
    (or 
    	(and (<= precio 50000) (eq ?tipo-transaccion compra))
    	(and (<= precio 400) (eq ?tipo-transaccion alquiler))
    )
    =>
    assert((barato ?piso))
)

(defrule PISOS::asquible
	(not (caro ?piso))
	(not (caro ?piso))
	=>
	assert((asequible ?piso))
)

(defrule PISOS::tamannoGrande
	(inmueble 
       (direccion ?piso) 
       (zona ?zona)
       (tipo-transaccion ?tipo-transaccion)
       (precio ?precio)
       (metros-cuadrados ?metros-cuadrados)
       (n-habitaciones ?n-habitaciones)
       (n-aseos ?n-aseos)
       (extras $?extras)
    )
    (>= metros-cuadrados 100)
    (>= n-habitaciones 6)
    (>= n-aseos 2)
    =>
    assert((espacioso ?piso))
)

(defrule PISOS::acogedor
	(not (espacioso ?piso))
	=>
	assert((acogedor ?piso))
)

(defmodule CLIENTES (export ?ALL))

(deftemplate CLIENTES::cliente "Datos del cliente"
    (slot nombre (type STRING))
    (slot ingresos-anuales
        (type INTEGER)
        (range 0 ?VARIABLE)
    )
    (slot n-residentes
        (type INTEGER)
        (range 0 ?VARIABLE)
    )
    (slot tipo-residentes
        (type SYMBOL)
        (allowed-symbols familia pareja amigos)
    )
    (slot zona-trabajo 
        (type STRING)
    )
    (slot coche (type SYMBOL) (allowed-symbols no si))
    (slot mascota (type SYMBOL) (allowed-symbols no si))
    (slot tipo-transaccion-deseada
       (type SYMBOL)
       (allowed-symbols compra alquiler)
    )
)

(defrule CLIENTES::numero_bajo
	(cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos)
        (n-residentes ?n-residentes)
        (tipo-residentes ?tipo-residentes)
        (zona-trabajo ?zona-trabajo)
        (coche ?coche)
        (mascota ?mascota)
        (tipo-transaccion-deseada ?tipo-transaccion)
    )
    (< ?n-residentes 4)
    =>
    assert((pocos ?cliente))
)

(defrule CLIENTES::numero_alto
	(not (pocos ?cliente))
    =>
    assert((numerosos ?cliente))
)

(defrule CLIENTES::poder_adquisitivo_alto
	(cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos)
        (n-residentes ?n-residentes)
        (tipo-residentes ?tipo-residentes)
        (zona-trabajo ?zona-trabajo)
        (coche ?coche)
        (mascota ?mascota)
        (tipo-transaccion-deseada ?tipo-transaccion)
    )
    (>= ?ingresos 30000)
    =>
    assert((clase-alta ?cliente))
)

(defrule CLIENTES::poder_adquisitivo_bajo
	(cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos)
        (n-residentes ?n-residentes)
        (tipo-residentes ?tipo-residentes)
        (zona-trabajo ?zona-trabajo)
        (coche ?coche)
        (tipo-transaccion-deseada ?tipo-transaccion)
    )
    (<= ?ingresos 1000)
    =>
    (clase-baja ?cliente)
)

(defrule CLIENTES::poder_adquisitivo_medio
	(not (clase-alta ?cliente))
	(not (clase-baja ?cliente))
	=>
	(clase-media ?cliente)
)
    
       
(defmodule ENCONTRAR-PISO (import MAIN ?ALL))
       
(defrule ENCONTRAR-PISO::recomendar
   (inmueble 
       (direccion ?piso) 
       (zona ?zona)
       (tipo-transaccion ?tipo-transaccion)
       (precio ?precio)
       (metros-cuadrados ?metros-cuadrados)
       (n-habitaciones ?n-habitaciones)
       (n-aseos ?n-aseos)
       (extras $?extras)
    )
    
   (cliente
        (nombre ?cliente)
        (ingresos-anuales ?ingresos)
        (n-residentes ?n-residentes)
        (tipo-residentes ?tipo-residentes)
        (zona-trabajo ?zona-trabajo)
        (coche ?coche)
        (tipo-transaccion-deseada ?tipo-transaccion)
    )

    ; Restricciones usando las inferencias anteriores
    (or 
   		(and (clase-baja ?cliente) (barato ?piso))
   		(and (clase-alta ?cliente) (caro ?piso))
   		(and (clase-media) (asequible ?piso))
   	)
   	(or 
   		(and (pocos ?cliente) (acogedor ?piso))
   		(and (numerosos ?cliente) (espacioso ?piso))
   	)
   

   ; Restricciones cualitativas
   (test (eq ?tipo-transaccion ?tipo-transaccion-deseada))
   (test (eq ?zona ?zona-trabajo))
   (test (or (neq ?coche si) (member garaje $?extras))
   (test (or (neq ?tipo-residentes familia) (member parque-infantil $?extras))

   =>
   (assert (recomendacion ?piso ?cliente))
)
  
;; DATABASE


(deffacts MAIN::inmuebles-database 
  (inmueble (direccion "C/Colón") (zona "centro") (precio 100.0) (n-habitaciones 3) (tipo piso))
)

(deffacts MAIN::clientes-database
  (cliente (nombre "Jose") (ingresos-anuales 12000) (n-residentes 3) (tipo-residentes familia) (zona-trabajo "centro") (coche si))
)