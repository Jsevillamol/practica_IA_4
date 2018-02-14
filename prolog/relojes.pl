
% estado([ParteSuperior1, ParteInferior1], [ParteSuperior2, ParteInferior1])

% nodo(estado, coste, solucion_parcial)

% Nodo inicial
nodo(estado([7,0],[11,0]), 0, [], []).

% Movimientos permitidos

% Giro1
nodo(estado([L1,U1], [U2,L2]), Coste, [giro1 | Solucion_parcial]) :-
	nodo(estado([U1,L1], [U2,L2]), Coste, Solucion_parcial).

% Giro2
nodo(estado([U1,L1], [L2,U2]), Coste, [giro2 | Solucion_parcial]) :-
	nodo(estado([U1,L1], [U2,L2]), Coste, Solucion_parcial).

% Wait
nodo(estado([0,L1], [U2,L2]), Coste, [esperar | Solucion_parcial]) :-
	nodo(estado([U1_old,L1_old], [U2_old,L2_old]), Coste_old, Solucion_parcial),
	U1_old < U2_old,
	L1 is L1_old + U1_old,
	U2 is U2_old - U1_old,
	L2 is L2_old + U1_old,
	Coste is Coste_old + U1_old.

nodo(estado([U1,L1], [0,L2]), Coste, [esperar | Solucion_parcial]) :-
	nodo(estado([U1_old,L1_old], [U2_old,L2_old]), Coste_old, Solucion_parcial),
	U1_old > U2_old,
	U1 is U2_old - U2_old,
	L1 is L1_old + U2_old,
	L2 is L2_old + U2_old,
	Coste is Coste_old + U2_old.

% Busqueda
resolver(EstadoInicial, EstadoFinal, Coste, Solucion):-
	busquedaGraphDFS(EstadoInicial, nodo(EstadoFinal, Coste, Solucion), PorVisitar, Visitados).

busquedaGraphDFS(EstadoInicial, NodoActual, PorVisitar, Visitados):-
	