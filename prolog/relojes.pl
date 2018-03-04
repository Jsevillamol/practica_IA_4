
% estado([ParteSuperior1, ParteInferior1], [ParteSuperior2, ParteInferior2])
% representa la cantidad de arena en minutos que queda en cada parte de sendos relojes

% nodo(estado, coste, solucion_parcial)
% estado = el estado donde se encuentra el nodo
% coste = coste asociado al nodo
% solucion_parcial = secuencia de operadores que transforman el estado inicial en el nodo actual

% Nodo inicial
nodo(estado([7,0],[11,0]), 0, [], []).

% Busqueda
resolver(Coste, Solucion):-
	busquedaGraphDFS([nodo(estado([7,0],[11,0]), 0, [])], [], Coste, Solucion).

% Goal test
% Las soluciones son aquellas en las que aparece el numero 3 en alguna parte del estado
busquedaGraphDFS([nodo(estado([U1,L1], [U2,L2]), Coste, Solucion) | _], _, Coste, Solucion):-
	U1 = 3 ; L1 = 3 ; U2 = 3; L2 = 3.

% Node expansion
% NodoActual = Nodo a expandir en el siguiente paso de la busqueda
% Frontera = Nodos que quedan por expandir
% Visitados = Estados que ya han sido visitados en el pasado
% Coste, Solucion = Parametros de salida
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
% Espera a que la arena caiga de los relojes hasta que uno de ellos se vacie
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
% Elimina de la lista [Nodos] los nodos con un estado en [Estados] y devuelve el resultado en Resultado
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
