#include <iostream>
#include <fstream>
#include <sstream>
#include "Libro.h"
#include <vector>
#include <set>
#include <map>
using namespace std;

#define SOLUCIONES_MAXIMAS 1000000

struct estadoAlumno
{
    int puntajeActual;
    set<string> libros;
    bool aprobado;
};

struct estadoFinal
{
    bool solucion;
    int cantidadAprobados;
    int cantidadEjemplaresLibres;
    map<int, estadoAlumno> asignacion;
};

vector<Libro *> procesar_archivo_entrada(string origen, int &cantidadEjemplares, int &cantidadLibros, int &puntajeMax);

void imprimirSolucion(estadoFinal solucion);
void back(estadoFinal &parcial, estadoFinal &final, vector<Libro *> &conjunto, int alumnos, int actual, int cantidadLibros, int puntajeRequerido, int posicion, int &cantidadSoluciones);
void asignarLibro(estadoFinal &estado, int alumnoActual, vector<Libro *> &conjunto, int libroActual, int puntajeRequerido);
void quitarLibro(estadoFinal &estado, int alumnoActual, vector<Libro *> &conjunto, int libroActual, int puntajeRequerido);

bool poda(estadoFinal &parcial, estadoFinal &final, int alumno, int posicion, vector<Libro *> &conjunto);

int main()
{
    int cantidadLibros = 0;
    int cantidadEjemplares = 0;
    int puntajeTotal = 0;

    vector<Libro *> biblioteca;

    string dataset;
    cout << "Ingrese nombre del dataset: ";
    cin >> dataset;
    biblioteca = procesar_archivo_entrada("./datasets/" + dataset, cantidadEjemplares, cantidadLibros, puntajeTotal);

    char repetir;
    
    do {
        int alumnos, puntaje;
        cout << "Ingrese cantidad de alumnos y puntaje mínimo para aprobar: " << endl;
        cin >> alumnos >> puntaje;
        int cantidadMax = min(puntajeTotal / puntaje, alumnos);
        cout << "Podrían aprobar como máximo: " << cantidadMax << endl;

        estadoFinal parcial;
        estadoFinal final;
        parcial.cantidadEjemplaresLibres = cantidadEjemplares;
        parcial.cantidadAprobados = 0;
        parcial.solucion = false;

        estadoAlumno estado;
        estado.aprobado = false;
        estado.puntajeActual = 0;
        for (int j = 1; j <= cantidadMax; j++)
        {
            parcial.asignacion[j] = estado;
        }
        final = parcial;
        int cantSol = 0;  // Inicializar cantSol antes de usar
        back(parcial, final, biblioteca, cantidadMax, 1, cantidadLibros, puntaje, 0, cantSol);

        if(cantSol < SOLUCIONES_MAXIMAS) {
            cout << "Fue la solución número: " << cantSol << endl;
        } else {
            cout << "Se cortó el algoritmo antes de que termine, la solución no es necesariamente la mejor" << endl;
        }
        imprimirSolucion(final);
        
        cout << "Desea volver a realizar una simulación (S/N)?: " << endl;
        cin >> repetir;
        //S: Se pide nuevamente cantidad de alumnos y puntaje mínimo con el mismo dataset.
    } while(repetir == 'S');

    for(auto it = biblioteca.begin(); it != biblioteca.end(); it++) {
        delete(*it);
    }
    return 0;
}

void imprimirSolucion(estadoFinal solucion)
{
    cout << "Asignación" << endl;
    for (const auto &itFinal : solucion.asignacion)
    {
        cout << "Alumno: " << itFinal.first;
        cout << " ----- ";
        cout << "Libros: ";
        for (const auto &itLib : itFinal.second.libros)
        {
            cout << itLib << " --- ";
        }
        cout << "Puntos : " << itFinal.second.puntajeActual;
        cout << " " << endl;
    }

    cout << "----------------------" << endl;
    cout << "Aprobaron en total: " << solucion.cantidadAprobados << endl;
}

