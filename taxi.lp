#program base.

cell(1..3, 1..3).
building(2,2).

taxi(t1).
passenger(p1).

init_pos(t1,1,1).
init_pos(p1,3,3).

station(1,3).

% Estado: una posición por taxi y una posición por pasajero (fuera)
{ at(T,X,Y) : cell(X,Y) } = 1 :- taxi(T).
{ atp(P,X,Y) : cell(X,Y) } = 1 :- passenger(P).
{ in(P,T) } :- passenger(P), taxi(T).

#program step(t).

% Acciones (exactamente una por taxi cada paso)
1 {
    move(T,up); move(T,down); move(T,left); move(T,right);
    pick(T,P); drop(T,P); wait(T)
} 1 :- taxi(T).

dir(up,0,1).
dir(down,0,-1).
dir(left,-1,0).
dir(right,1,0).

% Efecto de mover
at(T,X2,Y2) :-
    move(T,D),
    dir(D,DX,DY),
    at(T,X1,Y1),
    X2 = X1 + DX, Y2 = Y1 + DY.

% Efecto de esperar
at(T,X,Y) :- wait(T), at(T,X,Y).

% No entrar en edificios
:- at(T,X,Y), building(X,Y).

% Pick: pasajero dentro si taxi y pasajero coinciden
in(P,T) :-
    pick(T,P),
    at(T,X,Y),
    atp(P,X,Y).

% Drop: pasajero aparece en la celda del taxi
atp(P,X,Y) :-
    drop(T,P),
    in(P,T),
    at(T,X,Y).

% No puede estar a la vez dentro y fuera en cualquier posición
:- in(P,T), atp(P,_,_).

#program check.

% Dos taxis no pueden ocupar la misma celda (t1 != t2)
:- taxi(T1), taxi(T2), not T1 = T2, at(T1,X,Y), at(T2,X,Y).

% Dos pasajeros no pueden ocupar la misma celda
:- passenger(P1), passenger(P2), not P1 = P2, atp(P1,X,Y), atp(P2,X,Y).

% Si un pasajero está dentro del taxi, no puede estar fuera en otra celda:
% prohibimos X distinto o Y distinto mediante dos restricciones separadas
:- in(P,T), atp(P,Xp,Yp), at(T,Xt,Yt), not Xp = Xt.
:- in(P,T), atp(P,Xp,Yp), at(T,Xt,Yt), not Yp = Yt.

% Dos taxis no pueden intercambiar posiciones en un único paso (swap)
:- taxi(T1), taxi(T2), not T1 = T2,
   move(T1,D1), move(T2,D2),
   at(T1,X1,Y1), at(T2,X2,Y2),
   dir(D1,DX1,DY1), dir(D2,DX2,DY2),
   X1 + DX1 = X2, Y1 + DY1 = Y2,
   X2 + DX2 = X1, Y2 + DY2 = Y1.

% Objetivo: pasajero en estación
goal :- passenger(P), atp(P,X,Y), station(X,Y).

% Temporal: eventualmente se alcanza goal
:- not diamond goal.
