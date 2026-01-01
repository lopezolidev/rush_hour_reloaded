:- dynamic vehicle/5.

% -- PARTE I -- %

% initalBoard(VehicleList) -> recibe una lista de vehículos y si estos pasan los filtros se irán 
% agregando al tablero

initialBoard([]).
initialBoard(VehicleList) :-
    retractall(vehicle(_, _, _, _, _)) , % borramos cualquier cosa existente en la BC
    validarLista(VehicleList) , % validamos vehiculos y si no hay solapamientos
    generarVehiculos(VehicleList). % hacer los asserts

validarLista([]).
validarLista([CurrentVehicle | ListOfVehicles]) :-
    es_valido(CurrentVehicle) ,
    noHaySol(CurrentVehicle, ListOfVehicles),
    validarLista(ListOfVehicles) .
% predicado que valida las listas y que la estructura básica cumpla con los requerimientos
% así como verificar que no hay solapamiento del vehículo actual respecto a los demás


es_valido(vehicle(Id, Or, Row, Col, Len)) :-
    Id >= 0,
    member(Or, [h, v]),
    Row >= 0 , Row =< 5 ,
    Col >= 0 , Col =< 5 ,
    member(Len, [2, 3]),
    % Validar que no se salga del tablero según su largo
    (Or = h -> Fin is Col + Len ; Fin is Row + Len),
    Fin =< 6.
% estructura básica de cómo existe un vehiculo en este programa, parte de la BC que se irá modificando



noHaySol(_, []).
noHaySol(V1, [V2 | RestVehicles]) :-
    \+ choque(V1, V2),
    noHaySol(V1, RestVehicles).



% verificación de choque -> ocurre si hay coincidencia de al menos 1 celda entre ambos vehiculos
choque(V1, V2):-
    celdasOcupadas(V1, ListOfCellsA) ,
    celdasOcupadas(V2, ListOfCellsB) ,
    member(Cell, ListOfCellsA) ,
    member(Cell, ListOfCellsB) , !.
% si ya encuentra coincidencia devuelve true, no hay falta ver si hay más coincidencias entre las celdas




% celdas ocupadas si el vehículo tiene orientación horizontal
celdasOcupadas(vehicle(_, h, Row, Col, L), Cells) :-
    generarHorizontal(Row, Col, L, Cells).
% celdas ocupadas si el vehículo tiene orientación vertical
celdasOcupadas(vehicle(_, v, Row, Col, L), Cells) :-
    generarVertical(Row, Col, L, Cells).



% si la distancia es 0, ya no agregamos más celdas
generarHorizontal(_, _ , 0 , []).
% caso cuando nos queda distancia y estamos produciendo la lista de celdas
generarHorizontal(Row, Col, L, [(Row, Col) | RestCells]):-
    L > 0 ,
    NewCol is Col + 1 ,
    NewLength is L - 1,
    generarHorizontal(Row, NewCol, NewLength, RestCells).

% el equivalente vertical.
generarVertical(_, _, 0, []).
generarVertical(Row, Col, L, [(Row, Col) | RestCells]) :-
    L > 0,
    NewRow is Row + 1,
    NewLength is L - 1,
    generarVertical(NewRow, Col, NewLength, RestCells).



% generación de soluciones
generarVehiculos([]).
generarVehiculos([V | R]) :-
    assertz(V),
    generarVehiculos(R).