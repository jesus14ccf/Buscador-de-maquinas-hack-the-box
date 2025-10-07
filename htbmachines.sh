#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n ${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl + C
trap ctrl_c INT

# Variable globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel(){
  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Uso${endColour}:" 
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por direccion IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de una maquina (Fácil, Media, Difícil, Insane)${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Optener link de la resolucion de la máquina en youtube${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"
}


function updateFiles(){

 if [ ! -f bundle.js ]; then
    tput civis 
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js 
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
    tput cnorm
 else
   tput civis
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
   curl -s $main_url > bundle_temp.js 
   js-beautify bundle_temp.js | sponge bundle_temp.js
   md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
   md5_origin_value=$(md5sum bundle.js | awk '{print $1}')
   
   if [ "$md5_temp_value" == "$md5_origin_value" ]; then
     echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, esta todo al día ;)${endColour}"
     
     rm bundle_temp.js
   else
     echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones disponibles${endColour}"
     sleep 1

     rm bundle.js && mv bundle_temp.js bundle.js
     echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos han sido actualizados${endColour}"
   fi

   tput cnorm 
 fi


}

function searchMachine (){
  machineName="$1" #con el $1 estoy recogiendo la cadena de texto que se ha añadido en este caso el nombre de la maquina Tentacle por ejemplo
  nameMaquina_check="$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' |tr -d ',' | sed 's/^ *//')"

  if [ ! "$nameMaquina_check" ]; then
    echo -e "\n${redColour}[!] La maquina introducida no se ha encontrado ${endColour}\n"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' |tr -d ',' | sed 's/^ *//'
  fi
}

function searchIP(){
  ipAdress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [ ! $machineName ]; then
    echo -e "\n${redColour}[!] La ip introducida no se ha encontrado ${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}$ipAdress ${endColour} ${grayColour}es:${endColour} ${purpleColour}$machineName${endColour}\n"
  fi
}

function getYoutubeLink(){
 machineName="$1"         #Recuerda el awk /name: /,/resuelta:/ esto va a coger todo lo que haya entre medias de name: y resuelta:
 youtubeLink_check="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
 
 if [ "$youtubeLink_check" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para realizar la maquina esta en este link:${endColour} ${blueColour}$youtubeLink_check${endColour}\n"
 else
   echo -e "\n${redColour}[!] EL link para esta maquina no existe${endColour}"
 fi
}

function searchDificultad(){
  dificultad="$1"
  dificultad_check="$(cat bundle.js | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
 
 if [ "$dificultad_check" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas de dificultad${endColour} ${greenColour}$dificultad${endColour} ${grayColour}son:${endColour}\n"
   echo -e "$dificultad_check"
 else
   echo -e "\n${redColour}[!] La dificuktad introducida no existe${endColour}"
 fi
  
}

function getOsMachine(){
  os="$1"
  os_check="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | sort | column)"
   
  if [ "$os_check" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con sistema operativo${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n"
   echo -e "$os_check"
  else
   echo -e "\n${redColour}[!] El sistema operativo introducido no existe${endColour}\n"
  fi  
}

function getDificultadOsMachine(){
  dificultad="$1"
  os="$2"
  maquinasDiffOs="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | sort | column)"

  if [ "$dificultad" ] && [ "$os" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas de nivel ${endColour} ${blueColour}$dificultad${endColour} y con sistema operativo ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n"
   echo -e "\n$maquinasDiffOs\n"
  else
   echo -e "\n${redColour}[!] El sistema operativo introducido o la dificultad no existe${endColour}\n"
  fi  

}

# Indicadores

declare -i parameter_counter=0 #-i indica que es un integer

# Chivatos

declare -i chivato_dificultad=0
declare -i chivato_os=0

#Con esto hacemos un menu llamando al script y pasandole -m para ver una maquina o -h para ver un panel de ayuda
while getopts "m:ui:d:o:y:h" arg; do #se pone los : cuando el parametro va a recibir algun argumento en este caso -m "pepito"
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;; #Con OPTARG permito que se ingrese el nombre que se va a buscar -m Tentacle por ejemplo
    u) let parameter_counter+=2;;
    i) ipAdress="$OPTARG"; let parameter_counter+=3;;
    d) dificultad="$OPTARG"; chivato_dificultad=1; let parameter_counter+=4;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=5;;
    y) machineName="$OPTARG"; let parameter_counter+=6;;
    h) ;;  
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName

elif [ $parameter_counter -eq 2 ]; then
  updateFiles

elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress

elif [ $parameter_counter -eq 4 ]; then
  searchDificultad $dificultad

elif [ $parameter_counter -eq 5 ]; then
  getOsMachine $os

elif [ $parameter_counter -eq 6 ]; then
  getYoutubeLink $machineName

elif [ $chivato_dificultad -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getDificultadOsMachine $dificultad $os

else
  helpPanel
fi
  

