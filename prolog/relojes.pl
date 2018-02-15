
% estado([ParteSuperior1, ParteInferior1], [ParteSuperior2, ParteInferior2])

% nodo(estado, coste, solucion_parcial)

% Nodo inicial
nodo(estado([7,0],[11,0]), 0, [], []).

% Busqueda
resolver(Coste, Solucion):-
	busquedaGraphDFS([nodo(estado([7,0],[11,0]), 0, [])], [], Coste, Solucion).

% Goal test
busquedaGraphDFS([nodo(estado([U1,L1], [U2,L2]), Coste, Solucion) | _], _, Coste, Solucion):-
	U1 = 3 ; L1 = 3 ; U2 = 3; L2 = 3.

% Node expansion
busquedaGraphDFS([NodoActual | Frontera], Visitados, Coste, Solucion) :-
	write("Expandiendo "), write(NodoActual), nl,
	hijos(NodoActual, Hijos), % genera los hijos del nodo actual
	%write("Hijos del nodo actual: "), write(Hijos), nl,
	NodoActual = nodo(EstadoActual, _, _),
	filtrar(Hijos, [EstadoActual | Visitados], HijosNoExplorados),
	append(HijosNoExplorados, Frontera, NuevaFrontera),
	%write("Nueva frontera "), write(NuevaFrontera), nl, nl,
	busquedaGraphDFS(NuevaFrontera, [EstadoActual | Visitados], Coste, Solucion).

% Descendientes directos de un nodo
hijos(NodoActual, [Giro1, Giro2, Esperar]) :-
	aplicar(giro1, NodoActual, Giro1),
	aplicar(giro2, NodoActual, Giro2),
	aplicar(esperar, NodoActual, Esperar).

% Movimientos permitidos
% aplicar(operador, nodo, resultado)

% Giro1
aplicar(
	giro1,
	nodo(estado([U1,L1], [U2,L2]), Coste, Solucion_parcial),
	nodo(estado([L1,U1], [U2,L2]), Coste, [giro1 | Solucion_parcial])
	).

% Giro2
aplicar(
	giro2,
	nodo(estado([U1,L1], [U2,L2]), Coste, Solucion_parcial),
	nodo(estado([U1,L1], [L2,U2]), Coste, [giro2 | Solucion_parcial])
	).

% Esperar
aplicar(
	esperar, 
	nodo(estado([U1_old,L1_old], [U2_old,L2_old]), Coste_old, Solucion_parcial),
	nodo(estado([0,L1], [U2,L2]), Coste, [esperar | Solucion_parcial])
) :-
	U1_old =< U2_old,
	L1 is L1_old + U1_old,
	U2 is U2_old - U1_old,
	L2 is L2_old + U1_old,
	Coste is Coste_old + U1_old.

aplicar(
	esperar, 
	nodo(estado([U1_old,L1_old], [U2_old,L2_old]), Coste_old, Solucion_parcial),
	nodo(estado([U1,L1], [0,L2]), Coste, [esperar | Solucion_parcial])
) :-
	U1_old > U2_old,
	U1 is U1_old - U2_old,
	L1 is L1_old + U2_old,
	L2 is L2_old + U2_old,
	Coste is Coste_old + U2_old.

% Util

% filtrar([Nodos], [Estados], Resultado)
filtrar([], _, []).

filtrar([Nodo | Nodos], Visitados, Resultado) :-
	Nodo = nodo(Estado, _, _),
	member(Estado, Visitados),
	% !, //Casi seguro de que este corte esta bien puesto, y nos ahorra tener que usar /+ en el siguiente caso
	filtrar(Nodos, Visitados, Resultado).

filtrar([Nodo | Nodos], Visitados, [Nodo | Resultado]) :-
	Nodo = nodo(Estado, _, _),
	\+ member(Estado, Visitados),
	filtrar(Nodos, Visitados, Resultado).