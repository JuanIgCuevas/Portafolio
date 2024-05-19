#ifndef LIBRO_H
#define LIBRO_H

#include <iostream>

using namespace std;

class Libro {
    private:
        string id;
        string titulo;
        string autor;
        string genero;
        int paginas;
        int puntaje;
        int ejemplares;
        int ejemplaresLibres;

    public:
        Libro();
        Libro(string id, string titulo, string autor, string genero, int paginas, int puntaje, int ejemplares);
        int obtenerPuntaje() const;
        int cantidadEjemplares() const;
        string obtenerTitulo() const;
        string obtenerId() const;
        void asignarLibro();
        void liberarLibro();
        int cantidadLibres() const;

        
};


#endif /* LIBRO_H */
