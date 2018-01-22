#!/bin/bash

#Proyecto POSIX Tercer Parcial: Sistema basico de Administracion de Datos
#Guarda las opciones de menu seleccionadas por el usuario
INPUT=/tmp/menu.sh.$$
function nombres_userhome() ###Pide nombre de usuario para entrar a home y el nombre del archivo.
{                                   ### Tambien verifica si el archivo existe realmente.
    USUARIO=$(pwd | cut -d '/' -f3) ### Obtenemos el nombre de usuario por el comando pwd y recortando el campo 3.
    cd .. 
    cd /home/$USUARIO/Downloads/ ###Se tiene que ingresar el archivo descargado, asi que se trabajara en la carpeta Downloads.
    ls *$NOMBRE ###ls al ultimo estado del ultimo comando, [0] normal, [1] anormal
    if [ $? -eq 0 ]; then
       dialog --title "Exito" --msgbox "el archivo $NOMBRE ha sido encontrado" 0 0
       PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 0 0 --output-fd 1)
       if [ $? -eq 1 ]; then
           dialog --msgbox "cancel pressed" 0 0
       else

           grep $PASSSQL /home/osogato/scriptsh/mysql/config.cnf
           if [ $? -eq 2 ]; then
               crea_db
               mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf < proyectoposix.txt
               mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e "show databases;" > /tmp/mysqldb.txt
               dialog --title "[FINAL]" --textbox /tmp/mysqldb.txt 0 0
           else
               dialog --backtitle "Error" --msgbox "contraseña incorrecta" 0 0
           fi
       fi
    else
        dialog --backtitle "Error" --msgbox "el archivo \"$NOMBRE\" no existe" 0 0
    fi
        
}
function nombre_de_base(){  ###Pide el nombre del archivo descargado y llama a la funcion nombres_userhome.
    NOMBRE=$(dialog --inputbox "Ingresa el nombre del archivo descargado" 0 0 --output-fd 1)
    if [ $? -eq 1 ]; then
        --msgbox "CANCEL PRESSED" 0 0
    else

        nombres_userhome
        fi
}
function crea_db(){   ###crea los archivos para que seasn trabajados como sentencias Mysql.
    rm -rf proyectoposix.txt
    DBNAME=$(dialog --inputbox "Ingresa el nombre de la base de datos a crear" 0 0 --output-fd 1)
    if [ $? -eq 1 ]; then
        --msgbox "CANCEL" 0 0
        else
    TBNAME=$(dialog --inputbox "Ingresa el nombre de la tabla para la base de datos "$DBNAME" " 0 0 --output-fd 1)
    dialog --infobox "Convirtiendo archivo csv a sql" 3 34 
    iconv -f CP850 -t UTF-8 $NOMBRE | tr "\r" "\n" | sed 818q | sed 1d > dattab.txt
    echo "drop database if exists "$DBNAME";" >proyectoposix.txt
    echo "create database "$DBNAME";">> proyectoposix.txt
    echo "use "$DBNAME";" >> proyectoposix.txt
    echo "create table "$TBNAME"(le INT, Nombre CHAR(100), Programa CHAR(100), Nacionalidad CHAR(100), AnIngrProg INT, AnTermProg INT, Titulacion CHAR(100), Sexo CHAR(100), EstatusProg CHAR(100));" >>proyectoposix.txt
    while read l
    do
          dat1=$(echo "$l" | cut -d "," -f1)
          dat2=$(echo "$l" | cut -d "," -f2)
          dat3=$(echo "$l" | cut -d "," -f3)
          dat4=$(echo "$l" | cut -d "," -f4)
          dat5=$(echo "$l" | cut -d "," -f5)
          dat6=$(echo "$l" | cut -d "," -f6)
          dat7=$(echo "$l" | cut -d "," -f7)
          dat8=$(echo "$l" | cut -d "," -f8)
          dat9=$(echo "$l" | cut -d "," -f9)
          echo " INSERT INTO "$TBNAME"(le,Nombre,Programa,Nacionalidad,AnIngrProg,AnTermProg,Titulacion,Sexo,EstatusProg)" >>proyectoposix.txt
          echo " VALUES('"${dat1}"','"${dat2}"','"${dat3}"','"${dat4}"','"${dat5}"','"${dat6}"','"${dat7}"','"${dat8}"','"${dat9}"');" >>proyectoposix.txt
    done < dattab.txt
    fi
}
function cargar_datos(){ ###Esta funcion se encarga de llamar la funcion nombre_de_base y nada mas :vvvv
nombre_de_base
}