void back(estadoFinal &parcial, estadoFinal &final, vector<Libro *> &conjunto, int alumnos, int actual, int cantidadLibros, int puntajeRequerido, int posicion, int &cantidadSoluciones)
{
    if (parcial.cantidadAprobados == alumnos || parcial.cantidadEjemplaresLibres == 0 || posicion >= cantidadLibros)
    {
        cantidadSoluciones++;

        if (parcial.cantidadAprobados == alumnos)
        {
            parcial.solucion = true;
        }

        if (parcial.cantidadAprobados > final.cantidadAprobados)
        {
            final = parcial;
        }
    }
    else
    {
        int alumnoActual = 1;
        while (alumnoActual <= alumnos && !final.solucion && cantidadSoluciones < SOLUCIONES_MAXIMAS)
        {
            asignarLibro(parcial, alumnoActual, conjunto, posicion, puntajeRequerido);

            if(conjunto[posicion]->cantidadLibres() > 0 && alumnoActual <= alumnos) {
                back(parcial, final, conjunto, alumnos, alumnoActual + 1, cantidadLibros, puntajeRequerido, posicion, cantidadSoluciones);
            } else {
                back(parcial, final, conjunto, alumnos, alumnoActual, cantidadLibros, puntajeRequerido, posicion + 1, cantidadSoluciones);
            }

            quitarLibro(parcial, alumnoActual, conjunto, posicion, puntajeRequerido);
            alumnoActual++;
        }
    }
}

bool poda(estadoFinal &parcial, estadoFinal &final, int alumno, int posicion, vector<Libro *> &conjunto)
{
    bool podar = true;
    if (final.asignacion[alumno].libros.find(conjunto[posicion]->obtenerId()) != final.asignacion[alumno].libros.end())
    {
        podar = false;
    }
    return podar;
}

void asignarLibro(estadoFinal &estado, int alumnoActual, vector<Libro *> &conjunto, int libroActual, int puntajeRequerido)
{
    auto it = estado.asignacion.find(alumnoActual);

    if (it->second.libros.find(conjunto[libroActual]->obtenerId()) == it->second.libros.end())
    {
        it->second.puntajeActual += conjunto[libroActual]->obtenerPuntaje();
        it->second.libros.insert(conjunto[libroActual]->obtenerId());
        if (it->second.puntajeActual >= puntajeRequerido)
        {
            if (!it->second.aprobado)
            {
                estado.cantidadAprobados++;
            }
            it->second.aprobado = true;
        }
        estado.cantidadEjemplaresLibres--;
        conjunto[libroActual]->asignarLibro();
    }
}

void quitarLibro(estadoFinal &estado, int alumnoActual, vector<Libro *> &conjunto, int libroActual, int puntajeRequerido)
{
    auto it2 = estado.asignacion.find(alumnoActual);
    if (it2 != estado.asignacion.end())
    {
        auto itLib = it2->second.libros.find(conjunto[libroActual]->obtenerId());
        if (itLib != it2->second.libros.end())
        {
            estado.cantidadEjemplaresLibres++;
            conjunto[libroActual]->liberarLibro();
            it2->second.libros.erase(itLib);
            it2->second.puntajeActual -= conjunto[libroActual]->obtenerPuntaje();
            if (it2->second.puntajeActual < puntajeRequerido)
            {
                if (it2->second.aprobado)
                {
                    estado.cantidadAprobados--;
                }
                it2->second.aprobado = false;
            }
        }
    }
}

vector<Libro *> procesar_archivo_entrada(string origen, int &cantidadEjemplares, int &cantidadLibros, int &puntajeMax)
{
    ifstream archivo(origen);
    vector<Libro *> conjunto;
    if (!archivo.is_open())
        cout << "No se pudo abrir el archivo: " << origen << endl;
    else
    {
        string linea;
        getline(archivo, linea);
        cantidadLibros = stoi(linea);
        cout << "Se cargarán " << cantidadLibros << " libros." << endl;

        while (getline(archivo, linea))
        {
            stringstream ss(linea);
            string id, titulo, autor, genero;
            int paginas, puntaje, ejemplares;

            getline(ss, id, ';');
            getline(ss, titulo, ';');
            getline(ss, autor, ';');
            getline(ss, genero, ';');
            ss >> paginas;
            ss.ignore();
            ss >> puntaje;
            ss.ignore();
            ss >> ejemplares;

            cantidadEjemplares += ejemplares;
            puntajeMax += ejemplares * puntaje;
            conjunto.push_back(new Libro(id, titulo, autor, genero, paginas, puntaje, ejemplares));
        }
    }
    return conjunto;
}
