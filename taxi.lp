% =============================================
%  TAXI ROUTING PARA TELINGO 2.1.2 (CORREGIDO)
% =============================================

#program initial.
% Estado inicial definido en domain.lp

#program dynamic.

% ---------------------------------------------
% DIRECCIONES (movidas aquí desde base)
% ---------------------------------------------
dir(up, -1, 0).
dir(down, 1, 0).
dir(left, 0, -1).
dir(right, 0, 1).
direction(up; down; left; right).

% ---------------------------------------------
% ACCIONES
% ---------------------------------------------
1 {
    move(T,D) : direction(D);
    pick(T,P) : passenger(P);
    drop(T,P) : passenger(P);
    wait(T)
} 1 :- taxi(T).

% ---------------------------------------------
% PRECONDICIONES
% ---------------------------------------------

% Movimiento fuera del grid
:- move(T,D),
   'at(taxi(T),R1,C1),
   dir(D,DR,DC),
   R2 = R1+DR, C2 = C1+DC,
   not cell(R2,C2).

% No recoger si no está libre
:- pick(T,P),
   not 'free(taxi(T)).

% No recoger si no están en la misma celda
:- pick(T,P),
   'at(taxi(T),R,C),
   not 'at(pass(P),R,C).

% No dejar si no está dentro
:- drop(T,P),
   not 'in(pass(P),taxi(T)).

% Restricción pick/drop simultáneo
:- pick(T,_), drop(T,_).
:- pick(T,P1), pick(T,P2), P1 != P2.
:- drop(T,P1), drop(T,P2), P1 != P2.

% ---------------------------------------------
% EFECTOS
% ---------------------------------------------

% MOVE
at(taxi(T),R2,C2) :-
    move(T,D),
    'at(taxi(T),R1,C1),
    dir(D,DR,DC),
    R2 = R1+DR, C2 = C1+DC.

% PICK
in(pass(P),taxi(T)) :- pick(T,P).
occupied(taxi(T)) :- pick(T,P).

% DROP
at(pass(P),R,C) :-
    drop(T,P),
    'at(taxi(T),R,C).

% ---------------------------------------------
% INERCIA
% ---------------------------------------------

% Posición de taxis
at(taxi(T),R,C) :-
    'at(taxi(T),R,C),
    not move(T,_).

% Posición de pasajeros (si no están siendo recogidos)
at(pass(P),R,C) :-
    'at(pass(P),R,C),
    not pick(_,P).

% Pasajeros dentro de taxis
in(pass(P),taxi(T)) :-
    'in(pass(P),taxi(T)),
    not drop(_,P).

% Estado de ocupación de taxis
occupied(taxi(T)) :-
    'occupied(taxi(T)),
    not drop(T,_).

% Derivado: un taxi está libre si no está ocupado
free(taxi(T)) :-
    taxi(T),
    not occupied(taxi(T)).

% ---------------------------------------------
% RESTRICCIONES DEL DOMINIO
% ---------------------------------------------

% Dos taxis no pueden estar en la misma celda
:- at(taxi(T1),R,C),
   at(taxi(T2),R,C),
   T1 != T2.

% Dos pasajeros no pueden estar en la misma celda
:- at(pass(P1),R,C),
   at(pass(P2),R,C),
   P1 != P2.

% Un pasajero no puede estar en una celda si está dentro de un taxi
:- at(pass(P),_,_),
   in(pass(P), taxi(_)).

% ---------------------------------------------
% META (usando #program always para goals)
% ---------------------------------------------
#program always.

goal(P) :- at(pass(P),R,C), station(R,C).

#program final.

:- passenger(P), not goal(P).

% =============================================
#show move/2.
#show pick/2.
#show drop/2.
#show wait/1.