##########################################################################################################################                                               ::FUNCIONES ELIMINAR::

function eliminar_dbdb(){ ###Eliminar base de datos
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a eliminar" 25 25 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt ###Comprobacion: si existe la base de datos: Continuar.
    if [ $? -eq 0 ]; then
        dialog --title "Exito" \
              --msgbox "La base de datos ingresada existe, eliminando..." 20 20
        mysql -u root -p"$PASSSQL" -e "drop database if exists "$DBZ";"
        rm -rf /tmp/mysqldb.txt
        mysql -u root -p"$PASSSQL" -e "show databases;" > /tmp/mysqldb.txt
        dialog --backtitle "**nuevo estado de Mysql**" \
               --textbox /tmp/mysqldb.txt 0 0
    else
        dialog --title "Error" \
               --msgbox "¡La base de datos ingresada no existe!" 20 20
        eliminar_db
    fi
}
function eliminar_tab(){ ###Eliminar tablas
    rm -rf /tmp/mysqldb.txt
    mysql -u root -p"$PASSSQL" -e "show databases;" > /tmp/mysqldb.txt
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos donde se encuentra la tabla" 0 0 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        dialog --title "Exito" \
               --msgbox "La base de datos ingresada existe, ingresando..." 0 0
        mysql -u root -p"$PASSSQL" -e "use "$DBZ";show tables;" > /tmp/mysqltab.txt
        dialog --title "**tablas disponibles**" \
               --textbox /tmp/mysqltab.txt 0 0
        TABL=$(dialog --title "eliminar tablas" --inputbox "Ingresa el nombre de la tabla a eliminar" 0 0 --output-fd 1)
        grep $TABL /tmp/mysqltab.txt
        if [ $? -eq 0 ]; then
            dialog --title "Exito" \
                   --msgbox "La tabla existe, eliminando..." 20 20 ### Actividad Opcional= se podria agregar si se quiere truncar.
            mysql -u root -p"$PASSSQL" -e "use "$DBZ"; drop table "$TABL";"
            mysql -u root -p"$PASSSQL" -e "use "$DBZ"; show tables;" > /tmp/mysqltab.txt
            dialog --title "estado de sql"\
                   --backtitle "estado final"\
                   --textbox /tmp/mysqltab.txt 0 0
        else
            dialog --title "Error" \
                   --msgbox "La tabla no existe bro" 0 0
            eliminar_db
        fi

    else
        dialog --title "Error" \
               --msgbox "¡La base de datos ingresada no existe! Sorry bro :\"v" 0 0
        eliminar_db
        fi
}
function eliminar_reg(){
    rm rf /tmp/mysqldb.txt
    mysql --user=root --password="$PASSSQL" -e "SHOW DATABASES;" > /tmp/mysqldb.txt
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos" 0 0 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        rm -rf /tmp/mysqltab.txt
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SHOW TABLES;" > /tmp/mysqltab.txt
        dialog --textbox /tmp/mysqltab.txt 0 0
        TABL=$(dialog --title "nombre de tabla" --inputbox "Ingresa el nombre de la tabla" 0 0 --output-fd 1)
        grep $TABL /tmp/mysqltab.txt
        if [ $? -eq 0 ]; then
            mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SELECT * FROM "$TABL";" -t > /tmp/mysqlreg.txt
            dialog --textbox /tmp/mysqlreg.txt 0 0
            DCOL=$(dialog --title "¿que eliminar?" --inputbox "seleccionar la columna:" 25 25 --output-fd 1)
            grep $DCOL /tmp/mysqlreg.txt
            if [ $? -eq 0 ]; then
                DREG=$(dialog --title "ingresa campo" --inputbox "registro:" 25 25 --output-fd 1)
                grep $DREG /tmp/mysqlreg.txt
                if [ $? -eq 0 ]; then
                    mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; DELETE FROM "$TABL" WHERE "$DCOL"='"$DREG"';"
                    rm -rf /tmp/mysqlreg.txt
                    mysql --user=root --password="$PASSSQL" -e "USE "$DBZ";SELECT * FROM "$TABL"" > /tmp/mysqlreg.txt
                    dialog --title "nuevo estado de la tabla " --textbox /tmp/mysqlreg.txt 0 0
                else
                    dialog --msgbox "error no se encontro el registro" 0 0
                fi
            else
                dialog --title "error"\
                       --msgbox "No se encontro el registro especificado" 0 0
            fi
        else
            dialog --title "error"\
                   --msgbox "No se encontro la tabla" 0 0
        fi
    else
        dialog --title "error"\
               --msgbox "No se encontro la base de datos" 0 0
    fi


}

