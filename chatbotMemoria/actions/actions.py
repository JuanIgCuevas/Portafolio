from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import random
import os.path
import json

class OperarArchivo():

    @staticmethod
    def guardar(AGuardar):
        with open(".\\actions\\datos","w") as archivo_descarga:
            json.dump(AGuardar, archivo_descarga, indent=4)
        archivo_descarga.close()

    @staticmethod
    def cargarArchivo(): 
        if os.path.isfile(".\\actions\\datos"):
            with open(".\\actions\\datos","r") as archivo_carga:
                retorno=json.load(archivo_carga)
                archivo_carga.close()
        else:
            retorno={}
        return retorno

class ActionExtraerDatos(Action):
    def name(self) -> Text:
       return "action_extraer_datos"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        nro_libreta = next(tracker.get_latest_entity_values("nro_libreta"), None)
        alumnos= OperarArchivo.cargarArchivo()
        if nro_libreta in alumnos:
            mensaje="Hola "+alumnos[nro_libreta]['nombre']+", ya estas registrado. Tu comisión es: "+ alumnos[nro_libreta]['comision']
        else:
            comision="E"+str(random.randint(1,4))
            nombre = next(tracker.get_latest_entity_values("nombre"), None)
            mensaje="Un gusto "+nombre+", no tenía datos tuyos. Tu comisión será: "+ comision
            alumnos[nro_libreta]={}
            alumnos[nro_libreta]['nombre']=nombre
            alumnos[nro_libreta]['comision']=comision
            OperarArchivo.guardar(alumnos)
        dispatcher.utter_message(text=str(mensaje))
        return []