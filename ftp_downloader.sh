#!/bin/bash

LINK_FTP_EXTERNO='ftp://sftp.despegar.com/upload/'
LINK_FTP_INTERNO='ftp://10.254.22.99/'
USER_FTP_EXTERNO=worldpay
PASSWORD_FTP_EXTERNO=gj45Gxn7Df
USER_FTP_INTERNO=test
PASSWORD_FTP_INTERNO=test
PATH_EXTERNAL_FTP=''
PATH_INTERNAL_FTP=''


FILE_LISTADO_EXTERNO=listado_ftp_externo.dat
FILE_LISTADO_INTERNO=listado_ftp_interno.dat


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
      -pef|--pathexternalftp) PATH_EXTERNAL_FTP="$2"; shift
      ;;
      -pif|--pathinternalftp) PATH_INTERNAL_FTP="$2"; shift
      ;;
      -h|--help) help
      ;;
      *) break
    esac
    shift
  done
}

function help() {
  echo "#################"

  echo "Options you can use:"
  echo "  -h   | --help : this help"
  echo "  -fe  | --ftpexterno : external ftp link to connect"
  echo "  -fi  | --ftpinterno : internal ftp link to connect"
  echo "  -ufi | --userftpexterno : username external ftp "
  echo "  -ufe | --userftpinterno : username internal ftp "
  echo "  -pfe | --passwordftpexterno: password external ftp"
  echo "  -pfi | --passwordftpinterno: password internal ftp"
  echo "  -pef | --pathexternalftp: path external ftp. Default value: $PATH_EXTERNAL_FTP"
  echo "  -pif | --pathinternalftp: path internal ftp. Default value: $PATH_INTERNAL_FTP"


  echo "#################"
  exit 1
}


##############
## Main
##############
  parseValidArguments $@

  printf "\n Iniciando proceso\n"
     LISTADO_FTP_EXTERNO=$( curl $LINK_FTP_EXTERNO$PATH_EXTERNAL_FTP  --user $USER_FTP_EXTERNO:$PASSWORD_FTP_EXTERNO -ll)
     LISTADO_FTP_INTERNO=$( curl $LINK_FTP_INTERNO$PATH_INTERNAL_FTP  --user $USER_FTP_INTERNO:$PASSWORD_FTP_INTERNO -ll)

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
            curl $LINK_FTP_EXTERNO$PATH_EXTERNAL_FTP$line  --user worldpay:gj45Gxn7Df -o $line
            curl -T   $line $LINK_FTP_INTERNO$PATH_INTERNAL_FTP --user test:test
            rm -f $line
        fi

      done <"$FILE_LISTADO_EXTERNO"

      rm -f "$FILE_LISTADO_EXTERNO"
      rm -f "$FILE_LISTADO_INTERNO"