############################################################################################################################################################## FUNCIONES AGREGAR::

agregar_dbdb(){

    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a crear" 0 0 --output-fd 1)
    mysql --user=root --password="$PASSSQL" -e "CREATE DATABASE "$DBZ"; SHOW DATABASES;" > /tmp/mysqldb.txt
    dialog --backtitle "ESTADO FINAL" --title "nuevo estado" --textbox /tmp/mysqldb.txt 0 0
    agregar_db
}
agregar_tab(){
    dialog --backtitle "BASES DE DATOS DISPONIBLES" --textbox /tmp/mysqldb.txt 0 0
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a utilizar" 0 0 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SHOW TABLES;" -t > /tmp/mysqltab.txt
        dialog --backtitle "TABLAS EXISTENTES" --textbox /tmp/mysqltab.txt 0 0
        TABX=$(dialog --inputbox "Ingresa el nombre de la tabla a crear" 25 25 --output-fd 1)
        rm -rf /tmp/mysqltab.txt
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; CREATE TABLE "$TABX"(col1 int);"
        mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e "USE "$DBZ"; SHOW TABLES;" > /tmp/mysqltab.txt
        dialog --backtitle "NUEVO ESTADO DE TABLAS" --textbox /tmp/mysqltab.txt 0 0
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SELECT * FROM "$TABX";"
        dialog --backtitle "CONTENIDO DE TABLA" --textbox /tmp/regbox.txt 0 0
        agregar_db
    else
        dialog --title "error"\
               --msgbox "base de datos no existe" 0 0
        agregar_db
    fi

}
agregar_reg(){
    dialog --backtitle "BASES DE DATOS DISPONIBLES" --textbox /tmp/mysqldb.txt 0 0
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a utilizar" 0 0 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e "USE "$DBZ"; SHOW TABLES;" > /tmp/mysqltab.txt
        dialog --backtitle "TABLAS EXISTENTES" --textbox /tmp/mysqltab.txt 0 0
        TABX=$(dialog --inputbox "Ingresa el nombre de la tabla a utilizar para agregar nuevo registro" 0 0 --output-fd 1)
        grep $TABX /tmp/mysqltab.txt
        if [ $? -eq 0 ]; then
            mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e "USE "$DBZ"; SELECT * FROM "$TABX";" -t  > /tmp/mysqlreg.txt
            dialog --backtitle "CONTENIDO" --textbox /tmp/mysqlreg.txt 0 0
            touch /tmp/col.txt
            dialog --inputbox "Ingresa el nombre de las columna(s) a utilizar separadas por \"\,\" " 0 0 2>/tmp/col.txt
            touch /tmp/reg.txt
            TABCOL=$(cat /tmp/col.txt)
            dialog --inputbox "ingresa los registros entre ' ' \n Si son mas de uno separalos por ',\" " 0 0 2>/tmp/reg.txt
            REG=$(cat /tmp/reg.txt)
            echo $REG
            echo $TABCOL
            rm -rf /tmp/mysqlreg.txt
            mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e " USE "$DBZ" ; INSERT INTO "$TABX" ( "$TABCOL" ) VALUES ( "$REG" ); "
            mysql --defaults-extra-file=/home/osogato/scriptsh/mysql/config.cnf -e "USE "$DBZ"; SELECT * FROM "$TABX";" -t > /tmp/mysqlreg.txt
            dialog --backtitle ""$TABX" ES LA NUEVA COLUMNA AGREGADA" --textbox /tmp/mysqlreg.txt 0 0

            agregar_db
        else
            dialog --title "error"\
                   --msgbox "No se encontro la tabla" 0 0
            agregar_db
        fi
    else
        dialog --title "error"\
               --msgbox "No se encontro la base de datos" 0 0
        agregar_db
    fi


}
ver_dbdb(){
    rm -rf /tmp/mysqldb.txt
    PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    mysql --user=root --password="$PASSSQL" -e "SHOW DATABASES;" > /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        
        dialog --backtitle "BASES DE DATOS DISPONIBLES" --textbox /tmp/mysqldb.txt 0 0
    else
        dialog --msgbox "contraseña incorrecta" 0 0
    fi

}
ver_tab(){
    rm -rf /tmp/mysqldb.txt
    PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    mysql --user=root --password="$PASSSQL" -e "SHOW DATABASES;" > /tmp/mysqldb.txt
    dialog --backtitle "BASES DE DATOS DISPONIBLES" --textbox /tmp/mysqldb.txt 0 0
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a utilizar" 25 25 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SHOW TABLES" > /tmp/mysqltab.txt
        dialog --backtitle "TABLAS DISPONIBLES" --textbox /tmp/mysqltab.txt 0 0
    else
        dialog --msgbox "la tabla no existe" 0 0
    fi
   } 

