#!/bin/bash
LINK_FTP_EXTERNO=
LINK_FTP_INTERNO=
USER_FTP_EXTERNO=
PASSWORD_FTP_EXTERNO=
USER_FTP_INTERNO=
PASSWORD_FTP_INTERNO=
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

function validateArguments(){
  if [[ -z "$LINK_FTP_EXTERNO" ]]; then
    echo "Link external ftp required ( Param: -fe or--ftpexterno)"
    exit 1;
  fi

  if [[ -z "$LINK_FTP_INTERNO" ]]; then
    echo "Link internal ftp required ( Param: -fi or--ftpinterno)"
    exit 1;
  fi

  if [[ -z "$USER_FTP_EXTERNO" ]]; then
    echo "User external ftp required ( Param: -ufe or--userftpexterno)"
    exit 1;
  fi

  if [[ -z "$USER_FTP_INTERNO" ]]; then
    echo "User internal ftp required ( Param: -ufi or--userftpinterno)"
    exit 1;
  fi

  if [[ -z "$PASSWORD_FTP_EXTERNO" ]]; then
    echo "Password external ftp required ( Param: -pfe or--pathexternalftp)"
    exit 1;
  fi

  if [[ -z "$PASSWORD_FTP_INTERNO" ]]; then
    echo "Password internal ftp required ( Param: -pfi or--passwordftpinterno)"
    exit 1;
  fi

}

function help() {
  echo "#################"

  echo "Options you can use:"
  echo "  -h   | --help : this help"
  echo "  -fe  | --ftpexterno : external ftp link to connect (required)"
  echo "  -fi  | --ftpinterno : internal ftp link to connect (required)"
  echo "  -ufe | --userftpexterno : username external ftp (required)"
  echo "  -ufi | --userftpinterno : username internal ftp (required)"
  echo "  -pfe | --passwordftpexterno: password external ftp (required)"
  echo "  -pfi | --passwordftpinterno: password internal ftp (required)"
  echo "  -pef | --pathexternalftp: path external ftp (optional). Default value: $PATH_EXTERNAL_FTP"
  echo "  -pif | --pathinternalftp: path internal ftp (optional). Default value: $PATH_INTERNAL_FTP"

  echo "#################"
  exit 1
}

#TODO loguear bien y extraer a funciones
##############
## Main
##############
  parseValidArguments $@
  validateArguments

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
            echo "Ya existe el archivo: $line"
        else
            echo "Se va a descargar archivo: $line"
            curl $LINK_FTP_EXTERNO$PATH_EXTERNAL_FTP$line  --user $USER_FTP_EXTERNO:$PASSWORD_FTP_EXTERNO -o $line
            curl -T   $line $LINK_FTP_INTERNO$PATH_INTERNAL_FTP --user $USER_FTP_INTERNO:$PASSWORD_FTP_INTERNO
            rm -f $line
        fi

      done <"$FILE_LISTADO_EXTERNO"

      rm -f "$FILE_LISTADO_EXTERNO"
      rm -f "$FILE_LISTADO_INTERNO"
