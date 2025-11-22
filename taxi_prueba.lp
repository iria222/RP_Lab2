% taxi.lp - Solucion para Taxi Routing con Telingo
% -------------------------------------------------

% #################################################
% PROGRAMA BASE (Definiciones estaticas)
% #################################################
#program base.

% Direcciones y sus deltas
direction(r, 0, 1).
direction(l, 0, -1).
direction(u, -1, 0).
direction(d, 1, 0).

% Definimos celda valida (si no es un edificio)
is_valid_cell(R,C) :- cell(R,C), not building(R,C).

% Definimos que acciones son posibles conceptualmente
action(move(D)) :- direction(D,_,_).
action(pick).
action(drop).
action(wait).

% #################################################
% PROGRAMA INICIAL (Estado t=0)
% #################################################
#program initial.

% Convertimos la entrada del encode.py (holds con tiempo 0) a fluentes de Telingo
taxi_at(T, R, C) :- holds(at(taxi(T), R, C), 0).
pass_at(P, R, C) :- holds(at(pass(P), R, C), 0).
% inside(P,T) es falso por defecto al inicio

% #################################################
% PROGRAMA DINAMICO (Transiciones t > 0)
% #################################################
#program dynamic.

% 1. GENERACION DE ACCIONES
% Cada taxi debe ejecutar exactamente una accion por turno
1 { do(T, A) : _action(A) } 1 :- _taxi(T).

% 2. EFECTOS DE LAS ACCIONES (Leyes de Efecto)

% Mover: Actualiza la posicion del taxi
taxi_at(T, R+DR, C+DC) :- 
    do(T, move(D)), 
    'taxi_at(T, R, C), 
    _direction(D, DR, DC).

% Recoger (Pick): El pasajero pasa a estar dentro (inside)
inside(P, T) :- 
    do(T, pick), 
    'taxi_at(T, R, C), 
    'pass_at(P, R, C).

% Dejar (Drop): El pasajero vuelve a estar en una posicion (pass_at)
pass_at(P, R, C) :- 
    do(T, drop), 
    'taxi_at(T, R, C), 
    'inside(P, T).

% Auxiliar: Saber si un pasajero fue recogido en este paso (para la inercia)
picked(P) :- do(T, pick), 'taxi_at(T, R, C), 'pass_at(P, R, C).


% 3. AXIOMAS DE INERCIA (Leyes de Persistencia)
% "Lo que no cambia, se mantiene igual"

% Inercia del Taxi: Si no se mueve, se queda donde estaba
taxi_at(T, R, C) :- 'taxi_at(T, R, C), not do(T, move(_)).

% Inercia del Pasajero (Suelo): Si no fue recogido, se queda donde estaba
pass_at(P, R, C) :- 'pass_at(P, R, C), not picked(P).

% Inercia del Pasajero (Dentro): Si no fue dejado, sigue dentro
inside(P, T) :- 'inside(P, T), not do(T, drop).


% 4. RESTRICCIONES (Executability constraints)

% -- Restricciones de Movimiento --
% No atravesar paredes / salirse del mapa
:- taxi_at(T, R, C), not _is_valid_cell(R, C).

% No chocar taxis (dos taxis en la misma celda)
:- taxi_at(T1, R, C), taxi_at(T2, R, C), T1 < T2.

% No intercambiar posiciones (Swap)
:- do(T1, move(D1)), do(T2, move(D2)),
   'taxi_at(T1, R1, C1), 'taxi_at(T2, R2, C2),
   taxi_at(T1, R2, C2), taxi_at(T2, R1, C1),
   T1 < T2.

% -- Restricciones de Pick (Recoger) --
% No se puede recoger si ya hay alguien dentro del taxi
:- do(T, pick), 'inside(_, T).

% No se puede recoger si no hay pasajero en la celda actual
:- do(T, pick), 'taxi_at(T, R, C), not 'pass_at(_, R, C).

% -- Restricciones de Drop (Dejar) --
% No se puede dejar si no hay nadie dentro
:- do(T, drop), not 'inside(_, T).

% -- Restricciones de Pasajeros --
% Dos personas no pueden estar en la misma celda (pasajeros en el suelo)
:- pass_at(P1, R, C), pass_at(P2, R, C), P1 < P2.

% Un pasajero en el suelo y otro bajando del taxi en la misma celda
:- pass_at(P1, R, C), do(T, drop), 'taxi_at(T, R, C), 'inside(P2, T), P1 != P2.
% Nota: La regla anterior cubre el caso de dejar a alguien donde ya hay alguien.


% #################################################
% SALIDA Y DISPLAY
% #################################################

% Mapeo para que la salida coincida con lo que pide el enunciado
move(T,D) :- do(T,move(D)).
pick(T)   :- do(T,pick).
drop(T)   :- do(T,drop).
wait(T)   :- do(T,wait).

#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.

% #################################################
% PROGRAMA FINAL (Objetivo)
% #################################################
#program final.

delivered(P) :- pass_at(P, R, C), _station(R, C).

:- _passenger(P), not delivered(P).

