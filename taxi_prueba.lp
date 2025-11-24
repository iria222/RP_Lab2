% taxi_prueba.lp - Solucion Funcional y Robusta (Steps 1-4)
% -------------------------------------------------

% #################################################
% PROGRAMA BASE (Definiciones estaticas)
% #################################################
#program base.

direction(r, 0, 1).
direction(l, 0, -1).
direction(u, -1, 0).
direction(d, 1, 0).

is_valid_cell(R,C) :- cell(R,C), not building(R,C).

action(move(D)) :- direction(D,_,_).
action(pick).
action(drop).
action(wait).

% #################################################
% PROGRAMA INICIAL (Estado t=0)
% #################################################
#program initial.

taxi_at(T, R, C) :- holds(at(taxi(T), R, C), 0).
pass_at(P, R, C) :- holds(at(pass(P), R, C), 0).
% inside y la memoria (has_picked) empiezan vacios

% #################################################
% PROGRAMA DINAMICO (Transiciones t > 0)
% #################################################
#program dynamic.

% 1. GENERACION DE ACCIONES
1 { do(T, A) : _action(A) } 1 :- _taxi(T).

% 2. EFECTOS DE LAS ACCIONES
taxi_at(T, R+DR, C+DC) :- do(T, move(D)), 'taxi_at(T, R, C), _direction(D, DR, DC).
inside(P, T)           :- do(T, pick), 'taxi_at(T, R, C), 'pass_at(P, R, C).
pass_at(P, R, C)       :- do(T, drop), 'taxi_at(T, R, C), 'inside(P, T).

% Auxiliar: Saber si se acaba de recoger a alguien
picked_now(P) :- do(T, pick), 'taxi_at(T, R, C), 'pass_at(P, R, C).

% 3. AXIOMAS DE INERCIA
taxi_at(T, R, C) :- 'taxi_at(T, R, C), not do(T, move(_)).
pass_at(P, R, C) :- 'pass_at(P, R, C), not picked_now(P).
inside(P, T)     :- 'inside(P, T), not do(T, drop).

% 4. RESTRICCIONES BASICAS
:- taxi_at(T, R, C), not _is_valid_cell(R, C).
:- taxi_at(T1, R, C), taxi_at(T2, R, C), T1 < T2.

% No swaps
:- do(T1, move(D1)), do(T2, move(D2)),
   'taxi_at(T1, R1, C1), 'taxi_at(T2, R2, C2),
   taxi_at(T1, R2, C2), taxi_at(T2, R1, C1),
   T1 < T2.

% Logica Pick/Drop estandar
:- do(T, pick), 'inside(_, T).
:- do(T, pick), 'taxi_at(T, R, C), not 'pass_at(_, R, C).
:- do(T, drop), not 'inside(_, T).
:- inside(P1, T), inside(P2, T), P1 != P2.

% Conflictos de pasajeros
:- pass_at(P1, R, C), pass_at(P2, R, C), P1 < P2.
:- pass_at(P1, R, C), do(T, drop), 'taxi_at(T, R, C), 'inside(P2, T), P1 != P2.

% =========================================================
% OPTIMIZACION DEL PASO 4 (Implementacion Robusta)
% "Nunca recoger a la misma persona dos veces"
% =========================================================

% Definimos un predicado de "memoria" (has_picked)
% 1. Se vuelve verdadero si el taxi recoge al pasajero AHORA
has_picked(P, T) :- do(T, pick), 'taxi_at(T, R, C), 'pass_at(P, R, C).

% 2. Inercia: Si ya era verdadero antes, sigue siendo verdadero (nunca se olvida)
has_picked(P, T) :- 'has_picked(P, T).

% 3. Restriccion: No se puede hacer pick si 'has_picked' ya es verdadero
:- do(T, pick), 'taxi_at(T, R, C), 'pass_at(P, R, C), 'has_picked(P, T).

% =========================================================

% #################################################
% SALIDA Y DISPLAY
% #################################################
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