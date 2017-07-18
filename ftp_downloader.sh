#!/bin/bash

LINK_FTP_EXTERNO='ftp://sftp.despegar.com/upload/'
LINK_FTP_INTERNO='ftp://10.254.22.99/'
USER_FTP_EXTERNO=worldpay
PASSWORD_FTP_EXTERNO=gj45Gxn7Df
USER_FTP_INTERNO=test
PASSWORD_FTP_INTERNO=test

FILE_LISTADO_EXTERNO=listado_ftp_externo.dat
FILE_LISTADO_INTERNO=listado_ftp_interno.dat



#function help() {
#  echo "Options you can use:"
#  echo "  -h | --help : this help"
#  echo "  -p | --password : password to authorize against cassandra. Default value: cassandra"
#  echo "  -u | --user : username to authorize against cassandra. Default value: cassandra"
#  echo "  -rt | --repairtrigger : threshold to trigger a repair over keyspace's columnfamily. Default value: 80"
#  echo "  -w | --workers : number of workers to use for parallelism. Default value: 1"
#  echo "  -k | --keyspace : keyspace name. Default value: ALL"
#  echo "  -cf | --columnfamily: columnfamily name. Default value: ALL"
#  echo "  -c | --check : omit all other options, just check on log if it run ok based on log"
#  exit 1
#}


function parseValidArguments() {
  while :; do
    case $1 in
      -fe|--ftpexterno) LINK_FTP_EXTERNO="$2"; shift
      ;;
      -ufe|--userftpexterno) USER_FTP_EXTERNO="$2"; shift
      ;;
      -pfe|--passwordftpexterno) PASSWORD_FTP_EXTERNO="$2"; shift
      ;;
      -fi|--ftpinterno) LINK_FTP_INTERNO="$2"; shift
      ;;
      -ufi|--userftpinterno) USER_FTP_INTERNO="$2"; shift
      ;;
      -pfi|--passwordftpinterno) PASSWORD_FTP_INTERNO="$2"; shift
      ;;
      -h|--help) help
      ;;
      *) break
    esac
    shift
  done
}

function help() {
  echo "Options you can use:"
  echo "  -h   | --help : this help"
  echo "  -fe  | --ftpexterno : external ftp link to connect"
  echo "  -fi  | --ftpinterno : internal ftp link to connect"
  echo "  -ufi | --userftpexterno : username external ftp "
  echo "  -ufe | --userftpinterno : username internal ftp "
  echo "  -pfe | --passwordftpexterno: password external ftp"
  echo "  -pfi | --passwordftpinterno: password internal ftp"

  echo "############"
  echo "No se toma ningun valor por default se deben ingrear todos los prametros para que el script funcione correctamente"
  exit 1
}





##############
## Main
##############
  parseValidArguments $@

  printf "\n Iniciando proceso\n"
     LISTADO_FTP_EXTERNO=$( curl $LINK_FTP_EXTERNO  --user $USER_FTP_EXTERNO:$PASSWORD_FTP_EXTERNO -ll)
     LISTADO_FTP_INTERNO=$( curl $LINK_FTP_INTERNO  --user $USER_FTP_INTERNO:$PASSWORD_FTP_INTERNO -ll)

     echo "$LISTADO_FTP_EXTERNO" >> "$FILE_LISTADO_EXTERNO"
     echo "$LISTADO_FTP_INTERNO" >> "$FILE_LISTADO_INTERNO"


      while IFS= read -r line
      do
        result=$(grep -c $line "$FILE_LISTADO_INTERNO")
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
            curl -T   $line $LINK_FTP_INTERNO --user test:test
            rm -f $line
        fi

      done <"$FILE_LISTADO_EXTERNO"

      rm -f "$FILE_LISTADO_EXTERNO"
      rm -f "$FILE_LISTADO_INTERNO"