ver_reg(){
    rm -rf /tmp/mysqldb.txt
    PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    mysql --user=root --password="$PASSSQL" -e "SHOW DATABASES;" > /tmp/mysqldb.txt
    dialog --backtitle "BASES DE DATOS DISPONIBLES" --textbox /tmp/mysqldb.txt 0 0
    DBZ=$(dialog --inputbox "Ingresa el nombre de la base de datos a utilizar" 25 25 --output-fd 1)
    grep $DBZ /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then
        mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SHOW TABLES" > /tmp/mysqltab.txt
        dialog --backtitle "TABLAS DISPONIBLES" --textbox /tmp/mysqltab.txt 0 0
        TAB=$(dialog --inputbox "Ingresa el nombre de la tabla de a visualizar" 25 25 --output-fd 1)
        grep $TAB /tmp/mysqltab.txt
        if [ $? -eq 0 ]; then
            mysql --user=root --password="$PASSSQL" -e "USE "$DBZ"; SELECT * FROM "$TAB";" -t > /tmp/mysqltabx.txt
            dialog --backtitle "CONTENIDO DE TABLA:" --textbox /tmp/mysqltabx.txt 0 0
        else
            dialog --msgbox "la tabla no existe" 0 0
        fi
    else
        dialog --title "Error" --msgbox "base de datos no existe" 0 0
    fi    
}

menu_columnas(){
    dialog --backtitle "SELECCIONAR COLUMNAS" \
           --title "Selecciona tu columna" \
           --menu "Selecciona una opcion" 15 50 4 \

}


#********************************************************************************************************************************************************#


