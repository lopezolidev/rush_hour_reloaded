isValidMove(ID, Steps) :-
    % obtengamos primero el carro a mover
    vehicle(ID, Orientation, Row, Col, Length),

    % ahora calculemos las celdas en las que se moverá el carro
    nuevoEstado(Orientation, Row, Col, Length, Steps,Cells),

    % luego de esto, verificamos si está dentro del tablero esta serie de celdas
    dentroTablero(Cells) ,

    % ahora verificamos que no haya ningún choque con cualquier otro carro
    \+ chocanCarros(ID, Cells).

nuevoEstado(Orientation, Row, Col, Length, Steps, Cells) :-
    % caso cuando los pasos son positivos
    (Steps >= 0 ,
    movimientoPositivo(Orientation, Row, Col, Length, Steps, Cells) , !)
    % este cut impide la revisión de la siguiente regla, generando un solo resultado   
    ;
    % caso cuando los pasos son negativos
    (Steps < 0 ,
    movimientoNegativo(Orientation, Row, Col, Length, Steps, Cells) , !).

%
%%
%%% ---------------- movimiento positivo
%%
%

%%% ---------------- para caso del movimiento positivo horizontal

% caso base: cuando la cantidad de pasos llega a 0 y la longitud a 1,
% retorna lista con (fila, columna)   -> sirve para vertical también
movimientoPositivo(_, R, C, 1, 0, [(R, C) | []]) :- !.

% caso recursivo 1: cuando se ha consumido la distancia solamente, 
% empezamos a consumir los pasos
movimientoPositivo(h, Row, Col, 1, Steps, [(Row, Col) | Rest]) :-
    Steps > 0 ,
    NewCol is Col + 1 ,
    NewStep is Steps - 1 ,
    % restamos -1 a Steps y sumamos a Col porque es movimiento positivo y horizontal
    movimientoPositivo(h, Row, NewCol, 1, NewStep, Rest).

% caso recursivo 2: primero consumimos la distancia y luego se consumirán los pasos
movimientoPositivo(h, Row, Col, Length, Steps, [(Row, Col) | Rest]) :-  
    Length > 1 ,
    Steps > 0 ,
    NewCol is Col +1 ,
    NewLength is Length - 1,
    % restamos -1 a length y sumamos a Col porque es movimiento positivo y horizontal
    movimientoPositivo(h, Row, NewCol, NewLength, Steps, Rest).

%%% ---------------- para caso del movimiento positivo vertical

% caso recursivo 1: cuando se ha consumido la distancia solamente, 
% empezamos a consumir los pasos
movimientoPositivo(v, Row, Col, 1, Steps, [(Row, Col) | Rest]) :-
    NewRow is Row + 1 ,
    NewStep is Steps - 1 ,
    % restamos -1 a Steps y sumamos a Row porque es movimiento positivo y vertical
    movimientoPositivo(v, NewRow, Col, 1, NewStep, Rest).

% caso recursivo 2: primero consumimos la distancia y luego se consumirán los pasos
movimientoPositivo(v, Row, Col, Length, Steps, [(Row, Col) | Rest]) :-    
    NewRow is Row + 1 ,
    NewLength is Length - 1,
    % restamos -1 a length y sumamos a Col porque es movimiento positivo y horizontal
    movimientoPositivo(v, NewRow, Col, NewLength, Steps, Rest).
%
%%
%%% ---------------- movimiento negativo 
%%
%

% caso base: cuando la cantidad de pasos llega a 0 y la longitud a 1,
% retorna lista con (fila, columna)   -> sirve para vertical también
movimientoNegativo(_, R, C, 1, 0, [(R, C) | []]) :- !.

% caso recursivo 1: cuando se ha consumido la distancia solamente, 
% empezamos a consumir los pasos
movimientoNegativo(h, Row, Col, 1, Steps, [(Row, Col) | Rest]) :-
    Steps < 0 ,
    NewCol is Col - 1 ,
    NewStep is Steps + 1 ,
    % sumamos +1 a Steps y restamos a Col porque es movimiento negativo y horizontal
    movimientoNegativo(h, Row, NewCol, 1, NewStep, Rest).

% caso recursivo 2: primero consumimos la distancia y luego se consumirán los pasos
movimientoNegativo(h, Row, Col, Length, Steps, [(Row, Col) | Rest]) :- 
    Length > 1 ,
    Steps < 0 ,
    NewCol is Col -1 ,
    NewLength is Length - 1,
    % restamos -1 a length y restamos a Col porque es movimiento negativo y horizontal
    movimientoNegativo(h, Row, NewCol, NewLength, Steps, Rest).

%%% ---------------- para caso del movimiento negativo vertical

% caso recursivo 1: cuando se ha consumido la distancia solamente, 
% empezamos a consumir los pasos
movimientoNegativo(v, Row, Col, 1, Steps, [(Row, Col) | Rest]) :-
    Steps < 0 ,
    NewRow is Row - 1 ,
    NewStep is Steps + 1 ,
    % sumamos +1 a Steps y restamos a Row porque es movimiento negativo y vertical
    movimientoNegativo(v, NewRow, Col, 1, NewStep, Rest).

% caso recursivo 2: primero consumimos la distancia y luego se consumirán los pasos
movimientoNegativo(v, Row, Col, Length, Steps, [(Row, Col) | Rest]) :-  
    Length > 0 ,
    Steps < 0 ,
    NewRow is Row - 1 ,
    NewLength is Length - 1,
    % restamos -1 a length y restamos a Col porque es movimiento negativo y vertical
    movimientoNegativo(v, NewRow, Col, NewLength, Steps, Rest).


% ahora a verificar si están dentro del tablero las celdas obtenidas
dentroTablero([]).
dentroTablero([(X, Y) | Cells]) :-
    X >= 0 ,
    X =< 5 ,
    Y >= 0 ,
    Y =< 5 ,
    dentroTablero(Cells).

chocanCarros(MyID, PathCells) :-
    % 1. GENERADOR: Llamamos a la BD. 
    % Prolog pausa aquí, trae el primer carro, y si falla más abajo, 
    % vuelve aquí y trae el segundo.
    vehicle(OtherID, Or, Row, Col, Len),
    
    % 2. FILTRO: Asegurarnos de no chocar con nosotros mismos
    MyID \= OtherID,
    
    % 3. CÁLCULO: Generamos las celdas de ese OTRO carro
    OtherCar = vehicle(OtherID, Or, Row, Col, Len),
    celdasOcupadas(OtherCar, OtherCells),
    
    % 4. INTERSECCIÓN: busca celdas en común entre cualquier celda del vehículo actual y el otro
    member(Cell, PathCells),   % Toma una celda de mi camino
    member(Cell, OtherCells),  % Verifica si está en el otro carro
    
    % 5. CORTE: Si encontramos UN choque, ya es suficiente -> true.
    !.

