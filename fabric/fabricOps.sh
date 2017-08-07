#!/bin/bash

. ./scripts/channelname.sh

PROJECT_DIR=$PWD

ARGS_NUMBER="$#"
COMMAND="$1"
ARG_1="$2"
ARG_2="$3"

usage_message="Useage: $0 start | status | clean | cli | peer | ccview <cc id> <cc version>"

function verifyArg() {

    if [ $ARGS_NUMBER -gt 3 -a $ARGS_NUMBER -lt 1 ]; then
        echo $usage_message
        exit 1;
    fi
}

function verifyGOPATH(){

    if [ -z "$GOPATH" ]; then
        echo "Please set GOPATH"
        exit 1
    fi
}

OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric

function pullDockerImages(){
  local FABRIC_TAG="x86_64-1.0.0"
  for IMAGES in peer orderer ccenv tools; do
      echo "==> FABRIC IMAGE: $IMAGES"
      echo
      docker pull hyperledger/fabric-$IMAGES:$FABRIC_TAG
      docker tag hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
  done
}

function generateCerts(){

    if [ ! -f $GOPATH/bin/cryptogen ]; then
        go get github.com/hyperledger/fabric/common/tools/cryptogen
    fi
    
    echo
	echo "----------------------------------------------------------"
	echo "----- Generate certificates using cryptogen tool ---------"
	echo "----------------------------------------------------------"
	if [ -d ./crypto-config ]; then
		rm -rf ./crypto-config
	fi

    $GOPATH/bin/cryptogen generate --config=./crypto-config.yaml
    echo
}


function generateChannelArtifacts(){

    if [ ! -d ./channel-artifacts ]; then
		mkdir channel-artifacts
	fi

	if [ ! -f $GOPATH/bin/configtxgen ]; then
        go get github.com/hyperledger/fabric/common/configtx/tool/configtxgen
    fi

    echo
	echo "-----------------------------------------------------------------"
	echo "--- Generating channel configuration transaction 'channel.tx' ---"
	echo "-----------------------------------------------------------------"

    $GOPATH/bin/configtxgen -profile MyOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

    echo
	echo "-------------------------------------------------"
	echo "--- Generating anchor peer update for Org1MSP ---"
	echo "-------------------------------------------------"
    $GOPATH/bin/configtxgen -profile MyOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNELNAME

}

function startNetwork() {

    echo
    echo "----------------------------"
    echo "--- Starting the network ---"
    echo "----------------------------"
    cd $PROJECT_DIR
    docker-compose up -d

    echo
    echo "----------------------------"
    echo "--- Initialising network ---"
    echo "----------------------------"
    docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c $CHANNELNAME -f /etc/hyperledger/channel-artifacts/channel.tx
    docker exec peer0.org1.example.com peer channel join -b $CHANNELNAME.block

}

function cleanNetwork() {
    cd $PROJECT_DIR
    
    if [ -d ./channel-artifacts ]; then
            rm -rf ./channel-artifacts
    fi

    if [ -d ./crypto-config ]; then
            rm -rf ./crypto-config
    fi

    if [ -d ./tools ]; then
            rm -rf ./tools
    fi

    # This operations removes all docker containers and images regardless
    #
    docker rm -f $(docker ps -aq)
    docker rmi -f $(docker images -q)
    
    # This removes containers used to support the running chaincode.
    #docker rm -f $(docker ps --filter "name=dev" --filter "name=peer0.org1.example.com" --filter "name=cli" --filter "name=orderer.example.com" -q)

    # This removes only images hosting a running chaincode, and in this
    # particular case has the prefix dev-* 
    #docker rmi $(docker images | grep dev | xargs -n 1 docker images --format "{{.ID}}" | xargs -n 1 docker rmi -f)
}

function networkStatus() {
    docker ps --format "{{.Names}}: {{.Status}}" | grep '[peer0* | orderer* | cli ]' 
}

function dockerCli(){
    docker exec -it cli /bin/bash
}

function ccview(){
    docker logs dev-peer0.org1.example.com-$1-$2
}

function downloadExampleChaincodes(){ 
    if [ ! -d $GOPATH/src/github.com/hlf-go/example-chaincodes ]; then
        go get -d github.com/hlf-go/example-chaincodes
    fi
}

# Network operations
verifyArg
verifyGOPATH
downloadExampleChaincodes
case $COMMAND in
    "start")
        generateCerts
        generateChannelArtifacts
        pullDockerImages
        startNetwork
        ;;
    "status")
        networkStatus
        ;;
    "clean")
        cleanNetwork
        ;;
    "cli")
        dockerCli
        ;;
    "ccview")
        if [ $ARGS_NUMBER -ne 3 ]; then
            echo $ARGS_NUMBER
            exit 1
        fi
        ccview $ARG_1 $ARG_2
        ;;
    *)
        echo $usage_message
        exit 1
esac

