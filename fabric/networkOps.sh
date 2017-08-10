#!/bin/bash

set -e

PROJECT_DIR=$PWD

function createTools(){

    cd $PROJECT_DIR
    if [ ! -d ./tools ]; then
        mkdir ./tools
    fi
    
    echo "================================================="
    echo "Creating crypto tools and native fabric artifacts"
    echo "================================================="
    echo

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
        ./tools/configtxgen -profile MyOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel

    else
        echo "Unable to generate channel artefacts"
        exit 1
    fi

}

function generateArtifacts() {
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
    cd $PROJECT_DIR
    docker-compose up -d
}

createTools
generateArtifacts
startNetwork