function eliminar_db(){  ###Menu de operaciones de eliminacion
    dialog --backtitle "ELIMINAR REGISTRO" \
           --title "¿Que operación desea realizar?" \
           --menu "Selecciona una opcion" 15 50 4 \
           1 "Eliminar una base de datos" \
           2 "Eliminar tabla" \
           3 "Eliminar Registro" 2>"${INPUT}"
    select=$(<"${INPUT}")
    case $select in
1) eliminar_dbdb;; ### Ingresa a operaciones de ELIMINAR solo BASES DE DATOS.
2) eliminar_tab;;  ### Ingresa a operaciones de ELIMINAR solo TABLAS.
3) eliminar_reg;;  ### Ingresa a opciones de ELIMINAR solo REGISTROS.
4) clave_unica;; ### ELIMINAR por clave unica.
    esac
}
function agregar_db(){  ###Menu de operaciones de agregar
    dialog --backtitle "AGREGAR REGISTRO" \
           --title "¿Que operación desea realizar?" \
           --menu "Selecciona una opcion" 15 50 4 \
           1 "Agregar una base de datos" \
           2 "Agregar tabla" \
           3 "Agregar Registro" 2>"${INPUT}"
    select=$(<"${INPUT}")
    case $select in
        1) agregar_dbdb;; ### Ingresa a operaciones de AGREGAR solo BASES DE DATOS.
        2) agregar_tab;;  ### Ingresa a operaciones de AGREGAR solo TABLAS.
        3) agregar_reg;;  ### Ingresa a opciones de AGREGAR solo REGISTROS.
    esac
}

function modificar_db(){  ###Menu de operaciones de eliminacion
    dialog --backtitle "AGREGAR REGISTRO" \
           --title "¿Que operación desea realizar?" \
           --menu "Selecciona una opcion" 15 50 4 \
           1 "Modificar Registro" 2>"${INPUT}"
    select=$(<"${INPUT}")
    case $select in
        1) modificar_reg;; ### Ingresa a operaciones de MODIFICAR DATOS.
    esac
}

function visualizar_db(){
    dialog --backtitle "Visualizar" \
           --title "¿Que operación desea realizar?" \
           --menu "Selecciona una opcion" 15 50 4 \
           1 "Ver bases de datos" \
           2 "Ver tablas" \
           3 "Ver Registros" 2>"${INPUT}"
    select=$(<"${INPUT}")
    case $select in
        1) ver_dbdb;; ### Ingresa a operaciones de VISUALIZAR solo BASES DE DATOS.
        2) ver_tab;;  ### Ingresa a operaciones de VISUALIZAR solo TABLAS.
        3) ver_reg;;  ### Ingresa a opciones de VISUALIZAR solo REGISTROS.
    esac

}

                                                  ###(       FUNCIONES OPCION 2        )###
#********************************************************************************************************************************************************#


function show_eliminar_db(){  ###Muestra las bases de datos disponibles, se necesita contraseña root de Mysql.
    PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    mysql -u root -p"$PASSSQL" -e "show databases;" > /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then   ###Comprobar que la contraseña sea correcta

    dialog --backtitle "BASES DE DATOS EXISTENTES"\
           --title "Existen actualmente estas bases de datos =" \
           --textbox /tmp/mysqldb.txt 0 0
    dialog  --yesno "¿continuar con la operacion de eliminar?" 0 0
    respuesta=$?
    case $respuesta in
        0)eliminar_db;;      ###Confirmar que se quiere proceder :v.
        1)iniciar_menudb;;   ###Regresar al menu de "Administrar Base de Datos".
    esac
    else
        dialog --title "Error" \
               --msgbox "No se encuentra base de datos" 0 0

       iniciar_menudb
    fi

}
function show_agregar_db(){  ###Muestra las bases de datos disponibles, se necesita contraseña root de Mysql.
    PASSSQL=$(dialog --cancel-label "REGRESAR" --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    if [ $? -eq 0 ]; then
    mysql -u root -p"$PASSSQL" -e "show databases;" > /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then   ###Comprobar que la contraseña sea correcta

        dialog --backtitle "BASES DE DATOS EXISTENTES"\
               --title "Existen actualmente estas bases de datos =" \
               --textbox /tmp/mysqldb.txt 0 0
        dialog  --yesno "¿continuar con la operacion de agregar?" 0 0
        respuesta=$?
        case $respuesta in
            0)agregar_db;;      ###Confirmar que se quiere proceder :v.
            1)iniciar_menudb;;   ###Regresar al menu de "Administrar Base de Datos".
        esac
    else
        dialog --title "Error" \
               --msgbox "Contraseña root sql incorrecta" 0 0

        iniciar_menudb
        
    fi
    else
