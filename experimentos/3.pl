% el vehículo actual es el vehículo que encaja por ID
moveVehicle(
    [vehicle(ID, Or, R, C, L) | RV],
    ID, Steps, [FV | RV]) :-

    % definimos el nuevo lugar del vehículo (cabeza)
    movement(Or, R, C, Steps, NewR, NewC) ,

    % definimos el Primer Vehículo con su nueva posición
    FV = vehicle(ID, Or, NewR, NewC, L), !. % y cortamos

% el vehículo actual No es el vehículo a mover
moveVehicle([vehicle(ID2, Or, R, C, L) | RV] ,
        ID, Steps, [vehicle(ID2, Or, R, C, L) | NewState]) :-
    
    % se ignora el vehículo actual y se llama al predicado nuevamente
    moveVehicle(RV, ID, Steps, NewState).

% definimos la nueva posición del vehículo
% Caso Horizontal: Se mantiene R, cambia C
movement(h, R, C, Steps, R, NewC) :- 
    NewC is C + Steps.

% Caso Vertical: Se mantiene C, cambia R
movement(v, R, C, Steps, NewR, C) :- 
    NewR is R + Steps.