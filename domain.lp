#program base.

rows(4).
cols(9).

taxi(1).
taxi(2).
passenger(a).
passenger(b).
passenger(c).
cell(0,0).
cell(0,1).
cell(0,2).
cell(0,3).
cell(0,4).
cell(0,5).
cell(0,6).
cell(0,7).
cell(0,8).
cell(1,0).
cell(1,1).
cell(1,2).
cell(1,3).
cell(1,4).
cell(1,5).
cell(1,6).
cell(1,7).
cell(1,8).
cell(2,0).
cell(2,1).
cell(2,2).
cell(2,3).
cell(2,4).
cell(2,5).
cell(2,6).
cell(2,7).
cell(2,8).
cell(3,0).
cell(3,1).
cell(3,2).
cell(3,3).
cell(3,4).
cell(3,5).
cell(3,6).
cell(3,7).
cell(3,8).
building(1,1).
building(1,2).
building(1,3).
building(1,4).
building(1,5).
building(1,6).
building(1,7).
building(2,1).
building(2,7).
station(1,8).
station(2,3).
station(2,5).

#program initial.
% Taxi locations
holds(at(taxi(1),2,0),0).
holds(at(taxi(2),3,6),0).

% Passenger locations
holds(at(pass(a),0,4),0).
holds(at(pass(b),0,6),0).
holds(at(pass(c),3,2),0).
