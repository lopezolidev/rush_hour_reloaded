:- dynamic vehicle/5.


%%%                                   %%%
%%%%                                 %%%%
%%%%%                               %%%%%
% ----------- PARTE I.-------------------
%%%%%                               %%%%%  
%%%%                                 %%%%
%%%                                   %%%

% initalBoard(VehicleList) -> recibe una lista de vehículos y si estos pasan los filtros se irán 
% agregando al tablero

initialBoard([]).
initialBoard(VehicleList) :-
    retractall(vehicle(_, _, _, _, _)) , % borramos cualquier cosa existente en la BC
    validarLista(VehicleList) , % validamos vehiculos y si no hay solapamientos
    generarVehiculos(VehicleList),% hacer los asserts 
    !. % no necesitamos validar el resto del árbol

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
    Fin =< 6, !.
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

%%%                                   %%%
%%%%                                 %%%%
%%%%%                               %%%%%
% ----------- PARTE II.-------------------
%%%%%                               %%%%%  
%%%%                                 %%%%
%%%                                   %%%


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

%%%                                     %%%
%%%%                                   %%%%
%%%%%                                 %%%%%
% ----------- PARTE III.----------------- %
%%%%%                                 %%%%%  
%%%%                                   %%%%
%%%                                     %%%


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


%%%                                     %%%
%%%%                                   %%%%
%%%%%                                 %%%%%
% ----------- PARTE IV.------------------ %
%%%%%       
                          %%%%%  
%%%%                                   %%%%
%%%                                     %%%

solveRushHour(StartBoard, Solution) :-
    % La agenda inicial tiene un solo camino: [ (StartBoard, init) ]
    % init es solo para empezar, unificará con el primero
    bfs([ [(StartBoard, init)] ], [], SolutionRev),
    
    % El BFS devuelve la solución al revés, hay que voltearla
    sacar_movimientos(SolutionRev, Solution).

% caso base, el primer camino de la agenda llega al destino
bfs([ [(EstadoActual, Movimientos) | RestoCaminos] | _ ], _ , [ (EstadoActual | Movimientos) | RestoCaminos]) :-
    es_solucion(EstadoActual) . % verifica si el estado actual es meta

% caso recursivo -> explorar
bfs([ CaminoActual | RestoAgenda ], Visitados, Solucion) :-
    CaminoActual = [ (EstadoActual, _) | _ ], % Extraemos el estado actual (cabeza del camino)
    
    % 1. GENERADOR 
    % Buscamos todos los movimientos posibles desde EstadoActual
    findall(
        [(NuevoEstado, (ID, Steps)) | CaminoActual], % Construimos el nuevo camino extendido
        (
            % Lógica del generador:
            member(Vehiculo, EstadoActual),       % A. Elige un vehículo de la lista
            Vehiculo = vehicle(ID, _, _, _, _),   %    Extrae su ID
            generar_pasos(Steps),                 % B. Propone unos pasos (ej: -2, -1, 1, 2)
            
            % C. Valida en la LISTA 
            es_valido_en_lista(EstadoActual, ID, Steps), 
            
            % D. Genera el nuevo estado
            moveVehicle(EstadoActual, ID, Steps, NuevoEstado),
            
            % E. Verifica que no sea un estado repetido (Ciclos)
            \+ member(NuevoEstado, Visitados)
        ),
        NuevosCaminos
    ),
    % 2. Actualizar Visitados (Extraer los estados de los nuevos caminos)
    extraer_estados(NuevosCaminos, NuevosEstados),
    append(Visitados, NuevosEstados, NuevosVisitados),
    
    % 3. Agregar al FINAL de la agenda (Cola FIFO -> BFS)
    append(RestoAgenda, NuevosCaminos, NuevaAgenda),
    
    % 4. Recursión
    bfs(NuevaAgenda, NuevosVisitados, Solucion).

arco(0,2,2).
arco(0,1,4).
arco(2,3,1).
arco(1,3,2).
arco(1,4,5).
arco(3,4,1).
arco(3,5,1).
arco(4,5,2).
% origen y destino permutados
arco(2,0,2).
arco(1,0,4).
arco(3,2,1).
arco(3,1,2).
arco(4,1,5).
arco(4,3,1).
arco(5,3,1).
arco(5,4,2).

visitado(X). % X ya ha sido visitado en la búsqueda

camino(U, V) :- arco(U, V, _).
camino(U, V) :- arco(U, X, _),
                not(visitado(X)) ,
                assertz(visitado(X)) ,
                camino(X, V).

% lo siguiente funciona como un reset de la ejecución
caminoi(U, V) :-    retractall(visitado(_)) ,
                    assert(visitado(U)) ,
                    camino(U, V).