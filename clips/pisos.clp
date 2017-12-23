(deftemplate inmueble "Caracteristicas de un piso"
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
   (slot tipo
        (type SYMBOL)
        (allowed-symbols piso apartamento duplex chalet adosado atico planta-baja estudio loft finca-rustica)
       )
   (slot estado
        (type SYMBOL)
        (allowed-symbols nuevo segunda-mano reformado a-reformar)
       )
   (multislot extras
        (type SYMBOL)
        (allowed-symbols trastero garaje terraza jardin piscina parque-infantil portero pistas-deportivas amueblado calefaccion aire-acondicionado)
       )
  )

(deftemplate cliente "Preferencias del cliente"
   (slot nombre
       (type STRING)
      )
   (slot zona-deseada
       (type STRING)
      )
   (slot tipo-transaccion-deseada
       (type SYMBOL)
       (allowed-symbols compra alquiler)
      )
   (slot precio-minimo
       (type FLOAT)
      )
   (slot precio-maximo
       (type FLOAT)
      )
   (slot metros-cuadrados-minimos
       (type INTEGER)
      )
   (slot n-habitaciones-minimo
       (type INTEGER)
      )
   (slot n-aseos-minimo
       (type INTEGER)
      )
   (multislot tipos-admitidos
       (type SYMBOL)
       (allowed-symbols piso apartamento duplex chalet adosado atico planta-baja estudio loft finca-rustica)
      )
   (multislot estados-admitidos
       (type SYMBOL)
       (allowed-symbols nuevo segunda-mano reformado a-reformar)
      )
   (multislot extras-deseados
       (type SYMBOL)
       (allowed-symbols trastero garaje terraza jardin piscina parque-infantil portero pistas-deportivas amueblado calefaccion aire-acondicionado)
      )
  )

(defrule recomendar
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
   (cliente 
       (nombre ?cliente)
       (zona-deseada ?zona-deseada)
       (tipo-transaccion-deseada ?tipo-transaccion-deseada)
       (precio-minimo ?precio-minimo)
       (precio-maximo ?precio-maximo)
       (metros-cuadrados-minimos ?metros-cuadrados-minimos)
       (n-habitaciones-minimo ?n-habitaciones-minimo)
       (n-aseos-minimo ?n-aseos-minimo)
       (tipos-admitidos $?tipos-admitidos)
       (estados-admitidos $?estados-admitidos)
       (extras-deseados $?extras-deseados)
      )
   ; Aplicacion de filtros
   (test (eq ?zona ?zona-deseada))
   (test (eq ?tipo-transaccion ?tipo-transaccion-deseada))
   (test (>= ?precio ?precio-minimo))
   (test (<= ?precio ?precio-maximo))
   (test (>= ?metros-cuadrados ?metros-cuadrados-minimos))
   (test (>= ?n-habitaciones ?n-habitaciones-minimo))
   (test (>= ?n-aseos ?n-aseos-minimo))
   ; TODO add multislot checks
   =>
   (assert (recomendacion ?piso ?cliente))
  )
