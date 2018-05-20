% Convertidor de frases directas en indirectas y viceversa
% Jaime Sevilla 2018

% TEST1: directa2indirecta("maría me dijo : \" juan es mi amigo \"", Res).
% RESULTADO1: maria me dijo que juan era su amigo

% TEST2: directa2indirecta("miguel me dijo : \" estoy contento de verte \"", Res).
% RESULTADO1: miguel me dijo que estaba contento de verme

% TEST2: directa2indirecta("lucía me dijo : \" necesito un cambio en mi vida \"", Res).
% RESULTADO1: Lucía me dijo que necesitaba un cambio en su vida

% TEST2: directa2indirecta("luis me preguntó : \" ¿ estás ocupada esta noche ? \"", Res).
% RESULTADO1: Luis me preguntó que si estaba ocupada esa noche

% TEST: split_string("maria me dijo : \" juan es mi amigo \"", " ", "", StringList).
% TEST: maplist(myString_atom, ["maria", "me", "dijo", ":", "\"", "juan", "es", "mi", "amigo", "\""], FraseDirecta).

% TEST3: maplist(myString_atom, ["maria", "me", "dijo", ":", "\"", "juan", "es", "mi", "amigo", "\""], TokenList).

directa2indirecta(Entrada, Salida):-
	split_string(Entrada, " ", "", StringList),
	maplist(myString_atom, StringList, FraseDirecta),
	print(FraseDirecta),
	fraseDirecta(InfoSujeto, InfoCI, ModoSubordinada, FraseDirecta, []),
	print(" La frase es directa y sintacticamente correcta"),
	descomponerFraseDirecta(FraseDirecta, ModoSubordinada, FrasePrincipal, OracionSubordinada),
	print(" descomposicion done"),
	transformarSubordinada(OracionSubordinada, InfoSujeto, InfoCI, Resultado),
	print(" transformacion done"),
	componerResultado(FrasePrincipal, Resultado, ModoSubordinada, FraseIndirecta),
	maplist(atom_string, FraseIndirecta, Aux),
	atomic_list_concat(Aux, " ", Salida).
	

myString_atom("¿", "¿"):-!.
myString_atom("?", "?"):-!.
myString_atom("\"", "\""):-!.
myString_atom(":", ":"):-!.
myString_atom(String, Atom) :- atom_string(Atom, String).
	

% TEST1: descomponerFraseDirecta([maría, me, dijo, ":", "\"", juan, es, mi, amigo,"\""], afirmativo, FrasePrincipal, OracionSubordinada).
% RESULTADO1: FrasePrincipal = [maría, me, dijo], OracionSubordinada = [juan, es, mi, amigo]

descomponerFraseDirecta(Entrada, afirmativo, FrasePrincipal, OracionSubordinada):-
	append([FrasePrincipal, [":", "\""], OracionSubordinada ,["\""]], Entrada).

descomponerFraseDirecta(Entrada, interrogativo, FrasePrincipal, OracionSubordinada):-
	append([FrasePrincipal, [":", "\"", "¿"], OracionSubordinada ,["?","\""]], Entrada).

componerResultado(FrasePrincipal, Resultado, afirmativo, Salida):-
	append([FrasePrincipal, [que], Resultado], Salida).

componerResultado(FrasePrincipal, Resultado, interrogativo, Salida):-
	append([FrasePrincipal, [que, si], Resultado], Salida).

% TEST1: transformarSubordinada([juan, es, mi, amigo], sujeto(3, singular), ci(1, singular), Res).
% RESULTADO1: juan era su amigo
% TEST2: transformarSubordinada([juan, es, mi, amigo], sujeto(2, singular), ci(1, singular), Res).
% RESULTADO2: juan era tu amigo
% TEST3: transformarSubordinada([estoy,contento,de,verte], sujeto(3, singular), ci(1, singular), Res).

transformarSubordinada([], _, _, []).

% Pronombres personales
transformarSubordinada([Pronombre | Xs], InfoSujeto, InfoCI, [PronombreTransformado | Res]):-
	esPronombrePersonal(Pronombre, Persona, Numero, Genero),
	!,
	transformarPersona( original(Persona, Numero), InfoSujeto, InfoCI, resultado(PersonaTransformada, NumeroTransformado)),
	esPronombrePersonal(PronombreTransformado, PersonaTransformada, NumeroTransformado, Genero),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Verbo infinitivo + pronombre reflexivo
