#!/bin/bash

##############
## Main
##############

if [ "$1" == "-help" ]
then
  printf "\n#\n"
  printf "\nEl script lista la carperta de nuevos del ftp, descarga"
  printf "\nlos archivos y los mueve a la carpeta de consumidos"
else
  LINK_FTP_EXTERNO='ftp://sftp.despegar.com/upload/'
  LINK_FTP_ATALAYA='ftp://10.254.22.99/'

  printf "\n Iniciando proceso\n"
     LISTADO_FTP_EXTERNO=$( curl $LINK_FTP_EXTERNO  --user worldpay:gj45Gxn7Df -ll)
     LISTADO_FTP_ATLAYA=$( curl $LINK_FTP_ATALAYA  --user test:test -ll)

     echo "$LISTADO_FTP_EXTERNO" >> listado_ftp_externo.dat
     echo "$LISTADO_FTP_ATLAYA" >> listado_ftp_ATALAYA.dat

     file="listado_ftp_externo.dat"
      while IFS= read -r line
      do
        result=$(grep -c $line "listado_ftp_ATALAYA.dat")
      if [ $result != "0" ]
        then
            printf '\nYa existe el archivo\n'
            printf '\n %s' "$line"

        else
          #	printf '\n %s' "$line"
            printf '\nSe va a descargar archivo: \n'
            echo "$line"
            printf '\n'
            curl $LINK_FTP_EXTERNO$line  --user worldpay:gj45Gxn7Df -o $line
            curl -T   $line $LINK_FTP_ATALAYA --user test:test
            rm -f $line
        fi

      done <"$file"

      rm -f "listado_ftp_externo.dat"
      rm -f "listado_ftp_ATALAYA.dat"


fi