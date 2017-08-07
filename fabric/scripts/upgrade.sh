#!/bin/bash

. ./scripts/channelname.sh

function usage(){ 
    echo "Usage: $0 <arguments>"
    echo "Usage: $0 <flags>"
    echo "Mandatory:"
    echo "   -c <cc id>         A unique string identifier"
    echo "   -v <cc version>    A numeric number"
    echo "   -p <cc package>    A name of folder containing chaincodes"
    echo "Optional:"
    echo "   -a <cc argment>   <cc argument> must be in the form [\"method\", \"method-arg-1\", \"method-arg-2\"]"
}

if [ "$#" -eq "0" ]; then  
    usage
    exit
fi

while getopts "a:c:p:v:" opt; do
  case $opt in
    a)
      CHAINCODE_CONSTRUCTOR=$OPTARG
      ;;
    c)
      CHAINCODEID=$OPTARG
      ;;
    p)
      CCHAINCODE_PACKAGE=$OPTARG
      ;;
    v)
      CHAINCODE_VERSION=$OPTARG
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

if [[ ! -z $CHAINCODE_VERSION && ! -z $CHAINCODEID && ! -z $CCHAINCODE_PACKAGE ]]; then

    path_to_chaincode="github.com/hyperledger/fabric/examples/chaincode/go/$CCHAINCODE_PACKAGE"
    echo "INSTALLING chaincode $CHAINCODEID version $CHAINCODE_VERSION in $path_to_chaincode"
    echo
    peer chaincode install -n $CHAINCODEID -v $CHAINCODE_VERSION -p $path_to_chaincode

    echo "UPGRADING chaincode $CHAINCODEID to version $CHAINCODE_VERSION"
    echo "in $CHANNELNAME"
    echo "with constructor $CHAINCODE_CONSTRUCTOR"
    constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

    peer chaincode upgrade -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -v $CHAINCODE_VERSION -c $constructor
else
  usage
fi

