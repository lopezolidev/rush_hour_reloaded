:- dynamic vehicle/5.

% Convierte v(...) a vehicle(...)
normalizar(v(Id, Or, R, C, L), vehicle(Id, Or, R, C, L)).

% Si ya es vehicle(...), lo deja igual
normalizar(vehicle(Id, Or, R, C, L), vehicle(Id, Or, R, C, L)).

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
    cargarVehiculos(VehicleList) . % validamos vehiculos y si no hay solapamientos

cargarVehiculos([]).
cargarVehiculos([VehiculoInput | Resto]) :-
    normalizar(VehiculoInput, VehiculoCanónico),
    es_valido(VehiculoCanónico), 
    assertz(VehiculoCanónico),
    cargarVehiculos(Resto).
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
    \+ chocanCarros(ID, Cells), !.

nuevoEstado(Or, Row, Col, Len, Steps, Cells) :-
    % 1. Calculamos la coordenada de inicio (el mínimo entre actual y futura)
    (Steps >= 0 -> 
        Inicio = Col, 
        InicioRow = Row 
    ; 
        Inicio is Col + Steps, % Si es negativo, el inicio está a la izquierda
        InicioRow is Row + Steps
    ),

    % 2. Longitud original + Valor Absoluto de los pasos
    abs(Steps, PasosAbs),
    SuperLen is Len + PasosAbs,

    % 3. Generamos las celdas como si fuera un solo carro estático 
    (Or = h ->
        generarHorizontal(Row, Inicio, SuperLen, Cells)
    ;
        generarVertical(InicioRow, Col, SuperLen, Cells)
    ).

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


% el vehículo actual es el vehículo que encaja por ID -> usando v(...)
moveVehicle(
    [v(ID, Or, R, C, L) | RV],
    ID, Steps, [FV | RV]) :-

    % definimos el nuevo lugar del vehículo (cabeza)
    movement(Or, R, C, Steps, NewR, NewC) ,

    % definimos el Primer Vehículo con su nueva posición
    FV = vehicle(ID, Or, NewR, NewC, L), !. % y cortamos


% el vehículo actual No es el vehículo a mover -> usando v(...)
moveVehicle([v(ID, Or, R, C, L) | RV] ,
        ID, Steps, [v(_, Or, R, C, L) | NewState]) :-
    
    % se ignora el vehículo actual y se llama al predicado nuevamente
    moveVehicle(RV, ID, Steps, NewState).
    % el vehículo actual es el vehículo que encaja por ID -> usando v(...)

moveVehicle(
    [vehicle(ID, Or, R, C, L) | RV],
    ID, Steps, [FV | RV]) :-

    % definimos el nuevo lugar del vehículo (cabeza)
    movement(Or, R, C, Steps, NewR, NewC) ,

    % definimos el Primer Vehículo con su nueva posición
    FV = vehicle(ID, Or, NewR, NewC, L), !. % y cortamos


% el vehículo actual No es el vehículo a mover -> usando v(...)
moveVehicle([vehicle(ID, Or, R, C, L) | RV] ,
        ID, Steps, [vehicle(_, Or, R, C, L) | NewState]) :-
    
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
%%%%%                                 %%%%%  
%%%%                                   %%%%
%%%                                     %%%

solveRushHour(StartBoard, Solution) :-
    % La agenda inicial tiene un solo camino: [ (StartBoard, init) ]
    % init es solo para empezar, unificará con el primero
    bfs([ (StartBoard, []) ], [], Solution).

% caso base: el estado actual es el estado solución
bfs([ (EstadoActual, Movimientos) | _ ] , _ , SolRev) :-
    es_solucion(EstadoActual) , 
    
    reverse(Movimientos, SolRev), !. % verifica si el estado actual es meta y sea la primera

% caso recursivo 1: el estado actual No está repetido y tampoco es solución -> explorar
bfs([ (EstadoActual, Movs) | RestoCams ], Visitados, Solucion) :-

    % el estado actual no es solución pero tampoco está repetido
    \+ member(EstadoActual, Visitados) ,

    % marcamos el estado actual como visitado
    NuevosVisitados = [ EstadoActual |  Visitados],

    % generador de nuevos caminos válidos
    generarNuevosCaminos( (EstadoActual, Movs), EstadoActual,NuevosCaminos) ,

    % construimos la nueva agenda de caminos por visitar (Nuevo Resto Caminos)
    append(RestoCams, NuevosCaminos, NuevoRestoCams) ,

    % el algoritmo es finito porque hay un número finito de aristas
    bfs(NuevoRestoCams, NuevosVisitados, Solucion) .


