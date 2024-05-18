%HECHOS
padrede(martin,luis).
padrede(luis,jose).
padrede(luis,pedro).
espadre(martin).
espadre(luis).

%REGLAS
hijode(B,A):-padrede(A,B).

%REGLAS_AND
abuelode(A,C):-padrede(A,B),padrede(B,C).
hermanode(B,C):-espadre(A),padrede(A,B),padrede(A,C).

%REGLAS_OR
familiarde(A,B):-padrede(A,B);hijode(A,B);hermanode(A,B);abuelode(A,B).