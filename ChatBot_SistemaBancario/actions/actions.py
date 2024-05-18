# This files contains your custom actions which can be used to run
# custom Python code.

# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

class ActionTemas(Action):
   def name(self) -> Text:
       return "action_Tema"
   def run(self, dispatcher: CollectingDispatcher,tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        tema = tracker.get_slot("tema")
        print(tema)
        if tema == "cuentaBancaria":
            dispatcher.utter_message(text="Su cuenta bancaria se a creado con exito")
        elif tema == "tarjetaDebito":
            dispatcher.utter_message(text="Su tarjeta de debito se creo con exito")
        elif tema == "tarjetaCredito":
            dispatcher.utter_message(text="Su tarjeta de credito se creo con exito")
        return[]
