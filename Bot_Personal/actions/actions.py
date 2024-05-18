# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet, FollowupAction
from swiplserver import PrologMQI, PrologThread, create_posix_path
from .apiCalendar import event, get_event
from time import sleep
import wikipediaapi
import telebot
import os.path
import json
import requests
import datetime
import pyjokes

TOKEN = '5631646530:AAHhaAl382HhrwsRvHAY79JoxYHa9ya7hNA'
bot = telebot.TeleBot(TOKEN)

class ActionSaludo(Action):

    def name(self) -> Text:
        return "action_saludo"
    
    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        input_data=tracker.latest_message
        from_data=input_data["metadata"]["message"]["from"]
        
        name= from_data["first_name"]
        if name is None:
            dispatcher.utter_message("Nos vemos! Que sigas bien!")
        else:
            dispatcher.utter_message("Nos vemos  "+ name +"! Que sigas bien!".format(name))             
        return[]

class OperarArchivo():

    @staticmethod
    def guardar(AGuardar):
        with open(".\\actions\\datos.json","w") as archivo_descarga:
            json.dump(AGuardar, archivo_descarga, indent=4)
        archivo_descarga.close()

    @staticmethod
    def cargarArchivo(): 
        if os.path.isfile(".\\actions\\datos.json"):
            with open(".\\actions\\datos.json","r") as archivo_carga:
                retorno=json.load(archivo_carga)
                archivo_carga.close()
        else:
            retorno={}
        return retorno

class OperarAchDias():

    @staticmethod
    def cargarArchivo(): 
        if os.path.isfile(".\\actions\\dias.json"):
            with open(".\\actions\\dias.json","r") as archivo_carga:
                retorno=json.load(archivo_carga)
                archivo_carga.close()
        else:
            retorno={}
        return retorno

class action_prolog_cursadas(Action):
    def name(self) -> Text:
       return "action_prolog_cursadas"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        with PrologMQI(port=8000) as mqi:
            with mqi.create_thread() as prolog_thread:
                direccion= create_posix_path('C:/Users/54228/Documents/rasa_projects/new_rasa_project/Bot_Personal/actions/Materias(Sistemas).pl')
                prolog_thread.query_async(f'consult("{direccion}").', find_all=False)
                prolog_thread.query_async_result()
                prolog_thread.query_async(f"cursadas(X).", find_all=True)
                sleep(0.1)
                result=prolog_thread.query_async_result()
                print(str(result))
                if result:
                    mensaje="Ya curse: " + "\n "
                    for iterator in result:
                        mensaje= mensaje + iterator['X'] + "\n "
                    dispatcher.utter_message(text=mensaje)
        return []

class action_prolog_cursando(Action):
    def name(self) -> Text:
       return "action_prolog_cursando"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        with PrologMQI(port=8000) as mqi:
            with mqi.create_thread() as prolog_thread:
                direccion= create_posix_path('C:/Users/54228/Documents/rasa_projects/new_rasa_project/Bot_Personal/actions/Materias(Sistemas).pl')
                prolog_thread.query_async(f'consult("{direccion}").', find_all=False)
                prolog_thread.query_async_result()
                prolog_thread.query_async(f"cursando(X).", find_all=True)
                sleep(0.1)
                result=prolog_thread.query_async_result()
                print(str(result))
                if result:
                    mensaje="Actualmente estoy cursando: " + "\n "
                    for iterator in result:
                        mensaje= mensaje + iterator['X'] + "\n "
                    dispatcher.utter_message(text=mensaje)
        return []

class action_prolog_finales(Action):
    def name(self) -> Text:
       return "action_prolog_finales"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        with PrologMQI(port=8000) as mqi:
            with mqi.create_thread() as prolog_thread:
                direccion= create_posix_path('C:/Users/54228/Documents/rasa_projects/new_rasa_project/Bot_Personal/actions/Materias(Sistemas).pl')
                prolog_thread.query_async(f'consult("{direccion}").', find_all=False)
                prolog_thread.query_async_result()
                prolog_thread.query_async(f"finales(X).", find_all=True)
                sleep(0.1)
                result=prolog_thread.query_async_result()
                print(str(result))
                if result:
                    mensaje="Debo los finales de: " + "\n "
                    for iterator in result:
                        mensaje= mensaje + iterator['X'] + "\n "
                    dispatcher.utter_message(text=mensaje)
        return []


