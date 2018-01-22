#!/bin/bash
#ejecutar como superuser :V
#butiador de usbs por WizardTrejoLuna :v

INPUT=/tmp/menu.sh.$$

function showMount(){
    lsblk > /tmp/lsblk.txt
    dialog --backtitle "Lista de dispositivos montados" --textbox /tmp/lsblk.txt 0 0
    NAMEUSB=$(dialog --inputbox "Ingresa el nombre del usb" 0 0 --output-fd 1)
    if [ $? -eq 1 ]; then
        dialog --msgbox "CANCEL PRESSED" 0 0
    else
        dialog --backtitle "SOBREX" --msgbox "SOBRX PRRA :V" 0 0
    fi
}
function findIso(){
    NAMEANDIRISO=$(dialog --inputbox "ingresa el nombre de la iso a butiar :v" 0 0 --output-fd 1)
    if [ $? -eq 1 ]; then
        dialog --msgbox "CANCEL PRESSED" 0 0
    else
        dirAndNameIso
    fi

} 

function dirAndNameIso(){
    locate $NAMEANDIRISO > /tmp/findis.o
    dialog --backtitle "Se encontraron estas madres :v ¿proceder?" --textbox /tmp/findis.o 0 0
    if [ $? -eq 1 ]; then
        dialog --msgbox "CANCEL PRESSED" 0 0
    else
        ISODIR=$(cat /tmp/findis.o | cut -d "/" -f1,2,3,4)
        ISONAME=$(cat /tmp/findis.o | cut -d "/" -f5 )
        cd $ISODIR
        dd if=$ISONAME |pv| dd of=/dev/$NAMEUSB bs=4M

    fi


}








# ----------------------------------------------------- MAIN MENU -------------------------------------------------------#
# Se hace un loop infinito para regresar siempre al menu principal
while true
do
    dialog --clear  --ascii-lines  --backtitle "Butiador de USB's por WizardTrejoLuna :v" \
           --title "[ M E N U - P R I N C I P A L ]" \
           --menu "Para moverte por las opciones puedes utilizar: \n las teclas ARRIBA y ABAJO. \n La primera letra (que esta en rojo) \n numeros (1-9)." 15 50 4 \
           Mount "Mostrar montajes y seleccionar usb" \
           FindISO "Seleccionar imagen .ISO a bootear" \
           Exit "Regresar al shell" 2>"${INPUT}"
    menuitem=$(<"${INPUT}")
    #  Casos de seleccion.
    case $menuitem in
	      Mount) showMount;;
        FindISO) findIso;;
	      Exit) echo "¡Adios!"; break;;
    esac
done
