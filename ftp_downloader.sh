#!/bin/bash
LINK_EXTERNAL_FTP=
LINK_INTERNAL_FTP=
USER_EXTERNAL_FTP=
PASSWORD_EXTERNAL_FTP=
USER_INTERNAL_FTP=
PASSWORD_INTERNAL_FTP=
PATH_EXTERNAL_FTP=''
PATH_INTERNAL_FTP=''
TIME_OUT_CURL=60

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
      -to|--timeout) TIME_OUT_CURL="$2"; shift
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

function downloadAndUploadFile(){
 line=$1
 echo ""
 echo "==========================="
 log "INFO" "Start process File: $line "
 echo ""
 log "INFO" "Trying to download file: $line FROM $LINK_EXTERNAL_FTP"
 if $(curl --fail $LINK_EXTERNAL_FTP$PATH_EXTERNAL_FTP$line --connect-timeout $TIME_OUT_CURL --user $USER_EXTERNAL_FTP:$PASSWORD_EXTERNAL_FTP -o $line);then
   echo ""
   log "INFO" "File download: $line OK!"
   log "INFO" "Trying to upload file: $line to ftp $LINK_INTERNAL_FTP"
   echo ""

   if $(curl --fail -T $line $LINK_INTERNAL_FTP$PATH_INTERNAL_FTP --connect-timeout $TIME_OUT_CURL --user $USER_INTERNAL_FTP:$PASSWORD_INTERNAL_FTP);then
     echo ""
     log "INFO" "File upload : $line OK!"
   else
     log "ERROR" "Failed upoad file: $line"
   fi

 else
   log "ERROR" "Failed download file: $line"
 fi
 echo ""
 log "INFO" "End process File: $line "
 echo "==========================="

 rm -f $line
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
  echo "  -to  | --timeout: time out per request (optional). Default value: $TIME_OUT_CURL"

  echo "#################"
  exit 1
}

function log() {
  echo "$(date +%Y-%m-%d'T'%H:%M:%S)" $@
}

##############
## Main
##############
parseValidArguments $@
validateArguments

log "INFO" "INFO PARAMS"
log "INFO" "=================="
log "INFO" "Link external ftp: $LINK_EXTERNAL_FTP"
#log "INFO" "Username external ftp $USER_EXTERNAL_FTP"
log "INFO" "Path external Ftp: $PATH_EXTERNAL_FTP"
log "INFO" "Link internal ftp: $LINK_INTERNAL_FTP"
#log "INFO" "Username internal ftp $USER_INTERNAL_FTP"
log "INFO" "Path internaL Ftp: $PATH_INTERNAL_FTP"
log "INFO" "=================="

echo "###########"
LIST_EXTERNAL_FTP=$( curl $LINK_EXTERNAL_FTP$PATH_EXTERNAL_FTP --connect-timeout $TIME_OUT_CURL --user $USER_EXTERNAL_FTP:$PASSWORD_EXTERNAL_FTP -ll)
LIST_INTERNAL_FTP=$( curl $LINK_INTERNAL_FTP$PATH_INTERNAL_FTP --connect-timeout $TIME_OUT_CURL --user $USER_INTERNAL_FTP:$PASSWORD_INTERNAL_FTP -ll)

echo "$LIST_EXTERNAL_FTP" >> "$FILE_EXTERNAL_LIST"
echo "$LIST_INTERNAL_FTP" >> "$FILE_INTERNAL_LIST"

while IFS= read -r line
do
  result=$(grep -c $line "$FILE_INTERNAL_LIST")
  if [ $result != "0" ];then
    log "INFO" "File: $line already exists"
  else
    downloadAndUploadFile $line
  fi
  echo ""

done <"$FILE_EXTERNAL_LIST"

rm -f "$FILE_EXTERNAL_LIST"
rm -f "$FILE_INTERNAL_LIST"

##############
## End Main
##############
