#program initial.
location(table).
location(B) :- block(B).

action(move(B,table)) :- block(B), location(L), B!=L.
action(move(B,C)) :- g(B,C).

#program dynamic.
% Effect axioms.
h(on(B),L) :- o(move(B,L)).

% Exception axioms
% Cannot move B on something if B has already something on it
:- o(move(B,_)), 'unclear(B).
% Cannot move something on L if L has already something on it
:- o(move(_,L)), 'unclear(L).

% Control constraints

:- o(move(B,table)), 'h(on(B), table).

#program always.
unclean(B) :- h(on(_),B), _block(B).

#program final.

:- _g(B,L), not h(on(B), L).

