#!/bin/bash

. ./scripts/channelname.sh

function usage(){ 
    echo "Usage: $0 <flags>"
    echo "Mandatory:"
    echo "   -c <cc id> A unique string identifier"
    echo "Optional:"
    echo "   -a <cc constructor>   Must be in the form [\"method\", \"method-arg-1\", \"method-arg-2\"]"
}

if [ "$#" -eq "0" ]; then  
    usage
    exit 1
fi

while getopts "a:c:" opt; do
  case $opt in
    a)
      CHAINCODE_CONSTRUCTOR=$OPTARG
      ;;
    c)
      CHAINCODEID=$OPTARG
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      usage
      exit 1
      ;;
  esac
done

if [ -z $CHAINCODE_CONSTRUCTOR ]; then
  CHAINCODE_CONSTRUCTOR="[]"
fi

if [ ! -z $CHAINCODEID ]; then
  echo "INVOKING chaincode $CHAINCODEID in $CHANNELNAME"
  constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"
  echo "with constructor $constructor"
  peer chaincode invoke -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -c $constructor
else
  usage
fi 