class traer_nombre(Action):
    def name(self) -> Text:
       return "action_traer_nombre"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        input_data=tracker.latest_message
        from_data=input_data["metadata"]["message"]["from"]
        llave_id=from_data["id"]
        
        name= from_data["first_name"]
        surname= from_data.get("last_name")
        persona= OperarArchivo.cargarArchivo()
        
        if not (str(llave_id)) in persona:
            mensaje="Un gusto "+name+", no te conocia"
            persona[llave_id]= {}
            persona[llave_id]['nombre']= name
            if surname:
                persona[llave_id]['apellido']= surname
            OperarArchivo.guardar(persona)        
            dispatcher.utter_message(text=str(mensaje))
        
        print(from_data) 
        return []

class wikipediaAPI(Action):
    def name(self) -> Text:
       return "action_wikipedia_api"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        wiki_wiki = wikipediaapi.Wikipedia('es')
        buscar = tracker.get_slot("busqueda")
        cond = tracker.get_slot("respBuscar")
        print(buscar)
        if buscar:
            page_py = wiki_wiki.page(buscar.replace(" ", "_"))
            print("Page - Exists: %s" % page_py.exists())
            # Page - Exists: True

            respuesta= "Te dejo un breve resumen de lo que encontre sobre '"
            link= "Queres que te pase el link para profundizar?"
            
            if page_py.exists() and (not cond): # Extraer resumen de pagina
                print("Page - Title: %s" % page_py.title)
                # Page - Title: Python (programming language)

                mensaje= respuesta + page_py.title +"' \n "
                mensaje1= page_py.summary
                dispatcher.utter_message(text=str(mensaje))
                dispatcher.utter_message(text=str(mensaje1))
                dispatcher.utter_message(text=str(link))
                SlotSet("respBuscar", True)

        return [SlotSet("respondido", False)]

class action_wikipedia_link(Action):
    def name(self) -> Text:
       return "action_wikipedia_link"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        respondido = tracker.get_slot("respondido")

        if not respondido:
            wiki_wiki = wikipediaapi.Wikipedia('es')
            buscar = tracker.get_slot("busqueda")
            print(buscar)
            page_py = wiki_wiki.page(buscar.replace(" ", "_"))
            print(page_py.canonicalurl)
            if page_py.exists(): # Extraer resumen de pagina
                messaje= page_py.canonicalurl
                dispatcher.utter_message(text=str(messaje))
        return [SlotSet("busqueda", None), SlotSet("respondido", True)]

class action_wikipedia_linkNegado(Action):
    def name(self) -> Text:
       return "action_wikipedia_linkNegado"

    def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        messaje= "Perfecto, en que mas te puedo ayudar?"
        dispatcher.utter_message(text=str(messaje))
        return [SlotSet("busqueda", None)]

class ActionMood(Action):
   def name(self) -> Text:
       return "action_mood"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        tema = tracker.get_slot("mood")

        input_data=tracker.latest_message
        chat_id=input_data["metadata"]["message"]["chat"]["id"]
        file_image= 'C:/Users/54228/Documents/rasa_projects/new_rasa_project/motivadora.jpg'
        photo=open(file_image,'rb')

        if tema == "happy":
            mensaje= "Me alegro mucho!"
            mensaje1= "preguntame lo que quieras"
        elif tema == "sad":
            mensaje= "Espero que te haga sentir mejor!"
            mensaje1= "Queres que te cuente un chiste?"
            bot.send_photo(chat_id, photo)        
        elif tema == "angry":
            mensaje= "Estoy aqui para lo que necesites"
            mensaje1= "En que puedo ayudarte?"
        else: 
            mensaje= "jaja saludos"
            mensaje1= "Queres que te cuente un chiste?"
        
        dispatcher.utter_message(text=str(mensaje))
        dispatcher.utter_message(text=str(mensaje1))
        return[]

class ActionPinear(Action):
   def name(self) -> Text:
       return "actionPinear"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        input_data=tracker.latest_message
        chat_id=input_data["metadata"]["message"]["chat"]["id"]
        message_id=input_data["metadata"]["message"]["message_id"]

        getUrl = f'https://api.telegram.org/bot{TOKEN}/pinChatMessage'
        params_ChatMessage = {
        "chat_id": chat_id,
        "message_id": message_id
            }
        r = requests.get(getUrl, params_ChatMessage)
        print(r.text)
        return[]

