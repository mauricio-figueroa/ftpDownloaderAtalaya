#!/bin/bash
LINK_EXTERNAL_FTP=
LINK_INTERNAL_FTP=
USER_EXTERNAL_FTP=
PASSWORD_EXTERNAL_FTP=
USER_INTERNAL_FTP=
PASSWORD_INTERNAL_FTP=
PATH_EXTERNAL_FTP=''
PATH_INTERNAL_FTP=''

FILE_EXTERNAL_LIST=list_external_ftp.dat
FILE_INTERNAL_LIST=list_internal_ftp.dat

function parseValidArguments() {
  while :; do
    case $1 in
      -fe|--ftpexterno) LINK_EXTERNAL_FTP="$2"; shift
      ;;
      -ufe|--userftpexterno) USER_EXTERNAL_FTP="$2"; shift
      ;;
      -pfe|--passwordftpexterno) PASSWORD_EXTERNAL_FTP="$2"; shift
      ;;
      -fi|--ftpinterno) LINK_INTERNAL_FTP="$2"; shift
      ;;
      -ufi|--userftpinterno) USER_INTERNAL_FTP="$2"; shift
      ;;
      -pfi|--passwordftpinterno) PASSWORD_INTERNAL_FTP="$2"; shift
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
  if [[ -z "$LINK_EXTERNAL_FTP" ]]; then
    echo "Link external ftp required ( Param: -fe or--ftpexterno)"
    exit 1;
  fi

  if [[ -z "$LINK_INTERNAL_FTP" ]]; then
    echo "Link internal ftp required ( Param: -fi or--ftpinterno)"
    exit 1;
  fi

  if [[ -z "$USER_EXTERNAL_FTP" ]]; then
    echo "User external ftp required ( Param: -ufe or--userftpexterno)"
    exit 1;
  fi

  if [[ -z "$USER_INTERNAL_FTP" ]]; then
    echo "User internal ftp required ( Param: -ufi or--userftpinterno)"
    exit 1;
  fi

  if [[ -z "$PASSWORD_EXTERNAL_FTP" ]]; then
    echo "Password external ftp required ( Param: -pfe or--pathexternalftp)"
    exit 1;
  fi

  if [[ -z "$PASSWORD_INTERNAL_FTP" ]]; then
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

  echo "###########"
     LISTADO_FTP_EXTERNO=$( curl $LINK_EXTERNAL_FTP$PATH_EXTERNAL_FTP  --user $USER_EXTERNAL_FTP:$PASSWORD_EXTERNAL_FTP -ll)
     LISTADO_FTP_INTERNO=$( curl $LINK_INTERNAL_FTP$PATH_INTERNAL_FTP  --user $USER_INTERNAL_FTP:$PASSWORD_INTERNAL_FTP -ll)

     echo "$LISTADO_FTP_EXTERNO" >> "$FILE_EXTERNAL_LIST"
     echo "$LISTADO_FTP_INTERNO" >> "$FILE_INTERNAL_LIST"


      while IFS= read -r line
      do
        result=$(grep -c $line "$FILE_INTERNAL_LIST")
      if [ $result != "0" ]
        then
            echo "Ya existe el archivo: $line"
        else
            echo "Se va a descargar archivo: $line"
            curl $LINK_EXTERNAL_FTP$PATH_EXTERNAL_FTP$line  --user $USER_EXTERNAL_FTP:$PASSWORD_EXTERNAL_FTP -o $line
            curl -T   $line $LINK_INTERNAL_FTP$PATH_INTERNAL_FTP --user $USER_INTERNAL_FTP:$PASSWORD_INTERNAL_FTP
            rm -f $line
        fi

      done <"$FILE_EXTERNAL_LIST"

      rm -f "$FILE_EXTERNAL_LIST"
      rm -f "$FILE_INTERNAL_LIST"