dialog --backtitle "CANCELADO" --msgbox "REGRESAR presionado" 0 0
        iniciar_menudb
    fi

}
function show_modificar_db(){  ###Muestra las bases de datos disponibles, se necesita contraseña root de Mysql.
    PASSSQL=$(dialog --insecure --passwordbox "Se necesita la contraseña del usuario Root de Mysql" 10 30 --output-fd 1)
    mysql -u root -p"$PASSSQL" -e "show databases;" > /tmp/mysqldb.txt
    if [ $? -eq 0 ]; then   ###Comprobar que la contraseña sea correcta

        dialog --backtitle "BASES DE DATOS EXISTENTES"\
               --title "Existen actualmente estas bases de datos =" \
               --textbox /tmp/mysqldb.txt 0 0
        dialog  --yesno "¿continuar con la operacion de modificar?" 0 0
        respuesta=$?
        case $respuesta in
            0)agregar_db;;      ###Confirmar que se quiere proceder :v.
            1)iniciar_menudb;;   ###Regresar al menu de "Administrar Base de Datos".
        esac
    else
        dialog --title "Error" \
               --msgbox "Contraseña root sql incorrecta" 0 0

        iniciar_menudb
    fi

}
function iniciar_menudb(){  ### Menu de la opcion "Administrar Base de Datos".
    dialog --backtitle "Administrar Base de Datos" \
           --title "Elige una opcion" \
           --menu "Selecciona una opcion" 15 50 4 \
           Agregar "Agregar nuevo registro" \
           Eliminar "Eliminar Registro" \
           Modificar "Modificar Registros" \
           Visualizar "Visualizar Informacion" 2>"${INPUT}"
    select=$(<"${INPUT}")
    case $select in
        Agregar) show_agregar_db;; ###iniciamos operaciones para agregar :v
        Eliminar) show_eliminar_db;;  ###iniciamos el menu para operaciones de eliminar
        Modificar) show_modificar_db;;
        Visualizar) visualizar_db;;
    esac
}

                                        ####[      AQUI ESTA TODO LO QUE TENGA QUE VER CON GNUPLOT :V       ]###
##########################################################################################################################################################
  #                                                          #                           #                                                               #


preparar_plotuno(){
    USUARIO=$(pwd | cut -d '/' -f3)
    cd ..
    cd /home/$USUARIO/Downloads/
    cat dattab.txt | cut -d "," -f3 cat dattab.txt | cut -d "," -f6 |sort | uniq -c | sort -nr > /tmp/plotcarrera.txt #obtener numeros de carrera
    sed "s/^[ \t]*//" -i /tmp/plotcarrera.txt
    cat /tmp/plotcarrera.txt  | sed -e "s/[0-9][0-9][0-9]/&,/" | head -4 > /tmp/plotcarrera2.txt
    cat /tmp/plotcarrera.txt  | sed -e "s/[0-9]/&,/" | tail -1 > /tmp/plotcarreraend.txt
    cat /tmp/plotcarrera.txt  | sed -e "s/[0-9][0-9]/&,/" | tail -4 > /tmp/plotcarreramed1.txt
    cat /tmp/plotcarreramed1.txt | head -3 > /tmp/plotcarreramedfin.txt
    cat /tmp/plotcarreramedfin.txt >> /tmp/plotcarrera2.txt
    cat /tmp/plotcarreraend.txt >> /tmp/plotcarrera2.txt

}

