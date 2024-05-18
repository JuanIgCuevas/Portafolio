
    materia(6111,"introducion a la programacion 1").
    materia(6112,"analisis matematico 1").
    materia(6113,"algebra 1").
    materia(6114,"quimica").
    materia(6121,"ciencias de la Computacion 1").
    materia(6122,"introduccion a la programacion 2").
    materia(6123,"algebra lineal").
    materia(6124,"fisica General").
    materia(6125,"matematica discreta").

    materia(6211,"ciencias de la Computacion II").
    materia(6212,"analisis y Disenio_de_Algoritmos I").
    materia(6213,"introduccion a la Arquitectura de Sistemas").
    materia(6214,"analisis Matematico II").
    materia(6215,"electricidad y Magnetismo").
    materia(6221,"analisis y Disenio de Algoritmos II").
    materia(6222,"comunicacion de Datos I").
    materia(6223,"probabilidades y Estadistica").
    materia(6224,"electronica Digital").
    cursand(0,"ingles").

    cursand(6311,"programacion Orientada a Objetos").
    materia(6312,"estructuras de Almacenamiento de Datos").
    cursand(6321,"programacion Exploratoria").
    cursand(6325,"investigacion Operativa I").
    
    debefinales(6212).
    debefinales(6214).
    debefinales(6221).
    debefinales(6223).
    debefinales(6224).
    debefinales(6312).

  cursadas(X):- materia(_,X).

  cursando(X):- cursand(_,X).

  finales(X):- debefinales(Y),materia(Y,X).