% caso recursivo 2: el estado actual Sí está repetido y no es solución -> ignorar
bfs([ (EstadoActual, _) | RestoCams ], Visitados, Solucion) :-

    % confirmamos que ya fue visitado
    member(EstadoActual, Visitados),

    % ignoramos el estado actual y continuamos
    bfs(RestoCams, Visitados, Solucion).

% definición del generador del predicado generador de nuevos caminos
generarNuevosCaminos((Tablero, MovsPrevios), TableroCompleto, NuevosCaminos) :-
    % Llamamos a la iteración de vehículos
    % primer nivel de recursión
    % Args: ListaVehiculosRestantes, TableroCompleto, HistoriaMovs, Acumulador, Resultado
    iterar_vehiculos(Tablero, TableroCompleto, MovsPrevios, [], NuevosCaminos).

% Caso Base: No quedan vehículos por revisar. El acumulador es el resultado.
iterar_vehiculos([], _, _, Accum, Accum).

% Caso Recursivo:
iterar_vehiculos([Vehiculo | RestoVehiculos], TableroCompleto, MovsPrevios, Accum, Result) :-
    normalizar(Vehiculo, vehicle(ID, _, _, _, _)),

    % Obtenemos los hijos generados solo por mover este ID
    recolectar_movimientos_id(ID, TableroCompleto, MovsPrevios, HijosDeEsteVehiculo),
    
    % Los agregamos al acumulador
    append(Accum, HijosDeEsteVehiculo, NuevoAccum),
    
    % Seguimos con el siguiente vehículo
    iterar_vehiculos(RestoVehiculos, TableroCompleto, MovsPrevios, NuevoAccum, Result).

recolectar_movimientos_id(ID, Tablero, MovsPrevios, ListaHijos) :-
    % Probamos los 6 pasos básicos.
    % Usamos un acumulador auxiliar para ir guardando los que sí funcionen.
    try_step(ID, 1, Tablero, MovsPrevios, [], L1),
    try_step(ID, -1, Tablero, MovsPrevios, L1, L2),
    try_step(ID, 2, Tablero, MovsPrevios, L2, L3),
    try_step(ID, -2, Tablero, MovsPrevios, L3, L4),
    try_step(ID, 3, Tablero, MovsPrevios, L4, L5),
    try_step(ID, -3, Tablero, MovsPrevios, L5, L6),
    try_step(ID, 4, Tablero, MovsPrevios, L6, L7),
    try_step(ID, -4, Tablero, MovsPrevios, L7, ListaHijos).

% Helper: Intenta un paso. Si es válido, lo agrega. Si no, devuelve el acumulador igual.
try_step(ID, Steps, Tablero, MovsPrevios, Accum, NewAccum) :-
    % Verificar validez
    es_valido_en_lista(Tablero, ID, Steps),
    
    % Mover 
    moveVehicle(Tablero, ID, Steps, NuevoTablero),
    
    % Crear el nuevo camino: (NuevoTablero, [(ID, Steps) | Historial])
    NuevoCamino = (NuevoTablero, [(ID, Steps) | MovsPrevios]),
    
    % Agregar a la lista
    NewAccum = [NuevoCamino | Accum], !.

% Caso de fallo: Si es_valido falla, entra aquí y no agrega nada.
try_step(_, _, _, _, Accum, Accum).

es_valido_en_lista(Board, ID, Steps) :-
    % tomamos el vehículo
    member(vehicle(ID, Or, R,C,L), Board) ,

    % verificamos que no solapa con ningún otro vehículo

    % calculemos las celdas en las que se moverá el carro
    nuevoEstado(Or, R, C, L, Steps, Cells),

    % vemos si el movimiento no sacó al vehículo del tablero
    dentroTablero(Cells) ,

    \+ chocanCarros2(ID, Cells, Board).    
    
% CASO 1: Choca con la Cabeza (Encontramos un choque, paramos y devolvemos true)
chocanCarros2(MyID, PathCells, [FirstCar | _]) :-
    FirstCar = vehicle(OtherID, _, _, _, _), % Extraemos datos
    MyID \= OtherID,                         % No soy yo mismo
    celdasOcupadas(FirstCar, FirstCells),    % Generamos celdas del obstáculo
    
    % Intersección
    member(Cell, PathCells),
    member(Cell, FirstCells), 
    !. % Si encontramos un choque, no buscamos más. Éxito.

% CASO 2: No chocó con la Cabeza, revisamos la Cola (Recursión)
chocanCarros2(MyID, PathCells, [_ | RestCars]) :-
    chocanCarros2(MyID, PathCells, RestCars).