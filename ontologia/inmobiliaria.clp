(mapclass Cliente)
(mapclass Distrito)
(mapclass Vivienda)
(mapclass Inmobiliaria)

; Mapa de clientes a perfiles

(defrule perfil-cliente-clase-alta
(object (is-a Cliente) 
	(nombre ?name)
	(presupuesto_minimo ?min&:(> ?min 1000000)))
=>
(assert (perfil-cliente ?name clase-alta)))

(defrule perfil-cliente-clase-baja
(object (is-a Cliente) 
	(nombre ?name)
	(presupuesto_maximo ?max&:(< ?max 10000)))
=>
(assert (perfil-cliente ?name clase-baja)))

(defrule perfil-cliente-soltero
(object (is-a Cliente) 
	(nombre ?name)
	(n_miembros_familia ?n&:(eq ?n 1)))
=>
(assert (perfil-cliente ?name soltero)))

(defrule perfil-cliente-pareja
(object (is-a Cliente) 
	(nombre ?name)
	(n_miembros_familia ?n&:(eq ?n 2)))
=>
(assert (perfil-cliente ?name pareja)))

(defrule perfil-familia
(object (is-a Cliente) 
	(nombre ?name)
	(n_miembros_familia ?n&:(or (eq ?n 3) (eq ?n 4)))
	(presupuesto_maximo ?max))
=>
(assert (perfil-cliente ?name familia)))

(defrule perfil-familia-numerosa
(object (is-a Cliente) 
	(nombre ?name)
	(n_miembros_familia ?n&:(> ?n 4))
	(presupuesto_maximo ?max))
=>
(assert (perfil-cliente ?name soltero)))




; Mapa de edificios a perfiles para los que son adecuados





(defrule perfil-vivienda-clase-alta
(object (is-a ?tipo-vivienda)
		(direccion ?dir)
		(chimenea? TRUE)
		(cocina_independiente? TRUE)
		(jardin? TRUE)
		(n_baños ?n_baths&:(> ?n_baths 1))
		(plazas_garaje ?n_garage&:(> ?n_garage 1)))
	(test (superclassp Vivienda ?tipo-vivienda))
	=>
	(assert (perfil-vivienda ?dir clase-alta))
)

(defrule perfil-vivienda-clase-baja
(object (is-a ?tipo-vivienda)
		(direccion ?dir)
		(jardin? ?garden)
		(metros_cuadrados ?square_meters)
		(n_baños ?n_baths)
		(n_dormitorios ?n_dorms)
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(test (superclassp Vivienda ?tipo-vivienda))
	=>
	(assert (perfil-vivienda ?dir clase-baja))
)

(defrule perfil-vivienda-soltero
(object (is-a ?tipo-vivienda)
		(direccion ?dir)
		(jardin? ?garden)
		(metros_cuadrados ?square_meters&:(< ?square_meters 200))
		(n_baños ?n_baths&:(eq ?n_baths 1))
		(n_dormitorios ?n_dorms&:(<= ?n_dorms 2))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(test (superclassp Vivienda ?tipo-vivienda))
	=>
	(assert (perfil-vivienda ?dir soltero))
)

(defrule perfil-vivienda-familia
(object (is-a ?tipo-vivienda)
		(direccion ?dir)
		(jardin? ?garden)
		(metros_cuadrados ?square_meters&:(> ?square_meters 100))
		(n_baños ?n_baths&:(>= ?n_baths 1))
		(n_dormitorios ?n_dorms&:(>= ?n_dorms 2))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(test (superclassp Vivienda ?tipo-vivienda))
	=>
	(assert (perfil-vivienda ?dir familia))
)

(defrule perfil-vivienda-familia-numerosa
(object (is-a ?tipo-vivienda)
		(direccion ?dir)
		(jardin? ?garden)
		(metros_cuadrados ?square_meters&:(> ?square_meters 200))
		(n_baños ?n_baths&:(>= ?n_baths 2))
		(n_dormitorios ?n_dorms&:(>= ?n_dorms 3))
		(plazas_garaje ?n_garage)
		(precio ?price)
		(vendido_por ?seller)
		)
	(test (superclassp Vivienda ?tipo-vivienda))
	=>
	(assert (perfil-vivienda ?dir familia-numerosa))
)



; Identifica los edificios que cumplen las necesidades minimas
(defrule necesidades-minimas

	(object (is-a Cliente)
		(OBJECT ?cliente)
		(nombre ?name)
		(distrito_deseado ?desired_district)
		(presupuesto_maximo ?max)
		(presupuesto_minimo ?min))

	(object (is-a ?tipo-vivienda)
		(OBJECT ?vivienda)
		(direccion ?dir)
		(distrito ?desired_district)
		(precio ?price))
	
	(test (superclassp Vivienda ?tipo-vivienda))
	
	(test (and (<= ?min ?price) (<= ?price ?max)))
	(test (not (member$ ?vivienda (slot-get ?cliente requisitos_minimos))))
=>
	(printout t "Something2")
	(slot-insert$ ?cliente requisitos_minimos 1 ?vivienda)
)

; Identifica los edificios que cumplen necesidades minimas Y enajan con el perfil del cliente

(defrule recomendado
	(adecuado ?name ?dir)
	(object (is-a Cliente)
		(OBJECT ?cliente)
		(nombre ?name))

	(object (is-a ?tipo-vivienda)
		(OBJECT ?vivienda)
		(direccion ?dir))
	(test (superclassp Vivienda ?tipo-vivienda))
	(test (not (member$ ?vivienda (recomendaciones ?cliente))))
	
	(test (member$ ?vivienda (slot-get ?cliente requisitos_minimos)))
	(printout t "Something2")
	
	(perfil-cliente ?name ?perfil)
	(perfil-vivienda ?dir ?perfil)
=>
    
	(slot-insert$ ?cliente recomendaciones 1 ?vivienda)
	(Slot-delete$ ?cliente requisitos_minimos ?index (member$ ?vivienda (slot-get ?cliente requisitos_minimos)))
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
; 2. Run (batch "/home/david/Data/code/practicas_IA_4/ontologia/inmobiliaria.clp") en la barra de comandos
