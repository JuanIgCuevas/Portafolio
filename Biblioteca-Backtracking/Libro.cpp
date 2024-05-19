#include "Libro.h"

Libro::Libro() {

}

Libro::Libro(string id, string titulo, string autor, string genero, int paginas, int puntaje, int ejemplares) {
    this->id = id;
    this->titulo = titulo;
    this->autor = autor;
    this->genero = genero;
    this->paginas = paginas;
    this->puntaje = puntaje;
    this->ejemplares = ejemplares;
    this->ejemplaresLibres = ejemplares;
}

int Libro::obtenerPuntaje() const {
    return puntaje;
}

int Libro::cantidadEjemplares() const {
    return ejemplares;
}

string Libro::obtenerTitulo() const {
    return titulo;
}

string Libro::obtenerId() const {
    return id;
}

void Libro::asignarLibro() {
    if(ejemplaresLibres <= ejemplares && ejemplaresLibres > 0) {
        ejemplaresLibres = ejemplaresLibres - 1;
    }
}

void Libro::liberarLibro() {
    if(ejemplaresLibres != ejemplares) {
        ejemplaresLibres++;
    }

}

int Libro::cantidadLibres() const {
    return ejemplaresLibres;
}