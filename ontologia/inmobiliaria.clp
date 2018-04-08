(mapclass Cliente)
(mapclass Distrito)
(mapclass Vivienda)

; Mapa de clientes a perfiles

(defrule perfil-cliente-clase-alta
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n)
	(presupuesto_maximo ?max)
	(presupuesto_minimo ?min&:(> ?min 1000000)))
=>
(assert (perfil-cliente ?name clase-alta)))

(defrule perfil-cliente-clase-baja
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n)
	(presupuesto_maximo ?max:&(< ?max 10000))
	(presupuesto_minimo ?min))
=>
(assert (perfil-cliente ?name clase-baja)))

(defrule perfil-cliente-soltero
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n&:(eq ?n 1))
	(presupuesto_maximo ?max)
	(presupuesto_minimo ?min))
=>
(assert (perfil-cliente ?name soltero)))

(defrule perfil-cliente-pareja
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n&:(eq ?n 2))
	(presupuesto_maximo ?max)
	(presupuesto_minimo ?min))
=>
(assert (perfil-cliente ?name pareja)))

(defrule perfil-familia
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n&:(or (eq ?n 3) (eq ?n 4)))
	(presupuesto_maximo ?max)
	(presupuesto_minimo ?min))
=>
(assert (perfil-cliente ?name familia)))

(defrule perfil-familia-numerosa
?cliente <- (object (is-a Cliente) 
	(nombre ?name) 
	(discapacidad? ?discapacity)
	(distrito_deseado ?desired_district)
	(n_miembros_familia ?n&:(> ?n 4))
	(presupuesto_maximo ?max)
	(presupuesto_minimo ?min))
=>
(assert (perfil-cliente ?name soltero)))

; Mapa de edificios a perfiles para los que son adecuados

(defrule perfil-vivienda-clase-alta
	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? True)
		(cocina_independiente? True)
		(distrito ?dist)
		(jardin True)
		(metros_cuadrados ?square_meters)
		(n_baños ?n_baths&:(> ?n_baths 1))
		(n_dormitorios ?n_dorms)
		(plazas_garaje ?n_garage&:(> ?n_garage 1))
		(precio ?price)
		(vendido_por ?seller)
		)
	=>
	(assert (perfil-vivienda ?dir clase-alta))
)

(defrule perfil-vivienda-clase-baja
	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?dist)
		(jardin ?garden)
		(metros_cuadrados ?square_meters)
		(n_baños ?n_baths)
		(n_dormitorios ?n_dorms)
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	=>
	(assert (perfil-vivienda ?dir clase-baja))
)

(defrule perfil-vivienda-soltero
	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?dist)
		(jardin ?garden)
		(metros_cuadrados ?square_meters&:(< ?square_meters 200))
		(n_baños ?n_baths&:(eq ?n_baths 1))
		(n_dormitorios ?n_dorms&:(<= ?n_dorms 2))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	=>
	(assert (perfil-vivienda ?dir soltero))
)

(defrule perfil-vivienda-familia
	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?dist)
		(jardin ?garden)
		(metros_cuadrados ?square_meters&:(> ?square_meters 100))
		(n_baños ?n_baths&:(>= ?n_baths 1))
		(n_dormitorios ?n_dorms&:(>= ?n_dorms 2))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	=>
	(assert (perfil-vivienda ?dir familia))
)

(defrule perfil-vivienda-familia-numerosa
	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?dist)
		(jardin ?garden)
		(metros_cuadrados ?square_meters&:(> ?square_meters 200))
		(n_baños ?n_baths&:(>= ?n_baths 2))
		(n_dormitorios ?n_dorms&:(>= ?n_dorms 3))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	=>
	(assert (perfil-vivienda ?dir familia-numerosa))
)

; Identifica los edificios que cumplen las necesidades minimas
(defrule necesidades-minimas

	?cliente <- (object (is-a Cliente) 
		(nombre ?name) 
		(discapacidad? ?discapacity)
		(distrito_deseado ?desired_district)
		(n_miembros_familia ?n)
		(presupuesto_maximo ?max)
		(presupuesto_minimo ?min))

	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?desired_district)
		(jardin ?garden)
		(metros_cuadrados ?square_meters)
		(n_baños ?n_baths)
		(n_dormitorios ?n_dorms)
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(test (and (<= ?min ?price) (<= ?price ?max)))
=>
	(assert (adecuado ?name ?dir))
)

; Identifica los edificios que cumplen necesidades minimas Y enajan con el perfil del cliente

(defrule recomendado
	(adecuado ?name ?dir)
	?cliente <- (object (is-a Cliente) 
		(nombre ?name) 
		(discapacidad? ?discapacity)
		(distrito_deseado ?desired_district)
		(n_miembros_familia ?n)
		(presupuesto_maximo ?max)
		(presupuesto_minimo ?min))

	?vivienda <- (object (is-a Vivienda)
		(direccion ?dir)
		(chimenea? ?chimney)
		(cocina_independiente? ?kitchen)
		(distrito ?desired_district)
		(jardin ?garden)
		(metros_cuadrados ?square_meters)
		(n_baños ?n_baths)
		(n_dormitorios ?n_dorms)
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(perfil-cliente ?name ?perfil)
	(perfil-vivienda ?dir ?perfil)
=>
	(assert(recomendado ?name ?dir))
)

; Muestra los edificios que encajan con el perfil Y cumplen las necesidades minimas

(defrule mostrar-recomendaciones
	?recomendacion<-(recomendado ?name ?dir)
=>
	(printout t "Recomendamos el piso " ?dir " al cliente " ?name)
	(retract ?recomendacion)
)

; Y luego muestra los que cumplen las minimas pero no encajan con el perfil

(defrule mostrar-adecuados
	?recomendacion<-(adecuado ?name ?dir)
=>
	(printout t "El piso " ?dir " satisface las necesidades minimas del cliente " ?name)
	(retract ?recomendacion)
)

(reset)
(run)
(facts)

; Para ejecutar en Protege
; 1. Ve a la pestana Jess
; 2. Run (batch "inmobiliaria.clp") en la barra de comandos
; 3. Ok that did not work now what
; 4. Dunno man. I dont work here.