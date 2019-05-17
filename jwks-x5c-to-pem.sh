#!/bin/bash

set -e -o pipefail

function show_help {
  echo $0
  echo "-h Show help"  
  echo "-f Input file, Required"
  echo "-c Number only - x5c array item to extract, Required."
  echo "-k Number only - key array item to extract. Optional, if empty will assume this is a JWK not a JWKS."
  echo "E.g."
  echo "./jwks-x5c-to-pem.sh -f test.jwks -k 0 -c 1"
}


while getopts "h?f:c:k:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    f)  INPUT_FILE=${OPTARG}
        ;;
    c)  CHAIN_ITEM=$OPTARG
        ;;
    k)  KEY=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))

GET_KEY=""
if [ ! -z $KEY ]; then
   GET_KEY=".keys[${KEY}]"
fi

CERT=$(cat $INPUT_FILE | jq -r "$GET_KEY.x5c[${CHAIN_ITEM}]" | sed 's/-----.* CERTIFICATE-----//g'  | fold -w 63)
echo -e -n "-----BEGIN CERTIFICATE-----\n${CERT}\n-----END CERTIFICATE-----"