preparar_plotdos(){
    USUARIO=$(pwd | cut -d '/' -f3)
    cd ..
    cd /home/$USUARIO/Downloads/
    cat dattab.txt | cut -d "," -f6 |sort | uniq -c | sort -nr > /tmp/plotanio.txt
    sed "s/^[ \t]*//" -i /tmp/plotanio.txt
}

egresados_carrera(){

    preparar_plotuno

    dialog --backtitle "GNUPLOTS" --msgbox "pulsa ok para continuar" 0 0
    gnuplot -persist <<EOF

set title "EGRESADOS POR CARRERA" font ", 24"
set datafile separator ","
set grid
set terminal pngcairo size 1280,800 enhanced font 'Verdana,10'
set output '/tmp/egresadoscarrera.png'
set boxwidth 2
set ylabel "Numero de egresados" offset 2.5,0
set style fill solid
set style data histogram
set xtic rotate by 90
set bmargin 30
set xtics offset 0.5,-28.0
set xtics font ", 10"
set border 10
plot '/tmp/plotcarrera2.txt' using 1:xtic(2) title "Egresados por carrera"
EOF
    display /tmp/egresadoscarrera.png
}

egresados_anio(){
    preparar_plotdos
    dialog --ascii-lines --backtitle "GNUPLOT" --textbox /tmp/plotanio.txt 0 0
    gnuplot -persist <<EOF
set title "EGRESADOS POR AÑO" font ", 24"
set datafile separator " "
set grid
set terminal pngcairo size 1280,800 enhanced font 'Verdana,10'
set output '/tmp/egresadosanio.png'
set boxwidth 2
set ylabel "Numero de egresados" offset 2.5,0
set style fill solid
set style data histogram
set xtic rotate by 90
set bmargin 8
set xtics offset 0.5,-2.8
set xtics font ", 14"
set border 10
plot '/tmp/plotanio.txt' using 1:xtic(2) title "Egresados por año"
EOF
    display /tmp/egresadosanio.png
}

menu_gnuplot(){

    dialog --ascii-lines  --backtitle "GNUPLOT" \
           --title "[ GNUPLOT (no tiene nada que ver con GNU :v  ]" \
           --menu "Generar graficas bien chulas :v" 15 50 4 \
           1 "Generar grafica de egresados por carrera" \
           2 "Generar grafica de egresados por año" 2>"${INPUT}"
           menuitem=$(<"${INPUT}")
    #  Casos de seleccion.
    case $menuitem in
	      1) egresados_carrera;;
	      2) egresados_anio;;
	  esac
}
#********************************************************************************************************************************************************#

# Se hace un loop infinito para regresar siempre al menu principal
while true
do
dialog --clear  --ascii-lines  --backtitle "Sistema básico de Administración de Datos" \
--title "[ M E N U - P R I N C I P A L ]" \
           --menu "Para moverte por las opciones puedes utilizar: \n las teclas ARRIBA y ABAJO. \n La primera letra (que esta en rojo) \n numeros (1-9)." 15 50 4 \
           Cargar "Cargar Base de Datos" \
           Admin "Administrar Base de Datos" \
           Reportes "Generar informes con GNU Plot" \
           Exit "Regresar al shell" 2>"${INPUT}"
   menuitem=$(<"${INPUT}")
    #  Casos de seleccion.
    case $menuitem in
	      Cargar) cargar_datos;;
	      Admin) iniciar_menudb;;
	      Reportes) menu_gnuplot;;
	      Exit) echo "¡Adios!"; break;;
    esac
done





# made with GNU Emacs "Free Software for a free society". 
