#!/bin/bash

set -e

PROJECT_DIR=$PWD

ARGS_NUMBER="$#"
FIRST_ARG="$1"

function verifyArg() {

    if [ $ARGS_NUMBER -ne 1 ]; then
        echo "Useage: networkOps.sh start | status | clean | cli | peer"
        exit 1;
    fi
}

function createTools(){

    echo
    echo "================================================="
    echo "---------- Creating fabric tools ----------------"
    echo "================================================="
    echo

    cd $PROJECT_DIR
    if [ ! -d ./tools ]; then
        mkdir ./tools
    fi
    
    cd $GOPATH/src/github.com/hyperledger/fabric
    make configtxgen
    make cryptogen

    cp ./build/bin/configtxgen  $PROJECT_DIR/tools/
    cp ./build/bin/cryptogen  $PROJECT_DIR/tools/
}

function generateCerts(){
    cd $PROJECT_DIR
    if [ -f ./tools/cryptogen ]; then
        ./tools/cryptogen generate --config=./crypto-config.yaml
    else
        echo "Unable to generate cert"
        exit 1
    fi
}


function generateChannelArtifacts(){

    cd $PROJECT_DIR
    if  [ -f ./tools/configtxgen ]; then

        if [ ! -d ./channel-artifacts ]; then
            mkdir channel-artifacts
        fi

        ./tools/configtxgen -profile MyOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
        ./tools/configtxgen -profile MyOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID "mychannel"

    else
        echo "Unable to generate channel artefacts"
        exit 1
    fi

}

function generateArtifacts() {

    echo
    echo "================================================="
    echo "------ Generating Fabric network artefacts ------"
    echo "================================================="
    echo

    cd $PROJECT_DIR
    if [ -d ./tools ]; then
        generateCerts
        generateChannelArtifacts
    else
        echo "Unable to generate certs and channel artifacts"
        exit 1
    fi

}

function startNetwork() {

    echo
    echo "================================================="
    echo "---------- Starting the network -----------------"
    echo "================================================="
    echo

    cd $PROJECT_DIR
    docker-compose up -d
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

    cd $GOPATH/src/github.com/hyperledger/fabric
    make clean

    # This operations removes all docker containers and images regardless
    #
    # docker rm -f $(docker ps -aq)
    # docker rmi -f $(docker images -q)
    
    # This removes containers used to support the running chaincode.
    docker rm -f $(docker ps --filter "name=dev" --filter "name=peer0.org1.example.com" --filter "name=cli" --filter "name=orderer.example.com" -q)

    # This removes only images hosting a running chaincode, and in this
    # particular case has the prefix dev-* 
    docker rmi $(docker images | grep dev | xargs -n 1 docker images --format "{{.ID}}" | xargs -n 1 docker rmi -f)
}

function networkStatus() {
    docker ps --format "{{.Names}}: {{.Status}}" | grep '[peer0* | orderer* | cli ]' 
}

function dockerCli(){
    docker exec -it cli /bin/bash
}

# Network operations
verifyArg
case $FIRST_ARG in
    "start")
        createTools
        generateArtifacts
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
    *)
        echo "Useage: networkOps.sh start | status | clean | cli "
        exit 1;
esac

