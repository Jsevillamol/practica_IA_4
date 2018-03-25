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
	(presupuesto_minimo ?min))
(test (> ?min 1000000))
=>
(assert (perfil ?name clase-alta)))

; Mapa de edificios a perfiles para los que son adecuados

(defrule perfil-edificio-clase-alta

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
?vivienda <- (object ())
)

; Identifica los edificios que cumplen necesidades minimas Y enajan con el perfil del cliente

; Muestra los edificios que encajan con el perfil Y cumplen las necesidades minimas
; Y luego muestra los que cumplen las minimas pero no encajan con el perfil

(reset)
(run)
(facts)

; Para ejecutar en Protege
; 1. Ve a la pestana Jess
; 2. Run (batch "inmobiliaria.clp") en la barra de comandos
; 3. Ok that did not work now what
; 4. Dunno man. I dont work here.