transformarSubordinada([Compuesta | Xs], InfoSujeto, InfoCI, [CompuestaTransformada | Res]):-
	esVerbo(_, Verbo, _, _, _, _),
	esPronombreComplementoIndirecto(Pronombre, Persona, Numero),
	atom_concat(Verbo, Pronombre, Compuesta),
	!,
	transformarPersona(	original(Persona, Numero), InfoSujeto, InfoCI, resultado(PersonaTransformada, NumeroTransformado)),
	esPronombreComplementoIndirecto(PronombreTransformado, PersonaTransformada, NumeroTransformado),
	atom_concat(Verbo, PronombreTransformado, CompuestaTransformada),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Verbos
transformarSubordinada([Verbo | Xs], InfoSujeto, InfoCI, [VerboTransformado | Res]):-
	esVerbo(Verbo, Infinitivo, presente, Persona, Numero, _),
	!,
	transformarPersona(	original(Persona, Numero), InfoSujeto, InfoCI, resultado(PersonaTransformada, NumeroTransformado)),
	esVerbo(VerboTransformado, Infinitivo, pasado, PersonaTransformada, NumeroTransformado, _),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Posesivos
transformarSubordinada([Posesivo | Xs], InfoSujeto, InfoCI, [PosesivoTransformado | Res]):-
	esPosesivo(Posesivo, PersonaPoseedor, NumeroPoseedor, GeneroPoseido, NumeroPoseido),
	!,
	transformarPersona(	
		original(PersonaPoseedor, NumeroPoseedor), 
		InfoSujeto, InfoCI, 
		resultado(PersonaPoseedorTransformada, NumeroPoseedorTransformado)),
	esPosesivo(PosesivoTransformado, PersonaPoseedorTransformada, NumeroPoseedorTransformado, GeneroPoseido, NumeroPoseido),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Pronombres reflexivos
transformarSubordinada([Pronombre | Xs], InfoSujeto, InfoCI, [PronombreTransformado | Res]):-
	esPronombreReflexivo(Pronombre, Persona, Numero),
	!,
	transformarPersona(	original(Persona, Numero), InfoSujeto, InfoCI, resultado(PersonaTransformada, NumeroTransformado)),
	esPronombreReflexivo(PronombreTransformado, PersonaTransformada, NumeroTransformado),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Demostrativos
transformarSubordinada([Demostrativo | Xs], InfoSujeto, InfoCI, [DemostrativoTransformado | Res]):-
	esDemostrativo(Demostrativo, Persona, Numero, cercano),
	!,
	esDemostrativo(DemostrativoTransformado, Persona, Numero, lejano),
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% Resto
transformarSubordinada([X | Xs], InfoSujeto, InfoCI, [X | Res]):-
	transformarSubordinada(Xs, InfoSujeto, InfoCI, Res).

% TEST: transformarPersona(original(2, singular), sujeto(3, singular), ci(1,singular), resultado(PersonaTransformada, NumeroTransformado)).

% transformarPersona(
%	original(Persona, Numero), 
%	sujeto(SPersona, SNumero), 
%	ci(CIPersona, CINumero), 
%	resultado(Persona, Numero)).

transformarPersona(
	original(1, _), 
	sujeto(SPersona, SNumero), 
	ci(_, _), 
	resultado(SPersona, SNumero)).

transformarPersona(
	original(2, _), 
	sujeto(_, _), 
	ci(CIPersona, CINumero), 
	resultado(CIPersona, CINumero)).

