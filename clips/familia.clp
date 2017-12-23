(deffacts inicio
    (dd juan maria rosa m)
    (dd juan maria luis h)
    (dd jose laura pilar m)
    (dd luis pilar miguel h)
    (dd miguel isabel jaime h)
	(dd pedro rosa pablo h)
	(dd pedro rosa ana m)
)

(defrule padre
    (dd ?x ? ?y ?)
    =>
    (assert (padre ?x ?y))
)

(defrule madre
    (dd ? ?x ?y ?)
    =>
    (assert (madre ?x ?y))
)

(defrule hijo
    (or (dd ?x ? ?y h) (dd ? ?x ?y h))
    =>
    (assert (hijo ?y ?x))
)

(defrule hija
    (or (dd ?x ? ?y m) (dd ? ?x ?y m))
    =>
    (assert (hija ?y ?x))
)

(defrule hermano
    (dd ?x ?y ?a ?)
    (dd ?x ?y ?b h)
	(test (neq ?a ?b))
    =>
    (assert (hermano ?b ?a))
)

(defrule hermana
    (dd ?x ?y ?a ?)
    (dd ?x ?y ?b m)
	(test (neq ?a ?b))
    =>
    (assert (hermana ?b ?a))
)

(defrule abuelo
	(padre ?ab ?prog)
	(or (padre ?prog ?hi)
        (madre ?prog ?hi)
    )
    =>
    (assert (abuelo ?ab ?hi))
)

(defrule abuela
	(madre ?ab ?prog)
	(or (padre ?prog ?hi)
        (madre ?prog ?hi)
    )
    =>
    (assert (abuela ?ab ?hi))
)

(defrule primo
    (hijo ?p ?tie)
	(or (hermano ?tie ?prog) (hermana ?tie ?prog))
	(or (padre ?prog ?x) (madre ?prog ?x))
    =>
    (assert (primo ?p ?x))
)

(defrule prima
    (hija ?p ?tie)
	(or (hermano ?tie ?prog) (hermana ?tie ?prog))
	(or (padre ?prog ?x) (madre ?prog ?x))
    =>
    (assert (prima ?p ?x))
)

(defrule ascendiente
    (or
        (or (padre ?x ?y) (madre ?x ?y))
        (and (ascendiente ?x ?z) (ascendiente ?z ?y))
    )
    =>
    (assert (ascendiente ?x ?y))
)
