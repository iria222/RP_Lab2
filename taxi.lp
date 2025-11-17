% --- Taxi Routing Solver para telingo ---
% Este archivo (taxi.lp) contiene la lógica general del problema.
% Debe ser ejecutado junto con un archivo de instancia (ej. domain.lp)
% generado por encode.py.
%
% Ejemplo: telingo taxi.lp domain.lp


% --- PROGRAMA BASE (Estático) ---
% Hechos estáticos que no cambian con el tiempo.
#program base.

% Definición de direcciones para la acción 'move'.
dir(up, -1, 0).
dir(down, 1, 0).
dir(left, 0, -1).
dir(right, 0, 1).
direction(up; down; left; right).

% --- PREDICADOS DE ESTADO (Fluents) ---
% Estos son los predicados que cambian en cada paso de tiempo.
% Telingo 2.1.2 los infiere automáticamente sin la directiva #fluent.


% --- PROGRAMA DE PASO (Transición) ---
% Define la lógica para pasar del tiempo t-1 al tiempo t.
#program step(t).

% --- 1. ELECCIÓN DE ACCIONES ---
% Cada taxi (T) debe elegir exactamente una acción en cada paso (t).
1 {
    % Moverse en una dirección (D)
    move(T, D) : direction(D);

    % Recoger un pasajero (P)
    pick(T, P) : passenger(P);

    % Dejar un pasajero (P)
    drop(T, P) : passenger(P);

    % Esperar
    wait(T)
} 1 :- taxi(T).


% --- 2. PRECONDICIONES DE ACCIÓN ---
% Restricciones que impiden acciones imposibles.

% No puedes moverte a una celda fuera de los límites (calculamos la nueva posición)
:- move(T, D), holds(at(taxi(T), R1, C1), t-1), dir(D, DR, DC),
   R2 = R1 + DR,
   C2 = C1 + DC,
   not cell(R2, C2).

% No puedes moverte a una celda que es un edificio
:- move(T, D), holds(at(taxi(T), R1, C1), t-1), dir(D, DR, DC),
   R2 = R1 + DR,
   C2 = C1 + DC,
   building(R2, C2).

% No puedes recoger un pasajero (P) si el taxi (T) no está libre
:- pick(T, P), not holds(free(taxi(T)), t-1).

% No puedes recoger un pasajero (P) si no está en la misma celda que el taxi
:- pick(T, P), holds(at(taxi(T), RT, CT), t-1),
   not holds(at(pass(P), RT, CT), t-1).

% No puedes dejar un pasajero (P) si no está DENTRO del taxi (T)
:- drop(T, P), not holds(in(pass(P), taxi(T)), t-1).

% Un taxi solo puede realizar una acción de 'pick' o 'drop' a la vez
:- pick(T, P1), pick(T, P2), P1 != P2.
:- drop(T, P1), drop(T, P2), P1 != P2.
:- pick(T, _), drop(T, _).


% --- 3. EFECTOS DE LAS ACCIONES ---
% Cómo las acciones (válidas) cambian el estado en el tiempo t.

% --- Efectos de 'move' ---
holds(at(taxi(T), R2, C2), t) :-
    move(T, D),
    holds(at(taxi(T), R1, C1), t-1),
    dir(D, DR, DC),
    R2 = R1 + DR,
    C2 = C1 + DC.

% --- Efectos de 'pick' ---
% El pasajero (P) está 'en' el taxi (T)
holds(in(pass(P), taxi(T)), t) :-
    pick(T, P).

% El taxi (T) ya no está 'libre'
not holds(free(taxi(T)), t) :-
    pick(T, P).

% El pasajero (P) ya no está 'en' (at) la celda (porque está 'in' el taxi)
not holds(at(pass(P), R, C), t) :-
    pick(T, P),
    holds(at(pass(P), R, C), t-1).

% --- Efectos de 'drop' ---
% El pasajero (P) aparece 'en' (at) la celda del taxi
holds(at(pass(P), R, C), t) :-
    drop(T, P),
    holds(at(taxi(T), R, C), t-1). % El taxi no se ha movido este turno

% El taxi (T) vuelve a estar 'libre'
holds(free(taxi(T)), t) :-
    drop(T, P).

% El pasajero (P) ya no está 'en' (in) el taxi
not holds(in(pass(P), taxi(T)), t) :-
    drop(T, P).

% --- Efectos de 'wait' (y no-movimiento para pick/drop) ---
% Un taxi que espera, recoge o deja, se queda en su celda
% [Este bloque ha sido eliminado porque es redundante
% con la regla de inercia de la posición del taxi]


% --- 4. INERCIA (Lo que NO cambia) ---
% Si no se dice lo contrario, las cosas siguen igual.

% Inercia de la posición del taxi (si no se mueve)
holds(at(taxi(T), R, C), t) :-
    holds(at(taxi(T), R, C), t-1),
    not move(T, _).

% Inercia de la posición del pasajero (si no es recogido)
holds(at(pass(P), R, C), t) :-
    holds(at(pass(P), R, C), t-1),
    not pick(_, P).

% Inercia del pasajero DENTRO del taxi (si no es dejado)
holds(in(pass(P), taxi(T)), t) :-
    holds(in(pass(P), taxi(T)), t-1),
    not drop(T, P).

% Inercia del estado 'libre' del taxi (si no recoge o deja)
holds(free(taxi(T)), t) :-
    holds(free(taxi(T)), t-1),
    not pick(T, _), not drop(T, _).


% --- 5. RESTRICCIONES DEL DOMINIO (Enunciado) ---
% Reglas que deben cumplirse en TODO momento (t).

% 1. Dos taxis no pueden estar en la misma celda
:- holds(at(taxi(T1), R, C), t),
   holds(at(taxi(T2), R, C), t),
   T1 != T2.

% 2. Dos pasajeros no pueden estar en la misma celda (fuera del taxi)
:- holds(at(pass(P1), R, C), t),
   holds(at(pass(P2), R, C), t),
   P1 != P2.

% 3. No puede haber un pasajero 'en' (at) y otro 'in' (in) en la misma celda
:- holds(at(pass(P1), R, C), t),
   holds(in(pass(P2), taxi(T)), t),
   holds(at(taxi(T), R, C), t).

% 4. Dos taxis no pueden intercambiar (swap) posiciones
:- move(T1, D1), move(T2, D2),
   holds(at(taxi(T1), R1, C1), t-1),
   holds(at(taxi(T2), R2, C2), t-1),
   dir(D1, DR1, DC1), dir(D2, DR2, DC2),
   R1 + DR1 == R2,
   C1 + DC1 == C2, % T1 se mueve a la pos de T2
   R2 + DR2 == R1,
   C2 + DC2 == C1, % T2 se mueve a la pos de T1
   T1 != T2.


% --- PROGRAMA FINAL (Objetivo) ---
% Define cuándo consideramos que el plan ha terminado.
#program final(t).

% El objetivo para un pasajero (P) es estar en CUALQUIER estación
goal(P) :-
    holds(at(pass(P), R, C), t),
    station(R, C).

% El objetivo final se cumple si TODOS los pasajeros están en una estación
:- passenger(P), not goal(P).


% --- SALIDA ---
% Muestra las acciones que forman el plan.
#show move/2.
#show pick/2.
#show drop/2.
#show wait/1.