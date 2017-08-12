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

function createLogFolder(){
    cd $PROJECT_DIR
    if [ ! -d ./logs ]; then
        mkdir ./logs
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

    if [ -d ./logs ]; then
            rm -rf ./logs
    fi

    cd $GOPATH/src/github.com/hyperledger/fabric
    make clean

    docker rm -f $(docker ps -aq)
    docker rmi -f $(docker images -q)
}

function networkStatus() {
    docker ps -a | grep '[peer0* | orderer* | cli ]'
}

function dockerCli(){
    docker exec -it cli /bin/bash
}

function dockerPeer(){
    docker logs peer0.org1.example.com -f
}

# Network operations
verifyArg
case $FIRST_ARG in
    "start")
        createLogFolder
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
    "peer")
        dockerPeer
        ;;
    *)
        echo "Useage: networkOps.sh start | status | clean | cli | peer"
        exit 1;
esac

