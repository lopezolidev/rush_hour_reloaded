# Rush Hour Reloaded - Prolog Project

[![es](https://img.shields.io/badge/lang-es-yellow.svg)](#versión-en-español)
[![en](https://img.shields.io/badge/lang-en-red.svg)](#english-version)

---
<a name="versión-en-español"></a>

## Versión en Español

### Descripción
Este proyecto implementa un solucionador (solver) para el juego de lógica **Rush Hour** utilizando el paradigma de programación lógica con **SWI-Prolog**.

El objetivo principal es encontrar la secuencia de movimientos óptima (mínima cantidad de pasos) para sacar el vehículo objetivo (ID 0) de un tablero de $6 \times 6$ casillas.

## Autores

* **Estudiante 1:** Lopez Sergio, 26.272.957
* **Estudiante 2:** Rocafull Oriana, 25.386.529

### Representación del Estado
El estado del tablero no se maneja como una matriz, sino como una **lista de estructuras**.

* **Vehículos:** Se representan mediante el predicado `vehicle(ID, Orientation, Row, Col, Length)`.
    * `ID`: Identificador único (0 es el objetivo).
    * `Orientation`: 'h' (horizontal) o 'v' (vertical).
    * `Row`, `Col`: Coordenadas de la "cabeza" (top-left) del vehículo (0-5).
    * `Length`: Longitud del vehículo (2 o 3).

> **Nota de Implementación:** El sistema incluye un normalizador (`normalizar/2`) que permite al programa aceptar indistintamente la estructura `v(...)` (dada en los ejemplos del enunciado) o `vehicle(...)` (requerida para la base de datos), asegurando robustez en la entrada de datos.

### Estrategia de Solución

#### 1. Algoritmo de Búsqueda: BFS (Búsqueda en Anchura)
Para garantizar que la solución encontrada sea la más corta posible (óptima), se implementó un algoritmo **BFS**.
* **Agenda:** Se utiliza una cola de caminos `[(EstadoActual, HistorialMovimientos) | Resto]`.
* **Control de Ciclos:** Se mantiene una lista de estados `Visitados` para evitar bucles infinitos y re-procesamiento de estados redundantes.
* **Inmutabilidad:** Los estados no se modifican destructivamente; cada movimiento genera un nuevo tablero independiente.

#### 2. Generación de Movimientos (Sin `findall`)
Se implementó un generador de sucesores manual (`iterar_vehiculos` y `try_step`) que:
1.  Recorre cada vehículo del tablero actual.
2.  Prueba secuencialmente movimientos desde 1 hasta 4 pasos (positivos y negativos).
3.  Acumula solo los movimientos válidos en una lista de hijos, invirtiéndola al final para priorizar el orden natural de exploración.

#### 3. Validación Física y "Barrido" (Sweeping)
Para evitar el problema del **"Efecto Túnel"** (donde un carro "salta" un obstáculo si se mueve varios pasos de golpe), se implementó una lógica de barrido en el predicado `nuevoEstado`:
* En lugar de calcular solo la posición final, el sistema calcula un **"Super Vehículo"** temporal que abarca desde la posición original hasta la final.
* Se verifica que ninguna celda de este trayecto choque con otros vehículos.
* Esto garantiza matemáticamente que el camino está completamente libre antes de autorizar el movimiento.

### Instrucciones de Ejecución

1.  Abra SWI-Prolog y cargue el archivo del proyecto:
    ```prolog
    ?- [nombre_del_archivo].
    ```

2.  Ejecute el predicado `solveRushHour` con una configuración inicial. Ejemplo:
    ```prolog
    ?- StartBoard = [v(0, h, 2, 0, 2), v(1, v, 0, 3, 3)],
       solveRushHour(StartBoard, Solution).
    ```

    **Salida esperada:**
    ```prolog
    Solution = [(1, 3), (0, 4)].
    ```

---


[Go to English Version / Ir a la versión en Inglés](#english-version)


<a name="english-version"></a>

## English Version

### Description
This project implements a solver for the **Rush Hour** logic puzzle using the Logic Programming paradigm with **SWI-Prolog**.

The main goal is to find the optimal sequence of moves (minimum number of steps) to extract the target vehicle (ID 0) from a $6 \times 6$ grid.

### State Representation
The board state is not managed as a matrix, but as a **list of structures**.

* **Vehicles:** Represented by the predicate `vehicle(ID, Orientation, Row, Col, Length)`.
    * `ID`: Unique identifier (0 is the target).
    * `Orientation`: 'h' (horizontal) or 'v' (vertical).
    * `Row`, `Col`: Coordinates of the "head" (top-left) of the vehicle (0-5).
    * `Length`: Vehicle length (2 or 3).

> **Implementation Note:** The system includes a normalizer (`normalizar/2`) allowing the program to accept both the `v(...)` structure (from the assignment examples) and `vehicle(...)` (required for the dynamic database), ensuring input robustness.

### Solution Strategy

#### 1. Search Algorithm: BFS (Breadth-First Search)
To guarantee the optimal solution (shortest path), a **BFS** algorithm was implemented.
* **Agenda:** Uses a queue of paths `[(CurrentState, MoveHistory) | Rest]`.
* **Cycle Control:** Maintains a `Visited` list to prevent infinite loops and redundant processing.
* **Immutability:** States are not destructively modified; each move generates a new independent board list.

#### 2. Move Generation (No `findall`)
A manual successor generator was implemented (`iterar_vehiculos` and `try_step`) which:
1.  Iterates through every vehicle on the current board.
2.  Sequentially attempts moves from 1 to 4 steps (positive and negative).
3.  Accumulates only valid moves into a child list, reversing it at the end to prioritize natural exploration order.

#### 3. Physical Validation & "Sweeping"
To avoid the **"Tunneling Effect"** (where a car "jumps" over an obstacle if moving multiple steps at once), a sweeping logic was implemented in the `nuevoEstado` predicate:
* Instead of calculating just the final position, the system calculates a temporary **"Super Vehicle"** covering the area from the start to the end position.
* It verifies that no cell in this path collides with other vehicles.
* This mathematically guarantees the path is clear before authorizing the move.

### Execution Instructions

1.  Open SWI-Prolog and load the project file:
    ```prolog
    ?- [project_file_name].
    ```

2.  Run the `solveRushHour` predicate with an initial configuration. Example:
    ```prolog
    ?- StartBoard = [v(0, h, 2, 0, 2), v(1, v, 0, 3, 3)],
       solveRushHour(StartBoard, Solution).
    ```

    **Expected Output:**
    ```prolog
    Solution = [(1, 3), (0, 4)].
    ```

---
[Go to Spanish Version / Ir a la versión en Español](#versión-en-español)

<br>
<br>

***

## Authors

* **Student 1:** Lopez Sergio.
* **Student 2:** Rocafull Oriana.

---

*Proyecto realizado para la asignatura Lenguajes de Programación, Universidad Central de Venezuela (Semestre 2-2025).*