transformarPersona(
	original(3, Numero), 
	sujeto(_, _),
	ci(_, _),
	resultado(3, Numero)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   GRAMATICA     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TEST1: fraseDirecta(InfoSujeto, InfoCI, Modo, [maría, me, dijo, ":", "\"", juan, es, mi, amigo,"\""], []).
% TEST1: fraseDirecta(InfoSujeto, InfoCI, Modo, [miguel,me,dijo,":","\"",estoy,contento,de,verte,"\""], []).

fraseDirecta(InfoSujeto, InfoCI, Modo) --> 
	frasePrincipal(InfoSujeto, InfoCI, Modo), 
	[":"], ["\""],  oracionSubordinada(Modo), ["\""].

% TEST: frasePrincipal(InfoSujeto, InfoCI, Modo, [maría, me, dijo], []).
% TEST: frasePrincipal(InfoSujeto, InfoCI, Modo, [miguel,me,dijo], []).
% TEST: frasePrincipal(InfoSujeto, InfoCI, Modo, [luis,me,preguntó], []).
% TEST2: esPronombreComplementoIndirecto(me, CIPersona, CINumero).
% TEST3: esVerbo(dijo, _, pasado, SPersona, SNumero, declarativo(Modo)).

frasePrincipal(sujeto(SPersona, SNumero), ci(CIPersona, CINumero), Modo) -->
	sujeto(SPersona, SNumero, _), 
	[Pronombre], {esPronombreComplementoIndirecto(Pronombre, CIPersona, CINumero)}, 
	[Verbo], {esVerbo(Verbo, _, _, SPersona, SNumero, declarativo(Modo))}.

% TEST: sujeto(Persona, Numero, Genero, [maría], []).
% TEST: sujeto(Persona, Numero, Genero, [juan], []).
sujeto(3, Numero, Genero) --> [Nombre], {esNombrePropio(Nombre, Genero, Numero)}.
sujeto(Persona, Numero, Genero) --> [Pronombre], {esPronombrePersonal(Pronombre,Persona, Numero, Genero)}.
% sujeto([Pronombre], Persona, Numero, Genero) --> sintagmaNominal

% TEST: oracionSubordinada(Modo, [juan, es, mi, amigo], []).
% TEST: oracionSubordinada(Modo, [estoy, contento, de, verte], []).
% TEST: oracionSubordinada(Modo, ["¿",estás,ocupada,esta,noche,"?"], []).
% TEST2: esVerbo(es, _, presente, Persona, Numero, copulativo).
oracionSubordinada(afirmativo)--> 
	(sujeto(Persona, Numero, Genero) ; []),
	[Verbo], {esVerbo(Verbo, _, presente, Persona, Numero, copulativo)}, 
	atributo(Genero, Numero),
	(complementoTemporal ; []).

oracionSubordinada(afirmativo)-->
	(sujeto(Persona, Numero, _) ; []), 
	[Verbo], {esVerbo(Verbo, _, presente, Persona, Numero, transitivo)}, 
	complementoDirecto, 
	(complementoCircunstancial ;[]).

oracionSubordinada(interrogativo)-->
	["¿"], 
	%(PronombreInterrogativo ; []),
	oracionSubordinada(afirmativo) 
	,["?"].

% TEST: atributo(Genero, Numero, [ocupada], []).
atributo(Genero, Numero) --> sintagmaAdjetival(Genero, Numero).
atributo(Genero, Numero) --> sintagmaNominal(Genero, Numero).

complementoDirecto --> (sintagmaNominal(_,_) ; sintagmaPreposicional).

sintagmaNominal(Genero, Numero) --> 
	[Det], {esDeterminante(Det, Genero, Numero)}, 
	[Sust],{esSustantivoComun(Sust, Genero, Numero)}.
	%, (complementoDelNombre ; []).

sintagmaNominal(Genero, Numero) --> [Nombre], {esNombrePropio(Nombre, Genero, Numero)}.

% TEST: sintagmaAdjetival(Genero, Numero, [contento,de,verte], []).
% TEST: esAdjetivo(contento, Genero, Numero).
sintagmaAdjetival(Genero,Numero) --> 
	[Adj], {esAdjetivo(Adj, Genero, Numero)},
	(complementoAdjetivo ; []).

complementoAdjetivo --> sintagmaPreposicional.

%TEST: sintagmaPreposicional([de, verte], []).

sintagmaPreposicional --> 
	[Preposicion], {esPreposicion(Preposicion)},
	termino.

termino --> sintagmaNominal(_, _) ; subordinadaSustantiva.
subordinadaSustantiva --> [Compuesta], 
	{	
		esVerbo(_, Verbo, _, _, _, _), 
		esPronombreReflexivo(Pron, _, _),
		atom_concat(Verbo, Pron, Compuesta)
	}.

complementoCircunstancial --> sintagmaPreposicional.

% TEST: complementoTemporal([esta, noche], []).
complementoTemporal -->
	[Demostrativo],{esDemostrativo(Demostrativo, femenino, singular, _)},
	([mañana] ; [tarde] ;[noche]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   DICCIONARIO   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Verbos  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% esVerbo(Verbo, Infinitivo, Tiempo, Persona, Numero, tipo).

% verbo ser
esVerbo(soy, ser, presente, 1, singular, copulativo).
esVerbo(eres, ser, presente, 2, singular, copulativo).
esVerbo(es, ser, presente, 3, singular, copulativo).
esVerbo(somos, ser, presente, 1, plural, copulativo).
esVerbo(sois, ser, presente, 2, plural, copulativo).
esVerbo(son, ser, presente, 3, plural, copulativo).

esVerbo(era, ser, pasado, 1, singular, copulativo).
esVerbo(eras, ser, pasado, 2, singular, copulativo).
esVerbo(era, ser, pasado, 3, singular, copulativo).
esVerbo(eramos, ser, pasado, 1, plural, copulativo).
esVerbo(erais, ser, pasado, 2, plural, copulativo).
esVerbo(eran, ser, pasado, 3, plural, copulativo).

% verbo estar
esVerbo(estoy, estar, presente, 1, singular, copulativo).
esVerbo(estás, estar, presente, 2, singular, copulativo).
esVerbo(está, estar, presente, 3, singular, copulativo).
esVerbo(estamos, estar, presente, 1, plural, copulativo).
esVerbo(estáis, estar, presente, 2, plural, copulativo).
esVerbo(están, estar, presente, 3, plural, copulativo).

esVerbo(estaba, estar, pasado, 1, singular, copulativo).
esVerbo(estabas, estar, pasado, 2, singular, copulativo).
esVerbo(estaba, estar, pasado, 3, singular, copulativo).
esVerbo(estabamos, estar, pasado, 1, plural, copulativo).
esVerbo(estabais, estar, pasado, 2, plural, copulativo).
esVerbo(estaban, estar, pasado, 3, plural, copulativo).

% verbo decir
esVerbo(digo, decir, presente, 1, singular, declarativo(afirmativo)).
esVerbo(dices, decir, presente, 2, singular, declarativo(afirmativo)).
esVerbo(dice, decir, presente, 3, singular, declarativo(afirmativo)).
esVerbo(decimos, decir, presente, 1, plural, declarativo(afirmativo)).
esVerbo(decis, decir, presente, 2, plural, declarativo(afirmativo)).
esVerbo(dicen, decir, presente, 3, plural, declarativo(afirmativo)).

esVerbo(dije, decir, pasado, 1, singular, declarativo(afirmativo)).
esVerbo(dijiste, decir, pasado, 2, singular, declarativo(afirmativo)).
esVerbo(dijo, decir, pasado, 3, singular, declarativo(afirmativo)).
esVerbo(dijimos, decir, pasado, 1, plural, declarativo(afirmativo)).
esVerbo(dijisteis, decir, pasado, 2, plural, declarativo(afirmativo)).
esVerbo(dijeron, decir, pasado, 3, plural, declarativo(afirmativo)).

% verbo ver
esVerbo(veo, ver, presente, 1, singular, transitivo).

% TODO: generar automaticamente conjugaciones regulares

esVerbo(Verbo, Infinitivo, presente, 1, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, o, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, presente, 2, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, as, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, presente, 3, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, a, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, presente, 1, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, amos, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, presente, 2, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, ais, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, presente, 3, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, an, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

% pasado
esVerbo(Verbo, Infinitivo, pasado, 1, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, aba, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasado, 2, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, abas, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasado, 3, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, aba, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasado, 1, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, abamos, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasado, 2, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, abais, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasado, 3, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, aban, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

% pasadoPerfecto
esVerbo(Verbo, Infinitivo, pasadoPerfecto, 1, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, é, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasadoPerfecto, 2, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, aste, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasadoPerfecto, 3, singular, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, ó, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasadoPerfecto, 1, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, amos, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasadoPerfecto, 2, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, asteis, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

esVerbo(Verbo, Infinitivo, pasadoPerfecto, 3, plural, Tipo):-
	esLexemaVerboRegular(Lexema, ar, Tipo),
	atom_concat(Lexema, aron, Verbo),
	atom_concat(Lexema, ar, Infinitivo).

% esLexemaVerboRegular(Lexema, Conjugacion, tipo)
esLexemaVerboRegular(pregunt, ar, declarativo(interrogativo)).
esLexemaVerboRegular(necesit, ar, transitivo).

%% verboDeclarativo(1, singular, preteritoPerfectoSimple, interrogativo) --> [pregunté].
%% verboDeclarativo(3, singular, preteritoPerfectoSimple, interrogativo) --> [preguntó].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sustantivos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% esNombrePropio(Nombre, Genero, Numero).
esNombrePropio(luis, masculino, singular).
esNombrePropio(miguel, masculino, singular).
esNombrePropio(juan, masculino, singular).
esNombrePropio(maría, femenino, singular).
esNombrePropio(lucía, femenino, singular).

% esSustantivoComun(Sustantivo, Genero, Numero)
esSustantivoComun(cambio, masculino, singular).
esSustantivoComun(amigo, masculino, singular).
esSustantivoComun(amiga, femenino, singular).
esSustantivoComun(vida, femenino, singular).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Adjetivos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generacion automatica de adjetivos regulares
esAdjetivo(Adjetivo, masculino, singular):-
	esLexemaAdjetivoRegular(Lexema),
	atom_concat(Lexema, o, Adjetivo).
esAdjetivo(Adjetivo, femenino, singular):-
	esLexemaAdjetivoRegular(Lexema),
	atom_concat(Lexema, a, Adjetivo).
esAdjetivo(Adjetivo, masculino, plural):-
	esLexemaAdjetivoRegular(Lexema),
	atom_concat(Lexema, os, Adjetivo).
esAdjetivo(Adjetivo, femenino, plural):-
	esLexemaAdjetivoRegular(Lexema),
	atom_concat(Lexema, as, Adjetivo).

esLexemaAdjetivoRegular(content).
esLexemaAdjetivoRegular(ocupad).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Determinantes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

esDeterminante(Determinante, Genero, Numero):-
	esArticulo(Determinante, Genero, Numero,_ );
	esPosesivo(Determinante, _, _, Genero, Numero);
	esDemostrativo(Determinante, Genero, Numero, _).

% esArticulo(Articulo, Genero, Numero, GradoDeDeterminacion)
esArticulo(el, masculino, singular, definido).
esArticulo(un, masculino, singular, indefinido).
esArticulo(la, femenino, singular, definido).
esArticulo(una, femenino, singular, indefinido).
esArticulo(los, masculino, plural, definido).
esArticulo(unos, masculino, plural, indefinido).
esArticulo(las, femenino, plural, definido).
esArticulo(unas, femenino, plural, indefinido).

% esPosesivo(Posesivo, PersonaPoseedor, NumeroPoseedor, GeneroPoseido, NumeroPoseido).
esPosesivo(mi, 1, singular, _, singular).
esPosesivo(tu, 2, singular, _, singular).
esPosesivo(su, 3, singular, _, singular).
esPosesivo(mis, 1, singular, _, plural).
esPosesivo(tus, 2, singular, _, plural).
esPosesivo(sus, 3, singular, _, plural).

% esDemostrativo(Demostrativo, Genero, Numero, GradoDeDeixis).
esDemostrativo(este, masculino, singular, cercano).
esDemostrativo(esta, femenino, singular, cercano).
esDemostrativo(estos, masculino, plural, cercano).
esDemostrativo(estas, femenino, plural, cercano).
esDemostrativo(ese, masculino, singular, lejano).
esDemostrativo(esa, femenino, singular, lejano).
esDemostrativo(esos, masculino, plural, lejano).
esDemostrativo(esas, femenino, plural, lejano).


%%%%%%%%%%%%%%%%%%%%%%%%% Pronombres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% esPronombrePersonal(Pronombre,Persona, Numero, Genero).
esPronombrePersonal(yo, 1, singular, _).
esPronombrePersonal(tu, 2, singular, _).
esPronombrePersonal(él, 3, singular, masculino).
esPronombrePersonal(ella, 3, singular, femenino).
esPronombrePersonal(nosotros, 1, plural, masculino).
esPronombrePersonal(nosotras, 1, plural, femenino).
esPronombrePersonal(vosotros, 2, plural, masculino).
esPronombrePersonal(vosotras, 2, plural, femenino).
esPronombrePersonal(ellos, 3, plural, masculino).
esPronombrePersonal(ellas, 3, plural, femenino).

% esPronombreReflexivo(Pronombre, Persona, Numero).
esPronombreReflexivo(me, 1, singular).
esPronombreReflexivo(te, 2, singular).
esPronombreReflexivo(se, 3, singular).
esPronombreReflexivo(nos, 1, plural).
esPronombreReflexivo(os, 2, plural).
esPronombreReflexivo(se, 3, plural).

% esPronombreComplementoIndirecto(Pronombre, Persona, Numero)
esPronombreComplementoIndirecto(me, 1, singular).
esPronombreComplementoIndirecto(te, 2, singular).
esPronombreComplementoIndirecto(le, 3, singular).
esPronombreComplementoIndirecto(nos, 1, plural).
esPronombreComplementoIndirecto(os, 2, plural).
esPronombreComplementoIndirecto(les, 3, plural).

%%%%%%%%%%%%%%%%%%%%% Preposiciones %%%%%%%%%%%%%%%%%%%%%%%%%
esPreposicion(de).
esPreposicion(en).