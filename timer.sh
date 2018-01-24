#!/bin/bash

#Scriṕt que pregunta al usado por el tiempo que tiene que esperar.


TIME=$(zenity --entry --title="Timer" --text="Ingresa el tiempo \n\n 5s para 5 segundos, 10m para 10 minutos, 2h para 2 horas.")

TASK=$(zenity --entry --title="Tarea" --text="Ingresa la tarea a realizar durante el tiempo")

sleep $TIME

zenity --info --title="Timer Completado" --text="El tiempo se acabo ¿terminaste de hacer $TASK? \n\n fueron $TIME."
