;Dividir el programa en modulos:
;   El cliente nos da su información
;   Deducimos que tipo de inmueble busca
;   Buscamos entre nuestros inmuebles los que se ajustan
;   Los mostramos ordenados
;
; Mirar Diapositivas Control Ejecucion

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::inmueble "Caracteristicas de un piso"
   (slot direccion
       (type STRING)) 
   (slot zona
       (type STRING))  ; Incluso podrían ser simbolos predefinidos (como idealista.com)
   (slot tipo-transaccion
       (type SYMBOL)
       (allowed-symbols compra alquiler)) 
   (slot precio
       (type FLOAT))  
   (slot metros-cuadrados
       (type INTEGER))
   (slot n-habitaciones 
        (type INTEGER)) 
   (slot n-aseos
        (type INTEGER))
   (slot tipo
        (type SYMBOL)
        (allowed-symbols piso apartamento duplex chalet adosado atico planta-baja estudio loft finca-rustica))
   (slot estado
        (type SYMBOL)
        (allowed-symbols nuevo segunda-mano reformado a-reformar))
   (slot garaje (type SYMBOL) (allowed-symbols no si))
   (multislot extras
        (type SYMBOL)
        (allowed-symbols trastero terraza jardin piscina parque-infantil portero pistas-deportivas)))

(deftemplate MAIN::cliente "Datos del cliente"
    (slot nombre (type STRING))
    (slot ingresos-anuales
        (type INTEGER)
        (range 0 ?VARIABLE))
    (slot n-residentes
        (type INTEGER)
        (range 0 ?VARIABLE))
    (slot tipo-residentes
        (type SYMBOL)
        (allowed-symbols familia pareja amigos))
    (slot zona-trabajo ;Esto podría cambiarse a multislot zonas-trabajo para más residentes pero habría que hacer reglas de cercania de zonas
        (type STRING))
    (slot coche (type SYMBOL) (allowed-symbols no si))
    (slot mascota (type SYMBOL) (allowed-symbols no si))
    (slot tipo-transaccion-deseada
       (type SYMBOL)
       (allowed-symbols compra alquiler)))

(deftemplate MAIN::preferencias "Preferencias del cliente"
   (slot nombre
       (type STRING))
   (slot zona-deseada
       (type STRING))
   (slot tipo-transaccion-deseada
       (type SYMBOL)
       (allowed-symbols compra alquiler))
   (slot precio-minimo
       (type FLOAT))
   (slot precio-maximo
       (type FLOAT))
   (slot metros-cuadrados-minimos
       (type INTEGER))
   (slot n-habitaciones-minimo
       (type INTEGER))
   (slot n-aseos-minimo
       (type INTEGER))
   (multislot extras-deseados
       (type SYMBOL)
       (allowed-symbols garaje parque-infantil NULL)) ; el valor NULL se usa para no añadir un extra cuando una condicion es falsa
  )

(defmodule DEDUCCION (import MAIN ?ALL))
       
(defrule DEDUCCION::deducir-preferencias
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
  =>
    (assert (preferencias 
       (nombre ?cliente)
       (zona-deseada ?zona-trabajo)
       (tipo-transaccion-deseada ?tipo-transaccion)
       (precio-minimo (* ?ingresos 10))
       (precio-maximo (* ?ingresos 40))
       (metros-cuadrados-minimos (* ?n-residentes 20))
       (n-habitaciones-minimo (+ ?n-residentes 2))
       (n-aseos-minimo (if (>= ?n-residentes 4) then 2 else 1))

       (extras-deseados 
          (if (eq ?coche si) then garaje else NULL)
          (if (eq ?tipo-residentes familia) then parque-infantil else NULL)
       )

    ))
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
       (tipo ?tipo)
       (estado ?estado)
       (extras $?extras)
    )
    
   (preferencias 
       (nombre ?cliente)
       (zona-deseada ?zona)
       (tipo-transaccion-deseada ?tipo-transaccion)
       (precio-minimo ?precio-minimo)
       (precio-maximo ?precio-maximo)
       (metros-cuadrados-minimos ?metros-cuadrados-minimos)
       (n-habitaciones-minimo ?n-habitaciones-minimo)
       (n-aseos-minimo ?n-aseos-minimo)
       (extras-deseados $?extras-deseados)
    )

   ; Comprobaciones numericas
   (test (>= ?precio ?precio-minimo))
   (test (<= ?precio ?precio-maximo))
   (test (>= ?metros-cuadrados ?metros-cuadrados-minimos))
   (test (>= ?n-habitaciones ?n-habitaciones-minimo))
   (test (>= ?n-aseos ?n-aseos-minimo))

   ; Restricciones cualitativas
   (test (subsetp ?extras-deseados ?extras))

   =>
   (assert (recomendacion ?piso ?cliente))
  )
  
;; DATABASE

  (assert (inmueble (direccion "C/Colón") (zona "centro") (precio 100.0) (n-habitaciones 3) (tipo piso)))

  (assert (cliente (nombre "Jose") (ingresos-anuales 12000) (n-residentes 3) (tipo-residentes familia) (zona-trabajo "centro") (coche si)))