class ActionResponder(Action):
   def name(self) -> Text:
       return "actionResponder"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        chat_id= tracker.get_slot("id_chat")
        message_id= tracker.get_slot("id_message")
        input_data=tracker.latest_message
        name=input_data["metadata"]["message"]["from"]["first_name"]
        message= name + " Quedamos para ese dia!"
        
        getUrl = f'https://api.telegram.org/bot{TOKEN}/sendMessage'
        params_sendMessage = {
        "chat_id": chat_id,
        "text": message,
        "reply_to_message_id": message_id
            }
        r = requests.get(getUrl, params_sendMessage)
        return[]

class Action_get_eventos(Action):
   def name(self) -> Text:
       return "action_get_eventos"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        eventos= get_event()
        for event in eventos:
            fecha= event['start'].get('dateTime')
            if fecha:
                fechaMejorada= datetime.datetime.strptime(fecha, "%Y-%m-%dT%H:%M:%S%z")
            else:
                fecha= str(event['start'].get('date')).split("-")
                fechaMejorada= datetime.datetime(int(fecha[0]),int(fecha[1]),int(fecha[2]))

            dia= fechaMejorada.day
            mes= fechaMejorada.month
            anio= fechaMejorada.year
            message= f"{event['summary']}  {dia}/{mes}/{anio}"
            dispatcher.utter_message(text=str(message))
        return[]

class Action_guardarMensaje(Action):
   def name(self) -> Text:
       return "action_guardarMensaje"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        input_data=tracker.latest_message
        chat_id=input_data["metadata"]["message"]["chat"]["id"]
        message_id=input_data["metadata"]["message"]["message_id"]

        message= "Buenisimo, que horario te queda mejor?"
        dispatcher.utter_message(text=str(message))
        return[SlotSet("id_chat", chat_id), SlotSet("id_message", message_id)]

class Action_crear_evento(Action):
   def name(self) -> Text:
       return "action_crear_evento"
   def run(self,dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        archDias= OperarAchDias.cargarArchivo()
        fechaActual= datetime.datetime.now()
        fecha= tracker.get_slot("dia")
        hora= int(tracker.get_slot("hora"))
        if not fecha:
            dispatcher.utter_message(text=str("no te entiendo"))
            return[]
        if fecha == "hoy":
            fechaInicial= datetime.datetime(fechaActual.year,fechaActual.month,fechaActual.day,hora)
            fechaFinal= fechaInicial+ datetime.timedelta(hours=1) 
        elif fecha == "mañana":
            sumarDias= datetime.timedelta(1)
            DiaReunion= sumarDias + fechaActual
            fechaInicial= datetime.datetime(DiaReunion.year,DiaReunion.month,DiaReunion.day,hora)
            fechaFinal= fechaInicial+ datetime.timedelta(hours=1)
        else:
            diaActual= datetime.datetime.strftime(fechaActual,'%A')
            diferencia= archDias[str(diaActual)][str(fecha)]
            sumarDias= datetime.timedelta(diferencia)
            DiaReunion= sumarDias + fechaActual
            fechaInicial= datetime.datetime(DiaReunion.year,DiaReunion.month,DiaReunion.day,hora)   
            fechaFinal= fechaInicial+ datetime.timedelta(hours=1)

        persona= OperarArchivo.cargarArchivo()
        input_data=tracker.latest_message
        persona_id= input_data["metadata"]["message"]["from"]["id"]

        if (str(persona_id)) in persona:
            nom_persona= persona[str(persona_id)]["nombre"]
            apell_persona= persona[str(persona_id)].get("apellido")
            if apell_persona:
                nom_persona= nom_persona +" "+ apell_persona
            print("nombre",nom_persona)
            #event(nom_persona, fechaInicial.isoformat(), fechaFinal.isoformat())
            evento= event(nom_persona, fechaInicial.isoformat(), fechaFinal.isoformat())

            input_data=tracker.latest_message
            grupo=input_data["metadata"]["message"]["chat"]["type"]

            if grupo == "supergroup" or grupo == "group":
                message= "Perfecto, les dejo el link de la reunion por si alguien mas se quiere unir"
                message1= evento.get('htmlLink')
                dispatcher.utter_message(text=str(message))
                dispatcher.utter_message(text=str(message1))
            return[FollowupAction("actionResponder")]
        return[]

class ActionChistes(Action):

    def name(self) -> Text:
        return "ActionChistes"
    
    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        joke1 = pyjokes.get_joke(language='es', category= 'all')  
        message= "Queres otro?"
        #display the joke
        dispatcher.utter_message(text=str(joke1))    
        dispatcher.utter_message(text=str(message))    
        return[]
